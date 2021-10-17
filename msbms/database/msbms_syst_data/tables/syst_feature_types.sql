-- Source File: syst_feature_types.sql
-- Location:    msbms/database/msbms_syst_data/tables/syst_feature_types.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from thrid parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE msbms_syst_data.syst_feature_types
(
     id                      uuid        DEFAULT uuid_generate_v1( ) NOT NULL
        CONSTRAINT syst_feature_types_pk PRIMARY KEY
    ,internal_name           text                                    NOT NULL
        CONSTRAINT syst_feature_types_internal_name_udx UNIQUE
    ,display_name            text                                    NOT NULL
        CONSTRAINT syst_feature_types_display_name_udx UNIQUE
    ,description             text                                    NOT NULL
    ,feature_group           text                                    NOT NULL
    ,functional_type         text                                    NOT NULL
    ,diag_timestamp_created  timestamptz DEFAULT now( )              NOT NULL
    ,diag_role_created       text                                    NOT NULL
    ,diag_timestamp_modified timestamptz DEFAULT now( )              NOT NULL
    ,diag_wallclock_modified timestamptz DEFAULT clock_timestamp( )  NOT NULL
    ,diag_role_modified      text                                    NOT NULL
    ,diag_row_version        bigint      DEFAULT 1                   NOT NULL
    ,diag_update_count       bigint      DEFAULT 0                   NOT NULL
    ,CONSTRAINT functional_type_chk
        CHECK (functional_type IN ( 'master', 'support', 'nonbooking', 'booking', 'maintenance' ))
    ,CONSTRAINT feature_group_chk
        CHECK (feature_group IN ('document', 'operation', 'relation'))
);

ALTER TABLE msbms_syst_data.syst_feature_types OWNER TO msbms_owner;

REVOKE ALL ON TABLE msbms_syst_data.syst_feature_types FROM public;
GRANT ALL ON TABLE msbms_syst_data.syst_feature_types TO msbms_owner;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON msbms_syst_data.syst_feature_types
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE msbms_syst_data.syst_feature_types IS
$DOC$A list of the various types of forms, processes, and data managed by the ERP
system.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_types.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_types.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_types.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
app_functionals.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_types.description IS
$DOC$A text describing the meaning and use of the specific record that may be
visible to users of the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_types.feature_group IS
$DOC$Identifies the nature of the feature.  For example, a data records stored in the
database are considered part of the 'relation' feature groups.  This field is
used primarily for grouping like features together.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_types.functional_type IS
$DOC$Establishes the meaning of the record in relation to functionality implemented
in the system.  The system will base processing decisions upon the value in this
field.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_types.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_types.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_types.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_types.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_types.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_types.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_feature_types.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;

COMMENT ON
    CONSTRAINT functional_type_chk
    ON msbms_syst_data.syst_feature_types IS
$DOC$Defines the system recognized types which can alter processing.

      * master:       Identifies definitional data records which always represent the current state
                      of those attributes the record defines.  The 'persons' table is a master data
                      table defining what we know about a given person.

      * support:      Is definitional in the same sense as master data, but usually must be
                      understood in the context of a more fundamental master data entity to have
                      meaning.  Consider currency management.  The list of currencies would be
                      master data proper, but exchange rates between currencies would represent
                      support data; it is definitional, but cannot be understood absent the
                      identification of the more fundamental currencies that are party to the
                      exchange rate.  Additionally, supporting data may include data lists such
                      as categorizations, such as product classifications.  In this case they
                      have no meaning of their own but give additional meaning to the master
                      data which they support.  Finally, supporting data may also support
                      transactional booking and non-booking transactions as well, though the
                      supporting data doesn't lose its master data-like property or
                      timelessness.

      * nonbooking:   Transaction data, which defines an action at a specific point in time, but
                      does not have direct/immediate accounting consequences.  For example sales
                      orders and purchase orders represent a specific action over a defined
                      course of time, but they are merely the trigger events for later
                      transactions which would prompt a booking.

      * booking:      Transaction data, which defines an action at a specific point in time, but
                      which does have a direct accounting consequence which must be recorded as
                      appropriate to the transaction and its life-cycle.  Payment processing,
                      sales order deliveries, purchase receipts are all examples of booking
                      transactions.

      * matinenance:  This type isn't related to a specific data or record type as is the other
                      types, but instead refers to auxiliary actions which may be performed such as
                      logging into the system or running a batch or maintenance job.$DOC$;

COMMENT ON
    CONSTRAINT feature_group_chk
    ON msbms_syst_data.syst_feature_types IS
$DOC$Defines the currently recognized feature groups in the system:

    * document:  These are typically the forms with which the user interacts while using the
                 application.

    * relation:  As the name suggests these are database tables holding the application's data.

    * operation: These are systematic processes such as batch jobs and similar which aren't directly
                 interacted with, but still process data.$DOC$;
