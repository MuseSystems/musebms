-- File:        ms_syst_schemata.eex.sql
-- Location:    musebms/database/all/dbinit/ms_syst_schemata.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE SCHEMA IF NOT EXISTS ms_syst
    AUTHORIZATION <%= ms_owner %>;

REVOKE USAGE ON SCHEMA ms_syst FROM PUBLIC;

COMMENT ON SCHEMA ms_syst IS
$DOC$Public API for system management oriented data access and operations. This
schema contains procedures, functions, and views suitable for access by
applications and integration tools.$DOC$;

CREATE SCHEMA IF NOT EXISTS ms_syst_priv
    AUTHORIZATION <%= ms_owner %>;

REVOKE USAGE ON SCHEMA ms_syst_priv FROM PUBLIC;

COMMENT ON SCHEMA ms_syst_priv IS
$DOC$Internal system management logic for use by Muse Systems developers.

**All member objects of this schema are considered "private".**

Direct usage of this schema or its member objects is not supported.  Please
consider using features from `ms_syst` Public API schema or other Public APIs
as appropriate.$DOC$;

CREATE SCHEMA IF NOT EXISTS ms_syst_data
    AUTHORIZATION <%= ms_owner %>;

REVOKE USAGE ON SCHEMA ms_syst_data FROM PUBLIC;

COMMENT ON SCHEMA ms_syst_data IS
$DOC$Internal system management data for use by Muse Systems developers.

**All member objects of this schema are considered "private".**

Direct usage of this schema or its member objects is not supported.  Please
consider using features from `ms_syst` Public API schema or other Public APIs
as appropriate.$DOC$;
