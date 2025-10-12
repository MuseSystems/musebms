CREATE OR REPLACE FUNCTION ms_syst.trig_i_u_syst_interaction_fields()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_interaction_fields.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_interaction/ms_syst/api_views/syst_interaction_fields/trig_i_u_syst_interaction_fields.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

BEGIN

    IF new.interaction_context_id != old.interaction_context_id THEN

        RAISE EXCEPTION
        USING
            MESSAGE = 'You cannot change the parent Interaction Fields ' ||
                      'using this API view.',
            DETAIL = ms_syst_priv.get_exception_details(
                         p_proc_schema    => 'ms_syst'
                        ,p_proc_name      => 'trig_i_u_syst_interaction_fields'
                        ,p_param_data     =>
                            jsonb_build_object( 'old', old, 'new', new)
                        ,p_context_data   =>
                            jsonb_build_object(
                                 'tg_op',         tg_op
                                ,'tg_when',       tg_when
                                ,'tg_schema',     tg_table_schema
                                ,'tg_table_name', tg_table_name)),
            ERRCODE = 'PM001',
            SCHEMA = tg_table_schema,
            TABLE = tg_table_name;

    END IF;

    IF
        ( SELECT syst_defined AND NOT user_maintainable
          FROM ms_syst_data.syst_interaction_contexts
          WHERE id = old.interaction_context_id ) AND
            (new.internal_name != old.internal_name
                OR new.perm_id != old.perm_id
                OR new.interaction_category_id != old.interaction_category_id)
    THEN

        RAISE EXCEPTION
        USING
            MESSAGE = 'Prohibited update requested.  Parent Interaction Context ' ||
                      'record is System Defined and not User Maintainable.',
            DETAIL = ms_syst_priv.get_exception_details(
                         p_proc_schema    => 'ms_syst'
                        ,p_proc_name      => 'trig_i_u_syst_interaction_fields'
                        ,p_param_data     =>
                            jsonb_build_object( 'old', old, 'new', new)
                        ,p_context_data   =>
                            jsonb_build_object(
                                 'tg_op',         tg_op
                                ,'tg_when',       tg_when
                                ,'tg_schema',     tg_table_schema
                                ,'tg_table_name', tg_table_name)),
            ERRCODE = 'PM003',
            SCHEMA = tg_table_schema,
            TABLE = tg_table_name;

    END IF;

    UPDATE ms_syst_data.syst_interaction_fields
    SET
        internal_name           = new.internal_name
      , perm_id                 = new.perm_id
      , interaction_category_id = new.interaction_category_id
    WHERE id = new.id
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_u_syst_interaction_fields()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_interaction_fields() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_interaction_fields() TO <%= ms_owner %>;

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
    v_comments_config.function_name   := 'trig_i_u_syst_interaction_fields';

    v_comments_config.trigger_function := TRUE;
    v_comments_config.trigger_timing   := ARRAY [ 'i' ]::text[ ];
    v_comments_config.trigger_ops      := ARRAY [ 'u' ]::text[ ];

    v_comments_config.description :=
$DOC$Processes incoming API View requests according to globally applicable business
rules and data validation requirements.$DOC$;

    PERFORM ms_syst_priv.generate_comments_function( v_comments_config );

END;
$DOCUMENTATION$;
