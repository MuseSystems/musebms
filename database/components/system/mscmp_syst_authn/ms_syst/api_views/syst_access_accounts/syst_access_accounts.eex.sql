-- File:        syst_access_accounts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_access_accounts/syst_access_accounts.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE VIEW ms_syst.syst_access_accounts AS
    SELECT
          id
        , internal_name
        , external_name
        , owning_owner_id
        , allow_global_logins
        , access_account_state_id
        , diag_timestamp_created
        , diag_role_created
        , diag_timestamp_modified
        , diag_wallclock_modified
        , diag_role_modified
        , diag_row_version
        , diag_update_count
    FROM ms_syst_data.syst_access_accounts;

ALTER VIEW ms_syst.syst_access_accounts OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_access_accounts FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_access_accounts
    INSTEAD OF INSERT ON ms_syst.syst_access_accounts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_access_accounts();

CREATE TRIGGER a50_trig_i_u_syst_access_accounts
    INSTEAD OF UPDATE ON ms_syst.syst_access_accounts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_access_accounts();

CREATE TRIGGER a50_trig_i_d_syst_access_accounts
    INSTEAD OF DELETE ON ms_syst.syst_access_accounts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_access_accounts();

DO
$DOCUMENTATION$
DECLARE
    -- View
    v_view_config ms_syst_priv.comments_config_apiview;

    -- View Columns
    v_owning_owner_id         ms_syst_priv.comments_config_apiview_column;
    v_allow_global_logins     ms_syst_priv.comments_config_apiview_column;
    v_access_account_state_id ms_syst_priv.comments_config_apiview_column;

BEGIN

    --
    -- API View Config
    --

    v_view_config.table_schema := 'ms_syst_data';
    v_view_config.table_name   := 'syst_access_accounts';
    v_view_config.view_schema  := 'ms_syst';
    v_view_config.view_name    := 'syst_access_accounts';

    --
    -- Column Configs
    --

    v_owning_owner_id.column_name := 'owning_owner_id';
    v_owning_owner_id.user_update := FALSE;

    v_allow_global_logins.column_name := 'allow_global_logins';
    v_allow_global_logins.required := TRUE;

    v_access_account_state_id.column_name := 'access_account_state_id';
    v_access_account_state_id.required := TRUE;

    v_view_config.columns :=
        ARRAY [
              v_owning_owner_id
            , v_allow_global_logins
            , v_access_account_state_id
            ]::ms_syst_priv.comments_config_apiview_column[];

    PERFORM ms_syst_priv.generate_comments_apiview( v_view_config );

END;
$DOCUMENTATION$;
