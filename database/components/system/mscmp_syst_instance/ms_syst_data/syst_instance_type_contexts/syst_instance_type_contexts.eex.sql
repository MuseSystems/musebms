-- File:        syst_instance_type_contexts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst_data/syst_instance_type_contexts/syst_instance_type_contexts.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_instance_type_contexts
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
        CONSTRAINT syst_instance_type_contexts_pk PRIMARY KEY
    ,instance_type_application_id
        uuid
        NOT NULL
        CONSTRAINT syst_instance_type_contexts_inst_type_app_fk
            REFERENCES ms_syst_data.syst_instance_type_applications (id)
            ON DELETE CASCADE
    ,application_context_id
        uuid
        NOT NULL
        CONSTRAINT syst_instance_type_contexts_application_contexts_fk
            REFERENCES ms_syst_data.syst_application_contexts (id)
            ON DELETE CASCADE
    ,default_db_pool_size
        integer
        NOT NULL DEFAULT 0
        CONSTRAINT syst_instance_type_contexts_default_db_pool_size_chk
            CHECK ( default_db_pool_size >= 0 )
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
    ,CONSTRAINT syst_instance_type_contexts_instance_types_applications_udx
        UNIQUE (instance_type_application_id, application_context_id)
);

ALTER TABLE ms_syst_data.syst_instance_type_contexts OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_instance_type_contexts FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_instance_type_contexts TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_instance_type_contexts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

DO
$DOCUMENTATION$
DECLARE
    -- Table
    var_comments_config ms_syst_priv.comments_config_table;

    -- Columns
    var_instance_type_application_id ms_syst_priv.comments_config_table_column;
    var_application_context_id       ms_syst_priv.comments_config_table_column;
    var_default_db_pool_size         ms_syst_priv.comments_config_table_column;

BEGIN

    --
    -- Table Config
    --

    var_comments_config.table_schema := 'ms_syst_data';
    var_comments_config.table_name   := 'syst_instance_type_contexts';

    var_comments_config.description :=
$DOC$Establishes Instance Type defaults for each of an Application's defined
datastore contexts.$DOC$;

    var_comments_config.general_usage :=
$DOC$In practice, these records are used in the creation of Instance Context records,
but do not establish a direct relationship; records in this table simply inform
us what Instance Contexts should exist and give us default values to use in
their creation.$DOC$;

    --
    -- Column Configs
    --

    var_instance_type_application_id.column_name := 'instance_type_application_id';
    var_instance_type_application_id.description :=
$DOC$The Instance Type/Application association to which the context definition
belongs.$DOC$;

    var_application_context_id.column_name := 'application_context_id';
    var_application_context_id.description :=
$DOC$The Application Context which is being represented in the Instance Type.$DOC$;

    var_default_db_pool_size.column_name := 'default_db_pool_size';
    var_default_db_pool_size.description :=
$DOC$A default pool size which is assigned to new Instances of the Instance Type
unless the creator of the Instance specifies a different value.$DOC$;

    var_comments_config.columns :=
        ARRAY [
              var_instance_type_application_id
            , var_application_context_id
            , var_default_db_pool_size
            ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config );

END;
$DOCUMENTATION$;
