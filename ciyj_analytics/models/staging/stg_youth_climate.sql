{{ config(materialized = 'view')}}

-- models/staging/stg_youth_climate.sql
{{ config(materialized='view') }}

WITH source AS (
    SELECT *
    FROM {{ source('ciyj_raw', 'youth_climate') }}
)

SELECT
    -- Identifiers
    PBSYOUTHCLIMATESURVEYID                         AS youth_climate_survey_id,
    VERSIONNUMBER                                   AS version_number,
    COLLECTIONPERIOD                                AS collection_period,
    RESPONDENTID                                    AS respondent_id,
    TRY_TO_TIMESTAMP(CREATED)                       AS created_at,
    PBSFORMID                                       AS pbs_form_id,

    -- Period
    TRY_TO_DATE(PERIODBEGIN, 'YYYY-MM-DD')         AS period_begin,
    TRY_TO_DATE(PERIODEND, 'YYYY-MM-DD')           AS period_end,

    -- Facility dimensions
    FACILITYURBANRURAL                              AS facility_urban_rural,
    FACILITYFIELDAVERAGENAME                        AS facility_field_average_name,
    FACILITYREGION                                  AS facility_region,

    -- Youth demographics
    YOUTHGENDER                                     AS youth_gender,

    -- Physical activity
    WEEKEND2HOURSPHYSICALEXERCISEPERDAY             AS weekend_2hrs_physical_exercise,
    GET1HOURPHYSICALACTIVITYONWEEKDAYS              AS weekday_1hr_physical_activity,

    -- Education
    ATTENDINGSCHOOLSINCEHERE                        AS attending_school,
    HOWHELPFULHASSCHOOLBEEN                         AS school_helpful_rating,
    FACILITYHASGOODSCHOOLPROGRAM                    AS facility_has_good_school_program,

    -- Medical
    RECIEVEDMEDICALCARESINCEHERE                    AS received_medical_care,
    HOWHELPFULWASMEDICALCARE                        AS medical_care_helpful_rating,

    -- Treatment plan
    HAVETREATMENTORSERVICEPLAN                      AS has_treatment_or_service_plan,
    INVOLVEDWITHTREATMENTPLAN                       AS involved_in_treatment_plan,
    TREATMENTPLANSUPPORTSMYGOALS                    AS treatment_plan_supports_goals,
    PROGRAMMINGHELPSMEUNDERSTAND                    AS programming_helps_understand,

    -- Phase / behavior system
    PHASESYSTEMFORREWARDS                           AS phase_system_for_rewards,
    IUNDERSTANDTHEPHASESYSTEM                       AS understands_phase_system,
    IKNOWWHATPHASEIAMON                             AS knows_current_phase,
    PHASELEVEL                                      AS phase_level,

    -- Family engagement: phone contact
    TALKEDWITHPARENTPHONE                           AS talked_with_parent_phone,
    HOWOFTENTALKPARENTPHONE                         AS parent_phone_frequency,
    HOWFAIRARESTAFFPHONECALLS                       AS staff_phone_calls_fair,
    PHONECALLSWITHCHILDRENFREQ                      AS parents_phone_calls_with_children_freq,
    TALKEDONPHONEWITHCHILDREN                       AS talked_on_phone_with_children,

    -- Family engagement: visits
    VISITSFROMFAMILY                                AS visits_from_family,
    HOWOFTENVISITSWITHFAMILY                        AS family_visit_frequency,
    WHYNOVISITSWITHFAMILY                           AS why_no_visit_reason, -- null column 
    VISITSFROMCHILDRENFREQ                          AS visits_from_children_freq,
    RECIEVEDVISITSFROMCHILDREN                      AS received_visits_from_children,
    NOVISISTSFROMCHILDRENWHYNOT                     AS no_visits_from_children_reason,
    IDONOTWANTTOVISITFAMILY                         AS youth_does_not_want_visit,
    IHAVENOFAMILY                                   AS has_no_family,

    -- Family engagement: quality / barriers
    FAMILYANDSTAFFGETALONG                          AS family_staff_get_along,
    FAMILYFEELSWELCOMED                             AS family_feels_welcomed,
    FAMILYLIVESTOOFAR                               AS barrier_distance,
    FAMILYDOESNOTHAVETRANSPORTATION                 AS barrier_transportation,
    FAMILYDOESNOTWANTTOVISIT                        AS barrier_family_unwilling,
    FAMILYREGULARLYTALKSTOSTAFF                     AS family_regularly_talks_to_staff,
    JUDGEPROHIBITEDVISITS                           AS judge_prohibited_visits,
    NOVISITINGHOURS                                 AS no_visiting_hours,
    VISITINGHOURSBADFORFAMILY                       AS visiting_hours_bad_for_family,
    HAVECHILDREN                                    AS youth_has_children,

    -- Safety: victimization
    FEAREDFORSAFTEYINLASTSIXMONTHS                  AS feared_for_safety_last_6_months,
    BEATENUPINLASTSIXMONTHS                         AS been_beaten_up_last_6_months,
    PROPERTYSTOLENINLASTSIXMONTHS                   AS property_stolen_last_6_months,
    FORCEDSEXUALACTIVITYINLASTSIXMONTHS             AS forced_sexual_activity,
    HOWOFTEN                                        AS victimization_how_often, --check this
    WHODIDTHIS                                      AS victimization_who, -- check this again
    WASINCIDENTREPORTED                             AS victimization_reported, -- check this whether it relates to SA or any form of victimization
    ACTIONSTOSTOPREOCCURANCE                        AS actions_to_stop_reoccurrence,
    INJURIESBEYONDSEXUALASSAULT                     AS injuries_beyond_sexual_assault,
    WHATINJURIESSUFFERED                            AS injuries_suffered,
    RECEIVEDMEDICALCAREASARESULT                    AS received_medical_care_for_injury,
    WHEREITTOOKPLACE                                AS victimization_location,

    -- Safety: behavior
    INVOVEDINFIGHTS                                 AS involved_in_fights,
    LOCKEDUPFORMISBEHAVIOR                          AS locked_up_for_misbehavior,
    LONGESTTIMELOCKEDUPALONE                        AS longest_time_locked_up_alone,
    KNOWPROCEDUREIFFIRE                             AS knows_fire_procedure,

    -- Facility environment
    FACILITYISCLEAN                                 AS facility_is_clean,
    FOODISGOOD                                      AS food_is_good,
    FACILITYHASGOODRECREATIONPROGRAMS               AS facility_good_recreation,
    THERULESAREFAIR                                 AS rules_are_fair,
    EVERYTHINGWORKSINUNIT                           AS everything_works_in_unit,
    IHAVECLOTHINGANDTOILETRIES                      AS has_clothing_and_toiletries,
    COMMONAREASARECLEAN                             AS common_areas_clean,
    KNOWHOWTOFINDHELP                               AS knows_how_to_find_help,

    -- Staff quality
    STAFFSHOWRESPECT                                AS staff_show_respect,
    STAFFSHOWRESPECTFREQ                            AS staff_respect_frequency,
    STAFFAREGOODROLEMODELS                          AS staff_good_role_models,
    STAFFSEEMTOCARE                                 AS staff_seem_to_care,
    STAFFONLYUSESFORCEWHENNEEDED                    AS staff_use_force_only_when_needed,
    STAFFMAKESMOREPOSITIVECOMMENTS                  AS staff_more_positive_comments,
    STAFFFAIRABOUTDISCIPLINE                        AS staff_fair_discipline,
    STAFFFOLLOWSTHROUGH                             AS staff_follows_through,
    STAFFLETYOUMAKECHOICES                          AS staff_let_make_choices,
    STAFFHELPCALM                                   AS staff_help_calm,
    TRUSTSTAFFATTHEFACILITY                         AS trust_staff,
    CONSISTENTANSWERS                               AS consistent_answers_from_staff,
    PRIVATECONVERSATIONSNOTOVERHEARD                AS private_conversations_not_overheard,

    -- Staff /  communication
    STAFFDISCUSSEDFACILITYRULES                     AS staff_discussed_rules,
    STAFFAREINTERESTEDINWHATISAY                    AS staff_interested_in_youth_views,
    STAFFLISTENSTOSUGGESTIONS                       AS staff_listens_to_youth_suggestions,
    STAFFAREINITERESTEDINWHATFAMILYSAYS             AS staff_interested_in_family_views,
    STAFFRESPECTSMYCULTURE                          AS staff_respects_youth_culture,
    ASKEDIFBADTHINGSHAPPENEDTOYOU                   AS staff_asked_about_bad_things,
    ASKEDHOWFAMILYHELPSYOU                          AS staff_asked_about_family_support,
    FACILITYEXPLAINEDTRAMA                          AS facility_explained_trauma,

    -- Legal rights / lawyer access
    HAVEALAWYER                                     AS has_lawyer,
    HAVEYOUASKEDTOSEELAWYER                         AS asked_to_see_lawyer,
    ALLOWEDTOSEELAWYER                              AS allowed_to_see_lawyer,
    ASKEDTOCALLLAWYER                               AS asked_to_call_lawyer,
    ALLOWEDTOCALLLAWYER                             AS allowed_to_call_lawyer,
    ASKEDTOWRITETOLAWYER                            AS asked_to_write_lawyer,
    ALLOWEDTOWRITETOLAWYER                          AS allowed_to_write_lawyer,
    WRITTENCOPYOFLEGALRIGHTS                        AS written_copy_legal_rights,
    STAFFMEMBERDISCUSSESLEGALRIGHTS                 AS staff_discusses_legal_rights,
    UNDERSTANDLEGALRIGHTS                           AS understands_legal_rights,

    -- Rules understanding
    WRITTENCOPYOFRULES                              AS written_copy_of_rules,
    UNDERSTANDFACILITYRULES                         AS understands_facility_rules,
    DONOTUNDERSTANDRULESBECAUSE                     AS does_not_understand_rules_reason,

    -- Grievance
    IKNOWHOWTOFILEAGRIEVENCE                        AS knows_grievance_process,
    NOTHINGBADWILLHAPPENFORFILINGGRIEVENCE          AS no_retaliation_for_grievance,
    FILEDGRIEVENCEINLASTSIXMONTHS                   AS filed_grievance_last_6_months,
    GRIEVENCEADDRESSEDINLASTSIXMONTHS               AS grievance_addressed,
    WHOWILLYOUCONTACTWITHPROBLEMS                   AS who_to_contact_with_problems,

    -- Survey admin
    SURVEYADMINISTRATED                             AS survey_administered,
    SURVEYWASBLANK                                  AS survey_was_blank

FROM source



