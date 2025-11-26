1.1 Обновить цену
```sql
CREATE OR REPLACE PROCEDURE steam.update_game_price(
    game_id int,
    new_price int
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE steam.games
    SET price = new_price
    WHERE games.game_id = update_game_price.game_id;
END;
$$;

CALL steam.update_game_price(26,11501);
```

<img width="644" height="31" alt="image" src="https://github.com/user-attachments/assets/2ca0ce53-bf32-4cb8-8099-56cb2b3a916d" />


1.2 Добавить отзыв или обновить, если есть
```sql
CREATE OR REPLACE PROCEDURE steam.upsert_review(
    new_game_id int,
    new_account_id int,
    new_rating boolean,
    new_comment varchar,
    new_review_date date
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO steam.reviews (game_id, account_id, rating, comment, review_date)
    VALUES (new_game_id, new_account_id, new_rating, new_comment, new_review_date);
EXCEPTION
    WHEN unique_violation THEN
        UPDATE steam.reviews
        SET rating = new_rating,
            comment = new_comment,
            review_date = new_review_date
        WHERE game_id = new_game_id AND account_id = new_account_id;
END;
$$;


CALL steam.upsert_review(1,1, true, '.', '2025-11-11');
```

<img width="807" height="28" alt="image" src="https://github.com/user-attachments/assets/3af2b184-85d9-4b89-87a1-566840264e05" />


1.3 Добавить достижение с проверкой, что у достижения и ownership одна и та же игра
```sql
CREATE OR REPLACE PROCEDURE steam.insert_ownership_achievement(
    new_ownership_id int,
    new_achievement_id int
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF (SELECT game_id
        FROM steam.account_game
        WHERE ownership_id = new_ownership_id)
        =  (SELECT game_id
        FROM steam.achievements
        WHERE achievements.achievement_id = new_achievement_id)
        THEN INSERT INTO steam.ownership_achievement(ownership_id, achievement_id)
        VALUES (new_ownership_id, new_achievement_id);
    ELSE
        RAISE NOTICE 'Разные id игр';
    END IF;
END;
$$;

CALL steam.insert_ownership_achievement(2,44);
```

<img width="520" height="90" alt="image" src="https://github.com/user-attachments/assets/8c351b5b-9781-4269-9216-8c96b7692510" />

1.4 Все процедуры
```sql
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_type = 'PROCEDURE' AND routine_schema = 'steam';
```

<img width="656" height="126" alt="image" src="https://github.com/user-attachments/assets/2fd3d656-cca3-4c72-b0c9-5a2e78876089" />


2.1 Сколько денег пользователь потратил на игры
```sql
CREATE OR REPLACE FUNCTION steam.sum_spent_on_games_by_user(new_user_id INT)
RETURNS INT
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN (SELECT SUM(price) FROM steam.account_game
    JOIN steam.games g on g.game_id = account_game.game_id
    WHERE account_id = new_user_id);
END;
$$;

SELECT steam.sum_spent_on_games_by_user(10);
```

<img width="395" height="63" alt="image" src="https://github.com/user-attachments/assets/d7036548-8fb7-4eae-8543-31ac8a93dfe3" />


2.2 Сколько отзывов написал пользователь
```sql
CREATE OR REPLACE FUNCTION steam.sum_reviews_by_user(new_user_id INT)
RETURNS INT
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN (SELECT SUM(1) FROM steam.reviews
    WHERE account_id = new_user_id);
END;
$$;

SELECT steam.sum_reviews_by_user(10);
```

<img width="324" height="51" alt="image" src="https://github.com/user-attachments/assets/96e5462e-f8d4-431b-9ee0-034b08bbb5f7" />

2.3 Есть ли игра в списке желаемого
```sql
CREATE OR REPLACE FUNCTION steam.is_in_wishlist(new_game_id INT, new_user_id INT)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN EXISTS (SELECT 1 FROM steam.wishlists
    WHERE account_id = new_user_id AND game_id = new_game_id);
END;
$$;

SELECT steam.is_in_wishlist(6,8);
```

<img width="272" height="58" alt="image" src="https://github.com/user-attachments/assets/367cf040-f882-4479-ba07-5ffe6e1d6743" />


2.4 Вычислить процент положительных отзывов, которые написал пользователь
```sql
CREATE OR REPLACE FUNCTION steam.percent_reviews_by_user(new_user_id INT)
RETURNS FLOAT
LANGUAGE plpgsql
AS $$
DECLARE
    review_count INT;
    positive_review_count INT;
    negative_review_count INT;
BEGIN
    SELECT
        SUM(CASE WHEN steam.reviews.rating THEN 1 ELSE 0 END),
        SUM(CASE WHEN NOT steam.reviews.rating THEN 1 ELSE 0 END),
        COUNT(*)
    INTO positive_review_count, negative_review_count, review_count
    FROM steam.reviews
    WHERE account_id = new_user_id;



    RETURN positive_review_count * 1.0 / review_count;
END;
$$;

SELECT steam.percent_reviews_by_user(10);
```

<img width="368" height="60" alt="image" src="https://github.com/user-attachments/assets/5edbacb4-a022-4463-ad4d-363e4f0dcda8" />


2.5 Процент положительных отзывов у игры
```sql
CREATE OR REPLACE FUNCTION steam.percent_reviews_by_game(new_game_id INT)
RETURNS FLOAT
LANGUAGE plpgsql
AS $$
DECLARE
    review_count INT;
    positive_review_count INT;
    result FLOAT;
BEGIN
    SELECT
        COUNT(*),
        SUM(CASE WHEN steam.reviews.rating THEN 1 ELSE 0 END)
    INTO review_count, positive_review_count
    FROM steam.reviews
    WHERE game_id = new_game_id;

    BEGIN
        result := positive_review_count * 1.0 / review_count;
        RETURN result;
    EXCEPTION
        WHEN division_by_zero THEN
            RAISE EXCEPTION 'Нет отзывов';
    END;
END;
$$;

SELECT steam.percent_reviews_by_game(1);
```

<img width="363" height="66" alt="image" src="https://github.com/user-attachments/assets/3520a0c8-1e0c-4de6-8cc9-ec5912b97a93" />


2.6 Получить разработчика игры без join
```sql
CREATE OR REPLACE FUNCTION steam.game_developer_name(new_game_id INT)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    new_developer_id INT;
BEGIN
    SELECT developer_id INTO new_developer_id
    FROM steam.games
    WHERE game_id = new_game_id;

    RETURN (SELECT name FROM developers WHERE developer_id = new_developer_id);
END;
$$;

SELECT steam.game_developer_name(1);
```

<img width="339" height="64" alt="image" src="https://github.com/user-attachments/assets/bbfb3962-4a8c-4953-99a6-bebff5983b3d" />

2.7 Вычислить отклонение цены игры от средней в стиме
```sql
CREATE OR REPLACE FUNCTION steam.game_price_deviation(new_game_id INT)
RETURNS FLOAT
LANGUAGE plpgsql
AS $$
DECLARE
    avg_price INT;
BEGIN
    SELECT AVG(price) INTO avg_price FROM steam.games
    WHERE price > 0;
    RETURN (SELECT price - avg_price FROM steam.games WHERE game_id = new_game_id);
END;
$$;

SELECT steam.game_price_deviation(12);
```

<img width="336" height="57" alt="image" src="https://github.com/user-attachments/assets/4f349e6a-02e0-43b1-ae5f-5ff4866b2605" />


2.8 Все функции
```sql
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_type = 'FUNCTION' AND routine_schema = 'steam';
```

<img width="663" height="323" alt="image" src="https://github.com/user-attachments/assets/172f48b2-47ac-4343-b25e-2837facd4c43" />

3.1 Добавить или обновить отзыв C Exception
```sql
DO $$
BEGIN
    INSERT INTO steam.reviews (game_id, account_id, rating, comment, review_date)
    VALUES (10, 10, true, ' ' , '2025-11-23');
EXCEPTION
    WHEN unique_violation THEN
        UPDATE steam.reviews
        SET rating = true,
            comment = ' ',
            review_date = '2025-11-23'
        WHERE game_id = 10 AND account_id = 10;
END $$ language plpgsql;
```

<img width="805" height="32" alt="image" src="https://github.com/user-attachments/assets/190c6434-6735-4352-bea7-16f60f830f09" />

3.2 Добавить или обновить отзыв с IF
```sql
DO $$
BEGIN
    IF EXISTS(SELECT 1 FROM steam.reviews WHERE game_id = 10 and account_id = 10)
    THEN UPDATE steam.reviews
        SET rating = true,
        comment = ' ',
        review_date = '2025-11-23'
    WHERE game_id = 10 AND account_id = 10;
    ELSE INSERT INTO steam.reviews (game_id, account_id, rating, comment, review_date)
    VALUES (10, 10, true, ' ' , '2025-11-23');
    END IF;
END $$ language plpgsql;
```

<img width="805" height="32" alt="image" src="https://github.com/user-attachments/assets/21553b68-85e1-4739-b23f-09c10305c38f" />


3.3 Пользователь покупает игру

```sql
DO $$
DECLARE
    game_price INTEGER;
    current_balance INTEGER;
BEGIN
    SELECT price INTO game_price FROM steam.games WHERE game_id = 5;
    SELECT wallet_balance INTO current_balance FROM steam.accounts WHERE account_id = 8;

    IF current_balance >= game_price THEN
        INSERT INTO steam.account_game (account_id, game_id)
        VALUES (8, 5);

        UPDATE steam.accounts
        SET wallet_balance = wallet_balance - game_price
        WHERE account_id = 8;
    END IF;
END $$;
```

ДО

<img width="966" height="51" alt="image" src="https://github.com/user-attachments/assets/f66e457d-af67-4827-a55b-94f797098de1" />

ПОСЛЕ

<img width="960" height="30" alt="image" src="https://github.com/user-attachments/assets/1e0d3b34-0e0c-4542-bb9d-639af0c49982" />

4.1 Через сколько итераций первым в списке будет нужный нам пользователь, если сортировать рандомно
```sql
CREATE OR REPLACE FUNCTION steam.get_user_by_id_with_rand(new_user_id INT)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    iterations INT;
    while_user_id INT;
BEGIN
    iterations := 0;
    while_user_id := 0;
    WHILE new_user_id <> while_user_id LOOP
        SELECT accounts.account_id INTO while_user_id FROM steam.accounts
        ORDER BY RANDOM() LIMIT 1;
        iterations := iterations + 1;
    end loop;
RETURN iterations;
END;
$$;

SELECT steam.get_user_by_id_with_rand(1) as iterations;
```

<img width="228" height="63" alt="image" src="https://github.com/user-attachments/assets/8105dfff-fce3-4c3c-8f25-8c6b08f05b97" />


4.2 Сколько пользователей дружат друг с другом через менее, чем x человек
```sql
CREATE OR REPLACE FUNCTION steam.get_users_by_handshakes(new_user_id INT, iterations INT)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    users INT[];
BEGIN
    users := ARRAY[new_user_id];

    WHILE iterations > 0 LOOP
        SELECT ARRAY(
            SELECT DISTINCT account_id_1
            FROM steam.friends
            WHERE account_id_1 = ANY(users) OR account_id_2 = ANY(users)
            UNION
            SELECT DISTINCT account_id_2
            FROM steam.friends
            WHERE account_id_1 = ANY(users) OR account_id_2 = ANY(users)
        ) INTO users;
        iterations := iterations - 1;
    END LOOP;

    RETURN (SELECT array_length(users, 1));
END;
$$;

SELECT steam.get_users_by_handshakes(2,2) as how_many_users;
```

<img width="275" height="63" alt="image" src="https://github.com/user-attachments/assets/c03c6400-b6e9-491a-9505-5f231f7a6424" />


4.3 Получить категорию игры по проценту положительных отзывов
```sql
CREATE OR REPLACE FUNCTION steam.get_game_category(new_game_id INT)
RETURNS VARCHAR
LANGUAGE plpgsql
AS $$
DECLARE
    category VARCHAR(20);
    percent_of_reviews FLOAT;
BEGIN
    percent_of_reviews = steam.percent_reviews_by_game(new_game_id);
    category := CASE
        WHEN percent_of_reviews > 0.95 THEN 'Крайне положительные'
        WHEN percent_of_reviews BETWEEN 0.8 AND 0.94 THEN 'Очень положительные'
        WHEN percent_of_reviews BETWEEN 0.7 AND 0.79 THEN 'Положительные'
        WHEN percent_of_reviews BETWEEN 0.4 AND 0.69 THEN 'Смешанные'
        WHEN percent_of_reviews BETWEEN 0.2 AND 0.39 THEN 'Отрицательные'
        WHEN percent_of_reviews < 0.19 THEN 'Очень отрицательные'
    END;
    RETURN category;
END;
$$;

SELECT steam.get_game_category(2);
```

<img width="303" height="63" alt="image" src="https://github.com/user-attachments/assets/26590de4-3441-4ab6-8010-73accbeb3769" />

```
