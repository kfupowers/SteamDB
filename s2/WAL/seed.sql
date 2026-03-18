INSERT INTO steam.accounts (username, email, password, wallet_balance) SELECT
'user' || gs,
LEFT(md5(random()::varchar), 10) || '@gmail.com',
'pass' || LEFT(md5(random()::varchar), 15),
(random()*5000)::int
FROM generate_series(0, 25000) as gs
ON CONFLICT DO NOTHING;

SELECT COUNT(*) FROM steam.accounts;