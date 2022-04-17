-- File:        mstr_countries.eex.sql
-- Location:    database\app_msbms_instance\mod_brm\msbms_appl_data\tables\mstr_countries\mstr_countries.eex.sql
-- Project:     Muse Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE msbms_appl_data.mstr_countries
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT mstr_countries_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT mstr_countries_internal_name_udx UNIQUE
    ,display_name
        text
        CONSTRAINT mstr_countries_display_name_udx UNIQUE
    ,external_name
        text
        NOT NULL
    ,official_name_ar
        text
    ,official_name_cn
        text
    ,official_name_en
        text
    ,official_name_es
        text
    ,official_name_fr
        text
    ,official_name_ru
        text
    ,iso3166_1_alpha_2
        text
    ,iso3166_1_alpha_3
        text
    ,iso3166_1_numeric
        text
    ,iso4217_currency_alphabetic_code
        text
    ,iso4217_currency_country_name
        text
    ,iso4217_currency_minor_unit
        text
    ,iso4217_currency_name
        text
    ,iso4217_currency_numeric_code
        text
    ,cldr_display_name
        text
    ,capital
        text
    ,continent
        text
    ,ds
        text
    ,dial
        text
    ,edgar
        text
    ,fips
        text
    ,gaul
        text
    ,geoname_id
        text
    ,global_code
        text
    ,global_name
        text
    ,ioc
        text
    ,itu
        text
    ,intermediate_region_code
        text
    ,intermediate_region_name
        text
    ,languages
        text
    ,marc
        text
    ,region_code
        text
    ,region_name
        text
    ,sub_region_code
        text
    ,sub_region_name
        text
    ,tld
        text
    ,wmo
        text
    ,is_independent
        text
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

ALTER TABLE msbms_appl_data.mstr_countries OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_appl_data.mstr_countries FROM public;
GRANT ALL ON TABLE msbms_appl_data.mstr_countries TO <%= msbms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON msbms_appl_data.mstr_countries
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE msbms_appl_data.mstr_countries IS
$DOC$A listing of countries including currency symbology, official names, and other
information concering the country from standards bodies and international
organizations.

The table structure as it now stands is based on the data available at:
https://datahub.io/core/country-codes$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_countries.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_countries.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_countries.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interfaces.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_countries.external_name IS
$DOC$A friendly name for externally facing uses such as in postal addressing which
maynot follow accepted international conventions for naming.  Note that this is
not a key value and has no UNIQUE enforcement.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_countries.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_countries.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_countries.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_countries.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_countries.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_countries.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_countries.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
