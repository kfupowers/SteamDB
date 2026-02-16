
1 CTE

1.1 Хотим узнать, у кого в списке желаемого есть игра с наибольшой стоимостью
```sql
WITH Max_price AS (SELECT MAX(price) as max_price FROM steam.games)
SELECT username, title, price FROM steam.games
JOIN steam.wishlists w on games.game_id = w.game_id
JOIN steam.accounts a on a.account_id = w.account_id
WHERE price = (SELECT max_price FROM Max_price);
```
<img width="619" height="65" alt="image" src="https://github.com/user-attachments/assets/b32b0e67-67ca-44de-824d-1a23a213b8d8" />



1.2 Хотим узнать игры с ценой выше средней
```sql
WITH avg_price AS (SELECT AVG(price) as avg FROM steam.games
WHERE price > 0)
SELECT title, price, (SELECT avg FROM avg_price) FROM steam.games
WHERE price >= (SELECT avg FROM avg_price);
```
<img width="611" height="144" alt="image" src="https://github.com/user-attachments/assets/04f65ce9-78d1-4354-9a4b-cae7df63f235" />



1.3 Хотим узнать пользователей с максимальным количеством достижений
```sql
WITH qt as (SELECT account_id, count(*) as ct
FROM steam.account_game ag
JOIN steam.ownership_achievement oa on ag.ownership_id = oa.ownership_id
GROUP BY account_id)
SELECT username, ct
FROM qt
JOIN steam.accounts a ON qt.account_id = a.account_id
WHERE ct = (SELECT Max(ct) FROM qt);
```
<img width="403" height="59" alt="image" src="https://github.com/user-attachments/assets/756e55b5-c186-42cf-9130-9c2a98d80c2c" />

1.4 Хотим узнать среднее количество игр на аккаунтах
```sql
WITH games_count as (SELECT COUNT(*)  as gc
FROM steam.account_game
GROUP BY account_id)
SELECT AVG(games_count.gc) as avg_games_count
FROM games_count;
```
<img width="283" height="59" alt="image" src="https://github.com/user-attachments/assets/60ec099f-69b8-4ede-91ed-47eb10c75158" />

1.5 Хотим узнать аккаунты на которых средняя цена игр больше 100
```sql
WITH avg_games_price_by_account as (SELECT username, AVG(price) as avg_games_price
    FROM steam.games
    JOIN steam.account_game ag on games.game_id = ag.game_id
    JOIN steam.accounts a on a.account_id = ag.account_id
    GROUP BY username)
SELECT username, avg_games_price
FROM avg_games_price_by_account
WHERE avg_games_price > 100;
```
<img width="554" height="290" alt="image" src="https://github.com/user-attachments/assets/2427f978-3944-4db3-8599-048684f1b6ce" />


2 Union

2.1 Хотим узнать сколько бесплатных игр и сколько платных игр
```sql
SELECT 'Бесплатные игры' s, COUNT(*) FROM steam.games WHERE price = 0
UNION
SELECT 'Платные игры', COUNT(*) FROM steam.games WHERE price > 0
```
<img width="407" height="89" alt="image" src="https://github.com/user-attachments/assets/529c5299-3ef6-47a7-9a4b-cdf751fe61c1" />


2.2 Хотим узнать игры стоимостью от 300 до 400 и больше 600
```sql
SELECT title, price FROM steam.games WHERE price BETWEEN 300 AND 400
UNION
SELECT title, price FROM steam.games WHERE price > 600
```
<img width="545" height="203" alt="image" src="https://github.com/user-attachments/assets/78364dbd-c099-4a8e-b7c3-150a1e641d52" />


2.3 Хотим узнать пользователей с деньгами и без в кошельках
```sql
SELECT username, 'денег нет' money FROM steam.accounts WHERE wallet_balance = 0
UNION
SELECT username, 'деньги есть' FROM steam.accounts WHERE wallet_balance > 0
```
<img width="446" height="322" alt="image" src="https://github.com/user-attachments/assets/b8587c53-e4f9-46e4-8e9c-5fab1a346f93" />


3 Intersect

3.1 Хотим узнать игры стоимостью от 200 до 400
```sql
SELECT title, price FROM steam.games WHERE price > 200
INTERSECT
SELECT title, price FROM steam.games WHERE price < 400
```
<img width="551" height="110" alt="image" src="https://github.com/user-attachments/assets/c85c3d45-f31a-4848-8683-963a9be97c07" />

3.2 Хотим узнать игры Для одного игрока и в жанре Платформер
```sql
SELECT title, price FROM steam.games
JOIN steam.game_genre gg on games.game_id = gg.game_id
JOIN steam.genres g on g.genre_id = gg.genre_id
WHERE g.name = 'Платформер'
INTERSECT
SELECT title, price FROM steam.games
JOIN steam.game_gamemode gg2 on games.game_id = gg2.game_id
JOIN steam.gamemodes g2 on g2.mode_id = gg2.gamemode_id
WHERE g2.name = 'Для одного игрока';
```
<img width="546" height="143" alt="image" src="https://github.com/user-attachments/assets/fddc9f92-36dc-484e-a9ad-498b96f6305c" />


3.3 Хотим узнать пользователей, которые написали отзыв и сделали работу в мастерской
```sql
SELECT DISTINCT a.username FROM steam.accounts a
JOIN steam.reviews r on a.account_id = r.account_id
INTERSECT
SELECT DISTINCT a.username FROM steam.accounts a
JOIN steam.account_game ag on a.account_id = ag.account_id
JOIN steam.workshop w on ag.ownership_id = w.ownership_id
```
<img width="221" height="120" alt="image" src="https://github.com/user-attachments/assets/c5ad9406-2039-4c88-8527-b59e2783b704" />



4 Except

4.1 Хотим узнать игры Для одного игрока, которые не в жанре Платформер
```sql
SELECT title, price FROM steam.games
JOIN steam.game_gamemode gg2 on games.game_id = gg2.game_id
JOIN steam.gamemodes g2 on g2.mode_id = gg2.gamemode_id
WHERE g2.name = 'Для одного игрока'
EXCEPT
SELECT title, price FROM steam.games
JOIN steam.game_genre gg on games.game_id = gg.game_id
JOIN steam.genres g on g.genre_id = gg.genre_id
WHERE g.name = 'Платформер';
```
<img width="548" height="176" alt="image" src="https://github.com/user-attachments/assets/6a7b9475-77bc-4b94-b9e5-025a72ede748" />



4.2 Хотим узнать пользователей, которые написали отзыв, но не сделали работу в мастерской
```sql
SELECT DISTINCT a.username FROM steam.accounts a
JOIN steam.reviews r on a.account_id = r.account_id
EXCEPT
SELECT DISTINCT a.username FROM steam.accounts a
JOIN steam.account_game ag on a.account_id = ag.account_id
JOIN steam.workshop w on ag.ownership_id = w.ownership_id
```
<img width="214" height="176" alt="image" src="https://github.com/user-attachments/assets/ef5b2bf9-7166-4e26-9443-120054d04b20" />



4.3 Хотим узнать платные игры, которые есть в списках желаемого
```sql
SELECT DISTINCT g.title FROM steam.games g
JOIN steam.account_game ag on g.game_id = ag.game_id
JOIN steam.wishlists w on g.game_id = w.game_id
EXCEPT
SELECT g.title FROM steam.games g WHERE price = 0;
```
<img width="307" height="181" alt="image" src="https://github.com/user-attachments/assets/8f310ed6-a6f1-437d-a521-17dedf593363" />



5 Partition by

5.1 Хотим сколько денег пользователи потратили на игры
```sql
SELECT username, g.title, g.price, SUM(price) OVER (
PARTITION BY a.account_id
) as money_spent_on_games
FROM steam.games g
JOIN steam.account_game ag on g.game_id = ag.game_id
JOIN steam.accounts a on a.account_id = ag.account_id
```
<img width="1138" height="809" alt="image" src="https://github.com/user-attachments/assets/2345620b-0e29-466b-a4de-382f97ec31ce" />



5.2 Хотим узнать максимальную цену игр по модам
```sql
  SELECT gm.name, g.title, g.price, MAX(price) OVER (
  PARTITION BY gm.mode_id
  ) as max_game_price_in_mode
  FROM steam.games g
  JOIN steam.game_gamemode gg on g.game_id = gg.game_id
  JOIN steam.gamemodes gm on gm.mode_id = gg.gamemode_id
```
<img width="1231" height="839" alt="image" src="https://github.com/user-attachments/assets/62f28e1d-1c97-4659-97c6-e0314b76ebb5" />


6 Partition by + Order by

6.1 Хотим узнать нарастающую цену игр по жанрам
```sql
SELECT g2.name, g.title, g.price, SUM(price) OVER (
PARTITION BY g2.genre_id
ORDER BY g.price
) as max_game_price_in_mode
FROM steam.games g
JOIN steam.game_genre gg on g.game_id = gg.game_id
JOIN steam.genres g2 on g2.genre_id = gg.genre_id
```
<img width="1208" height="877" alt="image" src="https://github.com/user-attachments/assets/e98acbae-4ba8-4370-ba01-392d0ac4f257" />


  
6.2 Хотим узнать нарастающую цену игр по модам
```sql
SELECT gm.name, g.title, g.price, sum(price) OVER (
PARTITION BY gm.mode_id
ORDER BY price
) as max_game_price_in_mode
FROM steam.games g
JOIN steam.game_gamemode gg on g.game_id = gg.game_id
JOIN steam.gamemodes gm on gm.mode_id = gg.gamemode_id
```
<img width="1231" height="841" alt="image" src="https://github.com/user-attachments/assets/6eec4fc7-9ddb-43da-a20e-840fe9adfd60" />

7 Range

7.1 Хотим узнать среднюю цену в окне по жанрам
```sql
SELECT g2.name, g.title, g.price, AVG(price) OVER (
PARTITION BY g2.genre_id
ORDER BY g.price
RANGE BETWEEN 200 preceding and current row
) as avg_game_price_in_mode
FROM steam.games g
JOIN steam.game_genre gg on g.game_id = gg.game_id
JOIN steam.genres g2 on g2.genre_id = gg.genre_id
```
<img width="1197" height="874" alt="image" src="https://github.com/user-attachments/assets/aa4e482b-c434-435a-93b4-822ca7a0201f" />



7.2 Хотим узнать среднюю цену в окне
```sql
SELECT  g.title, g.price, AVG(price) OVER (
ORDER BY g.price
RANGE BETWEEN 200 preceding and current row
) as avg_game_price_in_mode
FROM steam.games g
```
<img width="945" height="380" alt="image" src="https://github.com/user-attachments/assets/4dbf0b20-7704-4f7d-b3a7-ca823a08e565" />


8 Rows

8.1 Хотим узнать среднюю цену в окне по жанрам
```sql
SELECT g2.name, g.title, g.price, AVG(price) OVER (
PARTITION BY g2.genre_id
ORDER BY g.price
ROWS BETWEEN 1 preceding and current row
) as avg_game_price_in_mode
FROM steam.games g
JOIN steam.game_genre gg on g.game_id = gg.game_id
JOIN steam.genres g2 on g2.genre_id = gg.genre_id
```
<img width="1198" height="761" alt="image" src="https://github.com/user-attachments/assets/02e4b39f-c913-4012-8d1f-218906a14b2c" />


8.2 Хотим узнать среднюю цену в окне 
```sql
SELECT  g.title, g.price, AVG(price) OVER (
ORDER BY g.price
ROWS BETWEEN 2 preceding and current row
) as avg_game_price_in_mode
FROM steam.games g
```
<img width="947" height="376" alt="image" src="https://github.com/user-attachments/assets/928d3941-9ade-4afe-a10b-ce159e32392c" />


9 Ранжирующие(Пользователи по количеству достижений)
WITH qt as (SELECT account_id, count(*) as ct
FROM steam.account_game ag
JOIN steam.ownership_achievement oa on ag.ownership_id = oa.ownership_id
GROUP BY account_id)
SELECT username, ct,
ROW_NUMBER() over (ORDER BY ct DESC) as row_number,
RANK() over (ORDER BY ct DESC) as rank,
DENSE_RANK() over (ORDER BY ct DESC) as dense_rank
FROM qt JOIN steam.accounts a ON qt.account_id = a.account_id
<img width="1050" height="299" alt="image" src="https://github.com/user-attachments/assets/92c90460-efab-4605-a462-586dda5e4ab4" />


10 Оконные функции смещени

```sql
SELECT  g.title, g.price,
LAG(price) over (ORDER BY g.price) as lag,
LEAD(price) over (ORDER BY g.price) as lead,
FIRST_VALUE(price) over (ORDER BY g.price RANGE BETWEEN 200 preceding AND CURRENT ROW) as first_value,
LAST_VALUE(price) over (ORDER BY g.price RANGE BETWEEN 400 preceding AND 100 PRECEDING) as last_value
FROM steam.games g
```
<img width="1373" height="181" alt="image" src="https://github.com/user-attachments/assets/5e7075de-c5af-4e99-8ddf-bbd489b1c9b6" />

