-- File:        syst_perm_roles.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_perms/ms_syst_data/syst_perm_roles/syst_perm_roles.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE ms_syst_data.syst_perm_roles
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
        CONSTRAINT syst_perm_roles_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_perm_roles_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_perm_roles_display_name_udx UNIQUE
    ,perm_functional_type_id
        uuid
        NOT NULL
        CONSTRAINT syst_perm_roles_perm_functional_type_fk
            REFERENCES ms_syst_data.syst_perm_functional_types ( id )
    ,syst_defined
        boolean
        NOT NULL DEFAULT FALSE
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
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
);

ALTER TABLE ms_syst_data.syst_perm_roles OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_perm_roles FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_perm_roles TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_perm_roles
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

DO
$DOCUMENTATION$
DECLARE
    -- Table
    var_comments_config ms_syst_priv.comments_config_table;

    -- Columns
    var_perm_functional_type_id ms_syst_priv.comments_config_table_column;

BEGIN

    --
    -- Table Config
    --

    var_comments_config.table_schema := 'ms_syst_data';
    var_comments_config.table_name   := 'syst_perm_roles';

    var_comments_config.description :=
$DOC$Defines collections of permissions which are then assignable to users.$DOC$;

    --
    -- Column Configs
    --

    var_perm_functional_type_id.column_name := 'perm_functional_type_id';
    var_perm_functional_type_id.description :=
$DOC$Assigns the Permission Role to a specific Permission Functional Type.$DOC$;
    var_perm_functional_type_id.general_usage :=
$DOC$Only Permissions with the same Permission Functional Type may be granted by the
Permission Role.$DOC$;


    var_comments_config.columns :=
        ARRAY [ var_perm_functional_type_id ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config );

END;
$DOCUMENTATION$;
