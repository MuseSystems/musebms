-- File:        syst_global_password_rules.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_global_password_rules/syst_global_password_rules.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE VIEW ms_syst.syst_global_password_rules AS
SELECT
    id
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
FROM ms_syst_data.syst_global_password_rules;

ALTER VIEW ms_syst.syst_global_password_rules OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_global_password_rules FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_global_password_rules
    INSTEAD OF INSERT ON ms_syst.syst_global_password_rules
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_global_password_rules();

CREATE TRIGGER a50_trig_i_u_syst_global_password_rules
    INSTEAD OF UPDATE ON ms_syst.syst_global_password_rules
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_global_password_rules();

CREATE TRIGGER a50_trig_i_d_syst_global_password_rules
    INSTEAD OF DELETE ON ms_syst.syst_global_password_rules
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_global_password_rules();

DO
$DOCUMENTATION$
DECLARE
    -- View
    var_view_config ms_syst_priv.comments_config_apiview;

    -- View Columns
    var_password_length        ms_syst_priv.comments_config_apiview_column;
    var_max_age                ms_syst_priv.comments_config_apiview_column;
    var_require_upper_case     ms_syst_priv.comments_config_apiview_column;
    var_require_lower_case     ms_syst_priv.comments_config_apiview_column;
    var_require_numbers        ms_syst_priv.comments_config_apiview_column;
    var_require_symbols        ms_syst_priv.comments_config_apiview_column;
    var_disallow_recently_used ms_syst_priv.comments_config_apiview_column;
    var_disallow_compromised   ms_syst_priv.comments_config_apiview_column;
    var_require_mfa            ms_syst_priv.comments_config_apiview_column;
    var_allowed_mfa_types      ms_syst_priv.comments_config_apiview_column;

BEGIN

    --
    -- API View Config
    --

    var_view_config.table_schema    := 'ms_syst_data';
    var_view_config.table_name      := 'syst_global_password_rules';
    var_view_config.view_schema     := 'ms_syst';
    var_view_config.view_name       := 'syst_global_password_rules';
    var_view_config.user_records    := FALSE;
    var_view_config.syst_records    := TRUE;
    var_view_config.syst_update     := TRUE;

    --
    -- Column Configs
    --

    var_password_length.column_name      := 'password_length';
    var_password_length.required         := TRUE;
    var_password_length.syst_update_mode := 'always';

    var_max_age.column_name      := 'max_age';
    var_max_age.required         := TRUE;
    var_max_age.syst_update_mode := 'always';

    var_require_upper_case.column_name      := 'require_upper_case';
    var_require_upper_case.required         := TRUE;
    var_require_upper_case.syst_update_mode := 'always';

    var_require_lower_case.column_name      := 'require_lower_case';
    var_require_lower_case.required         := TRUE;
    var_require_lower_case.syst_update_mode := 'always';

    var_require_numbers.column_name      := 'require_numbers';
    var_require_numbers.required         := TRUE;
    var_require_numbers.syst_update_mode := 'always';

    var_require_symbols.column_name      := 'require_symbols';
    var_require_symbols.required         := TRUE;
    var_require_symbols.syst_update_mode := 'always';

    var_disallow_recently_used.column_name      := 'disallow_recently_used';
    var_disallow_recently_used.required         := TRUE;
    var_disallow_recently_used.syst_update_mode := 'always';

    var_disallow_compromised.column_name      := 'disallow_compromised';
    var_disallow_compromised.required         := TRUE;
    var_disallow_compromised.syst_update_mode := 'always';

    var_require_mfa.column_name      := 'require_mfa';
    var_require_mfa.required         := TRUE;
    var_require_mfa.syst_update_mode := 'always';

    var_allowed_mfa_types.column_name      := 'allowed_mfa_types';
    var_allowed_mfa_types.required         := TRUE;
    var_allowed_mfa_types.syst_update_mode := 'always';

    var_view_config.columns :=
        ARRAY [
              var_password_length
            , var_max_age
            , var_require_upper_case
            , var_require_lower_case
            , var_require_numbers
            , var_require_symbols
            , var_disallow_recently_used
            , var_disallow_compromised
            , var_require_mfa
            , var_allowed_mfa_types
            ]::ms_syst_priv.comments_config_apiview_column[];

    PERFORM ms_syst_priv.generate_comments_apiview( var_view_config );

END;
$DOCUMENTATION$;
