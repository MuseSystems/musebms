-- File:        privileges.eex.sql
-- Location:    musebms/database/app_msbms_global/components/msbms_syst_instance_mgr/privileges.eex.sql
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
-- MsbmsSystInstanceMgr
--

-- syst_applications

GRANT SELECT ON TABLE msbms_syst.syst_applications TO <%= msbms_appusr %>;
GRANT SELECT ON TABLE msbms_syst.syst_applications TO <%= msbms_apiusr %>;

-- syst_application_contexts

GRANT SELECT, UPDATE ON TABLE msbms_syst.syst_application_contexts TO <%= msbms_appusr %>;
GRANT SELECT, UPDATE ON TABLE msbms_syst.syst_application_contexts TO <%= msbms_apiusr %>;

GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_application_contexts() TO <%= msbms_appusr %>;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_application_contexts() TO <%= msbms_apiusr %>;

-- syst_owners

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE msbms_syst.syst_owners TO <%= msbms_appusr %>;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE msbms_syst.syst_owners TO <%= msbms_apiusr %>;

GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_i_syst_owners() TO <%= msbms_appusr %>;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_i_syst_owners() TO <%= msbms_apiusr %>;

GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_owners() TO <%= msbms_appusr %>;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_owners() TO <%= msbms_apiusr %>;

GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_d_syst_owners() TO <%= msbms_appusr %>;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_d_syst_owners() TO <%= msbms_apiusr %>;

-- syst_instance_type_applications

GRANT SELECT, INSERT, DELETE ON TABLE msbms_syst.syst_instance_type_applications TO <%= msbms_appusr %>;
GRANT SELECT, INSERT, DELETE ON TABLE msbms_syst.syst_instance_type_applications TO <%= msbms_apiusr %>;

GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_i_syst_instance_type_applications() TO <%= msbms_appusr %>;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_i_syst_instance_type_applications() TO <%= msbms_apiusr %>;

GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_instance_type_applications() TO <%= msbms_appusr %>;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_instance_type_applications() TO <%= msbms_apiusr %>;

GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_d_syst_instance_type_applications() TO <%= msbms_appusr %>;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_d_syst_instance_type_applications() TO <%= msbms_apiusr %>;

-- syst_instance_type_contexts

GRANT SELECT, UPDATE ON TABLE msbms_syst.syst_instance_type_contexts TO <%= msbms_appusr %>;
GRANT SELECT, UPDATE ON TABLE msbms_syst.syst_instance_type_contexts TO <%= msbms_apiusr %>;

GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_i_syst_instance_type_contexts() TO <%= msbms_appusr %>;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_i_syst_instance_type_contexts() TO <%= msbms_apiusr %>;

GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_instance_type_contexts() TO <%= msbms_appusr %>;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_instance_type_contexts() TO <%= msbms_apiusr %>;

GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_d_syst_instance_type_contexts() TO <%= msbms_appusr %>;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_d_syst_instance_type_contexts() TO <%= msbms_apiusr %>;

-- syst_instances

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE msbms_syst.syst_instances TO <%= msbms_appusr %>;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE msbms_syst.syst_instances TO <%= msbms_apiusr %>;

GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_i_syst_instances() TO <%= msbms_appusr %>;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_i_syst_instances() TO <%= msbms_apiusr %>;

GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_instances() TO <%= msbms_appusr %>;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_instances() TO <%= msbms_apiusr %>;

GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_d_syst_instances() TO <%= msbms_appusr %>;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_d_syst_instances() TO <%= msbms_apiusr %>;

-- syst_instance_contexts

GRANT SELECT, UPDATE ON TABLE msbms_syst.syst_instance_contexts TO <%= msbms_appusr %>;
GRANT SELECT, UPDATE ON TABLE msbms_syst.syst_instance_contexts TO <%= msbms_apiusr %>;

GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_i_syst_instance_contexts() TO <%= msbms_appusr %>;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_i_syst_instance_contexts() TO <%= msbms_apiusr %>;

GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_instance_contexts() TO <%= msbms_appusr %>;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_instance_contexts() TO <%= msbms_apiusr %>;

GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_d_syst_instance_contexts() TO <%= msbms_appusr %>;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_d_syst_instance_contexts() TO <%= msbms_apiusr %>;
