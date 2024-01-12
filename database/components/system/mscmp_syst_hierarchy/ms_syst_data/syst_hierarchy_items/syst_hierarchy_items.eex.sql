-- File:        syst_hierarchy_items.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_hierarchy/ms_syst_data/syst_hierarchy_items/syst_hierarchy_items.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE ms_syst_data.syst_hierarchy_items
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
        CONSTRAINT syst_hierarchy_items_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_hierarchy_items_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_hierarchy_items_display_name_udx UNIQUE
    ,external_name
        text
        NOT NULL
    ,hierarchy_id
        uuid
        NOT NULL
        CONSTRAINT syst_hierarchy_items_hierarchy_fk
            REFERENCES ms_syst_data.syst_hierarchies ( id )
            ON DELETE CASCADE
    ,hierarchy_depth
        smallint
        NOT NULL
    ,CONSTRAINT syst_hierarchy_items_depth_udx
        UNIQUE (hierarchy_id, hierarchy_depth)
        DEFERRABLE
        INITIALLY DEFERRED
    ,required
        boolean
        NOT NULL DEFAULT TRUE
    ,allow_leaf_nodes
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

ALTER TABLE ms_syst_data.syst_hierarchy_items OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_hierarchy_items FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_hierarchy_items TO <%= ms_owner %>;

CREATE TRIGGER b50_trig_b_iu_syst_hierarchy_items_depth_maint
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_hierarchy_items
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_data.trig_b_iu_syst_hierarchy_items_depth_maint();

CREATE TRIGGER c50_trig_b_i_syst_hierarchy_items_hierarchy_prereqs
    BEFORE INSERT ON ms_syst_data.syst_hierarchy_items
    FOR EACH ROW
        EXECUTE PROCEDURE ms_syst_data.trig_b_i_syst_hierarchy_items_hierarchy_prereqs();

CREATE TRIGGER c50_trig_b_u_syst_hierarchy_items_hierarchy_inactive_check
    BEFORE UPDATE ON ms_syst_data.syst_hierarchy_items
    FOR EACH ROW WHEN (    new.hierarchy_depth != old.hierarchy_depth
                        OR new.required        != old.required
                        OR new.allow_leaf_nodes != old.allow_leaf_nodes)
        EXECUTE PROCEDURE
            ms_syst_data.trig_b_u_syst_hierarchy_items_hierarchy_inactive_check();

CREATE TRIGGER c50_trig_b_d_syst_hierarchy_items_hierarchy_inactive_check
    BEFORE DELETE ON ms_syst_data.syst_hierarchy_items
    FOR EACH ROW
        EXECUTE PROCEDURE
            ms_syst_data.trig_b_d_syst_hierarchy_items_hierarchy_inactive_check();

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_hierarchy_items
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

DO
$DOCUMENTATION$
DECLARE
    -- Table
    var_comments_config ms_syst_priv.comments_config_table;

    -- Columns
    var_hierarchy_id     ms_syst_priv.comments_config_table_column;
    var_hierarchy_depth  ms_syst_priv.comments_config_table_column;
    var_required         ms_syst_priv.comments_config_table_column;
    var_allow_leaf_nodes ms_syst_priv.comments_config_table_column;

BEGIN

    --
    -- Table Config
    --

    var_comments_config.table_schema := 'ms_syst_data';
    var_comments_config.table_name   := 'syst_hierarchy_items';

    var_comments_config.description :=
$DOC$Hierarchy Item records represent a level in the hierarchy of their parent
Hierarchy.$DOC$;
    var_comments_config.general_usage :=
$DOC$Each Hierarchy Item record is individually sequenced in its group via the
`hierarchy_depth` column.

Note that once the Hierarchy is active and in use by Hierarchy implementing
Components, most changes to the Hierarchy Item records will not be allowed to
ensure the consistency of currently used data.$DOC$;

    --
    -- Column Configs
    --

    var_hierarchy_id.column_name := 'hierarchy_id';
    var_hierarchy_id.description :=
$DOC$Identifies the Hierarchy to which the record belongs.$DOC$;

    var_required.column_name := 'required';
    var_required.description :=
$DOC$Indicates if the Hierarchy Item level must be represented by a record in the
implementing data, or if the Hierarchy Item level represents an optional level.
If true, the Hierarchy Item level must be represented by a record in the data of
the implementing Component for that data to be considered valid.  If false,
the Hierarchy Item level is considered optional and the data of the implementing
Component may omit the Hierarchy Item level in its data without the data being
considered invalid.$DOC$;
    var_required.general_usage :=
$DOC$The highest/root Hierarchy Item level must always be required.  If lower levels
of the Hierarchy are required, all parents to the lowest required Hierarchy Item
level must also be marked as required true.$DOC$;

    var_allow_leaf_nodes.column_name := 'allow_leaf_nodes';
    var_allow_leaf_nodes.description :=
$DOC$Indicates to implementing Components that this Hierarchy Item level can be
associated with "Leaf Nodes". Leaf Nodes are not defined in the
mscmp_syst_hierarchy Component, but are rather defined by Hierarchy implementing
Components.  Leaf Nodes are the records which the Branch Nodes/Hierarchy
definition are organizing.  An example of a Leaf Node would be an application
menu implementing Component defining references/links to specific application
functionality which are then displayed associated to branches of a tree
structure (menu/sub-menu/ etc.)  The links are Leaf Nodes and the branches of
the menu are Branch Nodes: representations of the Hierarchy Items.$DOC$;
    var_allow_leaf_nodes.general_usage :=
$DOC$If this value is true, it means this Hierarchy Item record may be associated
directly with Leaf Nodes.  If false, Leaf Nodes must be associated with other
levels of the Hierarchy.

The bottom/lowest level required Hierarchy Item must always be marked as
`allow_leaf_nodes` true.  Higher than the lowest required Hierarchy Item level
may arbitrarily allow or disallow Leaf Node associations as the implementing
Component sees fit.$DOC$;

    var_hierarchy_depth.column_name := 'hierarchy_depth';
    var_hierarchy_depth.description :=
$DOC$Indicates the at what level in the hierarchy this Group Type Item sits
relative to the other items in the Group Type.  Records with relatively
higher values are deeper or lower in the hierarchy.$DOC$;
    var_hierarchy_depth.general_usage :=
$DOC$When a value for this column is not provided at insert time, the record is
assigned the next hierarchy depth value relative to the existing records.  When
a record is inserted with a set hierarchy_depth value and that value pre-exists
for the same Group Type as the new record, the insert is treated as a "insert
above" operation, with the existing conflicting record being updated to have the
next hierarchy value; existing Group Type Item records are continued to be
updated until the last record is assigned a non-conflicting hierarchy_depth
value.$DOC$;

    var_comments_config.columns :=
        ARRAY [
              var_hierarchy_id
            , var_hierarchy_depth
            , var_required
            , var_allow_leaf_nodes
            ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config );

END;
$DOCUMENTATION$;


COMMENT ON
    CONSTRAINT syst_hierarchy_items_depth_udx
    ON ms_syst_data.syst_hierarchy_items IS
$DOC$No two records in the same Group Type should share the same hierarchy_depth
as their relationship would become ambiguous.  Group Type hierarchies are
only valuable when each individual level is uniquely placed in the hierarchy
relative to other records of the same group.$DOC$;
