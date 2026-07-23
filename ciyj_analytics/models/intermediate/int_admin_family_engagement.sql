with int_admin_family_engagement AS (

    SELECT
        collection_period,
        respondent_id,
        facility_field_average_name,
        average_possible_visitation_hours_per_week,
        CASE WHEN has_liaison_for_families_to_administration = 'Yes' THEN 1 ELSE 0 END AS has_liaison_for_families_to_administration,
        CASE WHEN family_included_during_policy_reviews = 'Yes' THEN 1 ELSE 0 END AS family_included_during_policy_reviews,
        visits_received
    FROM {{ ref('stg_admin_form') }}
)

SELECT *
FROM int_admin_family_engagement