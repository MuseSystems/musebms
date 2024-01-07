-- File:        syst_applications.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst_data/syst_applications/syst_applications.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_applications
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
        CONSTRAINT syst_applications_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_applications_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_applications_display_name_udx UNIQUE
    ,syst_description
        text
        NOT NULL
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

ALTER TABLE ms_syst_data.syst_applications OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_applications FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_applications TO <%= ms_owner %>;

CREATE TRIGGER b50_trig_b_d_syst_applications_delete_contexts
    BEFORE DELETE ON ms_syst_data.syst_applications
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_data.trig_b_d_syst_applications_delete_contexts();

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_applications
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

DO
$DOCUMENTATION$
DECLARE
    -- Table
    var_comments_config ms_syst_priv.comments_config_table;

BEGIN

    var_comments_config.table_schema := 'ms_syst_data';
    var_comments_config.table_name   := 'syst_applications';

    var_comments_config.description :=
$DOC$Describes the known applications which is managed by the global database and
authentication infrastructure.$DOC$;

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config );

END;
$DOCUMENTATION$;
