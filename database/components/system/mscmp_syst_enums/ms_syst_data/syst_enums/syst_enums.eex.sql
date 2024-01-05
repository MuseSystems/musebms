-- File:        syst_enums.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_enums/ms_syst_data/syst_enums/syst_enums.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_enums
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
        CONSTRAINT syst_enums_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_enums_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_enums_display_name_udx UNIQUE
    ,syst_description
        text
        NOT NULL
    ,user_description
        text
    ,syst_defined
        boolean
        NOT NULL DEFAULT FALSE
    ,user_maintainable
        boolean
        NOT NULL DEFAULT TRUE
    ,default_syst_options
        jsonb
    ,default_user_options
        jsonb
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

ALTER TABLE ms_syst_data.syst_enums OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_enums FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_enums TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_enums
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

DO
$DOCUMENTATION$
DECLARE
    var_comments_config ms_syst_priv.comments_config_table;

    var_default_syst_options ms_syst_priv.comments_config_table_column;
    var_default_user_options ms_syst_priv.comments_config_table_column;
BEGIN

    var_comments_config.table_schema := 'ms_syst_data';
    var_comments_config.table_name   := 'syst_enums';

    var_comments_config.description :=
$DOC$Enumerates the enumerations known to the system along with additional metadata
useful in applying them appropriately.$DOC$;

    var_default_syst_options.column_name := 'default_syst_options';
    var_default_syst_options.description :=
$DOC$Establishes the expected extended system options along with default values if
applicable.$DOC$;

    var_default_syst_options.general_usage :=
$DOC$Note that this setting is used to both validate and set defaults in the
`syst_enum_items.syst_options` column.$DOC$;

    var_default_user_options.column_name := 'default_user_options';
    var_default_user_options.description :=
$DOC$Allows a user to set the definition of syst_enum_items.user_options values and
provide defaults for those values if appropriate.$DOC$;

    var_comments_config.columns :=
        ARRAY [
              var_default_syst_options
            , var_default_user_options]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config);

END;
$DOCUMENTATION$;
