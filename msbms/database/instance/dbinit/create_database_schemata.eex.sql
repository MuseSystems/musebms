-- Source File: create_database_schemata.eex.sql
-- Location:    msbms/database/instance/dbinit/create_database_schemata.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from thrid parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE SCHEMA IF NOT EXISTS msbms_syst
    AUTHORIZATION <%= msbms_owner %>;

REVOKE USAGE ON SCHEMA msbms_syst FROM PUBLIC;
GRANT USAGE ON SCHEMA msbms_syst TO <%= msbms_app_admin %>;
GRANT USAGE ON SCHEMA msbms_syst TO <%= msbms_api_admin %>;
GRANT USAGE ON SCHEMA msbms_syst TO <%= msbms_app_user %>;
GRANT USAGE ON SCHEMA msbms_syst TO <%= msbms_api_user %>;

COMMENT ON SCHEMA msbms_syst IS
$DOC$Public API for system operations.  The important distinction is that business
data is not stored here. This schema contains procedures, functions, and views
suitable for calling outside of the application or via user customizations.$DOC$;

CREATE SCHEMA IF NOT EXISTS msbms_syst_priv
    AUTHORIZATION <%= msbms_owner %>;

REVOKE USAGE ON SCHEMA msbms_syst_priv FROM PUBLIC;
REVOKE USAGE ON SCHEMA msbms_syst_priv FROM <%= msbms_app_admin %>;
REVOKE USAGE ON SCHEMA msbms_syst_priv FROM <%= msbms_api_admin %>;
REVOKE USAGE ON SCHEMA msbms_syst_priv FROM <%= msbms_app_user %>;
REVOKE USAGE ON SCHEMA msbms_syst_priv FROM <%= msbms_api_user %>;

COMMENT ON SCHEMA msbms_syst_priv IS
$DOC$Internal, private system operations.  These functions are developed not for the
purpose of general access, but contain primitives and other internal booking-
keeping functions.  These functions should not be called directly outside of the
packaged application.$DOC$;

CREATE SCHEMA IF NOT EXISTS msbms_syst_data
    AUTHORIZATION <%= msbms_owner %>;

REVOKE USAGE ON SCHEMA msbms_syst_data FROM PUBLIC;
REVOKE USAGE ON SCHEMA msbms_syst_data FROM <%= msbms_app_admin %>;
REVOKE USAGE ON SCHEMA msbms_syst_data FROM <%= msbms_api_admin %>;
REVOKE USAGE ON SCHEMA msbms_syst_data FROM <%= msbms_app_user %>;
REVOKE USAGE ON SCHEMA msbms_syst_data FROM <%= msbms_api_user %>;

COMMENT ON SCHEMA msbms_syst_data IS
$DOC$Schema container for system operations related data tables and application
defined types.  The data in this schema is not related to user business data,
but rather facilitates the operation of the application as a software system.$DOC$;

CREATE SCHEMA IF NOT EXISTS msbms_appl
    AUTHORIZATION <%= msbms_owner %>;

REVOKE USAGE ON SCHEMA msbms_appl FROM PUBLIC;
GRANT USAGE ON SCHEMA msbms_appl TO <%= msbms_app_admin %>;
GRANT USAGE ON SCHEMA msbms_appl TO <%= msbms_api_admin %>;
GRANT USAGE ON SCHEMA msbms_appl TO <%= msbms_app_user %>;
GRANT USAGE ON SCHEMA msbms_appl TO <%= msbms_api_user %>;

COMMENT ON SCHEMA msbms_appl IS
$DOC$Public API for exposing business application logic and data.  Contains
procedures, functions, and views for accessing and manipulating business logic
and data.$DOC$;

CREATE SCHEMA IF NOT EXISTS msbms_appl_priv
    AUTHORIZATION <%= msbms_owner %>;

REVOKE USAGE ON SCHEMA msbms_appl_priv FROM PUBLIC;
REVOKE USAGE ON SCHEMA msbms_appl_priv FROM <%= msbms_app_admin %>;
REVOKE USAGE ON SCHEMA msbms_appl_priv FROM <%= msbms_api_admin %>;
REVOKE USAGE ON SCHEMA msbms_appl_priv FROM <%= msbms_app_user %>;
REVOKE USAGE ON SCHEMA msbms_appl_priv FROM <%= msbms_api_user %>;

COMMENT ON SCHEMA msbms_appl_priv IS
$DOC$Internal, private business logic.  This schema contains the lower level
business logic primitives upon which the public API builds.  Note that accessing
this API outside of the packaged application is not supported.$DOC$;

CREATE SCHEMA IF NOT EXISTS msbms_appl_data
    AUTHORIZATION <%= msbms_owner %>;

REVOKE USAGE ON SCHEMA msbms_appl_data FROM PUBLIC;
REVOKE USAGE ON SCHEMA msbms_appl_data FROM <%= msbms_app_admin %>;
REVOKE USAGE ON SCHEMA msbms_appl_data FROM <%= msbms_api_admin %>;
REVOKE USAGE ON SCHEMA msbms_appl_data FROM <%= msbms_app_user %>;
REVOKE USAGE ON SCHEMA msbms_appl_data FROM <%= msbms_api_user %>;

COMMENT ON SCHEMA msbms_appl_data IS
$DOC$Schema container for the application's business related data tables and
application defined types.$DOC$;

CREATE SCHEMA IF NOT EXISTS msbms_user
    AUTHORIZATION <%= msbms_owner %>;

REVOKE USAGE ON SCHEMA msbms_user FROM PUBLIC;
GRANT USAGE ON SCHEMA msbms_user TO <%= msbms_app_admin %>;
GRANT USAGE ON SCHEMA msbms_user TO <%= msbms_api_admin %>;
GRANT USAGE ON SCHEMA msbms_user TO <%= msbms_app_user %>;
GRANT USAGE ON SCHEMA msbms_user TO <%= msbms_api_user %>;

COMMENT ON SCHEMA msbms_user IS
$DOC$A schema container for user defined public API procedures, functions, and
views.$DOC$;

CREATE SCHEMA IF NOT EXISTS msbms_user_priv
    AUTHORIZATION <%= msbms_owner %>;

REVOKE USAGE ON SCHEMA msbms_user_priv FROM PUBLIC;
REVOKE USAGE ON SCHEMA msbms_user_priv FROM <%= msbms_app_admin %>;
REVOKE USAGE ON SCHEMA msbms_user_priv FROM <%= msbms_api_admin %>;
REVOKE USAGE ON SCHEMA msbms_user_priv FROM <%= msbms_app_user %>;
REVOKE USAGE ON SCHEMA msbms_user_priv FROM <%= msbms_api_user %>;

COMMENT ON SCHEMA msbms_user_priv IS
$DOC$A schema container for user defined logic primitives, procedures, functions, and
views.$DOC$;

CREATE SCHEMA IF NOT EXISTS msbms_user_data
    AUTHORIZATION <%= msbms_owner %>;

REVOKE USAGE ON SCHEMA msbms_user_data FROM PUBLIC;
REVOKE USAGE ON SCHEMA msbms_user_data FROM <%= msbms_app_admin %>;
REVOKE USAGE ON SCHEMA msbms_user_data FROM <%= msbms_api_admin %>;
REVOKE USAGE ON SCHEMA msbms_user_data FROM <%= msbms_app_user %>;
REVOKE USAGE ON SCHEMA msbms_user_data FROM <%= msbms_api_user %>;

COMMENT ON SCHEMA msbms_user_data IS
$DOC$Schema container for user defined data tables and user defined types.$DOC$;
