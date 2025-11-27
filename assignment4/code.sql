CREATE TABLE steam_reviews AS
SELECT *
FROM read_json_auto(
    'C:\Users\Asus\Downloads\20250901.json',
    maximum_object_size = 67108864
);

CREATE TABLE steam_games AS
SELECT *
FROM read_json_auto(
    'C:\Users\Asus\Downloads\20250831.json',
    maximum_object_size = 106144477
);

CREATE TABLE steam_reviews_unnested_reviews AS
SELECT
    game.appid,
    review.*
FROM (
    SELECT UNNEST(reviews) AS game
    FROM steam_reviews
),
UNNEST(game.review_data.reviews) AS review;

CREATE TABLE steam_reviews_unnested_game_info AS
SELECT
    game.appid,
    game.review_data.query_summary.total_reviews,
    game.review_data.query_summary.total_positive,
    game.review_data.query_summary.total_negative
FROM (
    SELECT UNNEST(reviews) AS game
    FROM steam_reviews
);

CREATE TABLE steam_games_unnested AS
WITH all_games AS (
    SELECT UNNEST(games).app_details.data AS d
    FROM steam_games
),
flat AS (
    SELECT UNNEST(d) AS g
    FROM all_games
)
SELECT
    g.* EXCLUDE (price_overview, genres, release_date, achievements, developers),

    CAST(g.required_age AS INT) AS required_age,

    g.price_overview.initial / 100 AS price_initial,
    g.price_overview.final   / 100 AS price_final,
    g.price_overview.currency,
    g.price_overview.discount_percent,
    g.price_overview.final_formatted,

    [x.description FOR x IN g.genres] AS genres,

    g.release_date.coming_soon AS is_coming_soon,
    g.release_date.date        AS release_date,

    IFNULL(g.achievements.total, 0) AS total_achievements,

    g.developers[1] AS main_dev_studio
FROM flat g;

SELECT
    g.name,
    r.appid,
    r.total_reviews,
    r.total_positive,
    r.total_negative,
FROM steam_reviews_unnested_game_info r
LEFT JOIN steam_games_unnested g
    ON r.appid = g.steam_appid
ORDER BY r.total_reviews DESC
LIMIT 20; -- top 20 games by amount of reviews

WITH years AS (
    SELECT
        TRY_CAST(RIGHT(TRIM(release_date), 4) AS INT) AS year
    FROM steam_games_unnested
    WHERE release_date IS NOT NULL
      AND (is_coming_soon IS FALSE OR is_coming_soon IS NULL)
)
SELECT
    year,
    COUNT(*) AS n_games
FROM years
GROUP BY year
ORDER BY year DESC; -- number of games per year

WITH genre_unnested AS (
    SELECT
        UNNEST(genres) AS genre,
        price_final,
        currency
    FROM steam_games_unnested
    WHERE price_final IS NOT NULL
)
SELECT
    genre,
    COUNT(*)        AS n_games,
    AVG(price_final) AS avg_price
FROM genre_unnested
GROUP BY genre
ORDER BY avg_price DESC; -- avg price by genre

WITH ratios AS (
    SELECT
        appid,
        total_positive,
        total_negative,
        total_reviews,
        (total_positive * 1.0 / NULLIF(total_reviews, 0)) * 100 AS positive_pct
    FROM steam_reviews_unnested_game_info
    WHERE total_reviews > 0
)
SELECT
    SUM(positive_pct > 50)::FLOAT / COUNT(*) * 100 AS percent_over_50,
    SUM(positive_pct < 50)::FLOAT / COUNT(*) * 100 AS percent_below_50
FROM ratios; -- відсоток ігор, у яких позитивні відгуки 50+ відсотків, та менше 50

CREATE OR REPLACE TABLE viz_genre_positive AS
WITH game_ratings AS (
    SELECT
        r.appid,
        (r.total_positive * 1.0 / NULLIF(r.total_reviews, 0)) * 100 AS positive_pct
    FROM steam_reviews_unnested_game_info r
    WHERE r.total_reviews > 0
),
genre_expanded AS (
    SELECT
        g.steam_appid,
        UNNEST(g.genres) AS genre
    FROM steam_games_unnested g
    WHERE g.genres IS NOT NULL
),
joined AS (
    SELECT
        ge.genre,
        gr.positive_pct
    FROM genre_expanded ge
    JOIN game_ratings gr
        ON ge.steam_appid = gr.appid
)
SELECT
    genre,
    COUNT(*)                                 AS n_games,
    AVG(positive_pct)                         AS avg_positive_pct
FROM joined
GROUP BY genre
HAVING COUNT(*) >= 5 -- щоб прибрати жанри з однією грою, нєтакусі
ORDER BY avg_positive_pct DESC; -- відсоток позитивних відгуків за жанрами ігор

SELECT * FROM viz_genre_positive;
COPY viz_genre_positive TO 'C:\Users\Asus\Downloads\genre_positive.csv' (FORMAT CSV, HEADER TRUE);
