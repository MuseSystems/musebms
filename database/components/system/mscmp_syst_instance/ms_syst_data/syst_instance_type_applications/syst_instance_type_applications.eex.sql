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
        NOT NULL DEFAULT uuid_generate_v7( )
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

DO
$DOCUMENTATION$
DECLARE
    -- Table
    var_comments_config ms_syst_priv.comments_config_table;

    -- Columns
    var_instance_type_id ms_syst_priv.comments_config_table_column;
    var_application_id   ms_syst_priv.comments_config_table_column;

BEGIN

    --
    -- Table Config
    --

    var_comments_config.table_schema := 'ms_syst_data';
    var_comments_config.table_name   := 'syst_instance_type_applications';

    var_comments_config.description :=
$DOC$A many-to-many relation indicating which Instance Types are usable for each
Application.$DOC$;

    var_comments_config.general_usage :=
$DOC$Note that creating ms_syst_data.syst_application_contexts records prior to
inserting an Instance Type/Application association into this table is
recommended as default Instance Type Context records can be created
automatically on INSERT into this table so long as the supporting data is
available.  After insert here, manipulations of what Contexts Applications
require must be handled manually.$DOC$;

    --
    -- Column Configs
    --

    var_instance_type_id.column_name := 'instance_type_id';
    var_instance_type_id.description :=
$DOC$A reference to the Instance Type being associated to an Application.$DOC$;

    var_application_id.column_name := 'application_id';
    var_application_id.description :=
$DOC$A reference to the Application being associated with the Instance Type.$DOC$;

    var_comments_config.columns :=
        ARRAY [
              var_instance_type_id
            , var_application_id
            ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config );

END;
$DOCUMENTATION$;
