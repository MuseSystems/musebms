CREATE OR REPLACE FUNCTION msbms_syst_priv.trig_a_iu_complex_format_value_check()
RETURNS trigger AS
$BODY$

-- File:        trig_a_iu_complex_format_value_check.eex.sql
-- Location:    musebms/database/components/system/msbms_syst_formats/msbms_syst_priv/trigger_functions/trig_a_iu_complex_format_value_check.eex.sql
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
    var_format_name   text COLLATE msbms_syst_priv.variant_insensitive := tg_argv[0];
    var_format_column text COLLATE msbms_syst_priv.variant_insensitive := tg_argv[1];
    var_new_json      jsonb                                            := to_jsonb(NEW);

BEGIN

    IF NOT exists( SELECT
                       TRUE
                   FROM msbms_syst_data.syst_complex_format_values cev
                   JOIN msbms_syst_data.syst_complex_formats ce ON ce.id = cev.complex_format_id
                   WHERE
                         ce.internal_name = var_format_name
                     AND cev.id = ( var_new_json ->> var_format_column )::uuid )
    THEN
        RAISE EXCEPTION
            USING
                MESSAGE =
                    format('The format value %1$s was not found for format %2$s.'
                        ,( var_new_json ->> var_format_column )::uuid
                        ,var_format_name),
                DETAIL = msbms_syst_priv.get_exception_details(
                             p_proc_schema    => 'msbms_syst_priv'
                            ,p_proc_name      => 'trig_a_iu_complex_format_value_check'
                            ,p_exception_name => 'complex_format_value_not_found'
                            ,p_errcode        => 'PM005'
                            ,p_param_data     => to_jsonb(tg_argv)
                            ,p_context_data   =>
                                jsonb_build_object(
                                     'tg_op',         tg_op
                                    ,'tg_when',       tg_when
                                    ,'tg_schema',     tg_table_schema
                                    ,'tg_table_name', tg_table_name)),
                ERRCODE = 'PM005',
                SCHEMA = tg_table_schema,
                TABLE = tg_table_name;
    END IF;

    RETURN NULL;

END;

$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION msbms_syst_priv.trig_a_iu_complex_format_value_check()
    OWNER TO <%= msbms_owner %>;

REVOKE EXECUTE ON FUNCTION msbms_syst_priv.trig_a_iu_complex_format_value_check() FROM public;
GRANT EXECUTE ON FUNCTION msbms_syst_priv.trig_a_iu_complex_format_value_check() TO <%= msbms_owner %>;

COMMENT ON FUNCTION msbms_syst_priv.trig_a_iu_complex_format_value_check() IS
$DOC$A constraint trigger function to provide foreign key like validation of columns
which reference syst_complex_format_values.  This relationship requires the
additional check so that only values from the desired format are used in
assigning to records.$DOC$;
