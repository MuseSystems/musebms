CREATE OR REPLACE FUNCTION ms_syst.trig_i_u_syst_menu_items()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_menu_items.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_nav/ms_syst/api_views/syst_menu_items/trig_i_u_syst_menu_items.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

DECLARE

    var_exception_message text;
    var_exception_errcode text := 'PM008';

    var_context record;

BEGIN

    SELECT INTO var_context
        syst_defined
      , syst_defined AND NOT user_maintainable AS no_user_maint
    FROM ms_syst_data.syst_menu
    WHERE id = old.menu_id;

    CASE
        WHEN new.menu_id != old.menu_id THEN

            var_exception_message :=
                'Prohibited update requested.  You may not change the ' ||
                'parent Menu of this record using this API view.';

        WHEN new.parent_menu_item_id != old.parent_menu_item_id THEN

            var_exception_message :=
                'Prohibited update requested.  You may not change the ' ||
                'Parent Menu Item record of this record using this API view.';

        WHEN
            var_context.syst_defined AND new.internal_name != old.internal_name
        THEN

            var_exception_message :=
                'Prohibited update requested.  You may not change the ' ||
                'internal name value of a System Defined record.';

        WHEN
            var_context.no_user_maint AND new.sort_order != old.sort_order
        THEN

            var_exception_message :=
                'Prohibited update requested.  You may not change the ' ||
                'Menu Item sort ordering of System Defined Menus unless ' ||
                'the Menu is also marked User Maintainable.';

        WHEN
            var_context.no_user_maint AND
            new.submenu_menu_id != old.submenu_menu_id
        THEN

            var_exception_message :=
                'Prohibited update requested.  You may not change the ' ||
                'Sub Menu Item assignment of System Defined Menus unless ' ||
                'the Menu is also marked User Maintainable.';

        WHEN
            var_context.no_user_maint AND new.action_id != old.action_id
        THEN

            var_exception_message :=
                'Prohibited update requested.  You may not change the ' ||
                'Action assignment of System Defined Menus unless the Menu ' ||
                'is also marked User Maintainable.';

        ELSE var_exception_message := NULL::text;

    END CASE;

    IF var_exception_message IS NOT NULL THEN

        RAISE EXCEPTION
        USING
            MESSAGE = var_exception_message,
            DETAIL = ms_syst_priv.get_exception_details(
                         p_proc_schema    => 'ms_syst'
                        ,p_proc_name      => 'trig_i_u_syst_menu_items'
                        ,p_exception_name => 'invalid_api_view_call'
                        ,p_errcode        => var_exception_errcode
                        ,p_param_data     =>
                            jsonb_build_object( 'old', old, 'new', new)
                        ,p_context_data   =>
                            jsonb_build_object(
                                 'tg_op',         tg_op
                                ,'tg_when',       tg_when
                                ,'tg_schema',     tg_table_schema
                                ,'tg_table_name', tg_table_name)),
            ERRCODE = var_exception_errcode,
            SCHEMA = tg_table_schema,
            TABLE = tg_table_name;

    END IF;

    UPDATE ms_syst_data.syst_menu_items
    SET
        internal_name    = new.internal_name
      , display_name     = new.display_name
      , external_name    = new.external_name
      , sort_order       = new.sort_order
      , submenu_menu_id  = new.submenu_menu_id
      , action_id        = new.action_id
      , user_description = new.user_description
    WHERE id = new.id
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_u_syst_menu_items()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_menu_items() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_menu_items() TO <%= ms_owner %>;

DO
$DOCUMENTATION$
DECLARE
    -- Function
    var_comments_config ms_syst_priv.comments_config_function;

BEGIN

    --
    -- Function Config
    --

    var_comments_config.function_schema := 'ms_syst';
    var_comments_config.function_name   := 'trig_i_u_syst_menu_items';

    var_comments_config.trigger_function := TRUE;
    var_comments_config.trigger_timing   := ARRAY [ 'i' ]::text[ ];
    var_comments_config.trigger_ops      := ARRAY [ 'u' ]::text[ ];

    var_comments_config.description :=
$DOC$Processes incoming API View requests according to globally applicable business
rules and data validation requirements.$DOC$;

    PERFORM ms_syst_priv.generate_comments_function( var_comments_config );

END;
$DOCUMENTATION$;
