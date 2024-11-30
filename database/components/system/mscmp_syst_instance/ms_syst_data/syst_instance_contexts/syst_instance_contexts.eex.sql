-- File:        syst_instance_contexts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst_data/syst_instance_contexts/syst_instance_contexts.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_instance_contexts
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
        CONSTRAINT syst_instance_contexts_pk PRIMARY KEY
    ,internal_name
        text COLLATE ms_syst_priv.variant_insensitive
        NOT NULL
        CONSTRAINT syst_instance_contexts_internal_name_udx UNIQUE
    ,instance_id
        uuid
        NOT NULL
        CONSTRAINT syst_instance_contexts_instances_fk
            REFERENCES ms_syst_data.syst_instances (id)
            ON DELETE CASCADE
    ,application_context_id
        uuid
        NOT NULL
        CONSTRAINT syst_instance_contexts_application_contexts_fk
            REFERENCES ms_syst_data.syst_application_contexts (id)
            ON DELETE CASCADE
    ,start_context
        boolean
        NOT NULl DEFAULT false
    ,db_pool_size
        integer
        NOT NULL DEFAULT 0
        CONSTRAINT syst_instance_contexts_db_pool_size_chk
            CHECK ( db_pool_size >= 0 )
    ,context_code
        bytea
        NOT NULL
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

ALTER TABLE ms_syst_data.syst_instance_contexts OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_instance_contexts FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_instance_contexts TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_instance_contexts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

DO
$DOCUMENTATION$
DECLARE
    -- Table
    v_comments_config ms_syst_priv.comments_config_table;

    -- Columns
    v_instance_id            ms_syst_priv.comments_config_table_column;
    v_application_context_id ms_syst_priv.comments_config_table_column;
    v_start_context          ms_syst_priv.comments_config_table_column;
    v_db_pool_size           ms_syst_priv.comments_config_table_column;
    v_context_code           ms_syst_priv.comments_config_table_column;

BEGIN

    --
    -- Table Config
    --
    v_comments_config.table_schema := 'ms_syst_data';
    v_comments_config.table_name   := 'syst_instance_contexts';

    v_comments_config.description :=
$DOC$Instance specific settings which determine how each Instance connects to the
defined Application Contexts.$DOC$;

    --
    -- Column Configs
    --

    v_instance_id.column_name := 'instance_id';
    v_instance_id.description :=
$DOC$Identifies the parent Instance for which Instance Contexts are being defined.$DOC$;

    v_application_context_id.column_name := 'application_context_id';
    v_application_context_id.description :=
$DOC$Identifies the Application Context which is being defined for the Instance.$DOC$;

    v_start_context.column_name := 'start_context';
    v_start_context.description :=
$DOC$Indicates whether the Instance Context should be started on Instance start.$DOC$;

    v_start_context.general_usage :=
$DOC$If true, indicates that the Instance Context should be started, so long as the
Application Context record is also set to allow context starting.  If false, the
Instance Context not be started, even if the related Application Context is set
to allow context starts.$DOC$;

    v_db_pool_size.column_name := 'db_pool_size';
    v_db_pool_size.description :=
$DOC$If the Application Context is a login datastore context, this value establishes
how many database connections to open on behalf of this Instance Context.$DOC$;

    v_context_code.column_name := 'context_code';
    v_context_code.description :=
$DOC$An Instance Context specific series of bytes which are used in algorithmic
credential generation.$DOC$;

    v_comments_config.columns :=
        ARRAY [
              v_instance_id
            , v_application_context_id
            , v_start_context
            , v_db_pool_size
            , v_context_code]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( v_comments_config );

END;
$DOCUMENTATION$;
