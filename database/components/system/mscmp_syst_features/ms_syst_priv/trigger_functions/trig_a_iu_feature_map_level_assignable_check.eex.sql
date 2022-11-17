CREATE OR REPLACE FUNCTION ms_syst_priv.trig_a_iu_feature_map_level_assignable_check()
RETURNS trigger AS
$BODY$

-- File:        trig_a_iu_feature_map_level_assignable_check.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_features/ms_syst_priv/trigger_functions/trig_a_iu_feature_map_level_assignable_check.eex.sql
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

    IF NOT exists( SELECT
                       TRUE
                   FROM ms_syst_data.syst_feature_map fm
                   JOIN ms_syst_data.syst_feature_map_levels fml
                        ON fml.id = fm.feature_map_level_id
                   WHERE fm.id = new.feature_map_id AND fml.functional_type = 'assignable' )
    THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'The feature to which you are trying to map is not assignable.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst_priv'
                            ,p_proc_name      => 'trig_a_iu_feature_map_level_assignable_check'
                            ,p_exception_name => 'feature_map_level_nonassignable'
                            ,p_errcode        => 'PM004'
                            ,p_param_data     => NULL::jsonb
                            ,p_context_data   =>
                                jsonb_build_object(
                                     'tg_op',         tg_op
                                    ,'tg_when',       tg_when
                                    ,'tg_schema',     tg_table_schema
                                    ,'tg_table_name', tg_table_name)),
                ERRCODE = 'PM004',
                SCHEMA = tg_table_schema,
                    TABLE = tg_table_name;
    END IF;

    RETURN NULL;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION ms_syst_priv.trig_a_iu_feature_map_level_assignable_check()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_priv.trig_a_iu_feature_map_level_assignable_check() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_priv.trig_a_iu_feature_map_level_assignable_check() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst_priv.trig_a_iu_feature_map_level_assignable_check() IS
$DOC$Determines if a syst_feature_map record is assigned to an assignable
syst_feature_map_levels record.  If the level record is functional type
nonassignable, an exception is raised.  Note that this function expects to be
executed by a constraint trigger and that the table associated with the trigger
should have a column feature_map_id referenced to syst_feature_map.$DOC$;
