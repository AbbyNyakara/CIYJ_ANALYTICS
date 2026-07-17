-- models/staging/stg_incidents_youth_involved.sql
{{ config(materialized='view') }}

WITH source AS (
    SELECT *
    FROM {{ source('ciyj_raw', 'incident_reports_youth_involved') }}
)

SELECT
    -- Identifiers
    PBSINCIDENTREPORTID                             AS incident_report_id,
    VERSIONNUMBER                                   AS version_number,
    COLLECTIONPERIOD                                AS collection_period,
    RESPONDENTID                                    AS respondent_id,
    TRY_TO_TIMESTAMP(CREATED)                       AS created,

    -- Period
    TRY_TO_DATE(PERIODBEGIN, 'YYYY-MM-DD')         AS period_begin,
    TRY_TO_DATE(PERIODEND, 'YYYY-MM-DD')           AS period_end,

    -- Facility dimensions
    FACILITYURBANRURAL                              AS facility_urban_rural,
    FACILITYFIELDAVERAGENAME                        AS facility_field_avg_name,
    FACILITYREGION                                  AS facility_region,

    -- Incident metadata
    ROWNUMBER                                       AS row_number,
    TRY_TO_DATE(OCCURRED, 'YYYY-MM-DD')             AS occurred_date,
    OCCURREDINLIVINGUNIT                            AS occurred_in_living_unit,

    -- Youth involved
    YOUTHID                                         AS youth_id,
    GENDER                                          AS gender,
    TRY_TO_NUMBER(AGE)                              AS age,
    ETHNICITY                                       AS ethnicity

FROM source
