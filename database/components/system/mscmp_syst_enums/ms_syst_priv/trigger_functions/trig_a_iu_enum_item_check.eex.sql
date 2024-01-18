CREATE OR REPLACE FUNCTION ms_syst_priv.trig_a_iu_enum_item_check()
RETURNS trigger AS
$BODY$

-- File:        trig_a_iu_enum_item_check.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_enums/ms_syst_priv/trigger_functions/trig_a_iu_enum_item_check.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

DECLARE
    var_enumeration_name   text COLLATE ms_syst_priv.variant_insensitive := tg_argv[0];
    var_enumeration_column text COLLATE ms_syst_priv.variant_insensitive := tg_argv[1];
    var_new_json           jsonb                                            := to_jsonb(NEW);

BEGIN

    IF NOT exists( SELECT
                       TRUE
                   FROM ms_syst_data.syst_enum_items cev
                   JOIN ms_syst_data.syst_enums ce ON ce.id = cev.enum_id
                   WHERE
                         ce.internal_name = var_enumeration_name
                     AND cev.id = ( var_new_json ->> var_enumeration_column )::uuid )
    THEN
        RAISE EXCEPTION
            USING
                MESSAGE =
                    format('The enumeration value %1$s was not for enumeration %2$s.'
                        ,( var_new_json ->> var_enumeration_column )::uuid
                        ,var_enumeration_name),
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst_priv'
                            ,p_proc_name      => 'trig_a_iu_enum_item_check'
                            ,p_exception_name => 'enum_item_not_found'
                            ,p_errcode        => 'PM003'
                            ,p_param_data     => to_jsonb(tg_argv)
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

    RETURN NULL;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst_priv.trig_a_iu_enum_item_check()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_priv.trig_a_iu_enum_item_check() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_priv.trig_a_iu_enum_item_check() TO <%= ms_owner %>;

DO
$DOCUMENTATION$
DECLARE
    -- Function
    var_comments_config ms_syst_priv.comments_config_function;

    -- Parameters
    var_tg_argv0 ms_syst_priv.comments_config_function_param;
    var_tg_argv1 ms_syst_priv.comments_config_function_param;

BEGIN

    --
    -- Function Config
    --

    var_comments_config.function_schema := 'ms_syst_priv';
    var_comments_config.function_name   := 'trig_a_iu_enum_item_check';

    var_comments_config.trigger_function := TRUE;
    var_comments_config.trigger_timing   := ARRAY [ 'a' ]::text[ ];
    var_comments_config.trigger_ops      := ARRAY [ 'i', 'u' ]::text[ ];

    var_comments_config.description :=
$DOC$A constraint trigger function to provide foreign key like validation of columns
which reference syst_enum_items.$DOC$;

    var_comments_config.general_usage :=
$DOC$This relationship requires the additional check that only values from the
desired enumeration are used in assigning to records.$DOC$;

    --
    -- Parameter Configs
    --

    var_tg_argv0.param_name := 'tg_argv[0]';
    var_tg_argv0.required := TRUE;
    var_tg_argv0.description :=
$DOC$The name of the enumeration to validate against.

This value will be the `ms_syst_data.syst_enums.internal_name` value which
identified the enumeration.$DOC$;

    var_tg_argv1.param_name := 'tg_argv[1]';
    var_tg_argv1.required := TRUE;
    var_tg_argv1.description :=
$DOC$The name of the foreign key column in the host table which references
`ms_syst_data.syst_enum_items` records.$DOC$;

    var_comments_config.params :=
        ARRAY [
              var_tg_argv0
            , var_tg_argv1
            ]::ms_syst_priv.comments_config_function_param[];

    PERFORM ms_syst_priv.generate_comments_function( var_comments_config );

END;
$DOCUMENTATION$;
