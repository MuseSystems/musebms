-- File:        syst_password_history.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst_data/syst_password_history/syst_password_history.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE ms_syst_data.syst_password_history
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
        CONSTRAINT syst_password_history_pk PRIMARY KEY
    ,access_account_id
        uuid
        NOT NULL
        CONSTRAINT syst_password_history_access_account_fk
            REFERENCES ms_syst_data.syst_access_accounts ( id )
            ON DELETE CASCADE
    ,credential_data
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

ALTER TABLE ms_syst_data.syst_password_history OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_password_history FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_password_history TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_password_history
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE INDEX syst_password_history_access_account_idx ON ms_syst_data.syst_password_history ( access_account_id );

DO
$DOCUMENTATION$
DECLARE
    -- Table
    var_comments_config ms_syst_priv.comments_config_table;

    -- Columns
    var_access_account_id ms_syst_priv.comments_config_table_column;
    var_credential_data   ms_syst_priv.comments_config_table_column;

BEGIN

    --
    -- Table Config
    --

    var_comments_config.table_schema := 'ms_syst_data';
    var_comments_config.table_name   := 'syst_password_history';

    var_comments_config.description :=
$DOC$Keeps the history of access account prior passwords for enforcing the reuse
password rule.$DOC$;

    --
    -- Column Configs
    --

    var_access_account_id.column_name := 'access_account_id';
    var_access_account_id.description :=
        $DOC$The Access Account to which the password history record belongs.$DOC$;

    var_credential_data.column_name := 'credential_data';
    var_credential_data.description :=
        $DOC$The previously hashed password recorded for reuse comparisons.$DOC$;
    var_credential_data.general_usage :=
        $DOC$This is the same format as the existing active password credential.$DOC$;

    var_comments_config.columns :=
        ARRAY [
              var_access_account_id
            , var_credential_data
            ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config );

END;
$DOCUMENTATION$;
