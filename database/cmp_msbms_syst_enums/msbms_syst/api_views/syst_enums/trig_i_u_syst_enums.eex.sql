CREATE OR REPLACE FUNCTION msbms_syst.trig_i_u_syst_enums()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_enums.eex.sql
-- Location:    database\cmp_msbms_syst_enums\msbms_syst\api_views\syst_enums\trig_i_u_syst_enums.eex.sql
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

    IF old.syst_defined AND new.internal_name != old.internal_name THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'The requested data update included changes to fields disallowed ' ||
                          'by the business rules of the API View.',
                DETAIL = msbms_syst_priv.get_exception_details(
                             p_proc_schema    => 'msbms_syst'
                            ,p_proc_name      => 'trig_i_u_syst_enums'
                            ,p_exception_name => 'invalid_api_view_call'
                            ,p_errcode        => 'PM008'
                            ,p_param_data     => to_jsonb(new)
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

    UPDATE msbms_syst_data.syst_enums SET
          internal_name        = new.internal_name
        , display_name         = new.display_name
        , user_description     = new.user_description
        , default_user_options = new.default_user_options
    WHERE id = new.id
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

ALTER FUNCTION msbms_syst.trig_i_u_syst_enums()
    OWNER TO <%= msbms_owner %>;

REVOKE EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_enums() FROM public;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_enums() TO <%= msbms_appusr %>;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_enums() TO <%= msbms_apiusr %>;


COMMENT ON FUNCTION msbms_syst.trig_i_u_syst_enums() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_enums API View for UPDATE operations.$DOC$;
