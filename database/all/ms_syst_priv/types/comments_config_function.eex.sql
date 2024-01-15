-- File:        comments_config_function.eex.sql
-- Location:    musebms/database/all/ms_syst_priv/types/comments_config_function.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TYPE ms_syst_priv.comments_config_function AS
    (
          function_schema text
        , function_name   text
        , description     text
        , general_usage   text
        , params          ms_syst_priv.comments_config_function_param[]
    );

COMMENT ON TYPE ms_syst_priv.comments_config_function IS
$DOC$Defines the structure of documentation for database procedural code
(`PROCEDURE`, `FUNCTION`) and allows for the automatic generation of formatted
documentation.$DOC$;

COMMENT ON
    COLUMN ms_syst_priv.comments_config_function.function_schema IS
$DOC$A text value indicating the database schema naming hosting the routine to be
commented upon.

**General Usage**

This value is required and there is no default value.$DOC$;

COMMENT ON
    COLUMN ms_syst_priv.comments_config_function.function_name IS
$DOC$The name of the routine being commented upon.

**General Usage**

This value is required and there is no default value.$DOC$;

COMMENT ON
    COLUMN ms_syst_priv.comments_config_function.description IS
$DOC$A description of the routine and its usage.

**General Usage**

This value is not required, though providing it is strongly recommend.  If not
provided the default is "( Routine Not Yet Documented )".$DOC$;

COMMENT ON
    COLUMN ms_syst_priv.comments_config_function.general_usage IS
$DOC$Notes regarding how callers should use the function and any details regarding
unobvious usage expectations.

**General Usage**

This value is not required.  If provided, a "General Usage" section will be
added to the comment including the configured text.  Otherwise the "General
Usage" section is omitted.$DOC$;

COMMENT ON
    COLUMN ms_syst_priv.comments_config_function.params IS
$DOC$A list of `ms_syst_priv.comments_config_function_param` objects which provide
comment configurations for each of the routine's parameters.

**General Usage**

This value is not required.  There is no default value provided.$DOC$;
