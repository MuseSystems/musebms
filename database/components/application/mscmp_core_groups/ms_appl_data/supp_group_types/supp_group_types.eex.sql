-- File:        supp_group_types.eex.sql
-- Location:    musebms/database/components/application/mscmp_core_groups/ms_appl_data/supp_group_types/supp_group_types.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE ms_appl_data.supp_group_types
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT supp_group_types_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT supp_group_types_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT supp_group_types_display_name_udx UNIQUE
    ,functional_type_id
        uuid
        NOT NULL
        CONSTRAINT supp_group_types_group_functional_type_fk
            REFERENCES ms_appl_data.supp_group_functional_types ( id )
            ON DELETE CASCADE
    ,syst_defined
        boolean
        NOT NULL DEFAULT FALSE
    ,user_maintainable
        boolean
        NOT NULL DEFAULT TRUE
    ,syst_description
        text
        NOT NULL
    ,user_description
        text
        NOT NULL
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

ALTER TABLE ms_appl_data.supp_group_types OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_appl_data.supp_group_types FROM public;
GRANT ALL ON TABLE ms_appl_data.supp_group_types TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_appl_data.supp_group_types
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE ms_appl_data.supp_group_types IS
$DOC$Establishes a hierarchical template for Group parent/child relationships to
follow. The Group Type relation creates a type of hierarchy which is linked
to a specific feature or functional area of the application via a record's
`functional_type_id` reference. The Group Type is also the parent relation
of Group Type Item relation (`ms_appl_data.supp_group_type_items`)
records where each Group Type Item record represents a level of the
hierarchy.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.supp_group_types.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.supp_group_types.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.supp_group_types.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN ms_appl_data.supp_group_types.functional_type_id IS
$DOC$A reference indicating in which specific functional area or with which feature
of the application the Group Type allows for its child Groups.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.supp_group_types.syst_defined IS
$DOC$Indicates whether or not the Group Type is system created for specific
purposes within the application or user created and fully manageable by the
user.  A true value in this column indicates that a record is system created and
managed whereas a false value indicates a user created and managed Group Type.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.supp_group_types.user_maintainable IS
$DOC$If a record is System Defined (`syst_defined` is true) this value will
determine if some aspects of the Group Type and Group Type Items are user
maintainable.  Principally this will indicate whether or not the Group Type
Items may be created or deleted by users or if the Group Type Item structure is
only maintainable by the system.

Note that the value of this column has no effect for user defined fields
(`syst_defined` is false) and will not have any bearing on the maintainability
of the `user_description` fields as those fields are always user maintainable.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.supp_group_types.syst_description IS
$DOC$A system defined description of a record's purpose and use cases which may be
presented to end users.  This value may be overridden by setting the
`user_description` column to a non-null value.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.supp_group_types.user_description IS
$DOC$An optional user provided description of the record purpose and use cases.
When this column is non-null, the value will override the text defined by the
`syst_description` column.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.supp_group_types.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.supp_group_types.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.supp_group_types.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.supp_group_types.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.supp_group_types.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.supp_group_types.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.supp_group_types.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
