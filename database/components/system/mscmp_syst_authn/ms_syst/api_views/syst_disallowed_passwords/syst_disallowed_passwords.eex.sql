-- File:        syst_disallowed_passwords.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_disallowed_passwords/syst_disallowed_passwords.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE VIEW ms_syst.syst_disallowed_passwords AS
SELECT password_hash FROM ms_syst_data.syst_disallowed_passwords;

ALTER VIEW ms_syst.syst_disallowed_passwords OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_disallowed_passwords FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_disallowed_passwords
    INSTEAD OF INSERT ON ms_syst.syst_disallowed_passwords
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_disallowed_passwords();

CREATE TRIGGER a50_trig_i_u_syst_disallowed_passwords
    INSTEAD OF UPDATE ON ms_syst.syst_disallowed_passwords
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_disallowed_passwords();

CREATE TRIGGER a50_trig_i_d_syst_disallowed_passwords
    INSTEAD OF DELETE ON ms_syst.syst_disallowed_passwords
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_disallowed_passwords();

DO
$DOCUMENTATION$
DECLARE
    -- View
    var_view_config ms_syst_priv.comments_config_apiview;

    -- View Columns
    var_password_hash ms_syst_priv.comments_config_apiview_column;

BEGIN

    --
    -- API View Config
    --

    var_view_config.table_schema    := 'ms_syst_data';
    var_view_config.table_name      := 'syst_disallowed_passwords';
    var_view_config.view_schema     := 'ms_syst';
    var_view_config.view_name       := 'syst_disallowed_passwords';
    var_view_config.user_update     := FALSE;
    var_view_config.generate_common := FALSE;

    --
    -- Column Configs
    --

    var_password_hash.column_name      := 'password_hash';
    var_password_hash.required         := TRUE;
    var_password_hash.unique_values    := TRUE;
    var_password_hash.supplemental     :=
$DOC$Attempting to `INSERT` a duplicate disallowed password using this API View
will simply result in the inserted record being silently ignored in favor of the
existing record.$DOC$;


    var_view_config.columns :=
        ARRAY [ var_password_hash ]::ms_syst_priv.comments_config_apiview_column[];

    PERFORM ms_syst_priv.generate_comments_apiview( var_view_config );

END;
$DOCUMENTATION$;
