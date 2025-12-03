1.1 Триггер проверяющий, что баланс >=0
```sql
CREATE OR REPLACE FUNCTION steam.positive_wallet_balance()
RETURNS TRIGGER AS $$
BEGIN
    IF(NEW.wallet_balance < 0)
    THEN RAISE EXCEPTION 'Amount cannot be negative';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_update_account_balance
BEFORE UPDATE ON steam.accounts
FOR EACH ROW
EXECUTE FUNCTION steam.positive_wallet_balance();

UPDATE steam.accounts SET wallet_balance = 0
WHERE account_id = 1;
```

<img width="606" height="56" alt="image" src="https://github.com/user-attachments/assets/72e43f29-9480-465e-a956-039fadeab2f2" />

1.2 Триггер проверяющий, что achievement и ownership относятся к одной игре.
```sql
CREATE OR REPLACE FUNCTION steam.ownership_game_achievement_game()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT game_id
        FROM steam.account_game
        WHERE ownership_id = NEW.ownership_id)
        =  (SELECT game_id
        FROM steam.achievements
        WHERE achievements.achievement_id = NEW.achievement_id)
        THEN RETURN NEW;
    ELSE
        RAISE EXCEPTION 'Разные id игр';
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_insert_achievement_game
BEFORE INSERT ON steam.ownership_achievement
FOR EACH ROW
EXECUTE FUNCTION steam.ownership_game_achievement_game();

INSERT INTO steam.ownership_achievement(ownership_id, achievement_id) VALUES (2,40);
```

<img width="1048" height="62" alt="image" src="https://github.com/user-attachments/assets/1e78a3c6-4908-48ab-9c06-b5e0bfc1b301" />

1.3 Триггер, ставящий последнюю дату изменения пароля
```sql
ALTER TABLE steam.accounts
ADD password_updated_at TIMESTAMP;

CREATE OR REPLACE FUNCTION steam.set_password_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    IF(OLD.password <> NEW.password) THEN NEW.password_updated_at = CURRENT_DATE;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_update_account_password
BEFORE UPDATE ON steam.accounts
FOR EACH ROW
EXECUTE FUNCTION steam.set_password_updated_at();

UPDATE steam.accounts SET password = 'qwerty1'
WHERE account_id = 1;
```

<img width="1244" height="32" alt="image" src="https://github.com/user-attachments/assets/2d5d12dd-8e7e-4480-add5-8101cafb21e5" />

1.4 Триггер логирующий изменение баланса кошельков
```sql
CREATE TABLE steam.balance_log (
    account_id INT,
    old_balance INT,
    new_balance INT,
    change_time TIMESTAMP,
    CONSTRAINT account_id_fk FOREIGN KEY (account_id)
        REFERENCES steam.accounts(account_id)
);

CREATE OR REPLACE FUNCTION steam.insert_balance_log()
RETURNS TRIGGER AS $$
BEGIN
    IF(NEW.wallet_balance <> OLD.wallet_balance)
    THEN INSERT INTO steam.balance_log(account_id, old_balance, new_balance, change_time)
         VALUES(NEW.account_id, OLD.wallet_balance, NEW.wallet_balance, now());
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER after_update_account_balance
AFTER UPDATE ON steam.accounts
FOR EACH ROW
EXECUTE FUNCTION steam.insert_balance_log();

UPDATE steam.accounts SET wallet_balance = 171
WHERE account_id = 2;
```

<img width="937" height="64" alt="image" src="https://github.com/user-attachments/assets/8043eef1-e53e-4764-ab7f-e529146eabae" />

1.5 При обновлении отзыва дата меняется на текущую
```sql
CREATE OR REPLACE FUNCTION steam.update_review_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    IF (OLD.rating <> NEW.rating) || (OLD.comment <> NEW.comment) THEN
        NEW.review_date = CURRENT_DATE;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER review_update_trigger
    BEFORE UPDATE ON steam.reviews
    FOR EACH ROW
    EXECUTE FUNCTION steam.update_review_timestamp();
```


1.6 При испольнении любого запроса над таблицей accounts, в таблицу добавляется запись current_user, NOW(), tg_op
```sql

CREATE TABLE steam.query_history (
    account_name VARCHAR(255),
    query_time TIMESTAMP,
    operation VARCHAR(15)
);

CREATE OR REPLACE FUNCTION steam.insert_query_history()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO steam.query_history(account_name, query_time, operation)
     VALUES (current_user, NOW(), tg_op);
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER save_query_history
    AFTER DELETE OR INSERT OR UPDATE ON steam.accounts
    FOR EACH STATEMENT
    EXECUTE FUNCTION steam.insert_query_history();

UPDATE steam.accounts SET wallet_balance = 171
WHERE account_id = 2;
```

<img width="863" height="235" alt="image" src="https://github.com/user-attachments/assets/6a5634df-5533-4e46-8677-07d716c11b53" />

1.7 При удалении аккаунта, есть 30 дней на его восстановление
```sql
CREATE TABLE steam.deleting_account (
    account_id INT,
    request_date DATE,
    CONSTRAINT account_id_fk FOREIGN KEY (account_id)
        REFERENCES steam.accounts(account_id)
);

CREATE OR REPLACE FUNCTION steam.insert_deleting_accounts()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS(SELECT 1 FROM steam.deleting_account
       WHERE deleting_account.account_id = OLD.account_id)
       THEN IF EXISTS(SELECT 1 FROM steam.deleting_account
            WHERE CURRENT_DATE - deleting_account.request_date >= 30)
            THEN RETURN OLD;
            ELSE RAISE NOTICE 'Не прошло 30 дней';
            END IF;
    ELSE INSERT INTO steam.deleting_account(account_id, request_date) VALUES (OLD.account_id, current_date);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER before_delete_account
    BEFORE DELETE ON steam.accounts
    FOR EACH ROW
    EXECUTE FUNCTION steam.insert_deleting_accounts();

INSERT INTO steam.accounts(account_id, username, email, password, wallet_balance, password_updated_at)
VALUES (100, '1', '1', '1', 1, NOW());

INSERT INTO steam.account_game(account_id, game_id) VALUES (100, 1);

DELETE FROM steam.accounts WHERE account_id = 100;
```

<img width="539" height="61" alt="image" src="https://github.com/user-attachments/assets/01ef3531-cf4c-4f6d-a870-b9444a0361ed" />

1.8 Все триггеры
```sql
SELECT *
FROM information_schema.triggers;
```

<img width="1793" height="386" alt="image" src="https://github.com/user-attachments/assets/09bfe099-0572-41b3-b7de-98d6caa0a7db" />

2.1 Крон удаляет старые логи
```sql
SELECT cron.schedule(
    'cleanup_old_logs',
    '0 0 * * *',
    'DELETE FROM balance_log WHERE change_time < NOW() - INTERVAL ''30 days'''
);
```


2.2 
```sql

CREATE TABLE steam.game_stats (
    game_id INT,
    copies_bought INT,
    sum_price INT,
    CONSTRAINT game_id_fk FOREIGN KEY (game_id)
        REFERENCES steam.games(game_id),
    CONSTRAINT  game_stats_pk PRIMARY KEY (game_id)
);

CREATE OR REPLACE PROCEDURE steam.upsert_game_stats()
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE steam.game_stats SET copies_bought = a.copies_bought, sum_price = a.sum_price
    FROM  (SELECT games.game_id, COUNT(*) as copies_bought, COUNT(*) * price as sum_price FROM steam.games
    JOIN steam.account_game ag on games.game_id = ag.game_id
    WHERE games.game_id IN(SELECT game_stats.game_id FROM steam.game_stats)
    GROUP BY games.game_id) as a
    WHERE a.game_id = game_stats.game_id;

    INSERT INTO steam.game_stats(game_id, copies_bought, sum_price)
    SELECT games.game_id, COUNT(*) as copies_bought, COUNT(*) * price as sum_price FROM steam.games
    JOIN steam.account_game ag on games.game_id = ag.game_id
    WHERE games.game_id NOT IN(SELECT game_stats.game_id FROM steam.game_stats)
    GROUP BY games.game_id;
END;
$$;


CALL steam.upsert_game_stats();

SELECT cron.schedule(
    'update_statistics',
    '0 * * * *',
    $$
        CALL steam.upsert_game_stats();
    $$
);
```

2.3 Крон удаляющий пользователей, у которых с запроса на удаление аккаунта прошло 30 дней
```sql
SELECT cron.schedule(
    'delete_accounts',
    '0 0 * * *',
    $$
        DELETE FROM steam.deleting_account WHERE CURRENT_DATE - request_date >= 30;
    $$
);
```

2.4 Все кроны
```sql
SELECT * FROM cron.job;
```
<img width="1792" height="408" alt="image" src="https://github.com/user-attachments/assets/9123fb76-81c7-43e2-a2c7-1a37ea1bde79" />

```sql
SELECT * FROM cron.job_run_details;
```
