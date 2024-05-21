INSERT INTO srik1981.actors_history_scd
WITH last_year AS ( -- Latest data from SCD table
    SELECT 
        * 
    FROM srik1981.actors_history_scd
    WHERE end_date = 1918
),
this_year AS ( -- Next year data from dimension
    SELECT 
        * 
    FROM srik1981.actors
    WHERE current_year = 1919
),
combined AS ( -- Prepare the dataset for incremental load
    SELECT 
        COALESCE(ly.actor, ty.actor) AS actor,
        COALESCE(ly.actor_id, ty.actor_id) AS actor_id,
        CASE 
            WHEN ly.quality_class IS NULL OR ty.quality_class <> ly.quality_class THEN 1
            WHEN ly.is_active IS NULL OR ty.is_active <> ly.is_active THEN 1
            ELSE 0
        END AS did_change,
        ly.quality_class AS l_quality_class,
        ty.quality_class AS t_quality_class,
        ly.is_active AS l_is_active,
        ty.is_active AS t_is_active,
        ly.start_date,
        ly.end_date,
        ly.current_year AS last_yr,
        ty.current_year AS curr_yr
    FROM this_year ty
    FULL OUTER JOIN last_year ly ON ly.actor_id = ty.actor_id
    AND ly.current_year + 1 = ty.current_year
)
-- Final query for clarity
SELECT
    actor,
    actor_id,
    t_quality_class AS quality_class,
    t_is_active AS is_active,
    CASE WHEN did_change = 0 THEN start_date ELSE curr_yr END AS start_date,
    curr_yr AS end_date,
    curr_yr AS current_year
FROM combined
