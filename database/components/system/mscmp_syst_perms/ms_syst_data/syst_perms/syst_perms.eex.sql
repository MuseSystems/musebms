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

DO
$DOCUMENTATION$
DECLARE
    -- Table
    var_comments_config ms_syst_priv.comments_config_table;

    -- Columns
    var_perm_functional_type_id ms_syst_priv.comments_config_table_column;
    var_view_scope_options      ms_syst_priv.comments_config_table_column;
    var_maint_scope_options     ms_syst_priv.comments_config_table_column;
    var_admin_scope_options     ms_syst_priv.comments_config_table_column;
    var_ops_scope_options       ms_syst_priv.comments_config_table_column;

BEGIN

    --
    -- Table Config
    --

    var_comments_config.table_schema := 'ms_syst_data';
    var_comments_config.table_name   := 'syst_perms';

    var_comments_config.description :=
$DOC$Defines the available system and application permissions which can be assigned
to users.

The Permission is divided into the following concepts:

  1. The Permission record itself defines a subject for which application
     security and control concerns exist.

  2. Each Permission is made up of standard Rights.  These Rights are:

      * View - the ability to view data.

      * Maintenance - the ability to change or process existing data.

      * Administration - the ability to create or destroy data.

      * Operations - the ability to perform certain operations or processes.

  3. The Right for each Permission is assigned a Scope of applicability which
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

     * Same Group - The Right grant is limited in Scope to those records which
       are in some way designated as belonging to a specific group or groups and
       to which the user belongs in some way.  Ownership designation will be
       defined by those functions where a Permission is checked.

     * All - The Right grant is not limited in Scope and all records which are
       subject to the Permission are available to the user.

Permissions are assigned to Permission Roles which are in turn granted to
individual users. If a Permission is not assigned to a Permission Role, then
the assumption is that the Permission Role's users are denied all rights granted
by the unassigned Permission.

Some Permissions may be dependent on the grants of other more fundamental
Permissions. For example, a user may be granted only View Rights to the sales
order form, but also granted Maintenance Rights to sales pricing data. In such
a case the sales order Rights would dictate that the user does not have the
ability to maintain sales pricing in the sales order context.

Specific details of applicability and the determination of Scope boundaries will
vary by each specific scenario. Consult individual Permission documentation for
specific understanding of how determinations of access are made.
$DOC$;

    --
    -- Column Configs
    --

    var_perm_functional_type_id.column_name := 'perm_functional_type_id';
    var_perm_functional_type_id.description :=
$DOC$Assigns the Permission to a specific Permission Functional Type.$DOC$;
    var_perm_functional_type_id.general_usage :=
$DOC$Permissions may only be granted in Permission Roles of the same Permission
Functional Type.$DOC$;

    var_view_scope_options.column_name := 'view_scope_options';
    var_view_scope_options.description :=
$DOC$If applicable, enumerates the available Scopes of viewable data offered by the
permission.$DOC$;
    var_view_scope_options.general_usage :=
$DOC$If not applicable the only option will be 'unused'.$DOC$;

    var_maint_scope_options.column_name := 'maint_scope_options';
    var_maint_scope_options.description :=
$DOC$If applicable, enumerates the available Scopes of maintainable data offered by
the permission.  Maintenance in this context refers to changing existing data.$DOC$;
    var_maint_scope_options.general_usage :=
$DOC$If not applicable the only option will be 'unused'.$DOC$;

    var_admin_scope_options.column_name := 'admin_scope_options';
    var_admin_scope_options.description :=
$DOC$If applicable, enumerates the available Scopes of data administration offered
by the permission.  Administration in this context refers to creating or
deleting records.$DOC$;
    var_admin_scope_options.general_usage :=
$DOC$If not applicable the only option will be 'unused'.$DOC$;

    var_ops_scope_options.column_name := 'ops_scope_options';
    var_ops_scope_options.description :=
$DOC$If applicable, enumerates the available Scopes of a given operation or
processing capability offered by the permission.$DOC$;
    var_ops_scope_options.general_usage :=
$DOC$If not applicable the only option will be 'unused'.$DOC$;

    var_comments_config.columns :=
        ARRAY [
              var_perm_functional_type_id
            , var_view_scope_options
            , var_maint_scope_options
            , var_admin_scope_options
            , var_ops_scope_options
            ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config );

END;
$DOCUMENTATION$;
