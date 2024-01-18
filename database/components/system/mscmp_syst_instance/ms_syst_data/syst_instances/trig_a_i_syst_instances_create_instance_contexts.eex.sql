CREATE OR REPLACE FUNCTION ms_syst_data.trig_a_i_syst_instances_create_instance_contexts()
RETURNS trigger AS
$BODY$

-- File:        trig_a_i_syst_instances_create_instance_contexts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst_data/syst_instances/trig_a_i_syst_instances_create_instance_contexts.eex.sql
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

    INSERT INTO ms_syst_data.syst_instance_contexts
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
        ms_syst_data.syst_owners so,
        ms_syst_data.syst_application_contexts sac
            JOIN ms_syst_data.syst_instance_type_contexts sitc
                ON sitc.application_context_id = sac.id
            JOIN ms_syst_data.syst_applications sa
                ON sa.id = sac.application_id
            JOIN ms_syst_data.syst_instance_type_applications sita
                ON sita.id = sitc.instance_type_application_id
    WHERE
          so.id = new.owner_id
      AND sita.instance_type_id = new.instance_type_id
      AND sa.id = new.application_id;

    RETURN new;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION ms_syst_data.trig_a_i_syst_instances_create_instance_contexts()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_data.trig_a_i_syst_instances_create_instance_contexts() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_data.trig_a_i_syst_instances_create_instance_contexts() TO <%= ms_owner %>;

DO
$DOCUMENTATION$
DECLARE
    -- Function
    var_comments_config ms_syst_priv.comments_config_function;

BEGIN

    --
    -- Function Config
    --

    var_comments_config.function_schema := 'ms_syst_data';
    var_comments_config.function_name   := 'trig_a_i_syst_instances_create_instance_contexts';

    var_comments_config.trigger_function := TRUE;
    var_comments_config.trigger_timing   := ARRAY [ 'a' ]::text[ ];
    var_comments_config.trigger_ops      := ARRAY [ 'i' ]::text[ ];

    var_comments_config.description :=
$DOC$Creates Instance Context records based on existing Application Contexts and Instance Type Contexts.$DOC$;

    PERFORM ms_syst_priv.generate_comments_function( var_comments_config );

END;
$DOCUMENTATION$;

COMMENT ON FUNCTION ms_syst_data.trig_a_i_syst_instances_create_instance_contexts() IS
$DOC$$DOC$;
