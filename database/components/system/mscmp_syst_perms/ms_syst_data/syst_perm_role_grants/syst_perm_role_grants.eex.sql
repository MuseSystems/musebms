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
        NOT NULL DEFAULT uuid_generate_v7( )
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

DO
$DOCUMENTATION$
DECLARE
    -- Table
    var_comments_config ms_syst_priv.comments_config_table;

    -- Columns
    var_perm_role_id ms_syst_priv.comments_config_table_column;
    var_perm_id      ms_syst_priv.comments_config_table_column;
    var_view_scope   ms_syst_priv.comments_config_table_column;
    var_maint_scope  ms_syst_priv.comments_config_table_column;
    var_admin_scope  ms_syst_priv.comments_config_table_column;
    var_ops_scope    ms_syst_priv.comments_config_table_column;

BEGIN

    --
    -- Table Config
    --

    var_comments_config.table_schema := 'ms_syst_data';
    var_comments_config.table_name   := 'syst_perm_role_grants';

    var_comments_config.description :=
$DOC$Establishes the individual permissions which are granted by the given permission
role.$DOC$;
    var_comments_config.general_usage :=
$DOC$Note that the absence of an explicit permission grant to a role is an implicit
denial of that permission.$DOC$;

    --
    -- Column Configs
    --

    var_perm_role_id.column_name := 'perm_role_id';
    var_perm_role_id.description :=
$DOC$Identifies the role to which the permission grant is being made.$DOC$;

    var_perm_id.column_name := 'perm_id';
    var_perm_id.description :=
$DOC$The permission being granted by the role.$DOC$;

    var_view_scope.column_name := 'view_scope';
    var_view_scope.description :=
$DOC$Assigns the Scope of the Permission's View Right being granted by the Role.$DOC$;
    var_view_scope.general_usage :=
$DOC$The valid Scope options are defined by the Permission record.$DOC$;

    var_maint_scope.column_name := 'maint_scope';
    var_maint_scope.description :=
$DOC$Assigns the Scope of the Permission's Maintenance Right being granted by the
Role.$DOC$;
    var_maint_scope.general_usage :=
$DOC$The valid Scope options are defined by the Permission record.$DOC$;

    var_admin_scope.column_name := 'admin_scope';
    var_admin_scope.description :=
$DOC$Assigns the Scope of the Permission's Data Administration Right being granted by
the Role.$DOC$;
    var_admin_scope.general_usage :=
$DOC$The valid Scope options are defined by the Permission record.$DOC$;

    var_ops_scope.column_name := 'ops_scope';
    var_ops_scope.description :=
$DOC$Assigns the Scope of the Permission's Operations Right being granted by the
Role.$DOC$;
    var_ops_scope.general_usage :=
$DOC$The valid Scope options are defined by the Permission record.$DOC$;

    var_comments_config.columns :=
        ARRAY [
              var_perm_role_id
            , var_perm_id
            , var_view_scope
            , var_maint_scope
            , var_admin_scope
            , var_ops_scope
            ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config );

END;
$DOCUMENTATION$;
