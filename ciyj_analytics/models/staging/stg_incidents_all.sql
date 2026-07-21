-- models/staging/stg_incidents_all.sql
{{ config(materialized='view') }}


WITH source AS (
    SELECT *
    FROM {{ source('ciyj_raw', 'incident_reports_all') }}
)


SELECT
    -- Identifiers
    PBSINCIDENTREPORTID                              AS incident_report_id,
    VERSIONNUMBER                                     AS version_number,
    COLLECTIONPERIOD                                  AS collection_period,
    RESPONDENTID                                      AS respondent_id,
    SURVEYINSTANCEID                                  AS survey_instance_id,
    TRY_TO_TIMESTAMP(CREATED)                         AS created,

    -- Period
    TRY_TO_DATE(PERIODBEGIN, 'YYYY-MM-DD')           AS period_begin,
    TRY_TO_DATE(PERIODEND, 'YYYY-MM-DD')             AS period_end,

    -- Facility dimensions
    FACILITYURBANRURAL                                AS facility_urban_rural,
    FACILITYFIELDAVERAGENAME                          AS facility_field_avg_name,
    FACILITYREGION                                    AS facility_region,
    YOUTHPOPULATION                                   AS youth_population,


    -- Incident metadata
    TRY_TO_DATE(OCCURRED, 'YYYY-MM-DD')               AS occurred_date,
    TRY_TO_DATE(LOGGED, 'YYYY-MM-DD')                 AS logged_date,
    OCCURREDINLIVINGUNIT                              AS occurred_in_living_unit,
    TRY_TO_NUMBER(NUMBEROFYOUTHINVOLVED)              AS number_of_youth_involved,
    TRY_TO_NUMBER(NUMBEROFSTAFFINVOLVED)              AS number_of_staff_involved,

    -- Incident category flags
    ASSAULT                                           AS assault,
    SUICIDALBEHAVIOR                                  AS suicidal_behavior,
    PROPERTY                                          AS property,
    MISCONDUCT                                        AS misconduct,
    MISCELLANEOUS                                     AS miscellaneous,
    RESTRAINT                                         AS restraint,
    INJURY                                            AS injury,
    SEENBYMEDICAL                                     AS seen_by_medical,
    CONFINEMENT                                       AS confinement

FROM source