-- File:        privileges.eex.sql
-- Location:    musebms/database/application/msmcp/components/ms_syst_instance_mgr/privileges.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

--
-- MscmpSystInstance
--

-- syst_applications

GRANT SELECT ON TABLE ms_syst.syst_applications TO <%= ms_appusr %>;
GRANT SELECT ON TABLE ms_syst.syst_applications TO <%= ms_apiusr %>;

-- syst_application_contexts

GRANT SELECT, UPDATE ON TABLE ms_syst.syst_application_contexts TO <%= ms_appusr %>;
GRANT SELECT, UPDATE ON TABLE ms_syst.syst_application_contexts TO <%= ms_apiusr %>;

GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_application_contexts() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_application_contexts() TO <%= ms_apiusr %>;

-- syst_owners

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_owners TO <%= ms_appusr %>;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_owners TO <%= ms_apiusr %>;

GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_owners() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_owners() TO <%= ms_apiusr %>;

GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_owners() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_owners() TO <%= ms_apiusr %>;

GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_owners() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_owners() TO <%= ms_apiusr %>;

-- syst_instance_type_applications

GRANT SELECT, INSERT, DELETE ON TABLE ms_syst.syst_instance_type_applications TO <%= ms_appusr %>;
GRANT SELECT, INSERT, DELETE ON TABLE ms_syst.syst_instance_type_applications TO <%= ms_apiusr %>;

GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_instance_type_applications() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_instance_type_applications() TO <%= ms_apiusr %>;

GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_instance_type_applications() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_instance_type_applications() TO <%= ms_apiusr %>;

GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_instance_type_applications() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_instance_type_applications() TO <%= ms_apiusr %>;

-- syst_instance_type_contexts

GRANT SELECT, UPDATE ON TABLE ms_syst.syst_instance_type_contexts TO <%= ms_appusr %>;
GRANT SELECT, UPDATE ON TABLE ms_syst.syst_instance_type_contexts TO <%= ms_apiusr %>;

GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_instance_type_contexts() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_instance_type_contexts() TO <%= ms_apiusr %>;

GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_instance_type_contexts() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_instance_type_contexts() TO <%= ms_apiusr %>;

GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_instance_type_contexts() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_instance_type_contexts() TO <%= ms_apiusr %>;

-- syst_instances

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_instances TO <%= ms_appusr %>;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_instances TO <%= ms_apiusr %>;

GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_instances() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_instances() TO <%= ms_apiusr %>;

GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_instances() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_instances() TO <%= ms_apiusr %>;

GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_instances() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_instances() TO <%= ms_apiusr %>;

-- syst_instance_contexts

GRANT SELECT, UPDATE ON TABLE ms_syst.syst_instance_contexts TO <%= ms_appusr %>;
GRANT SELECT, UPDATE ON TABLE ms_syst.syst_instance_contexts TO <%= ms_apiusr %>;

GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_instance_contexts() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_instance_contexts() TO <%= ms_apiusr %>;

GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_instance_contexts() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_instance_contexts() TO <%= ms_apiusr %>;

GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_instance_contexts() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_instance_contexts() TO <%= ms_apiusr %>;
