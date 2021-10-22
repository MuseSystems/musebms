-- Source File: enum_contact_types.sql
-- Location:    msbms/database/msbms_appl_data/tables/enum_contact_types.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from thrid parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE msbms_appl_data.enum_contact_types
(
     id                      uuid        DEFAULT uuid_generate_v1( ) NOT NULL
        CONSTRAINT enum_contact_types_pk PRIMARY KEY
    ,internal_name           text                                    NOT NULL
        CONSTRAINT enum_contact_types_internal_name_udx UNIQUE
    ,display_name            text                                    NOT NULL
        CONSTRAINT enum_contact_types_display_name_udx UNIQUE
    ,description             text                                    NOT NULL
    ,functional_type         text                                    NOT NULL
        CONSTRAINT enum_contact_types_function_type_chk
        CHECK(functional_type IN ('phone', 'physical_address', 'email_address',
                                   'website', 'chat', 'social_media', 'generic'))
    ,options                 jsonb       DEFAULT '{}'::jsonb         NOT NULL
    ,user_options            jsonb       DEFAULT '{}'::jsonb         NOT NULL
    ,diag_timestamp_created  timestamptz DEFAULT now( )              NOT NULL
    ,diag_role_created       text                                    NOT NULL
    ,diag_timestamp_modified timestamptz DEFAULT now( )              NOT NULL
    ,diag_wallclock_modified timestamptz DEFAULT clock_timestamp( )  NOT NULL
    ,diag_role_modified      text                                    NOT NULL
    ,diag_row_version        bigint      DEFAULT 1                   NOT NULL
    ,diag_update_count       bigint      DEFAULT 0                   NOT NULL
);

ALTER TABLE msbms_appl_data.enum_contact_types OWNER TO msbms_owner;

REVOKE ALL ON TABLE msbms_appl_data.enum_contact_types FROM public;
GRANT ALL ON TABLE msbms_appl_data.enum_contact_types TO msbms_owner;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON msbms_appl_data.enum_contact_types
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE msbms_appl_data.enum_contact_types IS
$DOC$Identifies the available types of contact that may be associated with a person,
entity, or place.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.enum_contact_types.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.enum_contact_types.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.enum_contact_types.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
contacts.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.enum_contact_types.description IS
$DOC$A text describing the meaning and use of the specific record that may be
visible to users of the record.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.enum_contact_types.functional_type IS
$DOC$Associates the contact type with known and supported application contact type
functionality.  These types include:
    * phone            - Telephone system dependent communications.  Contacts of
                         this type will include formatting information from the
                         msbms_appl_data.conf_phone_formats table.

    * physical_address - Street and mailing addresses.  Contacts of this type
                         will include formatting information from the
                         msbms_appl_data.conf_address_formats table.

    * email_address    - Email addresses

    * website          - Website addresses

    * chat             - Internet user and system

    * social_media     - Social media accounts and system

    * generic          - A miscellaneous type to record non-functional, but
                         still needed contact information.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.enum_contact_types.options IS
$DOC$A JSON representation of various behavioral options that the application may
make when the enum is assigned to the record it is qualifying.  Options may
include flags, rules to test, and other such arbitrary behaviors as required by
the specific record to which the enum is assigned.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.enum_contact_types.user_options IS
$DOC$Allows for user defined options related to the type similar to the way the
options field is envisioned.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.enum_contact_types.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.enum_contact_types.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.enum_contact_types.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.enum_contact_types.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.enum_contact_types.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.enum_contact_types.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN msbms_appl_data.enum_contact_types.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
