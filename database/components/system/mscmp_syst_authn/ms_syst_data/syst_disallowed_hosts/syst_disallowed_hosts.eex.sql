-- File:        syst_disallowed_hosts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst_data/syst_disallowed_hosts/syst_disallowed_hosts.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE ms_syst_data.syst_disallowed_hosts
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
        CONSTRAINT syst_disallowed_hosts_pk PRIMARY KEY
    ,host_address
        inet
        NOT NULL
        CONSTRAINT syst_disallowed_hosts_host_address_udx UNIQUE
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

ALTER TABLE ms_syst_data.syst_disallowed_hosts OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_disallowed_hosts FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_disallowed_hosts TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_disallowed_hosts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

DO
$DOCUMENTATION$
DECLARE
    -- Table
    var_comments_config ms_syst_priv.comments_config_table;

    -- Columns
    var_host_address ms_syst_priv.comments_config_table_column;

BEGIN

    --
    -- Table Config
    --

    var_comments_config.table_schema := 'ms_syst_data';
    var_comments_config.table_name   := 'syst_disallowed_hosts';

    var_comments_config.description :=
$DOC$A simple listing of "banned" IP address which are not allowed to authenticate
their users to the system.  This registry differs from the syst_*_network_rules
tables in that IP addresses here are registered as the result of automatic
system heuristics whereas the network rules are direct expressions of system
administrator intent.  The timing between these two mechanisms is also different
in that records in this table are evaluated prior to an authentication attempt
and most network rules are processed in the authentication attempt sequence.$DOC$;

    --
    -- Column Configs
    --

    var_host_address.column_name := 'host_address';
    var_host_address.description :=
$DOC$The IP address of the host disallowed from attempting to authenticate Access
Accounts.$DOC$;

    var_comments_config.columns :=
        ARRAY [ var_host_address ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config );

END;
$DOCUMENTATION$;
