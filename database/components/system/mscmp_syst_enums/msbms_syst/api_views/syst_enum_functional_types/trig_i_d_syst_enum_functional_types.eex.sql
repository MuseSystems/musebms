CREATE OR REPLACE FUNCTION msbms_syst.trig_i_d_syst_enum_functional_types()
RETURNS trigger AS
$BODY$

-- File:        trig_i_d_syst_enum_functional_types.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_enums/msbms_syst/api_views/syst_enum_functional_types/trig_i_d_syst_enum_functional_types.eex.sql
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

    IF old.syst_defined THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'You cannot delete a system defined enumeration ' ||
                          'functional type using the API Views.',
                DETAIL = msbms_syst_priv.get_exception_details(
                             p_proc_schema    => 'msbms_syst'
                            ,p_proc_name      => 'trig_i_d_syst_enum_functional_types'
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

    DELETE
    FROM msbms_syst_data.syst_enum_functional_types
    WHERE id = old.id
    RETURNING INTO old
          id
        , internal_name
        , display_name
        , external_name
        , old.syst_defined
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

    RETURN old;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO msbms_syst, pg_temp;

ALTER FUNCTION msbms_syst.trig_i_d_syst_enum_functional_types()
    OWNER TO <%= msbms_owner %>;

REVOKE EXECUTE ON FUNCTION msbms_syst.trig_i_d_syst_enum_functional_types() FROM public;

COMMENT ON FUNCTION msbms_syst.trig_i_d_syst_enum_functional_types() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_enum_functional_types API View for DELETE operations.$DOC$;
