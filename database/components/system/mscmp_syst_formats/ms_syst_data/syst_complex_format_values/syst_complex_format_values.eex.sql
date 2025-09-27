-- File:        syst_complex_format_values.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_formats/ms_syst_data/syst_complex_format_values/syst_complex_format_values.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_complex_format_values
(
     id
        uuid
        NOT NULL DEFAULT uuidv7( )
        CONSTRAINT syst_complex_format_values_pk PRIMARY KEY
    ,internal_name
        text COLLATE ms_syst_priv.variant_insensitive
        NOT NULL
        CONSTRAINT syst_complex_format_values_internal_name_udx UNIQUE
    ,display_name
        text COLLATE ms_syst_priv.variant_insensitive
        NOT NULL
        CONSTRAINT syst_complex_format_values_display_name_udx UNIQUE
    ,external_name
        text
        NOT NULL
    ,complex_format_id
        uuid
        NOT NULL
        CONSTRAINT syst_complex_format_values_complex_format_fk
            REFERENCES ms_syst_data.syst_complex_formats (id) ON DELETE CASCADE
    ,format_default
        boolean
        NOT NULL DEFAULT FALSE
    ,syst_defined
        boolean
        NOT NULL DEFAULT FALSE
    ,user_maintainable
        boolean
        NOT NULL DEFAULT FALSE
    ,syst_description
        text
        NOT NULL
    ,user_description
        text
    ,sort_order
        integer
        NOT NULL
    ,syst_data
        jsonb
        NOT NULL
    ,syst_form
        jsonb
        NOT NULL
    ,user_data
        jsonb
    ,user_form
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

ALTER TABLE ms_syst_data.syst_complex_format_values OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_complex_format_values FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_complex_format_values TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_complex_format_values
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

DO
$DOCUMENTATION$
DECLARE
    -- Table
    v_comments_config ms_syst_priv.comments_config_table;

    -- Columns
    v_complex_format_id ms_syst_priv.comments_config_table_column;
    v_format_default    ms_syst_priv.comments_config_table_column;
    v_sort_order        ms_syst_priv.comments_config_table_column;
    v_syst_data         ms_syst_priv.comments_config_table_column;
    v_syst_form         ms_syst_priv.comments_config_table_column;
    v_user_data         ms_syst_priv.comments_config_table_column;
    v_user_form         ms_syst_priv.comments_config_table_column;

BEGIN

    --
    -- Table Config
    --

    v_comments_config.table_schema := 'ms_syst_data';
    v_comments_config.table_name   := 'syst_complex_format_values';

    v_comments_config.description :=
$DOC$The list of values provided by an enumeration as well as related behavioral and
informational metadata.$DOC$;

    --
    -- Column Configs
    --

    v_complex_format_id.column_name := 'complex_format_id';
    v_complex_format_id.description :=
$DOC$The format record with which the value is associated.$DOC$;

    v_format_default.column_name := 'format_default';
    v_format_default.description :=
$DOC$If true, indicates that this value is the default selection from all values
defined for the enumerations.  If false then the value record has no special
significance relative to defaulting.

Note that if a record is inserted or updated in this table with enum_default set
true, and another record already exists for the enumeration with its
enum_default set true, the newly inserted/updated record will take precedence
and the value record previously set to be default will have its enum_default
setting set to false.$DOC$;

    v_sort_order.column_name := 'sort_order';
    v_sort_order.description :=
$DOC$Indicates the sort ordering of the particular value record with the lowest value
sorting first.  When a value record for an enumeration is inserted or updated
and this column is being set to a value which equals another enumeration value
record for the same enumeration, the system assumes that the new record is
being set to precede the existing record and it will be set to sort after the
newly inserted/updated enumeration value.$DOC$;

    v_syst_data.column_name := 'syst_data';
    v_syst_data.description :=
$DOC$For the system expected data definition this column identifies the individual
fields that make up the complex format type along with the expected type and
other expected metadata for each field.$DOC$;

    v_syst_form.column_name := 'syst_form';
    v_syst_form.description :=
$DOC$Describes how the individual data fields of the complex format are
presented in user interfaces and printed documents.$DOC$;

    v_user_data.column_name := 'user_data';
    v_user_data.description :=
$DOC$Allows for custom user data fields to be defined in place of the system provided
data in syst_data.  Note that when this column is not null, it replaces the
system definition: it does not augment it.  This means that any system expected
data fields should also appear in the user data.$DOC$;

    v_user_form.column_name := 'user_form';
    v_user_form.description :=
$DOC$Allows for custom user layout of the format data fields in user interfaces and
other user presentations.  Note that when this column is not null, it replaces
the system definition and so any system expected layout elements should also
be accounted for in this user layout.$DOC$;

    v_comments_config.columns :=
        ARRAY [
              v_complex_format_id
            , v_format_default
            , v_sort_order
            , v_syst_data
            , v_syst_form
            , v_user_data
            , v_user_form
            ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( v_comments_config );

END;
$DOCUMENTATION$;
