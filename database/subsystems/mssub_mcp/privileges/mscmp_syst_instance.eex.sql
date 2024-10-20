-- File:        mscmp_syst_instance.eex.sql
-- Location:    musebms/database/application/msapp_platform/mssub_mcp/privileges/mscmp_syst_instance.eex.sql
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
-- MscmpSystInstance
--

-- syst_applications

GRANT SELECT, INSERT, UPDATE ON TABLE ms_syst.syst_applications TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_applications() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_applications() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_applications() TO <%= ms_appusr %>;

-- syst_application_contexts

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_application_contexts TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_application_contexts() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_application_contexts() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_application_contexts() TO <%= ms_appusr %>;

-- syst_owners

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_owners TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_owners() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_owners() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_owners() TO <%= ms_appusr %>;

-- syst_instance_type_applications

GRANT SELECT, INSERT, DELETE ON TABLE ms_syst.syst_instance_type_applications TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_instance_type_applications() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_instance_type_applications() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_instance_type_applications() TO <%= ms_appusr %>;

-- syst_instance_type_contexts

GRANT SELECT, UPDATE ON TABLE ms_syst.syst_instance_type_contexts TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_instance_type_contexts() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_instance_type_contexts() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_instance_type_contexts() TO <%= ms_appusr %>;

-- syst_instances

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_instances TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_instances() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_instances() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_instances() TO <%= ms_appusr %>;

-- syst_instance_contexts

GRANT SELECT, UPDATE ON TABLE ms_syst.syst_instance_contexts TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_instance_contexts() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_instance_contexts() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_instance_contexts() TO <%= ms_appusr %>;
