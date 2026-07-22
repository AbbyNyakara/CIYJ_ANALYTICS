-- models/intermediate/int_youth_phone_contact.sql
{{ config(materialized='view') }}

WITH youth_phone_scored AS (
    SELECT
        respondent_id,
        collection_period,

        CASE talked_with_parent_phone
            WHEN 'Yes' THEN 1
            WHEN 'No'  THEN 0
        END AS talked_with_parent_phone_score,

        CASE parent_phone_frequency
            WHEN 'Less than once a month'   THEN 1
            WHEN 'Once a month'             THEN 2
            WHEN '2 - 3 times per month'    THEN 3
            WHEN '1 - 2 times per week'     THEN 4
            WHEN '3 - 4 times per week'     THEN 5
            WHEN '5 or more times per week' THEN 6
        END AS parent_phone_frequency_score,

        CASE staff_phone_calls_fair
            WHEN 'Very fair'       THEN 3
            WHEN 'Fair'            THEN 2
            WHEN 'Somewhat fair'   THEN 1
            WHEN 'Not fair at all' THEN 0
        END AS staff_phone_calls_fair_score

    FROM {{ ref('stg_youth_climate') }}
)

SELECT
    respondent_id,
    collection_period,
    -- facility_urban_rural,
    -- facility_field_avg_name,
    -- facility_region,

    COUNT(*) AS youth_response_count,

    AVG(talked_with_parent_phone_score)   AS avg_talked_with_parent_phone,
    AVG(parent_phone_frequency_score)     AS avg_parent_phone_frequency,
    AVG(staff_phone_calls_fair_score)     AS avg_staff_phone_calls_fair,

    -- FREQUENCY composite (normalized to 0-1 scale using /5 for the 6-point item)
    (
        COALESCE(AVG(talked_with_parent_phone_score), 0)
       + COALESCE((AVG(parent_phone_frequency_score) - 1) / 5.0, 0)
    ) / 2.0 AS phone_contact_frequency_composite,

    -- QUALITY composite (normalized to 0-1 scale using /3 for the 3-point item)
    COALESCE(AVG(staff_phone_calls_fair_score) / 3.0, 0) AS phone_contact_quality_composite

FROM youth_phone_scored
GROUP BY
    respondent_id,
    collection_period
