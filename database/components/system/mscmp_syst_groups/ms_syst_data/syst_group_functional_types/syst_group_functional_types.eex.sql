-- File:        syst_group_functional_types.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_groups/ms_syst_data/syst_group_functional_types/syst_group_functional_types.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE ms_syst_data.syst_group_functional_types
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_group_functional_types_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_group_functional_types_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_group_functional_types_display_name_udx UNIQUE
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

ALTER TABLE ms_syst_data.syst_group_functional_types OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_group_functional_types FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_group_functional_types TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_group_functional_types
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE ms_syst_data.syst_group_functional_types IS
$DOC$A relation for records identifying specific areas of functionality in the
application where specific Groups may be used.  This allows for our single
general means of defining groups to be useful in different contexts.

All maintenance of data in this relation is expected to be system maintained,
with the exception of user descriptions.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_group_functional_types.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_group_functional_types.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_group_functional_types.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_group_functional_types.syst_description IS
$DOC$A system defined text documenting the Group Functional Type and expected use
cases.  This value may be overridden by a user provided text via a non-null
`user_description` column value.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_group_functional_types.user_description IS
$DOC$A user provided textual description of the Group Functional Type and its
expected use cases.  If the value of this column is null, users will see the
system provided text stored in `syst_description`.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_group_functional_types.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_group_functional_types.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_group_functional_types.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_group_functional_types.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_group_functional_types.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_group_functional_types.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_group_functional_types.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
