
-- models/staging/stg_incident_reports_medical.sql
{{ config(materialized='view') }}

WITH source AS (
    SELECT *
    FROM {{ source('ciyj_raw', 'incident_reports_medical') }}
)

SELECT
    -- Identifiers
    ID                                               AS incident_id,
    VERSIONNUMBER                                    AS version_number,
    COLLECTIONPERIOD                                 AS collection_period,
    RESPONDENTID                                     AS respondent_id,
    TRY_TO_TIMESTAMP(CREATED)                        AS created_at,

    -- Period
    TRY_TO_DATE(PERIODBEGIN, 'YYYY-MM-DD')          AS period_begin,
    TRY_TO_DATE(PERIODEND, 'YYYY-MM-DD')            AS period_end,

    -- Facility dimensions
    FACILITYURBANRURAL                               AS facility_urban_rural,
    FACILITYFIELDAVERAGENAME                         AS facility_field_avg_name,
    FACILITYREGION                                   AS facility_region,

    -- Incident metadata
    ROWNUMBER                                        AS row_number,
    TRY_TO_DATE(OCCURRED, 'YYYY-MM-DD')              AS occurred_date,
    OCCURREDINLIVINGUNIT                             AS occurred_in_living_unit,

    -- Youth involved
    YOUTHID                                          AS youth_id,
    GENDER                                           AS gender,
    TRY_TO_NUMBER(AGE)                               AS age,
    ETHNICITY                                        AS ethnicity,

    -- Medical details
    REASONFOREXAMINATION                             AS reason_for_examination,
    TAKENOFFSITE                                     AS taken_off_site,
    TRY_TO_DATE(DATESEENBYMEDICALSTAFF, 'YYYY-MM-DD') AS date_seen_by_medical_staff

FROM source
