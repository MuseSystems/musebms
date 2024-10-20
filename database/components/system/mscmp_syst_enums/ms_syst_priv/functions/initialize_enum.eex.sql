CREATE OR REPLACE PROCEDURE ms_syst_priv.initialize_enum(p_enum_def jsonb)
AS
$BODY$

-- File:        initialize_enum.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_enums/ms_syst_priv/functions/initialize_enum.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

DECLARE
    var_new_enum             ms_syst_data.syst_enums;
    var_curr_functional_type jsonb;
    var_curr_enum_item      jsonb;

BEGIN

    INSERT INTO ms_syst_data.syst_enums
        (
           internal_name
          ,display_name
          ,syst_description
          ,syst_defined
          ,user_maintainable
          ,default_syst_options
        )
    VALUES
        (
           p_enum_def ->> 'internal_name'
          ,p_enum_def ->> 'display_name'
          ,p_enum_def ->> 'syst_description'
          ,( p_enum_def -> 'syst_defined' )::boolean
          ,( p_enum_def -> 'user_maintainable' )::boolean
          ,p_enum_def -> 'default_syst_options'
        )
    RETURNING * INTO var_new_enum;

    << functional_type_loop >>
    FOR var_curr_functional_type IN
        SELECT jsonb_array_elements(p_enum_def -> 'functional_types')
    LOOP

        INSERT INTO ms_syst_data.syst_enum_functional_types
            (
              internal_name
             ,display_name
             ,external_name
             ,enum_id
             ,syst_description
            )
        VALUES
            (
              var_curr_functional_type ->> 'internal_name'
             ,var_curr_functional_type ->> 'display_name'
             ,var_curr_functional_type ->> 'external_name'
             ,var_new_enum.id
             ,var_curr_functional_type ->> 'syst_description'
            );

    END LOOP functional_type_loop;

    << enum_item_loop >>
    FOR var_curr_enum_item IN
        SELECT jsonb_array_elements(p_enum_def -> 'enum_items')
    LOOP

        INSERT INTO ms_syst_data.syst_enum_items
            (
               internal_name
              ,display_name
              ,external_name
              ,enum_id
              ,functional_type_id
              ,enum_default
              ,functional_type_default
              ,syst_defined
              ,user_maintainable
              ,syst_description
              ,sort_order
              ,syst_options
            )
        VALUES
            (
                var_curr_enum_item ->> 'internal_name'
               ,var_curr_enum_item ->> 'display_name'
               ,var_curr_enum_item ->> 'external_name'
               ,var_new_enum.id
               ,( SELECT id
                  FROM ms_syst_data.syst_enum_functional_types
                  WHERE internal_name = var_curr_enum_item ->> 'functional_type_name')
               ,( var_curr_enum_item -> 'enum_default' )::boolean
               ,( var_curr_enum_item -> 'functional_type_default' )::boolean
               ,( var_curr_enum_item -> 'syst_defined' )::boolean
               ,( var_curr_enum_item -> 'user_maintainable' )::boolean
               ,var_curr_enum_item ->> 'syst_description'
               ,coalesce(
                   (SELECT max(sort_order) + 1
                    FROM ms_syst_data.syst_enum_items
                    WHERE enum_id = var_new_enum.id),
                   1
                    )
               ,var_curr_enum_item -> 'syst_options'
            );

    END LOOP enum_item_loop;

END;
$BODY$
LANGUAGE plpgsql;

ALTER PROCEDURE ms_syst_priv.initialize_enum(p_enum_def jsonb)
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON PROCEDURE ms_syst_priv.initialize_enum(p_enum_def jsonb) FROM public;
GRANT EXECUTE ON PROCEDURE ms_syst_priv.initialize_enum(p_enum_def jsonb) TO <%= ms_owner %>;


COMMENT ON PROCEDURE ms_syst_priv.initialize_enum(p_enum_def jsonb) IS
$DOC$Based on a specially formatted JSON object passed as a parameter, this function
will create a new enumeration along with its optional functional types and
starting value records.$DOC$;
