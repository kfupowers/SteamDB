1 Select

1.1 Хотим узнать почту первого пользователя
```sql
SELECT (SELECT email FROM steam.accounts LIMIT 1) AS ПОЧТА;
```
<img width="190" height="57" alt="image" src="https://github.com/user-attachments/assets/7fc4c1f2-2a2b-4feb-aac5-bc5c17da6cf5" />

1.2 Хотим узнать название первой игры
```sql
SELECT (SELECT title FROM steam.games LIMIT 1) AS НАЗВАНИЕ;
```
<img width="214" height="67" alt="image" src="https://github.com/user-attachments/assets/103131fc-4a23-4c32-aa82-5f6d737d2b0a" />

1.3 Хотим узнать название первой команды разработчиков
```sql
SELECT (SELECT name FROM steam.developers LIMIT 1) AS РАЗРАБОТЧИК;
```
<img width="244" height="64" alt="image" src="https://github.com/user-attachments/assets/e0113055-10fa-4f0b-8ade-2690928446dd" />


2 From

2.1 Хотим узнать среднее количество игр на аккаунтах
```sql
SELECT AVG(games_count) as avg_games_count
FROM (
    SELECT COUNT(*) as games_count FROM steam.account_game
    GROUP BY account_id
)
```
<img width="288" height="58" alt="image" src="https://github.com/user-attachments/assets/756e1d7d-fabe-484c-b5a7-bd0a19a35548" />

2.2 Хотим узнать аккаунты на которых средняя цена игр больше 100
```sql
SELECT username, avg_games_price
FROM (
    SELECT username, AVG(price) as avg_games_price FROM steam.games
    JOIN steam.account_game ag on games.game_id = ag.game_id
    JOIN steam.accounts a on a.account_id = ag.account_id
    GROUP BY username
)
WHERE avg_games_price > 100;
```
<img width="553" height="148" alt="image" src="https://github.com/user-attachments/assets/48835e0d-3a34-41a7-bd24-ac08d8d9531c" />


2.3 Хотим узнать игры с количеством жанров большим двух
```sql
SELECT title, genre_count
FROM ( SELECT title, COUNT(*) as genre_count
FROM steam.games
JOIN steam.game_genre gg on games.game_id = gg.game_id
GROUP BY title
)
WHERE genre_count > 2;
```
<img width="611" height="173" alt="image" src="https://github.com/user-attachments/assets/95c2b5e7-1819-4b82-9d82-b0ee4e57af0b" />

3 Where

3.1 Хотим узнать, у кого в списке желаемого есть игра с наибольшой стоимостью
```sql
SELECT username, title, price FROM steam.games
JOIN steam.wishlists w on games.game_id = w.game_id
JOIN steam.accounts a on a.account_id = w.account_id
WHERE price = (SELECT MAX(price) FROM steam.games);
```
<img width="622" height="87" alt="image" src="https://github.com/user-attachments/assets/a4c2a644-639c-4a5c-85ae-7e5323f8bf8b" />

3.2 Хотим узнать самую дешевую платную игру
```sql
SELECT title, price FROM steam.games
WHERE price = (SELECT MIN(price) FROM steam.games
WHERE price > 0);
```
<img width="404" height="65" alt="image" src="https://github.com/user-attachments/assets/f773b14d-c363-4b40-a310-83740ff72f9f" />


3.3 Хотим узнать игры с ценой больше средней
```sql
SELECT title, price FROM steam.games
WHERE price >= (SELECT AVG(price) FROM steam.games
WHERE price > 0);
```
<img width="551" height="67" alt="image" src="https://github.com/user-attachments/assets/7dc6c69a-ee16-4f96-b232-e006b2b30990" />


4 Having

4.1 Хотим узнать аккаунты с наибольшим количеством достижений
```sql
SELECT username, count(*) FROM steam.accounts
JOIN steam.account_game ag on accounts.account_id = ag.account_id
JOIN steam.ownership_achievement oa on ag.ownership_id = oa.ownership_id
JOIN steam.achievements a on a.achievement_id = oa.achievement_id
GROUP BY username
HAVING count(*) = (SELECT count(*) as c FROM steam.accounts
JOIN steam.account_game ag on accounts.account_id = ag.account_id
JOIN steam.ownership_achievement oa on ag.ownership_id = oa.ownership_id
JOIN steam.achievements a on a.achievement_id = oa.achievement_id
GROUP BY username
ORDER BY c DESC
LIMIT 1);
```
<img width="434" height="173" alt="image" src="https://github.com/user-attachments/assets/8da5138b-f4f1-42e6-a1f4-70d48f9e5c9f" />


4.2 Хотим узнать компанию с наибольшим количеством выпущенных игр
```sql
SELECT steam.developers.name, COUNT(*) FROM steam.developers
JOIN steam.games g on developers.developer_id = g.developer_id
GROUP BY steam.developers.name
HAVING COUNT(*) = (SELECT  COUNT(*) as c FROM steam.developers
JOIN steam.games g on developers.developer_id = g.developer_id
GROUP BY steam.developers.name
ORDER BY c DESC
LIMIT 1)
```
<img width="382" height="65" alt="image" src="https://github.com/user-attachments/assets/e3085d69-51f5-4927-8f56-d74be937f71a" />

4.3 Хотим узнать игры с наибольшим количеством жанров
```sql
SELECT title, COUNT(*) FROM steam.games
JOIN steam.game_genre gg on games.game_id = gg.game_id
GROUP BY title
HAVING COUNT(*) = (SELECT title, COUNT(*) as c FROM steam.games
JOIN steam.game_genre gg on games.game_id = gg.game_id
GROUP BY title
ORDER BY c DESC
LIMIT 1)
```
<img width="551" height="93" alt="image" src="https://github.com/user-attachments/assets/3cef27ab-1539-4a3f-bb0f-5bfdd67fe6f1" />


5 All

5.1 Хотим узнать все ли игры стоят меньше 1000
```sql
SELECT 1000 > ALL (SELECT price FROM steam.games);
```
<img width="210" height="70" alt="image" src="https://github.com/user-attachments/assets/1ac9e0e3-ff1b-4711-8138-9ea52af65205" />

5.2 Хотим узнать именя пользователей, у которых только бесплатные игры
```sql
SELECT username FROM steam.accounts
WHERE accounts.account_id <> ALL (SELECT DISTINCT account_id FROM steam.games
JOIN steam.account_game ag on games.game_id = ag.game_id
WHERE price > 0)
```
<img width="217" height="60" alt="image" src="https://github.com/user-attachments/assets/ad8a5cd7-7370-4087-9a45-250800a6e3ff" />

5.3 Хотим узнать пользователей без работ в мастерской
```sql
SELECT username FROM steam.accounts
WHERE accounts.account_id <> ALL (SELECT DISTINCT account_id FROM steam.workshop)
```
<img width="212" height="118" alt="image" src="https://github.com/user-attachments/assets/907bbaa3-7b66-4b1d-86f8-101d0ca8f57a" />


6 IN

6.1 Хотим узнать пользователей, у которых есть работы в мастерской
```sql
SELECT username FROM steam.accounts
WHERE accounts.account_id IN (SELECT DISTINCT account_id FROM steam.workshop)
```
<img width="212" height="86" alt="image" src="https://github.com/user-attachments/assets/e099dc89-3131-45c0-8f40-003f5e199048" />

6.2 Хотим узнать пользователей с играми, в которых у них выполнено больше 3 достижений
```sql
SELECT username, title FROM steam.accounts
JOIN steam.account_game ag on accounts.account_id = ag.account_id
JOIN steam.games g on g.game_id = ag.game_id
WHERE ag.ownership_id IN (SELECT DISTINCT ownership_id FROM steam.ownership_achievement oa
GROUP BY oa.ownership_id
HAVING COUNT(*) > 3)
```
<img width="597" height="165" alt="image" src="https://github.com/user-attachments/assets/080251f5-c1dd-4582-9646-5932af14d4db" />


6.3 Хотим узнать пользователей, которые написали хотя бы один положительный отзыв
```sql
SELECT username FROM steam.accounts
WHERE accounts.account_id IN (SELECT DISTINCT account_id FROM steam.reviews
WHERE rating)
```
<img width="214" height="150" alt="image" src="https://github.com/user-attachments/assets/87508064-573d-4899-bca0-96b78c118431" />


7 ANY

7.1 Хотим узнать пользователей, у которых есть работы в мастерской
```sql
SELECT username FROM steam.accounts
WHERE accounts.account_id = ANY (SELECT DISTINCT account_id FROM steam.workshop)
```
<img width="212" height="86" alt="image" src="https://github.com/user-attachments/assets/e099dc89-3131-45c0-8f40-003f5e199048" />

7.2 Хотим узнать пользователей с играми, в которых у них выполнено больше 3 достижений
```sql
SELECT username, title FROM steam.accounts
JOIN steam.account_game ag on accounts.account_id = ag.account_id
JOIN steam.games g on g.game_id = ag.game_id
WHERE ag.ownership_id = ANY (SELECT DISTINCT ownership_id FROM steam.ownership_achievement oa
GROUP BY oa.ownership_id
HAVING COUNT(*) > 3)
```
<img width="597" height="165" alt="image" src="https://github.com/user-attachments/assets/080251f5-c1dd-4582-9646-5932af14d4db" />

7.3 Хотим узнать пользователей, которые написали хотя бы один положительный отзыв
```sql
SELECT username FROM steam.accounts
WHERE accounts.account_id = ANY (SELECT DISTINCT account_id FROM steam.reviews
WHERE rating)
```
<img width="209" height="148" alt="image" src="https://github.com/user-attachments/assets/51b931bf-cf25-4392-a46b-db1f0c1737db" />


8 EXIST

8.1 Хотим найти пользователей, у которых есть хотя бы одна платная игра
```sql
SELECT username FROM steam.accounts
WHERE EXISTS (SELECT 1 FROM steam.games
JOIN steam.account_game ag on games.game_id = ag.game_id
WHERE price > 0 AND ag.account_id = accounts.account_id)
```
<img width="215" height="146" alt="image" src="https://github.com/user-attachments/assets/f4ee671d-6705-417a-98a6-4be22df09380" />

8.2 Хотим найти пользователей, которые написали хотя бы одни отрицательный отзыв
```sql
SELECT username FROM steam.accounts
WHERE EXISTS (SELECT 1 FROM steam.reviews
WHERE NOT rating and reviews.account_id = accounts.account_id)
```
<img width="214" height="67" alt="image" src="https://github.com/user-attachments/assets/6e4fabe3-0b69-4dc5-930a-039c4ba019c6" />

8.3 Хотим узнать пользователей, у которых нет работ в мастерской
```sql
SELECT username FROM steam.accounts
WHERE NOT EXISTS (SELECT 1 FROM steam.workshop
WHERE accounts.account_id = workshop.account_id)
```
<img width="212" height="115" alt="image" src="https://github.com/user-attachments/assets/55df2d98-c060-456c-bbd5-4d04bb84fe21" />

9 Сравнение по нескольким столбцам

9.1 Хотим узнать пользователей и игры, к которым пользователи написали положительные отзывы
```sql
    SELECT username, title FROM steam.accounts
    JOIN steam.account_game ag on accounts.account_id = ag.account_id
    JOIN steam.games g on g.game_id = ag.game_id
    WHERE (accounts.account_id, g.game_id) IN (SELECT account_id, reviews.game_id FROM steam.reviews
    WHERE rating)
```
<img width="584" height="153" alt="image" src="https://github.com/user-attachments/assets/07715d7b-19aa-49de-b89a-3ddb2e97698d" />

9.2 Хотим узнать пользователей и игры, к которым пользователи сделали работу в мастерской
```sql
SELECT username, title FROM steam.accounts
CROSS JOIN steam.games g 
WHERE (accounts.account_id, g.game_id) IN (SELECT workshop.account_id, workshop.game_id
FROM steam.workshop)
```
<img width="577" height="86" alt="image" src="https://github.com/user-attachments/assets/5686e682-9e26-4040-9638-be6afc375049" />

9.3 Хотим узнать пользователей, которые не оставили отзыв к своим играм
```sql
SELECT username, title FROM steam.accounts
JOIN steam.account_game ag on accounts.account_id = ag.account_id
JOIN steam.games g on g.game_id = ag.game_id
WHERE (accounts.account_id, g.game_id) NOT IN (SELECT account_id, reviews.game_id FROM steam.reviews)
```
<img width="587" height="233" alt="image" src="https://github.com/user-attachments/assets/a8713b16-5d7d-4944-a20f-6d10ffbcc19d" />

10 Коррелированные подзапросы

10.1 Хотим узнать сколько денег пользователи потратили на игры
```sql
SELECT username, (SELECT SUM(price) FROM steam.account_game
JOIN steam.games g on g.game_id = account_game.game_id
WHERE accounts.account_id = account_game.account_id)
FROM steam.accounts
```
<img width="404" height="177" alt="image" src="https://github.com/user-attachments/assets/2021face-8179-44df-bc6f-23f1eef9c114" />

10.2 Хотим узнать игры пользователей, которые стоят больше средней цены игр пользователя
```sql
SELECT username, g.title, price  FROM steam.account_game
JOIN steam.games g on g.game_id = account_game.game_id
JOIN steam.accounts a on a.account_id = account_game.account_id
WHERE price > (SELECT AVG(price) FROM steam.account_game
JOIN steam.games g on g.game_id = account_game.game_id
WHERE account_game.account_id = a.account_id)
```
<img width="763" height="146" alt="image" src="https://github.com/user-attachments/assets/eb0bd0e6-8e57-476c-97fb-3dc5e934a890" />

10.3 Хотим узнать пользователей, которые выполнили все достижения в какой-то игре
```sql
SELECT username, title FROM steam.account_game
JOIN steam.games g on g.game_id = account_game.game_id
JOIN steam.accounts a on a.account_id = account_game.account_id
JOIN steam.ownership_achievement oa on account_game.ownership_id = oa.ownership_id
GROUP BY (username, title, g.game_id)
HAVING COUNT(*) = (SELECT COUNT(*) FROM steam.achievements
WHERE g.game_id = achievements.game_id)
```
<img width="586" height="149" alt="image" src="https://github.com/user-attachments/assets/7c6f408e-716c-4da8-8274-98bae6d013f5" />


