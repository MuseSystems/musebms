CREATE OR REPLACE FUNCTION ms_syst_data.trig_b_d_syst_hierarchies_validate_prereqs()
RETURNS trigger AS
$BODY$

-- File:        trig_b_d_syst_hierarchies_validate_prereqs.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_hierarchy/ms_syst_data/syst_hierarchies/trig_b_d_syst_hierarchies_validate_prereqs.eex.sql
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

    IF ms_syst_priv.is_hierarchy_record_referenced( old.id ) THEN

        RAISE EXCEPTION
            USING
                MESSAGE = 'Hierarchy records may not be deleted when they ' ||
                          'are referenced in the data of hierarchy ' ||
                          'implementing Components.',
                DETAIL  = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_appl_data'
                            ,p_proc_name      => 'trig_b_d_syst_hierarchies_validate_prereqs'
                            ,p_exception_name => 'invalid_state'
                            ,p_errcode        => 'PM003'
                            ,p_param_data     => to_jsonb( old )
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

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE;

ALTER FUNCTION ms_syst_data.trig_b_d_syst_hierarchies_validate_prereqs()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_data.trig_b_d_syst_hierarchies_validate_prereqs() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_data.trig_b_d_syst_hierarchies_validate_prereqs() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst_data.trig_b_d_syst_hierarchies_validate_prereqs() IS
$DOC$Validates that a Hierarchy is no longer referenced by the data of Hierarchy
implementing Components prior to allowing that Hierarchy being deleted.  Note
that references from associated Hierarchy Item records do not count as
"references" and that deleting their parent Hierarchy record will cascade to the
Hierarchy Item records.$DOC$;
