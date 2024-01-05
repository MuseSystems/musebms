-- File:        syst_enums.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_enums/ms_syst/api_views/syst_enums/syst_enums.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE VIEW ms_syst.syst_enums AS
    SELECT
        id
      , internal_name
      , display_name
      , syst_description
      , user_description
      , syst_defined
      , user_maintainable
      , default_syst_options
      , default_user_options
      , diag_timestamp_created
      , diag_role_created
      , diag_timestamp_modified
      , diag_wallclock_modified
      , diag_role_modified
      , diag_row_version
      , diag_update_count
    FROM ms_syst_data.syst_enums;

ALTER VIEW ms_syst.syst_enums OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_enums FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_enums
    INSTEAD OF INSERT ON ms_syst.syst_enums
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_enums();

CREATE TRIGGER a50_trig_i_u_syst_enums
    INSTEAD OF UPDATE ON ms_syst.syst_enums
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_enums();

CREATE TRIGGER a50_trig_i_d_syst_enums
    INSTEAD OF DELETE ON ms_syst.syst_enums
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_enums();

DO
$DOCUMENTATION$
DECLARE
    var_view_config ms_syst_priv.comments_config_apiview;

    var_default_syst_options ms_syst_priv.comments_config_apiview_column;
    var_default_user_options ms_syst_priv.comments_config_apiview_column;

BEGIN

    var_view_config.table_schema := 'ms_syst_data';
    var_view_config.table_name   := 'syst_enums';
    var_view_config.view_schema  := 'ms_syst';
    var_view_config.view_name    := 'syst_enums';
    var_view_config.syst_records := TRUE;
    var_view_config.syst_update  := TRUE;
    var_view_config.syst_delete  := FALSE;

    var_default_syst_options.column_name := 'default_syst_options';
    var_default_syst_options.user_insert := FALSE;
    var_default_syst_options.user_update := FALSE;

    var_default_user_options.column_name := 'default_user_options';

    var_view_config.columns :=
        ARRAY [
              var_default_user_options
            , var_default_syst_options
            ]::ms_syst_priv.comments_config_apiview_column[];

    PERFORM ms_syst_priv.generate_comments_apiview( var_view_config );
END;
$DOCUMENTATION$;
