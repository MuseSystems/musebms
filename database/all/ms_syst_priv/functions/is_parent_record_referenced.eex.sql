CREATE OR REPLACE FUNCTION
    ms_syst_priv.is_parent_record_referenced(
        p_table_schema       text,
        p_table_name         text,
        p_parent_record_id   uuid,
        p_excluded_relations regclass[] DEFAULT '{}'::regclass[] )
RETURNS boolean AS
$BODY$

-- File:        is_parent_record_referenced.eex.sql
-- Location:    musebms/database/all/ms_syst_priv/functions/is_parent_record_referenced.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

DECLARE
    var_referencing_relation record;
    var_check_result         boolean;

BEGIN

    IF
           p_table_schema IS NULL
        OR p_table_name IS NULL
        OR p_parent_record_id IS NULL
    THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'All parameters are required with valid, non-null ' ||
                'values.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst_priv'
                            ,p_proc_name      => 'is_parent_record_referenced'
                            ,p_exception_name => 'invalid_parameter'
                            ,p_errcode        => 'PM008'
                            ,p_param_data     =>
                                jsonb_build_object(
                                     'p_table_schema',       p_table_schema
                                    ,'p_table_name',         p_table_name
                                    ,'p_parent_record_id',   p_parent_record_id
                                    ,'p_excluded_relations', p_excluded_relations)
                            ,p_context_data   => null),
                ERRCODE = 'PM008';
    END IF;

    << referencing_relations_loop >>
    FOR var_referencing_relation IN
        SELECT
              kcu.table_schema
            , kcu.table_name
            , kcu.column_name
        FROM information_schema.table_constraints tc
            JOIN information_schema.constraint_column_usage ccu
                ON  ccu.table_schema    = tc.table_schema AND
                    ccu.table_name      = tc.table_name   AND
                    ccu.constraint_name = tc.constraint_name
            JOIN information_schema.key_column_usage kcu
                ON  kcu.constraint_name = tc.constraint_name
        WHERE   tc.constraint_type = 'FOREIGN KEY'
            AND tc.table_schema    = p_table_schema
            AND tc.table_name      = p_table_name
            AND ccu.column_name    = 'id'
            AND NOT to_regclass( kcu.table_schema || '.' || kcu.table_name ) =
                    ANY ( coalesce( p_excluded_relations, '{}'::regclass[] ) )
    LOOP

        EXECUTE format(
            'SELECT exists(SELECT TRUE FROM %1$I.%2$I WHERE %3$I = (%4$L)::uuid)',
            var_referencing_relation.table_schema,
            var_referencing_relation.table_name,
            var_referencing_relation.column_name,
            p_parent_record_id)
            INTO var_check_result;

        IF var_check_result THEN
            RETURN TRUE;
        END IF;

    END LOOP referencing_relations_loop;

    RETURN FALSE;

END;
$BODY$
LANGUAGE plpgsql STABLE;

ALTER FUNCTION
    ms_syst_priv.is_parent_record_referenced(
        p_table_schema       text,
        p_table_name         text,
        p_parent_record_id   uuid,
        p_excluded_relations regclass[] )
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION
    ms_syst_priv.is_parent_record_referenced(
        p_table_schema       text,
        p_table_name         text,
        p_parent_record_id   uuid,
        p_excluded_relations regclass[] )
    FROM public;

GRANT EXECUTE ON FUNCTION
    ms_syst_priv.is_parent_record_referenced(
        p_table_schema       text,
        p_table_name         text,
        p_parent_record_id   uuid,
        p_excluded_relations regclass[] )
    TO <%= ms_owner %>;

COMMENT ON FUNCTION
    ms_syst_priv.is_parent_record_referenced(
        p_table_schema       text,
        p_table_name         text,
        p_parent_record_id   uuid,
        p_excluded_relations regclass[] )
    IS
$DOC$Tests if a specific parent record is referenced in a foreign key relationship.

The parent table is identified by the `p_table_schema` and `p_table_name`
parameters and the specific record is identified using the `p_parent_record_id`
parameter.  The `p_parent_record_id` is expected to be the `id` column value of
the parent relation.

On execution, the function will then look up all relations (children) with
foreign key references to the parent table and its `id` column and test if the
`p_parent_record_id` value exists in the child relation.  Once a child relation
with a reference is found, then the function returns `TRUE` and the search
stops. If no child relations have a reference to the given parent record, then
the function returns false.

There are several assumptions to be aware of when making use of this function.
The function assumes that any foreign key reference to the parent relation is a
simple, single column relationship to the parent relation's `id` column;  an
assumption is made that constraint names are unique across the application, but
there is no guarantee from PostgreSQL that this is true; and that by using this
function the developer is aware that when there are either many child relations
and/or the child relations contain many records, this function may not perform
well, especially in cases where there are no references to the given parent
record.  Finally, if any of the parameter values are `NULL`, the function will
return `NULL`.$DOC$;
