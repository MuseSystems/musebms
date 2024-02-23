-- File:        syst_interaction_contexts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_interaction/ms_syst_data/syst_interaction_contexts/syst_interaction_contexts.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE ms_syst_data.syst_interaction_contexts
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
        CONSTRAINT syst_interaction_contexts_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_interaction_contexts_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_interaction_contexts_display_name_udx UNIQUE
    ,interaction_category_id
        uuid
        CONSTRAINT syst_interaction_contexts_interaction_categories_fk
            REFERENCES ms_syst_data.syst_interaction_categories ( id )
    ,perm_id
        uuid
        CONSTRAINT syst_interaction_contexts_perms_fk
            REFERENCES ms_syst_data.syst_perms ( id )
    ,CONSTRAINT syst_interaction_contexts_perm_req_chk
         CHECK ( interaction_category_id IS NOT NULL OR perm_id IS NOT NULL )
    ,syst_defined
        boolean
        NOT NULL DEFAULT false
    ,user_maintainable
        boolean
        NOT NULL DEFAULT true
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

ALTER TABLE ms_syst_data.syst_interaction_contexts OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_interaction_contexts FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_interaction_contexts TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_interaction_contexts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

DO
$DOCUMENTATION$
DECLARE
    -- Table
    var_comments_config ms_syst_priv.comments_config_table;

    -- Columns
    var_interaction_category_id ms_syst_priv.comments_config_table_column;
    var_perm_id                 ms_syst_priv.comments_config_table_column;

BEGIN

    --
    -- Table Config
    --

    var_comments_config.table_schema := 'ms_syst_data';
    var_comments_config.table_name   := 'syst_interaction_contexts';

    var_comments_config.description :=
$DOC$Establishes a defined Interaction Context which can be assigned a context wide
default permission, a default Category, as well as serve as parent to more
granular data field and interaction record/permission assignments.$DOC$;

    var_comments_config.general_usage :=
$DOC$The Interaction Context must be assigned to either an Interaction Category, a
specific Permission, or both.  This assignment establishes the default
permission requirements for all member data fields or interactions not setting
more specific permission requirements individually.

In cases where a specific ("Primary") permission or a categorical permission is
not assigned and the individual child data fields and interactions also do not
define these permissions, that permission check is bypassed.  This is the reason
one or the other is required at this level: so that some permission check is
required, avoiding the possibility that a data field or interaction is
inadvertently left uncontrolled.$DOC$;

    --
    -- Column Configs
    --

    var_interaction_category_id.column_name := 'interaction_category_id';
    var_interaction_category_id.description :=
$DOC$If the Interaction Context as a whole should be subject to the requirements of a
specific Interaction Category, this field specifies the Interaction Category
which applies.$DOC$;
    var_interaction_category_id.constraints :=
$DOC$One of the `interaction_category_id` or `perm_id` columns must be non-null.  It
is acceptable for both values to be populated in which case both values will
apply.$DOC$;
    var_interaction_category_id.general_usage :=
$DOC$The expectation is that Interaction Category assignments at the Interaction
Context level will be rare compared to simple permission assignments via the
`perm_id` column.$DOC$;

    var_perm_id.column_name := 'perm_id';
    var_perm_id.description :=
$DOC$Assigns a Permission to the Interaction Context which acts as the default
primary permission for all data fields and actions associated with the
Interaction Context.$DOC$;
    var_perm_id.constraints :=
$DOC$One of the `interaction_category_id` or `perm_id` columns must be non-null.  It
is acceptable for both values to be populated in which case both values will
apply.$DOC$;

    var_comments_config.columns :=
        ARRAY [
            var_interaction_category_id
            , var_perm_id
            ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config );

END;
$DOCUMENTATION$;
