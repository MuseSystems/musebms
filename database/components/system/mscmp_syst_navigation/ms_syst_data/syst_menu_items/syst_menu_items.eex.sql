-- File:        syst_menu_items.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_navigation/ms_syst_data/syst_menu_items/syst_menu_items.eex.sql
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
        NOT NULL DEFAULT uuid_generate_v1( )
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
        UNIQUE( menu_id, parent_menu_item_id, sort_order )
        NULLS NOT DISTINCT ( parent_menu_item_id )
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

COMMENT ON
    TABLE ms_syst_data.syst_menu_items IS
$DOC$Individual menu entries which can serve as actionable menu items, grouping
items, references to other menus to include recursively, or any appropriate
combination thereof.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_menu_items.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_menu_items.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_menu_items.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions.

Please note that if this Menu Item record is also associated with either a Menu
(`submenu_menu_id`) or a Menu Action (`action_id`) then the value of this
column will be superseded by corresponding values of those records in most user
facing presentations.  In cases where associations of both a Menu and Menu
Action exist, the precedence texts is: Menu, Menu Action.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_menu_items.external_name IS
$DOC$A non-unique/non-key value used to display to users and external parties where
uniqueness is less of a concern than specific end user presentation.

Please note that if this Menu Item record is also associated with either a Menu
(`submenu_menu_id`) or a Menu Action (`action_id`) then the value of this
column will be superseded by corresponding values of those records in most user
facing presentations.  In cases where associations of both a Menu and Menu
Action exist, the precedence texts is: Menu, Menu Action.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_menu_items.menu_id IS
$DOC$Identifies the Menu to which the menu item belongs.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_menu_items.parent_menu_item_id IS
$DOC$References the current Menu Item's parent Menu Item record.  If the current Menu
Item record is at the root of the Menu, this value will be `NULL`.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_menu_items.sort_order IS
$DOC$Establishes the current Menu Item's sorting order relative to sibling Menu Item
records$DOC$;

COMMENT ON
    CONSTRAINT syst_menu_items_sort_ordering_udx ON ms_syst_data.syst_menu_items IS
$DOC$Enforces that sorting of sibling Menu Item records is unambiguous and
deterministic.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_menu_items.submenu_menu_id IS
$DOC$When not null, indicates that the Menu Item record imports an independently
defined Menu.

An attempt to associate a Menu which recursively references the current Menu
Item's parent Menu will result in an exception being raised and the transaction
attempting to make the association will be rolled back.

Note that the referenced Menu's descriptive texts and naming will supersede the
naming specified directly by this record or the text of any associated Menu
Action referenced in the `action_id` column.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_menu_items.action_id IS
$DOC$Associates a specific action to be invoked when the Menu Item that the
record represents is "selected".

Note that the referenced Menu Action's texts will supersede the Menu Item texts
in any user facing situations, though if the Menu Item is also associated with a
Menu (`submenu_menu_id`), the Menu's text will prevail.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_menu_items.syst_description IS
$DOC$A system default description describing the Menu Item and its uses in the
system.

Please note that if this Menu Item record is also associated with either a Menu
(`submenu_menu_id`) or a Menu Action (`action_id`) then the value of this
column will be superseded by corresponding values of those records in most user
facing presentations.  In cases where associations of both a Menu and Menu
Action exist, the precedence texts is: Menu, Menu Action.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_menu_items.user_description IS
$DOC$A custom, user defined description which overrides the syst_description value
where it would otherwise be used.  If this column is set NULL the
syst_description value will be used.

Please note that if this Menu Item record is also associated with either a Menu
(`submenu_menu_id`) or a Menu Action (`action_id`) then the value of this
column will be superseded by corresponding values of those records in most user
facing presentations.  In cases where associations of both a Menu and Menu
Action exist, the precedence texts is: Menu, Menu Action.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_menu_items.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_menu_items.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_menu_items.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_menu_items.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_menu_items.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_menu_items.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_menu_items.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
