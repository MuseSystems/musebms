-- File:        enum_app_interface_types.sql
-- Location:    msbms/database/msbms_syst_data/tables/enum_app_interface_types.sql
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

CREATE TABLE msbms_syst_data.enum_app_interface_types
(
     id                      uuid        DEFAULT uuid_generate_v1( ) NOT NULL
        CONSTRAINT enum_app_interface_types_pk PRIMARY KEY
    ,internal_name           text                                    NOT NULL
        CONSTRAINT enum_app_interface_types_internal_name_udx UNIQUE
    ,display_name            text                                    NOT NULL
        CONSTRAINT enum_app_interface_types_display_name_udx UNIQUE
    ,description             text                                    NOT NULL
    ,functional_type         text                                    NOT NULL
        CONSTRAINT functional_type_chk
            CHECK (functional_type IN ( 'web_ui', 'json_api', 'db_api' ))
    ,diag_timestamp_created  timestamptz DEFAULT now( )              NOT NULL
    ,diag_role_created       text                                    NOT NULL
    ,diag_timestamp_modified timestamptz DEFAULT now( )              NOT NULL
    ,diag_wallclock_modified timestamptz DEFAULT clock_timestamp( )  NOT NULL
    ,diag_role_modified      text                                    NOT NULL
    ,diag_row_version        bigint      DEFAULT 1                   NOT NULL
    ,diag_update_count       bigint      DEFAULT 0                   NOT NULL
);

ALTER TABLE msbms_syst_data.enum_app_interface_types OWNER TO msbms_owner;

REVOKE ALL ON TABLE msbms_syst_data.enum_app_interface_types FROM public;
GRANT ALL ON TABLE msbms_syst_data.enum_app_interface_types TO msbms_owner;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON msbms_syst_data.enum_app_interface_types
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE msbms_syst_data.enum_app_interface_types IS
$DOC$Lists the different supported entry points use to interact with the application.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.enum_app_interface_types.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.enum_app_interface_types.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.enum_app_interface_types.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
app_interfaces.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.enum_app_interface_types.description IS
$DOC$A text describing the meaning and use of the specific record that may be
visible to users of the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.enum_app_interface_types.functional_type IS
$DOC$Establishes the meaning of the record in relation to functionality implemented
in the system.  The system will base processing decisions upon the value in this
field.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.enum_app_interface_types.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.enum_app_interface_types.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.enum_app_interface_types.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.enum_app_interface_types.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.enum_app_interface_types.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.enum_app_interface_types.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.enum_app_interface_types.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;

COMMENT ON
    CONSTRAINT functional_type_chk
    ON msbms_syst_data.enum_app_interface_types IS
$DOC$Defines the system recognized types which can alter processing.

    * web_ui:   Identifies the web user interface typically accessed by real
                people using browsers.

    * json_api: Identifies access via HTTP protocol to a JSON based API suitable
                for external/programmatic interactions.

    * db_api:   Identifies access via the database "public" API.  This API is
                suitable for first party programmatic interactions with the
                application.$DOC$;
