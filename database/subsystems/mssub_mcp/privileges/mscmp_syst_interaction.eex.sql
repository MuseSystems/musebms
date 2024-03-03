-- File:        mscmp_syst_interaction.eex.sql
-- Location:    musebms/database/subsystems/mssub_mcp/privileges/mscmp_syst_interaction.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

-- syst_interaction_contexts

GRANT SELECT, UPDATE ON TABLE ms_syst.syst_interaction_contexts TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_interaction_contexts() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_interaction_contexts() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_interaction_contexts() TO <%= ms_appusr %>;

-- syst_interaction_categories

GRANT SELECT, UPDATE ON TABLE ms_syst.syst_interaction_categories TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_interaction_categories() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_interaction_categories() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_interaction_categories() TO <%= ms_appusr %>;

-- syst_interaction_fields

GRANT SELECT, UPDATE ON TABLE ms_syst.syst_interaction_fields TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_interaction_fields() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_interaction_fields() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_interaction_fields() TO <%= ms_appusr %>;

-- syst_interaction_actions

GRANT SELECT, UPDATE ON TABLE ms_syst.syst_interaction_actions TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_interaction_actions() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_interaction_actions() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_interaction_actions() TO <%= ms_appusr %>;
