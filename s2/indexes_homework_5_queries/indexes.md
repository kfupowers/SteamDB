EXPLAIN ANALYSE SELECT * FROM indexes.int_table WHERE uniform_int = 100;

![img.png](img.png)

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM indexes.int_table WHERE uniform_int = 100;

![img_1.png](img_1.png)


CREATE INDEX int_table_uniform_int_index ON indexes.int_table (uniform_int);

EXPLAIN ANALYSE SELECT * FROM indexes.int_table WHERE uniform_int = 100;

![img_2.png](img_2.png)

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM indexes.int_table WHERE uniform_int = 100;

![img_3.png](img_3.png)

DROP INDEX indexes.int_table_uniform_int_index;



CREATE INDEX int_table_uniform_int_index_hash ON indexes.int_table USING hash (uniform_int);

EXPLAIN ANALYSE SELECT * FROM indexes.int_table WHERE uniform_int = 100;

![img_4.png](img_4.png)

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM indexes.int_table WHERE uniform_int = 100;

![img_5.png](img_5.png)

DROP INDEX indexes.int_table_uniform_int_index_hash;



EXPLAIN ANALYSE SELECT * FROM indexes.int_table WHERE skewed_int < 100;

![img_6.png](img_6.png)

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM indexes.int_table WHERE skewed_int < 100;

![img_7.png](img_7.png)


CREATE INDEX int_table_skewed_int_index ON indexes.int_table (skewed_int);

EXPLAIN ANALYSE SELECT * FROM indexes.int_table WHERE skewed_int < 100;

![img_8.png](img_8.png)

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM indexes.int_table WHERE skewed_int < 100;

![img_9.png](img_9.png)

DROP INDEX indexes.int_table_skewed_int_index;



CREATE INDEX int_table_skewed_int_index_hash ON indexes.int_table USING hash (skewed_int);

EXPLAIN ANALYSE SELECT * FROM indexes.int_table WHERE skewed_int < 100;

![img_10.png](img_10.png)

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM indexes.int_table WHERE skewed_int < 100;

![img_11.png](img_11.png)

DROP INDEX indexes.int_table_skewed_int_index_hash;



EXPLAIN ANALYSE SELECT * FROM indexes.int_table WHERE int_table.low_selectivity_int IN (2, 3);

![img_12.png](img_12.png)

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM indexes.int_table WHERE int_table.low_selectivity_int IN (2, 3);

![img_13.png](img_13.png)


CREATE INDEX int_table_low_selectivity_int_index ON indexes.int_table (low_selectivity_int);

EXPLAIN ANALYSE SELECT * FROM indexes.int_table WHERE int_table.low_selectivity_int IN (2, 3);

![img_14.png](img_14.png)

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM indexes.int_table WHERE int_table.low_selectivity_int IN (2, 3);

![img_15.png](img_15.png)

DROP INDEX indexes.int_table_low_selectivity_int_index;



CREATE INDEX int_table_low_selectivity_int_index_hash ON indexes.int_table USING hash (low_selectivity_int);

EXPLAIN ANALYSE SELECT * FROM indexes.int_table WHERE int_table.low_selectivity_int IN (2, 3);

![img_16.png](img_16.png)

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM indexes.int_table WHERE int_table.low_selectivity_int IN (2, 3);

![img_17.png](img_17.png)

DROP INDEX indexes.int_table_low_selectivity_int_index_hash;



EXPLAIN ANALYSE SELECT * FROM indexes.int_table WHERE int_table.high_selectivity_int BETWEEN 100000 AND 100010;

![img_18.png](img_18.png)

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM indexes.int_table WHERE int_table.high_selectivity_int BETWEEN 100000 AND 100010;

![img_19.png](img_19.png)



CREATE INDEX int_table_high_selectivity_int_index ON indexes.int_table (high_selectivity_int);

EXPLAIN ANALYSE SELECT * FROM indexes.int_table WHERE int_table.high_selectivity_int BETWEEN 100000 AND 100010;

![img_20.png](img_20.png)

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM indexes.int_table WHERE int_table.high_selectivity_int BETWEEN 100000 AND 100010;

![img_21.png](img_21.png)

DROP INDEX indexes.int_table_high_selectivity_int_index;



CREATE INDEX int_table_high_selectivity_int_index_hash ON indexes.int_table USING hash(high_selectivity_int);

EXPLAIN ANALYSE SELECT * FROM indexes.int_table WHERE int_table.high_selectivity_int BETWEEN 100000 AND 100010;

![img_22.png](img_22.png)

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM indexes.int_table WHERE int_table.high_selectivity_int BETWEEN 100000 AND 100010;

![img_23.png](img_23.png)

DROP INDEX indexes.int_table_high_selectivity_int_index_hash;


EXPLAIN ANALYSE SELECT * FROM indexes.str_table WHERE str_table.skewed_str <> 'good';

![img_24.png](img_24.png)

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM indexes.str_table WHERE str_table.skewed_str <> 'good';

![img_25.png](img_25.png)


CREATE INDEX str_table_skewed_str_index ON indexes.str_table (skewed_str);

EXPLAIN ANALYSE SELECT * FROM indexes.str_table WHERE str_table.skewed_str <> 'good';

![img_26.png](img_26.png)

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM indexes.str_table WHERE str_table.skewed_str <> 'good';

![img_27.png](img_27.png)

DROP INDEX indexes.str_table_skewed_str_index;



CREATE INDEX str_table_skewed_str_index_hash ON indexes.str_table USING hash(skewed_str);

EXPLAIN ANALYSE SELECT * FROM indexes.str_table WHERE str_table.skewed_str <> 'good';

![img_28.png](img_28.png)

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM indexes.str_table WHERE str_table.skewed_str <> 'good';

![img_29.png](img_29.png)

DROP INDEX indexes.str_table_skewed_str_index_hash;