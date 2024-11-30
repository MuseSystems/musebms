-- File:        syst_credentials.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst_data/syst_credentials/syst_credentials.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_credentials
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
        CONSTRAINT syst_credentials_pk PRIMARY KEY
    ,access_account_id
        uuid
        NOT NULL
        CONSTRAINT syst_credentials_access_accounts_fk
            REFERENCES ms_syst_data.syst_access_accounts (id) ON DELETE CASCADE
    ,credential_type_id
        uuid
        NOT NULL
        CONSTRAINT syst_credentials_credential_types_fk
            REFERENCES ms_syst_data.syst_enum_items (id)
    ,credential_for_identity_id
        uuid
        CONSTRAINT syst_credentials_for_identities_fk
            REFERENCES ms_syst_data.syst_identities (id) ON DELETE CASCADE
    ,CONSTRAINT syst_credentials_udx
        UNIQUE NULLS NOT DISTINCT
            (access_account_id, credential_type_id, credential_for_identity_id)
    ,credential_data
        text
        NOT NULL
    ,last_updated
        timestamptz
        NOT NULL DEFAULT now( )
    ,force_reset
        timestamptz
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
        NOT NULL
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
        NOT NULL
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
);

ALTER TABLE ms_syst_data.syst_credentials OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_credentials FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_credentials TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_credentials
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_credential_types_enum_item_check
    AFTER INSERT ON ms_syst_data.syst_credentials
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('credential_types', 'credential_type_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_credential_types_enum_item_check
    AFTER UPDATE ON ms_syst_data.syst_credentials
    FOR EACH ROW WHEN ( old.credential_type_id != new.credential_type_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_enum_item_check(
                'credential_types', 'credential_type_id');

CREATE CONSTRAINT TRIGGER b50_trig_a_d_syst_credentials_delete_identity
    AFTER DELETE ON ms_syst_data.syst_credentials
    FOR EACH ROW WHEN ( old.credential_for_identity_id IS NOT NULL)
    EXECUTE PROCEDURE ms_syst_data.trig_a_d_syst_credentials_delete_identity();

DO
$DOCUMENTATION$
DECLARE
    -- Table
    v_comments_config ms_syst_priv.comments_config_table;

    -- Columns
    v_access_account_id          ms_syst_priv.comments_config_table_column;
    v_credential_type_id         ms_syst_priv.comments_config_table_column;
    v_credential_for_identity_id ms_syst_priv.comments_config_table_column;
    v_credential_data            ms_syst_priv.comments_config_table_column;
    v_last_updated               ms_syst_priv.comments_config_table_column;
    v_force_reset                ms_syst_priv.comments_config_table_column;

BEGIN

    --
    -- Table Config
    --

    v_comments_config.table_schema := 'ms_syst_data';
    v_comments_config.table_name   := 'syst_credentials';

    v_comments_config.description :=
$DOC$Hosts the Credentials by which a user or external system will prove its
Identity.$DOC$;
    v_comments_config.general_usage :=
$DOC$Note that not all Credential types are available for authentication with all
Identity types.$DOC$;

    --
    -- Column Configs
    --

    v_access_account_id.column_name := 'access_account_id';
    v_access_account_id.description :=
$DOC$The Access Account for which the Credential is to be used.$DOC$;

    v_credential_type_id.column_name := 'credential_type_id';
    v_credential_type_id.description :=
$DOC$The kind of Credential that the record represents.$DOC$;
    v_credential_type_id.general_usage :=
$DOC$Note that the behavior and use cases of the Credential may have specific
processing and handling requirements based on the Functional Type of the
Credential ype.$DOC$;

    v_credential_for_identity_id.column_name := 'credential_for_identity_id';
    v_credential_for_identity_id.description :=
$DOC$When an Access Account Identity is created for either Identity Validation or
Access Account recovery, a single use Identity is created as well as a single
use Credential.  In this specific case, the one time use Credential and the one
time use Identity are linked.  This is especially important in recovery
scenarios to ensure that only the correct recovery communication can recover the
account.  This field identifies the which Identity is associated with the
Credential.

For regular use Identities, there are no special Credential requirements that
would be needed to for a link and the value in this column should be null.$DOC$;

    v_credential_data.column_name := 'credential_data';
    v_credential_data.description :=
$DOC$The actual data which supports verifying the presented Identity in relation to
the Access Account.$DOC$;

    v_last_updated.column_name := 'last_updated';
    v_last_updated.description :=
$DOC$For Credential types where rules regarding updating may apply, such as common
passwords, this column indicates when the Credential was last updated (timestamp
of last password change, for example).$DOC$;
    v_last_updated.general_usage :=
$DOC$This field is explicitly not for dating trivial or administrative changes
which don't actually materially change the Credential data; please consult the
appropriate diagnostic fields for those use cases.$DOC$;

    v_force_reset.column_name := 'force_reset';
    v_force_reset.description :=
$DOC$Indicates whether or not certain Credential types, such as passwords, must be
updated.$DOC$;
    v_force_reset.general_usage :=
$DOC$When `NOT NULL`, the user must update their Credential on the next login; when
`NULL` updating the Credential is not being administratively forced.$DOC$;

    v_comments_config.columns :=
        ARRAY [
              v_access_account_id
            , v_credential_type_id
            , v_credential_for_identity_id
            , v_credential_data
            , v_last_updated
            , v_force_reset
            ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( v_comments_config );

END;
$DOCUMENTATION$;
