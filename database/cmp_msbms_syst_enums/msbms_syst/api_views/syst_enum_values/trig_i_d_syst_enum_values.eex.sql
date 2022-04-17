CREATE OR REPLACE FUNCTION msbms_syst.trig_i_d_syst_enum_values()
RETURNS trigger AS
$BODY$

-- File:        trig_i_d_syst_enum_values.eex.sql
-- Location:    database\cmp_msbms_syst_enums\msbms_syst\api_views\syst_enum_values\trig_i_d_syst_enum_values.eex.sql
-- Project:     Muse Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

BEGIN

    IF old.syst_defined THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'You cannot delete a system defined enumeration using the API Views.',
                DETAIL = msbms_syst_priv.get_exception_details(
                             p_proc_schema    => 'msbms_syst'
                            ,p_proc_name      => 'trig_i_d_syst_enum_valuess'
                            ,p_exception_name => 'invalid_api_view_call'
                            ,p_errcode        => 'PM008'
                            ,p_param_data     => to_jsonb(old)
                            ,p_context_data   =>
                                jsonb_build_object(
                                     'tg_op',         tg_op
                                    ,'tg_when',       tg_when
                                    ,'tg_schema',     tg_table_schema
                                    ,'tg_table_name', tg_table_name)),
                ERRCODE = 'PM008',
                SCHEMA = tg_table_schema,
                TABLE = tg_table_name;
    END IF;

    DELETE FROM msbms_syst_data.syst_enum_values WHERE id = old.id RETURNING * INTO old;

    RETURN old;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION msbms_syst.trig_i_d_syst_enum_values()
    OWNER TO <%= msbms_owner %>;

REVOKE EXECUTE ON FUNCTION msbms_syst.trig_i_d_syst_enum_values() FROM public;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_d_syst_enum_values() TO <%= msbms_owner %>;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_d_syst_enum_values() TO <%= msbms_apiusr>;


COMMENT ON FUNCTION msbms_syst.trig_i_d_syst_enum_values() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_enum_values API View for DELETE operations.$DOC$;
