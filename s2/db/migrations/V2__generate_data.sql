INSERT INTO indexes.int_table(uniform_int, skewed_int, low_selectivity_int, high_selectivity_int, range_int)
SELECT gs % 500,
CASE WHEN random() * 50 > 5 THEN (random() * 200 + 200)::int
WHEN random()*50 > 3 THEN (random()*100 + 100)::int
ELSE (random()*100)::int
END,
 (ARRAY[2, 3, 5, 8, 13])[floor(random() * 5 + 1)::int],
(random()*1000000)::int,
int4range((rnd*1000000)::int, (rnd * 1000000 + random()*1000000)::int)
FROM generate_series(1, 250000) gs, LATERAL (SELECT random() + gs - gs as rnd);


INSERT INTO indexes.str_table(int_id, uniform_str, skewed_str, low_selectivity_str, high_selectivity_str, full_text) SELECT
(SELECT id FROM indexes.int_table ORDER BY random() LIMIT 1),
 chr((65 + gs % (26*26) / 26))::varchar ||  chr((65 + gs % 26))::varchar,
 CASE WHEN random()  < 0.98 THEN 'good'
ELSE LEFT(md5(random()::varchar), 4)
END,
(ARRAY['a', 'b', 'c', 'd', 'e'])[floor(random() * 5 + 1)::int],
 CASE WHEN random()  < 0.17 THEN null
ELSE LEFT(md5(random()::varchar), 10)
END,
(SELECT string_agg(random_str, ' ')
FROM(
    SELECT LEFT(md5(random()::varchar), (random()*20+1)::int) AS random_str
    FROM generate_series(1, (random()*50)::int)
))::tsvector
 FROM  generate_series(0, 250000) gs;


 INSERT INTO indexes.array_table(int_array_20, int_array, str_array_20, str_array, date_array) SELECT
(SELECT array_agg(random_int)
FROM (
    SELECT (random() * 5)::int AS random_int
    FROM generate_series(1, 20)
)),
(SELECT array_agg(random_int)
FROM(
    SELECT (random() * 1000000)::int AS random_int
    FROM generate_series(1, (random()*50)::int)
)),
(SELECT array_agg(random_str)
FROM(
    SELECT LEFT(md5(random()::varchar), 2)  AS random_str
    FROM generate_series(1, 20)
)),
(SELECT array_agg(random_str)
FROM(
    SELECT LEFT(md5(random()::varchar), 10) AS random_str
    FROM generate_series(1, (random()*50)::int)
)),
(SELECT array_agg(random_date)
FROM(
    SELECT '2021-01-01'::date + (random() * ('2025-12-31'::date - '2021-01-01'::date)) :: int AS random_date
    FROM generate_series(1, (random()*50)::int)
)) FROM generate_series(0, 250000);


INSERT INTO indexes.others_table(fld_point, fld_line, date_range) SELECT
point(random()*1000000, random()*1000000),
format('{%s, %s, %s}',
           random()*5000,
           random()*10000 - 5000,
           random()*1000000)::line,
daterange('2021-01-01'::date + (rnd * ('2025-12-31'::date - '2021-01-01'::date)) :: int,
'2021-01-01'::date + (rnd * ('2025-12-31'::date - '2021-01-01'::date))::int + (random() * ('2025-12-31'::date - (rnd * ('2025-12-31'::date - '2021-01-01'::date))::int  - '2021-01-01'::date))::int)
FROM generate_series(0, 250000) gs, LATERAL (SELECT random() + gs - gs as rnd);