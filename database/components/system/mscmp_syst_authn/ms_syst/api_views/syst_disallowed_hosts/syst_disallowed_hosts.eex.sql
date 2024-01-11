-- File:        syst_disallowed_hosts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_disallowed_hosts/syst_disallowed_hosts.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE VIEW ms_syst.syst_disallowed_hosts AS
SELECT
    id
  , host_address
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM ms_syst_data.syst_disallowed_hosts;

ALTER VIEW ms_syst.syst_disallowed_hosts OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_disallowed_hosts FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_disallowed_hosts
    INSTEAD OF INSERT ON ms_syst.syst_disallowed_hosts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_disallowed_hosts();

CREATE TRIGGER a50_trig_i_u_syst_disallowed_hosts
    INSTEAD OF UPDATE ON ms_syst.syst_disallowed_hosts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_disallowed_hosts();

CREATE TRIGGER a50_trig_i_d_syst_disallowed_hosts
    INSTEAD OF DELETE ON ms_syst.syst_disallowed_hosts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_disallowed_hosts();

DO
$DOCUMENTATION$
DECLARE
    -- View
    var_view_config ms_syst_priv.comments_config_apiview;

    -- View Columns
    var_host_address ms_syst_priv.comments_config_apiview_column;

BEGIN

    --
    -- API View Config
    --

    var_view_config.table_schema := 'ms_syst_data';
    var_view_config.table_name   := 'syst_disallowed_hosts';
    var_view_config.view_schema  := 'ms_syst';
    var_view_config.view_name    := 'syst_disallowed_hosts';
    var_view_config.user_update  := FALSE;

    --
    -- Column Configs
    --
    var_host_address.column_name      := 'host_address';
    var_host_address.required         := TRUE;
    var_host_address.unique_values    := TRUE;
    var_host_address.supplemental     :=
$DOC$Attempting to `INSERT` a duplicate host using this API View will simply result
in the inserted record being silently ignored in favor of the existing record.$DOC$;

    var_view_config.columns :=
        ARRAY [ var_host_address ]::ms_syst_priv.comments_config_apiview_column[];

    PERFORM ms_syst_priv.generate_comments_apiview( var_view_config );

END;
$DOCUMENTATION$;
