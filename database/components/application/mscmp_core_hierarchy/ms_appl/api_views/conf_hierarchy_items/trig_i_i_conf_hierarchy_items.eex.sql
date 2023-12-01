CREATE OR REPLACE FUNCTION ms_appl.trig_i_i_conf_hierarchy_items()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_conf_hierarchy_items.eex.sql
-- Location:    musebms/database/components/application/mscmp_core_hierarchy/ms_appl/api_views/conf_hierarchy_items/trig_i_i_conf_hierarchy_items.eex.sql
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
          FROM ms_appl_data.conf_hierarchies
          WHERE id = new.hierarchy_id )
    THEN

        RAISE EXCEPTION
            USING
                MESSAGE = 'You cannot insert a Hierarchy Item record that ' ||
                          'is a child of a system defined, non-user maintainable ' ||
                          'Hierarchy.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_appl'
                            ,p_proc_name      => 'trig_i_i_conf_hierarchy_items'
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

    INSERT INTO ms_appl_data.conf_hierarchy_items
        ( internal_name
        , display_name
        , external_name
        , hierarchy_id
        , hierarchy_depth
        , required
        , allow_leaf_nodes)
    VALUES
        ( new.internal_name
        , new.display_name
        , new.external_name
        , new.hierarchy_id
        , new.hierarchy_depth
        , new.required
        , new.allow_leaf_nodes)
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_appl, pg_temp;

ALTER FUNCTION ms_appl.trig_i_i_conf_hierarchy_items()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_appl.trig_i_i_conf_hierarchy_items() FROM public;
GRANT EXECUTE ON FUNCTION ms_appl.trig_i_i_conf_hierarchy_items() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_appl.trig_i_i_conf_hierarchy_items() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
conf_hierarchy_items API View for INSERT operations.$DOC$;
