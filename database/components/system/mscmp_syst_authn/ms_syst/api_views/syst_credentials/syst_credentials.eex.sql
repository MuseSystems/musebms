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
    v_view_config ms_syst_priv.comments_config_apiview;

    -- View Columns
    v_access_account_id          ms_syst_priv.comments_config_apiview_column;
    v_credential_type_id         ms_syst_priv.comments_config_apiview_column;
    v_credential_for_identity_id ms_syst_priv.comments_config_apiview_column;
    v_credential_data            ms_syst_priv.comments_config_apiview_column;
    v_last_updated               ms_syst_priv.comments_config_apiview_column;
    v_force_reset                ms_syst_priv.comments_config_apiview_column;

BEGIN

    --
    -- API View Config
    --

    v_view_config.table_schema := 'ms_syst_data';
    v_view_config.table_name   := 'syst_credentials';
    v_view_config.view_schema  := 'ms_syst';
    v_view_config.view_name    := 'syst_credentials';

    --
    -- Column Configs
    --

    v_access_account_id.column_name      := 'access_account_id';
    v_access_account_id.required         := TRUE;
    v_access_account_id.user_update      := FALSE;
    v_access_account_id.supplemental     :=
$DOC$This column is part of a composite key.  The combined values of
`access_account_id`, `credential_type_id`, and `credential_for_identity_id`
must be unique; `NULL` values, where allowed, are not considered distinct for
this uniqueness check.$DOC$;

    v_credential_type_id.column_name      := 'credential_type_id';
    v_credential_type_id.required         := TRUE;
    v_credential_type_id.user_update      := FALSE;
    v_credential_type_id.supplemental     :=
$DOC$This column is part of a composite key.  The combined values of
`access_account_id`, `credential_type_id`, and `credential_for_identity_id`
must be unique; `NULL` values, where allowed, are not considered distinct for
this uniqueness check.$DOC$;

    v_credential_for_identity_id.column_name      := 'credential_for_identity_id';
    v_credential_for_identity_id.user_update      := FALSE;
    v_credential_for_identity_id.supplemental     :=
$DOC$This column is part of a composite key.  The combined values of
`access_account_id`, `credential_type_id`, and `credential_for_identity_id`
must be unique; `NULL` values, where allowed, are not considered distinct for
this uniqueness check.$DOC$;

    v_credential_data.column_name      := 'credential_data';
    v_credential_data.required         := TRUE;

    v_last_updated.column_name      := 'last_updated';

    v_force_reset.column_name      := 'force_reset';

    v_view_config.columns :=
        ARRAY [
              v_access_account_id
            , v_credential_type_id
            , v_credential_for_identity_id
            , v_credential_data
            , v_last_updated
            , v_force_reset]::ms_syst_priv.comments_config_apiview_column[];

    PERFORM ms_syst_priv.generate_comments_apiview( v_view_config );

END;
$DOCUMENTATION$;
