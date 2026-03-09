--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5
-- Dumped by pg_dump version 17.5

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: steam; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA steam;


ALTER SCHEMA steam OWNER TO postgres;

--
-- Name: cleanup_account_data(); Type: FUNCTION; Schema: steam; Owner: postgres
--

CREATE FUNCTION steam.cleanup_account_data() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM steam.wishlists WHERE account_id = OLD.account_id;

    DELETE FROM steam.friends
    WHERE (account_id_1 = OLD.account_id) || (account_id_2 = OLD.account_id);

    RETURN OLD;
END;
$$;


ALTER FUNCTION steam.cleanup_account_data() OWNER TO postgres;

--
-- Name: delete_genre_from_games(); Type: FUNCTION; Schema: steam; Owner: postgres
--

CREATE FUNCTION steam.delete_genre_from_games() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE from steam.game_genre WHERE genre_id = old.genre_id;
    RETURN NULL;
END;
$$;


ALTER FUNCTION steam.delete_genre_from_games() OWNER TO postgres;

--
-- Name: game_developer_name(integer); Type: FUNCTION; Schema: steam; Owner: postgres
--

CREATE FUNCTION steam.game_developer_name(new_game_id integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
    new_developer_id INT;
BEGIN
    SELECT developer_id INTO new_developer_id
    FROM steam.games
    WHERE game_id = new_game_id;

    RETURN (SELECT name FROM steam.developers WHERE developer_id = new_developer_id);
END;
$$;


ALTER FUNCTION steam.game_developer_name(new_game_id integer) OWNER TO postgres;

--
-- Name: game_price_deviation(integer); Type: FUNCTION; Schema: steam; Owner: postgres
--

CREATE FUNCTION steam.game_price_deviation(new_game_id integer) RETURNS double precision
    LANGUAGE plpgsql
    AS $$
DECLARE
    avg_price INT;
BEGIN
    SELECT AVG(price) INTO avg_price FROM steam.games
    WHERE price > 0;
    RETURN (SELECT price - avg_price FROM steam.games WHERE game_id = new_game_id);
END;
$$;


ALTER FUNCTION steam.game_price_deviation(new_game_id integer) OWNER TO postgres;

--
-- Name: get_game_category(integer); Type: FUNCTION; Schema: steam; Owner: postgres
--

CREATE FUNCTION steam.get_game_category(new_game_id integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
    category VARCHAR(20);
    percent_of_reviews FLOAT;
BEGIN
    percent_of_reviews = steam.percent_reviews_by_game(new_game_id);
    category := CASE
        WHEN percent_of_reviews > 0.95 THEN 'Крайне положительные'
        WHEN percent_of_reviews BETWEEN 0.8 AND 0.94 THEN 'Очень положительные'
        WHEN percent_of_reviews BETWEEN 0.7 AND 0.79 THEN 'Положительные'
        WHEN percent_of_reviews BETWEEN 0.4 AND 0.69 THEN 'Смешанные'
        WHEN percent_of_reviews BETWEEN 0.2 AND 0.39 THEN 'Отрицательные'
        WHEN percent_of_reviews < 0.19 THEN 'Очень отрицательные'
    END;
    RETURN category;
END;
$$;


ALTER FUNCTION steam.get_game_category(new_game_id integer) OWNER TO postgres;

--
-- Name: get_user_by_id_with_rand(integer); Type: FUNCTION; Schema: steam; Owner: postgres
--

CREATE FUNCTION steam.get_user_by_id_with_rand(new_user_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    iterations INT;
    while_user_id INT;
BEGIN
    iterations := 0;
    while_user_id := 0;
    WHILE new_user_id <> while_user_id LOOP
        SELECT accounts.account_id INTO while_user_id FROM steam.accounts
        ORDER BY RANDOM() LIMIT 1;
        iterations := iterations + 1;
    end loop;
RETURN iterations;
END;
$$;


ALTER FUNCTION steam.get_user_by_id_with_rand(new_user_id integer) OWNER TO postgres;

--
-- Name: get_users_by_handshakes(integer, integer); Type: FUNCTION; Schema: steam; Owner: postgres
--

CREATE FUNCTION steam.get_users_by_handshakes(new_user_id integer, iterations integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    users INT[];
BEGIN
    users := ARRAY[new_user_id];

    WHILE iterations > 0 LOOP
        SELECT ARRAY(
            SELECT DISTINCT account_id_1
            FROM steam.friends
            WHERE account_id_1 = ANY(users) OR account_id_2 = ANY(users)
            UNION
            SELECT DISTINCT account_id_2
            FROM steam.friends
            WHERE account_id_1 = ANY(users) OR account_id_2 = ANY(users)
        ) INTO users;
        iterations := iterations - 1;
    END LOOP;

    RETURN (SELECT array_length(users, 1));
END;
$$;


ALTER FUNCTION steam.get_users_by_handshakes(new_user_id integer, iterations integer) OWNER TO postgres;

--
-- Name: insert_balance_log(); Type: FUNCTION; Schema: steam; Owner: postgres
--

CREATE FUNCTION steam.insert_balance_log() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF(NEW.wallet_balance <> OLD.wallet_balance)
    THEN INSERT INTO steam.balance_log(account_id, old_balance, new_balance, change_time)
         VALUES(NEW.account_id, OLD.wallet_balance, NEW.wallet_balance, now());
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION steam.insert_balance_log() OWNER TO postgres;

--
-- Name: insert_deleting_accounts(); Type: FUNCTION; Schema: steam; Owner: postgres
--

CREATE FUNCTION steam.insert_deleting_accounts() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF EXISTS(SELECT 1 FROM steam.deleting_account
       WHERE deleting_account.account_id = OLD.account_id)
       THEN IF EXISTS(SELECT 1 FROM steam.deleting_account
            WHERE CURRENT_DATE - deleting_account.request_date >= 30)
            THEN RETURN OLD;
            ELSE RAISE NOTICE 'Не прошло 30 дней';
            END IF;
    ELSE INSERT INTO steam.deleting_account(account_id, request_date) VALUES (OLD.account_id, current_date);
    END IF;
    RETURN NULL;
END;
$$;


ALTER FUNCTION steam.insert_deleting_accounts() OWNER TO postgres;

--
-- Name: insert_ownership_achievement(integer, integer); Type: PROCEDURE; Schema: steam; Owner: postgres
--

CREATE PROCEDURE steam.insert_ownership_achievement(IN new_ownership_id integer, IN new_achievement_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF (SELECT game_id
        FROM steam.account_game
        WHERE ownership_id = new_ownership_id)
        =  (SELECT game_id
        FROM steam.achievements
        WHERE achievements.achievement_id = new_achievement_id)
        THEN INSERT INTO steam.ownership_achievement(ownership_id, achievement_id)
        VALUES (new_ownership_id, new_achievement_id);
    ELSE
        RAISE NOTICE 'Разные id у игр';
    END IF;
END;
$$;


ALTER PROCEDURE steam.insert_ownership_achievement(IN new_ownership_id integer, IN new_achievement_id integer) OWNER TO postgres;

--
-- Name: insert_query_history(); Type: FUNCTION; Schema: steam; Owner: postgres
--

CREATE FUNCTION steam.insert_query_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO steam.query_history(account_name, query_time, operation)
     VALUES (current_user, NOW(), tg_op);
    RETURN NULL;
END;
$$;


ALTER FUNCTION steam.insert_query_history() OWNER TO postgres;

--
-- Name: is_in_wishlist(integer, integer); Type: FUNCTION; Schema: steam; Owner: postgres
--

CREATE FUNCTION steam.is_in_wishlist(new_game_id integer, new_user_id integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN EXISTS (SELECT 1 FROM steam.wishlists
    WHERE account_id = new_user_id AND game_id = new_game_id);
END;
$$;


ALTER FUNCTION steam.is_in_wishlist(new_game_id integer, new_user_id integer) OWNER TO postgres;

--
-- Name: ownership_game_achievement_game(); Type: FUNCTION; Schema: steam; Owner: postgres
--

CREATE FUNCTION steam.ownership_game_achievement_game() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF (SELECT game_id
        FROM steam.account_game
        WHERE ownership_id = NEW.ownership_id)
        =  (SELECT game_id
        FROM steam.achievements
        WHERE achievements.achievement_id = NEW.achievement_id)
        THEN RETURN NEW;
    ELSE
        RAISE EXCEPTION 'Разные id игр';
    END IF;
END;
$$;


ALTER FUNCTION steam.ownership_game_achievement_game() OWNER TO postgres;

--
-- Name: percent_reviews_by_game(integer); Type: FUNCTION; Schema: steam; Owner: postgres
--

CREATE FUNCTION steam.percent_reviews_by_game(new_game_id integer) RETURNS double precision
    LANGUAGE plpgsql
    AS $$
DECLARE
    review_count INT;
    positive_review_count INT;
    result FLOAT;
BEGIN
    SELECT
        COUNT(*),
        SUM(CASE WHEN steam.reviews.rating THEN 1 ELSE 0 END)
    INTO review_count, positive_review_count
    FROM steam.reviews
    WHERE game_id = new_game_id;

    BEGIN
        result := positive_review_count * 1.0 / review_count;
        RETURN result;
    EXCEPTION
        WHEN division_by_zero THEN
            RAISE EXCEPTION 'Нет отзывов';
    END;
END;
$$;


ALTER FUNCTION steam.percent_reviews_by_game(new_game_id integer) OWNER TO postgres;

--
-- Name: percent_reviews_by_user(integer); Type: FUNCTION; Schema: steam; Owner: postgres
--

CREATE FUNCTION steam.percent_reviews_by_user(new_user_id integer) RETURNS double precision
    LANGUAGE plpgsql
    AS $$
DECLARE
    review_count INT;
    positive_review_count INT;
    negative_review_count INT;
BEGIN
    SELECT
        SUM(CASE WHEN steam.reviews.rating THEN 1 ELSE 0 END),
        SUM(CASE WHEN NOT steam.reviews.rating THEN 1 ELSE 0 END),
        COUNT(*)
    INTO positive_review_count, negative_review_count, review_count
    FROM steam.reviews
    WHERE account_id = new_user_id;

    

    RETURN positive_review_count * 1.0 / review_count;
END;
$$;


ALTER FUNCTION steam.percent_reviews_by_user(new_user_id integer) OWNER TO postgres;

--
-- Name: positive_wallet_balance(); Type: FUNCTION; Schema: steam; Owner: postgres
--

CREATE FUNCTION steam.positive_wallet_balance() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF(NEW.wallet_balance < 0)
    THEN RAISE EXCEPTION 'Amount cannot be negative';
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION steam.positive_wallet_balance() OWNER TO postgres;

--
-- Name: set_password_updated_at(); Type: FUNCTION; Schema: steam; Owner: postgres
--

CREATE FUNCTION steam.set_password_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF(OLD.password <> NEW.password) THEN NEW.password_updated_at = NOW();
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION steam.set_password_updated_at() OWNER TO postgres;

--
-- Name: sum_reviews_by_user(integer); Type: FUNCTION; Schema: steam; Owner: postgres
--

CREATE FUNCTION steam.sum_reviews_by_user(new_user_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT SUM(1) FROM steam.reviews
    WHERE account_id = new_user_id);
END;
$$;


ALTER FUNCTION steam.sum_reviews_by_user(new_user_id integer) OWNER TO postgres;

--
-- Name: sum_spent_on_games_by_user(integer); Type: FUNCTION; Schema: steam; Owner: postgres
--

CREATE FUNCTION steam.sum_spent_on_games_by_user(new_user_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (SELECT SUM(price) FROM steam.account_game
    JOIN steam.games g on g.game_id = account_game.game_id
    WHERE account_id = new_user_id);
END;
$$;


ALTER FUNCTION steam.sum_spent_on_games_by_user(new_user_id integer) OWNER TO postgres;

--
-- Name: update_game_price(integer, integer); Type: PROCEDURE; Schema: steam; Owner: postgres
--

CREATE PROCEDURE steam.update_game_price(IN game_id integer, IN new_price integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE steam.games
    SET price = new_price
    WHERE games.game_id = update_game_price.game_id;
END;
$$;


ALTER PROCEDURE steam.update_game_price(IN game_id integer, IN new_price integer) OWNER TO postgres;

--
-- Name: update_review_timestamp(); Type: FUNCTION; Schema: steam; Owner: postgres
--

CREATE FUNCTION steam.update_review_timestamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF (OLD.rating <> NEW.rating) || (OLD.comment <> NEW.comment) THEN
        NEW.review_date = CURRENT_DATE;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION steam.update_review_timestamp() OWNER TO postgres;

--
-- Name: upsert_game_stats(); Type: PROCEDURE; Schema: steam; Owner: postgres
--

CREATE PROCEDURE steam.upsert_game_stats()
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE steam.game_stats SET copies_bought = a.copies_bought, sum_price = a.sum_price
    FROM  (SELECT games.game_id, COUNT(*) as copies_bought, COUNT(*) * price as sum_price FROM steam.games
    JOIN steam.account_game ag on games.game_id = ag.game_id
    WHERE games.game_id IN(SELECT game_stats.game_id FROM steam.game_stats)
    GROUP BY games.game_id) as a
    WHERE a.game_id = game_stats.game_id;

    INSERT INTO steam.game_stats(game_id, copies_bought, sum_price)
    SELECT games.game_id, COUNT(*) as copies_bought, COUNT(*) * price as sum_price FROM steam.games
    JOIN steam.account_game ag on games.game_id = ag.game_id
    WHERE games.game_id NOT IN(SELECT game_stats.game_id FROM steam.game_stats)
    GROUP BY games.game_id;
END;
$$;


ALTER PROCEDURE steam.upsert_game_stats() OWNER TO postgres;

--
-- Name: upsert_review(integer, integer, boolean, character varying, date); Type: PROCEDURE; Schema: steam; Owner: postgres
--

CREATE PROCEDURE steam.upsert_review(IN new_game_id integer, IN new_account_id integer, IN new_rating boolean, IN new_comment character varying, IN new_review_date date)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO steam.reviews (
        game_id,
        account_id,
        rating,
        comment,
        review_date
    )
    VALUES (
        new_game_id,
        new_account_id,
        new_rating,
        new_comment,
        new_review_date
    );

EXCEPTION
    WHEN unique_violation THEN
        UPDATE steam.reviews
        SET
            rating = new_rating,
            comment = new_comment,
            review_date = new_review_date
        WHERE
            game_id = new_game_id
            AND account_id = new_account_id;
END;
$$;


ALTER PROCEDURE steam.upsert_review(IN new_game_id integer, IN new_account_id integer, IN new_rating boolean, IN new_comment character varying, IN new_review_date date) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: account_game; Type: TABLE; Schema: steam; Owner: postgres
--

CREATE TABLE steam.account_game (
    ownership_id integer NOT NULL,
    account_id integer NOT NULL,
    game_id integer NOT NULL
);


ALTER TABLE steam.account_game OWNER TO postgres;

--
-- Name: account_game_ownership_id_seq; Type: SEQUENCE; Schema: steam; Owner: postgres
--

CREATE SEQUENCE steam.account_game_ownership_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE steam.account_game_ownership_id_seq OWNER TO postgres;

--
-- Name: account_game_ownership_id_seq; Type: SEQUENCE OWNED BY; Schema: steam; Owner: postgres
--

ALTER SEQUENCE steam.account_game_ownership_id_seq OWNED BY steam.account_game.ownership_id;


--
-- Name: account_work; Type: TABLE; Schema: steam; Owner: postgres
--

CREATE TABLE steam.account_work (
    work_id integer NOT NULL,
    ownership_id integer NOT NULL
);


ALTER TABLE steam.account_work OWNER TO postgres;

--
-- Name: accounts; Type: TABLE; Schema: steam; Owner: postgres
--

CREATE TABLE steam.accounts (
    account_id integer NOT NULL,
    username character varying(200) NOT NULL,
    email character varying(50) NOT NULL,
    password character varying(50) NOT NULL,
    wallet_balance integer NOT NULL,
    password_updated_at timestamp without time zone,
    CONSTRAINT wallet_balance_ch CHECK ((wallet_balance >= 0))
);


ALTER TABLE steam.accounts OWNER TO postgres;

--
-- Name: accounts_account_id_seq; Type: SEQUENCE; Schema: steam; Owner: postgres
--

CREATE SEQUENCE steam.accounts_account_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE steam.accounts_account_id_seq OWNER TO postgres;

--
-- Name: accounts_account_id_seq; Type: SEQUENCE OWNED BY; Schema: steam; Owner: postgres
--

ALTER SEQUENCE steam.accounts_account_id_seq OWNED BY steam.accounts.account_id;


--
-- Name: achievements; Type: TABLE; Schema: steam; Owner: postgres
--

CREATE TABLE steam.achievements (
    achievement_id integer NOT NULL,
    game_id integer NOT NULL,
    name character varying(200) NOT NULL,
    description character varying(1000) NOT NULL
);


ALTER TABLE steam.achievements OWNER TO postgres;

--
-- Name: achievements_achievement_id_seq; Type: SEQUENCE; Schema: steam; Owner: postgres
--

CREATE SEQUENCE steam.achievements_achievement_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE steam.achievements_achievement_id_seq OWNER TO postgres;

--
-- Name: achievements_achievement_id_seq; Type: SEQUENCE OWNED BY; Schema: steam; Owner: postgres
--

ALTER SEQUENCE steam.achievements_achievement_id_seq OWNED BY steam.achievements.achievement_id;


--
-- Name: balance_log; Type: TABLE; Schema: steam; Owner: postgres
--

CREATE TABLE steam.balance_log (
    account_id integer,
    old_balance integer,
    new_balance integer,
    change_time timestamp without time zone
);


ALTER TABLE steam.balance_log OWNER TO postgres;

--
-- Name: deleting_account; Type: TABLE; Schema: steam; Owner: postgres
--

CREATE TABLE steam.deleting_account (
    account_id integer,
    request_date date
);


ALTER TABLE steam.deleting_account OWNER TO postgres;

--
-- Name: developers; Type: TABLE; Schema: steam; Owner: postgres
--

CREATE TABLE steam.developers (
    developer_id integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE steam.developers OWNER TO postgres;

--
-- Name: developers_developer_id_seq; Type: SEQUENCE; Schema: steam; Owner: postgres
--

CREATE SEQUENCE steam.developers_developer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE steam.developers_developer_id_seq OWNER TO postgres;

--
-- Name: developers_developer_id_seq; Type: SEQUENCE OWNED BY; Schema: steam; Owner: postgres
--

ALTER SEQUENCE steam.developers_developer_id_seq OWNED BY steam.developers.developer_id;


--
-- Name: friends; Type: TABLE; Schema: steam; Owner: postgres
--

CREATE TABLE steam.friends (
    account_id_1 integer NOT NULL,
    account_id_2 integer NOT NULL,
    CONSTRAINT friends_ch CHECK ((account_id_2 > account_id_1))
);


ALTER TABLE steam.friends OWNER TO postgres;

--
-- Name: game_gamemode; Type: TABLE; Schema: steam; Owner: postgres
--

CREATE TABLE steam.game_gamemode (
    game_id integer NOT NULL,
    gamemode_id integer NOT NULL
);


ALTER TABLE steam.game_gamemode OWNER TO postgres;

--
-- Name: game_genre; Type: TABLE; Schema: steam; Owner: postgres
--

CREATE TABLE steam.game_genre (
    game_id integer NOT NULL,
    genre_id integer NOT NULL
);


ALTER TABLE steam.game_genre OWNER TO postgres;

--
-- Name: game_stats; Type: TABLE; Schema: steam; Owner: postgres
--

CREATE TABLE steam.game_stats (
    game_id integer NOT NULL,
    copies_bought integer,
    sum_price integer
);


ALTER TABLE steam.game_stats OWNER TO postgres;

--
-- Name: gamemodes; Type: TABLE; Schema: steam; Owner: postgres
--

CREATE TABLE steam.gamemodes (
    mode_id integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE steam.gamemodes OWNER TO postgres;

--
-- Name: gamemodes_mode_id_seq; Type: SEQUENCE; Schema: steam; Owner: postgres
--

CREATE SEQUENCE steam.gamemodes_mode_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE steam.gamemodes_mode_id_seq OWNER TO postgres;

--
-- Name: gamemodes_mode_id_seq; Type: SEQUENCE OWNED BY; Schema: steam; Owner: postgres
--

ALTER SEQUENCE steam.gamemodes_mode_id_seq OWNED BY steam.gamemodes.mode_id;


--
-- Name: games; Type: TABLE; Schema: steam; Owner: postgres
--

CREATE TABLE steam.games (
    game_id integer NOT NULL,
    developer_id integer NOT NULL,
    title character varying(200) NOT NULL,
    description character varying(1000) NOT NULL,
    release_date date,
    price integer NOT NULL,
    CONSTRAINT price_ch CHECK ((price >= 0))
);


ALTER TABLE steam.games OWNER TO postgres;

--
-- Name: games_game_id_seq; Type: SEQUENCE; Schema: steam; Owner: postgres
--

CREATE SEQUENCE steam.games_game_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE steam.games_game_id_seq OWNER TO postgres;

--
-- Name: games_game_id_seq; Type: SEQUENCE OWNED BY; Schema: steam; Owner: postgres
--

ALTER SEQUENCE steam.games_game_id_seq OWNED BY steam.games.game_id;


--
-- Name: genres; Type: TABLE; Schema: steam; Owner: postgres
--

CREATE TABLE steam.genres (
    genre_id integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE steam.genres OWNER TO postgres;

--
-- Name: genres_genre_id_seq; Type: SEQUENCE; Schema: steam; Owner: postgres
--

CREATE SEQUENCE steam.genres_genre_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE steam.genres_genre_id_seq OWNER TO postgres;

--
-- Name: genres_genre_id_seq; Type: SEQUENCE OWNED BY; Schema: steam; Owner: postgres
--

ALTER SEQUENCE steam.genres_genre_id_seq OWNED BY steam.genres.genre_id;


--
-- Name: ownership_achievement; Type: TABLE; Schema: steam; Owner: postgres
--

CREATE TABLE steam.ownership_achievement (
    ownership_id integer NOT NULL,
    achievement_id integer NOT NULL
);


ALTER TABLE steam.ownership_achievement OWNER TO postgres;

--
-- Name: query_history; Type: TABLE; Schema: steam; Owner: postgres
--

CREATE TABLE steam.query_history (
    account_name character varying(255),
    query_time timestamp without time zone,
    operation character varying(15)
);


ALTER TABLE steam.query_history OWNER TO postgres;

--
-- Name: reviews; Type: TABLE; Schema: steam; Owner: postgres
--

CREATE TABLE steam.reviews (
    game_id integer NOT NULL,
    account_id integer NOT NULL,
    rating boolean NOT NULL,
    comment character varying(5000) NOT NULL,
    review_date date NOT NULL
);


ALTER TABLE steam.reviews OWNER TO postgres;

--
-- Name: wishlists; Type: TABLE; Schema: steam; Owner: postgres
--

CREATE TABLE steam.wishlists (
    account_id integer NOT NULL,
    game_id integer NOT NULL,
    added_date date NOT NULL
);


ALTER TABLE steam.wishlists OWNER TO postgres;

--
-- Name: workshop; Type: TABLE; Schema: steam; Owner: postgres
--

CREATE TABLE steam.workshop (
    work_id integer NOT NULL,
    ownership_id integer NOT NULL,
    work_name character varying(200) NOT NULL,
    description character varying(5000) NOT NULL,
    upload_date date NOT NULL
);


ALTER TABLE steam.workshop OWNER TO postgres;

--
-- Name: workshop_work_id_seq; Type: SEQUENCE; Schema: steam; Owner: postgres
--

CREATE SEQUENCE steam.workshop_work_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE steam.workshop_work_id_seq OWNER TO postgres;

--
-- Name: workshop_work_id_seq; Type: SEQUENCE OWNED BY; Schema: steam; Owner: postgres
--

ALTER SEQUENCE steam.workshop_work_id_seq OWNED BY steam.workshop.work_id;


--
-- Name: account_game ownership_id; Type: DEFAULT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.account_game ALTER COLUMN ownership_id SET DEFAULT nextval('steam.account_game_ownership_id_seq'::regclass);


--
-- Name: accounts account_id; Type: DEFAULT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.accounts ALTER COLUMN account_id SET DEFAULT nextval('steam.accounts_account_id_seq'::regclass);


--
-- Name: achievements achievement_id; Type: DEFAULT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.achievements ALTER COLUMN achievement_id SET DEFAULT nextval('steam.achievements_achievement_id_seq'::regclass);


--
-- Name: developers developer_id; Type: DEFAULT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.developers ALTER COLUMN developer_id SET DEFAULT nextval('steam.developers_developer_id_seq'::regclass);


--
-- Name: gamemodes mode_id; Type: DEFAULT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.gamemodes ALTER COLUMN mode_id SET DEFAULT nextval('steam.gamemodes_mode_id_seq'::regclass);


--
-- Name: games game_id; Type: DEFAULT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.games ALTER COLUMN game_id SET DEFAULT nextval('steam.games_game_id_seq'::regclass);


--
-- Name: genres genre_id; Type: DEFAULT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.genres ALTER COLUMN genre_id SET DEFAULT nextval('steam.genres_genre_id_seq'::regclass);


--
-- Name: workshop work_id; Type: DEFAULT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.workshop ALTER COLUMN work_id SET DEFAULT nextval('steam.workshop_work_id_seq'::regclass);


--
-- Data for Name: account_game; Type: TABLE DATA; Schema: steam; Owner: postgres
--

COPY steam.account_game (ownership_id, account_id, game_id) FROM stdin;
2	1	2
3	2	1
4	2	3
5	3	1
6	3	4
7	4	1
8	4	5
9	5	1
10	5	2
11	5	3
12	6	6
13	6	7
14	6	8
15	6	9
16	6	10
17	7	7
18	7	8
19	7	9
20	7	10
22	7	11
23	8	8
24	8	9
25	8	10
26	8	11
27	8	12
28	9	3
29	9	5
30	9	7
31	9	9
32	9	11
33	10	3
34	10	4
35	10	5
36	10	6
37	10	7
38	10	8
39	10	9
40	10	10
41	10	11
42	10	12
1	1	1
63	8	5
\.


--
-- Data for Name: account_work; Type: TABLE DATA; Schema: steam; Owner: postgres
--

COPY steam.account_work (work_id, ownership_id) FROM stdin;
1	2
1	10
2	4
\.


--
-- Data for Name: accounts; Type: TABLE DATA; Schema: steam; Owner: postgres
--

COPY steam.accounts (account_id, username, email, password, wallet_balance, password_updated_at) FROM stdin;
3	lystic	lystic@gmail.com	YAXzKhpUcsTT	230	\N
4	obikym	obikym@gmail.com	TdbPSZbBZJhW	2000	\N
5	sharyk	sharyk@gmail.com	NP6qZ2wWnnCE	30000	\N
6	HasuObs	hasuObs@gmail.com	1qEVrDZrli	5000	\N
7	Nurok	nurok@gmail.com	zmNdv2JKoj	870	\N
9	SportBilly	sportBilly@gmail.com	GjzN1R2v6J	2025	\N
10	Arcaner	arcaner@gmail.com	WJmFiVxxQy	99999999	\N
11	newuser	newuser@gmail.com	qweasdzxc	1000	\N
2	Hoot	hoot@gmail.com	GmFwTvgzmdeT	171	\N
1	Dimov	dimov@gmail.com	qwerty2	0	2025-12-02 21:49:23.306706
8	ethernal	ethernal@gmail.com	gRr0aoeqy6	931	\N
\.


--
-- Data for Name: achievements; Type: TABLE DATA; Schema: steam; Owner: postgres
--

COPY steam.achievements (achievement_id, game_id, name, description) FROM stdin;
1	2	Утешительный приз	Умрите от удара в спину 50 раз
2	2	Нас мало, но мы в килтах	Нанесите 1 миллион урона от взрывов
3	2	Агент-провокатор	Убейте ваших друзей из Steam ударом в спину 10 раз
4	2	Аптечный ковбой	За все время вылечите 100 000 единиц здоровья при помощи раздатчика
5	3	Разящее жало	Одолеть майора Разящее Жало
6	3	Жирдяй проглот	Одолеть жирдяя проглота
7	3	Глаз д-ра Плата	Отобрать глаз у доктора Плата
8	3	Убить всех	Перебить всех врагов на уровне одной кампании
9	4	1UP!	Получить 1UP
10	4	Спасибо, что играли	Завершить все "Стороны B"
11	4	Wow	Find the moon berry
12	4	Farewell	Complete Chapter 9
13	5	Medium well	Spend as little time as possible in Hell
14	5	Medium	Spend as little time as possible in The Salt Factory
15	5	Medium Rare	Spend as little time as possible in The Hospital
16	5	Rare	Spend as little time as possible in The Forest
17	6	Миссия невыполним	Пройти весь сюжет менее чем за 4 часа
18	6	Шерлок Холмс	Найти все игровые тайники
19	6	Плохой вкус	Порубить в капусту 1000 врагов
20	6	Это магика	Спихнуть солдата в яму
21	7	Ending?(Hard)	Beat the Rift on Hard
22	7	Infernal Engine(Hard)	Kill the Rust Fiend on Hard
23	7	The Cycle Continues(Hard)	Beat the game without all rune orbs on Hard
24	7	Conclusion(Hard)	Beat the game with all rune orbs on Hard
25	8	Stairway to Hell	Kill 5 enemies while climbing a ladder
26	8	Rock'n'Roll	Kill 5 enemies with rocks
27	8	Eagle Eye	Land 10 headshots on enemies with projectiles in a single game
28	8	Unstoppable	Kill 10 enemies in a row without dying
29	9	Тайный покупатель	Добраться до черного рынка в обычном забеге
30	9	Звезда забега	Пройти обучающий забег быстрее 30 секунд
31	9	Пилигрим	Добраться до затонувшего города в обычном забеге одиночного режима
32	9	Поддержим местных производителей!	Скупить лавку питомцев Яна в обычном забеге
33	10	Tag champion	Become the reining tag champion
34	10	Epitaph I	Clear Trial I.
35	10	Impossible riches	Finished a run with a score of 200,000.
36	10	Overflow	Reach Nowhere
37	11	Forsaken Tower NG+++	Beat the Forsaken Tower in NG+++
38	11	Good Fortune	Spend 5000 gold on positive favor
39	11	Attunement	Attune 10 items at the magic anvil
40	11	Friends for life	Acquire a companion
41	12	Ой-ой-ой...	Заставьте Билли Бума взорваться
42	12	Роборегулятор(Серебро)	Устраните 5000 врагов
43	12	Патронташ	Дсотигните бонуса патронов 75%
44	12	Бич боссов(Серебро)	Уничтожьте 10 босоов
\.


--
-- Data for Name: balance_log; Type: TABLE DATA; Schema: steam; Owner: postgres
--

COPY steam.balance_log (account_id, old_balance, new_balance, change_time) FROM stdin;
2	170	171	2025-12-02 19:58:58.488552
8	1230	931	2025-12-11 19:51:56.844732
\.


--
-- Data for Name: deleting_account; Type: TABLE DATA; Schema: steam; Owner: postgres
--

COPY steam.deleting_account (account_id, request_date) FROM stdin;
\.


--
-- Data for Name: developers; Type: TABLE DATA; Schema: steam; Owner: postgres
--

COPY steam.developers (developer_id, name) FROM stdin;
1	Valve
2	Team Meat
3	Maddy Makes Games Inc.
4	Crackshell
5	Arrowhead Game Studios
6	Nuke Nine
7	Triternion
8	Mossmouth
9	Team D-13
10	RyseUp Studios
\.


--
-- Data for Name: friends; Type: TABLE DATA; Schema: steam; Owner: postgres
--

COPY steam.friends (account_id_1, account_id_2) FROM stdin;
1	2
1	3
1	4
1	5
2	3
\.


--
-- Data for Name: game_gamemode; Type: TABLE DATA; Schema: steam; Owner: postgres
--

COPY steam.game_gamemode (game_id, gamemode_id) FROM stdin;
1	2
1	3
2	2
2	3
3	1
3	2
3	4
4	1
5	1
6	1
6	2
6	4
7	1
7	2
7	4
8	2
8	3
8	4
9	1
9	2
9	4
10	1
11	1
11	2
11	4
12	1
12	2
12	4
\.


--
-- Data for Name: game_genre; Type: TABLE DATA; Schema: steam; Owner: postgres
--

COPY steam.game_genre (game_id, genre_id) FROM stdin;
1	4
1	5
1	6
1	8
2	5
2	6
2	7
3	1
3	2
3	9
3	10
4	2
4	3
4	10
5	2
5	3
5	10
3	16
4	16
5	16
6	1
6	2
6	14
7	1
7	2
7	3
7	10
7	12
7	16
8	1
8	15
9	1
9	2
9	10
9	12
10	1
10	2
10	6
10	9
10	10
10	12
10	13
10	16
11	1
11	2
11	10
11	11
11	12
11	13
11	14
11	16
12	1
12	2
12	6
12	7
12	12
12	13
9	3
1	17
\.


--
-- Data for Name: game_stats; Type: TABLE DATA; Schema: steam; Owner: postgres
--

COPY steam.game_stats (game_id, copies_bought, sum_price) FROM stdin;
12	2	2038
3	4	1540
11	4	1836
8	4	4400
10	4	2516
9	5	2175
7	4	1396
1	6	0
5	3	897
4	2	1420
2	2	0
6	2	1118
\.


--
-- Data for Name: gamemodes; Type: TABLE DATA; Schema: steam; Owner: postgres
--

COPY steam.gamemodes (mode_id, name) FROM stdin;
1	Для одного игрока
2	Для нескольких игроков
3	Игрок против игрока
4	Кооператив
\.


--
-- Data for Name: games; Type: TABLE DATA; Schema: steam; Owner: postgres
--

COPY steam.games (game_id, developer_id, title, description, release_date, price) FROM stdin;
1	1	Deadlock	Deadlock — многопользовательская игра на ранней стадии разработки	\N	0
2	1	Team Fortress 2	Девять классов с уникальными характерами откроют вам доступ ко множеству разнообразных тактик и навыков. Игра беспрестанно пополняется новыми режимами, картами, предметами и, самое главное, шляпами!	2007-10-10	0
3	4	Serious Sam's Bogus Detour	Serious Sam’s Bogus Detour — это абсолютно новая убойная глава в легендарной саге Serious Sam от создателей игры "Hammerwatch", компании Crackshell.	2017-06-20	385
4	3	Celeste	В платформере от создателей TowerFall Мэдлин сражается со своими демонами на пути к вершине горы Селеста. Преодолевай сотни хорошо продуманных сложностей, отыскивай тайники и постигай загадку горы.	2018-01-25	710
5	2	Super Meat Boy	The infamous, tough-as-nails platformer comes to Steam with a playable Head Crab character (Steam-exclusive)!	2010-12-01	299
6	5	Magicka	Комплект для четверых уже доступен!	2011-01-25	559
7	6	Vagante	Vagante is an action-packed platformer that features permanent death and procedurally generated levels. Play cooperatively with friends both locally and online, or adventure solo in this challenging roguelike-inspired game.	2018-02-22	349
8	7	MORDHAU	MORDHAU — многопользовательский средневековый слэшер. Создайте наемника и участвуйте в жестоких сражениях, где вас ждут напряженные бои, осады замков, кавалерийские атаки и многое другое.	2019-04-29	1100
9	8	Spelunky 2	Spelunky 2 builds upon the unique, randomized challenges that made the original a roguelike classic, offering a huge adventure designed to satisfy players old and new. Meet the next generation of explorers as they find themselves on the Moon, searching for treasure and missing family.	2020-09-29	435
10	9	Star of Providence	Star of Providence is a top down action shooter with procedurally generated elements. Explore a large, abandoned facility in search of incredible power, fighting dangerous foes and gaining new weapons and upgrades as you progress.	2017-06-07	629
11	4	Heroes of Hammerwatch	Heroes of Hammerwatch is a rogue-lite action-adventure. Explore and battle your way through procedurally generated levels on your own or with up to 3 friends. 	2018-03-01	459
12	10	Roboquest	Roboquest - быстрый Шутер-Роуглайт в выжженном мире будущего. Вы - перезагруженный Хранитель, готовый надрать металлические задницы! Сражайтесь бок о бок с другом или в одиночку, и уничтожайте орды смертоносных ботов в постоянно меняющихся локациях.	2023-11-07	1019
26	1	1	1	2000-11-11	1000
\.


--
-- Data for Name: genres; Type: TABLE DATA; Schema: steam; Owner: postgres
--

COPY steam.genres (genre_id, name) FROM stdin;
1	Экшен
2	Инди
3	Платформер
4	MOBA
5	Геройский шутер
6	Шутер
7	От первого лица
8	От третьего лица
9	Шутер с видом сверху
10	2D
11	RPG
12	Рогалик
13	Пулевой ад
14	Фэнтэзи
15	Сражения на мечах
16	Пиксельная графика
17	test
\.


--
-- Data for Name: ownership_achievement; Type: TABLE DATA; Schema: steam; Owner: postgres
--

COPY steam.ownership_achievement (ownership_id, achievement_id) FROM stdin;
2	1
2	2
2	3
2	4
4	5
4	6
4	7
4	8
6	9
6	10
6	11
6	12
8	13
8	14
8	15
8	16
10	1
10	2
11	6
11	7
12	17
13	21
13	22
13	23
14	25
19	29
19	30
19	31
19	32
20	33
20	34
20	35
20	36
28	5
29	13
30	23
31	29
32	38
33	5
33	6
33	7
33	8
34	9
34	10
34	11
34	12
35	13
35	14
35	15
35	16
36	17
36	18
36	19
36	20
37	21
37	22
37	23
37	24
38	25
38	26
38	27
38	28
39	29
39	30
39	31
39	32
40	33
40	34
40	35
40	36
41	37
41	38
41	39
41	40
42	41
42	42
42	43
42	44
\.


--
-- Data for Name: query_history; Type: TABLE DATA; Schema: steam; Owner: postgres
--

COPY steam.query_history (account_name, query_time, operation) FROM stdin;
postgres	2025-12-02 13:04:04.633038	UPDATE
postgres	2025-12-02 13:39:37.192594	INSERT
postgres	2025-12-02 13:43:16.460308	DELETE
postgres	2025-12-02 13:47:25.954395	DELETE
postgres	2025-12-02 19:58:41.511448	UPDATE
postgres	2025-12-02 19:58:58.488552	UPDATE
postgres	2025-12-02 21:49:23.306706	UPDATE
postgres	2025-12-11 19:51:56.844732	UPDATE
postgres	2025-12-16 10:26:38.725724	DELETE
\.


--
-- Data for Name: reviews; Type: TABLE DATA; Schema: steam; Owner: postgres
--

COPY steam.reviews (game_id, account_id, rating, comment, review_date) FROM stdin;
2	1	t	Наилучшей шутер.	2025-06-27
3	2	t	Скажу не кривя душой, что на данный момент это лучшая инди-игра/спинофф во вселенной Serious Sam, которая по некоторым параметрам может дать серьёзную фору даже большим официальным играм от Croteam.	2017-06-20
4	3	t	Очень спокойная и расслабляющая игра… до тех пор пока ты не перейдешь дальше главного меню	2025-09-03
5	4	t	Понимание таймингов и некое умение нажимать на кнопочки в процессе игры были лишь порогом вхождения для 9 главы. Игра обязательна на 100% достижений	2025-09-07
4	5	f	Даже не смотря на то, что игра большей частью мне нравится, хочется всё-таки задать дискурс о слишком уж одуревшей сложности, при том, что играл я, всего лишь на normal(e).	2025-04-07
6	6	t	Уникальная в своем роде игра, с уникальным гамеплау, юмором да практически всем. Да короткая, но игра стоит прохождения, особенно в компании друзей. (пожалуйста не пишите плохие отзывы. Если игра вылетает, появляются баги ТО СКАЧАЙТЕ ФИКС С ГИТХАБА, ЕГО ЛЕГКО НАЙТИ).	2025-11-05
6	10	t	Игра, где ты волшебник с дипломом идиота.\r\nТы можешь создать бурю, молнию, лаву — и случайно поджечь себя, друзей и ближайший лес.\r\nНи одна другая игра так тонко не передаёт ощущение “я всё контролирую!” за секунду до того, как взорвёшься.\r\nЛучшее — дружеский френдли-файр. Когда твой товарищ орёт “не кастуй молнию!”, ты уже вжимаешь клавиши и наблюдаешь фейерверк из фей и боли.\r\n⭐ 10/10 — “Ups, that was not healing spell.”	2025-10-20
7	10	t	Ochen interesno, no slozno, no poetomy I horosho	2025-10-28
11	10	t	Heroes of Hammerwatch was exactly the type of game I was looking for. Imagine all the best aspects of Diablo and Gauntlet tied together in a neat, diverse package. Lots of characters, lots of places to explore, no fighting over items, no inventory clutter and no pausing the action to manage your equipment (as every piece you pick up directly improves your character's stats).\r\nYou can play in short bursts or go on long quests, which is perfectly adapted for my schedule.\r\nIt's worth noting that the prequel did not have the same appeal, despite its similarity. It had all the Gauntlet elements, but none of the long-term progression, so each playthrough felt meaningless. Now you manage a town and can buy permanent upgrades. It sounds dumb, but just an added layer of economy can turn a game that rots in my library to something I play regularly.\r\nEven the music is great. I hum the town theme when I do the dishes.\r\nI'm 50 hours in and I still have so much left to explore. 10/10, highly recommended. I can't think how it could improve other than adding more characters and areas. Maybe in a future DLC? 	2021-05-07
12	10	t	Наверное лучшее, что можно найти на рынке среди шутеров-рогаликов. Довольно драйвовая, кайфовая и очень эпичная пострелушка с огромной вариативностью в прокачке, и это ещё если будете играть на разных классах. Огромный выбор оружия с разными модификаторами, которые их к тому же меняют в плане стрельбы. Напоминает чем-то дум, несколько далек от совершенства, но за свою стоимость очень годный проект.\r\nИз минусов отмечу, что в игре очень медленная и душная прокачка, нужно постоянно лазить в гайды, смотреть что к чему, где найти ключ, какие-то условия ещё нужно соблюдать, чтобы этот ключ подобрать и только потом в следующем забеге его реализовать. На все это придется потратить время, если хотите раскрыть весь потенциал этой игры. Без гаджетов, кристаллов и дополнительного снаряжения вам вряд ли удатся пробиться к финальному боссу, не то, чтобы его победить...\r\nВ целом рекомендую к покупке, особенно если у вас есть с кем играть, ибо кооп тут тоже присутствует, зовите своего бробота и ломайте лица всем, кого видите!	2025-10-12
8	9	t	Мертвый онлайн и много трайхардеров, но игра дарит отличные эмоции	2025-10-08
8	10	f	Лучший симулятор фехтования почти без притока новых, задроты не дают адекватно поиграть, а на сервера где есть люди там по 69% это задроты - мне не нужны 40 смертей и 698 голды заместо хорошего настроения. особо обозлённые могут сказать что я просто плачу, может и да, но я, да и мои друзья поиграть нормально не смогли потому что нам что не битва то срубали головушки, так что проблема задротов тут насущна. либо вы станете таким же задротом с усравшимися рефлексами или просто перестанете в это играть. да, кастомизация и реализм просто прекрасны, но геймплей очень потный, особенно когда ты один пытаешься сдержать толпу хитрых индивидумов.	2025-11-02
9	9	t	Великолепная без всякого преувеличения игра! Достоинств настолько много, что даже без понятия, с чего начать.)\r\nОднозначно можно сказать то, что сиквел превзошёл оригинал буквально по всем параметрам. Начиная с графики, которая в оригинале уже выглядит устаревшей, заканчивая целыми ВАГОНАМИ нового контента и крутейшим улучшением всех существовавших игровых механик с добавлением новых. Поначалу игра будто бы кажется такой же, как первая часть. Та же первая локация. Повторяющиейся локации с первой части. Повторяющийся босс с первой части, который тут правда имеет три стадии битвы с ним. Да и проходя игру обычным способой ты выходишь на совершенно несложного босса, после которого идёт лишь нейтральная концовка.\r\nОднако когда ты начинаешь копать глубже в том, что присутствует в этой игре, сколько секретов, вещей, явлений и ситуаций бывает с каждым новым забегом, начинаешь реально охреневать и восхищаться. Для изучения 50% игры надо уже как минимум часов 50 потратить. Для всей игры - больше 100. Упомянув про нейтральную концовку, вы правильно догадались, что тут есть ещё концовки, плюс две причём. Но для выхода на хорошую концовку надо по-настоящему потеть, потому что необходимую большую цепочку действий, которую надо реализовать с самого начала игры, напоминает целый ритуал, будто бы это действительно нечто сверхкрутое. И это действительно так, ибо выясняется, что если посчитать весь контент оригинала и сравнить с текущей частью, то данная часть минимум в 4 раза больше и шире. Выясняется, что новых локаций здесь гораздо больше и они довольно красивые, боссов не один а куда больше, монстров больше и они куда интересней выглядят и реализованы.\r\nБерём ещё во внимание главнейший факт только, что с каждым новым забегом уровни геренируются СЛУЧАЙНЫМ образом. Хоть и есть несколько закономерностей, которые с каждым забегом будут повторяться, однако игра и её сложность всё равно может сильно разниться с каждой новой попыткой. Поэтому реиграбельность тут на высоченном уровне.Главное достоинство, чего не было в предыдущей части, онлайн кооператив до четырёх игроков, что очень круто. Можно отметить конечно сильные лаги, десинхрон и даже вылеты, но это настолько редкие явления, что я и не почуствовал проблем и какой-либо фрустрации. Всё работает гладко, поэтому с друганами играть можно совершенно спокойно.Да, игра реально сложная, и в первые часы игра будто бы издевается и терзает игрока всеми этими опасностями. Что тут говорить. Даже банальный кинутый камень, который если упадёт игроку на голову, то даст урон, оглушение, оттолкнёт, после которого могут играть далеко идущие последствия, вплоть до самой смерти, если это произошло в опасном месте, где есть враги, шипы, прочие ловушки. И неважно, сколько у тебя хп. Хоть блин 100 или 1000, всё равно аккуратно надо играть, потому что можно попасться на ловушки, которые моментально убивают, либо можно словить вечное оглушение, от которого ты и попадёшься на сразу убивающую ловушку, ну или просто в конце концов замочат. Но если приноровится, наиграться, изучить данную игру, то выясняется, что все неприятности и опасности легко избегаются лишь одной вещью - вниманием. Скилл естественно решает, как и доля удачи в том, что не сгенерируется мега сложный уровень, но реально, посудите сами. Если очень внимательно играть, всё делать по тактикам, не тупить, чётко взвешивать все риски и принимать правильные решения по меркам своих возможностей, не проходить очень медленно, то оказывается, игра то лёгкая.)\r\nОценка 94/100	2022-12-31
10	10	t	 	2025-11-23
1	1	t	.	2025-11-11
\.


--
-- Data for Name: wishlists; Type: TABLE DATA; Schema: steam; Owner: postgres
--

COPY steam.wishlists (account_id, game_id, added_date) FROM stdin;
1	3	2022-10-10
2	4	2020-12-11
3	2	2023-11-23
4	4	2025-05-24
5	5	2016-02-17
6	3	2022-10-10
6	4	2020-12-11
7	12	2023-11-23
8	6	2025-05-24
\.


--
-- Data for Name: workshop; Type: TABLE DATA; Schema: steam; Owner: postgres
--

COPY steam.workshop (work_id, ownership_id, work_name, description, upload_date) FROM stdin;
1	3	tr_walkway_rc2	I DID NOT CREATE THIS MAP!\r\nI've just uploaded it from gamebanana for convenience sake, I'm not trying to take any credit from the original creator (don't care about any credit tbh).\r\noriginal link: http://gamebanana.com/maps/107794	2016-01-23
2	10	Roguelike Detour	A new gamemode inspired by The Binding of Isaac and Boguelike mode.	2017-07-22
3	22	Connect & Reconnect	Connect & reconnect to any lobby at any time with this mod. Join mid-run in the archives or in town. Reconnect to your friend's lobby after crashing.	2018-12-04
4	13	[RU] Vagante Русификатор	Переводит внутриигровой текст на русский язык.	2024-05-02
\.


--
-- Name: account_game_ownership_id_seq; Type: SEQUENCE SET; Schema: steam; Owner: postgres
--

SELECT pg_catalog.setval('steam.account_game_ownership_id_seq', 63, true);


--
-- Name: accounts_account_id_seq; Type: SEQUENCE SET; Schema: steam; Owner: postgres
--

SELECT pg_catalog.setval('steam.accounts_account_id_seq', 12, true);


--
-- Name: achievements_achievement_id_seq; Type: SEQUENCE SET; Schema: steam; Owner: postgres
--

SELECT pg_catalog.setval('steam.achievements_achievement_id_seq', 44, true);


--
-- Name: developers_developer_id_seq; Type: SEQUENCE SET; Schema: steam; Owner: postgres
--

SELECT pg_catalog.setval('steam.developers_developer_id_seq', 10, true);


--
-- Name: gamemodes_mode_id_seq; Type: SEQUENCE SET; Schema: steam; Owner: postgres
--

SELECT pg_catalog.setval('steam.gamemodes_mode_id_seq', 4, true);


--
-- Name: games_game_id_seq; Type: SEQUENCE SET; Schema: steam; Owner: postgres
--

SELECT pg_catalog.setval('steam.games_game_id_seq', 26, true);


--
-- Name: genres_genre_id_seq; Type: SEQUENCE SET; Schema: steam; Owner: postgres
--

SELECT pg_catalog.setval('steam.genres_genre_id_seq', 17, true);


--
-- Name: workshop_work_id_seq; Type: SEQUENCE SET; Schema: steam; Owner: postgres
--

SELECT pg_catalog.setval('steam.workshop_work_id_seq', 4, true);


--
-- Name: account_game account_game_uq; Type: CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.account_game
    ADD CONSTRAINT account_game_uq UNIQUE (account_id, game_id);


--
-- Name: accounts account_id_pk; Type: CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.accounts
    ADD CONSTRAINT account_id_pk PRIMARY KEY (account_id);


--
-- Name: accounts accounts_email_uk; Type: CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.accounts
    ADD CONSTRAINT accounts_email_uk UNIQUE (email);


--
-- Name: achievements achievement_id_pk; Type: CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.achievements
    ADD CONSTRAINT achievement_id_pk PRIMARY KEY (achievement_id);


--
-- Name: ownership_achievement achievement_ownership_id_pk; Type: CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.ownership_achievement
    ADD CONSTRAINT achievement_ownership_id_pk PRIMARY KEY (ownership_id, achievement_id);


--
-- Name: developers developer_id_pk; Type: CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.developers
    ADD CONSTRAINT developer_id_pk PRIMARY KEY (developer_id);


--
-- Name: developers developer_name_uk; Type: CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.developers
    ADD CONSTRAINT developer_name_uk UNIQUE (name);


--
-- Name: friends friendship_id_pk; Type: CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.friends
    ADD CONSTRAINT friendship_id_pk PRIMARY KEY (account_id_1, account_id_2);


--
-- Name: account_game game_account_id_pk; Type: CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.account_game
    ADD CONSTRAINT game_account_id_pk PRIMARY KEY (ownership_id);


--
-- Name: game_gamemode game_gamemode_id_pk; Type: CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.game_gamemode
    ADD CONSTRAINT game_gamemode_id_pk PRIMARY KEY (game_id, gamemode_id);


--
-- Name: game_genre game_genre_id_pk; Type: CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.game_genre
    ADD CONSTRAINT game_genre_id_pk PRIMARY KEY (game_id, genre_id);


--
-- Name: games game_id_pk; Type: CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.games
    ADD CONSTRAINT game_id_pk PRIMARY KEY (game_id);


--
-- Name: game_stats game_stats_pk; Type: CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.game_stats
    ADD CONSTRAINT game_stats_pk PRIMARY KEY (game_id);


--
-- Name: gamemodes gamemode_name_uk; Type: CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.gamemodes
    ADD CONSTRAINT gamemode_name_uk UNIQUE (name);


--
-- Name: achievements games_id_name_uk; Type: CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.achievements
    ADD CONSTRAINT games_id_name_uk UNIQUE (game_id, name);


--
-- Name: games games_title_uk; Type: CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.games
    ADD CONSTRAINT games_title_uk UNIQUE (title);


--
-- Name: genres genre_id_pk; Type: CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.genres
    ADD CONSTRAINT genre_id_pk PRIMARY KEY (genre_id);


--
-- Name: genres genres_name_uk; Type: CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.genres
    ADD CONSTRAINT genres_name_uk UNIQUE (name);


--
-- Name: gamemodes mode_id_pk; Type: CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.gamemodes
    ADD CONSTRAINT mode_id_pk PRIMARY KEY (mode_id);


--
-- Name: reviews reviews_id_pk; Type: CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.reviews
    ADD CONSTRAINT reviews_id_pk PRIMARY KEY (game_id, account_id);


--
-- Name: wishlists wishlist_id_pk; Type: CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.wishlists
    ADD CONSTRAINT wishlist_id_pk PRIMARY KEY (account_id, game_id);


--
-- Name: workshop work_id_pk; Type: CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.workshop
    ADD CONSTRAINT work_id_pk PRIMARY KEY (work_id);


--
-- Name: workshop work_name_uq; Type: CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.workshop
    ADD CONSTRAINT work_name_uq UNIQUE (work_name);


--
-- Name: account_work work_ownership_id_pk; Type: CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.account_work
    ADD CONSTRAINT work_ownership_id_pk PRIMARY KEY (work_id, ownership_id);


--
-- Name: accounts after_update_account_balance; Type: TRIGGER; Schema: steam; Owner: postgres
--

CREATE TRIGGER after_update_account_balance AFTER UPDATE ON steam.accounts FOR EACH ROW EXECUTE FUNCTION steam.insert_balance_log();


--
-- Name: accounts before_delete_account; Type: TRIGGER; Schema: steam; Owner: postgres
--

CREATE TRIGGER before_delete_account BEFORE DELETE ON steam.accounts FOR EACH ROW EXECUTE FUNCTION steam.insert_deleting_accounts();


--
-- Name: ownership_achievement before_insert_achievement_game; Type: TRIGGER; Schema: steam; Owner: postgres
--

CREATE TRIGGER before_insert_achievement_game BEFORE INSERT ON steam.ownership_achievement FOR EACH ROW EXECUTE FUNCTION steam.ownership_game_achievement_game();


--
-- Name: accounts before_update_account_balance; Type: TRIGGER; Schema: steam; Owner: postgres
--

CREATE TRIGGER before_update_account_balance BEFORE UPDATE ON steam.accounts FOR EACH ROW EXECUTE FUNCTION steam.positive_wallet_balance();


--
-- Name: accounts before_update_account_password; Type: TRIGGER; Schema: steam; Owner: postgres
--

CREATE TRIGGER before_update_account_password BEFORE UPDATE ON steam.accounts FOR EACH ROW EXECUTE FUNCTION steam.set_password_updated_at();


--
-- Name: reviews review_update_trigger; Type: TRIGGER; Schema: steam; Owner: postgres
--

CREATE TRIGGER review_update_trigger BEFORE UPDATE ON steam.reviews FOR EACH ROW EXECUTE FUNCTION steam.update_review_timestamp();


--
-- Name: accounts save_query_history; Type: TRIGGER; Schema: steam; Owner: postgres
--

CREATE TRIGGER save_query_history AFTER INSERT OR DELETE OR UPDATE ON steam.accounts FOR EACH STATEMENT EXECUTE FUNCTION steam.insert_query_history();


--
-- Name: friends account_id_1_fk; Type: FK CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.friends
    ADD CONSTRAINT account_id_1_fk FOREIGN KEY (account_id_1) REFERENCES steam.accounts(account_id) ON DELETE CASCADE;


--
-- Name: friends account_id_2_fk; Type: FK CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.friends
    ADD CONSTRAINT account_id_2_fk FOREIGN KEY (account_id_2) REFERENCES steam.accounts(account_id) ON DELETE CASCADE;


--
-- Name: reviews account_id_fk; Type: FK CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.reviews
    ADD CONSTRAINT account_id_fk FOREIGN KEY (account_id) REFERENCES steam.accounts(account_id) ON DELETE CASCADE;


--
-- Name: wishlists account_id_fk; Type: FK CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.wishlists
    ADD CONSTRAINT account_id_fk FOREIGN KEY (account_id) REFERENCES steam.accounts(account_id) ON DELETE CASCADE;


--
-- Name: account_game account_id_fk; Type: FK CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.account_game
    ADD CONSTRAINT account_id_fk FOREIGN KEY (account_id) REFERENCES steam.accounts(account_id) ON DELETE CASCADE;


--
-- Name: balance_log account_id_fk; Type: FK CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.balance_log
    ADD CONSTRAINT account_id_fk FOREIGN KEY (account_id) REFERENCES steam.accounts(account_id);


--
-- Name: deleting_account account_id_fk; Type: FK CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.deleting_account
    ADD CONSTRAINT account_id_fk FOREIGN KEY (account_id) REFERENCES steam.accounts(account_id) ON DELETE CASCADE;


--
-- Name: ownership_achievement achievement_id_fk; Type: FK CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.ownership_achievement
    ADD CONSTRAINT achievement_id_fk FOREIGN KEY (achievement_id) REFERENCES steam.achievements(achievement_id);


--
-- Name: games developer_id_fk; Type: FK CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.games
    ADD CONSTRAINT developer_id_fk FOREIGN KEY (developer_id) REFERENCES steam.developers(developer_id);


--
-- Name: achievements game_id_fk; Type: FK CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.achievements
    ADD CONSTRAINT game_id_fk FOREIGN KEY (game_id) REFERENCES steam.games(game_id);


--
-- Name: reviews game_id_fk; Type: FK CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.reviews
    ADD CONSTRAINT game_id_fk FOREIGN KEY (game_id) REFERENCES steam.games(game_id);


--
-- Name: wishlists game_id_fk; Type: FK CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.wishlists
    ADD CONSTRAINT game_id_fk FOREIGN KEY (game_id) REFERENCES steam.games(game_id);


--
-- Name: account_game game_id_fk; Type: FK CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.account_game
    ADD CONSTRAINT game_id_fk FOREIGN KEY (game_id) REFERENCES steam.games(game_id);


--
-- Name: game_gamemode game_id_fk; Type: FK CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.game_gamemode
    ADD CONSTRAINT game_id_fk FOREIGN KEY (game_id) REFERENCES steam.games(game_id);


--
-- Name: game_genre game_id_fk; Type: FK CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.game_genre
    ADD CONSTRAINT game_id_fk FOREIGN KEY (game_id) REFERENCES steam.games(game_id);


--
-- Name: game_stats game_id_fk; Type: FK CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.game_stats
    ADD CONSTRAINT game_id_fk FOREIGN KEY (game_id) REFERENCES steam.games(game_id);


--
-- Name: game_gamemode gamemode_id_fk; Type: FK CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.game_gamemode
    ADD CONSTRAINT gamemode_id_fk FOREIGN KEY (gamemode_id) REFERENCES steam.gamemodes(mode_id);


--
-- Name: game_genre genre_id_fk; Type: FK CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.game_genre
    ADD CONSTRAINT genre_id_fk FOREIGN KEY (genre_id) REFERENCES steam.genres(genre_id);


--
-- Name: account_work ownership_id_fk; Type: FK CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.account_work
    ADD CONSTRAINT ownership_id_fk FOREIGN KEY (ownership_id) REFERENCES steam.account_game(ownership_id);


--
-- Name: ownership_achievement ownership_id_fk; Type: FK CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.ownership_achievement
    ADD CONSTRAINT ownership_id_fk FOREIGN KEY (ownership_id) REFERENCES steam.account_game(ownership_id) ON DELETE CASCADE;


--
-- Name: workshop ownership_id_fk; Type: FK CONSTRAINT; Schema: steam; Owner: postgres
--

ALTER TABLE ONLY steam.workshop
    ADD CONSTRAINT ownership_id_fk FOREIGN KEY (ownership_id) REFERENCES steam.account_game(ownership_id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

