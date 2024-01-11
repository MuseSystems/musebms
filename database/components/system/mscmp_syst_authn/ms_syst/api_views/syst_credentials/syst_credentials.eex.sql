-- File:        syst_credentials.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_credentials/syst_credentials.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE VIEW ms_syst.syst_credentials AS
SELECT
    id
  , access_account_id
  , credential_type_id
  , credential_for_identity_id
  , credential_data
  , last_updated
  , force_reset
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM ms_syst_data.syst_credentials;

ALTER VIEW ms_syst.syst_credentials OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_credentials FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_credentials
    INSTEAD OF INSERT ON ms_syst.syst_credentials
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_credentials();

CREATE TRIGGER a50_trig_i_u_syst_credentials
    INSTEAD OF UPDATE ON ms_syst.syst_credentials
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_credentials();

CREATE TRIGGER a50_trig_i_d_syst_credentials
    INSTEAD OF DELETE ON ms_syst.syst_credentials
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_credentials();

DO
$DOCUMENTATION$
DECLARE
    -- View
    var_view_config ms_syst_priv.comments_config_apiview;

    -- View Columns
    var_access_account_id          ms_syst_priv.comments_config_apiview_column;
    var_credential_type_id         ms_syst_priv.comments_config_apiview_column;
    var_credential_for_identity_id ms_syst_priv.comments_config_apiview_column;
    var_credential_data            ms_syst_priv.comments_config_apiview_column;
    var_last_updated               ms_syst_priv.comments_config_apiview_column;
    var_force_reset                ms_syst_priv.comments_config_apiview_column;

BEGIN

    --
    -- API View Config
    --

    var_view_config.table_schema := 'ms_syst_data';
    var_view_config.table_name   := 'syst_credentials';
    var_view_config.view_schema  := 'ms_syst';
    var_view_config.view_name    := 'syst_credentials';

    --
    -- Column Configs
    --

    var_access_account_id.column_name      := 'access_account_id';
    var_access_account_id.required         := TRUE;
    var_access_account_id.user_update      := FALSE;
    var_access_account_id.supplemental     :=
$DOC$This column is part of a composite key.  The combined values of
`access_account_id`, `credential_type_id`, and `credential_for_identity_id`
must be unique; `NULL` values, where allowed, are not considered distinct for
this uniqueness check.$DOC$;

    var_credential_type_id.column_name      := 'credential_type_id';
    var_credential_type_id.required         := TRUE;
    var_credential_type_id.user_update      := FALSE;
    var_credential_type_id.supplemental     :=
$DOC$This column is part of a composite key.  The combined values of
`access_account_id`, `credential_type_id`, and `credential_for_identity_id`
must be unique; `NULL` values, where allowed, are not considered distinct for
this uniqueness check.$DOC$;

    var_credential_for_identity_id.column_name      := 'credential_for_identity_id';
    var_credential_for_identity_id.user_update      := FALSE;
    var_credential_for_identity_id.supplemental     :=
$DOC$This column is part of a composite key.  The combined values of
`access_account_id`, `credential_type_id`, and `credential_for_identity_id`
must be unique; `NULL` values, where allowed, are not considered distinct for
this uniqueness check.$DOC$;

    var_credential_data.column_name      := 'credential_data';
    var_credential_data.required         := TRUE;

    var_last_updated.column_name      := 'last_updated';

    var_force_reset.column_name      := 'force_reset';

    var_view_config.columns :=
        ARRAY [
              var_access_account_id
            , var_credential_type_id
            , var_credential_for_identity_id
            , var_credential_data
            , var_last_updated
            , var_force_reset]::ms_syst_priv.comments_config_apiview_column[];

    PERFORM ms_syst_priv.generate_comments_apiview( var_view_config );

END;
$DOCUMENTATION$;
