-- File:        mstr_entity_selling_entities.eex.sql
-- Location:    musebms/database/components/application/mscmp_brm_entity_selling/ms_appl_data/mstr_entity_selling_entities/mstr_entity_selling_entities.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE ms_appl_data.mstr_entity_selling_entities
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
        CONSTRAINT mstr_entity_selling_entities_pk PRIMARY KEY
    ,entity_id
        uuid
        NOT NULL
        CONSTRAINT mstr_entity_selling_entities_entity_fk
            REFERENCES ms_appl_data.mstr_entities (id) ON DELETE CASCADE
    ,owning_entity_id
        uuid
        NOT NULL
        CONSTRAINT mstr_entity_selling_entities_owning_entity_fk
            REFERENCES ms_appl_data.mstr_entities (id) ON DELETE CASCADE
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
    ,CONSTRAINT mstr_entity_selling_entities_udx
        UNIQUE (entity_id, owning_entity_id)
);

ALTER TABLE ms_appl_data.mstr_entity_selling_entities OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_appl_data.mstr_entity_selling_entities FROM public;
GRANT ALL ON TABLE ms_appl_data.mstr_entity_selling_entities TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_appl_data.mstr_entity_selling_entities
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

DO
$DOCUMENTATION$
DECLARE
    -- Table
    var_comments_config ms_syst_priv.comments_config_table;

    -- Columns
    var_entity_id        ms_syst_priv.comments_config_table_column;
    var_owning_entity_id ms_syst_priv.comments_config_table_column;

BEGIN

    --
    -- Table Config
    --

    var_comments_config.table_schema := 'ms_appl_data';
    var_comments_config.table_name   := 'mstr_entity_selling_entities';

    var_comments_config.description :=
$DOC$Establishes a customer relationship between an Owning Entity and a customer
Entity.$DOC$;

    var_comments_config.general_usage :=
$DOC$This record, or its children, will define sales behavior when the
transaction Entity is the Owning Entity.$DOC$;

    --
    -- Column Configs
    --

    var_entity_id.column_name := 'entity_id';
    var_entity_id.description :=
$DOC$Identifies the Entity which will act as the Customer in the selling
relationship.$DOC$;

    var_owning_entity_id.column_name := 'owning_entity_id';
    var_owning_entity_id.description :=
$DOC$Identifies the Owning Entity which has a selling relationship with the
Customer Entity.$DOC$;


    var_comments_config.columns :=
        ARRAY [
              var_entity_id
            , var_owning_entity_id
            ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config );

END;
$DOCUMENTATION$;
