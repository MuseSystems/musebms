-- File:        syst_feature_map.eex.sql
-- Location:    database\common\msbms_syst_data\tables\syst_feature_map.eex.sql
-- Project:     Muse Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE msbms_syst_data.syst_feature_map
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_feature_map_pk PRIMARY KEY
    ,internal_name           
        text                                    
        NOT NULL
        CONSTRAINT syst_feature_map_internal_name_udx UNIQUE
    ,display_name            
        text                                    
        NOT NULL
        CONSTRAINT syst_feature_map_display_name_udx UNIQUE
    ,feature_map_level_id
        uuid
        NOT NULL
        CONSTRAINT syst_feature_map_feature_map_levels_id_fk
            REFERENCES msbms_syst_data.syst_feature_map_levels (id)
    ,parent_feature_map_id
        uuid
        CONSTRAINT syst_feature_map_feature_map_id_fk
            REFERENCES msbms_syst_data.syst_feature_map (id)
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
);

ALTER TABLE msbms_syst_data.syst_feature_map OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_syst_data.syst_feature_map FROM public;
GRANT ALL ON TABLE msbms_syst_data.syst_feature_map TO <%= msbms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON msbms_syst_data.syst_feature_map
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE msbms_syst_data.syst_feature_map IS
$DOC$A map organizing the application's features into a tree-like structure.  This
is principally a documentation tool, but is also useful for features such as
driving nested directories to aide users in navigating forms or configurations.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_map.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_map.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_map.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_map.feature_map_level_id IS
$DOC$Indicates to which level this mapping entry pertains.  The mapping level will
play a part in determining whether or not the mapping entry is able to be
directly associated with specific features or if the mapping entry is just a
container for other mapping entries.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_map.parent_feature_map_id IS
$DOC$Indicates of which mapping entry the current entry is a child, if it is a
child of any entry.  If this column is NULL, the mapping entry sits at the top/
root level of the hierarchy.  This series of parent/child relationships between
mapping entries establishes a tree structure for organizing system features.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_map.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_map.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_map.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_map.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_map.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_map.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_map.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
