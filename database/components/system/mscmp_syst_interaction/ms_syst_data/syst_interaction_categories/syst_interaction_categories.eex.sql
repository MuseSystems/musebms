-- File:        syst_interaction_categories.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_interaction/ms_syst_data/syst_interaction_categories/syst_interaction_categories.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE ms_syst_data.syst_interaction_categories
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
        CONSTRAINT syst_interaction_categories_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_interaction_categories_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_interaction_categories_display_name_udx UNIQUE
    ,perm_id
        uuid
        NOT NULL
        CONSTRAINT syst_interaction_categories_perms_fk
            REFERENCES ms_syst_data.syst_perms ( id )
    ,syst_defined
        boolean
        NOT NULL DEFAULT FALSE
    ,syst_description
        text
        NOT NULL
    ,user_maintainable
        boolean
        NOT NULL DEFAULT true
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

ALTER TABLE ms_syst_data.syst_interaction_categories OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_interaction_categories FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_interaction_categories TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_interaction_categories
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

DO
$DOCUMENTATION$
DECLARE
    -- Table
    var_comments_config ms_syst_priv.comments_config_table;

    -- Columns
    var_perm_id ms_syst_priv.comments_config_table_column;
BEGIN

    --
    -- Table Config
    --

    var_comments_config.table_schema := 'ms_syst_data';
    var_comments_config.table_name   := 'syst_interaction_categories';

    var_comments_config.description :=
$DOC$Defines broad categories of both data fields and interactions which can cut
across Interaction Contexts, but share a common permissioning need.

Consider unit costing information.  Unit costs can appear in contexts such as
item forms, inventory position and valuation reports, sales orders, and more.
However, a user accessing any of these functions should be restricted in seeing
unit costing data by the grant (or not) of a sinlge permission.  We have a
category of data points, all reflecting unit cost, which should be governable by
a single permission for the category.$DOC$;

    var_comments_config.general_usage :=
$DOC$Categorical permission checks are in addition to the existing Interaction
Context or specific primary permission checks assigned to the data field or
interaction.  In cases where the primary permission or the categorical
permission are in conflict regarding if a user has access to a field/function,
the most restrictive permission governs ("deny" wins over "grant").$DOC$;

    --
    -- Column Configs
    --

    var_perm_id.column_name := 'perm_id';
    var_perm_id.description :=
$DOC$An assigned permission which will be evaluated whenever a category member is
accessed.$DOC$;

    var_comments_config.columns :=
        ARRAY [ var_perm_id ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config );

END;
$DOCUMENTATION$;
