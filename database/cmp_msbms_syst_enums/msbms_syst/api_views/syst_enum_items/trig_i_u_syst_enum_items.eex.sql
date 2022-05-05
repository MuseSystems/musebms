CREATE OR REPLACE FUNCTION msbms_syst.trig_i_u_syst_enum_items()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_enum_items.eex.sql
-- Location:    database\cmp_msbms_syst_enums\msbms_syst\api_views\syst_enum_items\trig_i_u_syst_enum_items.eex.sql
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

    IF
        old.syst_defined AND
        (new.internal_name != old.internal_name OR
         new.functional_type_id != old.functional_type_id)
    THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'The requested data update included changes to fields disallowed ' ||
                          'by the business rules of the API View.',
                DETAIL = msbms_syst_priv.get_exception_details(
                             p_proc_schema    => 'msbms_syst'
                            ,p_proc_name      => 'trig_i_u_syst_enum_items'
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

    UPDATE msbms_syst_data.syst_enum_items
    SET
        internal_name           = new.internal_name
      , display_name            = new.display_name
      , external_name           = new.external_name
      , functional_type_id      = new.functional_type_id
      , enum_default            = new.enum_default
      , functional_type_default = new.functional_type_default
      , user_description        = new.user_description
      , sort_order              = new.sort_order
      , user_options            = new.user_options
    WHERE id = new.id
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO msbms_syst, pg_temp;

ALTER FUNCTION msbms_syst.trig_i_u_syst_enum_items()
    OWNER TO <%= msbms_owner %>;

REVOKE EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_enum_items() FROM public;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_enum_items() TO <%= msbms_owner %>;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_u_syst_enum_items() TO <%= msbms_apiusr %>;


COMMENT ON FUNCTION msbms_syst.trig_i_u_syst_enum_items() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_enum_items API View for UPDATE operations.$DOC$;
