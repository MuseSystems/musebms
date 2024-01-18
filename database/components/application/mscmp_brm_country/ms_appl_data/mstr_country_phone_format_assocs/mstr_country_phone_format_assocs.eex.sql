-- File:        mstr_country_phone_format_assocs.eex.sql
-- Location:    musebms/database/components/application/mscmp_brm_country/ms_appl_data/mstr_country_phone_format_assocs/mstr_country_phone_format_assocs.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE ms_appl_data.mstr_country_phone_format_assocs
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
        CONSTRAINT mstr_country_phone_format_assocs_pk PRIMARY KEY
    ,country_id
        uuid
        NOT NULL
        CONSTRAINT mstr_country_phone_format_assocs_countries_fk
            REFERENCES ms_appl_data.mstr_countries (id)
    ,phone_format_id
        uuid
        NOT NULL
        CONSTRAINT mstr_country_phone_format_assocs_phone_formats_fk
            REFERENCES ms_syst_data.syst_complex_format_values (id)
    ,is_default_for_country
        boolean
        NOT NULL DEFAULT false
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

ALTER TABLE ms_appl_data.mstr_country_phone_format_assocs OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_appl_data.mstr_country_phone_format_assocs FROM public;
GRANT ALL ON TABLE ms_appl_data.mstr_country_phone_format_assocs TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_appl_data.mstr_country_phone_format_assocs
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_complex_format_value_check
    AFTER INSERT ON ms_appl_data.mstr_country_phone_format_assocs
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_complex_format_value_check('phone_number_formats', 'phone_format_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_complex_format_value_check
    AFTER UPDATE ON ms_appl_data.mstr_country_phone_format_assocs
    FOR EACH ROW WHEN ( old.phone_format_id != new.phone_format_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_complex_format_value_check(
                'phone_number_formats', 'phone_format_id');

DO
$DOCUMENTATION$
DECLARE
    -- Table
    var_comments_config ms_syst_priv.comments_config_table;

    -- Columns
    var_country_id             ms_syst_priv.comments_config_table_column;
    var_phone_format_id        ms_syst_priv.comments_config_table_column;
    var_is_default_for_country ms_syst_priv.comments_config_table_column;

BEGIN

    --
    -- Table Config
    --

    var_comments_config.table_schema := 'ms_appl_data';
    var_comments_config.table_name   := 'mstr_country_phone_format_assocs';

    var_comments_config.description :=
$DOC$Establishes relationships between phone format records and country records and
allows recognizing an phone format as the default format for the country.$DOC$;

    --
    -- Column Configs
    --

    var_country_id.column_name := 'country_id';
    var_country_id.description :=
$DOC$Identifies the country with with the phone format is being associated.$DOC$;

    var_phone_format_id.column_name := 'phone_format_id';
    var_phone_format_id.description :=
$DOC$Identifies the phone format which is to be associated with the country.$DOC$;

    var_is_default_for_country.column_name := 'is_default_for_country';
    var_is_default_for_country.description :=
$DOC$If true, this format should be used as the default format for the country.$DOC$;
    var_is_default_for_country.general_usage :=
$DOC$There should only ever be one default for any one country_id.$DOC$;

    var_comments_config.columns :=
        ARRAY [
              var_country_id
            , var_phone_format_id
            , var_is_default_for_country
            ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config );

END;
$DOCUMENTATION$;
