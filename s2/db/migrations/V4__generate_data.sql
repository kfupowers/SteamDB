INSERT INTO steam.reviews(game_id, account_id, rating, comment, review_date) SELECT
(gs%200000 + 100)::int,
(gs%13333 + 200)::int,
(ARRAY[true, false])[floor(random()*2 + 1)::int],
'comment' || LEFT(md5(random()::varchar), 100),
'2021-01-01'::date + (random() * ('2025-12-31'::date - '2000-01-01'::date)) :: int
FROM generate_series(0, 250000) as gs;