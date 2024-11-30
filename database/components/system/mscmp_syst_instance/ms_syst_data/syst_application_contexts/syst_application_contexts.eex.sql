-- File:        syst_application_contexts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst_data/syst_application_contexts/syst_application_contexts.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_application_contexts
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
        CONSTRAINT syst_application_contexts_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_application_contexts_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_application_contexts_display_name_udx UNIQUE
    ,application_id
        uuid
        NOT NULL
        CONSTRAINT syst_application_contexts_applications_fk
            REFERENCES ms_syst_data.syst_applications (id)
            ON DELETE CASCADE
    ,description
        text
        NOT NULL
    ,start_context
        boolean
        NOT NULL DEFAULT FALSE
    ,login_context
        boolean
        NOT NULL DEFAULT FALSE
    ,database_owner_context
        boolean
        NOT NULL DEFAULT FALSE
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

ALTER TABLE ms_syst_data.syst_application_contexts OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_application_contexts FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_application_contexts TO <%= ms_owner %>;

CREATE TRIGGER c50_trig_b_d_syst_application_contexts_validate_owner_context
    BEFORE DELETE ON ms_syst_data.syst_application_contexts
    FOR EACH ROW
    WHEN (old.database_owner_context)
EXECUTE PROCEDURE ms_syst_data.trig_b_iud_syst_application_contexts_validate_owner_context();

CREATE TRIGGER c50_trig_b_i_syst_application_contexts_validate_owner_context
    BEFORE INSERT ON ms_syst_data.syst_application_contexts
    FOR EACH ROW
EXECUTE PROCEDURE ms_syst_data.trig_b_iud_syst_application_contexts_validate_owner_context();

CREATE TRIGGER c50_trig_b_u_syst_application_contexts_validate_owner_context
    BEFORE UPDATE ON ms_syst_data.syst_application_contexts
    FOR EACH ROW
    WHEN (new.database_owner_context AND old.database_owner_context != new.database_owner_context)
EXECUTE PROCEDURE ms_syst_data.trig_b_iud_syst_application_contexts_validate_owner_context();

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_application_contexts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

DO
$DOCUMENTATION$
DECLARE
    -- Table
    v_comments_config ms_syst_priv.comments_config_table;

    -- Columns
    v_application_id         ms_syst_priv.comments_config_table_column;
    v_description            ms_syst_priv.comments_config_table_column;
    v_start_context          ms_syst_priv.comments_config_table_column;
    v_login_context          ms_syst_priv.comments_config_table_column;
    v_database_owner_context ms_syst_priv.comments_config_table_column;

BEGIN

    --
    -- Table Config
    --
    v_comments_config.table_schema := 'ms_syst_data';
    v_comments_config.table_name   := 'syst_application_contexts';

    v_comments_config.description :=
$DOC$Applications are written with certain security and connection
characteristics in mind which correlate to database roles used by the
application for establishing connections.  This table defines the datastore
contexts the application is expecting so that Instance records can be validated
against the expectations.$DOC$;

    --
    -- Column Configs
    --

    v_application_id.column_name := 'application_id';
    v_application_id.description :=
$DOC$References the ms_syst_data.syst_applications record which owns the
context.$DOC$;

    v_description.column_name := 'description';
    v_description.description :=
$DOC$A user visible description of the application context, its role in the
application, uses, and any other helpful text.$DOC$;

    v_start_context.column_name := 'start_context';
    v_start_context.description :=
$DOC$Indicates whether or not the system should start the context for any Instances
of the application.$DOC$;
    v_start_context.general_usage :=
$DOC$If true, any Instance of the Application will start its
associated context so long as it is enabled at the Instance level.  If false,
the context is disabled for all Instances in the Application regardless of their
individual settings.$DOC$;

    v_login_context.column_name := 'login_context';
    v_login_context.description :=
$DOC$Indicates whether or not the Application Context is used for making
connections to the database.$DOC$;
    v_login_context.general_usage :=
$DOC$If true, each associated Instance Context is
created as a role in the database with the LOGIN privilege; if false, the
role is created in the database as a NOLOGIN role.  Most often non-login
Application Contexts are created to serve as the database role owning database
objects.$DOC$;

    v_database_owner_context.column_name := 'database_owner_context';
    v_database_owner_context.description :=
$DOC$Indicates if the Application Context represents the database role used for object
ownership.$DOC$;
    v_database_owner_context.general_usage :=
$DOC$If true, the Application Context does represent the ownership role
and should also be defined as a login_context = FALSE context.  If false, the
role is not used for database object ownership.  Note that there should only
ever be one Application Context defined as database_owner_context = TRUE for any
one Application.$DOC$;

    v_comments_config.columns :=
        ARRAY [
             v_application_id
            ,v_description
            ,v_start_context
            ,v_login_context
            ,v_database_owner_context
            ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( v_comments_config );

END;
$DOCUMENTATION$;
