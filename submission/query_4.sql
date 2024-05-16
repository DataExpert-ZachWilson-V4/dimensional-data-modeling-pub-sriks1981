INSERT INTO srik1981.actors_history_scd 
with last_year as (
        select
            actor,
            actor_id,
            quality_class,
            lag(quality_class) over (
                partition by actor
                order by
                    current_year
            ) as prev_quality_class,
            is_active,
            lag(is_active) over (
                partition by actor
                order by
                    current_year
            ) as prev_is_active,
            current_year
        from
            srik1981.actors
    ),
    result as (
        select
            actor,
            actor_id,
            quality_class,
            prev_quality_class,
            is_active,
            prev_is_active,
            SUM(
                case
                    when quality_class <> prev_quality_class
                    or is_active <> prev_is_active then 1
                    else 0
                end
            ) over (
                partition by actor
                order by
                    current_year
            ) as did_change,
            current_year
        from
            last_year
    )
select
    distinct actor,
    actor_id,
    quality_class,
    is_active,
    min(current_year) over (partition by actor, did_change) as start_date,
    max(current_year) over (partition by actor, did_change) as end_date,
    max(current_year) over () as current_year
from
    result
order by
    actor