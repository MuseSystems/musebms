-- Source File: mstr_person_contact_roles.eex.sql
-- Location:    database/instance/msbms_appl_data/tables/mstr_person_contact_roles.eex.sql
-- Project:     musebms
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE msbms_appl_data.mstr_person_contact_roles
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT mstr_person_contact_roles_pk PRIMARY KEY
    ,person_id
        uuid
        NOT NULL
        CONSTRAINT mstr_person_contact_roles_person_fk
            REFERENCES msbms_appl_data.mstr_persons (id) ON DELETE CASCADE
    ,person_contact_role_id
        uuid
        NOT NULL
        CONSTRAINT mstr_person_contact_roles_enum_person_contact_role_fk
            REFERENCES msbms_syst_data.syst_enum_values (id)
    ,place_id
        uuid
        CONSTRAINT mstr_person_contact_roles_place_fk
            REFERENCES msbms_appl_data.mstr_places (id)
    ,contact_id
        uuid
        NOT NULL
        CONSTRAINT mstr_person_contact_roles_contact_fk
            REFERENCES msbms_appl_data.mstr_contacts (id) ON DELETE CASCADE
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

ALTER TABLE msbms_appl_data.mstr_person_contact_roles OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_appl_data.mstr_person_contact_roles FROM public;
GRANT ALL ON TABLE msbms_appl_data.mstr_person_contact_roles TO <%= msbms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON msbms_appl_data.mstr_person_contact_roles
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_person_contact_roles_enum_value_check
    AFTER INSERT ON msbms_appl_data.mstr_person_contact_roles
    FOR EACH ROW EXECUTE PROCEDURE
        msbms_syst_priv.trig_a_iu_enum_value_check('person_contact_roles', 'person_contact_role_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_person_contact_roles_enum_value_check
    AFTER UPDATE ON msbms_appl_data.mstr_person_contact_roles
    FOR EACH ROW WHEN ( old.person_contact_role_id != new.person_contact_role_id)
        EXECUTE PROCEDURE
            msbms_syst_priv.trig_a_iu_enum_value_check(
                'person_contact_roles', 'person_contact_role_id');

COMMENT ON
    TABLE msbms_appl_data.mstr_person_contact_roles IS
$DOC$Associates individual persons with their contact data and includes an indication $DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_person_contact_roles.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_person_contact_roles.person_id IS
$DOC$Identifies the person which has the relationship to the contact information.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_person_contact_roles.person_contact_role_id IS
$DOC$Indicates a specific use or purpose for the identified contact information.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_person_contact_roles.place_id IS
$DOC$This is an optional value indicating whether the given contact information is
associated with a place.  If so, the place will appear here.  This value will be
null if not.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_person_contact_roles.contact_id IS
$DOC$A reference to the contact information which serves the given role for the given
person.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_person_contact_roles.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_person_contact_roles.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_person_contact_roles.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_person_contact_roles.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_person_contact_roles.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_person_contact_roles.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.mstr_person_contact_roles.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
