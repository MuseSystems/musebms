-- File:        app1.01.01.002.0000MT.000.eex.sql
-- Location:    musebms/database/cmp_msbms_syst_instance_mgr/testing_support/app1/app1.01.01.002.0000MT.000.eex.sql
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
$MIGRATION$
    BEGIN
        INSERT INTO testing.test_header
            ( test_value )
        VALUES
            ( '<%= app1_owner %>' )
             ,
            ( '<%= app1_appusr %>' )
             ,
            ( '<%= app1_apiusr %>' );

        INSERT INTO testing.test_detail
            ( test_header_id, test_detail_value )
        SELECT
            id
          , 'A test detail value for header: ' || id
        FROM testing.test_header;
    END;
$MIGRATION$;
