1.1 Хотим получить название игры, количество положительных отзывов,
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

1.2 Хотим для каждой игры посчитать цену после скидки при условии,
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

2.1 Хотим получить почты аккаунтов, которые выполнили определенную ачивку.

```sql
SELECT steam.accounts.email, steam.achievements.name
FROM steam.ownership_achievement INNER JOIN steam.achievements
ON ownership_achievement.achievement_id = achievements.achievement_id AND achievements.name = 'Утешительный приз'
INNER JOIN steam.account_game ON account_game.ownership_id = ownership_achievement.ownership_id
INNER JOIN steam.accounts ON account_game.account_id = accounts.account_id;
```

<img width="466" height="90" alt="image" src="https://github.com/user-attachments/assets/a0f99800-a365-4327-99e9-92d6741af404" />


2.2 Хотим получить сочетания всех жанров друг с другом,
чтобы придумать игру с новым или редким сочетанием жанром
```sql
SELECT genres.name, g.name
FROM steam.genres CROSS JOIN (SELECT * FROM steam.genres) AS g
WHERE genres.name > g.name;
```
<img width="503" height="534" alt="image" src="https://github.com/user-attachments/assets/967b406a-7e4e-4732-8501-c42ebfe14fd7" />
