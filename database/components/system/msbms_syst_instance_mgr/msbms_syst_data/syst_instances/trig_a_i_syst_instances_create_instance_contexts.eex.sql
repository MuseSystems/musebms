CREATE OR REPLACE FUNCTION msbms_syst_data.trig_a_i_syst_instances_create_instance_contexts()
RETURNS trigger AS
$BODY$

-- File:        trig_a_i_syst_instances_create_instance_contexts.eex.sql
-- Location:    musebms/database/components/system/msbms_syst_instance_mgr/msbms_syst_data/syst_instances/trig_a_i_syst_instances_create_instance_contexts.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

BEGIN

    INSERT INTO msbms_syst_data.syst_instance_contexts
        ( internal_name
        , instance_id
        , application_context_id
        , start_context
        , db_pool_size
        , context_code )
    SELECT
        new.internal_name || '_' || sac.internal_name
      , new.id
      , sac.id
      , sac.login_context
      , sitc.default_db_pool_size
      , public.gen_random_bytes( 16 )
    FROM
        msbms_syst_data.syst_owners so,
        msbms_syst_data.syst_application_contexts sac
            JOIN msbms_syst_data.syst_instance_type_contexts sitc
                ON sitc.application_context_id = sac.id
            JOIN msbms_syst_data.syst_applications sa
                ON sa.id = sac.application_id
            JOIN msbms_syst_data.syst_instance_type_applications sita
                ON sita.id = sitc.instance_type_application_id
    WHERE
          so.id = new.owner_id
      AND sita.instance_type_id = new.instance_type_id
      AND sa.id = new.application_id;

    RETURN new;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION msbms_syst_data.trig_a_i_syst_instances_create_instance_contexts()
    OWNER TO <%= msbms_owner %>;

REVOKE EXECUTE ON FUNCTION msbms_syst_data.trig_a_i_syst_instances_create_instance_contexts() FROM public;
GRANT EXECUTE ON FUNCTION msbms_syst_data.trig_a_i_syst_instances_create_instance_contexts() TO <%= msbms_owner %>;

COMMENT ON FUNCTION msbms_syst_data.trig_a_i_syst_instances_create_instance_contexts() IS
$DOC$Creates Instance Context records based on existing Application Contexts and Instance Type Contexts.$DOC$;
