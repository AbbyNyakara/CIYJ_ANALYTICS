{{ config(materialized='view') }}

WITH source AS (
    SELECT *
    FROM {{ source('ciyj_raw', 'incident_reports_assaults') }}
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
    INITIATED                                       AS initiated,
    VICTIM                                          AS victim,

    -- Initiator
    YOUTHIDWHOINITIATED                             AS youth_id_who_initiated,
    INITIATORGENDER                                 AS initiator_gender,
    TRY_TO_NUMBER(INITIATORAGE)                     AS initiator_age,
    INITIATORETHNICITY                              AS initiator_ethnicity,

    -- Victim
    YOUTHIDOFVICTIM                                 AS youth_id_of_victim,
    VICTIMGENDER                                    AS victim_gender,
    TRY_TO_NUMBER(VICTIMAGE)                        AS victim_age,
    VICTIMETHNICITY                                 AS victim_ethnicity

FROM source

