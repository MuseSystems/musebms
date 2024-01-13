-- File:        syst_menu_items.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_nav/ms_syst_data/syst_menu_items/syst_menu_items.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE ms_syst_data.syst_menu_items
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
        CONSTRAINT syst_menu_items_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_menu_items_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_menu_items_display_name_udx UNIQUE
    ,external_name
        text
        NOT NULL
    ,menu_id
        uuid
        NOT NULL
        CONSTRAINT syst_menu_items_menu_fk
            REFERENCES ms_syst_data.syst_menus ( id )
            ON DELETE CASCADE
    ,parent_menu_item_id
        uuid
        CONSTRAINT syst_menu_items_parent_menu_item_fk
            REFERENCES ms_syst_data.syst_menu_items ( id )
    ,sort_order
        smallint
        NOT NULL
    ,CONSTRAINT syst_menu_items_sort_ordering_udx
            UNIQUE NULLS NOT DISTINCT ( menu_id, parent_menu_item_id, sort_order )
    ,submenu_menu_id
        uuid
        CONSTRAINT syst_menu_items_submenu_menu_fk
            REFERENCES ms_syst_data.syst_menus ( id )
    ,action_id
        uuid
        CONSTRAINT syst_menu_items_action_fk
            REFERENCES ms_syst_data.syst_actions ( id )
    ,syst_description
        text
        NOT NULL
    ,user_description
        text
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
);

ALTER TABLE ms_syst_data.syst_menu_items OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_menu_items FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_menu_items TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_menu_items
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

DO
$DOCUMENTATION$
DECLARE
    -- Table
    var_comments_config ms_syst_priv.comments_config_table;

    -- Columns
    var_menu_id             ms_syst_priv.comments_config_table_column;
    var_parent_menu_item_id ms_syst_priv.comments_config_table_column;
    var_sort_order          ms_syst_priv.comments_config_table_column;
    var_submenu_menu_id     ms_syst_priv.comments_config_table_column;
    var_action_id           ms_syst_priv.comments_config_table_column;

BEGIN

    --
    -- Table Config
    --

    var_comments_config.table_schema := 'ms_syst_data';
    var_comments_config.table_name   := 'syst_menu_items';

    var_comments_config.description :=
$DOC$Individual menu entries which can serve as actionable menu items, grouping
items, references to other menus to include recursively, or any appropriate
combination thereof.$DOC$;

    --
    -- Column Configs
    --

    var_menu_id.column_name := 'menu_id';
    var_menu_id.description :=
$DOC$Identifies the Menu to which the menu item belongs.$DOC$;

    var_parent_menu_item_id.column_name := 'parent_menu_item_id';
    var_parent_menu_item_id.description :=
$DOC$References the current Menu Item's parent Menu Item record.  If the current Menu
Item record is at the root of the Menu, this value will be `NULL`.$DOC$;

    var_sort_order.column_name := 'sort_order';
    var_sort_order.description :=
$DOC$Establishes the current Menu Item's sorting order relative to sibling Menu Item
records$DOC$;

COMMENT ON
    CONSTRAINT syst_menu_items_sort_ordering_udx ON ms_syst_data.syst_menu_items IS
$DOC$Enforces that sorting of sibling Menu Item records is unambiguous and
deterministic.$DOC$;

    var_submenu_menu_id.column_name := 'submenu_menu_id';
    var_submenu_menu_id.description :=
$DOC$When not null, indicates that the Menu Item record imports an independently
defined Menu.$DOC$;
    var_submenu_menu_id.general_usage :=
$DOC$An attempt to associate a Menu which recursively references the current Menu
Item's parent Menu will result in an exception being raised and the transaction
attempting to make the association will be rolled back.

Note that the referenced Menu's descriptive texts and naming will supersede the
naming specified directly by this record or the text of any associated Menu
Action referenced in the `action_id` column.$DOC$;

    var_action_id.column_name := 'action_id';
    var_action_id.description :=
$DOC$Associates a specific action to be invoked when the Menu Item that the
record represents is "selected".$DOC$;
    var_action_id.general_usage :=
$DOC$Note that the referenced Action's texts will supersede the Menu Item texts in
any user facing situations, though if the Menu Item is also associated with a
Menu (`submenu_menu_id`), the Menu's text will prevail.$DOC$;

    var_comments_config.columns :=
        ARRAY [
              var_menu_id
            , var_parent_menu_item_id
            , var_sort_order
            , var_submenu_menu_id
            , var_action_id
            ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config );

END;
$DOCUMENTATION$;
