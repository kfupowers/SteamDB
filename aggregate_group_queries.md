<img width="817" height="460" alt="image" src="https://github.com/user-attachments/assets/e4870395-e971-4642-a9cd-e7b905d3c897" />1 AVG

1.1 Хотим получить среднню цену

```sql
SELECT AVG(price) as average_price FROM steam.games
```
<img width="263" height="63" alt="image" src="https://github.com/user-attachments/assets/806ebeaf-174a-4b51-b1aa-c0060c8c6fdf" />

1.2 Хотим получить средний процент отзывов

```sql
SELECT AVG(percent_of_reviews),
FROM
(SELECT title,
COUNT(CASE WHEN rating THEN 1 END) as positive_reviews,
COUNT(reviews) as all_reviews,
ROUND(
COUNT(CASE WHEN rating THEN 1 END)*1.0/COUNT(reviews), 2) as percent_of_reviews
FROM steam.reviews JOIN steam.games
ON games.game_id = reviews.game_id
GROUP BY games.game_id);
```
<img width="158" height="59" alt="image" src="https://github.com/user-attachments/assets/fa1a1d8e-e436-47ea-9663-9909e5f35cad" />

2 Count

2.1 Хотим получить количнство игр

```sql
SELECT COUNT(*) FROM steam.games
```
<img width="177" height="54" alt="image" src="https://github.com/user-attachments/assets/3b16d454-c505-4a4a-b2a6-843117e98d4d" />


2.2 Хотим получить количество пользователей

```sql
SELECT COUNT(*) FROM steam.accounts
```

<img width="177" height="54" alt="image" src="https://github.com/user-attachments/assets/ded998b6-cac8-4e84-ae5c-a22a4a2ee0cf" />

3 MIN, MAX

3.1 Хотим получить максимальную цену игры

```sql
SELECT MAX(price) FROM steam.games
```
<img width="170" height="60" alt="image" src="https://github.com/user-attachments/assets/3a4e0f28-c6de-4a16-a56a-668a461c11e4" />


3.2 Хотим получить минимальную цену небесплатной игры

```sql
SELECT MIN(PRICE) FROM steam.games
WHERE price >0
```
<img width="159" height="57" alt="image" src="https://github.com/user-attachments/assets/5cfb32cd-e053-4aa3-bad5-8f4681c1c211" />

4 SUM

4.1 Хотим получить сколько стоят все игры вместе

```sql
SELECT SUM(price) FROM steam.games
```
<img width="165" height="60" alt="image" src="https://github.com/user-attachments/assets/d782a069-3d9f-481b-8dee-0d6477647cd7" />

5 STRING_AGG

5.1 Хотим получить список игр в строчку

```sql
SELECT STRING_AGG(title, ',') from steam.games;
```
<img width="787" height="54" alt="image" src="https://github.com/user-attachments/assets/a9b44184-84cc-4ca3-be29-1a3191ccfae9" />

5.2 Хотим получить список почт в строчку

```sql
SELECT STRING_AGG(email, ',') from steam.accounts;
```
<img width="848" height="47" alt="image" src="https://github.com/user-attachments/assets/b3aa90ee-0b35-41fa-b7a2-2f087789e6c2" />


6 GROUP BY

6.1 Хотим получить количество игр у каждого разработчика

```sql
SELECT steam.developers.name, COUNT(*) FROM steam.developers
JOIN steam.games g on developers.developer_id = g.developer_id
GROUP BY steam.developers.name
```
<img width="510" height="152" alt="image" src="https://github.com/user-attachments/assets/80e16761-b619-4548-b275-81bad82f07a6" />

7 Having

7.1 Хотим получить разработчиков с количеством игр больше 1

```sql
SELECT steam.developers.name, COUNT(*) FROM steam.developers
JOIN steam.games g on developers.developer_id = g.developer_id
GROUP BY steam.developers.name
HAVING COUNT(*) >1;
```
<img width="526" height="76" alt="image" src="https://github.com/user-attachments/assets/daabaff4-95e7-444e-a5c3-3ca7e03b18fb" />


7.2 Хотим получить список почт из таблицы steam.accounts

```sql
SELECT title
FROM steam.reviews JOIN steam.games
ON games.game_id = reviews.game_id
GROUP BY games.game_id
HAVING (COUNT(CASE WHEN rating THEN 1 END)*1.0/COUNT(reviews), 2) >= 0.92
```
<img width="309" height="120" alt="image" src="https://github.com/user-attachments/assets/6e59e07b-963a-4cab-9473-486955561bbf" />


8 GROUPING SETS, ROLLUP, CUBE

8.1 Хотим получить сколько денег получили за каждую игру и в сумме и сколько денег потратил каждый пользователь на игры

```sql
SELECT name, title, username, SUM(price)
FROM steam.developers
JOIN steam.games on developers.developer_id = games.developer_id
JOIN steam.account_game ag on games.game_id = ag.game_id
JOIN steam.accounts a on a.account_id = ag.account_id
GROUP BY GROUPING SETS ((name),(title),(username))
ORDER BY SUM(price)
```
<img width="1029" height="436" alt="image" src="https://github.com/user-attachments/assets/c438442d-1555-4160-b825-7a057d1c5a6b" />


8.2 Хотим получить сколько стоят в сумме игры разработчиков

```sql
SELECT name, title, SUM(price)
FROM steam.developers
JOIN steam.games on developers.developer_id = games.developer_id
GROUP BY ROLLUP (name, title)
```
<img width="821" height="319" alt="image" src="https://github.com/user-attachments/assets/3b7610e1-4535-496c-8aad-c34c73577986" />


8.3 Хотим получить сколько денег получили компании за каждую игру и в сумме

```sql
SELECT name, title, SUM(price)
FROM steam.developers
JOIN steam.games on developers.developer_id = games.developer_id
JOIN steam.account_game ag on games.game_id = ag.game_id
GROUP BY CUBE (name, title)
ORDER BY SUM(price)
```
<img width="817" height="460" alt="image" src="https://github.com/user-attachments/assets/3fbcfc25-383c-4ba8-a2a7-42cfef2edea4" />


9 SELECT, FROM, WHERE, GROUP BY, HAVING, ORDER BY

9.1 Хотим получить сколько денег потратил каждый пользователь на игры, сколько денег собрала каждая игра и сколько денег получила каждая компания разработчиков

```sql
SELECT name, title, username, SUM(price) as sum
FROM steam.developers
JOIN steam.games on developers.developer_id = games.developer_id
JOIN steam.account_game ag on games.game_id = ag.game_id
JOIN steam.accounts a on a.account_id = ag.account_id
WHERE price > 0
GROUP BY GROUPING SETS ((name),(title),(username))
HAVING SUM(price) > 300
ORDER BY sum
```
<img width="1030" height="248" alt="image" src="https://github.com/user-attachments/assets/a923563c-a271-4657-8abb-e2167fd9f6be" />



