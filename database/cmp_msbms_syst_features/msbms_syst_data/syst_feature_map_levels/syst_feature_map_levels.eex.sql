-- File:        syst_feature_map_levels.eex.sql
-- Location:    database\cmp_msbms_syst_features\msbms_syst_data\syst_feature_map_levels\syst_feature_map_levels.eex.sql
-- Project:     Muse Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE msbms_syst_data.syst_feature_map_levels
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_feature_map_levels_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_feature_map_levels_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_feature_map_levels_display_name_udx UNIQUE
    ,functional_type
        text
        NOT NULL DEFAULT 'nonassignable'
        CONSTRAINT syst_feature_map_levels_functional_type_chk
            CHECK ( functional_type IN
                    ( 'assignable', 'nonassignable' ) )
    ,syst_description
        text
        NOT NULL
    ,user_description
        text
    ,system_defined
        boolean
        NOT NULL DEFAULT FALSE
    ,user_maintainable
        boolean
        NOT NULL DEFAULT TRUE
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

ALTER TABLE msbms_syst_data.syst_feature_map_levels OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_syst_data.syst_feature_map_levels FROM public;
GRANT ALL ON TABLE msbms_syst_data.syst_feature_map_levels TO <%= msbms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON msbms_syst_data.syst_feature_map_levels
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE msbms_syst_data.syst_feature_map_levels IS
$DOC$Defines the available levels of hierarchy of the features map.  Records in this
table also determine whether or not individual features may be assigned at the
level in question.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_map_levels.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_map_levels.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_map_levels.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_map_levels.functional_type IS
$DOC$Defines the system recognized types which can alter processing.

      * assignable:    Individual features may be mapped to syst_feature_map record assigned to a
                       level of this functional type.

      * nonassignable: When a syst_feature_map record is assigned to a level of this functional
                       type, the syst_feature_map record may not be directly associated with
                       individual features.  The level is considered to be an intermediate node for
                       grouping other, lower levels.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_map_levels.syst_description IS
$DOC$A description of the level, its purpose in the hierarchy, and other useful
information deemed relevant.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_map_levels.user_description IS
$DOC$A user defined override of the syst_description text.  If this column is not
null, it will override the system defined text at times that the description
would be visible to application users.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_map_levels.system_defined IS
$DOC$If true, indicates that the record was added by the standard system installation
process.  If false, the feature map level was user defined.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_map_levels.user_maintainable IS
$DOC$If true, users may make modifications to the record including the possibility
of deleting the record.  If false, the user may only make minimal modifications
to columns designated as user columns (i.e. user_description).$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_map_levels.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_map_levels.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_map_levels.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_map_levels.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_map_levels.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_map_levels.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_map_levels.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
