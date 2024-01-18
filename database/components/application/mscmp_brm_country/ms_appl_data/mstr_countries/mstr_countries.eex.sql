-- File:        mstr_countries.eex.sql
-- Location:    musebms/database/components/application/mscmp_brm_country/ms_appl_data/mstr_countries/mstr_countries.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE ms_appl_data.mstr_countries
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
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

ALTER TABLE ms_appl_data.mstr_countries OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_appl_data.mstr_countries FROM public;
GRANT ALL ON TABLE ms_appl_data.mstr_countries TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_appl_data.mstr_countries
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

DO
$DOCUMENTATION$
DECLARE
    -- Table
    var_comments_config ms_syst_priv.comments_config_table;
    
    -- Columns
    var_official_name_ar                 ms_syst_priv.comments_config_table_column;
    var_official_name_cn                 ms_syst_priv.comments_config_table_column;
    var_official_name_en                 ms_syst_priv.comments_config_table_column;
    var_official_name_es                 ms_syst_priv.comments_config_table_column;
    var_official_name_fr                 ms_syst_priv.comments_config_table_column;
    var_official_name_ru                 ms_syst_priv.comments_config_table_column;
    var_iso3166_1_alpha_2                ms_syst_priv.comments_config_table_column;
    var_iso3166_1_alpha_3                ms_syst_priv.comments_config_table_column;
    var_iso3166_1_numeric                ms_syst_priv.comments_config_table_column;
    var_iso4217_currency_alphabetic_code ms_syst_priv.comments_config_table_column;
    var_iso4217_currency_country_name    ms_syst_priv.comments_config_table_column;
    var_iso4217_currency_minor_unit      ms_syst_priv.comments_config_table_column;
    var_iso4217_currency_name            ms_syst_priv.comments_config_table_column;
    var_iso4217_currency_numeric_code    ms_syst_priv.comments_config_table_column;
    var_cldr_display_name                ms_syst_priv.comments_config_table_column;
    var_capital                          ms_syst_priv.comments_config_table_column;
    var_continent                        ms_syst_priv.comments_config_table_column;
    var_ds                               ms_syst_priv.comments_config_table_column;
    var_dial                             ms_syst_priv.comments_config_table_column;
    var_edgar                            ms_syst_priv.comments_config_table_column;
    var_fips                             ms_syst_priv.comments_config_table_column;
    var_gaul                             ms_syst_priv.comments_config_table_column;
    var_geoname_id                       ms_syst_priv.comments_config_table_column;
    var_global_code                      ms_syst_priv.comments_config_table_column;
    var_global_name                      ms_syst_priv.comments_config_table_column;
    var_ioc                              ms_syst_priv.comments_config_table_column;
    var_itu                              ms_syst_priv.comments_config_table_column;
    var_intermediate_region_code         ms_syst_priv.comments_config_table_column;
    var_intermediate_region_name         ms_syst_priv.comments_config_table_column;
    var_languages                        ms_syst_priv.comments_config_table_column;
    var_marc                             ms_syst_priv.comments_config_table_column;
    var_region_code                      ms_syst_priv.comments_config_table_column;
    var_region_name                      ms_syst_priv.comments_config_table_column;
    var_sub_region_code                  ms_syst_priv.comments_config_table_column;
    var_sub_region_name                  ms_syst_priv.comments_config_table_column;
    var_tld                              ms_syst_priv.comments_config_table_column;
    var_wmo                              ms_syst_priv.comments_config_table_column;
    var_is_independent                   ms_syst_priv.comments_config_table_column;
    
BEGIN
    
    --
    -- Table Config
    --

    var_comments_config.table_schema := 'ms_appl_data';
    var_comments_config.table_name   := 'mstr_countries';

    var_comments_config.description :=
$DOC$A listing of countries including currency symbology, official names, and other
information concerning the country from standards bodies and international
organizations.$DOC$;

    var_comments_config.general_usage :=
$DOC$The table structure as it now stands is based on the data available at:
https://datahub.io/core/country-codes$DOC$;

    --
    -- Column Configs
    --

    var_official_name_ar.column_name := 'official_name_ar';
    var_official_name_ar.description :=
$DOC$Country or Area official Arabic short name from UN Statistics Division$DOC$;

    var_official_name_cn.column_name := 'official_name_cn';
    var_official_name_cn.description :=
$DOC$Country or Area official Chinese short name from UN Statistics Division$DOC$;

    var_official_name_en.column_name := 'official_name_en';
    var_official_name_en.description :=
$DOC$Country or Area official English short name from UN Statistics Division$DOC$;

    var_official_name_es.column_name := 'official_name_es';
    var_official_name_es.description :=
$DOC$Country or Area official Spanish short name from UN Statistics Division$DOC$;

    var_official_name_fr.column_name := 'official_name_fr';
    var_official_name_fr.description :=
$DOC$Country or Area official French short name from UN Statistics Division$DOC$;

    var_official_name_ru.column_name := 'official_name_ru';
    var_official_name_ru.description :=
$DOC$Country or Area official Russian short name from UN Statistics Division$DOC$;

    var_iso3166_1_alpha_2.column_name := 'iso3166_1_alpha_2';
    var_iso3166_1_alpha_2.description :=
$DOC$Alpha-2 codes from ISO 3166-1$DOC$;

    var_iso3166_1_alpha_3.column_name := 'iso3166_1_alpha_3';
    var_iso3166_1_alpha_3.description :=
$DOC$Alpha-3 codes from ISO 3166-1 (synonymous with World Bank Codes)$DOC$;

    var_iso3166_1_numeric.column_name := 'iso3166_1_numeric';
    var_iso3166_1_numeric.description :=
$DOC$Numeric codes from ISO 3166-1$DOC$;

    var_iso4217_currency_alphabetic_code.column_name := 'iso4217_currency_alphabetic_code';
    var_iso4217_currency_alphabetic_code.description :=
$DOC$ISO 4217 currency alphabetic code$DOC$;

    var_iso4217_currency_country_name.column_name := 'iso4217_currency_country_name';
    var_iso4217_currency_country_name.description :=
$DOC$(ISO4217-currency_country_name) :: ISO 4217 country name$DOC$;


    var_iso4217_currency_minor_unit.column_name := 'iso4217_currency_minor_unit';
    var_iso4217_currency_minor_unit.description :=
$DOC$(ISO4217-currency_minor_unit) :: ISO 4217 currency number of minor units$DOC$;


    var_iso4217_currency_name.column_name := 'iso4217_currency_name';
    var_iso4217_currency_name.description :=
$DOC$(ISO4217-currency_name) :: ISO 4217 currency name$DOC$;


    var_iso4217_currency_numeric_code.column_name := 'iso4217_currency_numeric_code';
    var_iso4217_currency_numeric_code.description :=
$DOC$(ISO4217-currency_numeric_code) :: ISO 4217 currency numeric code$DOC$;


    var_cldr_display_name.column_name := 'cldr_display_name';
    var_cldr_display_name.description :=
$DOC$(CLDR display name) :: Country's customary English short name (CLDR)$DOC$;


    var_capital.column_name := 'capital';
    var_capital.description :=
$DOC$Capital city from Geonames$DOC$;


    var_continent.column_name := 'continent';
    var_continent.description :=
$DOC$(Continent) :: Continent from Geonames$DOC$;


    var_ds.column_name := 'ds';
    var_ds.description :=
$DOC$(DS) :: Distinguishing signs of vehicles in international traffic$DOC$;


    var_dial.column_name := 'dial';
    var_dial.description :=
$DOC$Country code from ITU-T recommendation E.164, sometimes followed by area code$DOC$;

    var_edgar.column_name := 'edgar';
    var_edgar.description :=
$DOC$(EDGAR) :: EDGAR country code from SEC$DOC$;


    var_fips.column_name := 'fips';
    var_fips.description :=
$DOC$(FIPS) :: Codes from the U.S. standard FIPS PUB 10-4$DOC$;


    var_gaul.column_name := 'gaul';
    var_gaul.description :=
$DOC$(GAUL) :: Global Administrative Unit Layers from the Food and Agriculture Organization$DOC$;


    var_geoname_id.column_name := 'geoname_id';
    var_geoname_id.description :=
$DOC$(Geoname ID) :: Geoname ID$DOC$;


    var_global_code.column_name := 'global_code';
    var_global_code.description :=
$DOC$(Global Code) :: Country classification from United Nations Statistics Division$DOC$;


    var_global_name.column_name := 'global_name';
    var_global_name.description :=
$DOC$(Global Name) :: Country classification from United Nations Statistics Division$DOC$;


    var_ioc.column_name := 'ioc';
    var_ioc.description :=
$DOC$(IOC) :: Codes assigned by the International Olympics Committee$DOC$;


    var_itu.column_name := 'itu';
    var_itu.description :=
$DOC$(ITU) :: Codes assigned by the International Telecommunications Union$DOC$;


    var_intermediate_region_code.column_name := 'intermediate_region_code';
    var_intermediate_region_code.description :=
$DOC$(Intermediate Region Code) :: Country classification from United Nations Statistics Division$DOC$;


    var_intermediate_region_name.column_name := 'intermediate_region_name';
    var_intermediate_region_name.description :=
$DOC$(Intermediate Region Name) :: Country classification from United Nations Statistics Division$DOC$;


    var_languages.column_name := 'languages';
    var_languages.description :=
$DOC$(Languages) :: Languages from Geonames$DOC$;


    var_marc.column_name := 'marc';
    var_marc.description :=
$DOC$(MARC) :: MAchine-Readable Cataloging codes from the Library of Congress$DOC$;


    var_region_code.column_name := 'region_code';
    var_region_code.description :=
$DOC$(Region Code) :: Country classification from United Nations Statistics Division$DOC$;


    var_region_name.column_name := 'region_name';
    var_region_name.description :=
$DOC$(Region Name) :: Country classification from United Nations Statistics Division$DOC$;


    var_sub_region_code.column_name := 'sub_region_code';
    var_sub_region_code.description :=
$DOC$(Sub-region Code) :: Country classification from United Nations Statistics Division$DOC$;


    var_sub_region_name.column_name := 'sub_region_name';
    var_sub_region_name.description :=
$DOC$(Sub-region Name) :: Country classification from United Nations Statistics Division$DOC$;


    var_tld.column_name := 'tld';
    var_tld.description :=
$DOC$(TLD) :: Top level domain from Geonames$DOC$;


    var_wmo.column_name := 'wmo';
    var_wmo.description :=
$DOC$(WMO) :: Country abbreviations by the World Meteorological Organization$DOC$;


    var_is_independent.column_name := 'is_independent';
    var_is_independent.description :=
$DOC$(is_independent) :: Country status, based on the CIA World Factbook$DOC$;


    var_comments_config.columns :=
        ARRAY [
              var_official_name_ar
            , var_official_name_cn
            , var_official_name_en
            , var_official_name_es
            , var_official_name_fr
            , var_official_name_ru
            , var_iso3166_1_alpha_2
            , var_iso3166_1_alpha_3
            , var_iso3166_1_numeric
            , var_iso4217_currency_alphabetic_code
            , var_iso4217_currency_country_name
            , var_iso4217_currency_minor_unit
            , var_iso4217_currency_name
            , var_iso4217_currency_numeric_code
            , var_cldr_display_name
            , var_capital
            , var_continent
            , var_ds
            , var_dial
            , var_edgar
            , var_fips
            , var_gaul
            , var_geoname_id
            , var_global_code
            , var_global_name
            , var_ioc
            , var_itu
            , var_intermediate_region_code
            , var_intermediate_region_name
            , var_languages
            , var_marc
            , var_region_code
            , var_region_name
            , var_sub_region_code
            , var_sub_region_name
            , var_tld
            , var_wmo
            , var_is_independent
            ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config );

END;
$DOCUMENTATION$;
