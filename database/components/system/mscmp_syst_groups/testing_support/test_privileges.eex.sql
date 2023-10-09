-- File:        test_privileges.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_groups/testing_support/test_privileges.eex.sql
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

-- syst_group_functional_types

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_group_functional_types TO <%= ms_appusr %>;

GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_group_functional_types() TO <%= ms_appusr %>;

GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_group_functional_types() TO <%= ms_appusr %>;

GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_group_functional_types() TO <%= ms_appusr %>;

-- syst_group_types

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_group_types TO <%= ms_appusr %>;

GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_group_types() TO <%= ms_appusr %>;

GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_group_types() TO <%= ms_appusr %>;

GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_group_types() TO <%= ms_appusr %>;

-- syst_group_type_items

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_group_type_items TO <%= ms_appusr %>;

GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_group_type_items() TO <%= ms_appusr %>;

GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_group_type_items() TO <%= ms_appusr %>;

GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_group_type_items() TO <%= ms_appusr %>;

-- syst_groups
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_groups TO <%= ms_appusr %>;

GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_groups() TO <%= ms_appusr %>;

GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_groups() TO <%= ms_appusr %>;

GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_groups() TO <%= ms_appusr %>;
