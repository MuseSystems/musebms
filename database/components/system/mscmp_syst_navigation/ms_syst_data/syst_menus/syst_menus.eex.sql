-- File:        syst_menus.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_navigation/ms_syst_data/syst_menus/syst_menus.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE ms_syst_data.syst_menus
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_menus_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_menus_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_menus_display_name_udx UNIQUE
    ,menu_state_id
        uuid
        NOT NULL
        CONSTRAINT syst_menus_menu_state_fk
            REFERENCES ms_syst_data.syst_enum_items ( id )
    ,syst_description
        text
        NOT NULL
    ,user_description
        text
    ,syst_defined
        boolean
        NOT NULL DEFAULT FALSE
    ,user_maintainable
        boolean
        NOT NULL DEFAULT TRUE
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

ALTER TABLE ms_syst_data.syst_menus OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_menus FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_menus TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_menus
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_menu_states_enum_item_check
    AFTER INSERT ON ms_syst_data.syst_menus
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('menu_states', 'menu_state_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_menu_states_enum_item_check
    AFTER UPDATE ON ms_syst_data.syst_menus
    FOR EACH ROW WHEN ( old.menu_state_id != new.menu_state_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_enum_item_check(
                'menu_states', 'menu_state_id');


COMMENT ON
    TABLE ms_syst_data.syst_menus IS
$DOC$Establishes user configurable menu and navigation definitions for use in the
User Interfaces of the application.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_menus.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_menus.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_menus.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
        COLUMN ms_syst_data.syst_menus.menu_state_id IS
$DOC$Indicates at which life-cycle stage the record exists.  Functionally, this
breaks down into "active" and "inactive" states.$DOC$;

COMMENT ON
        COLUMN ms_syst_data.syst_menus.syst_description IS
$DOC$A system default description describing the Menu and its uses in the system.$DOC$;

COMMENT ON
        COLUMN ms_syst_data.syst_menus.user_description IS
$DOC$A custom, user defined description which overrides the syst_description value
where it would otherwise be used.  If this column is set NULL the
syst_description value will be used.$DOC$;

COMMENT ON
        COLUMN ms_syst_data.syst_menus.syst_defined IS
$DOC$A value of `TRUE` indicates that the record and any child records are created
and maintained automatically by the system.$DOC$;

COMMENT ON
        COLUMN ms_syst_data.syst_menus.user_maintainable IS
$DOC$If `TRUE`, the system will allow some user maintenance of columns and child
records when the `syst_defined` column value is `TRUE`.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_menus.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_menus.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_menus.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_menus.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_menus.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_menus.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_menus.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
