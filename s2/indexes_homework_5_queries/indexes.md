EXPLAIN ANALYSE SELECT * FROM steam.games WHERE price = 100;

![img.png](img.png)

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM steam.games WHERE price = 100;

![img_1.png](img_1.png)


CREATE INDEX games_price_index ON steam.games (price);

EXPLAIN ANALYSE SELECT * FROM steam.games WHERE price = 100;

![img_2.png](img_2.png)

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM steam.games WHERE price = 100;

![img_3.png](img_3.png)

DROP INDEX steam.games_price_index;



CREATE INDEX games_price_index_hash ON steam.games USING hash (price);

EXPLAIN ANALYSE SELECT * FROM steam.games WHERE price = 100;

![img_4.png](img_4.png)

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM steam.games WHERE price = 100;

![img_5.png](img_5.png)

DROP INDEX steam.games_price_index_hash;



EXPLAIN ANALYSE SELECT * FROM steam.games WHERE price < 100;

![img_6.png](img_6.png)

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM steam.games WHERE price < 100;

![img_7.png](img_7.png)


CREATE INDEX games_price_index ON steam.games (price);

EXPLAIN ANALYSE SELECT * FROM steam.games WHERE price < 100;

![img_8.png](img_8.png)

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM steam.games WHERE price < 100;

![img_9.png](img_9.png)

DROP INDEX steam.games_price_index;



CREATE INDEX games_price_index_hash ON steam.games USING hash (price);

EXPLAIN ANALYSE SELECT * FROM steam.games WHERE price < 100;

![img_10.png](img_10.png)

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM steam.games WHERE price < 100;

![img_11.png](img_11.png)

DROP INDEX steam.games_price_index_hash;



EXPLAIN ANALYSE SELECT * FROM steam.games WHERE games.price IN (2, 3, 5);

![img_12.png](img_12.png)

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM steam.games WHERE games.price IN (2, 3, 5);

![img_13.png](img_13.png)


CREATE INDEX games_price_index ON steam.games (price);

EXPLAIN ANALYSE SELECT * FROM steam.games WHERE games.price IN (2, 3, 5);

![img_14.png](img_14.png)

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM steam.games WHERE games.price IN (2, 3, 5);

![img_15.png](img_15.png)

DROP INDEX steam.games_price_index;



CREATE INDEX games_price_index_hash ON steam.games USING hash (price);

EXPLAIN ANALYSE SELECT * FROM steam.games WHERE games.price IN (2, 3, 5);

![img_16.png](img_16.png)

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM steam.games WHERE games.price IN (2, 3, 5);

![img_17.png](img_17.png)

DROP INDEX steam.games_price_index_hash;



EXPLAIN ANALYSE SELECT * FROM steam.games WHERE games.price BETWEEN 3000 AND 4000;

![img_18.png](img_18.png)

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM steam.games WHERE games.price BETWEEN 3000 AND 4000;

![img_19.png](img_19.png)


CREATE INDEX games_price_index ON steam.games (price);

EXPLAIN ANALYSE SELECT * FROM steam.games WHERE games.price BETWEEN 3000 AND 4000;

![img_20.png](img_20.png)

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM steam.games WHERE games.price BETWEEN 3000 AND 4000;

![img_21.png](img_21.png)

DROP INDEX steam.games_price_index;



CREATE INDEX games_price_index_hash ON steam.games USING hash(price);

EXPLAIN ANALYSE SELECT * FROM steam.games WHERE games.price BETWEEN 3000 AND 4000;

![img_22.png](img_22.png)

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM steam.games WHERE games.price BETWEEN 3000 AND 4000;

![img_23.png](img_23.png)

DROP INDEX steam.games_price_index_hash;


EXPLAIN ANALYSE SELECT * FROM steam.reviews WHERE reviews.rating <> true;

![img_24.png](img_24.png)

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM steam.reviews WHERE reviews.rating <> true;

![img_25.png](img_25.png)


CREATE INDEX reviews_rating_index ON steam.reviews (rating);

EXPLAIN ANALYSE SELECT * FROM steam.reviews WHERE reviews.rating <> true;

![img_27.png](img_27.png)

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM steam.reviews WHERE reviews.rating <> true;

![img_26.png](img_26.png)

DROP INDEX steam.reviews_rating_index;



CREATE INDEX reviews_rating_index_hash ON steam.reviews USING hash(rating);

EXPLAIN ANALYSE SELECT * FROM steam.reviews WHERE reviews.rating <> true;

![img_28.png](img_28.png)

EXPLAIN (ANALYSE, BUFFERS)  SELECT * FROM steam.reviews WHERE reviews.rating <> true;

![img_29.png](img_29.png)

DROP INDEX steam.reviews_rating_index_hash;