EXPLAIN ANALYSE SELECT * FROM indexes.int_table WHERE uniform_int = 100;

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM indexes.int_table WHERE uniform_int = 100;



CREATE INDEX int_table_uniform_int_index ON indexes.int_table (uniform_int);

EXPLAIN ANALYSE SELECT * FROM indexes.int_table WHERE uniform_int = 100;

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM indexes.int_table WHERE uniform_int = 100;

DROP INDEX int_table_uniform_int_index;



CREATE INDEX int_table_uniform_int_index_hash ON indexes.int_table (uniform_int);

EXPLAIN ANALYSE SELECT * FROM indexes.int_table WHERE uniform_int = 100;

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM indexes.int_table WHERE uniform_int = 100;

DROP INDEX int_table_uniform_int_index_hash;



EXPLAIN ANALYSE SELECT * FROM indexes.int_table WHERE skewed_int < 100;

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM indexes.int_table WHERE skewed_int < 100;


CREATE INDEX int_table_skewed_int_index ON indexes.int_table (skewed_int);

EXPLAIN ANALYSE SELECT * FROM indexes.int_table WHERE skewed_int < 100;

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM indexes.int_table WHERE skewed_int < 100;

DROP INDEX int_table_skewed_int_index;



CREATE INDEX int_table_skewed_int_index_hash ON indexes.int_table (skewed_int);

EXPLAIN ANALYSE SELECT * FROM indexes.int_table WHERE skewed_int < 100;

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM indexes.int_table WHERE skewed_int < 100;

DROP INDEX int_table_skewed_int_index_hash;



EXPLAIN ANALYSE SELECT * FROM indexes.int_table WHERE int_table.low_selectivity_int IN (2, 3);

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM indexes.int_table WHERE int_table.low_selectivity_int IN (2, 3);



CREATE INDEX int_table_low_selectivity_int_index ON indexes.int_table (low_selectivity_int);

EXPLAIN ANALYSE SELECT * FROM indexes.int_table WHERE int_table.low_selectivity_int IN (2, 3);

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM indexes.int_table WHERE int_table.low_selectivity_int IN (2, 3);

DROP INDEX int_table_low_selectivity_int_index;



CREATE INDEX int_table_low_selectivity_int_index_hash ON indexes.int_table (low_selectivity_int);

EXPLAIN ANALYSE SELECT * FROM indexes.int_table WHERE int_table.low_selectivity_int IN (2, 3);

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM indexes.int_table WHERE int_table.low_selectivity_int IN (2, 3);

DROP INDEX int_table_low_selectivity_int_index_hash;



EXPLAIN ANALYSE SELECT * FROM indexes.int_table WHERE int_table.high_selectivity_int BETWEEN 100000 AND 100010;

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM indexes.int_table WHERE int_table.high_selectivity_int BETWEEN 100000 AND 100010;



CREATE INDEX int_table_high_selectivity_int_index ON indexes.int_table (high_selectivity_int);

EXPLAIN ANALYSE SELECT * FROM indexes.int_table WHERE int_table.high_selectivity_int BETWEEN 100000 AND 100010;

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM indexes.int_table WHERE int_table.high_selectivity_int BETWEEN 100000 AND 100010;

DROP INDEX int_table_high_selectivity_int_index;



CREATE INDEX int_table_high_selectivity_int_index_hash ON indexes.int_table (high_selectivity_int);

EXPLAIN ANALYSE SELECT * FROM indexes.int_table WHERE int_table.high_selectivity_int BETWEEN 100000 AND 100010;

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM indexes.int_table WHERE int_table.high_selectivity_int BETWEEN 100000 AND 100010;

DROP INDEX int_table_high_selectivity_int_index_hash;


EXPLAIN ANALYSE SELECT * FROM indexes.str_table WHERE str_table.skewed_str <> 'good';

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM indexes.str_table WHERE str_table.skewed_str <> 'good';



CREATE INDEX str_table_skewed_str_index ON indexes.str_table (skewed_str);

EXPLAIN ANALYSE SELECT * FROM indexes.str_table WHERE str_table.skewed_str <> 'good';

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM indexes.str_table WHERE str_table.skewed_str <> 'good';

DROP INDEX str_table_skewed_str_index;



CREATE INDEX str_table_skewed_str_index_hash ON indexes.str_table (skewed_str);

EXPLAIN ANALYSE SELECT * FROM indexes.str_table WHERE str_table.skewed_str <> 'good';

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM indexes.str_table WHERE str_table.skewed_str <> 'good';

DROP INDEX str_table_skewed_str_index_hash;