-- File:        test_privileges.eex.sql
-- Location:    database\cmp_msbms_syst_instance_mgr\testing_support\test_privileges.eex.sql
-- Project:     Muse Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

--
--  MsbmsSystEnums
--

-- syst_enums

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE msbms_syst.syst_enums TO <%= msbms_appusr %>;

GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_i_syst_enums() TO <%= msbms_appusr %>;

GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_enums() TO <%= msbms_appusr %>;

GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_d_syst_enums() TO <%= msbms_appusr %>;

-- syst_enum_functional_types

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE msbms_syst.syst_enum_functional_types TO <%= msbms_appusr %>;

GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_i_syst_enum_functional_types() TO <%= msbms_appusr %>;

GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_enum_functional_types() TO <%= msbms_appusr %>;

GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_d_syst_enum_functional_types() TO <%= msbms_appusr %>;

-- syst_enum_items

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE msbms_syst.syst_enum_items TO <%= msbms_appusr %>;

GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_i_syst_enum_items() TO <%= msbms_appusr %>;

GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_enum_items() TO <%= msbms_appusr %>;

GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_d_syst_enum_items() TO <%= msbms_appusr %>;

--
-- MsbmsSystInstanceMgr
--

-- syst_applications

GRANT SELECT ON TABLE msbms_syst.syst_applications TO <%= msbms_appusr %>;

-- syst_application_contexts

GRANT SELECT, UPDATE ON TABLE msbms_syst.syst_application_contexts TO <%= msbms_appusr %>;

GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_application_contexts() TO <%= msbms_appusr %>;

-- syst_owners

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE msbms_syst.syst_owners TO <%= msbms_appusr %>;

GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_i_syst_owners() TO <%= msbms_appusr %>;

GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_owners() TO <%= msbms_appusr %>;

GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_d_syst_owners() TO <%= msbms_appusr %>;

-- syst_instance_type_applications

GRANT SELECT, INSERT, DELETE ON TABLE msbms_syst.syst_instance_type_applications TO <%= msbms_appusr %>;

GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_i_syst_instance_type_applications() TO <%= msbms_appusr %>;

GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_instance_type_applications() TO <%= msbms_appusr %>;

GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_d_syst_instance_type_applications() TO <%= msbms_appusr %>;

-- syst_instance_type_contexts

GRANT SELECT, UPDATE ON TABLE msbms_syst.syst_instance_type_contexts TO <%= msbms_appusr %>;

GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_i_syst_instance_type_contexts() TO <%= msbms_appusr %>;

GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_instance_type_contexts() TO <%= msbms_appusr %>;

GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_d_syst_instance_type_contexts() TO <%= msbms_appusr %>;

-- syst_instances

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE msbms_syst.syst_instances TO <%= msbms_appusr %>;

GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_i_syst_instances() TO <%= msbms_appusr %>;

GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_instances() TO <%= msbms_appusr %>;

GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_d_syst_instances() TO <%= msbms_appusr %>;

-- syst_instance_contexts

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE msbms_syst.syst_instance_contexts TO <%= msbms_appusr %>;

GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_i_syst_instance_contexts() TO <%= msbms_appusr %>;

GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_instance_contexts() TO <%= msbms_appusr %>;

GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_d_syst_instance_contexts() TO <%= msbms_appusr %>;
