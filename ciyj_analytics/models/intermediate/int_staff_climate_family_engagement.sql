-- models/intermediate/int_staff_climate_family_engagement.sql
{{ config(materialized='view') }}

WITH staff_scored AS (

    SELECT
        respondent_id,
        collection_period,
        facility_urban_rural,
        facility_field_avg_name,
        facility_region,

        -- Convert Yes/No family engagement questions to 1/0
        CASE staff_value_family_as_partners
            WHEN 'Yes' THEN 1
            WHEN 'No'  THEN 0
        END AS value_family_score,

        CASE believes_family_improves_results
            WHEN 'Yes' THEN 1
            WHEN 'No'  THEN 0
        END AS believes_family_helps_score,

        CASE training_improved_family_interaction
            WHEN 'Yes' THEN 1
            WHEN 'No'  THEN 0
        END AS training_improved_interaction_score,

        -- Yes/Sometimes/No scale -> 1 / 0.5 / 0
        CASE staff_talk_youth_about_family
            WHEN 'Yes'       THEN 1
            WHEN 'Sometimes' THEN 0.5
            WHEN 'No'        THEN 0
        END AS talk_about_family_score,

        CASE ask_youths_about_bad_things
            WHEN 'Yes' THEN 1
            WHEN 'No'  THEN 0
            -- "Don't know" interpreted as NULL, excluded from AVG
        END AS asked_about_bad_things_score

    FROM {{ ref('stg_staff_climate') }}
)

SELECT
    respondent_id,
    collection_period,
    facility_urban_rural,
    facility_field_avg_name,
    facility_region,

    COUNT(*)                                        AS staff_response_count,

    AVG(value_family_score)                         AS avg_value_family_score,
    AVG(believes_family_helps_score)                AS avg_believes_family_helps_score,
    AVG(training_improved_interaction_score)        AS avg_training_improved_interaction_score,
    AVG(talk_about_family_score)                    AS avg_talk_about_family_score,
    AVG(asked_about_bad_things_score)               AS avg_asked_about_bad_things_score,

    -- Composite staff family engagement score
    (
        COALESCE(AVG(value_family_score), 0)
      + COALESCE(AVG(believes_family_helps_score), 0)
      + COALESCE(AVG(training_improved_interaction_score), 0)
      + COALESCE(AVG(talk_about_family_score), 0)
      + COALESCE(AVG(asked_about_bad_things_score), 0)
    ) / 5.0                                         AS staff_family_engagement_composite,

    -- Composite staff family attitudes
    (
    COALESCE(AVG(value_family_score), 0)
    + COALESCE(AVG(believes_family_helps_score), 0)
    + COALESCE(AVG(training_improved_interaction_score), 0)
    ) / 3.0 AS staff_family_attitude_composite,

    -- Composite staff_family_conversation_composite
    (
      COALESCE(AVG(talk_about_family_score), 0)
    + COALESCE(AVG(asked_about_bad_things_score), 0)
    ) / 2.0 AS staff_family_conversation_composite

FROM staff_scored
GROUP BY
    respondent_id,
    collection_period,
    facility_urban_rural,
    facility_field_avg_name,
    facility_region