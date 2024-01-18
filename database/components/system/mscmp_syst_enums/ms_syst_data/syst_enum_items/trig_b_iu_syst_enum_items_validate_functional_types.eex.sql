CREATE OR REPLACE FUNCTION ms_syst_data.trig_b_iu_syst_enum_items_validate_functional_types()
RETURNS trigger AS
$BODY$

-- File:        trig_b_iu_syst_enum_items_validate_functional_types.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_enums/ms_syst_data/syst_enum_items/trig_b_iu_syst_enum_items_validate_functional_types.eex.sql
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

    IF
        EXISTS( SELECT TRUE
                FROM ms_syst_data.syst_enum_functional_types seft
                WHERE   seft.enum_id = new.enum_id) AND
        NOT EXISTS( SELECT TRUE
                    FROM ms_syst_data.syst_enum_functional_types seft
                    WHERE   seft.id = new.functional_type_id
                        AND seft.enum_id = new.enum_id)
    THEN

        RAISE EXCEPTION
            USING
                MESSAGE = 'The enumeration requires a valid functional type to be specified.',
                DETAIL  = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst_data'
                            ,p_proc_name      => 'trig_b_iu_syst_enum_items_validate_functional_types'
                            ,p_exception_name => 'invalid_functional_type'
                            ,p_errcode        => 'PM003'
                            ,p_param_data     => to_jsonb(new)
                            ,p_context_data   =>
                                jsonb_build_object(
                                     'tg_op',         tg_op
                                    ,'tg_when',       tg_when
                                    ,'tg_schema',     tg_table_schema
                                    ,'tg_table_name', tg_table_name)),
                ERRCODE = 'PM003',
                SCHEMA  = tg_table_schema,
                TABLE   = tg_table_name;

    END IF;

    RETURN new;
END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION ms_syst_data.trig_b_iu_syst_enum_items_validate_functional_types()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_data.trig_b_iu_syst_enum_items_validate_functional_types() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_data.trig_b_iu_syst_enum_items_validate_functional_types() TO <%= ms_owner %>;

DO
$DOCUMENTATION$
DECLARE
    -- Function
    var_comments_config ms_syst_priv.comments_config_function;

    -- Parameters

BEGIN

    --
    -- Function Config
    --

    var_comments_config.function_schema := 'ms_syst_data';
    var_comments_config.function_name   := 'trig_b_iu_syst_enum_items_validate_functional_types';

    var_comments_config.trigger_function := TRUE;
    var_comments_config.trigger_timing   := ARRAY [ 'b' ]::text[ ];
    var_comments_config.trigger_ops      := ARRAY [ 'i', 'u' ]::text[ ];

    var_comments_config.description :=
$DOC$Ensures that if the parent syst_enums record has syst_enum_functional_types
records defined, a syst_enum_items record will reference one of those
functional types.$DOC$;

    var_comments_config.general_usage :=
$DOC$Note that this trigger function is intended to be use by
constraint triggers.$DOC$;

    --
    -- Parameter Configs
    --



    var_comments_config.params :=
        ARRAY [ ]::ms_syst_priv.comments_config_function_param[];

    PERFORM ms_syst_priv.generate_comments_function( var_comments_config );

END;
$DOCUMENTATION$;
