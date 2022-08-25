-- File:        initialize_feature_mapping.eex.sql
-- Location:    musebms/database/application/msbms_instance/gen_seed_data/initialize_feature_mapping.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

INSERT INTO msbms_syst_data.syst_feature_map_levels
    ( internal_name
    , display_name
    , functional_type
    , syst_description
    , system_defined
    , user_maintainable )
VALUES
    ( 'instance_module'
    , 'Modules'
    , 'nonassignable'
    , 'Groupings of features delineated into broad areas of business concern. ' ||
      '(e.g. Accounting, Business Relationship Management, etc.)'
    , TRUE
    , FALSE )
     ,
    ( 'instance_feature'
    , 'Features'
    , 'nonassignable'
    , 'Specific feature areas with a Module. (e.g. Sales Ordering, Purchasing, etc.)'
    , TRUE
    , FALSE )
     ,
    ( 'instance_information_type'
    , 'Information Type'
    , 'nonassignable'
    , 'Division of features into information types. (e.g. Master Data, Booking Transactions, etc.)'
    , TRUE
    , FALSE )
     ,
    ( 'instance_kind'
    , 'Kinds'
    , 'assignable'
    , 'Identifies different kinds of mappable features such as forms, settings, or enumerations.'
    , TRUE
    , FALSE );


-- The feature mapping as currently envisioned will create a hierarchy
-- structured Module -> Type -> Feature -> Kind.  Both the defining JSON
-- assigned to var_feature_mappings and the logic are assuming this structure to
-- be true.  If a different structure is desired, naturally either the JSON, the
-- insert logic, or both will need to be changed.

DO
$INITIALIZE_FEATURE_MAPPING$
    DECLARE
        var_root_internal_name text  := 'instance';
        var_root_display_name  text  := 'Instance';
        var_curr_module        jsonb;
        var_new_module         msbms_syst_data.syst_feature_map;
        var_curr_type          jsonb;
        var_new_type           msbms_syst_data.syst_feature_map;
        var_curr_feature       jsonb;
        var_new_feature        msbms_syst_data.syst_feature_map;
        var_curr_kind          jsonb;

        var_feature_mappings   jsonb := $FEATURE_MAP$
{
  "modules": [
    {
      "module_name": "System Administration",
      "module_display_name": "System Admin",
      "module_internal_name": "sysadmin",
      "module_description": "Functionality related to managing and providing global user authorization and instance wide systems auditing.",
      "module_map_level": "instance_module",
      "features": [
        {
          "feature_name": "User Authorization",
          "feature_display_name": "Authorization",
          "feature_internal_name": "authorization",
          "feature_description": "Functionality related to granting users access and managing associations to globally defined users.",
          "feature_map_level": "instance_feature",
          "feature_include_in": [
            "master",
            "maintenance"
          ]
        },
        {
          "feature_name": "System Auditing",
          "feature_display_name": "Auditing",
          "feature_internal_name": "auditing",
          "feature_description": "Systems usage auditing.",
          "feature_map_level": "instance_feature",
          "feature_include_in": [
            "maintenance"
          ]
        }
      ]
    },
    {
      "module_name": "Business Relationship Management",
      "module_display_name": "BRM",
      "module_internal_name": "brm",
      "module_description": "Functionality for managing business entities, people, and places.",
      "module_map_level": "instance_module",
      "features": [
        {
          "feature_name": "Entities",
          "feature_display_name": "Entities",
          "feature_internal_name": "entities",
          "feature_description": "Legal business entities with with whom business is conducted.",
          "feature_map_level": "instance_feature",
          "feature_include_in": [
            "master"
          ]
        },
        {
          "feature_name": "Places",
          "feature_display_name": "Places",
          "feature_internal_name": "places",
          "feature_description": "Physical locations where business entities conduct business.",
          "feature_map_level": "instance_feature",
          "feature_include_in": [
            "master"
          ]
        },
        {
          "feature_name": "People",
          "feature_display_name": "People",
          "feature_internal_name": "people",
          "feature_description": "People associated with business entities.",
          "feature_map_level": "instance_feature",
          "feature_include_in": [
            "master"
          ]
        },
        {
          "feature_name": "Contacts",
          "feature_display_name": "Contacts",
          "feature_internal_name": "contacts",
          "feature_description": "The means to contact specific people or business entities generically.",
          "feature_map_level": "instance_feature",
          "feature_include_in": [
            "supporting"
          ]
        },
        {
          "feature_name": "Countries",
          "feature_display_name": "Countries",
          "feature_internal_name": "countries",
          "feature_description": "Definitions of countries and related metadata.",
          "feature_map_level": "instance_feature",
          "feature_include_in": [
            "supporting"
          ]
        }

      ]
    },
    {
      "module_name": "Accounting",
      "module_display_name": "Accounting",
      "module_internal_name": "accounting",
      "module_description": "Functionality for running general ledger operations.",
      "module_map_level": "instance_module",
      "features": [
        {
          "feature_name": "Fiscal Calendar",
          "feature_display_name": "Fiscal Calendar",
          "feature_internal_name": "fiscal_calendar",
          "feature_description": "The means to contact specific people or business entities generically.",
          "feature_map_level": "instance_feature",
          "feature_include_in": [
            "supporting"
          ]
        },
        {
          "feature_name": "Chart of Accounts",
          "feature_display_name": "Chart of Accounts",
          "feature_internal_name": "gl_accounts",
          "feature_description": "The chart of general ledger accounts.",
          "feature_map_level": "instance_feature",
          "feature_include_in": [
            "master"
          ]
        },
        {
          "feature_name": "General Ledger",
          "feature_display_name": "General Ledger",
          "feature_internal_name": "accounting_ledger",
          "feature_description": "A general ledger of accounting transactions.  Note that in reality this will ultimately contain both booking and non-booking transactions, but expectations would align this feature as a ledger of booking transactions.",
          "feature_map_level": "instance_feature",
          "feature_include_in": [
            "booking"
          ]
        }
      ]
    }
  ],
  "information_types": [
    {
      "type_name": "Master Data",
      "type_display_name": "Master",
      "type_internal_name": "master",
      "type_description": "Qualitative information which describes the current state of a subject.  (e.g. entity, item)",
      "type_map_level": "instance_information_type"
    },
    {
      "type_name": "Supporting Data",
      "type_display_name": "Supporting",
      "type_internal_name": "supporting",
      "type_description": "'Qualitative information which enhances or provides more complex descriptions of more fundamental master data.'",
      "type_map_level":  "instance_information_type"
    },
    {
      "type_name": "Non-booking Transaction",
      "type_display_name": "Non-booking",
      "type_internal_name": "nonbooking",
      "type_description": "Finite duration events which express an intention/direction to act and often express contractual terms involving third-parties.  These transactions do not have direct accounting requirements, but will usually lead to transactions with direct accounting requirements. (e.g. purchase orders, sales orders)",
      "type_map_level":  "instance_information_type"
    },
    {
      "type_name": "Booking Transaction",
      "type_display_name": "Booking",
      "type_internal_name": "booking",
      "type_description": "Finite duration events which express a concrete action, often taken in conjunction with third-parties.  These transactions do have direct accounting requirements and are often related to non-booking transactions that originally direct the action to be taken.  (e.g. purchase receipts, customer invoices)",
      "type_map_level":  "instance_information_type"
    },
    {
      "type_name": "Activity Transaction",
      "type_display_name": "Activity",
      "type_internal_name": "activity",
      "type_description": "Finite duration events which express specific actions or tasks by staff (or their automated proxies) requiring tracking of time, communications, and/or outcomes. Activities may lead to either non-booking or booking transactions.",
      "type_map_level":  "instance_information_type"
    },
    {
      "type_name": "Maintenance",
      "type_display_name": "Maintenance",
      "type_internal_name": "maintenance",
      "type_description": "Systematic job and batch processing support.",
      "type_map_level":  "instance_information_type"
    }
  ],
  "kinds": [
    {
      "kind_name": "Settings",
      "kind_display_name": "Settings",
      "kind_internal_name": "settings",
      "kind_description": "Configurable values which determine application behaviors, assign defaults, or assign constant values.",
      "kind_map_level":"instance_kind"
    },
    {
      "kind_name": "Numbering",
      "kind_display_name": "Numbering",
      "kind_internal_name": "numbering",
      "kind_description": "Provides master data record and transaction numbering and allows configuration of numbering formats and rules.",
      "kind_map_level": "instance_kind"
    },
    {
      "kind_name": "Enumerations",
      "kind_display_name": "Enumerations",
      "kind_internal_name": "enumerations",
      "kind_description": "Lists of values used in fixed answer contexts such as forms and record life-cycle management.",
      "kind_map_level": "instance_kind"
    },
    {
      "kind_name": "Formats",
      "kind_display_name": "Formats",
      "kind_internal_name": "formats",
      "kind_description": "Data definition and related user presentation descriptions for specialized multi-field data types.  (e.g. addresses, phone numbers)",
      "kind_map_level": "instance_kind"
    },
    {
      "kind_name": "Jobs",
      "kind_display_name": "Jobs",
      "kind_internal_name": "jobs",
      "kind_description": "Automated Job and Batch processing.",
      "kind_map_level": "instance_kind"
    },
    {
      "kind_name": "Forms",
      "kind_display_name": "Forms",
      "kind_internal_name": "forms",
      "kind_description": "User interface data and layout definition.",
      "kind_map_level": "instance_kind"
    },
    {
      "kind_name": "Database Tables",
      "kind_display_name": "Relations",
      "kind_internal_name": "relations",
      "kind_description": "Associates certain database tables and similar structures for custom field management and documentation purposes.",
      "kind_map_level": "instance_kind"
    }
  ]
}
        $FEATURE_MAP$::jsonb;

    BEGIN

        <<module_loop>>
        FOR var_curr_module IN
            SELECT jsonb_array_elements( var_feature_mappings -> 'modules' )
        LOOP

                INSERT INTO msbms_syst_data.syst_feature_map
                    ( internal_name
                    , display_name
                    , external_name
                    , feature_map_level_id
                    , parent_feature_map_id
                    , system_defined
                    , user_maintainable
                    , displayable
                    , syst_description
                    , sort_order )
                VALUES
                    (
                      var_root_internal_name || '_' || ( var_curr_module ->> 'module_internal_name' )
                    , var_root_display_name || ' / ' || ( var_curr_module ->> 'module_display_name' )
                    , var_curr_module ->> 'module_name'
                    , ( SELECT id
                        FROM msbms_syst_data.syst_feature_map_levels
                        WHERE internal_name = (var_curr_module ->> 'module_map_level') )
                    , NULL
                    , TRUE
                    , FALSE
                    , TRUE
                    , var_curr_module ->> 'module_description'
                    , coalesce(
                        ( SELECT max( sort_order ) + 1
                          FROM msbms_syst_data.syst_feature_map fm
                              JOIN msbms_syst_data.syst_feature_map_levels fml
                                  ON fml.id = fm.feature_map_level_id
                          WHERE fml.internal_name = (var_curr_module ->> 'module_map_level') )
                        , 1 ) )
                RETURNING * INTO var_new_module;

                <<information_type_loop>>
                FOR var_curr_type IN
                    SELECT jsonb_array_elements( var_feature_mappings -> 'information_types' )
                LOOP

                    INSERT INTO msbms_syst_data.syst_feature_map
                        ( internal_name
                        , display_name
                        , external_name
                        , feature_map_level_id
                        , parent_feature_map_id
                        , system_defined
                        , user_maintainable
                        , displayable
                        , syst_description
                        , sort_order )
                    VALUES
                        (
                          var_new_module.internal_name || '_' || ( var_curr_type ->> 'type_internal_name' )
                        , var_new_module.display_name || ' / ' || ( var_curr_type ->> 'type_display_name' )
                        , var_curr_type ->> 'type_name'
                        , ( SELECT id
                            FROM msbms_syst_data.syst_feature_map_levels
                            WHERE internal_name = (var_curr_type ->> 'type_map_level') )
                        , var_new_module.id
                        , TRUE
                        , FALSE
                        , TRUE
                        , var_curr_type ->> 'type_description'
                        , coalesce(
                            ( SELECT max( sort_order ) + 1
                              FROM msbms_syst_data.syst_feature_map fm
                                  JOIN msbms_syst_data.syst_feature_map_levels fml
                                      ON fml.id = fm.feature_map_level_id
                              WHERE fm.parent_feature_map_id = var_new_module.id)
                            , 1 ) )
                    RETURNING * INTO var_new_type;

                    <<feature_loop>>
                    FOR var_curr_feature IN
                        SELECT jsonb_array_elements( var_curr_module -> 'features' )
                    LOOP

                        IF
                            ( var_curr_feature -> 'feature_include_in' ) ?
                                (var_curr_type ->> 'type_internal_name')
                        THEN

                            INSERT INTO msbms_syst_data.syst_feature_map
                                ( internal_name
                                , display_name
                                , external_name
                                , feature_map_level_id
                                , parent_feature_map_id
                                , system_defined
                                , user_maintainable
                                , displayable
                                , syst_description
                                , sort_order )
                            VALUES
                                (
                                  var_new_type.internal_name || '_' ||
                                    ( var_curr_feature ->> 'feature_internal_name' )
                                , var_new_type.display_name || ' / ' ||
                                    ( var_curr_feature ->> 'feature_display_name' )
                                , var_curr_feature ->> 'feature_name'
                                , ( SELECT id
                                    FROM msbms_syst_data.syst_feature_map_levels
                                    WHERE internal_name = (var_curr_feature ->> 'feature_map_level') )
                                , var_new_type.id
                                , TRUE
                                , FALSE
                                , TRUE
                                , var_curr_feature ->> 'feature_description'
                                , coalesce(
                                    ( SELECT max( sort_order ) + 1
                                      FROM msbms_syst_data.syst_feature_map fm
                                          JOIN msbms_syst_data.syst_feature_map_levels fml
                                              ON fml.id = fm.feature_map_level_id
                                      WHERE fm.parent_feature_map_id = var_new_type.id)
                                    , 1 ) )
                            RETURNING * INTO var_new_feature;

                            <<kind_loop>>
                            FOR var_curr_kind IN
                                SELECT jsonb_array_elements( var_feature_mappings -> 'kinds' )
                            LOOP

                                INSERT INTO msbms_syst_data.syst_feature_map
                                ( internal_name
                                , display_name
                                , external_name
                                , feature_map_level_id
                                , parent_feature_map_id
                                , system_defined
                                , user_maintainable
                                , displayable
                                , syst_description
                                , sort_order )
                            VALUES
                                (
                                  var_new_feature.internal_name || '_' ||
                                    ( var_curr_kind ->> 'kind_internal_name' )
                                , var_new_feature.display_name || ' / ' ||
                                    ( var_curr_kind ->> 'kind_display_name' )
                                , var_curr_kind ->> 'kind_name'
                                , ( SELECT id
                                    FROM msbms_syst_data.syst_feature_map_levels
                                    WHERE internal_name = (var_curr_kind ->> 'kind_map_level') )
                                , var_new_feature.id
                                , TRUE
                                , FALSE
                                , TRUE
                                , var_curr_kind ->> 'kind_description'
                                , coalesce(
                                    ( SELECT max( sort_order ) + 1
                                      FROM msbms_syst_data.syst_feature_map fm
                                          JOIN msbms_syst_data.syst_feature_map_levels fml
                                              ON fml.id = fm.feature_map_level_id
                                      WHERE fm.parent_feature_map_id = var_new_feature.id)
                                    , 1 ) );

                            END LOOP kind_loop;

                        END IF;

                    END LOOP feature_loop;

                END LOOP information_type_loop;

            END LOOP module_loop;
    END;
$INITIALIZE_FEATURE_MAPPING$;
