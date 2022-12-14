-- File:        applications.eex.sql
-- Location:    musebms/database/application/msapp_platform/mssub_mcp/seed_data/applications.eex.sql
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
$INIT_PLATFORM_APPLICATIONS$
    DECLARE
        var_mssub_bms_app_id uuid;

    BEGIN

        ----------------------------------------------------------------------------------------------------------------
        --
        -- MS-BMS Application Initialization
        --
        ----------------------------------------------------------------------------------------------------------------

        INSERT INTO ms_syst_data.syst_applications
            ( internal_name, display_name, syst_description )
        VALUES
            ( 'msbms', 'Muse Systems Business Management System'
            , 'A general purpose, whole business management system.' )
        RETURNING id INTO var_mssub_bms_app_id;

        INSERT INTO ms_syst_data.syst_application_contexts
            ( internal_name
            , display_name
            , application_id
            , description
            , start_context
            , login_context
            , database_owner_context )
        VALUES
            ( 'msbms_owner'
            , 'MS-BMS Datastore Owner Role'
            , var_mssub_bms_app_id
            , 'Ownership and privileged access for Muse Systems Business Management System databases.'
            , FALSE
            , FALSE
            , TRUE )

          ,
            ( 'msbms_app'
            , 'MS-BMS Application Access Role'
            , var_mssub_bms_app_id
            , 'Regular interactive user session access for Muse Systems Business Management System databases.'
            , TRUE
            , TRUE
            , FALSE );
    END ;
$INIT_PLATFORM_APPLICATIONS$;
