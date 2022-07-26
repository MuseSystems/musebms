-- File:        create_database_schemata.eex.sql
-- Location:    database\cmp_msbms_syst_authentication\testing_support\create_database_schemata.eex.sql
-- Project:     Muse Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE SCHEMA IF NOT EXISTS msbms_syst
    AUTHORIZATION <%= msbms_owner %>;

REVOKE USAGE ON SCHEMA msbms_syst FROM PUBLIC;
GRANT USAGE ON SCHEMA msbms_syst TO <%= msbms_appusr %>;

COMMENT ON SCHEMA msbms_syst IS
$DOC$Public API for system operations.  The important distinction is that business
data is not stored here. This schema contains procedures, functions, and views
suitable for calling outside of the application or via user customizations.$DOC$;

CREATE SCHEMA IF NOT EXISTS msbms_syst_priv
    AUTHORIZATION <%= msbms_owner %>;

REVOKE USAGE ON SCHEMA msbms_syst_priv FROM PUBLIC;
GRANT  USAGE ON SCHEMA msbms_syst_priv TO   <%= msbms_appusr %>;

COMMENT ON SCHEMA msbms_syst_priv IS
$DOC$Internal, private system operations.  These functions are developed not for the
purpose of general access, but contain primitives and other internal booking-
keeping functions.  These functions should not be called directly outside of the
packaged application.$DOC$;

CREATE SCHEMA IF NOT EXISTS msbms_syst_data
    AUTHORIZATION <%= msbms_owner %>;

REVOKE USAGE ON SCHEMA msbms_syst_data FROM PUBLIC;
GRANT  USAGE ON SCHEMA msbms_syst_data TO   <%= msbms_appusr %>;

COMMENT ON SCHEMA msbms_syst_data IS
$DOC$Schema container for system operations related data tables and application
defined types.  The data in this schema is not related to user business data,
but rather facilitates the operation of the application as a software system.$DOC$;
