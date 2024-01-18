-- File:        mstr_person_contact_roles.eex.sql
-- Location:    musebms/database/components/application/mscmp_brm_person_contact/ms_appl_data/mstr_person_contact_roles/mstr_person_contact_roles.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE ms_appl_data.mstr_person_contact_roles
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
        CONSTRAINT mstr_person_contact_roles_pk PRIMARY KEY
    ,person_id
        uuid
        NOT NULL
        CONSTRAINT mstr_person_contact_roles_person_fk
            REFERENCES ms_appl_data.mstr_persons (id) ON DELETE CASCADE
    ,person_contact_role_id
        uuid
        NOT NULL
        CONSTRAINT mstr_person_contact_roles_enum_person_contact_role_fk
            REFERENCES ms_syst_data.syst_enum_items (id)
    ,place_id
        uuid
        CONSTRAINT mstr_person_contact_roles_place_fk
            REFERENCES ms_appl_data.mstr_places (id)
    ,contact_id
        uuid
        NOT NULL
        CONSTRAINT mstr_person_contact_roles_contact_fk
            REFERENCES ms_appl_data.mstr_contacts (id) ON DELETE CASCADE
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

ALTER TABLE ms_appl_data.mstr_person_contact_roles OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_appl_data.mstr_person_contact_roles FROM public;
GRANT ALL ON TABLE ms_appl_data.mstr_person_contact_roles TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_appl_data.mstr_person_contact_roles
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_person_contact_roles_enum_item_check
    AFTER INSERT ON ms_appl_data.mstr_person_contact_roles
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('person_contact_roles', 'person_contact_role_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_person_contact_roles_enum_item_check
    AFTER UPDATE ON ms_appl_data.mstr_person_contact_roles
    FOR EACH ROW WHEN ( old.person_contact_role_id != new.person_contact_role_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_enum_item_check(
                'person_contact_roles', 'person_contact_role_id');

DO
$DOCUMENTATION$
DECLARE
    -- Table
    var_comments_config ms_syst_priv.comments_config_table;

    -- Columns
    var_person_id              ms_syst_priv.comments_config_table_column;
    var_person_contact_role_id ms_syst_priv.comments_config_table_column;
    var_place_id               ms_syst_priv.comments_config_table_column;
    var_contact_id             ms_syst_priv.comments_config_table_column;

BEGIN

    --
    -- Table Config
    --

    var_comments_config.table_schema := 'ms_appl_data';
    var_comments_config.table_name   := 'mstr_person_contact_roles';

    var_comments_config.description :=
$DOC$Establishes the Roles that Contact records serve in relation to the given
Person.$DOC$;

    --
    -- Column Configs
    --

    var_person_id.column_name := 'person_id';
    var_person_id.description :=
$DOC$Identifies the Person which has the relationship to the Contact information.$DOC$;

    var_person_contact_role_id.column_name := 'person_contact_role_id';
    var_person_contact_role_id.description :=
$DOC$Indicates a specific use or purpose for the identified Contact information.$DOC$;

    var_place_id.column_name := 'place_id';
    var_place_id.description :=
$DOC$This is an optional value indicating whether the given Contact information is
associated with a known Place.$DOC$;
    var_place_id.general_usage :=
$DOC$If the Contact information is associated with a specific Place, a reference to
the Place record ID will appear here.  Otherwise the value will be `NULL`.$DOC$;

    var_contact_id.column_name := 'contact_id';
    var_contact_id.description :=
$DOC$A reference to the Contact record which serves the given Role for the given
Person.$DOC$;


    var_comments_config.columns :=
        ARRAY [
              var_person_id
            , var_person_contact_role_id
            , var_place_id
            , var_contact_id
            ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config );

END;
$DOCUMENTATION$;
