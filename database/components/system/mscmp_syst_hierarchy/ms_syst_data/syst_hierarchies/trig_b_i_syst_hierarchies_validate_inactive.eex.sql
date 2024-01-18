CREATE OR REPLACE FUNCTION ms_syst_data.trig_b_i_syst_hierarchies_validate_inactive()
RETURNS trigger AS
$BODY$

-- File:        trig_b_i_syst_hierarchies_validate_inactive.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_hierarchy/ms_syst_data/syst_hierarchies/trig_b_i_syst_hierarchies_validate_inactive.eex.sql
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

    IF
        ( SELECT eft.internal_name = 'hierarchy_states_active'
          FROM ms_syst_data.syst_enum_items ei
              JOIN ms_syst_data.syst_enum_functional_types eft
                  ON eft.id = ei.functional_type_id
          WHERE ei.id = new.hierarchy_state_id )
    THEN

        RAISE EXCEPTION
            USING
                MESSAGE = 'New Hierarchy records may not be inserted using ' ||
                          'an "active" state.',
                DETAIL  = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_appl_data'
                            ,p_proc_name      => 'trig_b_i_syst_hierarchies_validate_inactive'
                            ,p_exception_name => 'invalid_state'
                            ,p_errcode        => 'PM003'
                            ,p_param_data     => to_jsonb( new )
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
    LANGUAGE plpgsql
    VOLATILE;

ALTER FUNCTION ms_syst_data.trig_b_i_syst_hierarchies_validate_inactive()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_data.trig_b_i_syst_hierarchies_validate_inactive() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_data.trig_b_i_syst_hierarchies_validate_inactive() TO <%= ms_owner %>;

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
    var_comments_config.function_name   := 'trig_b_i_syst_hierarchies_validate_inactive';
    
    var_comments_config.trigger_function := FALSE;
    var_comments_config.trigger_timing   := ARRAY [ 'b' ]::text[ ];
    var_comments_config.trigger_ops      := ARRAY [ 'i' ]::text[ ];

    var_comments_config.description :=
$DOC$Prevents Hierarchy records from being inserted in an already "active" state.$DOC$;

    var_comments_config.general_usage :=
$DOC$Hierarchy records should be inserted "inactive" and then later made "active"
once the record and its associate Hierarchy Item records are complete and valid.$DOC$;

    PERFORM ms_syst_priv.generate_comments_function( var_comments_config );

END;
$DOCUMENTATION$;
