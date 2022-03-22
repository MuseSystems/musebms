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
    ( 'master_document'
    , 'Master Data Forms'
    , 'User interface forms targeted at maintaining master data.'
    , 'master'
    , 'document' )
     ,
    ( 'master_job'
    , 'Master Data Jobs'
    , 'Scheduled jobs & batch processing related to master data.'
    , 'master'
    , 'job' )
    ,
    ( 'master_relation'
    , 'Master Data Tables'
    , 'Tables related to master data retention.'
    , 'master'
    , 'relation' )
    ,
    ( 'master_enumeration'
    , 'Master Data Lists of Values'
    , 'Lists of values used in master data forms and referenced by master data records.'
    , 'master'
    , 'enumeration' )
    ,
    ( 'master_setting'
    , 'Master Data Settings'
    , 'Configuration settings which influence the behavior of master data maintenance and ' ||
      'interpretation.'
    , 'master'
    , 'setting' )
    ,
    ( 'support_document'
    , 'Supporting Data Forms'
    , 'User interface forms targeted at maintaining supporting data.'
    , 'support'
    , 'document' )
     ,
    ( 'support_job'
    , 'Supporting Data Jobs'
    , 'Scheduled jobs & batch processing related to supporting data.'
    , 'support'
    , 'job' )
    ,
    ( 'support_relation'
    , 'Supporting Data Tables'
    , 'Tables related to supporting data retention.'
    , 'support'
    , 'relation' )
    ,
    ( 'support_enumeration'
    , 'Supporting Data Lists of Values'
    , 'Lists of values used in supporting data forms and referenced by supporting data records.'
    , 'support'
    , 'enumeration' )
    ,
    ( 'support_setting'
    , 'Supporting Data Settings'
    , 'Configuration settings which influence the behavior of supporting data maintenance and ' ||
      'interpretation.'
    , 'support'
    , 'setting' )
    ,
    ( 'maintenance_document'
    , 'System Admin Forms'
    , 'User interface forms targeted at maintaining systems administration data.'
    , 'maintenance'
    , 'document' )
     ,
    ( 'maintenance_job'
    , 'System Admin Jobs'
    , 'Scheduled jobs & batch processing related to systems administration data.'
    , 'maintenance'
    , 'job' )
    ,
    ( 'maintenance_relation'
    , 'System Admin Tables'
    , 'Tables related to systems administration data retention.'
    , 'maintenance'
    , 'relation' )
    ,
    ( 'maintenance_enumeration'
    , 'System Admin Lists of Values'
    , 'Lists of values used in systems administration data forms and referenced by systems ' ||
      'administration data records.'
    , 'maintenance'
    , 'enumeration' )
    ,
    ( 'maintenance_setting'
    , 'System Admin Settings'
    , 'Configuration settings which influence the behavior of systems administration data ' ||
      'maintenance and interpretation.'
    , 'maintenance'
    , 'setting' );
