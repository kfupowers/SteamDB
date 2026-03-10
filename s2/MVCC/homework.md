
```sql
INSERT INTO steam.genres(name) VALUES ('test1');

SELECT ctid, xmin, xmax, * from steam.genres;
```

![img.png](img.png)

```sql
UPDATE steam.genres SET name = 'new_test1' WHERE genre_id = 18;

SELECT ctid, xmin, xmax, * from steam.genres;
```

![img_1.png](img_1.png)


```sql
SELECT
t_ctid,        -- Физический адрес версии
t_xmin,        -- Кто вставил эту версию
t_xmax,        -- Кто удалил эту версию
t_infomask     -- Флаги (удаление, блокировка и т.д.)
FROM heap_page_items(get_raw_page('steam.genres', 0));
```
![img_2.png](img_2.png)

```sql
INSERT INTO steam.genres(name) VALUES ('deadlock_1'),('deadlock_2');

SELECT * from steam.genres;
```
![img_3.png](img_3.png)

READ COMMITED
```sql
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED ;
SELECT ctid, xmin, xmax,* FROM steam.genres WHERE genres.genre_id = 19;

SELECT ctid, xmin, xmax,* FROM steam.genres WHERE genres.genre_id = 19;

UPDATE steam.genres SET name = 'deadlock_1' WHERE genre_id = 19;

commit
```

```sql
BEGIN TRANSACTION ISOLATION LEVEL read committed;
UPDATE steam.genres SET name = 'READ COMMITTED' WHERE genre_id = 19;
commit;
```

![img_7.png](img_7.png)

![img_8.png](img_8.png)

```sql
SELECT ctid, xmin, xmax, * from steam.genres;
```

![img_9.png](img_9.png)

REPEATABLE READ
```sql
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ ;
SELECT ctid, xmin, xmax,* FROM steam.genres WHERE genres.genre_id = 19;

SELECT ctid, xmin, xmax,* FROM steam.genres WHERE genres.genre_id = 19;

UPDATE steam.genres SET name = 'REPEATABLE READ' WHERE genre_id = 19;

commit
```

```sql
BEGIN TRANSACTION ISOLATION LEVEL read committed;
UPDATE steam.genres SET name = 'READ COMMITTED' WHERE genre_id = 19;
commit;
```

![img_10.png](img_10.png)

![img_11.png](img_11.png)

![img_12.png](img_12.png)

```sql
SELECT ctid, xmin, xmax, * from steam.genres;
```

![img_13.png](img_13.png)


DEADLOCK
```sql
BEGIN;
UPDATE steam.genres SET name = 'new_deadlock_1' WHERE genre_id = 19;

UPDATE steam.genres SET name = 'super_new_deadlock_2' WHERE genre_id = 20;
```

```sql
BEGIN;
UPDATE steam.genres SET name = 'new_deadlock_2' WHERE genre_id = 20;

UPDATE steam.genres SET name = 'super_new_deadlock_1' WHERE genre_id = 19;
```

![img_4.png](img_4.png)

```sql
SELECT ctid, xmin, xmax, * from steam.genres;
```
![img_6.png](img_6.png)

БЛОКИРОВКИ НА УРОВНЕ СТРОК

```sql
BEGIN;
SELECT * FROM steam.genres WHERE genre_id = 1 FOR UPDATE;
commit
```

```sql
BEGIN;
SELECT * FROM steam.genres WHERE genre_id = 1 FOR share ;
commit
```

![img_14.png](img_14.png)


```sql
BEGIN;
SELECT * FROM steam.genres WHERE genre_id = 1 FOR KEY SHARE ;
commit
```

```sql
BEGIN;
SELECT * FROM steam.genres WHERE genre_id = 1 FOR NO KEY UPDATE ;
commit
```

![img_15.png](img_15.png)

```sql
INSERT INTO steam.achievements (achievement_id, game_id, name, description) VALUES
(50, 50 , 'test', 'test');

BEGIN;
SELECT * FROM steam.achievements WHERE achievement_id = 50 FOR KEY SHARE;
commit
```

```sql
BEGIN;
UPDATE steam.achievements SET description = 'NO KEY UPDATE' WHERE achievement_id = 50;
commit;
```

![img_16.png](img_16.png)

![img_17.png](img_17.png)

ОЧИСТКА

```sql
VACUUM (VERBOSE, ANALYZE)
```