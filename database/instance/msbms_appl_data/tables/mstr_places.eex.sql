-- File:        mstr_places.eex.sql
-- Location:    database\instance\msbms_appl_data\tables\mstr_places.eex.sql
-- Project:     Muse Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE msbms_appl_data.mstr_places
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT mstr_places_pk PRIMARY KEY
    ,owning_entity_id
        uuid
        NOT NULL
        CONSTRAINT mstr_places_entities_fk
            REFERENCES msbms_appl_data.mstr_entities (id)
    ,internal_name
        text
        NOT NULL
        CONSTRAINT mstr_places_internal_name_udx UNIQUE
    ,display_name
        text
        CONSTRAINT mstr_places_display_name_udx UNIQUE
    ,external_name
        text
        NOT NULL
    ,place_type_id
        uuid
        NOT NULL
        CONSTRAINT mstr_places_place_types_fk
            REFERENCES msbms_appl_data.enum_place_types (id)
    ,place_state_id
        uuid
        CONSTRAINT mstr_places_place_states_fk
            REFERENCES msbms_appl_data.enum_place_states (id)
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

ALTER TABLE msbms_appl_data.mstr_places OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_appl_data.mstr_places FROM public;
GRANT ALL ON TABLE msbms_appl_data.mstr_places TO <%= msbms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON msbms_appl_data.mstr_places
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE msbms_appl_data.mstr_places IS
$DOC$places are system representations of real world buildings, such as office
buildings, warehouses, factories, or sales centers.  Note that a place may be
associated with multiple addresses which can be assigned roles for different
purposes.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_places.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN   msbms_appl_data.mstr_places.owning_entity_id IS
$DOC$Indicates which managing entity owns the place record for the purposes of
default visibility and access.  Any place record owned by the global entity is
by default visible and usable by any managed entity.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_places.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_places.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interfaces.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_places.external_name IS
$DOC$A friendly name for externally facing uses such as in communications with the
place.  Note that this is not a key value and has no UNIQUE enforcement.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_places.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_places.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_places.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_places.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_places.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_places.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_places.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
