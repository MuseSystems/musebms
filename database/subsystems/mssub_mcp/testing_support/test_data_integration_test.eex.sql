-- File:        test_data_integration_test.eex.sql
-- Location:    musebms/database/subsystems/mssub_mcp/testing_support/test_data_integration_test.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

DO
$MCP_TESTING_INIT$
    DECLARE
        var_application_id uuid;

    BEGIN

        -- The testing data below is not user maintainable and would be created
        -- by a business logic sub-system, such as mssub_bms.  As such we need
        -- to create this prior to running integration tests.

        INSERT INTO ms_syst_data.syst_applications
            ( internal_name, display_name, syst_description )
        VALUES
            ( 'test_app'
            , 'Testing Application'
            , 'A hypothetical application used for testing purposes.' )
        RETURNING id INTO var_application_id;

        INSERT INTO ms_syst_data.syst_application_contexts
            ( internal_name
            , display_name
            , application_id
            , description
            , start_context
            , login_context
            , database_owner_context )
        VALUES
            ( 'test_app_owner'
            , 'Testing Application Owner Role'
            , var_application_id
            , 'The Database Owner Context for the Testing Application.'
            , FALSE
            , FALSE
            , TRUE )
             ,
            ( 'test_app_access'
            , 'Testing Application Access Role'
            , var_application_id
            , 'The Database Access Role Context for the Testing Application.'
            , TRUE
            , TRUE
            , FALSE );

    END;

$MCP_TESTING_INIT$;
