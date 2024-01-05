-- File:        syst_enum_functional_types.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_enums/ms_syst_data/syst_enum_functional_types/syst_enum_functional_types.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_enum_functional_types
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
        CONSTRAINT syst_enum_functional_types_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_enum_functional_types_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_enum_functional_types_display_name_udx UNIQUE
    ,external_name
        text
        NOT NULL
    ,enum_id
        uuid
        NOT NULL
        CONSTRAINT syst_enum_functional_types_enum_fk
            REFERENCES ms_syst_data.syst_enums (id) ON DELETE CASCADE
    ,syst_description
        text
        NOT NULL
    ,user_description
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

ALTER TABLE ms_syst_data.syst_enum_functional_types OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_enum_functional_types FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_enum_functional_types TO <%= ms_owner %>;

CREATE TRIGGER a10_trig_b_i_syst_enum_functional_type_validate_new_allowed
    BEFORE INSERT ON ms_syst_data.syst_enum_functional_types
    FOR EACH ROW
    EXECUTE PROCEDURE ms_syst_data.trig_b_i_syst_enum_functional_type_validate_new_allowed( );

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_enum_functional_types
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

DO
$DOCUMENTATION$
DECLARE
    var_comments_config ms_syst_priv.comments_config_table;

    var_enum_id  ms_syst_priv.comments_config_table_column;
BEGIN
    var_comments_config.table_schema := 'ms_syst_data';
    var_comments_config.table_name   := 'syst_enum_functional_types';

    var_comments_config.description :=
$DOC$For those Enumerations requiring Functional Type designation, this table defines
the available types and persists related metadata.  Note that not all
Enumerations require Functional Types.$DOC$;

    var_enum_id.column_name := 'enum_id';
    var_enum_id.description :=
$DOC$A reference to the owning Enumeration of the functional type.$DOC$;


    var_comments_config.columns :=
        ARRAY [ var_enum_id ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config);

END;
$DOCUMENTATION$;
