CREATE SCHEMA indexes;

CREATE TABLE indexes.int_table (
    id SERIAL PRIMARY KEY,
    uniform_int INT,
    skewed_int INT,
    low_selectivity_int INT,
    high_selectivity_int INT,
    range_int int4range
);

CREATE TABLE indexes.str_table (
    int_id INT NOT NULL,
    uniform_str VARCHAR,
    skewed_str VARCHAR,
    low_selectivity_str VARCHAR,
    high_selectivity_str VARCHAR,
    full_text tsvector,
    ----------------------------
    CONSTRAINT str_id_fk FOREIGN KEY (int_id)
        REFERENCES indexes.int_table(id)
);



CREATE TABLE indexes.array_table (
    id SERIAL PRIMARY KEY,
    int_array_20 INT[20],
    int_array INT[],
    str_array_20 VARCHAR[20],
    str_array VARCHAR[],
    date_array VARCHAR[]
);



CREATE TABLE indexes.others_table (
    id SERIAL PRIMARY KEY,
    fld_point point,
    fld_line line,
    date_range daterange
);