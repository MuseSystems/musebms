-- Source File: mstr_country_phone_format_assocs.eex.sql
-- Location:    database/instance/msbms_appl_data/tables/mstr_country_phone_format_assocs.eex.sql
-- Project:     musebms
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems
CREATE TABLE msbms_appl_data.mstr_country_phone_format_assocs
(
     id                      uuid        DEFAULT uuid_generate_v1( ) NOT NULL
        CONSTRAINT mstr_country_phone_format_assocs_pk PRIMARY KEY
    ,country_id              uuid                                    NOT NULL
        CONSTRAINT mstr_country_phone_format_assocs_countries_fk
        REFERENCES msbms_appl_data.mstr_countries (id)
    ,phone_format_id       uuid                                    NOT NULL
        CONSTRAINT mstr_country_phone_format_assocs_phone_formats_fk
        REFERENCES msbms_appl_data.conf_phone_formats (id)
    ,is_default_for_country  boolean     DEFAULT false               NOT NULL
    ,diag_timestamp_created  timestamptz DEFAULT now( )              NOT NULL
    ,diag_role_created       text                                    NOT NULL
    ,diag_timestamp_modified timestamptz DEFAULT now( )              NOT NULL
    ,diag_wallclock_modified timestamptz DEFAULT clock_timestamp( )  NOT NULL
    ,diag_role_modified      text                                    NOT NULL
    ,diag_row_version        bigint      DEFAULT 1                   NOT NULL
    ,diag_update_count       bigint      DEFAULT 0                   NOT NULL
);

ALTER TABLE msbms_appl_data.mstr_country_phone_format_assocs OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_appl_data.mstr_country_phone_format_assocs FROM public;
GRANT ALL ON TABLE msbms_appl_data.mstr_country_phone_format_assocs TO <%= msbms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON msbms_appl_data.mstr_country_phone_format_assocs
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE msbms_appl_data.mstr_country_phone_format_assocs IS
$DOC$Establishes relationships between phone format records and country records and
allows recognizing an phone format as the default format for the country.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_country_phone_format_assocs.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_country_phone_format_assocs.country_id IS
$DOC$Identifies the country with with the phone format is being associated.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_country_phone_format_assocs.phone_format_id IS
$DOC$Identifies the phone format which is to be associated with the country.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_country_phone_format_assocs.is_default_for_country IS
$DOC$If true, this format should be used as the default format for the country. There
should only ever be one default for any one country_id.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_country_phone_format_assocs.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_country_phone_format_assocs.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_country_phone_format_assocs.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_country_phone_format_assocs.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_country_phone_format_assocs.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_country_phone_format_assocs.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_country_phone_format_assocs.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
