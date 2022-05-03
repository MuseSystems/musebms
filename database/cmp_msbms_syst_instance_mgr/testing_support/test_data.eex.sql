-- File:        test_data.eex.sql
-- Location:    database\cmp_msbms_syst_instance_mgr\testing_support\test_data.eex.sql
-- Project:     Muse Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

--
--  Applications
--
INSERT INTO msbms_syst_data.syst_applications
    ( internal_name, display_name, syst_description )
VALUES
    ( 'test_app_2', 'Test App Two', 'Test App Two Description' )
     ,
    ( 'test_app_1', 'Test App One', 'Test App One Description' );
