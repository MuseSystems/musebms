-- File:        mstr_facilities.sql
-- Location:    msbms/database/msbms_appl_data/tables/mstr_facilities.sql
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

CREATE TABLE msbms_appl_data.mstr_facilities
(
     id                      uuid        DEFAULT uuid_generate_v1( ) NOT NULL
        CONSTRAINT mstr_facilities_pk PRIMARY KEY
    ,owning_entity_id        uuid                                    NOT NULL
        CONSTRAINT mstr_facilities_entities_fk
        REFERENCES msbms_appl_data.mstr_facilities (id)
    ,internal_name           text                                    NOT NULL
        CONSTRAINT mstr_facilities_internal_name_udx UNIQUE
    ,display_name            text
        CONSTRAINT mstr_facilities_display_name_udx UNIQUE
    ,external_name           text                                    NOT NULL
    ,facility_type_id        uuid                                    NOT NULL
        CONSTRAINT mstr_facilities_facility_types_fk
        REFERENCES msbms_appl_data.enum_facility_types (id)
    ,facility_state_id       uuid
        CONSTRAINT mstr_facilities_facility_states_fk
        REFERENCES msbms_appl_data.enum_facility_states (id)
    ,diag_timestamp_created  timestamptz DEFAULT now( )              NOT NULL
    ,diag_role_created       text                                    NOT NULL
    ,diag_timestamp_modified timestamptz DEFAULT now( )              NOT NULL
    ,diag_wallclock_modified timestamptz DEFAULT clock_timestamp( )  NOT NULL
    ,diag_role_modified      text                                    NOT NULL
    ,diag_row_version        bigint      DEFAULT 1                   NOT NULL
    ,diag_update_count       bigint      DEFAULT 0                   NOT NULL
);

ALTER TABLE msbms_appl_data.mstr_facilities OWNER TO msbms_owner;

REVOKE ALL ON TABLE msbms_appl_data.mstr_facilities FROM public;
GRANT ALL ON TABLE msbms_appl_data.mstr_facilities TO msbms_owner;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON msbms_appl_data.mstr_facilities
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE msbms_appl_data.mstr_facilities IS
$DOC$Facilities are system representations of real world buildings, such as office
buildings, warehouses, factories, or sales centers.  Note that a facility may be
associated with multiple addresses which can be assigned roles for different
purposes.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_facilities.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_facilities.owning_entity_id IS
$DOC$Indicates which entity is the owning managing entity for purposes of default
access and visibility.  Facilities assigned to the global entity are by default
visible and accessible to all other managed entities, unless restricted by other
access mechanisms.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_facilities.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_facilities.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interfaces.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_facilities.external_name IS
$DOC$A friendly name for externally facing uses such as in communications with the
facility.  Note that this is not a key value and has no UNIQUE enforcement.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_facilities.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_facilities.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_facilities.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_facilities.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_facilities.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_facilities.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_facilities.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
