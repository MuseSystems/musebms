-- File:        test_data_integration_test.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_settings/testing_support/test_data_integration_test.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

--------------------------------------------------------------------------------
--  Primary Initialization -- Settings
--------------------------------------------------------------------------------

INSERT INTO ms_syst_data.syst_settings
    ( internal_name
    , display_name
    , syst_description
    , syst_defined
    , user_description
    , setting_flag )
VALUES
    ( 'delete_test_setting'
    , 'Delete Test Setting'
    , 'A system-defined setting used for testing delete functionality'
    , TRUE
    , 'A user-defined setting used for testing delete functionality'
    , TRUE );
