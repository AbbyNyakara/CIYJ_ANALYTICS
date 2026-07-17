-- models/staging/stg_incidents_confinement.sql
{{ config(materialized='view') }}

WITH source AS (
    SELECT *
    FROM {{ source('ciyj_raw', 'incident_reports_confinement') }}
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

    -- Confinement details
    CONFINEMENTTYPE                                 AS confinement_type,
    WHYCONFINEMENTWASUSED                           AS why_confinement_used,
    IFOTHER                                         AS if_other,
    TRY_TO_TIMESTAMP(DATETIMEIN)                    AS datetime_in,
    TRY_TO_TIMESTAMP(DATETIMEOUT)                   AS datetime_out,
    TRY_TO_NUMBER(MINUTESINCONFINEMENT)             AS minutes_in_confinement,
    LOCATION                                        AS confinement_location,

    -- Youth involved
    YOUTHID                                         AS youth_id,
    GENDER                                          AS gender,
    TRY_TO_NUMBER(AGE)                              AS age,
    ETHNICITY                                       AS ethnicity,

    -- Facility-level context for this incident
    TRY_TO_NUMBER(NUMBEROFYOUTHS)                   AS number_of_youths,
    TRY_TO_FLOAT(AVERAGETOTALPROGRAMMINGHOURSPERDAY) AS avg_programming_hours_per_day,
    TRY_TO_FLOAT(AVERAGETOTALRECREATIONHOURSPERDAY)  AS avg_recreation_hours_per_day

FROM source
