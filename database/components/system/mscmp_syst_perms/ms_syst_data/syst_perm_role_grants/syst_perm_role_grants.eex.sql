-- File:        syst_perm_role_grants.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_perms/ms_syst_data/syst_perm_role_grants/syst_perm_role_grants.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE ms_syst_data.syst_perm_role_grants
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_perm_role_grants_pk PRIMARY KEY
    ,perm_role_id
        uuid
        NOT NULL
        CONSTRAINT syst_perm_role_grants_perm_role_fk
            REFERENCES ms_syst_data.syst_perm_roles ( id )
            ON DELETE CASCADE
    ,perm_id
        uuid
        NOT NULL
        CONSTRAINT syst_perm_role_grants_perm_fk
            REFERENCES ms_syst_data.syst_perms ( id )
            ON DELETE CASCADE
    ,CONSTRAINT syst_perm_role_grants_perm_perm_role_udx
        UNIQUE ( perm_role_id, perm_id )
    ,view_scope
        text
        NOT NULL
    ,maint_scope
        text
        NOT NULL
    ,admin_scope
        text
        NOT NULL
    ,ops_scope
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

ALTER TABLE ms_syst_data.syst_perm_role_grants OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_perm_role_grants FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_perm_role_grants TO <%= ms_owner %>;

CREATE TRIGGER b50_trig_b_iu_syst_perm_role_grants_default_scopes
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_perm_role_grants
    FOR EACH ROW
    WHEN ( new.view_scope IS NULL OR
           new.maint_scope IS NULL OR
           new.admin_scope IS NULL OR
           new.ops_scope IS NULL )
    EXECUTE PROCEDURE ms_syst_data.trig_b_iu_syst_perm_role_grants_default_scopes();

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_perm_role_grants
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER c50_trig_a_iu_syst_perm_role_grants_related_data_checks
    AFTER INSERT OR UPDATE ON ms_syst_data.syst_perm_role_grants
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_data.trig_a_iu_syst_perm_role_grants_related_data_checks();

COMMENT ON
    TABLE ms_syst_data.syst_perm_role_grants IS
$DOC$Establishes the individual permissions which are granted by the given permission
role.

Note that the absence of an explicit permission grant to a role is an implicit
denial of that permission.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_perm_role_grants.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_perm_role_grants.perm_role_id IS
$DOC$Identifies the role to which the permission grant is being made.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_perm_role_grants.perm_id IS
$DOC$The permission being granted by the role.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_perm_role_grants.view_scope IS
$DOC$Assigns the Scope of the Permission's View Right being granted by the Role.

The valid Scope options are defined by the Permission record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_perm_role_grants.maint_scope IS
$DOC$Assigns the Scope of the Permission's Maintenance Right being granted by the
Role.

The valid Scope options are defined by the Permission record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_perm_role_grants.admin_scope IS
$DOC$Assigns the Scope of the Permission's Data Administration Right being granted by
the Role.

The valid Scope options are defined by the Permission record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_perm_role_grants.ops_scope IS
$DOC$Assigns the Scope of the Permission's Operations Right being granted by the
Role.

The valid Scope options are defined by the Permission record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_perm_role_grants.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_perm_role_grants.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_perm_role_grants.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_perm_role_grants.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_perm_role_grants.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_perm_role_grants.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_perm_role_grants.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
