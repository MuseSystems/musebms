CREATE OR REPLACE FUNCTION msbms_syst.trig_i_i_syst_enum_functional_types()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_enum_functional_types.eex.sql
-- Location:    musebms/database/cmp_msbms_syst_enums/msbms_syst/api_views/syst_enum_functional_types/trig_i_i_syst_enum_functional_types.eex.sql
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
    var_syst_defined boolean;
BEGIN
    SELECT syst_defined INTO var_syst_defined
    FROM msbms_syst_data.syst_enums
    WHERE id = new.enum_id;

    IF var_syst_defined THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'The functional type creation for the requested ' ||
                          'enumeration is invalid.',
                DETAIL = msbms_syst_priv.get_exception_details(
                             p_proc_schema    => 'msbms_syst'
                            ,p_proc_name      => 'trig_i_i_syst_enum_functional_types'
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

    INSERT INTO msbms_syst_data.syst_enum_functional_types
        (  internal_name
         , display_name
         , external_name
         , enum_id
         , syst_description
         , user_description)
    VALUES
        (  new.internal_name
         , new.display_name
         , new.external_name
         , new.enum_id
         , '(System Description Not Available)'
         , new.user_description)
    RETURNING INTO new
          id
        , internal_name
        , display_name
        , external_name
        , var_syst_defined
        , enum_id
        , syst_description
        , user_description
        , diag_timestamp_created
        , diag_role_created
        , diag_timestamp_modified
        , diag_wallclock_modified
        , diag_role_modified
        , diag_row_version
        , diag_update_count ;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO msbms_syst, pg_temp;

ALTER FUNCTION msbms_syst.trig_i_i_syst_enum_functional_types()
    OWNER TO <%= msbms_owner %>;

REVOKE EXECUTE ON FUNCTION msbms_syst.trig_i_i_syst_enum_functional_types() FROM public;

COMMENT ON FUNCTION msbms_syst.trig_i_i_syst_enum_functional_types() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_enum_functional_types API View for INSERT operations.

Note that the parent msbms_syst_data.syst_enums.syst_defined determines whether
or not child msbms_syst_data.syst_enum_functional_types records are considered
system defined.$DOC$;
