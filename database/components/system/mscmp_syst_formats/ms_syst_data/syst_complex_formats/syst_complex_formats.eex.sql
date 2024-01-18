-- File:        syst_complex_formats.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_formats/ms_syst_data/syst_complex_formats/syst_complex_formats.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_complex_formats
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
        CONSTRAINT syst_complex_formats_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_complex_formats_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_complex_formats_display_name_udx UNIQUE
    ,syst_description
        text
        NOT NULL
    ,user_description
        text
    ,feature_id
        uuid
        NOT NULL
        CONSTRAINT syst_complex_formats_feature_fk
            REFERENCES ms_syst_data.syst_feature_map (id)
    ,syst_defined
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

ALTER TABLE ms_syst_data.syst_complex_formats OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_complex_formats FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_complex_formats TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_complex_formats
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

DO
$DOCUMENTATION$
DECLARE
    -- Table
    var_comments_config ms_syst_priv.comments_config_table;

    -- Columns
    var_feature_id ms_syst_priv.comments_config_table_column;

BEGIN

    --
    -- Table Config
    --

    var_comments_config.table_schema := 'ms_syst_data';
    var_comments_config.table_name   := 'syst_complex_formats';

    var_comments_config.description :=
$DOC$Establishes definitions for complex data types and their user interface related
formatting.

Complex data types may include concepts such as street addresses, personal
names, and phone numbers; in each of these cases there are typically multiple
fields, but internationally there is no consistent definition of what fields are
available and how they should be ordered or arranged.$DOC$;

    --
    -- Column Configs
    --

    var_feature_id.column_name := 'feature_id';
    var_feature_id.description :=
$DOC$A reference to the specific feature of which the format is considered to be
part.

This reference is chiefly used to determine where in the configuration options
the format should appear.$DOC$;

    var_comments_config.columns :=
        ARRAY [ var_feature_id ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config );

END;
$DOCUMENTATION$;
