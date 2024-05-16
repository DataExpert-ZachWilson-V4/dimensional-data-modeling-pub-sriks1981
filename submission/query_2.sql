INSERT INTO srik1981.actors 
WITH last_year AS (
        -- CTE for previous year data, this will be empty for the very first time
        SELECT
            *
        FROM
            srik1981.actors
        WHERE
            current_year = 1913
    ),
    current_year AS (
        -- CTE for current year data
        SELECT
            actor,
            actor_id,
            array_agg(
                CAST(
                    ROW(film, votes, rating, film_id, year) AS ROW(
                        film VARCHAR,
                        votes INTEGER,
                        rating DOUBLE,
                        film_id VARCHAR,
                        year INTEGER
                    )
                )
            ) AS films,
            year AS current_year,
            AVG(rating) AS avg_rating
        FROM
            bootcamp.actor_films
        WHERE
            year = 1914
        GROUP BY
            actor,
            actor_id,
            year
    ),
    result_set AS (
        SELECT
            coalesce(ly.actor, cy.actor) AS actor,
            coalesce(ly.actor_id, cy.actor_id) AS actor_id,
            CASE
                WHEN cy.films IS NULL THEN ly.films
                WHEN ly.films IS NULL THEN cy.films
                WHEN cy.films IS NOT NULL
                AND ly.films IS NOT NULL THEN cy.films || ly.films
            END AS films,
            CASE
                when avg_rating > 8 THEN 'star'
                when avg_rating > 7
                AND avg_rating <= 8 THEN 'good'
                when avg_rating > 6
                AND avg_rating <= 7 THEN 'average'
                when avg_rating <= 6 THEN 'bad'
                else ly.quality_class
            END AS quality_class,
            case
                when cy.actor_id is not null then true
                else false
            end as is_active,
            COALESCE(cy.current_year, ly.current_year + 1) as current_year
        FROM
            last_year ly FULL
            OUTER JOIN current_year cy ON ly.actor = cy.actor
    )
SELECT
    rs.actor,
    rs.actor_id,
    rs.films,
    rs.quality_class,
    rs.is_active,
    rs.current_year
FROM
    result_set rs