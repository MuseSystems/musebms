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
    , ''
    , 'master'
    , 'document' )
     ,
    ( 'master_job'
    , 'Master Data Jobs'
    , ''
    , 'master'
    , 'job' )
    ,
    ( 'master_relation'
    , 'Master Data Tables'
    , ''
    , 'master'
    , 'relation' )
    ,
    ( 'master_enumeration'
    , 'Master Data Lists of Values'
    , ''
    , 'master'
    , 'enumeration' )
    ,
    ( 'master_setting'
    , 'Master Data Settings'
    , ''
    , 'master'
    , 'setting' )
    ,
    ( 'support_document'
    , 'Supporting Data Forms'
    , ''
    , 'support'
    , 'document' )
     ,
    ( 'support_job'
    , 'Supporting Data Jobs'
    , ''
    , 'support'
    , 'job' )
    ,
    ( 'support_relation'
    , 'Supporting Data Tables'
    , ''
    , 'support'
    , 'relation' )
    ,
    ( 'support_enumeration'
    , 'Supporting Data Lists of Values'
    , ''
    , 'support'
    , 'enumeration' )
    ,
    ( 'support_setting'
    , 'Supporting Data Settings'
    , ''
    , 'support'
    , 'setting' )
    ,
    ( 'maintenance_document'
    , 'System Admin Forms'
    , ''
    , 'maintenance'
    , 'document' )
     ,
    ( 'maintenance_job'
    , 'System Admin Jobs'
    , ''
    , 'maintenance'
    , 'job' )
    ,
    ( 'maintenance_relation'
    , 'System Admin Tables'
    , ''
    , 'maintenance'
    , 'relation' )
    ,
    ( 'maintenance_enumeration'
    , 'System Admin Lists of Values'
    , ''
    , 'maintenance'
    , 'enumeration' )
    ,
    ( 'maintenance_setting'
    , 'System Admin Settings'
    , ''
    , 'maintenance'
    , 'setting' );
