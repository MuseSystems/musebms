-- File:        initial_privileges.eex.sql
-- Location:    musebms/database/application/msapp_platform/mssub_mcp/privileges/initial_privileges.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

GRANT USAGE ON SCHEMA ms_syst TO <%= ms_appusr %>;

GRANT USAGE ON SCHEMA ms_appl TO <%= ms_appusr %>;
