-- File:        comments_config_function_param.eex.sql
-- Location:    musebms/database/all/ms_syst_priv/types/comments_config_function_param.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TYPE ms_syst_priv.comments_config_function_param AS
    (
          param_name    text
        , description   text
        , required      boolean
        , default_value text
    );

COMMENT ON TYPE ms_syst_priv.comments_config_function_param IS
$DOC$Provides standardized documentation attributes for `FUNCTION` and `PROCEDURE`,
parameters, allowing their documentation to be systematically generated.
$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_function_param.param_name IS
$DOC$The name of the parameter being documented.

**General Usage**

This value is required and there is no default value.$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_function_param.description IS
$DOC$A description of the parameter and its usage.

**General Usage**

This value is not required, though providing it is strongly recommend.  If not
provided the default is "( Parameter Not Yet Documented )".$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_function_param.required IS
$DOC$A boolean parameter indicating if the parameter must be provided by the caller.

**General Usage**

This value is not required.  If a value is not set the default value is `TRUE`
on the assumption that parameters are generally required.$DOC$;

COMMENT ON COLUMN ms_syst_priv.comments_config_function_param.default_value IS
$DOC$A text value indicating the default value of optional parameters.

**General Usage**

This value is not required.  If a value is not provided for this attribute, a
default value of "( Default Not Documented )" is used.$DOC$;
