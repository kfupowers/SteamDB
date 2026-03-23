Архитектура
![Архитектура репликации.png](Архитектура репликации.png)


Вставка на мастере
```sql
INSERT INTO steam.genres(name) VALUES ('REPLICA');
```
```sql
SELECT * from steam.genres;
```
![img.png](img.png)

Вставка на реплике
```sql
INSERT INTO steam.genres(name) VALUES ('REPLICA_ON_REPLICA');
```
![img_1.png](img_1.png)

Анализ lag

while ($true) {
docker exec postgres psql -U postgres -d steamDB -c "SELECT application_name, write_lag, flush_lag, replay_lag FROM pg_stat_replication;"
Start-Sleep -Seconds 5
}

![img_2.png](img_2.png)

![img_3.png](img_3.png)

![img_4.png](img_4.png)

Логически репликации

```sql
CREATE PUBLICATION alltables FOR ALL TABLES;
```
```sql
CREATE SUBSCRIPTION subs
CONNECTION 'host=logical1 port=5432 dbname=steamDB user=postgres password=teamwork.tf application_name=sub1'
PUBLICATION alltables;
```

```sql
INSERT INTO steam.genres(name) VALUES ('LOGICAL')
```

![img_5.png](img_5.png)

```sql
ALTER TABLE steam.developers ADD COLUMN subs integer;
INSERT INTO steam.developers(name, subs) VALUES ('DEV_LOG', 100)
```

```sql
SELECT * FROM steam.developers
```

реплика
![img_6.png](img_6.png)

мастер
![img_7.png](img_7.png)

```sql
CREATE TABLE steam.logical_rep (
    id int
);

INSERT INTO steam.logical_rep(id) VALUES (1),(5);
```

![img_8.png](img_8.png)

```sql
SELECT * FROM pg_stat_replication;
```

![img_9.png](img_9.png)

После того как синхронизовал все таблицы вручную
![img_10.png](img_10.png)