<img width="595" height="141" alt="image" src="https://github.com/user-attachments/assets/bce4a813-0df4-4968-bebd-f31c13da2b25" />1 Выборка всех данных из таблицы

1.1 Хотим получить таблицу games
```sql
SELECT * FROM steam.games
```

<img width="1629" height="173" alt="image" src="https://github.com/user-attachments/assets/cc2fe26b-b725-4be7-9ef5-317b36b717d4" />

1.2 Хотим получить таблицу accounts
```sql
SELECT * FROM steam.accounts
```

<img width="1218" height="175" alt="image" src="https://github.com/user-attachments/assets/68a9fdb1-8cd4-41e8-91bb-48a32196a1a3" />

2 Выборка отдельных столбцов

2.1 Хотим получить список игр из таблицы steam.games

```sql
SELECT title FROM steam.games
```
<img width="311" height="188" alt="image" src="https://github.com/user-attachments/assets/f92087ba-4d74-49f6-8387-9b0bc5374bde" />

2.2 Хотим получить список почт из таблицы steam.accounts

```sql
SELECT email FROM steam.accounts
```
<img width="206" height="167" alt="image" src="https://github.com/user-attachments/assets/f4093f5f-727f-4a0f-8c3c-51c85734f7b3" />

3 Присвоение новых имен слобцам при формировании выборки

3.1 Хотим получить список игр из таблицы steam.games

```sql
SELECT title AS Название FROM steam.games
```
<img width="304" height="181" alt="image" src="https://github.com/user-attachments/assets/49bcc84c-8163-43b8-8842-2edbea11ff67" />

3.2 Хотим получить список почт из таблицы steam.accounts

```sql
SELECT email AS ПОЧТА FROM steam.accounts
```
<img width="209" height="177" alt="image" src="https://github.com/user-attachments/assets/d1364ccf-6010-42bd-a104-15362bd38ff1" />

4 Выборка данных, вычисляемые столбцы, математические функции

4.1 Хотим получить цены игр из таблицы steam.games до и после скидки

```sql
SELECT price, ROUND(price*90.0/100) as sale_price FROM steam.games
```
<img width="456" height="173" alt="image" src="https://github.com/user-attachments/assets/c0a18988-4f4c-4d72-9141-d3c618768f03" />

5 Выборка данных по условию

5.1 Хотим получить названия бесплатных игр

```sql
SELECT title FROM steam.games
WHERE price = 0
```
<img width="302" height="98" alt="image" src="https://github.com/user-attachments/assets/295e8606-7b1c-4a6f-b750-9578fa908212" />

5.2 Хотим получить названия игр, у которых цена после скидку меньше 600

```sql
SELECT title, price*90.0/100 as sale_price FROM steam.games
WHERE price*90.0/100  < 600
```

<img width="595" height="141" alt="image" src="https://github.com/user-attachments/assets/8fcb2a19-2379-4292-b0f0-d554eead3b05" />

6 Логические операции

6.1 Хотим получить не бесплатные игры Valve

```sql
SELECT title, price as sale_price FROM steam.games
WHERE price != 0 AND developer_id = 1
```

<img width="587" height="69" alt="image" src="https://github.com/user-attachments/assets/33e4df47-48f4-48d7-b1e1-da8d813c1964" />

6.2 
```sql
SELECT title, price FROM steam.games
WHERE price !=0 AND developer_id = 1 OR developer_id =2
```
<img width="538" height="59" alt="image" src="https://github.com/user-attachments/assets/2c3aa838-3ee2-4d65-b091-d67c0b5d93b7" />


7 Операторы BETWEEN, IN

7.1Хотим получить игры в ценовом диапозоне от 500 до 700
```sql
SELECT title, price FROM steam.games
WHERE price BETWEEN 500 AND 700;
```

<img width="379" height="89" alt="image" src="https://github.com/user-attachments/assets/6e7b015c-a9b6-4bb8-bc0a-072fcf370a5a" />

7.2 Хотим получить все поля игр Celeste и Super Meat Boy
```sql
SELECT * FROM steam.games
WHERE title IN ('Celeste', 'Super Meat Boy')
```

<img width="1618" height="94" alt="image" src="https://github.com/user-attachments/assets/8c3945a7-4117-4cb3-b248-3a410bdaed8e" />

8 Выборка данных с сортировкой


8.1 Хотим получить игры отсортированные по названию команды разработчиков и цене

```sql
SELECT developers.name, games.title, price FROM steam.developers join steam.games
ON developers.developer_id = games.developer_id
ORDER BY developers.name, price DESC;
```

<img width="824" height="176" alt="image" src="https://github.com/user-attachments/assets/b31d2d70-be48-45b8-bf6a-fe7e5f13fc82" />

8.2  Хотим получить игры отсортированные по цене
```sql
SELECT title, price FROM steam.games
ORDER BY price DESC
```

<img width="546" height="186" alt="image" src="https://github.com/user-attachments/assets/4d2185ea-c9c9-487c-908f-deedc91de4ff" />

9 Выборка данных оператор Like

9.1 Игры начинающиеся на S

```sql
SELECT title FROM steam.games
WHERE title LIKE 'S%'
```

<img width="302" height="97" alt="image" src="https://github.com/user-attachments/assets/0e3bdd60-7a0d-4379-9e51-52841f16a4f1" />

9.2 Игры, названия которых состоят из нескольких слов
```sql
SELECT title FROM steam.games
WHERE title LIKE '_% _%'
```

<img width="537" height="122" alt="image" src="https://github.com/user-attachments/assets/031f2529-53c7-4cef-9015-a64a2a29674a" />

10 Выбор ограниченного количества возвращаемых строк 

10.1
```sql
SELECT title, price FROM steam.games
ORDER BY price DESC
LIMIT 3
```

<img width="650" height="137" alt="image" src="https://github.com/user-attachments/assets/1d9c2729-7a6e-46cb-93d3-a08181557fc4" />


10.2
```sql
SELECT developers.name, games.title FROM steam.developers join steam.games 
ON developers.developer_id = games.developer_id
ORDER BY developers.name
LIMIT 3
```

![Uploading image.png…]()


11 Запросы на выборку из нескольких таблиц, логические функции

11.1 Хотим получить название игры, количество положительных отзывов,
сколько всего отзывов, процент положительных отзывов и категория,
к которой можно отнести игру по отзывам.

```sql
SELECT title, positive_reviews, all_reviews, percent_of_reviews,
CASE
    WHEN percent_of_reviews > 0.95 THEN 'Крайне положительные'
    WHEN percent_of_reviews BETWEEN 0.8 AND 0.94 THEN 'Очень положительные'
    WHEN percent_of_reviews BETWEEN 0.7 AND 0.79 THEN 'Положительные'
    WHEN percent_of_reviews BETWEEN 0.4 AND 0.69 THEN 'Смешанные'
    WHEN percent_of_reviews BETWEEN 0.2 AND 0.39 THEN 'Отрицательные'
    WHEN percent_of_reviews < 0.19 THEN 'Очень отрицательные'
    END as review_categories
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

<img width="999" height="146" alt="image" src="https://github.com/user-attachments/assets/5fc25564-1ec3-4337-94cd-9923aa88240c" />

11.2 Хотим для каждой игры посчитать цену после скидки при условии,
что игры с жанром платформер получают скидку 40%, а остальные 10%.
```sql
SELECT title, name, price,
ROUND(
CASE
    WHEN genres.name = 'Платформер' THEN price * 0.6
    ELSE price * 0.9
END, 0) AS sale
FROM steam.genres INNER JOIN steam.game_genre
ON genres.name = 'Платформер' and genres.genre_id = game_genre.genre_id
RIGHT JOIN steam.games on games.game_id = game_genre.game_id;
```
<img width="888" height="175" alt="img_1" src="https://github.com/user-attachments/assets/2a2e4df6-e68a-4a40-8a83-c58da00eeef8" />

11.3 Хотим получить почты аккаунтов, которые выполнили определенную ачивку.

```sql
SELECT steam.accounts.email, steam.achievements.name
FROM steam.ownership_achievement INNER JOIN steam.achievements
ON ownership_achievement.achievement_id = achievements.achievement_id AND achievements.name = 'Утешительный приз'
INNER JOIN steam.account_game ON account_game.ownership_id = ownership_achievement.ownership_id
INNER JOIN steam.accounts ON account_game.account_id = accounts.account_id;
```

<img width="466" height="90" alt="image" src="https://github.com/user-attachments/assets/a0f99800-a365-4327-99e9-92d6741af404" />


11.4 Хотим получить сочетания всех жанров друг с другом,
чтобы придумать игру с новым или редким сочетанием жанром
```sql
SELECT genres.name, g.name
FROM steam.genres CROSS JOIN (SELECT * FROM steam.genres) AS g
WHERE genres.name > g.name;
```
<img width="503" height="534" alt="image" src="https://github.com/user-attachments/assets/967b406a-7e4e-4732-8501-c42ebfe14fd7" />
