-- File:        test_privileges.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_nav/testing_support/test_privileges.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

-- syst_nav_action_groups

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_nav_action_groups TO <%= ms_appusr %>;
-- GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_nav_action_groups() TO <%= ms_appusr %>;
-- GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_nav_action_groups() TO <%= ms_appusr %>;
-- GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_nav_action_groups() TO <%= ms_appusr %>;

-- syst_nav_actions

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_nav_actions TO <%= ms_appusr %>;
-- GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_nav_actions() TO <%= ms_appusr %>;
-- GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_nav_actions() TO <%= ms_appusr %>;
-- GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_nav_actions() TO <%= ms_appusr %>;


-- syst_menus

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_menus TO <%= ms_appusr %>;
-- GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_menus() TO <%= ms_appusr %>;
-- GRANT EXECUTE ON FUNCTION ms_syst.trig_u_i_syst_menus() TO <%= ms_appusr %>;
-- GRANT EXECUTE ON FUNCTION ms_syst.trig_d_i_syst_menus() TO <%= ms_appusr %>;


-- syst_menu_items

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_menu_items TO <%= ms_appusr %>;
-- GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_menu_items() TO <%= ms_appusr %>;
-- GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_sust_menu_items() TO <%= ms_appusr %>;
-- GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_sdst_menu_items() TO <%= ms_appusr %>;
