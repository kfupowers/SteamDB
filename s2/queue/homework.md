1 Создание таблицы

```sql
CREATE TABLE IF NOT EXISTS steam.tasks (
task_id         BIGSERIAL PRIMARY KEY,
task_type       VARCHAR(50)   NOT NULL,
payload         JSONB         NOT NULL,
priority        INT           NOT NULL DEFAULT 0,
status          VARCHAR(20)   NOT NULL DEFAULT 'ready',
created_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
scheduled_at    TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
attempts        INT           NOT NULL DEFAULT 0,
max_attempts    INT           NOT NULL DEFAULT 3,
last_error      TEXT          NULL,
started_at      TIMESTAMPTZ   NULL,
completed_at    TIMESTAMPTZ   NULL
);


CREATE INDEX IF NOT EXISTS idx_tasks_fetch
ON steam.tasks (priority DESC, scheduled_at ASC)
WHERE status = 'ready';

CREATE INDEX IF NOT EXISTS idx_tasks_lag
ON steam.tasks (created_at)
WHERE status = 'ready';
```

2 Вычисление лага

```sql
SELECT 
    EXTRACT(EPOCH FROM (NOW() - created_at)) AS lag_seconds,
    task_id,
    created_at
FROM steam.tasks
WHERE status = 'ready'
ORDER BY created_at ASC
LIMIT 1;
```

3 Autovacuum
```sql
ALTER TABLE steam.tasks SET (
autovacuum_vacuum_scale_factor = 0.0,
autovacuum_vacuum_threshold = 1000,
autovacuum_analyze_scale_factor = 0.0,
autovacuum_analyze_threshold = 1000
);
```