-- File:        seed_syst_feature_types.eex.sql
-- Location:    database\instance\seed_data\seed_syst_feature_types.eex.sql
-- Project:     Muse Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

INSERT INTO msbms_syst_data.syst_feature_types
    ( internal_name, display_name, syst_description, feature_group, functional_type )
VALUES
    ( 'nonbooking_document'
    , 'Non-booking Transaction Forms'
    , 'User interface forms target at maintaining non-booking transaction data.'
    , 'nonbooking'
    , 'document' )
     ,
    ( 'nonbooking_job'
    , 'Non-booking Transaction Jobs'
    , 'Scheduled jobs & batch processing related to non-booking transaction data.'
    , 'nonbooking'
    , 'job' )
    ,
    ( 'nonbooking_relation'
    , 'Non-booking Transaction Tables'
    , 'Tables related to non-booking transaction data retention.'
    , 'nonbooking'
    , 'relation' )
    ,
    ( 'nonbooking_enumeration'
    , 'Non-booking Transaction Lists of Values'
    , 'Lists of values used in non-booking transaction data forms and referenced by non-' ||
      'booking transaction data records.'
    , 'nonbooking'
    , 'enumeration' )
    ,
    ( 'nonbooking_setting'
    , 'Non-booking Transaction Settings'
    , 'Configuration settings which influence the behavior of non-booking transaction data ' ||
      'maintenance and interpretation.'
    , 'nonbooking'
    , 'setting' )
    ,
    ( 'booking_document'
    , 'Booking Transaction Forms'
    , 'User interface forms target at maintaining booking transaction data.'
    , 'booking'
    , 'document' )
     ,
    ( 'booking_job'
    , 'Booking Transaction Jobs'
    , 'Scheduled jobs & batch processing related to booking transaction data.'
    , 'booking'
    , 'job' )
    ,
    ( 'booking_relation'
    , 'Booking Transaction Tables'
    , 'Tables related to booking transaction data retention.'
    , 'booking'
    , 'relation' )
    ,
    ( 'booking_enumeration'
    , 'Booking Transaction Lists of Values'
    , 'Lists of values used in booking transaction data forms and referenced by booking ' ||
      'transaction data records.'
    , 'booking'
    , 'enumeration' )
    ,
    ( 'booking_setting'
    , 'Booking Transaction Settings'
    , 'Configuration settings which influence the behavior of booking transaction data ' ||
      'maintenance and interpretation.'
    , 'booking'
    , 'setting' )
    ,
    ( 'tasking_document'
    , 'Tasking Transaction Forms'
    , 'User interface forms target at maintaining tasking transaction data.'
    , 'tasking'
    , 'document' )
     ,
    ( 'tasking_job'
    , 'Tasking Transaction Jobs'
    , 'Scheduled jobs & batch processing related to tasking transaction data.'
    , 'tasking'
    , 'job' )
    ,
    ( 'tasking_relation'
    , 'Tasking Transaction Tables'
    , 'Tables related to tasking transaction data retention.'
    , 'tasking'
    , 'relation' )
    ,
    ( 'tasking_enumeration'
    , 'Tasking Transaction Lists of Values'
    , 'Lists of values used in tasking transaction data forms and referenced by tasking ' ||
      'transaction data records.'
    , 'tasking'
    , 'enumeration' )
    ,
    ( 'tasking_setting'
    , 'Tasking Transaction Settings'
    , 'Configuration settings which influence the behavior of tasking transaction data ' ||
      'maintenance and interpretation.'
    , 'tasking'
    , 'setting' );
