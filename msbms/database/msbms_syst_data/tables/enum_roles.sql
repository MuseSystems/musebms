-- File:        enum_roles.sql
-- Location:    msbms/database/msbms_syst_data/tables/enum_roles.sql
-- Project:     Muse Systems Business Management System
--
-- Licensed to Lima Buttgereit Holdings LLC (d/b/a Muse Systems) under one or
-- more agreements.  Muse Systems licenses this file to you under the terms and
-- conditions of your Muse Systems Master Services Agreement or governing
-- Statement of Work.
--
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE msbms_syst_data.enum_roles
(
     id                      uuid        DEFAULT uuid_generate_v1( ) NOT NULL
        CONSTRAINT enum_roles_pk PRIMARY KEY
    ,app_relation_id         uuid                                    NOT NULL
        CONSTRAINT enum_roles_app_relation_id_fk
        REFERENCES msbms_syst_data.app_relations (id)
            ON DELETE CASCADE
    ,internal_name           text                                    NOT NULL
        CONSTRAINT enum_roles_internal_name_udx UNIQUE
    ,display_name            text                                    NOT NULL
        CONSTRAINT enum_roles_display_name_udx UNIQUE
    ,sort_order              integer                                 NOT NULL DEFAULT 999999
    ,description             text                                    NOT NULL
    ,app_feature_type_id     uuid                                    NOT NULL
        CONSTRAINT enum_roles_app_feature_type_id_fk
        REFERENCES msbms_syst_data.app_feature_types (id)
    ,functional_type         text                                    NOT NULL
    ,diag_timestamp_created  timestamptz DEFAULT now( )              NOT NULL
    ,diag_role_created       text                                    NOT NULL
    ,diag_timestamp_modified timestamptz DEFAULT now( )              NOT NULL
    ,diag_wallclock_modified timestamptz DEFAULT clock_timestamp( )  NOT NULL
    ,diag_role_modified      text                                    NOT NULL
    ,diag_row_version        bigint      DEFAULT 1                   NOT NULL
    ,diag_update_count       bigint      DEFAULT 0                   NOT NULL
    ,CONSTRAINT enum_roles_app_relation_id_display_name_udx
        UNIQUE (app_relation_id, display_name)
);

ALTER TABLE msbms_syst_data.enum_roles OWNER TO msbms_owner;

REVOKE ALL ON TABLE msbms_syst_data.enum_roles FROM public;
GRANT ALL ON TABLE msbms_syst_data.enum_roles TO msbms_owner;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON msbms_syst_data.enum_roles
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE msbms_syst_data.enum_roles IS
$DOC$A listing of 'roles' for use by various system oriented relations.  These roles
are designed to drive lists of values which appear in the application and exist
for the purposes of categorizing various relations in the system.  Note that
often times these roles will have actual functional ramifications when selected.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.enum_roles.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON COLUMN
    msbms_syst_data.enum_roles.app_relation_id IS
$DOC$Identifies the specific relation with which the enum_roles record is associated.
This value forms part of a compound candidate key for the record along with the
enum_roles.display_name column.$DOC$;

COMMENT ON COLUMN
    msbms_syst_data.enum_roles.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.  Note
that this value is expected to be unique in this table even though other columns
which are normally candidate keys are only compound key components in this
table.$DOC$;

COMMENT ON COLUMN
    msbms_syst_data.enum_roles.display_name IS
$DOC$A friendly name for the record suitable for use in user interfaces.  Note that
the display_name value in this table may be duplicated unlike many other tables
where this field appears.  In this table, display_name is only a component of
the app_relation_id, display_name composite candidate key.$DOC$;

COMMENT ON COLUMN
    msbms_syst_data.enum_roles.sort_order IS
$DOC$A simple number based sort use to sort on-screen displays of the data in the
table.$DOC$;

COMMENT ON COLUMN
    msbms_syst_data.enum_roles.description IS
$DOC$A text describing the meaning and use of the specific record.$DOC$;

COMMENT ON COLUMN
    msbms_syst_data.enum_roles.app_feature_type_id IS
$DOC$A reference to the feature type to which the enumeration type is associated.$DOC$;

COMMENT ON COLUMN
    msbms_syst_data.enum_roles.functional_type IS
$DOC$$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.enum_roles.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.enum_roles.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.enum_roles.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.enum_roles.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.enum_roles.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.enum_roles.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.enum_roles.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
