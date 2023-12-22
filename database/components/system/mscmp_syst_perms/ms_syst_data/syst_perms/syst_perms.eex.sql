-- File:        syst_perms.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_perms/ms_syst_data/syst_perms/syst_perms.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE ms_syst_data.syst_perms
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
        CONSTRAINT syst_perms_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_perms_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_perms_display_name_udx UNIQUE
    ,perm_functional_type_id
        uuid
        NOT NULL
        CONSTRAINT syst_perms_perm_functional_type_fk
            REFERENCES ms_syst_data.syst_perm_functional_types ( id )
    ,syst_defined
        boolean
        NOT NULL DEFAULT FALSE
    ,syst_description
        text
        NOT NULL
    ,user_description
        text
    ,view_scope_options
        text[]
        NOT NULL DEFAULT ARRAY ['unused']::text[]
        CONSTRAINT syst_perms_view_scope_options_chk
            CHECK ( cardinality(view_scope_options) > 0 AND
                    view_scope_options <@ ARRAY ['unused', 'deny', 'same_user', 'same_group', 'all']::text[] )
    ,maint_scope_options
        text[]
        NOT NULL DEFAULT ARRAY ['unused']::text[]
        CONSTRAINT syst_perms_maint_scope_options_chk
            CHECK ( cardinality(maint_scope_options) > 0 AND
                    maint_scope_options <@ ARRAY ['unused', 'deny', 'same_user', 'same_group', 'all']::text[] )
    ,admin_scope_options
        text[]
        NOT NULL DEFAULT ARRAY ['unused']::text[]
        CONSTRAINT syst_perms_admin_scope_options_chk
            CHECK ( cardinality(admin_scope_options) > 0 AND
                    admin_scope_options <@ ARRAY ['unused', 'deny', 'same_user', 'same_group', 'all']::text[] )
    ,ops_scope_options
        text[]
        NOT NULL DEFAULT ARRAY ['unused']::text[]
        CONSTRAINT syst_perms_ops_scope_options_chk
            CHECK ( cardinality(ops_scope_options) > 0 AND
                    ops_scope_options <@ ARRAY ['unused', 'deny', 'same_user', 'same_group', 'all']::text[] )
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

ALTER TABLE ms_syst_data.syst_perms OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_perms FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_perms TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_perms
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE ms_syst_data.syst_perms IS
$DOC$Defines the available system and application permissions which can be
assigned to users.

The Permission is divided into the following concepts:

    1- The Permission record itself defines a subject for which application
    security and control concerns exist.

    2- Each Permission is made up of standard Rights.  These Rights are:

        * View - the ability to view data.

        * Maintenance - the ability to change or process existing data.

        * Administration - the ability to create or destroy data.

        * Operations - the ability to perform certain operations or processes.

    3- The Right for each Permission is assigned a Scope of applicability which
    can limit or extend the grant of a Right.  Each Right of the Permission may
    define which Scopes it supports out of the following possibilities:

        * Unused - The Right does not exist in any meaningful way for the
        Permission.

        * Deny - The Right is not granted by the Permission grant; this is
        typically used in cases where other Rights may be granted, for example
        permitting a user to see a value (View Right), but not to Maintain or
        perform data Admin tasks (Maint & Admin Rights).

        * Same User - The Right grant is limited in Scope to those records which
        are in some way designated as belonging to the specific user exercising
        the Right.  Ownership designation will be defined by those functions
        where a Permission is checked.

        * Same Group - The Right grant is limited in Scope to those records
        which are in some way designated as belonging to a specific group or
        groups and to which the user belongs in some way.  Ownership designation
        will be defined by those functions where a Permission is checked.

        * All - The Right grant is not limited in Scope and all records which
        are subject to the Permission are available to the user.

Permissions are assigned to Permission Roles which are in turn granted to
individual users.  If a Permission is not assigned to a Permission Role, then
the assumption is that the Permission Role's users are denied all rights granted
by the unassigned Permission.

Some Permissions may be dependent on the grants of other more fundamental
Permissions.  For example, a user may be granted only View Rights to the sales
order form, but also granted Maintenance Rights to sales pricing data.  In such
a case the sales order Rights would dictate that the user does not have the
ability to maintain sales pricing in the sales order context.

Specific details of applicability and the determination of Scope boundaries will
vary by each specific scenario.  Consult individual Permission documentation for
specific understanding of how determinations of access are made.
$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_perms.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_perms.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_perms.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_perms.perm_functional_type_id IS
$DOC$Assigns the Permission to a specific Permission Functional Type.

Permissions may only be granted in Permission Roles of the same Permission
Functional Type.$DOC$;

COMMENT ON
     COLUMN ms_syst_data.syst_perms.syst_defined IS
$DOC$If true, indicates that the permission was created by the system or system
installation process.  A false value indicates that the record was user created.$DOC$;

COMMENT ON
     COLUMN ms_syst_data.syst_perms.syst_description IS
$DOC$A system default description describing the permission and its uses in the
system.$DOC$;

COMMENT ON
     COLUMN ms_syst_data.syst_perms.user_description IS
$DOC$A custom user defined description which overrides the syst_description value
where it would otherwise be used.  If this column is set NULL the
syst_description value will be used.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_perms.view_scope_options IS
$DOC$If applicable, enumerates the available Scopes of viewable data offered by the
permission.  If not applicable the only option will be 'unused'.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_perms.maint_scope_options IS
$DOC$If applicable, enumerates the available Scopes of maintainable data offered by
the permission.  Maintenance in this context refers to changing existing data.
If not applicable the only option will be 'unused'.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_perms.admin_scope_options IS
$DOC$If applicable, enumerates the available Scopes of data administration offered
by the permission.  Administration in this context refers to creating or
deleting records.  If not applicable the only option will be 'unused'.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_perms.ops_scope_options IS
$DOC$If applicable, enumerates the available Scopes of a given operation or
processing capability offered by the permission.  If not applicable the only
option will be 'unused'.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_perms.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_perms.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_perms.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_perms.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_perms.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_perms.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_perms.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
