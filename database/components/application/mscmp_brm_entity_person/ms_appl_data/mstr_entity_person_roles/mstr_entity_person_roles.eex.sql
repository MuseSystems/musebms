-- File:        mstr_entity_person_roles.eex.sql
-- Location:    musebms/database/components/application/mscmp_brm_entity_person/ms_appl_data/mstr_entity_person_roles/mstr_entity_person_roles.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE ms_appl_data.mstr_entity_person_roles
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
        CONSTRAINT mstr_entity_person_roles_pk PRIMARY KEY
    ,person_id
        uuid
        NOT NULL
        CONSTRAINT mstr_entity_person_roles_person_fk
            REFERENCES ms_appl_data.mstr_persons (id) ON DELETE CASCADE
    ,entity_id
        uuid
        NOT NULL
        CONSTRAINT mstr_entity_person_roles_entity_fk
            REFERENCES ms_appl_data.mstr_entities (id) ON DELETE CASCADE
    ,entity_person_role_id
        uuid
        NOT NULL
        CONSTRAINT mstr_entity_person_roles_enum_entity_person_role_fk
            REFERENCES ms_syst_data.syst_enum_items (id)
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
    ,CONSTRAINT mstr_entity_person_roles_person_entity_role_udx
        UNIQUE (person_id, entity_id, entity_person_role_id)
);

ALTER TABLE ms_appl_data.mstr_entity_person_roles OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_appl_data.mstr_entity_person_roles FROM public;
GRANT ALL ON TABLE ms_appl_data.mstr_entity_person_roles TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_appl_data.mstr_entity_person_roles
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_entity_person_roles_enum_item_check
    AFTER INSERT ON ms_appl_data.mstr_entity_person_roles
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('entity_person_roles', 'entity_person_role_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_entity_person_roles_enum_item_check
    AFTER UPDATE ON ms_appl_data.mstr_entity_person_roles
    FOR EACH ROW WHEN ( old.entity_person_role_id != new.entity_person_role_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_enum_item_check(
                'entity_person_roles', 'entity_person_role_id');

DO
$DOCUMENTATION$
DECLARE
    -- Table
    var_comments_config ms_syst_priv.comments_config_table;

    -- Columns
    var_person_id             ms_syst_priv.comments_config_table_column;
    var_entity_id             ms_syst_priv.comments_config_table_column;
    var_entity_person_role_id ms_syst_priv.comments_config_table_column;

BEGIN

    --
    -- Table Config
    --

    var_comments_config.table_schema := 'ms_appl_data';
    var_comments_config.table_name   := 'mstr_entity_person_roles';

    var_comments_config.description :=
$DOC$Establishes the relationship between individual persons and and entity.$DOC$;

    var_comments_config.general_usage :=
$DOC$Note that for now a simple table with the Entity, Person, and the Role assigned
is sufficient for expressing the relationship, though in future it may be
appropriate to have specific relationship tables like Entity/Entity
relationships should the relationships not be containable in a single attribute
describing the Role.$DOC$;

    --
    -- Column Configs
    --

    var_person_id.column_name := 'person_id';
    var_person_id.description :=
$DOC$The Person that is being assigned a Role with the Entity.$DOC$;

    var_entity_id.column_name := 'entity_id';
    var_entity_id.description :=
$DOC$The Entity with which the identified Person has a Role.  In many regards,
this field identifies the Owner of the record.$DOC$;

    var_entity_person_role_id.column_name := 'entity_person_role_id';
    var_entity_person_role_id.description :=
$DOC$Identifies the Role being assigned to the Person for the identified Entity.$DOC$;


    var_comments_config.columns :=
        ARRAY [
              var_person_id
            , var_entity_id
            , var_entity_person_role_id
            ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config );

END;
$DOCUMENTATION$;
