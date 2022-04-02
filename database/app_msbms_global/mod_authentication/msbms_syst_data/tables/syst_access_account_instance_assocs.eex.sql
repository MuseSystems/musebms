-- File:        syst_access_account_instance_assocs.eex.sql
-- Location:    database\app_msbms_global\mod_authentication\msbms_syst_data\tables\syst_access_account_instance_assocs.eex.sql
-- Project:     Muse Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE msbms_syst_data.syst_access_account_instance_assocs
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_access_account_instance_assocs_pk PRIMARY KEY
    ,access_account_id
        uuid
        NOT NULL
        CONSTRAINT syst_access_account_instance_assocs_access_accounts_fk
            REFERENCES msbms_syst_data.syst_access_accounts (id) ON DELETE CASCADE
    ,credential_type_id
        uuid
        NOT NULL
        CONSTRAINT syst_access_account_instance_assocs_credential_types_fk
            REFERENCES msbms_syst_data.syst_enum_values (id) ON DELETE CASCADE
    ,instance_id
        uuid
        NOT NULL
        CONSTRAINT syst_access_account_instance_assocs_instances_fk
            REFERENCES msbms_syst_data.syst_instances (id) ON DELETE CASCADE
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

ALTER TABLE msbms_syst_data.syst_access_account_instance_assocs OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_syst_data.syst_access_account_instance_assocs FROM public;
GRANT ALL ON TABLE msbms_syst_data.syst_access_account_instance_assocs TO <%= msbms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON msbms_syst_data.syst_access_account_instance_assocs
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_credential_types_enum_value_check
    AFTER INSERT ON msbms_syst_data.syst_access_account_instance_assocs
    FOR EACH ROW EXECUTE PROCEDURE
        msbms_syst_priv.trig_a_iu_enum_value_check('credential_types', 'credential_type_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_credential_types_enum_value_check
    AFTER UPDATE ON msbms_syst_data.syst_access_account_instance_assocs
    FOR EACH ROW WHEN ( old.credential_type_id != new.credential_type_id)EXECUTE PROCEDURE
        msbms_syst_priv.trig_a_iu_enum_value_check('credential_types', 'credential_type_id');

COMMENT ON
    TABLE msbms_syst_data.syst_access_account_instance_assocs IS
$DOC$Associates access accounts with the instances for which they are allowed to
authenticate to.  Note that being able to authenticate to an instance is not the
same as having authorized rights within the instance; authorization is handled
by the instance directly.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_access_account_instance_assocs.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_access_account_instance_assocs.access_account_id IS
$DOC$The access account which is being granted authentication rights to the given
instance.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_access_account_instance_assocs.credential_type_id IS
$DOC$Allows a specific kind of credential to be used to authenticate the access
account to the instance.  Typically this is to control the ability to connect as
a user or using API tokens.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_access_account_instance_assocs.instance_id IS
$DOC$The identity of the instance to which authentication rights is being granted.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_access_account_instance_assocs.access_granted IS
$DOC$The timestamp at which access to the instance was granted and active.  If
the access did not require the access invitation process, this value will
typically reflect the creation timestamp of the record.  If the invitation was
required, it will reflect the time when the access account holder actually
accepted the invitation to access the instance.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_access_account_instance_assocs.invitation_issued IS
$DOC$When inviting unowned, independent access accounts such as might be used by an
external bookkeeper, the grant of access by the instance owner is
not immediately effective but must also be approved by the access account holder
being granted access.  The timestamp in this column indicates when the
invitation to connect to the instance was issued.

If the value in this column is null, the assumption is that no invitation was
required to grant the access to the access account.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_access_account_instance_assocs.invitation_expires IS
$DOC$The timestamp at which the invitation to access a given instance expires.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_access_account_instance_assocs.invitation_declined IS
$DOC$The timestamp at which the access account holder explicitly declined the
invitation to access the given instance.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_access_account_instance_assocs.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_access_account_instance_assocs.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_access_account_instance_assocs.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_access_account_instance_assocs.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_access_account_instance_assocs.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_access_account_instance_assocs.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_access_account_instance_assocs.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
