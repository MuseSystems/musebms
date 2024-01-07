-- File:        syst_instances.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst_data/syst_instances/syst_instances.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_instances
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
        CONSTRAINT syst_instances_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_instances_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_instances_display_name_udx UNIQUE
    ,application_id
        uuid
        NOT NULL
        CONSTRAINT syst_instances_applications_fk
            REFERENCES ms_syst_data.syst_applications (id)
    ,instance_type_id
        uuid
        NOT NULL
        CONSTRAINT syst_instances_enum_instance_type_fk
            REFERENCES ms_syst_data.syst_enum_items (id)
    ,instance_state_id
        uuid
        NOT NULL
        CONSTRAINT syst_instances_enum_instance_state_fk
            REFERENCES ms_syst_data.syst_enum_items (id)
    ,owner_id
        uuid
        NOT NULL
        CONSTRAINT syst_instances_owners_fk
            REFERENCES ms_syst_data.syst_owners (id)
    ,owning_instance_id
        uuid
        CONSTRAINT syst_instances_owning_instance_fk
            REFERENCES ms_syst_data.syst_instances (id)
        CONSTRAINT syst_instances_self_ownership_chk
            CHECK (owning_instance_id IS NULL OR owning_instance_id != id)
    ,dbserver_name
        text
    ,instance_code
        bytea
        NOT NULL
    ,instance_options
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

ALTER TABLE ms_syst_data.syst_instances OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_instances FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_instances TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_instances
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_instance_types_enum_item_check
    AFTER INSERT ON ms_syst_data.syst_instances
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('instance_types', 'instance_type_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_instance_types_enum_item_check
    AFTER UPDATE ON ms_syst_data.syst_instances
    FOR EACH ROW WHEN ( old.instance_type_id != new.instance_type_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_enum_item_check(
                'instance_types', 'instance_type_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_i_instance_states_enum_item_check
    AFTER INSERT ON ms_syst_data.syst_instances
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('instance_states', 'instance_state_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_instance_states_enum_item_check
    AFTER UPDATE ON ms_syst_data.syst_instances
    FOR EACH ROW WHEN ( old.instance_state_id != new.instance_state_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_enum_item_check(
                'instance_states', 'instance_state_id');

CREATE TRIGGER b50_trig_a_i_syst_instances_create_instance_contexts
    AFTER INSERT ON ms_syst_data.syst_instances
    FOR EACH ROW
        EXECUTE PROCEDURE ms_syst_data.trig_a_i_syst_instances_create_instance_contexts();

DO
$DOCUMENTATION$
DECLARE
    -- Table
    var_comments_config ms_syst_priv.comments_config_table;

    -- Columns
    var_application_id     ms_syst_priv.comments_config_table_column;
    var_instance_type_id   ms_syst_priv.comments_config_table_column;
    var_instance_state_id  ms_syst_priv.comments_config_table_column;
    var_owner_id           ms_syst_priv.comments_config_table_column;
    var_owning_instance_id ms_syst_priv.comments_config_table_column;
    var_dbserver_name      ms_syst_priv.comments_config_table_column;
    var_instance_code      ms_syst_priv.comments_config_table_column;
    var_instance_options   ms_syst_priv.comments_config_table_column;

BEGIN

    --
    -- Table Config
    --

    var_comments_config.table_schema := 'ms_syst_data';
    var_comments_config.table_name   := 'syst_instances';

    var_comments_config.description :=
$DOC$Defines known application instances and provides their configuration settings.$DOC$;

    --
    -- Column Configs
    --

    var_application_id.column_name := 'application_id';
    var_application_id.description :=
$DOC$Indicates an instance of which application is being described by the record.$DOC$;

    var_instance_type_id.column_name := 'instance_type_id';
    var_instance_type_id.description :=
$DOC$Indicates the type of the instance.  This can designate instances as being
production or non-production, or make other functional differences between
instances created for different reasons based on the assigned instance type.$DOC$;

    var_instance_state_id.column_name := 'instance_state_id';
    var_instance_state_id.description :=
$DOC$Establishes the current life-cycle state of the instance record.  This can
determine functionality such as if the instance is usable, visible, or if it may
be purged from the database completely.$DOC$;

    var_owner_id.column_name := 'owner_id';
    var_owner_id.description :=
$DOC$Identifies the owner of the instance.  The owner is the entity which
commissioned the instance and is the "user" of the instance.  Owners have
nominal management rights over their instances, such as which access accounts
and which credential types are allowed to be used to authenticate to the owner's
instances.$DOC$;

    var_owning_instance_id.column_name := 'owning_instance_id';
    var_owning_instance_id.description :=
$DOC$In some cases, an instance is considered subordinate to another instance.  For
example, consider a production environment and a related sandbox environment.
The existence of the sandbox doesn't have real meaning without being associated
with some sort of production instance where the real work is performed.  This
kind of association becomes clearer in SaaS environments where a primary
instance is contracted for, but other supporting instances, such as a sandbox,
should follow certain account related actions of the primary.$DOC$;

    var_dbserver_name.column_name := 'dbserver_name';
    var_dbserver_name.description :=
$DOC$Identifies on which database server the instance is hosted. If empty, no
server has been assigned and the instance is unstartable.$DOC$;

    var_instance_code.column_name := 'instance_code';
    var_instance_code.description :=
$DOC$This is a random sequence of bytes intended for use in certain algorithmic
credential generation routines.$DOC$;
    var_instance_code.general_usage :=
$DOC$Note that losing this value may prevent the Instance from being started due to
bad credentials; there may be other consequences as well.$DOC$;

    var_instance_options.column_name := 'instance_options';
    var_instance_options.description :=
$DOC$A key/value store of values which define application or instance specific
options.$DOC$;

    var_comments_config.columns :=
        ARRAY [
              var_application_id
            , var_instance_type_id
            , var_instance_state_id
            , var_owner_id
            , var_owning_instance_id
            , var_dbserver_name
            , var_instance_code
            , var_instance_options
            ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config );

END;
$DOCUMENTATION$;
