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
        NOT NULL DEFAULT uuid_generate_v1( )
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

COMMENT ON
    TABLE ms_syst_data.syst_application_contexts IS
$DOC$Applications are written with certain security and connection
characteristics in mind which correlate to database roles used by the
application for establishing connections.  This table defines the datastore
contexts the application is expecting so that Instance records can be validated
against the expectations.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_application_contexts.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_application_contexts.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_application_contexts.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_application_contexts.application_id IS
$DOC$References the ms_syst_data.syst_applications record which owns the
context.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_application_contexts.start_context IS
$DOC$Indicates whether or not the system should start the context for any Instances
of the application.  If true, any Instance of the Application will start its
associated context so long as it is enabled at the Instance level.  If false,
the context is disabled for all Instances in the Application regardless of their
individual settings.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_application_contexts.login_context IS
$DOC$Indicates whether or not the Application Context is used for making
connections to the database.  If true, each associated Instance Context is
created as a role in the database with the LOGIN privilege; if false, the
role is created in the database as a NOLOGIN role.  Most often non-login
Application Contexts are created to serve as the database role owning database
objects.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_application_contexts.database_owner_context IS
$DOC$Indicates if the Application Context represents the database role used for object
ownership.  If true, the Application Context does represent the ownership role
and should also be defined as a login_context = FALSE context.  If false, the
role is not used for database object ownership.  Note that there should only
ever be one Application Context defined as database_owner_context = TRUE for any
one Application.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_application_contexts.description IS
$DOC$A user visible description of the application context, its role in the
application, uses, and any other helpful text.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_application_contexts.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_application_contexts.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_application_contexts.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_application_contexts.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_application_contexts.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_application_contexts.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_application_contexts.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
