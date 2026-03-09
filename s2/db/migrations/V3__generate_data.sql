 INSERT INTO steam.array_table(int_array_20, int_array, str_array_20, str_array, date_array) SELECT
(SELECT array_agg(random_int)
FROM (
    SELECT (random() * 5)::int AS random_int
    FROM generate_series(1, 20 +gs - gs)
)),
(SELECT array_agg(random_int)
FROM(
    SELECT (random() * 1000000)::int AS random_int
    FROM generate_series(1, (random()*50+gs - gs)::int)
)),
(SELECT array_agg(random_str)
FROM(
    SELECT LEFT(md5(random()::varchar), 2)  AS random_str
    FROM generate_series(1, 20+gs - gs)
)),
(SELECT array_agg(random_str)
FROM(
    SELECT LEFT(md5(random()::varchar), 10) AS random_str
    FROM generate_series(1, (random()*50+gs - gs)::int)
)),
(SELECT array_agg(random_date)
FROM(
    SELECT '2021-01-01'::date + (random() * ('2025-12-31'::date - '2021-01-01'::date)) :: int AS random_date
    FROM generate_series(1, (random()*50 + gs - gs)::int)
)) FROM generate_series(0, 250000) as gs;


INSERT INTO steam.others_table(fld_point, fld_line, full_text, range_int) SELECT
point((random()*1000000)::int, (random()*1000000)::int),
format('{%s, %s, %s}',
           (random()*5000)::int,
           (random()*10000 - 5000)::int,
           (random()*1000000)::int)::line,
(SELECT string_agg(random_str, ' ')
FROM(
    SELECT LEFT(md5(random()::varchar), (random()*20+1)::int) AS random_str
    FROM generate_series(1, (random()*50 +gs - gs)::int)
))::tsvector,
int4range((rnd*1000000)::int, (rnd * 1000000 + random()*1000000)::int)
FROM generate_series(0, 250000) gs, LATERAL (SELECT random() + gs - gs as rnd);


INSERT INTO steam.accounts (username, email, password, wallet_balance) SELECT
'user' || gs,
LEFT(md5(random()::varchar), 10) || '@gmail.com',
'pass' || LEFT(md5(random()::varchar), 15),
(random()*5000)::int
FROM generate_series(0, 250000) as gs;

INSERT INTO steam.games(developer_id, title, description, release_date, price) SELECT
(random()*9 + 1)::int,
'game' || gs,
'description' || LEFT(md5(random()::varchar), 100),
'2021-01-01'::date + (random() * ('2025-12-31'::date - '2000-01-01'::date)) :: int,
random()*5000
FROM generate_series(0, 250000) as gs;


