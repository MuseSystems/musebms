-- File:        test_app.01.01.002.0000MT.000.eex.sql
-- Location:    musebms/database/subsystems/mssub_mcp/testing_support/test_app/test_app.01.01.002.0000MT.000.eex.sql
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
$MIGRATION$
    BEGIN
        INSERT INTO testing.test_header
            ( test_value )
        VALUES
            ( '<%= test_app_owner %>' )
             ,
            ( '<%= test_app_access %>' );

        INSERT INTO testing.test_detail
            ( test_header_id, test_detail_value )
        SELECT
            id
          , 'A test detail value for header: ' || id
        FROM testing.test_header;
    END;
$MIGRATION$;
