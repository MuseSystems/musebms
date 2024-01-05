-- File:        syst_enum_items.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_enums/ms_syst/api_views/syst_enum_items/syst_enum_items.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE VIEW ms_syst.syst_enum_items AS
    SELECT
        id
      , internal_name
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
      , syst_options
      , user_options
      , diag_timestamp_created
      , diag_role_created
      , diag_timestamp_modified
      , diag_wallclock_modified
      , diag_role_modified
      , diag_row_version
      , diag_update_count
    FROM ms_syst_data.syst_enum_items;

ALTER VIEW ms_syst.syst_enum_items OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_enum_items FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_enum_items
    INSTEAD OF INSERT ON ms_syst.syst_enum_items
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_enum_items();

CREATE TRIGGER a50_trig_i_u_syst_enum_items
    INSTEAD OF UPDATE ON ms_syst.syst_enum_items
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_enum_items();

CREATE TRIGGER a50_trig_i_d_syst_enum_items
    INSTEAD OF DELETE ON ms_syst.syst_enum_items
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_enum_items();

DO
$DOCUMENTATION$
DECLARE
    var_view_config ms_syst_priv.comments_config_apiview;

    var_enum_id                 ms_syst_priv.comments_config_apiview_column;
    var_functional_type_id      ms_syst_priv.comments_config_apiview_column;
    var_enum_default            ms_syst_priv.comments_config_apiview_column;
    var_functional_type_default ms_syst_priv.comments_config_apiview_column;
    var_sort_order              ms_syst_priv.comments_config_apiview_column;
    var_syst_options            ms_syst_priv.comments_config_apiview_column;
    var_user_options            ms_syst_priv.comments_config_apiview_column;

BEGIN

    var_view_config.table_schema := 'ms_syst_data';
    var_view_config.table_name   := 'syst_enum_items';
    var_view_config.view_schema  := 'ms_syst';
    var_view_config.view_name    := 'syst_enum_items';
    var_view_config.syst_records := TRUE;
    var_view_config.syst_update  := TRUE;
    var_view_config.syst_delete  := FALSE;

    var_enum_id.column_name := 'enum_id';
    var_enum_id.required    := TRUE;
    var_enum_id.user_update := FALSE;

    var_functional_type_id.column_name := 'functional_type_id';

    var_enum_default.column_name      := 'enum_default';
    var_enum_default.default_value    := '`FALSE`';
    var_enum_default.syst_update_mode := 'maint';

    var_functional_type_default.column_name      := 'functional_type_default';
    var_functional_type_default.default_value    := '`FALSE`';
    var_functional_type_default.syst_update_mode := 'maint';

    var_sort_order.column_name      := 'sort_order';
    var_sort_order.required         := TRUE;
    var_sort_order.syst_update_mode := 'maint';

    var_syst_options.column_name := 'syst_options';
    var_syst_options.user_insert := FALSE;
    var_syst_options.user_update := FALSE;

    var_user_options.column_name      := 'user_options';
    var_user_options.syst_update_mode := 'always';

    var_view_config.columns :=
        ARRAY [
              var_enum_id
            , var_functional_type_id
            , var_enum_default
            , var_functional_type_default
            , var_sort_order
            , var_syst_options
            , var_user_options
            ]::ms_syst_priv.comments_config_apiview_column[];

    PERFORM ms_syst_priv.generate_comments_apiview( var_view_config );

END;
$DOCUMENTATION$;
