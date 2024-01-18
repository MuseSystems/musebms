-- File:        syst_numbering_segment_types.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_docnum/ms_syst_data/syst_numbering_segment_types/syst_numbering_segment_types.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

-- TODO: Is this just an Enumeration?  At some point sit down and figure that
--       out.

CREATE TABLE ms_syst_data.syst_numbering_segment_types
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
        CONSTRAINT syst_numbering_segment_types_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_numbering_segment_types_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_numbering_segment_types_display_name_udx UNIQUE
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

ALTER TABLE ms_syst_data.syst_numbering_segment_types OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_numbering_segment_types FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_numbering_segment_types TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_numbering_segment_types
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

DO
$DOCUMENTATION$
DECLARE
    -- Table
    var_comments_config ms_syst_priv.comments_config_table;

BEGIN

    --
    -- Table Config
    --

    var_comments_config.table_schema := 'ms_syst_data';
    var_comments_config.table_name   := 'syst_numbering_segment_types';

    var_comments_config.description :=
$DOC$Enumerates the available kinds of segments which may be used to construct an
application numbering system.$DOC$;

    var_comments_config.general_usage :=
$DOC$Note that as of this writing, these records are not considered user configurable
beyond setting a custom user_description value.$DOC$;

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config );

END;
$DOCUMENTATION$;
