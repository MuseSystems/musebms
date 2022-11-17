-- File:        syst_instances.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/msbms_syst_data/syst_instances/syst_instances.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE msbms_syst_data.syst_instances
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
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
            REFERENCES msbms_syst_data.syst_applications (id)
    ,instance_type_id
        uuid
        NOT NULL
        CONSTRAINT syst_instances_enum_instance_type_fk
            REFERENCES msbms_syst_data.syst_enum_items (id)
    ,instance_state_id
        uuid
        NOT NULL
        CONSTRAINT syst_instances_enum_instance_state_fk
            REFERENCES msbms_syst_data.syst_enum_items (id)
    ,owner_id
        uuid
        NOT NULL
        CONSTRAINT syst_instances_owners_fk
            REFERENCES msbms_syst_data.syst_owners (id)
    ,owning_instance_id
        uuid
        CONSTRAINT syst_instances_owning_instance_fk
            REFERENCES msbms_syst_data.syst_instances (id)
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

ALTER TABLE msbms_syst_data.syst_instances OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_syst_data.syst_instances FROM public;
GRANT ALL ON TABLE msbms_syst_data.syst_instances TO <%= msbms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON msbms_syst_data.syst_instances
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_instance_types_enum_item_check
    AFTER INSERT ON msbms_syst_data.syst_instances
    FOR EACH ROW EXECUTE PROCEDURE
        msbms_syst_priv.trig_a_iu_enum_item_check('instance_types', 'instance_type_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_instance_types_enum_item_check
    AFTER UPDATE ON msbms_syst_data.syst_instances
    FOR EACH ROW WHEN ( old.instance_type_id != new.instance_type_id)
        EXECUTE PROCEDURE
            msbms_syst_priv.trig_a_iu_enum_item_check(
                'instance_types', 'instance_type_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_i_instance_states_enum_item_check
    AFTER INSERT ON msbms_syst_data.syst_instances
    FOR EACH ROW EXECUTE PROCEDURE
        msbms_syst_priv.trig_a_iu_enum_item_check('instance_states', 'instance_state_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_instance_states_enum_item_check
    AFTER UPDATE ON msbms_syst_data.syst_instances
    FOR EACH ROW WHEN ( old.instance_state_id != new.instance_state_id)
        EXECUTE PROCEDURE
            msbms_syst_priv.trig_a_iu_enum_item_check(
                'instance_states', 'instance_state_id');

CREATE TRIGGER b50_trig_a_i_syst_instances_create_instance_contexts
    AFTER INSERT ON msbms_syst_data.syst_instances
    FOR EACH ROW
        EXECUTE PROCEDURE msbms_syst_data.trig_a_i_syst_instances_create_instance_contexts();

COMMENT ON
    TABLE msbms_syst_data.syst_instances IS
$DOC$Defines known application instances and provides their configuration settings.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instances.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instances.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instances.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instances.application_id IS
$DOC$Indicates an instance of which application is being described by the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instances.instance_type_id IS
$DOC$Indicates the type of the instance.  This can designate instances as being
production or non-production, or make other functional differences between
instances created for different reasons based on the assigned instance type.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instances.instance_state_id IS
$DOC$Establishes the current life-cycle state of the instance record.  This can
determine functionality such as if the instance is usable, visible, or if it may
be purged from the database completely.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instances.owner_id IS
$DOC$Identifies the owner of the instance.  The owner is the entity which
commissioned the instance and is the "user" of the instance.  Owners have
nominal management rights over their instances, such as which access accounts
and which credential types are allowed to be used to authenticate to the owner's
instances.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instances.owning_instance_id IS
$DOC$In some cases, an instance is considered subordinate to another instance.  For
example, consider a production environment and a related sandbox environment.
The existence of the sandbox doesn't have real meaning without being associated
with some sort of production instance where the real work is performed.  This
kind of association becomes clearer in SaaS environments where a primary
instance is contracted for, but other supporting instances, such as a sandbox,
should follow certain account related actions of the primary.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instances.dbserver_name IS
$DOC$Identifies on which database server the instance is hosted. If empty, no
server has been assigned and the instance is unstartable.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instances.instance_code IS
$DOC$This is a random sequence of bytes intended for use in certain algorithmic
credential generation.  Note that losing this value may prevent the Instance
from being started due to bad credentials; there may be other consequences as
well.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instances.instance_options IS
$DOC$A key/value store of values which define application or instance specific
options.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instances.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instances.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instances.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instances.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instances.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instances.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_instances.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;