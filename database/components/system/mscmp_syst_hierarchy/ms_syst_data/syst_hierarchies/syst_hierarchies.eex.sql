-- File:        syst_hierarchies.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_hierarchy/ms_syst_data/syst_hierarchies/syst_hierarchies.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE ms_syst_data.syst_hierarchies
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
        CONSTRAINT syst_hierarchies_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_hierarchies_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_hierarchies_display_name_udx UNIQUE
    ,hierarchy_type_id
        uuid
        NOT NULL
        CONSTRAINT syst_hierarchies_hierarchy_type_fk
            REFERENCES ms_syst_data.syst_enum_items ( id )
            ON DELETE CASCADE
    ,hierarchy_state_id
        uuid
        NOT NULL
        CONSTRAINT syst_hierarchies_hierarchy_state_fk
            REFERENCES ms_syst_data.syst_enum_items ( id )
    ,syst_defined
        boolean
        NOT NULL DEFAULT FALSE
    ,user_maintainable
        boolean
        NOT NULL DEFAULT TRUE
    ,structured
        boolean
        NOT NULL DEFAULT TRUE
    ,syst_description
        text
        NOT NULL
    ,user_description
        text
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

ALTER TABLE ms_syst_data.syst_hierarchies OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_hierarchies FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_hierarchies TO <%= ms_owner %>;

CREATE TRIGGER c50_trig_b_i_syst_hierarchies_validate_inactive
    BEFORE INSERT ON ms_syst_data.syst_hierarchies
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_data.trig_b_i_syst_hierarchies_validate_inactive();

CREATE TRIGGER c50_trig_b_u_syst_hierarchies_validate_state_change
    BEFORE UPDATE ON ms_syst_data.syst_hierarchies
    FOR EACH ROW WHEN ( old.hierarchy_state_id != new.hierarchy_state_id )
        EXECUTE PROCEDURE ms_syst_data.trig_b_u_syst_hierarchies_validate_state_change();

CREATE TRIGGER c55_trig_b_u_syst_hierarchies_validate_structured
    BEFORE UPDATE ON ms_syst_data.syst_hierarchies
    FOR EACH ROW WHEN ( old.structured != new.structured )
        EXECUTE PROCEDURE ms_syst_data.trig_b_u_syst_hierarchies_validate_structured();

CREATE TRIGGER c50_trig_b_d_syst_hierarchies_validate_prereqs
    BEFORE DELETE ON ms_syst_data.syst_hierarchies
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_data.trig_b_d_syst_hierarchies_validate_prereqs();

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_hierarchies
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_hierarchy_states_enum_item_check
    AFTER INSERT ON ms_syst_data.syst_hierarchies
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('hierarchy_states', 'hierarchy_state_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_hierarchy_states_enum_item_check
    AFTER UPDATE ON ms_syst_data.syst_hierarchies
    FOR EACH ROW WHEN ( old.hierarchy_state_id != new.hierarchy_state_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_enum_item_check(
                'hierarchy_states', 'hierarchy_state_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_i_hierarchy_types_enum_item_check
    AFTER INSERT ON ms_syst_data.syst_hierarchies
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('hierarchy_types', 'hierarchy_type_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_hierarchy_types_enum_item_check
    AFTER UPDATE ON ms_syst_data.syst_hierarchies
    FOR EACH ROW WHEN ( old.hierarchy_type_id != new.hierarchy_type_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_enum_item_check(
                'hierarchy_types', 'hierarchy_type_id');

DO
$DOCUMENTATION$
DECLARE
    -- Table
    var_comments_config ms_syst_priv.comments_config_table;
    
    -- Columns
    var_hierarchy_type_id  ms_syst_priv.comments_config_table_column;
    var_hierarchy_state_id ms_syst_priv.comments_config_table_column;
    var_structured         ms_syst_priv.comments_config_table_column;
    
BEGIN
    
    --
    -- Table Config
    --
    
    var_comments_config.table_schema := 'ms_syst_data';
    var_comments_config.table_name   := 'syst_hierarchies';

    var_comments_config.description :=
$DOC$Establishes a hierarchical template for parent/child relationships to
follow. The `hierarchies` relation creates a type of hierarchy which is linked
to a specific feature or functional area of the application via a record's
`hierarchy_type_id` reference. Hierarchies is also the parent relation of
Hierarchy Items relation (`ms_syst_data.syst_hierarchy_items`)
records where each Hierarchy Items record represents a level of the
hierarchy.$DOC$;
    var_comments_config.general_usage :=
$DOC$Note that once the Hierarchy is active and in use by Hierarchy implementing
Components, most changes to the Hierarchy records will not be allowed to ensure
the consistency of currently used data.$DOC$;

    --
    -- Column Configs
    --

    var_hierarchy_type_id.column_name := 'hierarchy_type_id';
    var_hierarchy_type_id.description :=
$DOC$A reference indicating in which specific functional area or with which feature
of the application the Hierarchy is associated with.$DOC$;

    var_hierarchy_state_id.column_name := 'hierarchy_state_id';
    var_hierarchy_state_id.description :=
$DOC$A reference indicating at which point in the Hierarchy life-cycle the record
sits.$DOC$;
    var_hierarchy_state_id.general_usage :=
$DOC$The record may only be set in an `active` state if the record and any associated
Hierarchy Item records are in a consistent, valid state.  Similarly, the record
may only be set to an `inactive` state if the Hierarchy record is not in use,
which is defined as the record being referenced by an Hierarchy implementing
Component's records.$DOC$;

    var_structured.column_name := 'structured';
    var_structured.description :=
$DOC$A flag indicating whether or not the Hierarchy actually defines a structure, or
if the any implementations allow fully ad hoc structuring within the
implementing Component.$DOC$;
    var_structured.general_usage :=
$DOC$This configuration exists for cases where a Component implements Hierarchy
functionality, but can also operate while bypassing any hierarchy checks at all;
this way we can still require a Hierarchy record reference in the implementation
while allowing the Hierarchy definition itself be the configuration point for
determining whether or not hierarchical structure is required.$DOC$;

    var_comments_config.columns :=
        ARRAY [
              var_hierarchy_type_id
            , var_hierarchy_state_id
            , var_structured
            ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config );

END;
$DOCUMENTATION$;
