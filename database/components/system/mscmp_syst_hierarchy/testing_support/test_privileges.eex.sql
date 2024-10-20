-- File:        test_privileges.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_hierarchy/testing_support/test_privileges.eex.sql
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

-- syst_hierarchies

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_hierarchies TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_hierarchies() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_hierarchies() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_hierarchies() TO <%= ms_appusr %>;

-- syst_hierarchy_items

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_hierarchy_items TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_hierarchy_items() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_hierarchy_items() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_hierarchy_items() TO <%= ms_appusr %>;
