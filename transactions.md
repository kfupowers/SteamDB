1
```sql
BEGIN;
INSERT INTO steam.accounts(account_id, username, email, password, wallet_balance) VALUES
(11, 'newuser', 'newuser@gmail.com', 'qweasdzxc', 1000);
UPDATE steam.account_game SET account_id = 11 WHERE ownership_id = 1;
COMMIT;
SELECT * FROM steam.account_game WHERE ownership_id = 1;
```

<img width="748" height="68" alt="image" src="https://github.com/user-attachments/assets/cbae1337-188a-4dde-ac0f-0d6bfda7b208" />

2
```sql
BEGIN;
INSERT INTO steam.accounts(account_id, username, email, password, wallet_balance) VALUES
(11, 'newuser', 'newuser@gmail.com', 'qweasdzxc', 1000);
UPDATE steam.account_game SET account_id = 11 WHERE ownership_id = 1;
ROLLBACK;
SELECT * FROM steam.account_game WHERE ownership_id = 1;
```
<img width="749" height="64" alt="image" src="https://github.com/user-attachments/assets/05da8cf2-cd8c-4dc4-81ed-954a93e197a5" />


3
```sql
BEGIN;
INSERT INTO steam.accounts(account_id, username, email, password, wallet_balance) VALUES
(11, 'newuser', 'newuser@gmail.com', 'qweasdzxc', 1000);
UPDATE steam.account_game SET account_id = 11/0 WHERE ownership_id = 1;
COMMIT;
SELECT * FROM steam.account_game WHERE ownership_id = 1;
```

<img width="744" height="64" alt="image" src="https://github.com/user-attachments/assets/d9433e2a-b106-4cfd-96b7-a79d9c4afc33" />

4.1 Read Uncommitted/Read Committed
```sql
BEGIN;
UPDATE steam.account_game SET account_id = 11 WHERE ownership_id = 1;
```

```sql
BEGIN TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT * FROM  steam.account_game WHERE ownership_id = 1;
COMMIT;
```

<img width="741" height="62" alt="image" src="https://github.com/user-attachments/assets/38d0b57e-3c38-49f3-b543-1700c51d4d8c" />

4.2 Read Uncommitted/Read Committed
```sql
BEGIN;
UPDATE steam.account_game SET account_id = 11 WHERE ownership_id = 1;
```

```sql
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT * FROM  steam.account_game WHERE ownership_id = 1;
COMMIT;
```

<img width="741" height="62" alt="image" src="https://github.com/user-attachments/assets/38d0b57e-3c38-49f3-b543-1700c51d4d8c" />

5.1 Read Committed
```sql
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT * FROM  steam.account_game WHERE ownership_id = 1;
SELECT pg_sleep(15);
SELECT * FROM steam.account_game WHERE ownership_id = 1;
```

```sql
BEGIN;
UPDATE steam.account_game SET account_id = 11 WHERE ownership_id = 1;
COMMIT;
```

<img width="743" height="59" alt="image" src="https://github.com/user-attachments/assets/7b2bf781-1f53-4347-a1cd-0039f192fa03" />

<img width="750" height="59" alt="image" src="https://github.com/user-attachments/assets/2179f75c-6700-4593-b785-54f21af9e655" />

6.1 Repeatable Read
```sql
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT * FROM  steam.account_game WHERE ownership_id = 1;
SELECT pg_sleep(15);
SELECT * FROM steam.account_game WHERE ownership_id = 1;
```

```sql
BEGIN;
UPDATE steam.account_game SET account_id = 11 WHERE ownership_id = 1;
COMMIT;
```

<img width="778" height="132" alt="image" src="https://github.com/user-attachments/assets/a02da70e-b96c-4334-8bbb-ced10418d478" />

<img width="796" height="138" alt="image" src="https://github.com/user-attachments/assets/1a44a84a-2258-4582-93d7-bbe2d18fa60e" />

6.2 Repeatable Read
```sql
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT * FROM  steam.account_game WHERE account_id = 1;
SELECT pg_sleep(15);
SELECT * FROM steam.account_game WHERE account_id = 1;
```

```sql
BEGIN;
INSERT INTO steam.account_game(account_id, game_id) VALUES (1, 10);
COMMIT;
```

<img width="790" height="160" alt="image" src="https://github.com/user-attachments/assets/6f40418d-3ea8-4f9a-9600-bad1dcd61c31" />

<img width="806" height="197" alt="image" src="https://github.com/user-attachments/assets/83f0267e-6bb0-48a8-a1df-32c778115486" />

```sql
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ ;
SELECT * FROM  steam.account_game WHERE account_id = 1;
SELECT pg_sleep(15);
SELECT * FROM steam.account_game WHERE account_id = 1;
COMMIT;
SELECT pg_sleep(5);
SELECT * FROM steam.account_game WHERE account_id = 1;
```

```sql
BEGIN;
INSERT INTO steam.account_game(account_id, game_id) VALUES (1, 10);
COMMIT;
```

<img width="1236" height="162" alt="image" src="https://github.com/user-attachments/assets/33fc1fde-70df-4248-b0dc-7e2b8ff7faa3" />

<img width="1214" height="159" alt="image" src="https://github.com/user-attachments/assets/88ddc451-48ff-458b-ad5b-f8f2f6477d96" />

<img width="1234" height="194" alt="image" src="https://github.com/user-attachments/assets/bda2eec0-4181-49c8-a073-0f0d94629b9c" />

7 Serializable
```sql
INSERT INTO steam.games(game_id, developer_id, title, description, release_date, price) values
 (26, 2, '2', '2', '2000-11-11', 1000);

BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT pg_sleep(10);
UPDATE steam.games SET price = price - 33 WHERE  game_id = 26;
COMMIT;
```

```sql
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT pg_sleep(10);
UPDATE steam.games SET price = price + 10000 WHERE  game_id = 26;
COMMIT;
```

<img width="986" height="42" alt="image" src="https://github.com/user-attachments/assets/6125a61d-83bc-4dd6-8d34-9fc8a6726494" />

<img width="1242" height="32" alt="image" src="https://github.com/user-attachments/assets/50de33db-a665-41c5-ab8b-7a62b453332d" />

8.1 Savepoint

```sql
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SAVEPOINT before_updating;
UPDATE steam.games SET price = price + 10000 WHERE  game_id = 26;
ROLLBACK TO SAVEPOINT before_updating;
UPDATE steam.games SET price = price + 50000 WHERE  game_id = 26;
COMMIT;
```

<img width="895" height="34" alt="image" src="https://github.com/user-attachments/assets/e3611b75-ab5e-4948-81f3-d7266e82efb5" />

8.2 Savepoint

```sql
BEGIN;
SAVEPOINT before_updating;
UPDATE steam.games SET price = price + 10000 WHERE  game_id = 26;
ROLLBACK TO SAVEPOINT before_updating;
UPDATE steam.games SET price = price + 1 WHERE game_id = 26;
SAVEPOINT after_updating;
UPDATE steam.games SET price = price + 50000 WHERE  game_id = 26;
ROLLBACK TO SAVEPOINT after_updating;
UPDATE steam.games SET price = price + 500 WHERE  game_id = 26;
COMMIT;
```

<img width="693" height="41" alt="image" src="https://github.com/user-attachments/assets/2f19fe4a-65a2-45c5-b726-220a687204ca" />


