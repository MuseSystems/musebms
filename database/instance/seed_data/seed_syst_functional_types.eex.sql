-- File:        seed_syst_functional_types.eex.sql
-- Location:    database\instance\seed_data\seed_syst_functional_types.eex.sql
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
    ( 'nonbooking_data_forms'
    , 'Non-booking Transaction Forms'
    , 'Forms used for processing non-booking transaction records.'
    , 'document'
    , 'master' )
     ,
    ( 'nonbooking_data_tables'
    , 'Non-booking Data Tables'
    , 'Database tables containing non-booking transaction data records.'
    , 'relation'
    , 'master' )
     ,
    ( 'nonbooking_data_operations'
    , 'Non-booking Transaction Processes'
    , 'Batch and background processes acting on non-booking transaction data.'
    , 'relation'
    , 'master' )
     ,
    ( 'booking_data_forms'
    , 'Booking Transaction Forms'
    , 'Forms used for processing booking transaction records.'
    , 'document'
    , 'master' )
     ,
    ( 'booking_data_tables'
    , 'Booking Data Tables'
    , 'Database tables containing booking transaction data records.'
    , 'relation'
    , 'master' )
     ,
    ( 'booking_data_operations'
    , 'Booking Transaction Processes'
    , 'Batch and background processes acting on booking transaction data.'
    , 'relation'
    , 'master' );
