-- File:        mstr_entity_bank_entities.eex.sql
-- Location:    musebms/database/components/application/mscmp_brm_entity_bank/ms_appl_data/mstr_entity_bank_entities/mstr_entity_bank_entities.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems
CREATE TABLE ms_appl_data.mstr_entity_bank_entities
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
        CONSTRAINT mstr_entity_bank_entities_pk PRIMARY KEY
    ,entity_id
        uuid
        NOT NULL
        CONSTRAINT mstr_entity_bank_entities_entity_fk
            REFERENCES ms_appl_data.mstr_entities (id) ON DELETE CASCADE
    ,owning_entity_id
        uuid
        NOT NULL
        CONSTRAINT mstr_entity_bank_entities_owning_entity_fk
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
    ,CONSTRAINT mstr_entity_bank_entities_udx
        UNIQUE (entity_id, owning_entity_id)
);

ALTER TABLE ms_appl_data.mstr_entity_bank_entities OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_appl_data.mstr_entity_bank_entities FROM public;
GRANT ALL ON TABLE ms_appl_data.mstr_entity_bank_entities TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_appl_data.mstr_entity_bank_entities
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
    var_comments_config.table_name   := 'mstr_entity_bank_entities';

    var_comments_config.description :=
$DOC$Establishes an financial service provider relationship between an Owning entity
and an Entity which provides financial and banking services.$DOC$;

    var_comments_config.general_usage :=
$DOC$Banks can process certain financial related transactions and be associated with
specific asset and liability accounts is relation to the owning Entity.$DOC$;

    --
    -- Column Configs
    --

    var_entity_id.column_name := 'entity_id';
    var_entity_id.description :=
$DOC$Identifies an Entity which acts as a bank or financial institution in the
relationship.$DOC$;

    var_owning_entity_id.column_name := 'owning_entity_id';
    var_owning_entity_id.description :=
$DOC$Identifies the Entity on whose behalf the banking relationship exists.$DOC$;

    var_comments_config.columns :=
        ARRAY [
              var_entity_id
            , var_owning_entity_id
            ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config );

END;
$DOCUMENTATION$;
