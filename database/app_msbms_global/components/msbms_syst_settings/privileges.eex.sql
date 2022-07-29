-- File:        privileges.eex.sql
-- Location:    musebms/database/app_msbms_global/components/msbms_syst_settings/privileges.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE msbms_syst.syst_settings TO <%= msbms_appusr %>;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE msbms_syst.syst_settings TO <%= msbms_apiusr %>;

GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_i_syst_settings() TO <%= msbms_appusr %>;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_i_syst_settings() TO <%= msbms_apiusr %>;

GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_settings() TO <%= msbms_appusr %>;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_settings() TO <%= msbms_apiusr %>;

GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_d_syst_settings() TO <%= msbms_appusr %>;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_d_syst_settings() TO <%= msbms_apiusr %>;
