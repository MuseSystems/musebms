-- File:        privileges.eex.sql
-- Location:    musebms/database/subsystems/mssub_mcp/components/mscmp_syst_features/privileges.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

--
-- MscmpSystFeatures
--

-- syst_access_accounts

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_feature_setting_assigns TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_feature_setting_assigns() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_feature_setting_assigns() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_feature_setting_assigns() TO <%= ms_appusr %>;
