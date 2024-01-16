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
$DOC$Public API for application business data access and logic operations.

This schema contains procedures, functions, and views suitable for access by
applications and integration tools.$DOC$;

CREATE SCHEMA IF NOT EXISTS ms_appl_priv
    AUTHORIZATION <%= ms_owner %>;

REVOKE USAGE ON SCHEMA ms_appl_priv FROM PUBLIC;

COMMENT ON SCHEMA ms_appl_priv IS
$DOC$Internal application business logic for use by Muse Systems developers.

**All member objects of this schema are considered "private".**

Direct usage of this schema or its member objects is not supported.  Please
consider using features from `ms_appl` Public API schema or other Public APIs
as appropriate.
$DOC$;

CREATE SCHEMA IF NOT EXISTS ms_appl_data
    AUTHORIZATION <%= ms_owner %>;

REVOKE USAGE ON SCHEMA ms_appl_data FROM PUBLIC;

COMMENT ON SCHEMA ms_appl_data IS
$DOC$Internal application business data for use by Muse Systems developers.

**All member objects of this schema are considered "private".**

Direct usage of this schema or its member objects is not supported.  Please
consider using features from `ms_appl` Public API schema or other Public APIs
as appropriate.$DOC$;
