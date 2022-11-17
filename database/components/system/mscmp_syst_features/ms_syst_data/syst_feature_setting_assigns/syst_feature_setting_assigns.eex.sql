-- File:        syst_feature_setting_assigns.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_features/ms_syst_data/syst_feature_setting_assigns/syst_feature_setting_assigns.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

DO
$SYST_SETTINGS_OPTION$
    BEGIN
        IF
            exists( SELECT TRUE
                    FROM information_schema.tables
                    WHERE table_schema = 'ms_syst_data'
                      AND table_name = 'syst_settings')
        THEN

CREATE TABLE ms_syst_data.syst_feature_setting_assigns
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_feature_setting_assigns_pk PRIMARY KEY
    ,feature_map_id
        uuid
        NOT NULL
        CONSTRAINT syst_feature_setting_assigns_feature_map_fk
            REFERENCES ms_syst_data.syst_feature_map (id)
    ,setting_id
        uuid
        NOT NULL
        CONSTRAINT syst_feature_setting_assigns_setting_fk
            REFERENCES ms_syst_data.syst_settings (id)
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
        NOT NULL
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
        NOT NULL
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
);

ALTER TABLE ms_syst_data.syst_feature_setting_assigns OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_feature_setting_assigns FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_feature_setting_assigns TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_feature_setting_assigns
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_feature_map_level_assignable_check
    AFTER INSERT ON ms_syst_data.syst_feature_setting_assigns
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_a_iu_feature_map_level_assignable_check();

CREATE CONSTRAINT TRIGGER a50_trig_a_u_feature_map_level_assignable_check
    AFTER UPDATE ON ms_syst_data.syst_feature_setting_assigns
    FOR EACH ROW WHEN ( OLD.feature_map_id != NEW.feature_map_id )
        EXECUTE PROCEDURE ms_syst_priv.trig_a_iu_feature_map_level_assignable_check();

COMMENT ON
    TABLE ms_syst_data.syst_feature_setting_assigns IS
$DOC$A join table which allows application settings to be associated with various
application features.  This is a many-to-many relationship.  The expectation is
that this association will be used in organizing certain configuration or
permissioning displays into a tree-like structure.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_setting_assigns.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_setting_assigns.feature_map_id IS
$DOC$Identifies the feature mapping record to which the relation record is being
associated.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_setting_assigns.setting_id IS
$DOC$Identifies the settings record which is being associated with the feature.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_setting_assigns.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_setting_assigns.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_setting_assigns.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_setting_assigns.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_setting_assigns.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_setting_assigns.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_setting_assigns.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;

        END IF;
    END;
$SYST_SETTINGS_OPTION$;
