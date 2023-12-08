-- File:        syst_hierarchies.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_hierarchy/ms_syst_data/syst_hierarchies/syst_hierarchies.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE ms_syst_data.syst_hierarchies
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_hierarchies_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_hierarchies_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_hierarchies_display_name_udx UNIQUE
    ,hierarchy_type_id
        uuid
        NOT NULL
        CONSTRAINT syst_hierarchies_hierarchy_type_fk
            REFERENCES ms_syst_data.syst_enum_items ( id )
            ON DELETE CASCADE
    ,hierarchy_state_id
        uuid
        NOT NULL
        CONSTRAINT syst_hierarchies_hierarchy_state_fk
            REFERENCES ms_syst_data.syst_enum_items ( id )
    ,syst_defined
        boolean
        NOT NULL DEFAULT FALSE
    ,user_maintainable
        boolean
        NOT NULL DEFAULT TRUE
    ,structured
        boolean
        NOT NULL DEFAULT TRUE
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

ALTER TABLE ms_syst_data.syst_hierarchies OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_hierarchies FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_hierarchies TO <%= ms_owner %>;

CREATE TRIGGER c50_trig_b_i_syst_hierarchies_validate_inactive
    BEFORE INSERT ON ms_syst_data.syst_hierarchies
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_data.trig_b_i_syst_hierarchies_validate_inactive();

CREATE TRIGGER c50_trig_b_u_syst_hierarchies_validate_state_change
    BEFORE UPDATE ON ms_syst_data.syst_hierarchies
    FOR EACH ROW WHEN ( old.hierarchy_state_id != new.hierarchy_state_id )
        EXECUTE PROCEDURE ms_syst_data.trig_b_u_syst_hierarchies_validate_state_change();

CREATE TRIGGER c55_trig_b_u_syst_hierarchies_validate_structured
    BEFORE UPDATE ON ms_syst_data.syst_hierarchies
    FOR EACH ROW WHEN ( old.structured != new.structured )
        EXECUTE PROCEDURE ms_syst_data.trig_b_u_syst_hierarchies_validate_structured();

CREATE TRIGGER c50_trig_b_d_syst_hierarchies_validate_prereqs
    BEFORE DELETE ON ms_syst_data.syst_hierarchies
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_data.trig_b_d_syst_hierarchies_validate_prereqs();

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_hierarchies
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_hierarchy_states_enum_item_check
    AFTER INSERT ON ms_syst_data.syst_hierarchies
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('hierarchy_states', 'hierarchy_state_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_hierarchy_states_enum_item_check
    AFTER UPDATE ON ms_syst_data.syst_hierarchies
    FOR EACH ROW WHEN ( old.hierarchy_state_id != new.hierarchy_state_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_enum_item_check(
                'hierarchy_states', 'hierarchy_state_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_i_hierarchy_types_enum_item_check
    AFTER INSERT ON ms_syst_data.syst_hierarchies
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('hierarchy_types', 'hierarchy_type_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_hierarchy_types_enum_item_check
    AFTER UPDATE ON ms_syst_data.syst_hierarchies
    FOR EACH ROW WHEN ( old.hierarchy_type_id != new.hierarchy_type_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_enum_item_check(
                'hierarchy_types', 'hierarchy_type_id');

COMMENT ON
    TABLE ms_syst_data.syst_hierarchies IS
$DOC$Establishes a hierarchical template for parent/child relationships to
follow. The `hierarchies` relation creates a type of hierarchy which is linked
to a specific feature or functional area of the application via a record's
`hierarchy_type_id` reference. Hierarchies is also the parent relation of
Hierarchy Items relation (`ms_syst_data.syst_hierarchy_items`)
records where each Hierarchy Items record represents a level of the
hierarchy.

Note that once the Hierarchy is active and in use by Hierarchy implementing
Components, most changes to the Hierarchy records will not be allowed to ensure
the consistency of currently used data.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_hierarchies.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_hierarchies.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_hierarchies.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_hierarchies.hierarchy_type_id IS
$DOC$A reference indicating in which specific functional area or with which feature
of the application the Hierarchy is associated with.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_hierarchies.hierarchy_state_id IS
$DOC$A reference indicating at which point in the Hierarchy life-cycle the record
sits.  The record may only be set in an `active` state if the record and any
associated Hierarchy Item records are in a consistent, valid state.  Similarly,
the record may only be set to an `inactive` state if the Hierarchy record is not
in use, which is defined as the record being referenced by an Hierarchy
implementing Component's records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_hierarchies.syst_defined IS
$DOC$Indicates whether or not the Hierarchies record is system created for specific
purposes within the application or user created and fully manageable by the
user.  A true value in this column indicates that a record is system created and
managed whereas a false value indicates a user created and managed Hierarchy.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_hierarchies.user_maintainable IS
$DOC$If a record is System Defined (`syst_defined` is true) this value will
determine if some aspects of the Hierarchy and Hierarchy Items are user
maintainable.  Principally this will indicate whether or not the Hierarchy
Items may be created or deleted by users or if the Hierarchy Item structure is
only maintainable by the system.

Note that the value of this column has no effect for user defined fields
(`syst_defined` is false) and will not have any bearing on the maintainability
of the `user_description` fields as those fields are always user maintainable.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_hierarchies.structured IS
$DOC$A flag indicating whether or not the Hierarchy actually defines a structure, or
if the any implementations allow fully ad hoc structuring within the
implementing Component.

This configuration exists for cases where a Component implements Hierarchy
functionality, but can also operate while bypassing any hierarchy checks at all;
this way we can still require a Hierarchy record reference in the implementation
while allowing the Hierarchy definition itself be the configuration point for
determining whether or not hierarchical structure is required.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_hierarchies.syst_description IS
$DOC$A system defined description of a record's purpose and use cases which may be
presented to end users.  This value may be overridden by setting the
`user_description` column to a non-null value.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_hierarchies.user_description IS
$DOC$An optional user provided description of the record purpose and use cases.
When this column is non-null, the value will override the text defined by the
`syst_description` column.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_hierarchies.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_hierarchies.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_hierarchies.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_hierarchies.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_hierarchies.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_hierarchies.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_hierarchies.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
