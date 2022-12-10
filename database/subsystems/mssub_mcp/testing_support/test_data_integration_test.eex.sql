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
    BEGIN

        RAISE NOTICE 'There is no special mssub_mcp integration testing data.';

    END;
$MCP_TESTING_INIT$;
