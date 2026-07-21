-- models/intermediate/int_youth_family_engagement.sql
{{ config(materialized='view') }}

WITH youth_scored AS (

    SELECT
        respondent_id,
        collection_period,
        facility_urban_rural,
        facility_field_average_name AS facility_field_avg_name,
        facility_region,

        -- Frequency indicators (raw yes/no)
        CASE visits_from_family
            WHEN 'Yes' THEN 1
            WHEN 'No'  THEN 0
        END AS visits_from_family_score,

        CASE talked_with_parent_phone
            WHEN 'Yes' THEN 1
            WHEN 'No'  THEN 0
        END AS talked_parent_phone_score,

        -- Relational quality indicators
        CASE family_staff_get_along
            WHEN 'Yes' THEN 1
            WHEN 'No'  THEN 0
        END AS family_staff_get_along_score,

        CASE family_feels_welcomed
            WHEN 'Yes' THEN 1
            WHEN 'No'  THEN 0
        END AS family_feels_welcomed_score,

        CASE family_regularly_talks_to_staff
            WHEN 'Yes' THEN 1
            WHEN 'No'  THEN 0
        END AS family_regularly_talks_score,

        -- Barrier flags (kept separate — presence of a barrier = 1)
        CASE WHEN barrier_distance IS NOT NULL AND barrier_distance != '' THEN 1 ELSE 0 END        AS barrier_distance_flag,
        CASE WHEN barrier_transportation IS NOT NULL AND barrier_transportation != '' THEN 1 ELSE 0 END AS barrier_transportation_flag,
        CASE WHEN barrier_family_unwilling IS NOT NULL AND barrier_family_unwilling != '' THEN 1 ELSE 0 END AS barrier_family_unwilling_flag,
        CASE WHEN judge_prohibited_visits IS NOT NULL AND judge_prohibited_visits != '' THEN 1 ELSE 0 END AS barrier_judge_flag,
        CASE WHEN no_visiting_hours IS NOT NULL AND no_visiting_hours != '' THEN 1 ELSE 0 END        AS barrier_no_hours_flag

    FROM {{ ref('stg_youth_climate') }}
)

SELECT
    respondent_id,
    collection_period,
    facility_urban_rural,
    facility_field_avg_name,
    facility_region,

    COUNT(*)                                        AS youth_response_count,

    -- Frequency dimension
    AVG(visits_from_family_score)                   AS avg_visits_from_family_score,
    AVG(talked_parent_phone_score)                  AS avg_talked_parent_phone_score,

    -- Relational quality dimension
    AVG(family_staff_get_along_score)               AS avg_family_staff_get_along_score,
    AVG(family_feels_welcomed_score)                AS avg_family_feels_welcomed_score,
    AVG(family_regularly_talks_score)                AS avg_family_regularly_talks_score,

    -- Barrier rates (share of youth reporting each barrier)
    AVG(barrier_distance_flag)                       AS pct_barrier_distance,
    AVG(barrier_transportation_flag)                 AS pct_barrier_transportation,
    AVG(barrier_family_unwilling_flag)               AS pct_barrier_family_unwilling,
    AVG(barrier_judge_flag)                          AS pct_barrier_judge_prohibited,
    AVG(barrier_no_hours_flag)                       AS pct_barrier_no_visiting_hours,

    -- Two separate composite scores, per your framework:
    -- (1) engagement FREQUENCY
    (
        COALESCE(AVG(visits_from_family_score), 0)
      + COALESCE(AVG(talked_parent_phone_score), 0)
    ) / 2.0  AS youth_family_frequency_composite,

    -- (2) engagement RELATIONAL QUALITY
    (
        COALESCE(AVG(family_staff_get_along_score), 0)
      + COALESCE(AVG(family_feels_welcomed_score), 0)
      + COALESCE(AVG(family_regularly_talks_score), 0)
    ) / 3.0  AS youth_family_quality_composite

FROM youth_scored
GROUP BY
    respondent_id,
    collection_period,
    facility_urban_rural,
    facility_field_avg_name,
    facility_region