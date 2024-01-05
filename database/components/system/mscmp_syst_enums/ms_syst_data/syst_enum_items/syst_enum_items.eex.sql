-- File:        syst_enum_items.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_enums/ms_syst_data/syst_enum_items/syst_enum_items.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_enum_items
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
        CONSTRAINT syst_enum_items_pk PRIMARY KEY
    ,internal_name
        text COLLATE ms_syst_priv.variant_insensitive
        NOT NULL
        CONSTRAINT syst_enum_items_internal_name_udx UNIQUE
    ,display_name
        text COLLATE ms_syst_priv.variant_insensitive
        NOT NULL
        CONSTRAINT syst_enum_items_display_name_udx UNIQUE
    ,external_name
        text
        NOT NULL
    ,enum_id
        uuid
        NOT NULL
        CONSTRAINT syst_enum_items_enum_fk
            REFERENCES ms_syst_data.syst_enums (id) ON DELETE CASCADE
    ,functional_type_id
        uuid
        CONSTRAINT syst_enum_items_enum_functional_type_fk
            REFERENCES ms_syst_data.syst_enum_functional_types (id)
    ,enum_default
        boolean
        NOT NULL DEFAULT FALSE
    ,functional_type_default
        boolean
        NOT NULL DEFAULT FALSE
    ,syst_defined
        boolean
        NOT NULL DEFAULT FALSE
    ,user_maintainable
        boolean
        NOT NULL DEFAULT TRUE
    ,syst_description
        text
        NOT NULL
    ,user_description
        text
    ,sort_order
        smallint
        NOT NULL
    ,syst_options
        jsonb
    ,user_options
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

ALTER TABLE ms_syst_data.syst_enum_items OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_enum_items FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_enum_items TO <%= ms_owner %>;

CREATE TRIGGER b50_trig_b_i_syst_enum_items_maintain_sort_order
    BEFORE INSERT
    ON ms_syst_data.syst_enum_items
    FOR EACH ROW
EXECUTE PROCEDURE ms_syst_data.trig_b_i_syst_enum_items_maintain_sort_order( );

CREATE TRIGGER c50_trig_b_i_syst_enum_items_validate_functional_type
    BEFORE INSERT
    ON ms_syst_data.syst_enum_items
    FOR EACH ROW
EXECUTE PROCEDURE ms_syst_data.trig_b_iu_syst_enum_items_validate_functional_types( );

CREATE TRIGGER c50_trig_b_u_syst_enum_items_validate_functional_type
    BEFORE UPDATE
    ON ms_syst_data.syst_enum_items
    FOR EACH ROW
    WHEN ( old.functional_type_id IS DISTINCT FROM new.functional_type_id )
EXECUTE PROCEDURE ms_syst_data.trig_b_iu_syst_enum_items_validate_functional_types( );

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE
    ON ms_syst_data.syst_enum_items
    FOR EACH ROW
EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns( );

CREATE TRIGGER b55_trig_a_iu_syst_enum_items_maintain_sort_order
    AFTER INSERT
    ON ms_syst_data.syst_enum_items
    FOR EACH ROW
EXECUTE PROCEDURE ms_syst_data.trig_a_iu_syst_enum_items_maintain_sort_order( );

DO
$DOCUMENTATION$
DECLARE
    var_comments_config ms_syst_priv.comments_config_table;

    var_enum_id                 ms_syst_priv.comments_config_table_column;
    var_functional_type_id      ms_syst_priv.comments_config_table_column;
    var_enum_default            ms_syst_priv.comments_config_table_column;
    var_functional_type_default ms_syst_priv.comments_config_table_column;
    var_sort_order              ms_syst_priv.comments_config_table_column;
    var_syst_options            ms_syst_priv.comments_config_table_column;
    var_user_options            ms_syst_priv.comments_config_table_column;

BEGIN
    var_comments_config.table_schema := 'ms_syst_data';
    var_comments_config.table_name   := 'syst_enum_items';

    var_comments_config.description :=
$DOC$The list of values provided by an Enumeration as well as related behavioral and
informational metadata.$DOC$;

    var_enum_id.column_name := 'enum_id';
    var_enum_id.description :=
$DOC$The enumeration record with which the value is associated.$DOC$;

    var_functional_type_id.column_name := 'functional_type_id';
    var_functional_type_id.description :=
$DOC$If the enumeration requires a functional type, this column references the
functional type associated with the enumeration value record.$DOC$;

    var_functional_type_id.general_usage :=
$DOC$Note that not all enumerations require functional types.  If
syst_enum_functional_types records exist for an enumeration, then this column
will be required for any values of that enumeration; if there are no functional
types defined for an enumeration, the this column must remain NULL.$DOC$;

    var_enum_default.column_name := 'enum_default';
    var_enum_default.description :=
$DOC$If true, indicates that this value is the default selection from all values
defined for the enumerations.$DOC$;

    var_enum_default.general_usage :=
$DOC$Note that if a record is inserted or updated in this table with enum_default set
true, and another record already exists for the enumeration with its
enum_default set true, the newly inserted/updated record will take precedence
and the value record previously set to be default will have its enum_default
setting set to false.

If false then the value record has no special significance relative to
defaulting.$DOC$;

    var_functional_type_default.column_name := 'functional_type_default';
    var_functional_type_default.description :=
$DOC$If true, the value record is the default selection for any of a specific
fucntional type.  This is helpful in situations where a progression of state is
automatically processed by the system and the state is represented by an
enumeration.$DOC$;

    var_functional_type_default.general_usage :=
$DOC$Note that if a record is inserted or updated in this table with its
functional_type_default set true, and another record already exists for the
enumeration/functional type combination with its functional_type_default set
true, the newly inserted/updated record will take precedence and the value
record previously set to be default will have its functional_type_default
setting set to false.

In cases where there are no functional types, this value should simply remain
false.$DOC$;


    var_sort_order.column_name := 'sort_order';
    var_sort_order.description :=
$DOC$Indicates the sort ordering of the particular value record with the lowest value
sorting first.$DOC$;

    var_sort_order.general_usage :=
$DOC$When a value record for an enumeration is inserted or updated and this
column is being set to a value which equals another enumeration value record for
the same enumeration, the system assumes that the new record is being set to
precede the existing record and it will be set to sort after the newly
inserted/updated enumeration value.$DOC$;

    var_syst_options.column_name := 'syst_options';
    var_syst_options.description :=
$DOC$Extended options and metadata which describe the behavior and meaning of the
specific value within the enumeration.$DOC$;

    var_syst_options.general_usage :=
$DOC$The owning syst_enums record's default_syst_options column will indicate
what syst_options are required or available and establishes default values for
them.$DOC$;

    var_user_options.column_name := 'user_options';
    var_user_options.description :=
$DOC$Extended user defined options, similar to syst_options, but for the purpose of
driving custom functionality.$DOC$;

    var_comments_config.columns :=
        ARRAY [
              var_enum_id
            , var_functional_type_id
            , var_enum_default
            , var_functional_type_default
            , var_sort_order
            , var_syst_options
            , var_user_options]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config);

END;
$DOCUMENTATION$;
