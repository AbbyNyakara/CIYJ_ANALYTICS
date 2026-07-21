{% set survey_columns = [

    "staff_gender",
    "tenure_over_six_months",

    "staff_value_family_as_partners",
    "believes_family_improves_results",
    "training_improved_family_interaction",
    "staff_talk_youth_about_family",
    "ask_youths_about_bad_things",

    "facility_safe_for_staff",
    "staff_feared_for_safety",
    "injured_by_youth",
    "practiced_fire_drill_last_6_months",
    "can_recommend_security_changes",
    "security_policies_rating",
    "staff_follow_security_procedures",
    "staff_follow_safety_procedures_rating",
    "safety_policies_rating",
    "what_would_make_facility_safer",

    "facility_safe_or_dangerous_for_youth",
    "staff_force_only_when_needed",

    "job_satisfied",
    "supervisor_support_rating",
    "knows_job_expectations",
    "has_info_to_perform_job",
    "communications_between_areas",
    "teamwork_on_youth_treatment",
    "staff_authority_to_discipline_youth",
    "staff_authority_to_reward_youth",
    "behavior_mgmt_system_clear_to_youth_and_staff",

    "filed_grievance",
    "grievance_addressed",

    "received_training",
    "training_improved_skills",
    "suicide_prevention_training_rating",
    "prea_training_rating",
    "training_wanted_write_in",
    "training_would_like_to_see_select",
    "staff_explain_trauma_to_youth",

    "staff_good_role_models",
    "staff_care_about_residents",
    "staff_show_residents_respect",
    "staff_treats_residents_fairly",
    "staff_more_positive_comments",
    "able_to_input_youth_treatment",
    "rewards_used_to_influence_behavior",

    "programming_helps_youth_success",
    "youth_orientation_rating",
    "health_services_rating_for_youth",
    "educational_programming_rating",
    "facility_good_school_program",
    "facility_good_recreation",
    "rules_fair_to_youths",
    "food_is_good",
    "facility_is_clean",
    "everything_works_in_unit",
    "common_areas_clean",
    "youths_have_clothing_toiletries",

    "survey_was_blank"
] %}


{{ config(materialized='view') }}

WITH source AS (
    SELECT *
    FROM {{ source('ciyj_raw', 'staff_climate') }}
),

RENAMED AS (

SELECT
    -- Identifiers
    PBSSTAFFCLIMATESURVEYID                             AS staff_climate_survey_id,
    VERSIONNUMBER                                       AS version_number,
    COLLECTIONPERIOD                                    AS collection_period,
    RESPONDENTID                                        AS respondent_id,
    TRY_TO_TIMESTAMP(CREATED)                           AS created,

    -- Period
    TRY_TO_DATE(PERIODBEGIN, 'YYYY-MM-DD')             AS period_begin,
    TRY_TO_DATE(PERIODEND, 'YYYY-MM-DD')               AS period_end,

    -- Facility dimensions
    FACILITYURBANRURAL                                  AS facility_urban_rural,
    FACILITYFIELDAVERAGENAME                            AS facility_field_avg_name,
    FACILITYREGION                                      AS facility_region,

    -- Staff demographics
    STAFFGENDER                                         AS staff_gender,
    BEENFORMORETHANSIXMONTHS                            AS tenure_over_six_months,

    -- Family engagement (staff perspective)
    IVALUEFAMILYASPARTNERS                              AS staff_value_family_as_partners,
    BETTERRESULTSWHENFAMILIESINCLUDED                   AS believes_family_improves_results,
    TRAININGIMPROVEDHOWIINTERACTWITHFAMILY              AS training_improved_family_interaction,
    STAFFTALKWITHYOUTHSABOUTFAMILY                      AS staff_talk_youth_about_family,
    ASKYOUTHSABOUTIFBADTHINGSHAVEHAPPENED               AS ask_youths_about_bad_things,

    -- Safety: staff
    FACILITYFEELSSAFEORDANGEROUSFORSTAFF                AS facility_safe_for_staff,
    HAVEYOUFEAREDFORSAFETY                              AS staff_feared_for_safety,
    INJUREDBYYOUTHINLASTSIXMONTHS                       AS injured_by_youth,
    PRACTICIEDFIREDRILLINLASTSIXMONTHS                  AS practiced_fire_drill_last_6_months,
    ICANRECOMMENDCHANGESINSECURITY                      AS can_recommend_security_changes,
    RATESECURITYPOLICIES                                AS security_policies_rating,
    STAFFFOLLOWSECURITYPROCEDURES                       AS staff_follow_security_procedures,
    HOWADEQUATELYDOSTAFFFOLLOWSAFETYPROCEDURES          AS staff_follow_safety_procedures_rating,
    RATESAFETYPOLICIESATFACILITY                        AS safety_policies_rating,
    WHATWOULDMAKEFACILITYSAFER                          AS what_would_make_facility_safer,
    WHATWOULDMAKEFACILITYSAFEROTHER                     AS what_would_make_facility_safer_other,

    -- Safety: youth
    FACILITYFEELSSAFEORDANGEROUSFORYOUTH                AS facility_safe_or_dangerous_for_youth,
    STAFFUSEFORCEONLYWHENNEEDED                         AS staff_force_only_when_needed,

    -- Job satisfaction / organizational
    IAMSATISFIEDWITHMYJOB                               AS job_satisfied,
    RATESUPPORTGUIDANCEFROMSUPERVISOR                   AS supervisor_support_rating,
    IKNOWMYJOBEXPECTATIONS                              AS knows_job_expectations,
    IHAVEINFORMATIONTOPERFORMMYJOB                      AS has_info_to_perform_job,
    COMMUNICATIONSBETWEENAREAS                          AS communications_between_areas,
    FACILITYTEAMWORKONYOUTHSTREATMENT                   AS teamwork_on_youth_treatment,
    STAFFAUTHORITYTODISCIPLINEYOUTH                     AS staff_authority_to_discipline_youth,
    STAFFAUTHORITYTOREWARDYOUTH                         AS staff_authority_to_reward_youth,
    BEHAVIORMANAGEMENTSYSTEMCLEARTOSTAFFANDYOUTHS       AS behavior_mgmt_system_clear_to_youth_and_staff,

    -- Grievance
    FILEDGRIEVANCEINLASTSIXMONTHS                       AS filed_grievance,
    WASGRIEVANCEADDRESSED                               AS grievance_addressed,

    -- Training
    RECEIVEDTRAINING                                    AS received_training,
    TRAININGHASIMPROVEDJOBSKILLS                        AS training_improved_skills,
    RATETRAININGREGARDINGSUICIDEPREVENTION              AS suicide_prevention_training_rating,
    RATETRAININGREGARDINGPREA                           AS prea_training_rating,
    WHATTRAININGWOULDYOULIKETOSEEWRITEIN                AS training_wanted_write_in,
    WHATTRAININGWOULDYOULIKETOSEESELECT                 AS training_would_like_to_see_select,
    TRAININGIFOTHER                                     AS training_other,
    STAFFEXPLAINWHATTRAUMAISTOYOUTH                     AS staff_explain_trauma_to_youth,

    -- Youth treatment quality
    STAFFGOODROLEMODELS                                 AS staff_good_role_models,
    STAFFSEEMTOCAREABOUTRESIDENTS                       AS staff_care_about_residents,
    STAFFSHOWRESIDENTSRESPECT                           AS staff_show_residents_respect,
    STAFFTREATSRESIDENTSFAIRLY                          AS staff_treats_residents_fairly,
    STAFFGIVEMOREPOSITIVETHANNEGATIVECOMMENTS           AS staff_more_positive_comments,
    ABLETOPROVIDEINPUTOFYOUTHSTREATMENT                 AS able_to_input_youth_treatment,
    AREREWARDSUSEDTOINFLUENCEBEHAVIOR                   AS rewards_used_to_influence_behavior,

    -- Programming / facility quality
    PROGRAMMINGHELPSYOUTHSWITHSUCCESSSTRATEGIES         AS programming_helps_youth_success,
    RATEYOUTHORIENTATIONWHENTHEYARRIVE                  AS youth_orientation_rating,
    RATEHEALTHSERVICESYOUTHS                            AS health_services_rating_for_youth,
    RATEEDUCATIONALPROGRAMMINGFORYOUTHS                 AS educational_programming_rating,
    FACILITYHASGOODSCHOOLPROGRAM                        AS facility_good_school_program,
    FACILITYHASGOODRECREATIONALPROGRAMS                 AS facility_good_recreation,
    RULESAREFAIRTOYOUTHS                                AS rules_fair_to_youths,
    THEFOODISGOOD                                       AS food_is_good,
    FACILITYISCLEAN                                     AS facility_is_clean,
    INUNITSEVERYTHINGINWORKINGORDER                     AS everything_works_in_unit,
    COMMONAREASARECLEAN                                 AS common_areas_clean,
    YOUTHSHAVEREQUIREDCLOTHINGANDTOILETRIES             AS youths_have_clothing_toiletries,

    -- Survey admin
    TRY_TO_DATE(DATESURVEYADMINISTERED, 'YYYY-MM-DD')  AS survey_administered_date,
    WASSURVEYRETURNEDBLANK                              AS survey_was_blank

FROM source 
)

SELECT *
FROM renamed
WHERE {{ filter_sparse_rows(survey_columns, max_nulls=20) }}
