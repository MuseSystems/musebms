-- File:        ms_schemata.eex.sql
-- Location:    musebms/database/application/msbms/gen_dbinit/ms_schemata.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE SCHEMA IF NOT EXISTS ms_appl
    AUTHORIZATION <%= ms_owner %>;

REVOKE USAGE ON SCHEMA ms_appl FROM PUBLIC;
GRANT USAGE ON SCHEMA ms_appl TO <%= ms_appusr %>;
GRANT USAGE ON SCHEMA ms_appl TO <%= ms_apiusr %>;

COMMENT ON SCHEMA ms_appl IS
$DOC$Public API for exposing business application logic and data.  Contains
procedures, functions, and views for accessing and manipulating business logic
and data.$DOC$;

CREATE SCHEMA IF NOT EXISTS ms_appl_priv
    AUTHORIZATION <%= ms_owner %>;

REVOKE USAGE ON SCHEMA ms_appl_priv FROM PUBLIC;
REVOKE USAGE ON SCHEMA ms_appl_priv FROM <%= ms_appusr %>;
REVOKE USAGE ON SCHEMA ms_appl_priv FROM <%= ms_apiusr %>;

COMMENT ON SCHEMA ms_appl_priv IS
$DOC$Internal, private business logic.  This schema contains the lower level
business logic primitives upon which the public API builds.  Note that accessing
this API outside of the packaged application is not supported.$DOC$;

CREATE SCHEMA IF NOT EXISTS ms_appl_data
    AUTHORIZATION <%= ms_owner %>;

REVOKE USAGE ON SCHEMA ms_appl_data FROM PUBLIC;
REVOKE USAGE ON SCHEMA ms_appl_data FROM <%= ms_appusr %>;
REVOKE USAGE ON SCHEMA ms_appl_data FROM <%= ms_apiusr %>;

COMMENT ON SCHEMA ms_appl_data IS
$DOC$Schema container for the application's business related data tables and
application defined types.$DOC$;

CREATE SCHEMA IF NOT EXISTS ms_user
    AUTHORIZATION <%= ms_owner %>;

REVOKE USAGE ON SCHEMA ms_user FROM PUBLIC;
GRANT USAGE ON SCHEMA ms_user TO <%= ms_appusr %>;
GRANT USAGE ON SCHEMA ms_user TO <%= ms_apiusr %>;

COMMENT ON SCHEMA ms_user IS
$DOC$A schema container for user defined public API procedures, functions, and
views.$DOC$;

CREATE SCHEMA IF NOT EXISTS ms_user_priv
    AUTHORIZATION <%= ms_owner %>;

REVOKE USAGE ON SCHEMA ms_user_priv FROM PUBLIC;
REVOKE USAGE ON SCHEMA ms_user_priv FROM <%= ms_appusr %>;
REVOKE USAGE ON SCHEMA ms_user_priv FROM <%= ms_apiusr %>;

COMMENT ON SCHEMA ms_user_priv IS
$DOC$A schema container for user defined logic primitives, procedures, functions, and
views.$DOC$;

CREATE SCHEMA IF NOT EXISTS ms_user_data
    AUTHORIZATION <%= ms_owner %>;

REVOKE USAGE ON SCHEMA ms_user_data FROM PUBLIC;
REVOKE USAGE ON SCHEMA ms_user_data FROM <%= ms_appusr %>;
REVOKE USAGE ON SCHEMA ms_user_data FROM <%= ms_apiusr %>;

COMMENT ON SCHEMA ms_user_data IS
$DOC$Schema container for user defined data tables and user defined types.$DOC$;
