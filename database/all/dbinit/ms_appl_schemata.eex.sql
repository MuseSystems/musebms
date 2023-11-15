-- File:        ms_appl_schemata.eex.sql
-- Location:    musebms/database/all/dbinit/ms_appl_schemata.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE SCHEMA IF NOT EXISTS ms_appl
    AUTHORIZATION <%= ms_owner %>;

REVOKE USAGE ON SCHEMA ms_appl FROM PUBLIC;

COMMENT ON SCHEMA ms_appl IS
$DOC$Public API for business data/logic operations.  The important distinction is
that data is not stored here. This schema contains procedures, functions, and
views suitable for calling outside of the application or via user
customizations.$DOC$;

CREATE SCHEMA IF NOT EXISTS ms_appl_priv
    AUTHORIZATION <%= ms_owner %>;

REVOKE USAGE ON SCHEMA ms_appl_priv FROM PUBLIC;

COMMENT ON SCHEMA ms_appl_priv IS
$DOC$Internal, private business logic operations.  These functions are developed not
for the purpose of general access, but contain primitives and other internal
booking-keeping functions.  These functions should not be called directly
outside of the packaged application.$DOC$;

CREATE SCHEMA IF NOT EXISTS ms_appl_data
    AUTHORIZATION <%= ms_owner %>;

REVOKE USAGE ON SCHEMA ms_appl_data FROM PUBLIC;

COMMENT ON SCHEMA ms_appl_data IS
$DOC$Schema container principally for business related data tables and application
defined types.$DOC$;
