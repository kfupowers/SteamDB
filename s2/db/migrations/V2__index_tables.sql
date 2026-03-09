
CREATE TABLE steam.array_table (
    id SERIAL PRIMARY KEY,
    int_array_20 INT[20],
    int_array INT[],
    str_array_20 VARCHAR[20],
    str_array VARCHAR[],
    date_array date[]
);



CREATE TABLE steam.others_table (
    id SERIAL PRIMARY KEY,
    fld_point point,
    fld_line line,
    full_text tsvector,
    range_int int4range
);