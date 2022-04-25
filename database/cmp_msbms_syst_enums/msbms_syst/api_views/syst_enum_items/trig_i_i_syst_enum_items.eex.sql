CREATE OR REPLACE FUNCTION msbms_syst.trig_i_i_syst_enum_items()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_enum_items.eex.sql
-- Location:    database\cmp_msbms_syst_enums\msbms_syst\api_views\syst_enum_items\trig_i_i_syst_enum_items.eex.sql
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
        exists( SELECT TRUE
                FROM msbms_syst_data.syst_enums
                WHERE id = new.enum_id AND syst_defined AND NOT user_maintainable)
    THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'You may not add new enumeration items for system defined ' ||
                          'enumerations that are not marked user maintainable.',
                DETAIL = msbms_syst_priv.get_exception_details(
                             p_proc_schema    => 'msbms_syst'
                            ,p_proc_name      => 'trig_i_i_syst_enum_items'
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

    INSERT INTO msbms_syst_data.syst_enum_items
        ( internal_name
        , display_name
        , external_name
        , enum_id
        , functional_type_id
        , enum_default
        , functional_type_default
        , syst_defined
        , user_maintainable
        , syst_description
        , user_description
        , sort_order
        , user_options )
    VALUES
        ( new.internal_name
        , new.display_name
        , new.external_name
        , new.enum_id
        , new.functional_type_id
        , new.enum_default
        , new.functional_type_default
        , FALSE
        , TRUE
        , '(System Description Not Available)'
        , new.user_description
        , new.sort_order
        , new.user_options )
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

ALTER FUNCTION msbms_syst.trig_i_i_syst_enum_items()
    OWNER TO <%= msbms_owner %>;

REVOKE EXECUTE ON FUNCTION msbms_syst.trig_i_i_syst_enum_items() FROM public;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_i_syst_enum_items() TO <%= msbms_owner %>;
GRANT EXECUTE ON FUNCTION msbms_syst.trig_i_i_syst_enum_items() TO <%= msbms_apiusr %>;

COMMENT ON FUNCTION msbms_syst.trig_i_i_syst_enum_items() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_enum_items API View for INSERT operations.$DOC$;
