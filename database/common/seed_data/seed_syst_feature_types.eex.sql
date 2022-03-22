-- File:        seed_syst_feature_types.eex.sql
-- Location:    database\common\seed_data\seed_syst_feature_types.eex.sql
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
    ( 'master_data_forms'
    , 'Master Data Forms'
    , 'Forms used for maintaining master records.'
    , 'document'
    , 'master' )
     ,
    ( 'master_data_tables'
    , 'Master Data Tables'
    , 'Database tables containing master data records.'
    , 'relation'
    , 'master' )
     ,
    ( 'master_data_operations'
    , 'Master Data Processes'
    , 'Batch and background processes acting on master data.'
    , 'relation'
    , 'master' )
     ,
    ( 'support_data_forms'
    , 'Supporting Data Forms'
    , 'Forms used for maintaining supporting records.'
    , 'document'
    , 'master' )
     ,
    ( 'support_data_tables'
    , 'Supporting Data Tables'
    , 'Database tables containing supporting data records.'
    , 'relation'
    , 'master' )
     ,
    ( 'support_data_operations'
    , 'Supporting Data Processes'
    , 'Batch and background processes acting on supporting data.'
    , 'relation'
    , 'master' )
    ,
    ( 'maintenance_data_forms'
    , 'System Data Forms'
    , 'Forms used for maintaining primary system management records.'
    , 'document'
    , 'master' )
     ,
    ( 'maintenance_data_tables'
    , 'System Data Tables'
    , 'Database tables containing system management supporting data records.'
    , 'relation'
    , 'master' )
     ,
    ( 'maintenance_data_operations'
    , 'System Data Processes'
    , 'Batch and background processes acting on systems management data.'
    , 'relation'
    , 'master' );
