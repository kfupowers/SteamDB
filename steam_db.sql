CREATE SCHEMA IF NOT EXISTS steam;

CREATE TABLE IF NOT EXISTS steam.accounts
(
    account_id serial NOT NULL,
    username VARCHAR(200) NOT NULL,
    email VARCHAR(50) NOT NULL,
    password VARCHAR(50) NOT NULL,
    wallet_balance integer NOT NULL,
    CONSTRAINT account_id_pk PRIMARY KEY (account_id),
    CONSTRAINT accounts_email_uk UNIQUE (email),
    CONSTRAINT wallet_balance_ch CHECK (wallet_balance >=0)
);

CREATE TABLE IF NOT EXISTS steam.developers
(
    developer_id serial NOT NULL,
    name VARCHAR(100) NOT NULL,
    CONSTRAINT developer_id_pk PRIMARY KEY (developer_id),
    CONSTRAINT developer_name_uk UNIQUE (name)
);

CREATE TABLE IF NOT EXISTS steam.friends
(
    account_id_1 integer NOT NULL,
    account_id_2 integer NOT NULL,
    CONSTRAINT friendship_id_pk PRIMARY KEY (account_id_1, account_id_2),
    CONSTRAINT account_id_1_fk FOREIGN KEY (account_id_1)
        REFERENCES steam.accounts (account_id),
    CONSTRAINT account_id_2_fk FOREIGN KEY (account_id_2)
        REFERENCES steam.accounts (account_id),
    CONSTRAINT friends_ch CHECK (account_id_2 > account_id_1)
);

CREATE TABLE IF NOT EXISTS steam.gamemodes
(
    mode_id serial NOT NULL,
    name VARCHAR(100) NOT NULL,
    CONSTRAINT mode_id_pk PRIMARY KEY (mode_id),
    CONSTRAINT gamemode_name_uk UNIQUE (name)
);

CREATE TABLE IF NOT EXISTS steam.games
(
    game_id serial NOT NULL,
    developer_id integer NOT NULL,
    title VARCHAR(200) NOT NULL,
    description VARCHAR(1000),
    release_date date,
    price integer NOT NULL,
    CONSTRAINT game_id_pk PRIMARY KEY (game_id),
    CONSTRAINT developer_id_fk FOREIGN KEY (developer_id)
        REFERENCES steam.developers (developer_id),
    CONSTRAINT games_title_uk UNIQUE (title),
    CONSTRAINT price_ch CHECK(price >= 0)
);

CREATE TABLE IF NOT EXISTS steam.achievements
(
    achievement_id serial NOT NULL,
    game_id integer NOT NULL,
    name VARCHAR(200) NOT NULL,
    description VARCHAR(1000),
    CONSTRAINT achievement_id_pk PRIMARY KEY (achievement_id),
    CONSTRAINT game_id_fk FOREIGN KEY (game_id)
        REFERENCES steam.games (game_id)
);

CREATE TABLE IF NOT EXISTS steam.genres
(
    genre_id serial NOT NULL,
    name VARCHAR(100) NOT NULL,
    CONSTRAINT genre_id_pk PRIMARY KEY (genre_id),
    CONSTRAINT genres_name_uk UNIQUE (name)
);

CREATE TABLE IF NOT EXISTS steam.reviews
(
    game_id integer NOT NULL,
    account_id integer NOT NULL,
    rating boolean NOT NULL,
    comment VARCHAR(2000),
    review_date date NOT NULL,
    CONSTRAINT reviews_id_pk PRIMARY KEY (game_id, account_id),
    CONSTRAINT account_id_fk FOREIGN KEY (account_id)
        REFERENCES steam.accounts (account_id),
    CONSTRAINT game_id_fk FOREIGN KEY (game_id)
        REFERENCES steam.games (game_id)
);

CREATE TABLE IF NOT EXISTS steam.wishlists
(
    account_id integer NOT NULL,
    game_id integer NOT NULL,
    added_date date NOT NULL,
    CONSTRAINT wishlist_id_pk PRIMARY KEY (account_id, game_id),
    CONSTRAINT account_id_fk FOREIGN KEY (account_id)
        REFERENCES steam.accounts (account_id),
    CONSTRAINT game_id_fk FOREIGN KEY (game_id)
        REFERENCES steam.games (game_id)
);

CREATE TABLE IF NOT EXISTS steam.workshop
(
    work_id serial,
    game_id integer NOT NULL,
    account_id integer NOT NULL,
    CONSTRAINT work_id_pk PRIMARY KEY (work_id),
    CONSTRAINT account_id_fk FOREIGN KEY (account_id)
        REFERENCES steam.accounts (account_id),
    CONSTRAINT game_id_fk FOREIGN KEY (game_id)
        REFERENCES steam.games (game_id)
);

ALTER TABLE steam.workshop ADD COLUMN work_name varchar(200);
ALTER TABLE steam.workshop ADD COLUMN description varchar(5000);
ALTER TABLE steam.workshop ADD COLUMN upload_date date;
ALTER TABLE steam.workshop ALTER COLUMN work_name set NOT NULL;
ALTER TABLE steam.workshop ALTER COLUMN upload_date set NOT NULL;


CREATE TABLE IF NOT EXISTS steam.account_achievement
(
    account_id integer NOT NULL,
    achievement_id integer NOT NULL,
    CONSTRAINT achievement_account_id_pk PRIMARY KEY (account_id, achievement_id),
    CONSTRAINT account_id_fk FOREIGN KEY (account_id)
        REFERENCES steam.accounts (account_id),
    CONSTRAINT achievement_id_fk FOREIGN KEY (achievement_id)
        REFERENCES steam.achievements (achievement_id)
);

CREATE TABLE IF NOT EXISTS steam.account_game
(
    account_id integer NOT NULL,
    game_id integer NOT NULL,
    CONSTRAINT game_account_id_pk PRIMARY KEY (account_id, game_id),
    CONSTRAINT account_id_fk FOREIGN KEY (account_id)
        REFERENCES steam.accounts (account_id),
    CONSTRAINT game_id_fk FOREIGN KEY (game_id)
        REFERENCES steam.games (game_id)
);

CREATE TABLE IF NOT EXISTS steam.game_gamemode
(
    game_id integer NOT NULL,
    gamemode_id integer NOT NULL,
    CONSTRAINT game_gamemode_id_pk PRIMARY KEY (game_id,gamemode_id),
    CONSTRAINT game_id_fk FOREIGN KEY (game_id)
        REFERENCES steam.games (game_id),
    CONSTRAINT gamemode_id_fk FOREIGN KEY (gamemode_id)
        REFERENCES steam.gamemodes (mode_id)
);

CREATE TABLE IF NOT EXISTS steam.game_genre
(
    game_id integer NOT NULL,
    genre_id integer NOT NULL,
    CONSTRAINT game_genre_id_pk PRIMARY KEY (game_id, genre_id),
    CONSTRAINT game_id_fk FOREIGN KEY (game_id)
        REFERENCES steam.games (game_id),
    CONSTRAINT genre_id_fk FOREIGN KEY (genre_id)
        REFERENCES steam.genres (genre_id)
);

INSERT INTO steam.accounts (username, email, password, wallet_balance) VALUES
('Dimov', 'dimov@gmail.com', 'ndazqdCzDGyn', 0),
('Hoot', 'hoot@gmail.com', 'GmFwTvgzmdeT', 170),
('lystic', 'lystic@gmail.com', 'YAXzKhpUcsTT', 230),
('obikym', 'obikym@gmail.com', 'TdbPSZbBZJhW', 2000),
('sharyk', 'sharyk@gmail.com', 'NP6qZ2wWnnCE', 30000);

INSERT INTO steam.friends (account_id_1, account_id_2) VALUES
(1, 2),
(1, 3),
(1, 4),
(1, 5),
(2, 3);

INSERT INTO steam.developers (name) VALUES
('Valve'),
('Team Meat'),
('Maddy Makes Games Inc.'),
('Crackshell');

INSERT INTO steam.games (developer_id, title, description, release_date, price) VALUES
(1, 'Deadlock','Deadlock — многопользовательская игра на ранней стадии разработки', NULL, 0),
(1, 'Team Fortress 2','Девять классов с уникальными характерами откроют вам доступ ко множеству разнообразных тактик и навыков. Игра беспрестанно пополняется новыми режимами, картами, предметами и, самое главное, шляпами!', '2007-10-10', 0),
(4, 'Serious Sam''s Bogus Detour','Serious Sam’s Bogus Detour — это абсолютно новая убойная глава в легендарной саге Serious Sam от создателей игры "Hammerwatch", компании Crackshell.', '2017-06-20', 385),
(3, 'Celeste','В платформере от создателей TowerFall Мэдлин сражается со своими демонами на пути к вершине горы Селеста. Преодолевай сотни хорошо продуманных сложностей, отыскивай тайники и постигай загадку горы.', '2018-01-25', 710),
(2, 'Super Meat Boy','The infamous, tough-as-nails platformer comes to Steam with a playable Head Crab character (Steam-exclusive)!', '2010-12-01', 299);

INSERT INTO steam.gamemodes(name) VALUES
('Для одного игрока'),
('Для нескольких игроков'),
('Игрок против игрока'),
('Кооператив');

INSERT INTO steam.game_gamemode(game_id, gamemode_id) VALUES
(1, 2),
(1, 3),
(2, 2),
(2, 3),
(3, 1),
(3, 2),
(3, 4),
(4, 1),
(5, 1);

INSERT INTO steam.genres(name) VALUES
('Экшен'),
('Инди'),
('Платформер'),
('MOBA'),
('Геройский шутер'),
('Шутер'),
('От первого лица'),
('От третьего лица'),
('Шутер с видом сверху'),
('2D');

INSERT INTO steam.game_genre(game_id, genre_id) VALUES
(1, 4),
(1, 5),
(1, 6),
(1, 8),
(2, 5),
(2, 6),
(2, 7),
(3, 1),
(3, 2),
(3, 9),
(3, 10),
(4, 2),
(4, 3),
(4, 10),
(5, 2),
(5, 3),
(5, 10);

INSERT INTO steam.account_game(account_id, game_id) VALUES
(1, 1),
(1, 2),
(2, 1),
(2, 3),
(3, 1),
(3, 4),
(4, 1),
(4, 5),
(5, 1),
(5, 2),
(5, 3);

INSERT INTO steam.wishlists(account_id, game_id, added_date) VALUES
(1, 3, '2022-10-10'),
(2, 4, '2020-12-11'),
(3, 2, '2023-11-23'),
(4, 4, '2025-05-24'),
(5, 5, '2016-02-17');

INSERT INTO steam.workshop(game_id, account_id, work_name, description, upload_date) VALUES
(2, 1, 'tr_walkway_rc2', 'I DID NOT CREATE THIS MAP!
I''ve just uploaded it from gamebanana for convenience sake, I''m not trying to take any credit from the original creator (don''t care about any credit tbh).
original link: http://gamebanana.com/maps/107794', '2016-01-23'),
(5,2, 'Roguelike Detour', 'A new gamemode inspired by The Binding of Isaac and Boguelike mode.', '2017-07-22');

INSERT INTO steam.reviews(game_id, account_id, rating, comment, review_date) VALUES
(2, 1, TRUE, 'Наилучшей шутер.', '2025-06-27'),
(3, 2, TRUE, 'Скажу не кривя душой, что на данный момент это лучшая инди-игра/спинофф во вселенной Serious Sam, которая по некоторым параметрам может дать серьёзную фору даже большим официальным играм от Croteam.', '2017-06-20'),
(4, 3, TRUE, 'Очень спокойная и расслабляющая игра… до тех пор пока ты не перейдешь дальше главного меню', '2025-09-03'),
(5, 4, TRUE, 'Понимание таймингов и некое умение нажимать на кнопочки в процессе игры были лишь порогом вхождения для 9 главы. Игра обязательна на 100% достижений', '2025-09-07');

INSERT INTO steam.achievements(game_id, name, description) VALUES
(2, 'Утешительный приз', 'Умрите от удара в спину 50 раз'),
(2, 'Нас мало, но мы в килтах', 'Нанесите 1 миллион урона от взрывов'),
(2, 'Агент-провокатор', 'Убейте ваших друзей из Steam ударом в спину 10 раз'),
(2, 'Аптечный ковбой', 'За все время вылечите 100 000 единиц здоровья при помощи раздатчика'),
(3, 'Разящее жало', 'Одолеть майора Разящее Жало'),
(3, 'Жирдяй проглот', 'Одолеть жирдяя проглота'),
(3, 'Глаз д-ра Плата', 'Отобрать глаз у доктора Плата'),
(3, 'Убить всех', 'Перебить всех врагов на уровне одной кампании'),
(4, '1UP!', 'Получить 1UP'),
(4, 'Спасибо, что играли', 'Завершить все "Стороны B"'),
(4, 'Wow', 'Find the moon berry'),
(4, 'Farewell', 'Complete Chapter 9'),
(5, 'Medium well', 'Spend as little time as possible in Hell'),
(5, 'Medium', 'Spend as little time as possible in The Salt Factory'),
(5, 'Medium Rare', 'Spend as little time as possible in The Hospital'),
(5, 'Rare', 'Spend as little time as possible in The Forest');

INSERT INTO steam.account_achievement(account_id, achievement_id) VALUES
(1,1),
(1,2),
(1,3),
(1,4),
(2,5),
(2,6),
(2,7),
(2,8),
(3,9),
(3,10),
(3,11),
(3,12),
(4,13),
(4,14),
(4,15),
(4,16),
(5,1),
(5,2),
(5,6),
(5,7);


