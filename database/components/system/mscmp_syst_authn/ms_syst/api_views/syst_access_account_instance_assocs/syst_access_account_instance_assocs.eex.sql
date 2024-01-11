-- File:        syst_access_account_instance_assocs.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_access_account_instance_assocs/syst_access_account_instance_assocs.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE VIEW ms_syst.syst_access_account_instance_assocs AS
SELECT
    id
  , access_account_id
  , instance_id
  , access_granted
  , invitation_issued
  , invitation_expires
  , invitation_declined
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM ms_syst_data.syst_access_account_instance_assocs;

ALTER VIEW ms_syst.syst_access_account_instance_assocs OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_access_account_instance_assocs FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_access_account_instance_assocs
    INSTEAD OF INSERT ON ms_syst.syst_access_account_instance_assocs
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_access_account_instance_assocs();

CREATE TRIGGER a50_trig_i_u_syst_access_account_instance_assocs
    INSTEAD OF UPDATE ON ms_syst.syst_access_account_instance_assocs
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_access_account_instance_assocs();

CREATE TRIGGER a50_trig_i_d_syst_access_account_instance_assocs
    INSTEAD OF DELETE ON ms_syst.syst_access_account_instance_assocs
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_access_account_instance_assocs();

DO
$DOCUMENTATION$
DECLARE
    -- View
    var_view_config ms_syst_priv.comments_config_apiview;

    -- View Columns
    var_access_account_id   ms_syst_priv.comments_config_apiview_column;
    var_instance_id         ms_syst_priv.comments_config_apiview_column;
    var_access_granted      ms_syst_priv.comments_config_apiview_column;
    var_invitation_issued   ms_syst_priv.comments_config_apiview_column;
    var_invitation_expires  ms_syst_priv.comments_config_apiview_column;
    var_invitation_declined ms_syst_priv.comments_config_apiview_column;

BEGIN

    --
    -- API View Config
    --

    var_view_config.table_schema := 'ms_syst_data';
    var_view_config.table_name   := 'syst_access_account_instance_assocs';
    var_view_config.view_schema  := 'ms_syst';
    var_view_config.view_name    := 'syst_access_account_instance_assocs';

    --
    -- Column Configs
    --

    var_access_account_id.column_name      := 'access_account_id';
    var_access_account_id.required         := TRUE;
    var_access_account_id.user_update      := FALSE;
    var_access_account_id.supplemental     :=
$DOC$This column is part of a composite key along with column `instance_id`.  The
combined values of `access_account_id` and `instance_id` must be unique.$DOC$;

    var_instance_id.column_name      := 'instance_id';
    var_instance_id.required         := TRUE;
    var_instance_id.user_update      := FALSE;
    var_instance_id.supplemental     :=
$DOC$This column is part of a composite key along with column `access_account_id`.
The combined values of `access_account_id` and `instance_id` must be unique.$DOC$;

    var_access_granted.column_name      := 'access_granted';

    var_invitation_issued.column_name      := 'invitation_issued';

    var_invitation_expires.column_name      := 'invitation_expires';

    var_invitation_declined.column_name      := 'invitation_declined';

    var_view_config.columns :=
        ARRAY [
              var_access_account_id
            , var_instance_id
            , var_access_granted
            , var_invitation_issued
            , var_invitation_expires
            , var_invitation_declined
            ]::ms_syst_priv.comments_config_apiview_column[];

    PERFORM ms_syst_priv.generate_comments_apiview( var_view_config );

END;
$DOCUMENTATION$;
