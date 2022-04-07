-- File:        syst_feature_setting_assigns.eex.sql
-- Location:    database\cmp_msbms_syst_features\msbms_syst\api_views\syst_feature_setting_assigns\syst_feature_setting_assigns.eex.sql
-- Project:     Muse Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

DO
$SYS_SETTINGS_OPTION$
    BEGIN
        IF
            exists( SELECT TRUE
                    FROM information_schema.tables
                    WHERE table_schema = 'msbms_syst_data'
                      AND table_name = 'syst_settings')
        THEN

CREATE VIEW msbms_syst.syst_feature_setting_assigns AS
    SELECT
        id
      , feature_map_id
      , setting_id
      , diag_timestamp_created
      , diag_role_created
      , diag_timestamp_modified
      , diag_wallclock_modified
      , diag_role_modified
      , diag_row_version
      , diag_update_count
    FROM msbms_syst_data.syst_feature_setting_assigns;

ALTER VIEW msbms_syst.syst_feature_setting_assigns OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_syst.syst_feature_setting_assigns FROM PUBLIC;

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE msbms_syst.syst_feature_setting_assigns TO <%= msbms_appusr %>;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE msbms_syst.syst_feature_setting_assigns TO <%= msbms_apiusr %>;

CREATE TRIGGER a50_trig_i_i_syst_feature_setting_assigns
    INSTEAD OF INSERT ON msbms_syst.syst_feature_setting_assigns
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst.trig_i_i_syst_feature_setting_assigns();

CREATE TRIGGER a50_trig_i_u_syst_feature_setting_assigns
    INSTEAD OF UPDATE ON msbms_syst.syst_feature_setting_assigns
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst.trig_i_u_syst_feature_setting_assigns();

CREATE TRIGGER a50_trig_i_d_syst_feature_setting_assigns
    INSTEAD OF DELETE ON msbms_syst.syst_feature_setting_assigns
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst.trig_i_d_syst_feature_setting_assigns();

COMMENT ON
    VIEW msbms_syst.syst_feature_setting_assigns IS
$DOC$A join table which allows application settings to be associated with various
application features.  This is a many-to-many relationship.  The expectation is
that this association will be used in organizing certain configuration or
permissioning displays into a tree-like structure.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.$DOC$;

        END IF;
    END;
$SYS_SETTINGS_OPTION$;
