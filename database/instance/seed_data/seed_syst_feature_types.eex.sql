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
    , ''
    , 'nonbooking'
    , 'document' )
     ,
    ( 'nonbooking_job'
    , 'Non-booking Transaction Jobs'
    , ''
    , 'nonbooking'
    , 'job' )
    ,
    ( 'nonbooking_relation'
    , 'Non-booking Transaction Tables'
    , ''
    , 'nonbooking'
    , 'relation' )
    ,
    ( 'nonbooking_enumeration'
    , 'Non-booking Transaction Lists of Values'
    , ''
    , 'nonbooking'
    , 'enumeration' )
    ,
    ( 'nonbooking_setting'
    , 'Non-booking Transaction Settings'
    , ''
    , 'nonbooking'
    , 'setting' )
    ,
    ( 'booking_document'
    , 'Booking Transaction Forms'
    , ''
    , 'booking'
    , 'document' )
     ,
    ( 'booking_job'
    , 'Booking Transaction Jobs'
    , ''
    , 'booking'
    , 'job' )
    ,
    ( 'booking_relation'
    , 'Booking Transaction Tables'
    , ''
    , 'booking'
    , 'relation' )
    ,
    ( 'booking_enumeration'
    , 'Booking Transaction Lists of Values'
    , ''
    , 'booking'
    , 'enumeration' )
    ,
    ( 'booking_setting'
    , 'Booking Transaction Settings'
    , ''
    , 'booking'
    , 'setting' )
    ,
    ( 'tasking_document'
    , 'Tasking Transaction Forms'
    , ''
    , 'tasking'
    , 'document' )
     ,
    ( 'tasking_job'
    , 'Tasking Transaction Jobs'
    , ''
    , 'tasking'
    , 'job' )
    ,
    ( 'tasking_relation'
    , 'Tasking Transaction Tables'
    , ''
    , 'tasking'
    , 'relation' )
    ,
    ( 'tasking_enumeration'
    , 'Tasking Transaction Lists of Values'
    , ''
    , 'tasking'
    , 'enumeration' )
    ,
    ( 'tasking_setting'
    , 'Tasking Transaction Settings'
    , ''
    , 'tasking'
    , 'setting' );
