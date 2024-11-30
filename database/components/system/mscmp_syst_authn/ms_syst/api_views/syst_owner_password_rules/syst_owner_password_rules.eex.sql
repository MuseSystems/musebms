-- File:        syst_owner_password_rules.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_owner_password_rules/syst_owner_password_rules.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE VIEW ms_syst.syst_owner_password_rules AS
SELECT
    id
  , owner_id
  , password_length
  , max_age
  , require_upper_case
  , require_lower_case
  , require_numbers
  , require_symbols
  , disallow_recently_used
  , disallow_compromised
  , require_mfa
  , allowed_mfa_types
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM ms_syst_data.syst_owner_password_rules;

ALTER VIEW ms_syst.syst_owner_password_rules OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_owner_password_rules FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_owner_password_rules
    INSTEAD OF INSERT ON ms_syst.syst_owner_password_rules
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_owner_password_rules();

CREATE TRIGGER a50_trig_i_u_syst_owner_password_rules
    INSTEAD OF UPDATE ON ms_syst.syst_owner_password_rules
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_owner_password_rules();

CREATE TRIGGER a50_trig_i_d_syst_owner_password_rules
    INSTEAD OF DELETE ON ms_syst.syst_owner_password_rules
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_owner_password_rules();

DO
$DOCUMENTATION$
DECLARE
    -- View
    v_view_config ms_syst_priv.comments_config_apiview;

    -- View Columns
    v_owner_id               ms_syst_priv.comments_config_apiview_column;
    v_password_length        ms_syst_priv.comments_config_apiview_column;
    v_max_age                ms_syst_priv.comments_config_apiview_column;
    v_require_upper_case     ms_syst_priv.comments_config_apiview_column;
    v_require_lower_case     ms_syst_priv.comments_config_apiview_column;
    v_require_numbers        ms_syst_priv.comments_config_apiview_column;
    v_require_symbols        ms_syst_priv.comments_config_apiview_column;
    v_disallow_recently_used ms_syst_priv.comments_config_apiview_column;
    v_disallow_compromised   ms_syst_priv.comments_config_apiview_column;
    v_require_mfa            ms_syst_priv.comments_config_apiview_column;
    v_allowed_mfa_types      ms_syst_priv.comments_config_apiview_column;

BEGIN

    --
    -- API View Config
    --

    v_view_config.table_schema := 'ms_syst_data';
    v_view_config.table_name   := 'syst_owner_password_rules';
    v_view_config.view_schema  := 'ms_syst';
    v_view_config.view_name    := 'syst_owner_password_rules';

    --
    -- Column Configs
    --

    v_owner_id.column_name      := 'owner_id';
    v_owner_id.required         := TRUE;
    v_owner_id.unique_values    := TRUE;
    v_owner_id.user_update      := FALSE;

    v_password_length.column_name := 'password_length';
    v_password_length.required    := TRUE;

    v_max_age.column_name := 'max_age';
    v_max_age.required    := TRUE;

    v_require_upper_case.column_name := 'require_upper_case';
    v_require_upper_case.required    := TRUE;

    v_require_lower_case.column_name := 'require_lower_case';
    v_require_lower_case.required    := TRUE;

    v_require_numbers.column_name := 'require_numbers';
    v_require_numbers.required    := TRUE;

    v_require_symbols.column_name := 'require_symbols';
    v_require_symbols.required    := TRUE;

    v_disallow_recently_used.column_name := 'disallow_recently_used';
    v_disallow_recently_used.required    := TRUE;

    v_disallow_compromised.column_name := 'disallow_compromised';
    v_disallow_compromised.required    := TRUE;

    v_require_mfa.column_name := 'require_mfa';
    v_require_mfa.required    := TRUE;

    v_allowed_mfa_types.column_name := 'allowed_mfa_types';
    v_allowed_mfa_types.required    := TRUE;


    v_view_config.columns :=
        ARRAY [
              v_owner_id
            , v_password_length
            , v_max_age
            , v_require_upper_case
            , v_require_lower_case
            , v_require_numbers
            , v_require_symbols
            , v_disallow_recently_used
            , v_disallow_compromised
            , v_require_mfa
            , v_allowed_mfa_types
            ]::ms_syst_priv.comments_config_apiview_column[];

    PERFORM ms_syst_priv.generate_comments_apiview( v_view_config );

END;
$DOCUMENTATION$;
