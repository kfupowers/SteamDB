import org.postgresql.PGConnection;

import java.sql.*;
import java.time.Instant;
import java.util.Random;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.atomic.AtomicLong;

public class TaskQueue {

    private static final String DB_URL = "jdbc:postgresql://localhost:5432/postgres";
    private static final String DB_USER = "postgres";
    private static final String DB_PASS = "teamwork.tf";

    private static final String NOTIFY_CHANNEL = "task_inserted";

    private static final Random RAND = new Random();

    public static void main(String[] args) throws Exception {
        Class.forName("org.postgresql.Driver");

        ExecutorService executor = Executors.newFixedThreadPool(3);
        executor.submit(new Producer());
        executor.submit(new Consumer("worker-1"));
        executor.submit(new Consumer("worker-2"));

        Thread.sleep(300000);
        executor.shutdownNow();
    }

    static class Producer implements Runnable {
        @Override
        public void run() {
            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
                conn.setAutoCommit(false);
                while (!Thread.currentThread().isInterrupted()) {

                    String taskType = randomTaskType();
                    String payload = generatePayload(taskType);
                    int priority = RAND.nextInt(100) < 80 ? 0 : 100;

                    try {
                        PreparedStatement logStmt = conn.prepareStatement(
                                "INSERT INTO steam.query_history (account_name, query_time, operation) VALUES (?, NOW(), 'task_insert')"
                        );
                        logStmt.setString(1, DB_USER);
                        logStmt.executeUpdate();

                        PreparedStatement taskStmt = conn.prepareStatement(
                                "INSERT INTO steam.tasks (task_type, payload, priority) VALUES (?, ?::jsonb, ?)"
                        );
                        taskStmt.setString(1, taskType);
                        taskStmt.setString(2, payload);
                        taskStmt.setInt(3, priority);
                        taskStmt.executeUpdate();

                        conn.commit();

                        try (Statement notifyStmt = conn.createStatement()) {
                            notifyStmt.execute("NOTIFY " + NOTIFY_CHANNEL);
                        }

                        System.out.printf("[PRODUCER] Inserted %s task (priority=%d)%n", taskType, priority);
                    } catch (SQLException e) {
                        conn.rollback();
                        System.err.println("[PRODUCER] Error: " + e.getMessage());
                    }

                    Thread.sleep(RAND.nextInt(3) + 1);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        private String randomTaskType() {
            String[] types = {"recalc_rating", "notify_achievement", "cleanup_temp", "update_stats"};
            return types[RAND.nextInt(types.length)];
        }

        private String generatePayload(String type) {
            switch (type) {
                case "recalc_rating":
                    return String.format("{\"game_id\": %d}", RAND.nextInt(1000) + 1);
                case "notify_achievement":
                    return String.format("{\"user_id\": %d, \"achievement_id\": %d}", RAND.nextInt(500) + 1, RAND.nextInt(2000) + 1);
                default:
                    return "{}";
            }
        }
    }

    static class Consumer implements Runnable {
        private final String name;

        Consumer(String name) {
            this.name = name;
        }

        @Override
        public void run() {
            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
                conn.setAutoCommit(true);
                PGConnection pgConn = conn.unwrap(PGConnection.class);

                try (Statement stmt = conn.createStatement()) {
                    stmt.execute("LISTEN " + NOTIFY_CHANNEL);
                }

                while (!Thread.currentThread().isInterrupted()) {
                    Task task = fetchAndLockTask(conn);
                    if (task != null) {
                        processTask(conn, task);
                        continue;
                    }

                    try {
                        pgConn.getNotifications(2000);
                    } catch (SQLException e) {
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        private Task fetchAndLockTask(Connection conn) throws SQLException {
            conn.setAutoCommit(false);
            try {
                PreparedStatement selectStmt = conn.prepareStatement(
                        "SELECT task_id, task_type, payload, priority, attempts " +
                                "FROM steam.tasks " +
                                "WHERE status = 'ready' " +
                                "  AND scheduled_at <= NOW() " +
                                "ORDER BY priority DESC, scheduled_at ASC " +
                                "LIMIT 1 " +
                                "FOR UPDATE SKIP LOCKED"
                );
                ResultSet rs = selectStmt.executeQuery();
                if (rs.next()) {
                    Task task = new Task();
                    task.id = rs.getLong("task_id");
                    task.type = rs.getString("task_type");
                    task.payload = rs.getString("payload");
                    task.priority = rs.getInt("priority");
                    task.attempts = rs.getInt("attempts");

                    PreparedStatement updateStmt = conn.prepareStatement(
                            "UPDATE steam.tasks SET status = 'running', started_at = NOW() WHERE task_id = ?"
                    );
                    updateStmt.setLong(1, task.id);
                    updateStmt.executeUpdate();

                    conn.commit();
                    return task;
                }
                conn.commit();
                return null;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }

        private void processTask(Connection conn, Task task) throws SQLException {
            System.out.printf("[%s] Picked task #%d (type=%s, priority=%d)%n", name, task.id, task.type, task.priority);
            long start = System.currentTimeMillis();

            try {
                Thread.sleep(RAND.nextInt(10) + 5);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                markTaskCompleted(conn, task.id, false, "Interrupted");
                return;
            }

            boolean success = RAND.nextInt(100) < 90;
            if (success) {
                markTaskCompleted(conn, task.id, true, null);
                long duration = System.currentTimeMillis() - start;
                System.out.printf("[%s] Completed task #%d in %d ms%n", name, task.id, duration);
            } else {
                String errorMsg = "Simulated processing error";
                markTaskCompleted(conn, task.id, false, errorMsg);

                if (task.attempts + 1 < 3) {
                    PreparedStatement retryStmt = conn.prepareStatement(
                            "UPDATE steam.tasks SET status = 'ready', " +
                                    "scheduled_at = NOW() + (power(2, ?) * INTERVAL '1 minute'), " +
                                    "attempts = attempts + 1, last_error = ? " +
                                    "WHERE task_id = ?"
                    );
                    retryStmt.setInt(1, task.attempts);
                    retryStmt.setString(2, errorMsg);
                    retryStmt.setLong(3, task.id);
                    retryStmt.executeUpdate();
                    System.out.printf("[%s] Task #%d failed, scheduled retry #%d%n", name, task.id, task.attempts + 1);
                } else {
                    System.out.printf("[%s] Task #%d permanently failed after %d attempts%n", name, task.id, task.attempts);
                }
            }
        }

        private void markTaskCompleted(Connection conn, long taskId, boolean success, String error) throws SQLException {
            PreparedStatement stmt = conn.prepareStatement(
                    "UPDATE steam.tasks SET status = ?, completed_at = NOW(), last_error = ? WHERE task_id = ?"
            );
            stmt.setString(1, success ? "completed" : "failed");
            stmt.setString(2, error);
            stmt.setLong(3, taskId);
            stmt.executeUpdate();
        }

        static class Task {
            long id;
            String type;
            String payload;
            int priority;
            int attempts;
        }
    }
}