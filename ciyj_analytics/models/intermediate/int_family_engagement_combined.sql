-- models/intermediate/int_family_engagement_combined.sql
{{ config(materialized='view') }}

SELECT
    s.respondent_id,
    s.collection_period,
    s.facility_urban_rural,
    s.facility_field_avg_name,
    s.facility_region,

    -- Staff family engagement
    s.staff_response_count,
    s.staff_family_attitude_composite,
    s.staff_family_conversation_composite,

    -- Youth phone contact
    p.youth_response_count         AS youth_phone_response_count,
    p.phone_contact_frequency_composite,
    p.phone_contact_quality_composite,

    -- Youth family visits
    v.youth_response_count         AS youth_visits_response_count,
    v.youth_family_frequency_composite,
    v.youth_family_quality_composite

FROM {{ ref('int_staff_climate_family_engagement') }} AS s
LEFT JOIN {{ ref('int_youth_phone_contact') }} AS p
  ON s.respondent_id     = p.respondent_id
 AND s.collection_period = p.collection_period
LEFT JOIN {{ ref('int_youth_climate_family_engagement') }} AS v
  ON s.respondent_id     = v.respondent_id
 AND s.collection_period = v.collection_period