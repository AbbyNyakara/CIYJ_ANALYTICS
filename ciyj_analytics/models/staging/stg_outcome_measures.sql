{{ config(materialized='view') }}

WITH source AS (
    SELECT *
    FROM {{ source('ciyj_raw', 'outcome_measures') }}
)

SELECT
    -- Identifiers
    COLLECTIONPERIOD                                AS collection_period,
    RESPONDENTID                                    AS respondent_id,
    TRY_TO_TIMESTAMP(CREATED)                       AS created,

    -- Period
    TRY_TO_DATE(PERIODBEGIN, 'YYYY-MM-DD')         AS period_begin,
    TRY_TO_DATE(PERIODEND, 'YYYY-MM-DD')           AS period_end,

    -- Facility dimensions
    FACILITYURBANRURAL                              AS facility_urban_rural,
    FACILITYFIELDAVERAGENAME                        AS facility_field_avg_name,
    REGION                                          AS facility_region,

    -- Measure metadata
    NAME                                            AS measure_name,
    DESCRIPTION                                     AS measure_description,
    DISPLAYTYPE                                     AS display_type,
    DIRECTION                                       AS direction,

    -- Measure values
    TRY_TO_DOUBLE(NUMERATOR)                         AS numerator,
    TRY_TO_DOUBLE(DENOMINATOR)                       AS denominator,
    TRY_TO_DOUBLE(RESULT)                            AS result

FROM source
