-- File:        test_privileges.eex.sql
-- Location:    musebms/database/components/application/mscmp_core_hierarchy/testing_support/test_privileges.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

GRANT USAGE ON SCHEMA ms_appl TO <%= ms_appusr %>;

-- conf_hierarchies

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_appl.conf_hierarchies TO <%= ms_appusr %>;

GRANT EXECUTE ON FUNCTION ms_appl.trig_i_i_conf_hierarchies() TO <%= ms_appusr %>;

GRANT EXECUTE ON FUNCTION ms_appl.trig_i_u_conf_hierarchies() TO <%= ms_appusr %>;

GRANT EXECUTE ON FUNCTION ms_appl.trig_i_d_conf_hierarchies() TO <%= ms_appusr %>;

-- conf_hierarchy_items

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_appl.conf_hierarchy_items TO <%= ms_appusr %>;

GRANT EXECUTE ON FUNCTION ms_appl.trig_i_i_conf_hierarchy_items() TO <%= ms_appusr %>;

GRANT EXECUTE ON FUNCTION ms_appl.trig_i_u_conf_hierarchy_items() TO <%= ms_appusr %>;

GRANT EXECUTE ON FUNCTION ms_appl.trig_i_d_conf_hierarchy_items() TO <%= ms_appusr %>;
