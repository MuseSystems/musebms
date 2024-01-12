-- File:        syst_access_account_perm_role_assigns.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_mcp_perms/ms_syst_data/syst_access_account_perm_role_assigns/syst_access_account_perm_role_assigns.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE ms_syst_data.syst_access_account_perm_role_assigns
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
        CONSTRAINT syst_access_account_perm_role_assigns_pk PRIMARY KEY
    ,access_account_id
        uuid
        NOT NULL
        CONSTRAINT syst_access_account_perm_role_assigns_access_account_fk
            REFERENCES ms_syst_data.syst_access_accounts ( id )
            ON DELETE CASCADE
    ,perm_role_id
        uuid
        NOT NULL
        CONSTRAINT syst_access_account_perm_role_assigns_perm_role_fk
            REFERENCES ms_syst_data.syst_perm_roles ( id )
            ON DELETE CASCADE
    ,CONSTRAINT syst_access_account_perm_role_assigns_udx
        UNIQUE ( access_account_id, perm_role_id )
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

ALTER TABLE ms_syst_data.syst_access_account_perm_role_assigns OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_access_account_perm_role_assigns FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_access_account_perm_role_assigns TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_access_account_perm_role_assigns
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

DO
$DOCUMENTATION$
DECLARE
    -- Table
    var_comments_config ms_syst_priv.comments_config_table;

    -- Columns
    var_access_account_id ms_syst_priv.comments_config_table_column;
    var_perm_role_id      ms_syst_priv.comments_config_table_column;

BEGIN

    --
    -- Table Config
    --

    var_comments_config.table_schema := 'ms_syst_data';
    var_comments_config.table_name   := 'syst_access_account_perm_role_assigns';

    var_comments_config.description :=
$DOC$Assigns Permission Roles to Access Accounts providing an MCP authentication
mechanism.$DOC$;

    --
    -- Column Configs
    --

    var_access_account_id.column_name := 'access_account_id';
    var_access_account_id.description :=
$DOC$References the Access Account to which the Permission Role is being assigned.$DOC$;

    var_perm_role_id.column_name := 'perm_role_id';
    var_perm_role_id.description :=
$DOC$A reference to the Permission Role being assigned to the Access Account.$DOC$;

    var_comments_config.columns :=
        ARRAY [
              var_access_account_id
            , var_perm_role_id
            ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config );

END;
$DOCUMENTATION$;
