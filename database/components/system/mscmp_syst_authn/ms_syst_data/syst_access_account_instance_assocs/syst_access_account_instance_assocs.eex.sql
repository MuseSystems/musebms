-- File:        syst_access_account_instance_assocs.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst_data/syst_access_account_instance_assocs/syst_access_account_instance_assocs.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_access_account_instance_assocs
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v7( )
        CONSTRAINT syst_access_account_instance_assocs_pk PRIMARY KEY
    ,access_account_id
        uuid
        NOT NULL
        CONSTRAINT syst_access_account_instance_assocs_access_accounts_fk
            REFERENCES ms_syst_data.syst_access_accounts (id) ON DELETE CASCADE
    ,instance_id
        uuid
        NOT NULL
        CONSTRAINT syst_access_account_instance_assocs_instances_fk
            REFERENCES ms_syst_data.syst_instances (id) ON DELETE CASCADE
    ,CONSTRAINT syst_access_account_instance_assoc_a_i_udx
        UNIQUE ( access_account_id, instance_id )
    ,access_granted
        timestamptz
    ,invitation_issued
        timestamptz
    ,invitation_expires
        timestamptz
    ,invitation_declined
        timestamptz
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

ALTER TABLE ms_syst_data.syst_access_account_instance_assocs OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_access_account_instance_assocs FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_access_account_instance_assocs TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_access_account_instance_assocs
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

DO
$DOCUMENTATION$
DECLARE
    -- Table
    var_comments_config ms_syst_priv.comments_config_table;

    -- Columns
    var_access_account_id   ms_syst_priv.comments_config_table_column;
    var_instance_id         ms_syst_priv.comments_config_table_column;
    var_access_granted      ms_syst_priv.comments_config_table_column;
    var_invitation_issued   ms_syst_priv.comments_config_table_column;
    var_invitation_expires  ms_syst_priv.comments_config_table_column;
    var_invitation_declined ms_syst_priv.comments_config_table_column;

BEGIN

    --
    -- Table Config
    --

    var_comments_config.table_schema := 'ms_syst_data';
    var_comments_config.table_name   := 'syst_access_account_instance_assocs';

    var_comments_config.description :=
$DOC$Associates access accounts with the instances for which they are allowed to
authenticate to.  Note that being able to authenticate to an instance is not the
same as having authorized rights within the instance; authorization is handled
by the instance directly.$DOC$;

    --
    -- Column Configs
    --

    var_access_account_id.column_name := 'access_account_id';
    var_access_account_id.description :=
$DOC$The access account which is being granted authentication rights to the given
instance.$DOC$;

    var_instance_id.column_name := 'instance_id';
    var_instance_id.description :=
$DOC$The identity of the instance to which authentication rights is being granted.$DOC$;

    var_access_granted.column_name := 'access_granted';
    var_access_granted.description :=
$DOC$The timestamp at which access to the instance was granted and active.$DOC$;
    var_access_granted.general_usage :=
$DOC$If the access did not require the access invitation process, this value will
typically reflect the creation timestamp of the record.  If the invitation was
required, it will reflect the time when the access account holder actually
accepted the invitation to access the instance.$DOC$;


    var_invitation_issued.column_name := 'invitation_issued';
    var_invitation_issued.description :=
$DOC$When inviting unowned, independent access accounts such as might be used by an
external bookkeeper, the grant of access by the instance owner is
not immediately effective but must also be approved by the access account holder
being granted access.  $DOC$;
    var_invitation_issued.general_usage :=
$DOC$The timestamp in this column indicates when the invitation to connect to the
instance was issued. If the value in this column is null, the assumption is that
no invitation was required to grant the access to the access account.$DOC$;

    var_invitation_expires.column_name := 'invitation_expires';
    var_invitation_expires.description :=
$DOC$The timestamp at which the invitation to access a given instance expires.$DOC$;

    var_invitation_declined.column_name := 'invitation_declined';
    var_invitation_declined.description :=
$DOC$The timestamp at which the access account holder explicitly declined the
invitation to access the given instance.$DOC$;

    var_comments_config.columns :=
        ARRAY [
              var_access_account_id
            , var_instance_id
            , var_access_granted
            , var_invitation_issued
            , var_invitation_expires
            , var_invitation_declined
            ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config );

END;
$DOCUMENTATION$;
