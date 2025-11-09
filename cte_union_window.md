
1 CTE

1.1 Хотим узнать, у кого в списке желаемого есть игра с наибольшой стоимостью
```sql
WITH Max_price AS (SELECT MAX(price) as max_price FROM steam.games)
SELECT username, title, price FROM steam.games
JOIN steam.wishlists w on games.game_id = w.game_id
JOIN steam.accounts a on a.account_id = w.account_id
WHERE price = (SELECT max_price FROM Max_price);
```
<img width="611" height="89" alt="image" src="https://github.com/user-attachments/assets/e9444f19-f5de-43a8-a652-2da17cdb7acc" />


1.2 Хотим узнать игры с ценой выше средней
```sql
WITH avg_price AS (SELECT AVG(price) as avg FROM steam.games
WHERE price > 0)
SELECT title, price, (SELECT avg FROM avg_price) FROM steam.games
WHERE price >= (SELECT avg FROM avg_price);
```
<img width="657" height="60" alt="image" src="https://github.com/user-attachments/assets/a7c39cdb-e59e-40a8-99e7-f99524db362d" />


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
<img width="398" height="174" alt="image" src="https://github.com/user-attachments/assets/91af3240-3bcc-4ee8-99e9-3805b6fdc3e4" />

1.4 Хотим узнать среднее количество игр на аккаунтах
```sql
WITH games_count as (SELECT COUNT(*)  as gc
FROM steam.account_game
GROUP BY account_id)
SELECT AVG(games_count.gc) as avg_games_count
FROM games_count;
```
<img width="286" height="65" alt="image" src="https://github.com/user-attachments/assets/54dce743-77a4-4ec7-98ad-9ed719ea7cce" />

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
<img width="557" height="145" alt="image" src="https://github.com/user-attachments/assets/ca341f69-4067-4217-9453-100260f84d58" />

2 Union

2.1 Хотим узнать сколько бесплатных игр и сколько платных игр
```sql
SELECT 'Бесплатные игры' s, COUNT(*) FROM steam.games WHERE price = 0
UNION
SELECT 'Платные игры', COUNT(*) FROM steam.games WHERE price > 0
```
<img width="411" height="92" alt="image" src="https://github.com/user-attachments/assets/20f1ca67-f14e-4105-9f72-b4c0079724cb" />


2.2 Хотим узнать игры стоимостью от 300 до 400 и больше 600
```sql
SELECT title, price FROM steam.games WHERE price BETWEEN 300 AND 400
UNION
SELECT title, price FROM steam.games WHERE price > 600
```
<img width="548" height="87" alt="image" src="https://github.com/user-attachments/assets/564ee61c-1b3f-440d-8996-79cea6980516" />


2.3 Хотим узнать пользователей с деньгами и без в кошельках
```sql
SELECT username, 'денег нет' money FROM steam.accounts WHERE wallet_balance = 0
UNION
SELECT username, 'деньги есть' FROM steam.accounts WHERE wallet_balance > 0
```
<img width="417" height="178" alt="image" src="https://github.com/user-attachments/assets/b317b838-dceb-4e2b-bed0-7da711a4297f" />



3 Intersect

3.1 Хотим узнать игры стоимостью от 200 до 400
```sql
SELECT title, price FROM steam.games WHERE price > 200
INTERSECT
SELECT title, price FROM steam.games WHERE price < 400
```<img width="546" height="89" alt="image" src="https://github.com/user-attachments/assets/590ee8be-b1d8-4152-b7d4-b6b7ac95130e" />

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
<img width="544" height="87" alt="image" src="https://github.com/user-attachments/assets/5b53f0a7-e945-4677-99d8-c4ef7f93dafc" />

3.3 Хотим узнать пользователей, которые написали отзыв и сделали работу в мастерской
```sql
SELECT DISTINCT a.username FROM steam.accounts a
JOIN steam.reviews r on a.account_id = r.account_id
INTERSECT
SELECT DISTINCT a.username FROM steam.accounts a
JOIN steam.workshop w on a.account_id = w.account_id
```
<img width="212" height="90" alt="image" src="https://github.com/user-attachments/assets/b9fd5585-19ba-46fb-ad64-5fc86422c638" />


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
<img width="544" height="56" alt="image" src="https://github.com/user-attachments/assets/a623694f-d18b-4681-b33e-0fba226b1139" />


4.2 Хотим узнать пользователей, которые написали отзыв, но не сделали работу в мастерской
```sql
SELECT DISTINCT a.username FROM steam.accounts a
JOIN steam.reviews r on a.account_id = r.account_id
EXCEPT
SELECT DISTINCT a.username FROM steam.accounts a
JOIN steam.workshop w on a.account_id = w.account_id
```
<img width="213" height="121" alt="image" src="https://github.com/user-attachments/assets/b96153f0-1c2f-4930-88ed-f92b8dbb1060" />


4.3 Хотим узнать платные игры, которые есть в списках желаемого
```sql
SELECT DISTINCT g.title FROM steam.games g
JOIN steam.account_game ag on g.game_id = ag.game_id
JOIN steam.wishlists w on g.game_id = w.game_id
EXCEPT
SELECT g.title FROM steam.games g WHERE price = 0;
```
<img width="308" height="106" alt="image" src="https://github.com/user-attachments/assets/2303062d-dc0f-4414-84a3-107c474dea76" />


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
<img width="1141" height="350" alt="image" src="https://github.com/user-attachments/assets/d7dea614-53a5-4001-9248-ee47419c45a3" />


5.2 Хотим узнать максимальную цену игр по модам
```sql
  SELECT gm.name, g.title, g.price, MAX(price) OVER (
  PARTITION BY gm.mode_id
  ) as max_game_price_in_mode
  FROM steam.games g
  JOIN steam.game_gamemode gg on g.game_id = gg.game_id
  JOIN steam.gamemodes gm on gm.mode_id = gg.gamemode_id
```
<img width="1215" height="293" alt="image" src="https://github.com/user-attachments/assets/90062575-5672-4f60-aa87-e681cad2698b" />

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
<img width="1200" height="520" alt="image" src="https://github.com/user-attachments/assets/ebdb025c-6a0b-460b-8b82-acb774d994e8" />

  
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
<img width="1217" height="288" alt="image" src="https://github.com/user-attachments/assets/1525e9bd-ed48-4537-a236-00ba14647ee4" />


