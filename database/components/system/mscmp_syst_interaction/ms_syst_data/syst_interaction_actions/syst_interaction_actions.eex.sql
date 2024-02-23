-- File:        syst_interaction_actions.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_interaction/ms_syst_data/syst_interaction_actions/syst_interaction_actions.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE ms_syst_data.syst_interaction_actions
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
        CONSTRAINT syst_interaction_actions_pk PRIMARY KEY
    ,interaction_context_id
        uuid
        NOT NULL
        CONSTRAINT syst_interaction_actions_interaction_contexts_fk
            REFERENCES ms_syst_data.syst_interaction_contexts ( id )
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_interaction_actions_internal_name_udx UNIQUE
    ,perm_id
        uuid
        CONSTRAINT syst_interaction_actions_perms_fk
            REFERENCES ms_syst_data.syst_perms ( id )
    ,interaction_category_id
        uuid
        CONSTRAINT syst_interaction_actions_interaction_categories_fk
            REFERENCES ms_syst_data.syst_interaction_categories ( id )
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

ALTER TABLE ms_syst_data.syst_interaction_actions OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_interaction_actions FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_interaction_actions TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_interaction_actions
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

DO
$DOCUMENTATION$
DECLARE
    -- Table
    var_comments_config ms_syst_priv.comments_config_table;

    -- Columns
    var_interaction_context_id  ms_syst_priv.comments_config_table_column;
    var_perm_id                 ms_syst_priv.comments_config_table_column;
    var_interaction_category_id ms_syst_priv.comments_config_table_column;

BEGIN

    --
    -- Table Config
    --

    var_comments_config.table_schema := 'ms_syst_data';
    var_comments_config.table_name   := 'syst_interaction_actions';

    var_comments_config.description :=
$DOC$Allows for the assignment of overriding primary and categorical permissions as
compared to the parent Interaction Context values.$DOC$;

    var_comments_config.general_usage :=
$DOC$Whether or not records in this table are considered 'System Defined' is
determined by the `ms_syst_data.syst_interaction_contexts.syst_defined` value of
the parent Interaction Context record.$DOC$;

    --
    -- Column Configs
    --

    var_interaction_context_id.column_name := 'interaction_context_id';
    var_interaction_context_id.description :=
$DOC$The parent Interaction Context to which this actions permission specification
belongs.$DOC$;

    var_perm_id.column_name := 'perm_id';
    var_perm_id.description :=
$DOC$Assigns a specific permission for the action which overrides the default primary
permission otherwise inherited from the Interaction Context.$DOC$;
    var_perm_id.general_usage :=
$DOC$Leave this value `NULL` for the primary permission of the Interaction
Context to apply, if one is defined.$DOC$;

    var_interaction_category_id.column_name := 'interaction_category_id';
    var_interaction_category_id.description :=
$DOC$Assigns a specific permission for the action which overrides the default
categorical permission otherwise inherited from the Interaction Context.$DOC$;
    var_interaction_category_id.general_usage :=
$DOC$Leave this value `NULL` for the categorical permission of the Interaction
Context to apply, if one is defined.$DOC$;

    var_comments_config.columns :=
        ARRAY [
            var_interaction_context_id
            ,var_perm_id
            ,var_interaction_category_id
            ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config );

END;
$DOCUMENTATION$;
