CREATE OR REPLACE FUNCTION ms_syst.trig_i_i_syst_instances()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_instances.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst/api_views/syst_instances/trig_i_i_syst_instances.eex.sql
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

    INSERT INTO ms_syst_data.syst_instances
        ( internal_name
        , display_name
        , application_id
        , instance_type_id
        , instance_lifecycle_state_id
        , owner_id
        , owning_instance_id
        , dbserver_name
        , instance_code
        , instance_options )
    VALUES
        ( new.internal_name
        , new.display_name
        , new.application_id
        , new.instance_type_id
        , new.instance_lifecycle_state_id
        , new.owner_id
        , new.owning_instance_id
        , new.dbserver_name
        , new.instance_code
        , new.instance_options )
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_i_syst_instances()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_instances() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_instances() TO <%= ms_owner %>;

DO
$DOCUMENTATION$
DECLARE
    -- Function
    v_comments_config ms_syst_priv.comments_config_function;

BEGIN

    --
    -- Function Config
    --

    v_comments_config.function_schema := 'ms_syst';
    v_comments_config.function_name   := 'trig_i_i_syst_instances';

    v_comments_config.trigger_function := TRUE;
    v_comments_config.trigger_timing   := ARRAY [ 'i' ]::text[ ];
    v_comments_config.trigger_ops      := ARRAY [ 'i' ]::text[ ];

    v_comments_config.description :=
$DOC$Processes incoming API View requests according to globally applicable business
rules and data validation requirements.$DOC$;

    PERFORM ms_syst_priv.generate_comments_function( v_comments_config );

END;
$DOCUMENTATION$;
