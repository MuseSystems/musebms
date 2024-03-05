-- File:        test_privileges.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_interaction/testing_support/test_privileges.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

GRANT INSERT, SELECT, DELETE ON TABLE ms_syst.syst_interaction_contexts TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_interaction_contexts() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_interaction_contexts() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_interaction_contexts() TO <%= ms_appusr %>;

GRANT INSERT, SELECT, DELETE ON TABLE ms_syst.syst_interaction_categories TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_interaction_categories() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_interaction_categories() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_interaction_categories() TO <%= ms_appusr %>;

GRANT INSERT, SELECT, DELETE ON TABLE ms_syst.syst_interaction_fields TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_interaction_fields() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_interaction_fields() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_interaction_fields() TO <%= ms_appusr %>;

GRANT INSERT, SELECT, DELETE ON TABLE ms_syst.syst_interaction_actions TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_interaction_actions() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_interaction_actions() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_interaction_actions() TO <%= ms_appusr %>;
