CREATE OR REPLACE FUNCTION ms_appl.trig_i_i_supp_group_type_items()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_supp_group_type_items.eex.sql
-- Location:    musebms/database/components/application/mscmp_core_groups/ms_appl/api_views/supp_group_type_items/trig_i_i_supp_group_type_items.eex.sql
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
        ( SELECT syst_defined AND NOT user_maintainable
          FROM ms_appl_data.supp_group_types
          WHERE id = new.group_type_id )
    THEN

        RAISE EXCEPTION
            USING
                MESSAGE = 'You cannot insert a Group Type Item record that ' ||
                          'is a child of a system defined, non-user maintainable ' ||
                          'Group Type.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_appl'
                            ,p_proc_name      => 'trig_i_i_supp_group_type_items'
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

    INSERT INTO ms_appl_data.supp_group_type_items
        ( internal_name
        , display_name
        , external_name
        , group_type_id
        , hierarchy_depth )
    VALUES
        ( new.internal_name
        , new.display_name
        , new.external_name
        , new.group_type_id
        , new.hierarchy_depth )
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_appl, pg_temp;

ALTER FUNCTION ms_appl.trig_i_i_supp_group_type_items()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_appl.trig_i_i_supp_group_type_items() FROM public;
GRANT EXECUTE ON FUNCTION ms_appl.trig_i_i_supp_group_type_items() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_appl.trig_i_i_supp_group_type_items() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
supp_group_type_items API View for INSERT operations.$DOC$;
