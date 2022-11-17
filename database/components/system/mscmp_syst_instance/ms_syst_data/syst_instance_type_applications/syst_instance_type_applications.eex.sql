-- File:        syst_instance_type_applications.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst_data/syst_instance_type_applications/syst_instance_type_applications.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_instance_type_applications
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_instance_type_applications_pk PRIMARY KEY
    ,instance_type_id
        uuid
        NOT NULL
        CONSTRAINT syst_instance_type_applications_instance_types_fk
            REFERENCES ms_syst_data.syst_enum_items (id)
            ON DELETE CASCADE
    ,application_id
        uuid
        NOT NULL
        CONSTRAINT syst_instance_type_applications_applications_fk
            REFERENCES ms_syst_data.syst_applications (id)
            ON DELETE CASCADE
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
    ,CONSTRAINT syst_instance_type_applications_instance_type_applications_udx
        UNIQUE (instance_type_id, application_id)
);

ALTER TABLE ms_syst_data.syst_instance_type_applications OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_instance_type_applications FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_instance_type_applications TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_instance_type_applications
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_instance_types_enum_item_check
    AFTER INSERT ON ms_syst_data.syst_instance_type_applications
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('instance_types', 'instance_type_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_instance_types_enum_item_check
    AFTER UPDATE ON ms_syst_data.syst_instance_type_applications
    FOR EACH ROW WHEN ( old.instance_type_id != new.instance_type_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_enum_item_check('instance_types', 'instance_type_id');

CREATE TRIGGER b50_trig_a_i_syst_instance_type_apps_create_inst_type_contexts
    AFTER INSERT ON ms_syst_data.syst_instance_type_applications
    FOR EACH ROW
        EXECUTE PROCEDURE ms_syst_data.trig_a_i_syst_instance_type_apps_create_inst_type_contexts();

COMMENT ON
    TABLE ms_syst_data.syst_instance_type_applications IS
$DOC$A many-to-many relation indicating which Instance Types are usable for each
Application.

Note that creating ms_syst_data.syst_application_contexts records prior to
inserting an Instance Type/Application association into this table is
recommended as default Instance Type Context records can be created
automatically on INSERT into this table so long as the supporting data is
available.  After insert here, manipulations of what Contexts Applications
require must be handled manually.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_type_applications.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_type_applications.instance_type_id IS
$DOC$A reference to the Instance Type being associated to an Application.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_type_applications.application_id IS
$DOC$A reference to the Application being associated with the Instance Type.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_type_applications.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_type_applications.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_type_applications.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_type_applications.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_type_applications.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_type_applications.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_type_applications.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
