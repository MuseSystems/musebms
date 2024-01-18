-- File:        syst_numberings.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_docnum/ms_syst_data/syst_numberings/syst_numberings.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_numberings
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
        CONSTRAINT syst_numberings_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_numberings_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_numberings_display_name_udx UNIQUE
    ,syst_description
        text
        NOT NULL
    ,user_description
        text
    ,feature_id
        uuid
        NOT NULL
        CONSTRAINT syst_numberings_feature_fk
            REFERENCES ms_syst_data.syst_feature_map (id)
    ,syst_defined
        boolean
        NOT NULL DEFAULT FALSE
    ,user_maintainable
        boolean
        NOT NULL DEFAULT TRUE
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

ALTER TABLE ms_syst_data.syst_numberings OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_numberings FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_numberings TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_numberings
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

DO
$DOCUMENTATION$
DECLARE
    -- Table
    var_comments_config ms_syst_priv.comments_config_table;

    -- Columns
    var_feature_id ms_syst_priv.comments_config_table_column;

BEGIN

    --
    -- Table Config
    --

    var_comments_config.table_schema := 'ms_syst_data';
    var_comments_config.table_name   := 'syst_numberings';

    var_comments_config.description :=
$DOC$Records the available numbering sequences in the system.  These may be system
created or user created.$DOC$;

    --
    -- Column Configs
    --

    var_feature_id.column_name := 'feature_id';
    var_feature_id.description :=
$DOC$A reference to the specific feature of which the numbering is considered to be
part.  This reference is chiefly used to determine where in the configuration
options the numbering should appear.$DOC$;


    var_comments_config.columns :=
        ARRAY [ var_feature_id ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config );

END;
$DOCUMENTATION$;
