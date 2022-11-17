-- File:        initialize_feature_mapping.eex.sql
-- Location:    musebms/database/application/msmcp/gen_seed_data/initialize_feature_mapping.eex.sql
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
    ( 'global_module'
    , 'Modules'
    , 'nonassignable'
    , 'Broad, top level feature grouping.'
    , TRUE
    , FALSE )
     ,
    ( 'global_kind'
    , 'Kinds'
    , 'assignable'
    , 'Identifies different kinds of mappable features such as forms, settings, or enumerations.'
    , TRUE
    , FALSE );

--------------------------------------------------------------------------------
-- 01 - Global Settings Module
--------------------------------------------------------------------------------

-- Module Definition

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
    ( 'global_settings'
    , 'Global Settings'
    , 'Global Settings'
    , ( SELECT id
        FROM msbms_syst_data.syst_feature_map_levels
        WHERE internal_name = 'global_module' )
    , NULL
    , TRUE
    , FALSE
    , TRUE
    , 'Global settings which define behaviors for the system, including across instances.'
    , 1 );

-- Kinds Definition

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
    ( 'global_settings_settings'
    , 'Global Settings/Settings'
    , 'Settings'
    , ( SELECT id
        FROM msbms_syst_data.syst_feature_map_levels
        WHERE internal_name = 'global_kind' )
    , ( SELECT id FROM msbms_syst_data.syst_feature_map WHERE internal_name = 'global_settings' )
    , TRUE
    , FALSE
    , TRUE
    , 'Global settings which define behaviors for the system, including across instances.'
    , 1 );

--------------------------------------------------------------------------------
-- 02 - Global Authentication Module
--------------------------------------------------------------------------------

-- Module Definition

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
    ( 'global_authentication'
    , 'Global Authentication'
    , 'Global Authentication'
    , ( SELECT id
        FROM msbms_syst_data.syst_feature_map_levels
        WHERE internal_name = 'global_module' )
    , NULL
    , TRUE
    , FALSE
    , TRUE
    , 'Functionality related to managing and providing global user authentication.'
    , 2 );

-- Kinds Definition

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
    ( 'global_authentication_settings'
    , 'Global Authentication/Settings'
    , 'Settings'
    , ( SELECT id
        FROM msbms_syst_data.syst_feature_map_levels
        WHERE internal_name = 'global_kind' )
    , ( SELECT id
        FROM msbms_syst_data.syst_feature_map
        WHERE internal_name = 'global_authentication' )
    , TRUE
    , FALSE
    , TRUE
    , 'Global settings which define system wide authentication behaviors.'
    , 1 )
     ,
    ( 'global_authentication_enumerations'
    , 'Global Authentication/Enumerations'
    , 'Enumerations'
    , ( SELECT id FROM msbms_syst_data.syst_feature_map_levels WHERE internal_name = 'global_kind' )
    , ( SELECT id
        FROM msbms_syst_data.syst_feature_map
        WHERE internal_name = 'global_authentication' )
    , TRUE
    , FALSE
    , TRUE
    , 'Lists of values which are available in support of global user authentication.'
    , 2 );

--------------------------------------------------------------------------------
-- 03 - Global Instance Management Module
--------------------------------------------------------------------------------

-- Module Definition

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
    ( 'global_instance_management'
    , 'Global Instance Management'
    , 'Global Instance Management'
    , ( SELECT id
        FROM msbms_syst_data.syst_feature_map_levels
        WHERE internal_name = 'global_module' )
    , NULL
    , TRUE
    , FALSE
    , TRUE
    , 'Management of individual instances from the Global context.'
    , 3 );

-- Kinds Definition

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
    ( 'global_instance_management_settings'
    , 'Global Instance Management/Settings'
    , 'Settings'
    , ( SELECT id FROM msbms_syst_data.syst_feature_map_levels WHERE internal_name = 'global_kind' )
    , ( SELECT id
        FROM msbms_syst_data.syst_feature_map
        WHERE internal_name = 'global_instance_management' )
    , TRUE
    , FALSE
    , TRUE
    , 'Settings which define behaviors for global instance management.'
    , 1 )
     ,
    ( 'global_instance_management_enumerations'
    , 'Global Instance Management/Enumerations'
    , 'Enumerations'
    , ( SELECT id FROM msbms_syst_data.syst_feature_map_levels WHERE internal_name = 'global_kind' )
    , ( SELECT id
        FROM msbms_syst_data.syst_feature_map
        WHERE internal_name = 'global_authentication' )
    , TRUE
    , FALSE
    , TRUE
    , 'Lists of values available for global instance management as applicable.'
    , 2 );
