-- models/marts/mart_family_perception_gap.sql
{{ config(materialized='table') }}

WITH combined AS (

    SELECT
        s.respondent_id,
        s.collection_period,

        s.staff_response_count,
        s.staff_family_attitude_composite,
        s.staff_family_conversation_composite,

        y.youth_response_count           AS youth_visits_response_count,
        y.youth_family_frequency_composite,
        y.youth_family_quality_composite,
        y.pct_barrier_distance,
        y.pct_barrier_transportation,
        y.pct_barrier_family_unwilling,
        y.pct_barrier_judge_prohibited,
        y.pct_barrier_no_visiting_hours,

        ph.youth_response_count          AS youth_phone_response_count,
        ph.phone_contact_frequency_composite,
        ph.phone_contact_quality_composite,

        a.average_possible_visitation_hours_per_week,
        a.has_liaison_for_families_to_administration,
        a.family_included_during_policy_reviews,
        a.visits_received

    FROM {{ ref('int_staff_climate_family_engagement') }} AS s
    LEFT JOIN {{ ref('int_youth_climate_family_engagement') }} AS y
        ON s.respondent_id     = y.respondent_id
       AND s.collection_period = y.collection_period
    LEFT JOIN {{ ref('int_youth_phone_contact') }} AS ph
        ON s.respondent_id     = ph.respondent_id
       AND s.collection_period = ph.collection_period
    LEFT JOIN {{ ref('int_admin_family_engagement') }} AS a
        ON s.respondent_id     = a.respondent_id
       AND s.collection_period = a.collection_period
)

SELECT
    respondent_id,
    collection_period,

    staff_response_count,
    youth_visits_response_count,
    youth_phone_response_count,

    staff_family_attitude_composite,
    staff_family_conversation_composite,

    youth_family_frequency_composite,
    youth_family_quality_composite,
    phone_contact_frequency_composite,
    phone_contact_quality_composite,

    pct_barrier_distance,
    pct_barrier_transportation,
    pct_barrier_family_unwilling,
    pct_barrier_judge_prohibited,
    pct_barrier_no_visiting_hours,

    average_possible_visitation_hours_per_week,
    has_liaison_for_families_to_administration,
    family_included_during_policy_reviews,
    visits_received,

    -- Gap 1: staff attitude vs youth-reported visit relational quality
    staff_family_attitude_composite - youth_family_quality_composite
        AS attitude_vs_youth_quality_gap,

    -- Gap 2: staff conversation behavior vs youth-reported visit frequency
    staff_family_conversation_composite - youth_family_frequency_composite
        AS conversation_vs_youth_frequency_gap,

    -- Gap 3 (NEW): staff conversation behavior vs youth-reported phone contact quality
    staff_family_conversation_composite - phone_contact_quality_composite
        AS conversation_vs_youth_phone_quality_gap,

    -- Gap 4: formal structural readiness (liaison + policy inclusion, visitation-only) vs youth-reported visit quality
    (
        (has_liaison_for_families_to_administration + family_included_during_policy_reviews) / 2.0
    ) - youth_family_quality_composite
        AS structural_vs_youth_quality_gap,

    -- Alignment flags
    CASE
        WHEN (staff_family_attitude_composite - youth_family_quality_composite) > 0.25 THEN 'Staff overestimates'
        WHEN (staff_family_attitude_composite - youth_family_quality_composite) < -0.25 THEN 'Youth overestimates'
        ELSE 'Aligned'
    END AS attitude_alignment_flag,

    CASE
        WHEN (staff_family_conversation_composite - youth_family_frequency_composite) > 0.25 THEN 'Staff overestimates'
        WHEN (staff_family_conversation_composite - youth_family_frequency_composite) < -0.25 THEN 'Youth overestimates'
        ELSE 'Aligned'
    END AS conversation_alignment_flag,

    CASE
        WHEN (staff_family_conversation_composite - phone_contact_quality_composite) > 0.25 THEN 'Staff overestimates'
        WHEN (staff_family_conversation_composite - phone_contact_quality_composite) < -0.25 THEN 'Youth overestimates'
        ELSE 'Aligned'
    END AS phone_alignment_flag,

    CASE
        WHEN (
            (has_liaison_for_families_to_administration + family_included_during_policy_reviews) / 2.0
        ) - youth_family_quality_composite > 0.25 THEN 'Policy overstates'
        WHEN (
            (has_liaison_for_families_to_administration + family_included_during_policy_reviews) / 2.0
        ) - youth_family_quality_composite < -0.25 THEN 'Youth exceeds policy'
        ELSE 'Aligned'
    END AS structural_alignment_flag

FROM combined
WHERE staff_response_count >= 3
  AND youth_visits_response_count >= 3