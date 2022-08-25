-- File:        test_data_integration_test.eex.sql
-- Location:    musebms/database/components/system/msbms_syst_instance_mgr/testing_support/test_data_integration_test.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

DO
$INSTANCE_MGR_TESTING_INIT$
BEGIN

    --
    --  Applications
    --

    INSERT INTO msbms_syst_data.syst_applications
        ( internal_name, display_name, syst_description )
    VALUES
        ( 'app2', 'App 2', 'App Two Description' )
         ,
        ( 'app1', 'App 1', 'App One Description' );

    --
    -- Application Contexts
    --

    INSERT INTO msbms_syst_data.syst_application_contexts
        ( internal_name
        , display_name
        , application_id
        , description
        , start_context
        , login_context
        , database_owner_context )
    VALUES
        ( 'app1_owner'
        , 'App 1 Owner'
        , ( SELECT id
            FROM msbms_syst_data.syst_applications
            WHERE internal_name = 'app1' )
        , 'App 1 Owner'
        , FALSE
        , FALSE
        , TRUE )

         ,
        ( 'app1_appusr'
        , 'App 1 AppUsr'
        , ( SELECT id
            FROM msbms_syst_data.syst_applications
            WHERE internal_name = 'app1' )
        , 'App 1 AppUsr'
        , TRUE
        , TRUE
        , FALSE )

         ,
        ( 'app1_apiusr'
        , 'App 1 ApiUsr'
        , ( SELECT id
            FROM msbms_syst_data.syst_applications
            WHERE internal_name = 'app1' )
        , 'App 1 API user Context'
        , TRUE
        , TRUE
        , FALSE )

         ,
        ( 'app2_owner'
        , 'App 2 Owner'
        , ( SELECT id
            FROM msbms_syst_data.syst_applications
            WHERE internal_name = 'app2' )
        , 'App 2 Owner'
        , FALSE
        , FALSE
        , TRUE )

         ,
        ( 'app2_appusr'
        , 'App 2 AppUsr'
        , ( SELECT id
            FROM msbms_syst_data.syst_applications
            WHERE internal_name = 'app2' )
        , 'App 2 App'
        , TRUE
        , TRUE
        , FALSE )

         ,
        ( 'app2_apiusr'
        , 'App 2 ApiUsr'
        , ( SELECT id
            FROM msbms_syst_data.syst_applications
            WHERE internal_name = 'app2' )
        , 'App 2 API'
        , TRUE
        , TRUE
        , FALSE );

END;
$INSTANCE_MGR_TESTING_INIT$;
