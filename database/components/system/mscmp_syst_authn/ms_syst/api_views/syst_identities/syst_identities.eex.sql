-- File:        syst_identities.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_identities/syst_identities.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE VIEW ms_syst.syst_identities AS
SELECT
    id
  , access_account_id
  , identity_type_id
  , account_identifier
  , validated
  , validates_identity_id
  , validation_requested
  , identity_expires
  , external_name
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM ms_syst_data.syst_identities;

ALTER VIEW ms_syst.syst_identities OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_identities FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_identities
    INSTEAD OF INSERT ON ms_syst.syst_identities
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_identities();

CREATE TRIGGER a50_trig_i_u_syst_identities
    INSTEAD OF UPDATE ON ms_syst.syst_identities
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_identities();

CREATE TRIGGER a50_trig_i_d_syst_identities
    INSTEAD OF DELETE ON ms_syst.syst_identities
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_identities();

DO
$DOCUMENTATION$
DECLARE
    -- View
    v_view_config ms_syst_priv.comments_config_apiview;

    -- View Columns
    v_access_account_id     ms_syst_priv.comments_config_apiview_column;
    v_identity_type_id      ms_syst_priv.comments_config_apiview_column;
    v_account_identifier    ms_syst_priv.comments_config_apiview_column;
    v_validated             ms_syst_priv.comments_config_apiview_column;
    v_validates_identity_id ms_syst_priv.comments_config_apiview_column;
    v_validation_requested  ms_syst_priv.comments_config_apiview_column;
    v_identity_expires      ms_syst_priv.comments_config_apiview_column;

BEGIN

    --
    -- API View Config
    --

    v_view_config.table_schema := 'ms_syst_data';
    v_view_config.table_name   := 'syst_identities';
    v_view_config.view_schema  := 'ms_syst';
    v_view_config.view_name    := 'syst_identities';

    --
    -- Column Configs
    --

    v_access_account_id.column_name      := 'access_account_id';
    v_access_account_id.required         := TRUE;
    v_access_account_id.user_update      := FALSE;

    v_identity_type_id.column_name      := 'identity_type_id';
    v_identity_type_id.required         := TRUE;
    v_identity_type_id.user_update      := FALSE;

    v_account_identifier.column_name      := 'account_identifier';
    v_account_identifier.required         := TRUE;
    v_account_identifier.user_update      := FALSE;

    v_validated.column_name      := 'validated';

    v_validates_identity_id.column_name      := 'validates_identity_id';
    v_validates_identity_id.unique_values    := TRUE;
    v_validates_identity_id.user_update      := FALSE;

    v_validation_requested.column_name      := 'validation_requested';

    v_identity_expires.column_name      := 'identity_expires';

    v_view_config.columns :=
        ARRAY [
              v_access_account_id
            , v_identity_type_id
            , v_account_identifier
            , v_validated
            , v_validates_identity_id
            , v_validation_requested
            , v_identity_expires
            ]::ms_syst_priv.comments_config_apiview_column[];

    PERFORM ms_syst_priv.generate_comments_apiview( v_view_config );

END;
$DOCUMENTATION$;
