-- Migration: priv/database/app_msbms/app_msbms.01.01.000.0000MS.000.eex.sql
-- Built on:  2022-11-17 22:48:00.639691Z

DO
$MIGRATION$
BEGIN
-- File:        database_initial_setup.eex.sql
-- Location:    musebms/database/all/dbinit/database_initial_setup.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

/****
  This script initializes a fresh installation of the Muse Systems Business
  Management System.

  This script will create the required database roles and extensions in the
  target database cluster/database.

  Please be sure that the following extensions are available to be installed
  prior to running this script:

    - uuid-ossp


****/


DO
$SCRIPT$
BEGIN

    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
    CREATE EXTENSION IF NOT EXISTS "pgcrypto";

    REVOKE ALL ON SCHEMA public FROM public;
END;
$SCRIPT$;
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
$DOC$Public API for system operations.  The important distinction is that business
data is not stored here. This schema contains procedures, functions, and views
suitable for calling outside of the application or via user customizations.$DOC$;

CREATE SCHEMA IF NOT EXISTS ms_syst_priv
    AUTHORIZATION <%= ms_owner %>;

REVOKE USAGE ON SCHEMA ms_syst_priv FROM PUBLIC;

COMMENT ON SCHEMA ms_syst_priv IS
$DOC$Internal, private system operations.  These functions are developed not for the
purpose of general access, but contain primitives and other internal booking-
keeping functions.  These functions should not be called directly outside of the
packaged application.$DOC$;

CREATE SCHEMA IF NOT EXISTS ms_syst_data
    AUTHORIZATION <%= ms_owner %>;

REVOKE USAGE ON SCHEMA ms_syst_data FROM PUBLIC;

COMMENT ON SCHEMA ms_syst_data IS
$DOC$Schema container for system operations related data tables and application
defined types.  The data in this schema is not related to user business data,
but rather facilitates the operation of the application as a software system.$DOC$;
-- File:        variant_insensitive.eex.sql
-- Location:    musebms/database/all/ms_syst_priv/collations/variant_insensitive.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE COLLATION ms_syst_priv.variant_insensitive (
     PROVIDER      = 'icu'
    ,LOCALE        = 'und-u-ks-level1'
    ,DETERMINISTIC = FALSE
    );

COMMENT ON
    COLLATION ms_syst_priv.variant_insensitive IS
$DOC$A collation which ignores upper/lower case and certain other types of base
character variants (i.e. e = é).  Mostly this will be used for internal_name
columns.  Please note that there are performance implications and cross system
consistency implications when using this collation.$DOC$;

ALTER COLLATION ms_syst_priv.variant_insensitive OWNER TO <%= ms_owner %>;
--
-- Returns exception details based on the passed parameters represented as a pretty-printed JSON
-- object.  The returned value is intended to standardize the details related to RAISEd exceptions
-- and be suitable for use in setting the RAISE DETAILS variable.
--

CREATE OR REPLACE FUNCTION
    ms_syst_priv.get_exception_details(p_proc_schema    text
                                         ,p_proc_name      text
                                         ,p_exception_name text
                                         ,p_errcode        text
                                         ,p_param_data     jsonb
                                         ,p_context_data   jsonb)
RETURNS text AS
$BODY$

-- File:        get_exception_details.eex.sql
-- Location:    musebms/database/all/ms_syst_priv/functions/get_exception_details.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems


    SELECT
        jsonb_pretty(
            jsonb_build_object(
                 'procedure_schema',      p_proc_schema
                ,'procedure_name',        p_proc_name
                ,'exception_name',        p_exception_name
                ,'sqlstate',              p_errcode
                ,'parameters',            p_param_data
                ,'context',               p_context_data
                ,'transaction_timestamp', now()
                ,'wallclock_timestamp',   clock_timestamp()));

$BODY$
LANGUAGE sql VOLATILE;

ALTER FUNCTION ms_syst_priv.get_exception_details(p_proc_schema    text
                                                    ,p_proc_name      text
                                                    ,p_exception_name text
                                                    ,p_errcode        text
                                                    ,p_param_data     jsonb
                                                    ,p_context_data   jsonb)
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION
    ms_syst_priv.get_exception_details(p_proc_schema    text
                                          ,p_proc_name      text
                                          ,p_exception_name text
                                          ,p_errcode        text
                                          ,p_param_data     jsonb
                                          ,p_context_data   jsonb)
    FROM public;

GRANT EXECUTE ON FUNCTION
    ms_syst_priv.get_exception_details( p_proc_schema    text
                                          ,p_proc_name      text
                                          ,p_exception_name text
                                          ,p_errcode        text
                                          ,p_param_data     jsonb
                                          ,p_context_data   jsonb)
    TO <%= ms_owner %>;


COMMENT ON FUNCTION
    ms_syst_priv.get_exception_details(p_proc_schema    text
                                          ,p_proc_name      text
                                          ,p_exception_name text
                                          ,p_errcode        text
                                          ,p_param_data     jsonb
                                          ,p_context_data   jsonb) IS
$DOC$Returns exception details based on the passed parameters represented as a pretty-printed JSON
object.  The returned value is intended to standardize the details related to RAISEd exceptions and
be suitable for use in setting the RAISE DETAILS variable. $DOC$;
CREATE OR REPLACE FUNCTION ms_syst_priv.trig_b_iu_set_diagnostic_columns()
RETURNS trigger AS
$BODY$

-- File:        trig_b_iu_set_diagnostic_columns.eex.sql
-- Location:    musebms/database/all/ms_syst_priv/trigger_functions/trig_b_iu_set_diagnostic_columns.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

BEGIN
    DECLARE
        var_jsonb_new        jsonb;
        var_jsonb_old        jsonb;
        var_jsonb_final      jsonb;

        bypass_change_fields boolean;

    BEGIN
        -- If this is an update and no actual data has changed, we don't want to
        -- pretend that something actually did change.  We set the flag here and
        -- later we bypass all of the fields indicating a real change.  We still
        -- update the diag_update_count field, because the database is still
        -- doing work in that scenario.
        bypass_change_fields := CASE
                                    WHEN tg_op = 'UPDATE' THEN
                                        to_jsonb( new ) = to_jsonb( old )
                                    ELSE
                                        FALSE
                                END;

        -- Let's turn the new and old records into hstores so we can arbitrarily
        -- get their columns.  We also need to make the final hstore look a lot
        -- like NEW.
        var_jsonb_new := to_jsonb( new );
        var_jsonb_old := to_jsonb( old );

        var_jsonb_final := var_jsonb_new - ARRAY [ 'diag_timestamp_created'
                                                  ,'diag_role_created'
                                                  ,'diag_timestamp_modified'
                                                  ,'diag_wallclock_modified'
                                                  ,'diag_role_modified'
                                                  ,'diag_row_version'
                                                  ,'diag_update_count'];

        -- Now we can get some work done.
        CASE tg_op
            WHEN 'INSERT' THEN
                var_jsonb_final :=
                    var_jsonb_final ||
                    jsonb_build_object( 'diag_timestamp_created', now( ) );
                var_jsonb_final :=
                    var_jsonb_final ||
                    jsonb_build_object( 'diag_role_created', session_user );
                var_jsonb_final :=
                    var_jsonb_final ||
                    jsonb_build_object( 'diag_timestamp_modified', now( ) );
                var_jsonb_final :=
                    var_jsonb_final ||
                    jsonb_build_object( 'diag_wallclock_modified',
                                        clock_timestamp( ) );
                var_jsonb_final :=
                    var_jsonb_final ||
                    jsonb_build_object( 'diag_role_modified', session_user );
                var_jsonb_final :=
                    var_jsonb_final ||
                    jsonb_build_object( 'diag_row_version', 1 );
                var_jsonb_final :=
                    var_jsonb_final ||
                    jsonb_build_object( 'diag_update_count', 0 );

            WHEN 'UPDATE' THEN
                IF NOT bypass_change_fields THEN
                    var_jsonb_final :=
                        var_jsonb_final ||
                        jsonb_build_object( 'diag_timestamp_modified', now( ) );
                    var_jsonb_final :=
                        var_jsonb_final ||
                        jsonb_build_object( 'diag_wallclock_modified',
                                            clock_timestamp( ) );
                    var_jsonb_final :=
                        var_jsonb_final ||
                        jsonb_build_object( 'diag_role_modified', session_user );
                    var_jsonb_final :=
                        var_jsonb_final ||
                        jsonb_build_object( 'diag_row_version',
                                            ( var_jsonb_old -> 'diag_row_version' )::bigint  + 1 );
                END IF;

                var_jsonb_final :=
                    var_jsonb_final ||
                    jsonb_build_object( 'diag_update_count',
                                        ( var_jsonb_old -> 'diag_update_count' )::bigint  + 1 );

        ELSE
            RAISE EXCEPTION
                USING
                    MESSAGE = 'We should never get here.  The diagnostic column maintenance '
                              'trigger was fired on something other than the insert/update of a '
                              'regular record type.',
                    DETAIL = ms_syst_priv.get_exception_details(
                                 p_proc_schema    => 'ms_syst_priv'
                                ,p_proc_name      => 'trig_b_iu_set_diagnostic_columns'
                                ,p_exception_name => 'unreachable_code_reached'
                                ,p_errcode        => 'PM001'
                                ,p_param_data     => NULL::jsonb
                                ,p_context_data   =>
                                    jsonb_build_object(
                                         'tg_op',         tg_op
                                        ,'tg_when',       tg_when
                                        ,'tg_schema',     tg_table_schema
                                        ,'tg_table_name', tg_table_name)),
                    ERRCODE = 'PM001',
                    SCHEMA = tg_table_schema,
                    TABLE = tg_table_name;

        END CASE;

        -- We've done our jsonb magic, lets actually get a record to return...
        new := jsonb_populate_record( new, var_jsonb_final );

        RETURN new;

    END;
END;
$BODY$ LANGUAGE plpgsql
    VOLATILE;

ALTER FUNCTION ms_syst_priv.trig_b_iu_set_diagnostic_columns()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_priv.trig_b_iu_set_diagnostic_columns() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_priv.trig_b_iu_set_diagnostic_columns() TO <%= ms_owner %>;


COMMENT ON FUNCTION ms_syst_priv.trig_b_iu_set_diagnostic_columns() IS
$DOC$Automatically maintains the common table diagnostic columns whenever data is
inserted or updated.  For UPDATE transactions, the trigger will determine if
there are 'real data changes', meaning any fields other than the common
diagnostic columns being changed by the transaction.  If not, only the
diag_update_count column will be updated.$DOC$;
CREATE OR REPLACE FUNCTION
    ms_syst_priv.nonstandard_encode(p_base integer, p_tokens text, p_value bigint)
RETURNS text AS
$BODY$

-- File:        nonstandard_encode.eex.sql
-- Location:    musebms/database/all/ms_syst_priv/functions/nonstandard_encode.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

-- Note that this function is an adaptation of code published publicly by
-- David Sanabria (https://github.com/david-sanabria) at:
-- https://gist.github.com/david-sanabria/0d3ff67eb56d2750502aed4186d6a4a7
--
-- The original code is believed to be copyright David Sanabria.

DECLARE
    var_token_array text[]  := string_to_array(p_tokens, NULL );
    var_remainder   integer;
    var_interim     bigint;
    var_return_text text    := '';


BEGIN

    var_interim := abs( p_value );

    << conversion_loop >>
    LOOP
        var_remainder   := var_interim % p_base;
        var_interim     := var_interim / p_base;
        var_return_text := '' || var_token_array[( var_remainder + 1 )] || var_return_text;

        EXIT WHEN var_interim <= 0;

    END LOOP conversion_loop;

    RETURN var_return_text;

END;
$BODY$
LANGUAGE plpgsql IMMUTABLE;

ALTER FUNCTION ms_syst_priv.nonstandard_encode(p_base integer, p_tokens text, p_value bigint)
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION
    ms_syst_priv.nonstandard_encode(p_base integer, p_tokens text, p_value bigint) FROM public;

GRANT EXECUTE ON FUNCTION
    ms_syst_priv.nonstandard_encode(p_base integer, p_tokens text, p_value bigint)
    TO <%= ms_owner %>;

COMMENT ON
    FUNCTION ms_syst_priv.nonstandard_encode(p_base integer, p_tokens text, p_value bigint) IS
$DOC$Performs an encode operation, similar to the standard encode function, but for
non-standard encoding schemes, such as Base32 or Base36.$DOC$;
CREATE OR REPLACE FUNCTION
    ms_syst_priv.nonstandard_decode(p_base integer, p_tokens text, p_value text)
RETURNS bigint AS
$BODY$

-- File:        nonstandard_decode.eex.sql
-- Location:    musebms/database/all/ms_syst_priv/functions/nonstandard_decode.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

-- Note that this function is an adaptation of code published publicly by
-- David Sanabria (https://github.com/david-sanabria) at:
-- https://gist.github.com/david-sanabria/0d3ff67eb56d2750502aed4186d6a4a7
--
-- The original code is believed to be copyright David Sanabria.

DECLARE
    var_encoded_arr       text[];
    var_return_result     bigint  := 0;
    var_interim           bigint;
    var_index             integer; -- Pointer to input array
    var_token             text;
    var_power             integer := 0; -- reverse pointer, used for position exponent (e.g. 2^32)

BEGIN

    IF p_value IS NULL OR length( p_value ) = 0 THEN
        RETURN NULL;
    END IF;

    var_encoded_arr := string_to_array( reverse( p_value ), NULL );

    << conversion_loop >>
    FOREACH var_token IN ARRAY var_encoded_arr LOOP

        var_index := strpos( p_tokens, var_token );

        IF var_index <> 0 THEN

            var_interim       := ( ( var_index - 1 ) * pow( p_base, var_power ) );
            var_return_result := var_return_result + var_interim;
            var_power         := 1 + var_power;

        END IF;

    END LOOP conversion_loop;

    RETURN var_return_result;

END;
$BODY$
LANGUAGE plpgsql IMMUTABLE;

ALTER FUNCTION ms_syst_priv.nonstandard_decode(p_base integer, p_tokens text, p_value text)
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION
    ms_syst_priv.nonstandard_decode(p_base integer, p_tokens text, p_value text) FROM public;

GRANT EXECUTE ON FUNCTION
    ms_syst_priv.nonstandard_decode(p_base integer, p_tokens text, p_value text)
    TO <%= ms_owner %>;

COMMENT ON
    FUNCTION ms_syst_priv.nonstandard_decode(p_base integer, p_tokens text, p_value text) IS
$DOC$Performs a decode operation, similar to the standard decode function, but for
non-standard decoding schemes, such as Base32 or Base36.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst_priv.encode_base32(p_value bigint)
RETURNS text AS
$BODY$

-- File:        encode_base32.eex.sql
-- Location:    musebms/database/all/ms_syst_priv/functions/encode_base32.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

    SELECT
        ms_syst_priv.nonstandard_encode(32, '0123456789ABCDEFGHJKMNPQRSTVWXYZ', p_value);

$BODY$
LANGUAGE sql IMMUTABLE;

ALTER FUNCTION ms_syst_priv.encode_base32(p_value bigint)
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_priv.encode_base32(p_value bigint) FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_priv.encode_base32(p_value bigint) TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst_priv.encode_base32(p_value bigint) IS
$DOC$Encodes a big integer value into Base32 representation.  The representation here
is that designed by Douglas Crockford (https://www.crockford.com/base32.html).$DOC$;
CREATE OR REPLACE FUNCTION ms_syst_priv.encode_base36(p_value bigint)
RETURNS text AS
$BODY$

-- File:        encode_base36.eex.sql
-- Location:    musebms/database/all/ms_syst_priv/functions/encode_base36.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

    SELECT
        ms_syst_priv.nonstandard_encode(36, '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ', p_value);

$BODY$
LANGUAGE sql IMMUTABLE;

ALTER FUNCTION ms_syst_priv.encode_base36(p_value bigint)
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_priv.encode_base36(p_value bigint) FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_priv.encode_base36(p_value bigint) TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst_priv.encode_base36(p_value bigint) IS
$DOC$Encodes a big integer value into Base36 representation.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst_priv.decode_base32(p_value text)
RETURNS bigint AS
$BODY$

-- File:        decode_base32.eex.sql
-- Location:    musebms/database/all/ms_syst_priv/functions/decode_base32.eex.sql
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
    var_resolved_value text :=
        upper(
            regexp_replace(
                regexp_replace( p_value, '[il]', '1', 'ig' ),
                'o', '0', 'ig' ));
BEGIN

    RETURN
        (SELECT
             ms_syst_priv.nonstandard_decode(
                 p_base   => 32,
                 p_tokens => '0123456789ABCDEFGHJKMNPQRSTVWXYZ',
                 P_value  => var_resolved_value));

END;
$BODY$
LANGUAGE plpgsql IMMUTABLE;

ALTER FUNCTION ms_syst_priv.decode_base32(p_value text)
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_priv.decode_base32(p_value text) FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_priv.decode_base32(p_value text) TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst_priv.decode_base32(p_value text) IS
$DOC$Decodes integers represented in Base32.  The representation here
is that designed by Douglas Crockford (https://www.crockford.com/base32.html).$DOC$;
CREATE OR REPLACE FUNCTION ms_syst_priv.decode_base36(p_value text)
RETURNS bigint AS
$BODY$

-- File:        decode_base36.eex.sql
-- Location:    musebms/database/all/ms_syst_priv/functions/decode_base36.eex.sql
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
    var_resolved_value text := upper(p_value);
BEGIN

    RETURN
        (SELECT
             ms_syst_priv.nonstandard_decode(
                 p_base   => 36,
                 p_tokens => '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ',
                 P_value  => var_resolved_value));

END;
$BODY$
LANGUAGE plpgsql IMMUTABLE;

ALTER FUNCTION ms_syst_priv.decode_base36(p_value text)
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_priv.decode_base36(p_value text) FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_priv.decode_base36(p_value text) TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst_priv.decode_base36(p_value text) IS
$DOC$Decodes integers represented in Base36 notation.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst_priv.get_random_string(
                                  p_length integer
                                , p_tokens text DEFAULT '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ' )
RETURNS text AS
$BODY$

-- File:        get_random_string.eex.sql
-- Location:    musebms/database/all/ms_syst_priv/functions/get_random_string.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

-- TODO: PostgreSQL's random function is not a cryptographically secure
--       source of randomness.  That's probably OK here, but we do expect
--       this function to be used to generate ID's so I'm not 100%
--       confident that OK.

SELECT
    string_agg(
        ( string_to_array( p_tokens, NULL ) )[round( ( length( p_tokens ) - 1 ) * random( ) ) + 1],
        '' )
FROM generate_series( 1, p_length );

$BODY$
LANGUAGE sql VOLATILE;

ALTER FUNCTION ms_syst_priv.get_random_string(p_length integer, p_tokens text)
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION
    ms_syst_priv.get_random_string(p_length integer, p_tokens text) FROM public;

GRANT EXECUTE ON FUNCTION
    ms_syst_priv.get_random_string(p_length integer, p_tokens text) TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst_priv.get_random_string(p_length integer, p_tokens text) IS
$DOC$Returns a random text string, by default consisting of alpha-numeric symbols, of
the requested length. Arbitrary characters may be provided my the caller.$DOC$;
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
-- File:        syst_settings.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_settings/ms_syst_data/syst_settings/syst_settings.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_settings
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_settings_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_settings_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_settings_display_name_udx UNIQUE
    ,syst_defined
        boolean
        NOT NULL DEFAULT FALSE
    ,syst_description
        text
        NOT NULL
    ,user_description
        text
    ,setting_flag
        boolean
    ,setting_integer
        bigint
    ,setting_integer_range
        int8range
    ,setting_decimal
        numeric
    ,setting_decimal_range
        numrange
    ,setting_interval
        interval
    ,setting_date
        date
    ,setting_date_range
        daterange
    ,setting_time
        time
    ,setting_timestamp
        timestamptz
    ,setting_timestamp_range
        tstzrange
    ,setting_json
        jsonb
    ,setting_text
        text
    ,setting_uuid
        uuid
    ,setting_blob
        bytea
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
        NOT NULL
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
        NOT NULL
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
);

ALTER TABLE ms_syst_data.syst_settings OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_settings FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_settings TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_settings
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE ms_syst_data.syst_settings IS
$DOC$Configuration data which establishes application behaviors, defaults, and
provides a reference center to interested application functionality.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_settings.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_settings.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_settings.display_name IS
$DOC$A friendly name and candidate key for the record suitable for use in user
interfaces.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_settings.syst_defined IS
$DOC$When true, indicates that the setting was created as part of the system and is
expected to exist.  If false, the setting is user created and maintained.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_settings.syst_description IS
$DOC$A text describing the meaning and use of the specific record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_settings.user_description IS
$DOC$A user customizable override of the system description text.  When the value in
this column is not NULL, this text will be displayed to users in preference to
the description found in syst_description.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_settings.setting_flag IS
$DOC$A boolean configuration point.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_settings.setting_integer IS
$DOC$An integer configuration point$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_settings.setting_integer_range IS
$DOC$An integer range configuration point.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_settings.setting_decimal IS
$DOC$An decimal configuration point (not floating point).$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_settings.setting_decimal_range IS
$DOC$A decimal range configuration point.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_settings.setting_interval IS
$DOC$An interval configuration point.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_settings.setting_date IS
$DOC$A date configuation point.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_settings.setting_date_range IS
$DOC$A date range configuration point.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_settings.setting_time IS
$DOC$A time configuration point (without time zone).$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_settings.setting_timestamp IS
$DOC$A full datetime configuration point including time zone.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_settings.setting_timestamp_range IS
$DOC$A range of timestamps with time zone configuration points.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_settings.setting_json IS
$DOC$A JSON configuration point.  Note that duplicate keys at the same level are not
allowed.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_settings.setting_text IS
$DOC$A text configuration point.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_settings.setting_uuid IS
$DOC$A UUID configuration point.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_settings.setting_blob IS
$DOC$A binary configuration point.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_settings.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_settings.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_settings.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_settings.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_settings.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_settings.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_settings.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_i_syst_settings()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_settings.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_settings/ms_syst/api_views/syst_settings/trig_i_i_syst_settings.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

BEGIN

    INSERT INTO ms_syst_data.syst_settings
        ( internal_name
        , display_name
        , syst_defined
        , syst_description
        , user_description
        , setting_flag
        , setting_integer
        , setting_integer_range
        , setting_decimal
        , setting_decimal_range
        , setting_interval
        , setting_date
        , setting_date_range
        , setting_time
        , setting_timestamp
        , setting_timestamp_range
        , setting_json
        , setting_text
        , setting_uuid
        , setting_blob )
    VALUES
        ( new.internal_name
        , new.display_name
        , FALSE
        , '(System Description Not Available)'
        , new.user_description
        , new.setting_flag
        , new.setting_integer
        , new.setting_integer_range
        , new.setting_decimal
        , new.setting_decimal_range
        , new.setting_interval
        , new.setting_date
        , new.setting_date_range
        , new.setting_time
        , new.setting_timestamp
        , new.setting_timestamp_range
        , new.setting_json
        , new.setting_text
        , new.setting_uuid
        , new.setting_blob )
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$ LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

ALTER FUNCTION ms_syst.trig_i_i_syst_settings() OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_settings() FROM PUBLIC;

COMMENT ON
    FUNCTION ms_syst.trig_i_i_syst_settings() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_settings API View for INSERT operations.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_u_syst_settings()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_settings.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_settings/ms_syst/api_views/syst_settings/trig_i_u_syst_settings.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

BEGIN

    IF old.syst_defined AND new.internal_name != old.internal_name THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'The requested data update included changes to fields disallowed ' ||
                          'by the business rules of the API View.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst'
                            ,p_proc_name      => 'trig_i_u_syst_settings'
                            ,p_exception_name => 'invalid_api_view_call'
                            ,p_errcode        => 'PM008'
                            ,p_param_data     => to_jsonb(new)
                            ,p_context_data   =>
                                jsonb_build_object(
                                     'tg_op',         tg_op
                                    ,'tg_when',       tg_when
                                    ,'tg_schema',     tg_table_schema
                                    ,'tg_table_name', tg_table_name)),
                ERRCODE = 'PM008',
                SCHEMA = tg_table_schema,
                TABLE = tg_table_name;
    END IF;

    UPDATE ms_syst_data.syst_settings SET
          internal_name           = new.internal_name
        , display_name            = new.display_name
        , user_description        = new.user_description
        , setting_flag            = new.setting_flag
        , setting_integer         = new.setting_integer
        , setting_integer_range   = new.setting_integer_range
        , setting_decimal         = new.setting_decimal
        , setting_decimal_range   = new.setting_decimal_range
        , setting_interval        = new.setting_interval
        , setting_date            = new.setting_date
        , setting_date_range      = new.setting_date_range
        , setting_time            = new.setting_time
        , setting_timestamp       = new.setting_timestamp
        , setting_timestamp_range = new.setting_timestamp_range
        , setting_json            = new.setting_json
        , setting_text            = new.setting_text
        , setting_uuid            = new.setting_uuid
        , setting_blob            = new.setting_blob
    WHERE id = new.id
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$ LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

ALTER FUNCTION ms_syst.trig_i_u_syst_settings() OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_settings() FROM PUBLIC;

COMMENT ON
    FUNCTION ms_syst.trig_i_u_syst_settings() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_settings API View for UPDATE operations.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_d_syst_settings()
RETURNS trigger AS
$BODY$

-- File:        trig_i_d_syst_settings.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_settings/ms_syst/api_views/syst_settings/trig_i_d_syst_settings.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

BEGIN

    IF old.syst_defined THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'You cannot delete a system defined setting using the API Views.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst'
                            ,p_proc_name      => 'trig_i_d_syst_settings'
                            ,p_exception_name => 'invalid_api_view_call'
                            ,p_errcode        => 'PM008'
                            ,p_param_data     => to_jsonb(old)
                            ,p_context_data   =>
                                jsonb_build_object(
                                     'tg_op',         tg_op
                                    ,'tg_when',       tg_when
                                    ,'tg_schema',     tg_table_schema
                                    ,'tg_table_name', tg_table_name)),
                ERRCODE = 'PM008',
                SCHEMA = tg_table_schema,
                TABLE = tg_table_name;
    END IF;

    DELETE FROM ms_syst_data.syst_settings WHERE id = old.id RETURNING * INTO old;

    RETURN old;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_d_syst_settings() OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_settings() FROM PUBLIC;

COMMENT ON
    FUNCTION ms_syst.trig_i_d_syst_settings() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_settings API View for DELETE operations.$DOC$;
-- File:        syst_settings.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_settings/ms_syst/api_views/syst_settings/syst_settings.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE VIEW ms_syst.syst_settings AS
    SELECT
        id
      , internal_name
      , display_name
      , syst_defined
      , syst_description
      , user_description
      , setting_flag
      , setting_integer
      , setting_integer_range
      , setting_decimal
      , setting_decimal_range
      , setting_interval
      , setting_date
      , setting_date_range
      , setting_time
      , setting_timestamp
      , setting_timestamp_range
      , setting_json
      , setting_text
      , setting_uuid
      , setting_blob
      , diag_timestamp_created
      , diag_role_created
      , diag_timestamp_modified
      , diag_wallclock_modified
      , diag_role_modified
      , diag_row_version
      , diag_update_count
    FROM ms_syst_data.syst_settings;

ALTER VIEW ms_syst.syst_settings OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_settings FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_settings
    INSTEAD OF INSERT ON ms_syst.syst_settings
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_settings();

CREATE TRIGGER a50_trig_i_u_syst_settings
    INSTEAD OF UPDATE ON ms_syst.syst_settings
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_settings();

CREATE TRIGGER a50_trig_i_d_syst_settings
    INSTEAD OF DELETE ON ms_syst.syst_settings
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_settings();

COMMENT ON
    VIEW ms_syst.syst_settings IS
$DOC$Configuration data which establishes application behaviors, defaults, and
provides a reference center to interested application functionality.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_settings.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_settings.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_settings.display_name IS
$DOC$A friendly name and candidate key for the record suitable for use in user
interfaces.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_settings.syst_defined IS
$DOC$When true, indicates that the setting was created as part of the system and is
expected to exist.  If false, the setting is user created and maintained.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_settings.syst_description IS
$DOC$A text describing the meaning and use of the specific record.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_settings.user_description IS
$DOC$A user customizable override of the system description text.  When the value in
this column is not NULL, this text will be displayed to users in preference to
the description found in syst_description.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_settings.setting_flag IS
$DOC$A boolean configuration point.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_settings.setting_integer IS
$DOC$An integer configuration point$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_settings.setting_integer_range IS
$DOC$An integer range configuration point.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_settings.setting_decimal IS
$DOC$An decimal configuration point (not floating point).$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_settings.setting_decimal_range IS
$DOC$A decimal range configuration point.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_settings.setting_interval IS
$DOC$An interval configuration point.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_settings.setting_date IS
$DOC$A date configuation point.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_settings.setting_date_range IS
$DOC$A date range configuration point.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_settings.setting_time IS
$DOC$A time configuration point (without time zone).$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_settings.setting_timestamp IS
$DOC$A full datetime configuration point including time zone.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_settings.setting_timestamp_range IS
$DOC$A range of timestamps with time zone configuration points.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_settings.setting_json IS
$DOC$A JSON configuration point.  Note that duplicate keys at the same level are not
allowed.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_settings.setting_text IS
$DOC$A text configuration point.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_settings.setting_uuid IS
$DOC$A UUID configuration point.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_settings.setting_blob IS
$DOC$A binary configuration point.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_settings.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_settings.diag_role_created IS
$DOC$The database role which created the record.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_settings.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_settings.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_settings.diag_role_modified IS
$DOC$The database role which modified the record.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_settings.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_settings.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.

Note that this column may not be updated via this API View.$DOC$;
-- File:        privileges.eex.sql
-- Location:    musebms/database/application/msbms/components/mscmp_syst_settings/privileges.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_settings TO <%= ms_appusr %>;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_settings TO <%= ms_apiusr %>;

GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_settings() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_settings() TO <%= ms_apiusr %>;

GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_settings() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_settings() TO <%= ms_apiusr %>;

GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_settings() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_settings() TO <%= ms_apiusr %>;
-- File:        syst_enums.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_enums/ms_syst_data/syst_enums/syst_enums.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_enums
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_enums_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_enums_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_enums_display_name_udx UNIQUE
    ,syst_description
        text
        NOT NULL
    ,user_description
        text
    ,syst_defined
        boolean
        NOT NULL DEFAULT FALSE
    ,user_maintainable
        boolean
        NOT NULL DEFAULT TRUE
    ,default_syst_options
        jsonb
    ,default_user_options
        jsonb
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
        NOT NULL
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
        NOT NULL
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
);

ALTER TABLE ms_syst_data.syst_enums OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_enums FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_enums TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_enums
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE ms_syst_data.syst_enums IS
$DOC$Enumerates the enumerations known to the system along with additional metadata
useful in applying them appropriately.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enums.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enums.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enums.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enums.syst_description IS
$DOC$A default description of the enumeration which might include details such as how
the enumeration is used and what kind of functionality might be impacted by
choosing specific enumeration values.

Note that users should not change this value.  For custom descriptions, use the
ms_syst_data.syst_enums.user_description field instead.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enums.user_description IS
$DOC$A user defined description of the enumeration to support custom user
documentation of the purpose and function of the enumeration.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enums.syst_defined IS
$DOC$If true, this value indicates that the enumeration is considered part of the
application.  Often times, system enumerations are manageable by users, but the
existence of the enumeration in the system is assumed to exist by the
application.  If false, the assumption is that the enumeration was created by
users and supports custom user functionality.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enums.user_maintainable IS
$DOC$When true, this column indicates that the enumeration is user maintainable;
this might include the ability to add, edit, or remove enumeration values.  When
false, the enumeration is strictly system managed for any functional purpose.
Note that the value of this column doesn't effect the ability to set a
user_description value; the ability to set custom descriptions is always
available for any properly authorized user.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enums.default_syst_options IS
$DOC$Establishes the expected extended system options along with default values if
applicable.  Note that this setting is used to both validate
and set defaults in the syst_enum_items.syst_options column.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enums.default_user_options IS
$DOC$Allows a user to set the definition of syst_enum_items.user_options values and
provide defaults for those values if appropriate.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enums.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enums.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enums.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enums.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enums.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enums.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enums.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst_data.trig_b_i_syst_enum_functional_type_validate_new_allowed()
RETURNS trigger AS
$BODY$

-- File:        trig_b_i_syst_enum_functional_type_validate_new_allowed.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_enums/ms_syst_data/syst_enum_functional_types/trig_b_i_syst_enum_functional_type_validate_new_allowed.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

BEGIN

    IF
        NOT EXISTS(SELECT TRUE
                    FROM ms_syst_data.syst_enum_functional_types
                    WHERE enum_id = new.enum_id) AND
        EXISTS(
                SELECT TRUE
                FROM ms_syst_data.syst_enum_items
                WHERE enum_id = new.enum_id
            )
    THEN

        RAISE EXCEPTION
            USING
                MESSAGE = 'You cannot add a functional type requirement after enumeration item ' ||
                          'records have already been defined.',
                DETAIL  = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst_data'
                            ,p_proc_name      => 'trig_b_i_syst_enum_functional_type_validate_new_allowed'
                            ,p_exception_name => 'invalid_functional_type'
                            ,p_errcode        => 'PM003'
                            ,p_param_data     => to_jsonb(new)
                            ,p_context_data   =>
                                jsonb_build_object(
                                     'tg_op',         tg_op
                                    ,'tg_when',       tg_when
                                    ,'tg_schema',     tg_table_schema
                                    ,'tg_table_name', tg_table_name)),
                ERRCODE = 'PM003',
                SCHEMA  = tg_table_schema,
                TABLE   = tg_table_name;

    END IF;

    RETURN new;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION ms_syst_data.trig_b_i_syst_enum_functional_type_validate_new_allowed()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_data.trig_b_i_syst_enum_functional_type_validate_new_allowed() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_data.trig_b_i_syst_enum_functional_type_validate_new_allowed() TO <%= ms_owner %>;


COMMENT ON FUNCTION ms_syst_data.trig_b_i_syst_enum_functional_type_validate_new_allowed() IS
$DOC$Checks to see if this is the first functional type being added for the
enumeration and, if so, that no syst_enum_items records already exist.  Adding a
first functional type for an enumeration which already has defined enumeration
items implies that the enumeration items must be assigned a functional type in
the same operation to keep data consistency.  In practice, this would be
difficult since there would almost certainly have to be multiple functional
types available in order to avoid making bogus assignments; it would be much
more difficult to manage such a process as compared to simply disallowing the
scenario.$DOC$;
-- File:        syst_enum_functional_types.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_enums/ms_syst_data/syst_enum_functional_types/syst_enum_functional_types.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_enum_functional_types
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_enum_functional_types_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_enum_functional_types_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_enum_functional_types_display_name_udx UNIQUE
    ,external_name
        text
        NOT NULL
    ,enum_id
        uuid
        NOT NULL
        CONSTRAINT syst_enum_functional_types_enum_fk
            REFERENCES ms_syst_data.syst_enums (id) ON DELETE CASCADE
    ,syst_description
        text
        NOT NULL
    ,user_description
        text
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
        NOT NULL
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
        NOT NULL
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
);

ALTER TABLE ms_syst_data.syst_enum_functional_types OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_enum_functional_types FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_enum_functional_types TO <%= ms_owner %>;

CREATE TRIGGER a10_trig_b_i_syst_enum_functional_type_validate_new_allowed
    BEFORE INSERT ON ms_syst_data.syst_enum_functional_types
    FOR EACH ROW
    EXECUTE PROCEDURE ms_syst_data.trig_b_i_syst_enum_functional_type_validate_new_allowed( );

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_enum_functional_types
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE ms_syst_data.syst_enum_functional_types IS
$DOC$For those enumerations requiring functional type designation, this table defines
the available types and persists related metadata.  Note that not all
enumerations require functional types.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enum_functional_types.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enum_functional_types.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enum_functional_types.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enum_functional_types.external_name IS
$DOC$A non-unique/non-key value used to display to users and external parties where
uniqueness is less of a concern than specific end user presentation.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enum_functional_types.enum_id IS
$DOC$A reference to the owning enumeration of the functional type.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enum_functional_types.syst_description IS
$DOC$A default description of the specific functional type and its use cases within
the enumeration which is identitied as the parent.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enum_functional_types.user_description IS
$DOC$A custom, user suppplied description of the functional type which will be
preferred over the syst_description field if set to a not null value.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enum_functional_types.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enum_functional_types.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enum_functional_types.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enum_functional_types.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enum_functional_types.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enum_functional_types.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enum_functional_types.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst_data.trig_b_i_syst_enum_items_maintain_sort_order()
RETURNS trigger AS
$BODY$

-- File:        trig_b_i_syst_enum_items_maintain_sort_order.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_enums/ms_syst_data/syst_enum_items/trig_b_i_syst_enum_items_maintain_sort_order.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

BEGIN

    new.sort_order :=
        coalesce(
            new.sort_order,
            ( SELECT max( sort_order ) + 1
              FROM ms_syst_data.syst_enum_items
              WHERE enum_id = new.enum_id ),
            1 );

    RETURN new;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION ms_syst_data.trig_b_i_syst_enum_items_maintain_sort_order()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_data.trig_b_i_syst_enum_items_maintain_sort_order() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_data.trig_b_i_syst_enum_items_maintain_sort_order() TO <%= ms_owner %>;


COMMENT ON FUNCTION ms_syst_data.trig_b_i_syst_enum_items_maintain_sort_order() IS
$DOC$For INSERTed records with a null sort_order value, this trigger will assign a
default value assuming the new record should be inserted at the end of the sort.

If the inserted record was already assigned a sort_order value, the inserted
value is respected.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst_data.trig_b_iu_syst_enum_items_validate_functional_types()
RETURNS trigger AS
$BODY$

-- File:        trig_b_iu_syst_enum_items_validate_functional_types.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_enums/ms_syst_data/syst_enum_items/trig_b_iu_syst_enum_items_validate_functional_types.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

BEGIN

    IF
        EXISTS( SELECT TRUE
                FROM ms_syst_data.syst_enum_functional_types seft
                WHERE   seft.enum_id = new.enum_id) AND
        NOT EXISTS( SELECT TRUE
                    FROM ms_syst_data.syst_enum_functional_types seft
                    WHERE   seft.id = new.functional_type_id
                        AND seft.enum_id = new.enum_id)
    THEN

        RAISE EXCEPTION
            USING
                MESSAGE = 'The enumeration requires a valid functional type to be specified.',
                DETAIL  = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst_data'
                            ,p_proc_name      => 'trig_b_iu_syst_enum_items_validate_functional_types'
                            ,p_exception_name => 'invalid_functional_type'
                            ,p_errcode        => 'PM003'
                            ,p_param_data     => to_jsonb(new)
                            ,p_context_data   =>
                                jsonb_build_object(
                                     'tg_op',         tg_op
                                    ,'tg_when',       tg_when
                                    ,'tg_schema',     tg_table_schema
                                    ,'tg_table_name', tg_table_name)),
                ERRCODE = 'PM003',
                SCHEMA  = tg_table_schema,
                TABLE   = tg_table_name;

    END IF;

    RETURN new;
END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION ms_syst_data.trig_b_iu_syst_enum_items_validate_functional_types()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_data.trig_b_iu_syst_enum_items_validate_functional_types() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_data.trig_b_iu_syst_enum_items_validate_functional_types() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst_data.trig_b_iu_syst_enum_items_validate_functional_types() IS
$DOC$Ensures that if the parent syst_enums record has syst_enum_functional_types
records defined, a syst_enum_items record will reference one of those
functional types.  Note that this trigger function is intended to be use by
constraint triggers.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst_data.trig_a_iu_syst_enum_items_maintain_sort_order()
RETURNS trigger AS
$BODY$

-- File:        trig_a_iu_syst_enum_items_maintain_sort_order.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_enums/ms_syst_data/syst_enum_items/trig_a_iu_syst_enum_items_maintain_sort_order.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

BEGIN

    UPDATE ms_syst_data.syst_enum_items
    SET sort_order = sort_order + 1
    WHERE enum_id = new.enum_id AND sort_order = new.sort_order AND id != new.id;

    RETURN NULL;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION ms_syst_data.trig_a_iu_syst_enum_items_maintain_sort_order()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_data.trig_a_iu_syst_enum_items_maintain_sort_order() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_data.trig_a_iu_syst_enum_items_maintain_sort_order() TO <%= ms_owner %>;


COMMENT ON FUNCTION ms_syst_data.trig_a_iu_syst_enum_items_maintain_sort_order() IS
$DOC$Automatically maintains the sort order of syst_enum_item records in cases where
sort ordering collides with existing syst_enum_items records for the same
enum_id.  On insert or update when the new sort_order value matches that of an
existing record for the enumeration, the system will sort the match record after
the new/updated record. This will cascade for all syst_enum_items records
matching the enum_id until the last one is updated.$DOC$;
-- File:        syst_enum_items.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_enums/ms_syst_data/syst_enum_items/syst_enum_items.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_enum_items
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_enum_items_pk PRIMARY KEY
    ,internal_name
        text COLLATE ms_syst_priv.variant_insensitive
        NOT NULL
        CONSTRAINT syst_enum_items_internal_name_udx UNIQUE
    ,display_name
        text COLLATE ms_syst_priv.variant_insensitive
        NOT NULL
        CONSTRAINT syst_enum_items_display_name_udx UNIQUE
    ,external_name
        text
        NOT NULL
    ,enum_id
        uuid
        NOT NULL
        CONSTRAINT syst_enum_items_enum_fk
            REFERENCES ms_syst_data.syst_enums (id) ON DELETE CASCADE
    ,functional_type_id
        uuid
        CONSTRAINT syst_enum_items_enum_functional_type_fk
            REFERENCES ms_syst_data.syst_enum_functional_types (id)
    ,enum_default
        boolean
        NOT NULL DEFAULT FALSE
    ,functional_type_default
        boolean
        NOT NULL DEFAULT FALSE
    ,syst_defined
        boolean
        NOT NULL DEFAULT FALSE
    ,user_maintainable
        boolean
        NOT NULL DEFAULT TRUE
    ,syst_description
        text
        NOT NULL
    ,user_description
        text
    ,sort_order
        integer
        NOT NULL
    ,syst_options
        jsonb
    ,user_options
        jsonb
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
        NOT NULL
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
        NOT NULL
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
);

ALTER TABLE ms_syst_data.syst_enum_items OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_enum_items FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_enum_items TO <%= ms_owner %>;

CREATE TRIGGER b50_trig_b_i_syst_enum_items_maintain_sort_order
    BEFORE INSERT
    ON ms_syst_data.syst_enum_items
    FOR EACH ROW
EXECUTE PROCEDURE ms_syst_data.trig_b_i_syst_enum_items_maintain_sort_order( );

CREATE TRIGGER c50_trig_b_i_syst_enum_items_validate_functional_type
    BEFORE INSERT
    ON ms_syst_data.syst_enum_items
    FOR EACH ROW
EXECUTE PROCEDURE ms_syst_data.trig_b_iu_syst_enum_items_validate_functional_types( );

CREATE TRIGGER c50_trig_b_u_syst_enum_items_validate_functional_type
    BEFORE UPDATE
    ON ms_syst_data.syst_enum_items
    FOR EACH ROW
    WHEN ( old.functional_type_id IS DISTINCT FROM new.functional_type_id )
EXECUTE PROCEDURE ms_syst_data.trig_b_iu_syst_enum_items_validate_functional_types( );

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE
    ON ms_syst_data.syst_enum_items
    FOR EACH ROW
EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns( );

CREATE TRIGGER b55_trig_a_iu_syst_enum_items_maintain_sort_order
    AFTER INSERT
    ON ms_syst_data.syst_enum_items
    FOR EACH ROW
EXECUTE PROCEDURE ms_syst_data.trig_a_iu_syst_enum_items_maintain_sort_order( );

COMMENT ON
    TABLE ms_syst_data.syst_enum_items IS
$DOC$The list of values provided by an enumeration as well as related behavioral and
informational metadata.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enum_items.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enum_items.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enum_items.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enum_items.external_name IS
$DOC$A non-unique/non-key value used to display to users and external parties where
uniqueness is less of a concern than specific end user presentation.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enum_items.enum_id IS
$DOC$The enumeration record with which the value is associated.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enum_items.functional_type_id IS
$DOC$If the enumeration requires a functional type, this column references the
functional type associated with the enumeration value record.  Note that not all
enumerations require functional types.  If syst_enum_functional_types records
exist for an enumeration, then this column will be required for any values of
that enumeration; if there are no functional types defined for an enumeration,
the this column must remain NULL.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enum_items.enum_default IS
$DOC$If true, indicates that this value is the default selection from all values
defined for the enumerations.  If false then the value record has no special
significance relative to defaulting.

Note that if a record is inserted or updated in this table with enum_default set
true, and another record already exists for the enumeration with its
enum_default set true, the newly inserted/updated record will take precedence
and the value record previously set to be default will have its enum_default
setting set to false.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enum_items.functional_type_default IS
$DOC$If true, the value record is the default selection for any of a specific
fucntional type.  This is helpful in situations where a progression of state is
automatically processed by the system and the state is represented by an
enumeration.  In cases where there are no functional types, this value should
simply remain false.

Note that if a record is inserted or updated in this table with its
functional_type_default set true, and another record already exists for the
enumeration/functional type combination with its functional_type_default set
true, the newly inserted/updated record will take precedence and the value
record previously set to be default will have its functional_type_default
setting set to false.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enum_items.syst_defined IS
$DOC$If true, indicates that the value was created by the system or system
installation process.  A false value indicates that the record was user created.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enum_items.user_maintainable IS
$DOC$If true, the user may maintain the value including setting user_options or
even setting the record inactive/deleting it.  If false, the value record is
required by the system for correct operation.  The user_description and
user_options columns are always available for user maintenance regardless of
this setting.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enum_items.syst_description IS
$DOC$A system default description describing the value and its use cases within the
enumeration.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enum_items.user_description IS
$DOC$A custom user defined description which overrides the syst_description value
where it would otherwise be used.  If this column is set NULL the
syst_description value will be used.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enum_items.sort_order IS
$DOC$Indicates the sort ordering of the particular value record with the lowest value
sorting first.  When a value record for an enumeration is inserted or updated
and this column is being set to a value which equals another enumeration value
record for the same enumeration, the system assumes that the new record is
being set to precede the existing record and it will be set to sort after the
newly inserted/updated enumeration value.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enum_items.syst_options IS
$DOC$Extended options and metadata which describe the behavior and meaning of the
specific value within the enumeration.  The owning
syst_enums record's default_syst_options column will indicate what syst_options
are required or available and establishes default values for them.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enum_items.user_options IS
$DOC$Extended user defined options, similar to syst_options, but for the purpose of
driving custom functionality.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enum_items.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enum_items.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enum_items.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enum_items.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enum_items.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enum_items.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_enum_items.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst_priv.initialize_enum(p_enum_def jsonb)
RETURNS void AS
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
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION ms_syst_priv.initialize_enum(p_enum_def jsonb)
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_priv.initialize_enum(p_enum_def jsonb) FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_priv.initialize_enum(p_enum_def jsonb) TO <%= ms_owner %>;


COMMENT ON FUNCTION ms_syst_priv.initialize_enum(p_enum_def jsonb) IS
$DOC$Based on a specially formatted JSON object passed as a parameter, this function
will create a new enumeration along with its optional functional types and
starting value records.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst_priv.trig_a_iu_enum_item_check()
RETURNS trigger AS
$BODY$

-- File:        trig_a_iu_enum_item_check.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_enums/ms_syst_priv/trigger_functions/trig_a_iu_enum_item_check.eex.sql
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
    var_enumeration_name   text COLLATE ms_syst_priv.variant_insensitive := tg_argv[0];
    var_enumeration_column text COLLATE ms_syst_priv.variant_insensitive := tg_argv[1];
    var_new_json           jsonb                                            := to_jsonb(NEW);

BEGIN

    IF NOT exists( SELECT
                       TRUE
                   FROM ms_syst_data.syst_enum_items cev
                   JOIN ms_syst_data.syst_enums ce ON ce.id = cev.enum_id
                   WHERE
                         ce.internal_name = var_enumeration_name
                     AND cev.id = ( var_new_json ->> var_enumeration_column )::uuid )
    THEN
        RAISE EXCEPTION
            USING
                MESSAGE =
                    format('The enumeration value %1$s was not for enumeration %2$s.'
                        ,( var_new_json ->> var_enumeration_column )::uuid
                        ,var_enumeration_name),
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst_priv'
                            ,p_proc_name      => 'trig_a_iu_enum_item_check'
                            ,p_exception_name => 'enum_item_not_found'
                            ,p_errcode        => 'PM003'
                            ,p_param_data     => to_jsonb(tg_argv)
                            ,p_context_data   =>
                                jsonb_build_object(
                                     'tg_op',         tg_op
                                    ,'tg_when',       tg_when
                                    ,'tg_schema',     tg_table_schema
                                    ,'tg_table_name', tg_table_name)),
                ERRCODE = 'PM003',
                SCHEMA = tg_table_schema,
                TABLE = tg_table_name;
    END IF;

    RETURN NULL;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst_priv.trig_a_iu_enum_item_check()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_priv.trig_a_iu_enum_item_check() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_priv.trig_a_iu_enum_item_check() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst_priv.trig_a_iu_enum_item_check() IS
$DOC$A constraint trigger function to provide foreign key like validation of columns
which reference syst_enum_items.  This relationship requires the additional
check that only values from the desired enumeration are used in assigning to
records.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_i_syst_enums()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_enums.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_enums/ms_syst/api_views/syst_enums/trig_i_i_syst_enums.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

BEGIN

    INSERT INTO ms_syst_data.syst_enums
        ( internal_name
        , display_name
        , syst_description
        , user_description
        , syst_defined
        , user_maintainable
        , default_user_options )
    VALUES
        ( new.internal_name
        , new.display_name
        , '(System Description Not Available)'
        , new.user_description
        , FALSE
        , TRUE
        , new.default_user_options )
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_i_syst_enums()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_enums() FROM public;

COMMENT ON FUNCTION ms_syst.trig_i_i_syst_enums() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_enums API View for INSERT operations.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_u_syst_enums()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_enums.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_enums/ms_syst/api_views/syst_enums/trig_i_u_syst_enums.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

BEGIN

    IF old.syst_defined AND new.internal_name != old.internal_name THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'The requested data update included changes to fields disallowed ' ||
                          'by the business rules of the API View.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst'
                            ,p_proc_name      => 'trig_i_u_syst_enums'
                            ,p_exception_name => 'invalid_api_view_call'
                            ,p_errcode        => 'PM008'
                            ,p_param_data     => to_jsonb(new)
                            ,p_context_data   =>
                                jsonb_build_object(
                                     'tg_op',         tg_op
                                    ,'tg_when',       tg_when
                                    ,'tg_schema',     tg_table_schema
                                    ,'tg_table_name', tg_table_name)),
                ERRCODE = 'PM008',
                SCHEMA = tg_table_schema,
                TABLE = tg_table_name;
    END IF;

    UPDATE ms_syst_data.syst_enums SET
          internal_name        = new.internal_name
        , display_name         = new.display_name
        , user_description     = new.user_description
        , default_user_options = new.default_user_options
    WHERE id = new.id
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_u_syst_enums()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_enums() FROM public;

COMMENT ON FUNCTION ms_syst.trig_i_u_syst_enums() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_enums API View for UPDATE operations.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_d_syst_enums()
RETURNS trigger AS
$BODY$

-- File:        trig_i_d_syst_enums.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_enums/ms_syst/api_views/syst_enums/trig_i_d_syst_enums.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

BEGIN

    IF old.syst_defined THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'You cannot delete a system defined enumeration using the API Views.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst'
                            ,p_proc_name      => 'trig_i_d_syst_enums'
                            ,p_exception_name => 'invalid_api_view_call'
                            ,p_errcode        => 'PM008'
                            ,p_param_data     => to_jsonb(old)
                            ,p_context_data   =>
                                jsonb_build_object(
                                     'tg_op',         tg_op
                                    ,'tg_when',       tg_when
                                    ,'tg_schema',     tg_table_schema
                                    ,'tg_table_name', tg_table_name)),
                ERRCODE = 'PM008',
                SCHEMA = tg_table_schema,
                TABLE = tg_table_name;
    END IF;

    DELETE FROM ms_syst_data.syst_enums WHERE id = old.id RETURNING * INTO old;

    RETURN old;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_d_syst_enums()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_enums() FROM public;

COMMENT ON FUNCTION ms_syst.trig_i_d_syst_enums() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_enums API View for DELETE operations.$DOC$;
-- File:        syst_enums.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_enums/ms_syst/api_views/syst_enums/syst_enums.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE VIEW ms_syst.syst_enums AS
    SELECT
        id
      , internal_name
      , display_name
      , syst_description
      , user_description
      , syst_defined
      , user_maintainable
      , default_syst_options
      , default_user_options
      , diag_timestamp_created
      , diag_role_created
      , diag_timestamp_modified
      , diag_wallclock_modified
      , diag_role_modified
      , diag_row_version
      , diag_update_count
    FROM ms_syst_data.syst_enums;

ALTER VIEW ms_syst.syst_enums OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_enums FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_enums
    INSTEAD OF INSERT ON ms_syst.syst_enums
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_enums();

CREATE TRIGGER a50_trig_i_u_syst_enums
    INSTEAD OF UPDATE ON ms_syst.syst_enums
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_enums();

CREATE TRIGGER a50_trig_i_d_syst_enums
    INSTEAD OF DELETE ON ms_syst.syst_enums
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_enums();

COMMENT ON
    VIEW ms_syst.syst_enums IS
$DOC$Enumerates the enumerations known to the system along with additional metadata
useful in applying them appropriately.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enums.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enums.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enums.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enums.syst_description IS
$DOC$A default description of the enumeration which might include details such as how
the enumeration is used and what kind of functionality might be impacted by
choosing specific enumeration values.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enums.user_description IS
$DOC$A user defined description of the enumeration to support custom user
documentation of the purpose and function of the enumeration.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enums.syst_defined IS
$DOC$If true, this value indicates that the enumeration is considered part of the
application.  Often times, system enumerations are manageable by users, but the
existence of the enumeration in the system is assumed to exist by the
application.  If false, the assumption is that the enumeration was created by
users and supports custom user functionality.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enums.user_maintainable IS
$DOC$When true, this column indicates that the enumeration is user maintainable;
this might include the ability to add, edit, or remove enumeration values.  When
false, the enumeration is strictly system managed for any functional purpose.
Note that the value of this column doesn't effect the ability to set a
user_description value; the ability to set custom descriptions is always
available for any properly authorized user.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enums.default_syst_options IS
$DOC$Establishes the expected extended system options along with default values if
applicable.  Note that this setting is used to both validate
and set defaults in the syst_enum_items.syst_options column.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enums.default_user_options IS
$DOC$Allows a user to set the definition of syst_enum_items.user_options values and
provide defaults for those values if appropriate.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enums.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enums.diag_role_created IS
$DOC$The database role which created the record.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enums.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enums.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enums.diag_role_modified IS
$DOC$The database role which modified the record.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enums.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enums.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.

Note that this column may not be updated via this API View.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_i_syst_enum_functional_types()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_enum_functional_types.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_enums/ms_syst/api_views/syst_enum_functional_types/trig_i_i_syst_enum_functional_types.eex.sql
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
    var_syst_defined boolean;
BEGIN
    SELECT syst_defined INTO var_syst_defined
    FROM ms_syst_data.syst_enums
    WHERE id = new.enum_id;

    IF var_syst_defined THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'The functional type creation for the requested ' ||
                          'enumeration is invalid.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst'
                            ,p_proc_name      => 'trig_i_i_syst_enum_functional_types'
                            ,p_exception_name => 'invalid_api_view_call'
                            ,p_errcode        => 'PM008'
                            ,p_param_data     => to_jsonb(new)
                            ,p_context_data   =>
                                jsonb_build_object(
                                     'tg_op',         tg_op
                                    ,'tg_when',       tg_when
                                    ,'tg_schema',     tg_table_schema
                                    ,'tg_table_name', tg_table_name)),
                ERRCODE = 'PM008',
                SCHEMA = tg_table_schema,
                TABLE = tg_table_name;
    END IF;

    INSERT INTO ms_syst_data.syst_enum_functional_types
        (  internal_name
         , display_name
         , external_name
         , enum_id
         , syst_description
         , user_description)
    VALUES
        (  new.internal_name
         , new.display_name
         , new.external_name
         , new.enum_id
         , '(System Description Not Available)'
         , new.user_description)
    RETURNING INTO new
          id
        , internal_name
        , display_name
        , external_name
        , var_syst_defined
        , enum_id
        , syst_description
        , user_description
        , diag_timestamp_created
        , diag_role_created
        , diag_timestamp_modified
        , diag_wallclock_modified
        , diag_role_modified
        , diag_row_version
        , diag_update_count ;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_i_syst_enum_functional_types()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_enum_functional_types() FROM public;

COMMENT ON FUNCTION ms_syst.trig_i_i_syst_enum_functional_types() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_enum_functional_types API View for INSERT operations.

Note that the parent ms_syst_data.syst_enums.syst_defined determines whether
or not child ms_syst_data.syst_enum_functional_types records are considered
system defined.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_u_syst_enum_functional_types()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_enum_functional_types.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_enums/ms_syst/api_views/syst_enum_functional_types/trig_i_u_syst_enum_functional_types.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

BEGIN
    IF
        (old.syst_defined AND old.internal_name != new.internal_name) OR
        old.enum_id != new.enum_id
    THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'The requested data update included changes to fields disallowed ' ||
                          'by the business rules of the API View.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst'
                            ,p_proc_name      => 'trig_i_u_syst_enum_functional_types'
                            ,p_exception_name => 'invalid_api_view_call'
                            ,p_errcode        => 'PM008'
                            ,p_param_data     => to_jsonb(new)
                            ,p_context_data   =>
                                jsonb_build_object(
                                     'tg_op',         tg_op
                                    ,'tg_when',       tg_when
                                    ,'tg_schema',     tg_table_schema
                                    ,'tg_table_name', tg_table_name)),
                ERRCODE = 'PM008',
                SCHEMA = tg_table_schema,
                TABLE = tg_table_name;
    END IF;

    UPDATE ms_syst_data.syst_enum_functional_types
    SET
        internal_name    = new.internal_name
      , display_name     = new.display_name
      , external_name    = new.external_name
      , user_description = new.user_description
    WHERE id = new.id
    RETURNING INTO new
          id
        , internal_name
        , display_name
        , external_name
        , old.syst_defined
        , enum_id
        , syst_description
        , user_description
        , diag_timestamp_created
        , diag_role_created
        , diag_timestamp_modified
        , diag_wallclock_modified
        , diag_role_modified
        , diag_row_version
        , diag_update_count ;

    RAISE WARNING '======>>>>>>> New Func. Type: %', to_jsonb(new);

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_u_syst_enum_functional_types()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_enum_functional_types() FROM public;

COMMENT ON FUNCTION ms_syst.trig_i_u_syst_enum_functional_types() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_enum_functional_types API View for UPDATE operations.

Note that the parent ms_syst_data.syst_enums.syst_defined determines whether
or not child ms_syst_data.syst_enum_functional_types records are considered
system defined.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_d_syst_enum_functional_types()
RETURNS trigger AS
$BODY$

-- File:        trig_i_d_syst_enum_functional_types.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_enums/ms_syst/api_views/syst_enum_functional_types/trig_i_d_syst_enum_functional_types.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

BEGIN

    IF old.syst_defined THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'You cannot delete a system defined enumeration ' ||
                          'functional type using the API Views.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst'
                            ,p_proc_name      => 'trig_i_d_syst_enum_functional_types'
                            ,p_exception_name => 'invalid_api_view_call'
                            ,p_errcode        => 'PM008'
                            ,p_param_data     => to_jsonb(old)
                            ,p_context_data   =>
                                jsonb_build_object(
                                     'tg_op',         tg_op
                                    ,'tg_when',       tg_when
                                    ,'tg_schema',     tg_table_schema
                                    ,'tg_table_name', tg_table_name)),
                ERRCODE = 'PM008',
                SCHEMA = tg_table_schema,
                TABLE = tg_table_name;
    END IF;

    DELETE
    FROM ms_syst_data.syst_enum_functional_types
    WHERE id = old.id
    RETURNING INTO old
          id
        , internal_name
        , display_name
        , external_name
        , old.syst_defined
        , enum_id
        , syst_description
        , user_description
        , diag_timestamp_created
        , diag_role_created
        , diag_timestamp_modified
        , diag_wallclock_modified
        , diag_role_modified
        , diag_row_version
        , diag_update_count ;

    RETURN old;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_d_syst_enum_functional_types()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_enum_functional_types() FROM public;

COMMENT ON FUNCTION ms_syst.trig_i_d_syst_enum_functional_types() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_enum_functional_types API View for DELETE operations.$DOC$;
-- File:        syst_enum_functional_types.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_enums/ms_syst/api_views/syst_enum_functional_types/syst_enum_functional_types.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE VIEW ms_syst.syst_enum_functional_types AS
    SELECT
        seft.id
      , seft.internal_name
      , seft.display_name
      , seft.external_name
      , se.syst_defined
      , seft.enum_id
      , seft.syst_description
      , seft.user_description
      , seft.diag_timestamp_created
      , seft.diag_role_created
      , seft.diag_timestamp_modified
      , seft.diag_wallclock_modified
      , seft.diag_role_modified
      , seft.diag_row_version
      , seft.diag_update_count
    FROM ms_syst_data.syst_enum_functional_types seft
        JOIN ms_syst_data.syst_enums se
            ON se.id = seft.enum_id;

ALTER VIEW ms_syst.syst_enum_functional_types OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_enum_functional_types FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_enum_functional_types
    INSTEAD OF INSERT ON ms_syst.syst_enum_functional_types
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_enum_functional_types();

CREATE TRIGGER a50_trig_i_u_syst_enum_functional_types
    INSTEAD OF UPDATE ON ms_syst.syst_enum_functional_types
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_enum_functional_types();

CREATE TRIGGER a50_trig_i_d_syst_enum_functional_types
    INSTEAD OF DELETE ON ms_syst.syst_enum_functional_types
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_enum_functional_types();

COMMENT ON
    VIEW ms_syst.syst_enum_functional_types IS
$DOC$For those enumerations requiring functional type designation, this table defines
the available types and persists related metadata.  Note that not all
enumerations require functional types.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_functional_types.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_functional_types.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_functional_types.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_functional_types.external_name IS
$DOC$A non-unique/non-key value used to display to users and external parties where
uniqueness is less of a concern than specific end user presentation.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_functional_types.syst_defined IS
$DOC$If true, this value indicates that the functional type is considered to be
system defined and a part of the application.  This column is not part of the
functional type underlying data and is a reflect of the functional type's parent
enumeration since the parent determines if the functional type is considered
system defined.  If false, the assumption is that the functional type is user
defined and supports custom user functionality.

See the documentation for ms_syst.syst_enums.syst_defined for a more complete
complete description.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_functional_types.enum_id IS
$DOC$A reference to the owning enumeration of the functional type.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_functional_types.syst_description IS
$DOC$A default description of the specific functional type and its use cases within
the enumeration which is identitied as the parent.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_functional_types.user_description IS
$DOC$A custom, user suppplied description of the functional type which will be
preferred over the syst_description field if set to a not null value.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_functional_types.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_functional_types.diag_role_created IS
$DOC$The database role which created the record.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_functional_types.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_functional_types.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_functional_types.diag_role_modified IS
$DOC$The database role which modified the record.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_functional_types.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_functional_types.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.

Note that this column may not be updated via this API View.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_i_syst_enum_items()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_enum_items.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_enums/ms_syst/api_views/syst_enum_items/trig_i_i_syst_enum_items.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

BEGIN

    IF
        exists( SELECT TRUE
                FROM ms_syst_data.syst_enums
                WHERE id = new.enum_id AND syst_defined AND NOT user_maintainable)
    THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'You may not add new enumeration items for system defined ' ||
                          'enumerations that are not marked user maintainable.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst'
                            ,p_proc_name      => 'trig_i_i_syst_enum_items'
                            ,p_exception_name => 'invalid_api_view_call'
                            ,p_errcode        => 'PM008'
                            ,p_param_data     => to_jsonb(new)
                            ,p_context_data   =>
                                jsonb_build_object(
                                     'tg_op',         tg_op
                                    ,'tg_when',       tg_when
                                    ,'tg_schema',     tg_table_schema
                                    ,'tg_table_name', tg_table_name)),
                ERRCODE = 'PM008',
                SCHEMA = tg_table_schema,
                TABLE = tg_table_name;
    END IF;

    INSERT INTO ms_syst_data.syst_enum_items
        ( internal_name
        , display_name
        , external_name
        , enum_id
        , functional_type_id
        , enum_default
        , functional_type_default
        , syst_defined
        , user_maintainable
        , syst_description
        , user_description
        , sort_order
        , user_options )
    VALUES
        ( new.internal_name
        , new.display_name
        , new.external_name
        , new.enum_id
        , new.functional_type_id
        , new.enum_default
        , new.functional_type_default
        , FALSE
        , TRUE
        , '(System Description Not Available)'
        , new.user_description
        , new.sort_order
        , new.user_options )
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_i_syst_enum_items()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_enum_items() FROM public;

COMMENT ON FUNCTION ms_syst.trig_i_i_syst_enum_items() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_enum_items API View for INSERT operations.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_u_syst_enum_items()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_enum_items.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_enums/ms_syst/api_views/syst_enum_items/trig_i_u_syst_enum_items.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

BEGIN

    IF
        old.syst_defined AND
        (new.internal_name != old.internal_name OR
         new.functional_type_id != old.functional_type_id)
    THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'The requested data update included changes to fields disallowed ' ||
                          'by the business rules of the API View.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst'
                            ,p_proc_name      => 'trig_i_u_syst_enum_items'
                            ,p_exception_name => 'invalid_api_view_call'
                            ,p_errcode        => 'PM008'
                            ,p_param_data     => to_jsonb(new)
                            ,p_context_data   =>
                                jsonb_build_object(
                                     'tg_op',         tg_op
                                    ,'tg_when',       tg_when
                                    ,'tg_schema',     tg_table_schema
                                    ,'tg_table_name', tg_table_name)),
                ERRCODE = 'PM008',
                SCHEMA = tg_table_schema,
                TABLE = tg_table_name;
    END IF;

    UPDATE ms_syst_data.syst_enum_items
    SET
        internal_name           = new.internal_name
      , display_name            = new.display_name
      , external_name           = new.external_name
      , functional_type_id      = new.functional_type_id
      , enum_default            = new.enum_default
      , functional_type_default = new.functional_type_default
      , user_description        = new.user_description
      , sort_order              = new.sort_order
      , user_options            = new.user_options
    WHERE id = new.id
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_u_syst_enum_items()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_enum_items() FROM public;

COMMENT ON FUNCTION ms_syst.trig_i_u_syst_enum_items() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_enum_items API View for UPDATE operations.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_d_syst_enum_items()
RETURNS trigger AS
$BODY$

-- File:        trig_i_d_syst_enum_items.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_enums/ms_syst/api_views/syst_enum_items/trig_i_d_syst_enum_items.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

BEGIN

    IF old.syst_defined THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'You cannot delete a system defined enumeration using the API Views.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst'
                            ,p_proc_name      => 'trig_i_d_syst_enum_itemss'
                            ,p_exception_name => 'invalid_api_view_call'
                            ,p_errcode        => 'PM008'
                            ,p_param_data     => to_jsonb(old)
                            ,p_context_data   =>
                                jsonb_build_object(
                                     'tg_op',         tg_op
                                    ,'tg_when',       tg_when
                                    ,'tg_schema',     tg_table_schema
                                    ,'tg_table_name', tg_table_name)),
                ERRCODE = 'PM008',
                SCHEMA = tg_table_schema,
                TABLE = tg_table_name;
    END IF;

    DELETE FROM ms_syst_data.syst_enum_items WHERE id = old.id RETURNING * INTO old;

    RETURN old;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_d_syst_enum_items()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_enum_items() FROM public;


COMMENT ON FUNCTION ms_syst.trig_i_d_syst_enum_items() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_enum_items API View for DELETE operations.$DOC$;
-- File:        syst_enum_items.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_enums/ms_syst/api_views/syst_enum_items/syst_enum_items.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE VIEW ms_syst.syst_enum_items AS
    SELECT
        id
      , internal_name
      , display_name
      , external_name
      , enum_id
      , functional_type_id
      , enum_default
      , functional_type_default
      , syst_defined
      , user_maintainable
      , syst_description
      , user_description
      , sort_order
      , syst_options
      , user_options
      , diag_timestamp_created
      , diag_role_created
      , diag_timestamp_modified
      , diag_wallclock_modified
      , diag_role_modified
      , diag_row_version
      , diag_update_count
    FROM ms_syst_data.syst_enum_items;

ALTER VIEW ms_syst.syst_enum_items OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_enum_items FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_enum_items
    INSTEAD OF INSERT ON ms_syst.syst_enum_items
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_enum_items();

CREATE TRIGGER a50_trig_i_u_syst_enum_items
    INSTEAD OF UPDATE ON ms_syst.syst_enum_items
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_enum_items();

CREATE TRIGGER a50_trig_i_d_syst_enum_items
    INSTEAD OF DELETE ON ms_syst.syst_enum_items
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_enum_items();

COMMENT ON
    VIEW ms_syst.syst_enum_items IS
$DOC$The list of values provided by an enumeration as well as related behavioral and
informational metadata.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_items.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_items.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_items.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_items.external_name IS
$DOC$A non-unique/non-key value used to display to users and external parties where
uniqueness is less of a concern than specific end user presentation.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_items.enum_id IS
$DOC$The enumeration record with which the value is associated.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_items.functional_type_id IS
$DOC$If the enumeration requires a functional type, this column references the
functional type associated with the enumeration value record.  Note that not all
enumerations require functional types.  If syst_enum_functional_types records
exist for an enumeration, then this column will be required for any values of
that enumeration; if there are no functional types defined for an enumeration,
the this column must remain NULL.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_items.enum_default IS
$DOC$If true, indicates that this value is the default selection from all values
defined for the enumerations.  If false then the value record has no special
significance relative to defaulting.

Note that if a record is inserted or updated in this table with enum_default set
true, and another record already exists for the enumeration with its
enum_default set true, the newly inserted/updated record will take precedence
and the value record previously set to be default will have its enum_default
setting set to false.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_items.functional_type_default IS
$DOC$If true, the value record is the default selection for any of a specific
fucntional type.  This is helpful in situations where a progression of state is
automatically processed by the system and the state is represented by an
enumeration.  In cases where there are no functional types, this value should
simply remain false.

Note that if a record is inserted or updated in this table with its
functional_type_default set true, and another record already exists for the
enumeration/functional type combination with its functional_type_default set
true, the newly inserted/updated record will take precedence and the value
record previously set to be default will have its functional_type_default
setting set to false.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_items.syst_defined IS
$DOC$If true, indicates that the value was created by the system or system
installation process.  A false value indicates that the record was user created.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_items.user_maintainable IS
$DOC$If true, the user may maintain the value including setting user_options or
even setting the record inactive/deleting it.  If false, the value record is
required by the system for correct operation.  The user_description and
user_options columns are always available for user maintenance regardless of
this setting.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_items.syst_description IS
$DOC$A system default description describing the value and its use cases within the
enumeration.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_items.user_description IS
$DOC$A custom user defined description which overrides the syst_description value
where it would otherwise be used.  If this column is set NULL the
syst_description value will be used.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_items.sort_order IS
$DOC$Indicates the sort ordering of the particular value record with the lowest value
sorting first.  When a value record for an enumeration is inserted or updated
and this column is being set to a value which equals another enumeration value
record for the same enumeration, the system assumes that the new record is
being set to precede the existing record and it will be set to sort after the
newly inserted/updated enumeration value.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_items.syst_options IS
$DOC$Extended options and metadata which describe the behavior and meaning of the
specific value within the enumeration.  The owning
syst_enums record's default_syst_options column will indicate what syst_options
are required or available and establishes default values for them.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_items.user_options IS
$DOC$Extended user defined options, similar to syst_options, but for the purpose of
driving custom functionality.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_items.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_items.diag_role_created IS
$DOC$The database role which created the record.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_items.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_items.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_items.diag_role_modified IS
$DOC$The database role which modified the record.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_items.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.

Note that this column may not be updated via this API View.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_enum_items.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.

Note that this column may not be updated via this API View.$DOC$;
-- File:        privileges.eex.sql
-- Location:    musebms/database/application/msbms/components/mscmp_syst_enums/privileges.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

-- syst_enums

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_enums TO <%= ms_appusr %>;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_enums TO <%= ms_apiusr %>;

GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_enums() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_enums() TO <%= ms_apiusr %>;

GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_enums() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_enums() TO <%= ms_apiusr %>;

GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_enums() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_enums() TO <%= ms_apiusr %>;

-- syst_enum_functional_types

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_enum_functional_types TO <%= ms_appusr %>;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_enum_functional_types TO <%= ms_apiusr %>;

GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_enum_functional_types() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_enum_functional_types() TO <%= ms_apiusr %>;

GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_enum_functional_types() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_enum_functional_types() TO <%= ms_apiusr %>;

GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_enum_functional_types() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_enum_functional_types() TO <%= ms_apiusr %>;

-- syst_enum_items

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_enum_items TO <%= ms_appusr %>;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_enum_items TO <%= ms_apiusr %>;

GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_enum_items() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_enum_items() TO <%= ms_apiusr %>;

GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_enum_items() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_enum_items() TO <%= ms_apiusr %>;

GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_enum_items() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_enum_items() TO <%= ms_apiusr %>;
-- File:        syst_relations.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_features/ms_syst_data/syst_relations/syst_relations.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_relations
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_relations_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_relations_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_relations_display_name_udx UNIQUE
    ,schema_name
        text
        NOT NULL
    ,table_name
        text
        NOT NULL
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
        NOT NULL
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
        NOT NULL
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
    ,CONSTRAINT syst_relations_schema_table_udx
        UNIQUE ( schema_name, table_name )
);

ALTER TABLE ms_syst_data.syst_relations OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_relations FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_relations TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_relations
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE ms_syst_data.syst_relations IS
$DOC$A list of the application tables and associated metadata that is not normally
part of the table definition kept in the catalog.  This includes categorization
by the feature type and association with forms and operations that may make use
of the relation.  Finally, this serves to associate enum values to the relations
to which they pertain.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_relations.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_relations.internal_name IS
$DOC$A candidate key useful for programatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_relations.display_name IS
$DOC$A friendly name and candidate key for the record suitable for use in user
interfaces.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_relations.schema_name IS
$DOC$The schema name where the record's table resides.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_relations.table_name IS
$DOC$The name of the relation that is the subject of the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_relations.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_relations.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_relations.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_relations.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_relations.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_relations.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_relations.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
-- File:        syst_feature_map_levels.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_features/ms_syst_data/syst_feature_map_levels/syst_feature_map_levels.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_feature_map_levels
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_feature_map_levels_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_feature_map_levels_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_feature_map_levels_display_name_udx UNIQUE
    ,functional_type
        text
        NOT NULL DEFAULT 'nonassignable'
        CONSTRAINT syst_feature_map_levels_functional_type_chk
            CHECK ( functional_type IN
                    ( 'assignable', 'nonassignable' ) )
    ,syst_description
        text
        NOT NULL
    ,user_description
        text
    ,system_defined
        boolean
        NOT NULL DEFAULT FALSE
    ,user_maintainable
        boolean
        NOT NULL DEFAULT TRUE
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
);

ALTER TABLE ms_syst_data.syst_feature_map_levels OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_feature_map_levels FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_feature_map_levels TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_feature_map_levels
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE ms_syst_data.syst_feature_map_levels IS
$DOC$Defines the available levels of hierarchy of the features map.  Records in this
table also determine whether or not individual features may be assigned at the
level in question.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_map_levels.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_map_levels.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_map_levels.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_map_levels.functional_type IS
$DOC$Defines the system recognized types which can alter processing.

      * assignable:    Individual features may be mapped to syst_feature_map record assigned to a
                       level of this functional type.

      * nonassignable: When a syst_feature_map record is assigned to a level of this functional
                       type, the syst_feature_map record may not be directly associated with
                       individual features.  The level is considered to be an intermediate node for
                       grouping other, lower levels.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_map_levels.syst_description IS
$DOC$A description of the level, its purpose in the hierarchy, and other useful
information deemed relevant.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_map_levels.user_description IS
$DOC$A user defined override of the syst_description text.  If this column is not
null, it will override the system defined text at times that the description
would be visible to application users.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_map_levels.system_defined IS
$DOC$If true, indicates that the record was added by the standard system installation
process.  If false, the feature map level was user defined.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_map_levels.user_maintainable IS
$DOC$If true, users may make modifications to the record including the possibility
of deleting the record.  If false, the user may only make minimal modifications
to columns designated as user columns (i.e. user_description).$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_map_levels.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_map_levels.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_map_levels.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_map_levels.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_map_levels.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_map_levels.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_map_levels.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
-- File:        syst_feature_map.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_features/ms_syst_data/syst_feature_map/syst_feature_map.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_feature_map
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_feature_map_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_feature_map_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_feature_map_display_name_udx UNIQUE
    ,external_name
        text
        NOT NULL
    ,feature_map_level_id
        uuid
        NOT NULL
        CONSTRAINT syst_feature_map_feature_map_levels_fk
            REFERENCES ms_syst_data.syst_feature_map_levels (id)
    ,parent_feature_map_id
        uuid
        CONSTRAINT syst_feature_map_feature_map_fk
            REFERENCES ms_syst_data.syst_feature_map (id)
    ,system_defined
        boolean
        NOT NULL DEFAULT FALSE
    ,user_maintainable
        boolean
        NOT NULL DEFAULT TRUE
    ,displayable
        boolean
        NOT NULL DEFAULT TRUE
    ,syst_description
        text
        NOT NULL
    ,user_description
        text
    ,sort_order
        smallint
        NOT NULL DEFAULT 32767
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
);

ALTER TABLE ms_syst_data.syst_feature_map OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_feature_map FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_feature_map TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_feature_map
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE ms_syst_data.syst_feature_map IS
$DOC$A map organizing the application's features into a tree-like structure.  This
is principally a documentation tool, but is also useful for features such as
driving nested directories to aide users in navigating forms or configurations.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_map.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_map.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_map.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_map.external_name IS
$DOC$A non-unique/non-key value used to display to users and external parties where
uniqueness is less of a concern than specific end user presentation.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_map.feature_map_level_id IS
$DOC$Indicates to which level this mapping entry pertains.  The mapping level will
play a part in determining whether or not the mapping entry is able to be
directly associated with specific features or if the mapping entry is just a
container for other mapping entries.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_map.parent_feature_map_id IS
$DOC$Indicates of which mapping entry the current entry is a child, if it is a
child of any entry.  If this column is NULL, the mapping entry sits at the top/
root level of the hierarchy.  This series of parent/child relationships between
mapping entries establishes a tree structure for organizing system features.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_map.system_defined IS
$DOC$If true, indicates that the record was added by the standard system installation
process.  If false, the feature map level was user defined.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_map.user_maintainable IS
$DOC$If true, users may make modifications to the record including the possibility
of deleting the record.  If false, the user may only make minimal modifications
to columns designated as user columns (i.e. user_description).$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_map.displayable IS
$DOC$If true, the feature map record may appear in queried results for the
application.  If false, the feature map record will only be available if the
user explicitly asks for hidden feature map records.  Note that this field is
user maintainable even when the user_maintainable column is false.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_map.syst_description IS
$DOC$A standard description of the mapping value suitable for display to application
users.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_map.user_description IS
$DOC$A user customizable description which, if not NULL, will be used to override the
text in syst_description.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_map.sort_order IS
$DOC$In user display contexts, indicates the sort relative to other records of the
same level and grouping.  Sorting is done on a lowest value first.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_map.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_map.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_map.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_map.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_map.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_map.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_map.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst_priv.trig_a_iu_feature_map_level_assignable_check()
RETURNS trigger AS
$BODY$

-- File:        trig_a_iu_feature_map_level_assignable_check.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_features/ms_syst_priv/trigger_functions/trig_a_iu_feature_map_level_assignable_check.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

BEGIN

    IF NOT exists( SELECT
                       TRUE
                   FROM ms_syst_data.syst_feature_map fm
                   JOIN ms_syst_data.syst_feature_map_levels fml
                        ON fml.id = fm.feature_map_level_id
                   WHERE fm.id = new.feature_map_id AND fml.functional_type = 'assignable' )
    THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'The feature to which you are trying to map is not assignable.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst_priv'
                            ,p_proc_name      => 'trig_a_iu_feature_map_level_assignable_check'
                            ,p_exception_name => 'feature_map_level_nonassignable'
                            ,p_errcode        => 'PM004'
                            ,p_param_data     => NULL::jsonb
                            ,p_context_data   =>
                                jsonb_build_object(
                                     'tg_op',         tg_op
                                    ,'tg_when',       tg_when
                                    ,'tg_schema',     tg_table_schema
                                    ,'tg_table_name', tg_table_name)),
                ERRCODE = 'PM004',
                SCHEMA = tg_table_schema,
                    TABLE = tg_table_name;
    END IF;

    RETURN NULL;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION ms_syst_priv.trig_a_iu_feature_map_level_assignable_check()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_priv.trig_a_iu_feature_map_level_assignable_check() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_priv.trig_a_iu_feature_map_level_assignable_check() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst_priv.trig_a_iu_feature_map_level_assignable_check() IS
$DOC$Determines if a syst_feature_map record is assigned to an assignable
syst_feature_map_levels record.  If the level record is functional type
nonassignable, an exception is raised.  Note that this function expects to be
executed by a constraint trigger and that the table associated with the trigger
should have a column feature_map_id referenced to syst_feature_map.$DOC$;
-- File:        syst_feature_relation_assigns.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_features/ms_syst_data/syst_feature_relation_assigns/syst_feature_relation_assigns.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_feature_relation_assigns
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_feature_relation_assigns_pk PRIMARY KEY
    ,feature_map_id
        uuid
        NOT NULL
        CONSTRAINT syst_feature_relation_assigns_feature_map_fk
            REFERENCES ms_syst_data.syst_feature_map (id)
    ,relation_id
        uuid
        NOT NULL
        CONSTRAINT syst_feature_relation_assigns_relation_fk
            REFERENCES ms_syst_data.syst_relations (id)
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
        NOT NULL
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
        NOT NULL
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
);

ALTER TABLE ms_syst_data.syst_feature_relation_assigns OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_feature_relation_assigns FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_feature_relation_assigns TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_feature_relation_assigns
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_feature_map_level_assignable_check
    AFTER INSERT ON ms_syst_data.syst_feature_relation_assigns
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_a_iu_feature_map_level_assignable_check();

CREATE CONSTRAINT TRIGGER a50_trig_a_u_feature_map_level_assignable_check
    AFTER UPDATE ON ms_syst_data.syst_feature_relation_assigns
    FOR EACH ROW WHEN ( OLD.feature_map_id != NEW.feature_map_id )
        EXECUTE PROCEDURE ms_syst_priv.trig_a_iu_feature_map_level_assignable_check();

COMMENT ON
    TABLE ms_syst_data.syst_feature_relation_assigns IS
$DOC$A join table which allows application relations to be associated with various
application features.  This is a many-to-many relationship.  The expectation is
that this association will be used in organizing certain configuration or
permissioning displays into a tree-like structure.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_relation_assigns.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_relation_assigns.feature_map_id IS
$DOC$Identifies the feature mapping record to which the relation record is being
associated.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_relation_assigns.relation_id IS
$DOC$Identifies the relation record which is being associated with the feature.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_relation_assigns.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_relation_assigns.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_relation_assigns.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_relation_assigns.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_relation_assigns.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_relation_assigns.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_relation_assigns.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
-- File:        syst_feature_setting_assigns.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_features/ms_syst_data/syst_feature_setting_assigns/syst_feature_setting_assigns.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

DO
$SYST_SETTINGS_OPTION$
    BEGIN
        IF
            exists( SELECT TRUE
                    FROM information_schema.tables
                    WHERE table_schema = 'ms_syst_data'
                      AND table_name = 'syst_settings')
        THEN

CREATE TABLE ms_syst_data.syst_feature_setting_assigns
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_feature_setting_assigns_pk PRIMARY KEY
    ,feature_map_id
        uuid
        NOT NULL
        CONSTRAINT syst_feature_setting_assigns_feature_map_fk
            REFERENCES ms_syst_data.syst_feature_map (id)
    ,setting_id
        uuid
        NOT NULL
        CONSTRAINT syst_feature_setting_assigns_setting_fk
            REFERENCES ms_syst_data.syst_settings (id)
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
        NOT NULL
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
        NOT NULL
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
);

ALTER TABLE ms_syst_data.syst_feature_setting_assigns OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_feature_setting_assigns FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_feature_setting_assigns TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_feature_setting_assigns
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_feature_map_level_assignable_check
    AFTER INSERT ON ms_syst_data.syst_feature_setting_assigns
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_a_iu_feature_map_level_assignable_check();

CREATE CONSTRAINT TRIGGER a50_trig_a_u_feature_map_level_assignable_check
    AFTER UPDATE ON ms_syst_data.syst_feature_setting_assigns
    FOR EACH ROW WHEN ( OLD.feature_map_id != NEW.feature_map_id )
        EXECUTE PROCEDURE ms_syst_priv.trig_a_iu_feature_map_level_assignable_check();

COMMENT ON
    TABLE ms_syst_data.syst_feature_setting_assigns IS
$DOC$A join table which allows application settings to be associated with various
application features.  This is a many-to-many relationship.  The expectation is
that this association will be used in organizing certain configuration or
permissioning displays into a tree-like structure.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_setting_assigns.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_setting_assigns.feature_map_id IS
$DOC$Identifies the feature mapping record to which the relation record is being
associated.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_setting_assigns.setting_id IS
$DOC$Identifies the settings record which is being associated with the feature.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_setting_assigns.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_setting_assigns.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_setting_assigns.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_setting_assigns.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_setting_assigns.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_setting_assigns.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_setting_assigns.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;

        END IF;
    END;
$SYST_SETTINGS_OPTION$;
-- File:        syst_feature_enum_assigns.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_features/ms_syst_data/syst_feature_enum_assigns/syst_feature_enum_assigns.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

DO
$SYST_ENUMS_OPTION$
    BEGIN
        IF
            exists( SELECT TRUE
                    FROM information_schema.tables
                    WHERE table_schema = 'ms_syst_data'
                      AND table_name = 'syst_enums')
        THEN
CREATE TABLE ms_syst_data.syst_feature_enum_assigns
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_feature_enum_assigns_pk PRIMARY KEY
    ,feature_map_id
        uuid
        NOT NULL
        CONSTRAINT syst_feature_enum_assigns_feature_map_fk
            REFERENCES ms_syst_data.syst_feature_map (id)
    ,enum_id
        uuid
        NOT NULL
        CONSTRAINT syst_feature_enum_assigns_enum_fk
            REFERENCES ms_syst_data.syst_enums (id)
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
        NOT NULL
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
        NOT NULL
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
);

ALTER TABLE ms_syst_data.syst_feature_enum_assigns OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_feature_enum_assigns FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_feature_enum_assigns TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_feature_enum_assigns
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_feature_map_level_assignable_check
    AFTER INSERT ON ms_syst_data.syst_feature_enum_assigns
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_a_iu_feature_map_level_assignable_check();

CREATE CONSTRAINT TRIGGER a50_trig_a_u_feature_map_level_assignable_check
    AFTER UPDATE ON ms_syst_data.syst_feature_enum_assigns
    FOR EACH ROW WHEN ( OLD.feature_map_id != NEW.feature_map_id )
        EXECUTE PROCEDURE ms_syst_priv.trig_a_iu_feature_map_level_assignable_check();

COMMENT ON
    TABLE ms_syst_data.syst_feature_enum_assigns IS
$DOC$A join table which allows application enumerations to be associated with various
application features.  This is a many-to-many relationship.  The expectation is
that this association will be used in organizing certain configuration or
permissioning displays into a tree-like structure.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_enum_assigns.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_enum_assigns.feature_map_id IS
$DOC$Identifies the feature mapping record to which the relation record is being
associated.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_enum_assigns.enum_id IS
$DOC$Identifies the enumeration record which is being associated with the feature.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_enum_assigns.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_enum_assigns.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_enum_assigns.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_enum_assigns.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_enum_assigns.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_enum_assigns.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_feature_enum_assigns.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;

        END IF;
    END;
$SYST_ENUMS_OPTION$;
DO
$SYS_SETTINGS_OPTION$
    BEGIN
        IF
            exists( SELECT TRUE
                    FROM information_schema.tables
                    WHERE table_schema = 'ms_syst_data'
                      AND table_name = 'syst_settings')
        THEN

CREATE OR REPLACE FUNCTION ms_syst.trig_i_i_syst_feature_setting_assigns()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_feature_setting_assigns.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_features/ms_syst/api_views/syst_feature_setting_assigns/trig_i_i_syst_feature_setting_assigns.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

BEGIN

    IF
        (
            SELECT syst_defined
            FROM   ms_syst_data.syst_settings
            WHERE  id = new.setting_id
        )
    THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'You cannot create a new feature/setting mapping for system defined ' ||
                          'settings using this API view.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst'
                            ,p_proc_name      => 'trig_i_i_syst_feature_setting_assigns'
                            ,p_exception_name => 'invalid_api_view_call'
                            ,p_errcode        => 'PM008'
                            ,p_param_data     => to_jsonb(new)
                            ,p_context_data   =>
                                jsonb_build_object(
                                     'tg_op',         tg_op
                                    ,'tg_when',       tg_when
                                    ,'tg_schema',     tg_table_schema
                                    ,'tg_table_name', tg_table_name)),
                ERRCODE = 'PM008',
                SCHEMA = tg_table_schema,
                TABLE = tg_table_name;
    END IF;

    INSERT INTO ms_syst_data.syst_feature_setting_assigns
        ( feature_map_id, setting_id )
    VALUES
        ( new.feature_map_id, new.setting_id );

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_i_syst_feature_setting_assigns() OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_feature_setting_assigns() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_feature_setting_assigns() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_feature_setting_assigns() TO <%= ms_apiusr %>;

COMMENT ON
    FUNCTION ms_syst.trig_i_i_syst_feature_setting_assigns() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_settings API View for INSERT operations.$DOC$;

        END IF;
    END;
$SYS_SETTINGS_OPTION$;
DO
$SYS_SETTINGS_OPTION$
    BEGIN
        IF
            exists( SELECT TRUE
                    FROM information_schema.tables
                    WHERE table_schema = 'ms_syst_data'
                      AND table_name = 'syst_settings')
        THEN

CREATE OR REPLACE FUNCTION ms_syst.trig_i_u_syst_feature_setting_assigns()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_feature_setting_assigns.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_features/ms_syst/api_views/syst_feature_setting_assigns/trig_i_u_syst_feature_setting_assigns.eex.sql
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
    var_setting_system_defined boolean;

BEGIN

    RAISE EXCEPTION
        USING
            MESSAGE = 'You cannot update a system defined setting/feature assignment ' ||
                      'using the API Views.',
            DETAIL = ms_syst_priv.get_exception_details(
                         p_proc_schema    => 'ms_syst'
                        ,p_proc_name      => 'trig_i_u_syst_feature_setting_assigns'
                        ,p_exception_name => 'invalid_api_view_call'
                        ,p_errcode        => 'PM008'
                        ,p_param_data     => to_jsonb(old)
                        ,p_context_data   =>
                            jsonb_build_object(
                                 'tg_op',         tg_op
                                ,'tg_when',       tg_when
                                ,'tg_schema',     tg_table_schema
                                ,'tg_table_name', tg_table_name)),
            ERRCODE = 'PM008',
            SCHEMA = tg_table_schema,
            TABLE = tg_table_name;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_u_syst_feature_setting_assigns()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_feature_setting_assigns() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_feature_setting_assigns() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_feature_setting_assigns() TO <%= ms_apiusr %>;


COMMENT ON
    FUNCTION ms_syst.trig_i_u_syst_feature_setting_assigns() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_settings API View for UPDATE operations.

Note that for syst_feature_setting_assigns records that updating is not a
supported operation.  Any change in the feature or the setting is a sufficiently
large change to justify just using a full delete/insert.$DOC$;

        END IF;
    END;
$SYS_SETTINGS_OPTION$;
DO
$SYS_SETTINGS_OPTION$
    BEGIN
        IF
            exists( SELECT TRUE
                    FROM information_schema.tables
                    WHERE table_schema = 'ms_syst_data'
                      AND table_name = 'syst_settings')
        THEN

CREATE OR REPLACE FUNCTION ms_syst.trig_i_d_syst_feature_setting_assigns()
RETURNS trigger AS
$BODY$

-- File:        trig_i_d_syst_feature_setting_assigns.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_features/ms_syst/api_views/syst_feature_setting_assigns/trig_i_d_syst_feature_setting_assigns.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

BEGIN

    IF
        (
            SELECT syst_defined
            FROM   ms_syst_data.syst_settings
            WHERE  id = old.setting_id
        )
    THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'You cannot delete a system defined setting/feature assignment ' ||
                          'using the API Views.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst'
                            ,p_proc_name      => 'trig_i_d_syst_feature_setting_assigns'
                            ,p_exception_name => 'invalid_api_view_call'
                            ,p_errcode        => 'PM008'
                            ,p_param_data     => to_jsonb(old)
                            ,p_context_data   =>
                                jsonb_build_object(
                                     'tg_op',         tg_op
                                    ,'tg_when',       tg_when
                                    ,'tg_schema',     tg_table_schema
                                    ,'tg_table_name', tg_table_name)),
                ERRCODE = 'PM008',
                SCHEMA = tg_table_schema,
                TABLE = tg_table_name;
    END IF;

    DELETE FROM ms_syst_data.syst_feature_setting_assigns WHERE id = old.id;

    RETURN null;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_d_syst_feature_setting_assigns()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_feature_setting_assigns() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_feature_setting_assigns() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_feature_setting_assigns() TO <%= ms_apiusr %>;


COMMENT ON
    FUNCTION ms_syst.trig_i_d_syst_feature_setting_assigns() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_settings API View for DELETE operations.$DOC$;

        END IF;
    END;
$SYS_SETTINGS_OPTION$;
-- File:        syst_feature_setting_assigns.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_features/ms_syst/api_views/syst_feature_setting_assigns/syst_feature_setting_assigns.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

DO
$SYS_SETTINGS_OPTION$
    BEGIN
        IF
            exists( SELECT TRUE
                    FROM information_schema.tables
                    WHERE table_schema = 'ms_syst_data'
                      AND table_name = 'syst_settings')
        THEN

CREATE VIEW ms_syst.syst_feature_setting_assigns AS
    SELECT
        id
      , feature_map_id
      , setting_id
      , diag_timestamp_created
      , diag_role_created
      , diag_timestamp_modified
      , diag_wallclock_modified
      , diag_role_modified
      , diag_row_version
      , diag_update_count
    FROM ms_syst_data.syst_feature_setting_assigns;

ALTER VIEW ms_syst.syst_feature_setting_assigns OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_feature_setting_assigns FROM PUBLIC;

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_feature_setting_assigns TO <%= ms_appusr %>;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_feature_setting_assigns TO <%= ms_apiusr %>;

CREATE TRIGGER a50_trig_i_i_syst_feature_setting_assigns
    INSTEAD OF INSERT ON ms_syst.syst_feature_setting_assigns
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_feature_setting_assigns();

CREATE TRIGGER a50_trig_i_u_syst_feature_setting_assigns
    INSTEAD OF UPDATE ON ms_syst.syst_feature_setting_assigns
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_feature_setting_assigns();

CREATE TRIGGER a50_trig_i_d_syst_feature_setting_assigns
    INSTEAD OF DELETE ON ms_syst.syst_feature_setting_assigns
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_feature_setting_assigns();

COMMENT ON
    VIEW ms_syst.syst_feature_setting_assigns IS
$DOC$A join table which allows application settings to be associated with various
application features.  This is a many-to-many relationship.  The expectation is
that this association will be used in organizing certain configuration or
permissioning displays into a tree-like structure.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.$DOC$;

        END IF;
    END;
$SYS_SETTINGS_OPTION$;
-- File:        initialize_feature_mapping.eex.sql
-- Location:    musebms/database/application/msbms/gen_seed_data/initialize_feature_mapping.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

INSERT INTO ms_syst_data.syst_feature_map_levels
    ( internal_name
    , display_name
    , functional_type
    , syst_description
    , system_defined
    , user_maintainable )
VALUES
    ( 'instance_module'
    , 'Modules'
    , 'nonassignable'
    , 'Groupings of features delineated into broad areas of business concern. ' ||
      '(e.g. Accounting, Business Relationship Management, etc.)'
    , TRUE
    , FALSE )
     ,
    ( 'instance_feature'
    , 'Features'
    , 'nonassignable'
    , 'Specific feature areas with a Module. (e.g. Sales Ordering, Purchasing, etc.)'
    , TRUE
    , FALSE )
     ,
    ( 'instance_information_type'
    , 'Information Type'
    , 'nonassignable'
    , 'Division of features into information types. (e.g. Master Data, Booking Transactions, etc.)'
    , TRUE
    , FALSE )
     ,
    ( 'instance_kind'
    , 'Kinds'
    , 'assignable'
    , 'Identifies different kinds of mappable features such as forms, settings, or enumerations.'
    , TRUE
    , FALSE );


-- The feature mapping as currently envisioned will create a hierarchy
-- structured Module -> Type -> Feature -> Kind.  Both the defining JSON
-- assigned to var_feature_mappings and the logic are assuming this structure to
-- be true.  If a different structure is desired, naturally either the JSON, the
-- insert logic, or both will need to be changed.

DO
$INITIALIZE_FEATURE_MAPPING$
    DECLARE
        var_root_internal_name text  := 'instance';
        var_root_display_name  text  := 'Instance';
        var_curr_module        jsonb;
        var_new_module         ms_syst_data.syst_feature_map;
        var_curr_type          jsonb;
        var_new_type           ms_syst_data.syst_feature_map;
        var_curr_feature       jsonb;
        var_new_feature        ms_syst_data.syst_feature_map;
        var_curr_kind          jsonb;

        var_feature_mappings   jsonb := $FEATURE_MAP$
{
  "modules": [
    {
      "module_name": "System Administration",
      "module_display_name": "System Admin",
      "module_internal_name": "sysadmin",
      "module_description": "Functionality related to managing and providing global user authorization and instance wide systems auditing.",
      "module_map_level": "instance_module",
      "features": [
        {
          "feature_name": "User Authorization",
          "feature_display_name": "Authorization",
          "feature_internal_name": "authorization",
          "feature_description": "Functionality related to granting users access and managing associations to globally defined users.",
          "feature_map_level": "instance_feature",
          "feature_include_in": [
            "master",
            "maintenance"
          ]
        },
        {
          "feature_name": "System Auditing",
          "feature_display_name": "Auditing",
          "feature_internal_name": "auditing",
          "feature_description": "Systems usage auditing.",
          "feature_map_level": "instance_feature",
          "feature_include_in": [
            "maintenance"
          ]
        }
      ]
    },
    {
      "module_name": "Business Relationship Management",
      "module_display_name": "BRM",
      "module_internal_name": "brm",
      "module_description": "Functionality for managing business entities, people, and places.",
      "module_map_level": "instance_module",
      "features": [
        {
          "feature_name": "Entities",
          "feature_display_name": "Entities",
          "feature_internal_name": "entities",
          "feature_description": "Legal business entities with with whom business is conducted.",
          "feature_map_level": "instance_feature",
          "feature_include_in": [
            "master"
          ]
        },
        {
          "feature_name": "Places",
          "feature_display_name": "Places",
          "feature_internal_name": "places",
          "feature_description": "Physical locations where business entities conduct business.",
          "feature_map_level": "instance_feature",
          "feature_include_in": [
            "master"
          ]
        },
        {
          "feature_name": "People",
          "feature_display_name": "People",
          "feature_internal_name": "people",
          "feature_description": "People associated with business entities.",
          "feature_map_level": "instance_feature",
          "feature_include_in": [
            "master"
          ]
        },
        {
          "feature_name": "Contacts",
          "feature_display_name": "Contacts",
          "feature_internal_name": "contacts",
          "feature_description": "The means to contact specific people or business entities generically.",
          "feature_map_level": "instance_feature",
          "feature_include_in": [
            "supporting"
          ]
        },
        {
          "feature_name": "Countries",
          "feature_display_name": "Countries",
          "feature_internal_name": "countries",
          "feature_description": "Definitions of countries and related metadata.",
          "feature_map_level": "instance_feature",
          "feature_include_in": [
            "supporting"
          ]
        }

      ]
    },
    {
      "module_name": "Accounting",
      "module_display_name": "Accounting",
      "module_internal_name": "accounting",
      "module_description": "Functionality for running general ledger operations.",
      "module_map_level": "instance_module",
      "features": [
        {
          "feature_name": "Fiscal Calendar",
          "feature_display_name": "Fiscal Calendar",
          "feature_internal_name": "fiscal_calendar",
          "feature_description": "The means to contact specific people or business entities generically.",
          "feature_map_level": "instance_feature",
          "feature_include_in": [
            "supporting"
          ]
        },
        {
          "feature_name": "Chart of Accounts",
          "feature_display_name": "Chart of Accounts",
          "feature_internal_name": "gl_accounts",
          "feature_description": "The chart of general ledger accounts.",
          "feature_map_level": "instance_feature",
          "feature_include_in": [
            "master"
          ]
        },
        {
          "feature_name": "General Ledger",
          "feature_display_name": "General Ledger",
          "feature_internal_name": "accounting_ledger",
          "feature_description": "A general ledger of accounting transactions.  Note that in reality this will ultimately contain both booking and non-booking transactions, but expectations would align this feature as a ledger of booking transactions.",
          "feature_map_level": "instance_feature",
          "feature_include_in": [
            "booking"
          ]
        }
      ]
    }
  ],
  "information_types": [
    {
      "type_name": "Master Data",
      "type_display_name": "Master",
      "type_internal_name": "master",
      "type_description": "Qualitative information which describes the current state of a subject.  (e.g. entity, item)",
      "type_map_level": "instance_information_type"
    },
    {
      "type_name": "Supporting Data",
      "type_display_name": "Supporting",
      "type_internal_name": "supporting",
      "type_description": "'Qualitative information which enhances or provides more complex descriptions of more fundamental master data.'",
      "type_map_level":  "instance_information_type"
    },
    {
      "type_name": "Non-booking Transaction",
      "type_display_name": "Non-booking",
      "type_internal_name": "nonbooking",
      "type_description": "Finite duration events which express an intention/direction to act and often express contractual terms involving third-parties.  These transactions do not have direct accounting requirements, but will usually lead to transactions with direct accounting requirements. (e.g. purchase orders, sales orders)",
      "type_map_level":  "instance_information_type"
    },
    {
      "type_name": "Booking Transaction",
      "type_display_name": "Booking",
      "type_internal_name": "booking",
      "type_description": "Finite duration events which express a concrete action, often taken in conjunction with third-parties.  These transactions do have direct accounting requirements and are often related to non-booking transactions that originally direct the action to be taken.  (e.g. purchase receipts, customer invoices)",
      "type_map_level":  "instance_information_type"
    },
    {
      "type_name": "Activity Transaction",
      "type_display_name": "Activity",
      "type_internal_name": "activity",
      "type_description": "Finite duration events which express specific actions or tasks by staff (or their automated proxies) requiring tracking of time, communications, and/or outcomes. Activities may lead to either non-booking or booking transactions.",
      "type_map_level":  "instance_information_type"
    },
    {
      "type_name": "Maintenance",
      "type_display_name": "Maintenance",
      "type_internal_name": "maintenance",
      "type_description": "Systematic job and batch processing support.",
      "type_map_level":  "instance_information_type"
    }
  ],
  "kinds": [
    {
      "kind_name": "Settings",
      "kind_display_name": "Settings",
      "kind_internal_name": "settings",
      "kind_description": "Configurable values which determine application behaviors, assign defaults, or assign constant values.",
      "kind_map_level":"instance_kind"
    },
    {
      "kind_name": "Numbering",
      "kind_display_name": "Numbering",
      "kind_internal_name": "numbering",
      "kind_description": "Provides master data record and transaction numbering and allows configuration of numbering formats and rules.",
      "kind_map_level": "instance_kind"
    },
    {
      "kind_name": "Enumerations",
      "kind_display_name": "Enumerations",
      "kind_internal_name": "enumerations",
      "kind_description": "Lists of values used in fixed answer contexts such as forms and record life-cycle management.",
      "kind_map_level": "instance_kind"
    },
    {
      "kind_name": "Formats",
      "kind_display_name": "Formats",
      "kind_internal_name": "formats",
      "kind_description": "Data definition and related user presentation descriptions for specialized multi-field data types.  (e.g. addresses, phone numbers)",
      "kind_map_level": "instance_kind"
    },
    {
      "kind_name": "Jobs",
      "kind_display_name": "Jobs",
      "kind_internal_name": "jobs",
      "kind_description": "Automated Job and Batch processing.",
      "kind_map_level": "instance_kind"
    },
    {
      "kind_name": "Forms",
      "kind_display_name": "Forms",
      "kind_internal_name": "forms",
      "kind_description": "User interface data and layout definition.",
      "kind_map_level": "instance_kind"
    },
    {
      "kind_name": "Database Tables",
      "kind_display_name": "Relations",
      "kind_internal_name": "relations",
      "kind_description": "Associates certain database tables and similar structures for custom field management and documentation purposes.",
      "kind_map_level": "instance_kind"
    }
  ]
}
        $FEATURE_MAP$::jsonb;

    BEGIN

        <<module_loop>>
        FOR var_curr_module IN
            SELECT jsonb_array_elements( var_feature_mappings -> 'modules' )
        LOOP

                INSERT INTO ms_syst_data.syst_feature_map
                    ( internal_name
                    , display_name
                    , external_name
                    , feature_map_level_id
                    , parent_feature_map_id
                    , system_defined
                    , user_maintainable
                    , displayable
                    , syst_description
                    , sort_order )
                VALUES
                    (
                      var_root_internal_name || '_' || ( var_curr_module ->> 'module_internal_name' )
                    , var_root_display_name || ' / ' || ( var_curr_module ->> 'module_display_name' )
                    , var_curr_module ->> 'module_name'
                    , ( SELECT id
                        FROM ms_syst_data.syst_feature_map_levels
                        WHERE internal_name = (var_curr_module ->> 'module_map_level') )
                    , NULL
                    , TRUE
                    , FALSE
                    , TRUE
                    , var_curr_module ->> 'module_description'
                    , coalesce(
                        ( SELECT max( sort_order ) + 1
                          FROM ms_syst_data.syst_feature_map fm
                              JOIN ms_syst_data.syst_feature_map_levels fml
                                  ON fml.id = fm.feature_map_level_id
                          WHERE fml.internal_name = (var_curr_module ->> 'module_map_level') )
                        , 1 ) )
                RETURNING * INTO var_new_module;

                <<information_type_loop>>
                FOR var_curr_type IN
                    SELECT jsonb_array_elements( var_feature_mappings -> 'information_types' )
                LOOP

                    INSERT INTO ms_syst_data.syst_feature_map
                        ( internal_name
                        , display_name
                        , external_name
                        , feature_map_level_id
                        , parent_feature_map_id
                        , system_defined
                        , user_maintainable
                        , displayable
                        , syst_description
                        , sort_order )
                    VALUES
                        (
                          var_new_module.internal_name || '_' || ( var_curr_type ->> 'type_internal_name' )
                        , var_new_module.display_name || ' / ' || ( var_curr_type ->> 'type_display_name' )
                        , var_curr_type ->> 'type_name'
                        , ( SELECT id
                            FROM ms_syst_data.syst_feature_map_levels
                            WHERE internal_name = (var_curr_type ->> 'type_map_level') )
                        , var_new_module.id
                        , TRUE
                        , FALSE
                        , TRUE
                        , var_curr_type ->> 'type_description'
                        , coalesce(
                            ( SELECT max( sort_order ) + 1
                              FROM ms_syst_data.syst_feature_map fm
                                  JOIN ms_syst_data.syst_feature_map_levels fml
                                      ON fml.id = fm.feature_map_level_id
                              WHERE fm.parent_feature_map_id = var_new_module.id)
                            , 1 ) )
                    RETURNING * INTO var_new_type;

                    <<feature_loop>>
                    FOR var_curr_feature IN
                        SELECT jsonb_array_elements( var_curr_module -> 'features' )
                    LOOP

                        IF
                            ( var_curr_feature -> 'feature_include_in' ) ?
                                (var_curr_type ->> 'type_internal_name')
                        THEN

                            INSERT INTO ms_syst_data.syst_feature_map
                                ( internal_name
                                , display_name
                                , external_name
                                , feature_map_level_id
                                , parent_feature_map_id
                                , system_defined
                                , user_maintainable
                                , displayable
                                , syst_description
                                , sort_order )
                            VALUES
                                (
                                  var_new_type.internal_name || '_' ||
                                    ( var_curr_feature ->> 'feature_internal_name' )
                                , var_new_type.display_name || ' / ' ||
                                    ( var_curr_feature ->> 'feature_display_name' )
                                , var_curr_feature ->> 'feature_name'
                                , ( SELECT id
                                    FROM ms_syst_data.syst_feature_map_levels
                                    WHERE internal_name = (var_curr_feature ->> 'feature_map_level') )
                                , var_new_type.id
                                , TRUE
                                , FALSE
                                , TRUE
                                , var_curr_feature ->> 'feature_description'
                                , coalesce(
                                    ( SELECT max( sort_order ) + 1
                                      FROM ms_syst_data.syst_feature_map fm
                                          JOIN ms_syst_data.syst_feature_map_levels fml
                                              ON fml.id = fm.feature_map_level_id
                                      WHERE fm.parent_feature_map_id = var_new_type.id)
                                    , 1 ) )
                            RETURNING * INTO var_new_feature;

                            <<kind_loop>>
                            FOR var_curr_kind IN
                                SELECT jsonb_array_elements( var_feature_mappings -> 'kinds' )
                            LOOP

                                INSERT INTO ms_syst_data.syst_feature_map
                                ( internal_name
                                , display_name
                                , external_name
                                , feature_map_level_id
                                , parent_feature_map_id
                                , system_defined
                                , user_maintainable
                                , displayable
                                , syst_description
                                , sort_order )
                            VALUES
                                (
                                  var_new_feature.internal_name || '_' ||
                                    ( var_curr_kind ->> 'kind_internal_name' )
                                , var_new_feature.display_name || ' / ' ||
                                    ( var_curr_kind ->> 'kind_display_name' )
                                , var_curr_kind ->> 'kind_name'
                                , ( SELECT id
                                    FROM ms_syst_data.syst_feature_map_levels
                                    WHERE internal_name = (var_curr_kind ->> 'kind_map_level') )
                                , var_new_feature.id
                                , TRUE
                                , FALSE
                                , TRUE
                                , var_curr_kind ->> 'kind_description'
                                , coalesce(
                                    ( SELECT max( sort_order ) + 1
                                      FROM ms_syst_data.syst_feature_map fm
                                          JOIN ms_syst_data.syst_feature_map_levels fml
                                              ON fml.id = fm.feature_map_level_id
                                      WHERE fm.parent_feature_map_id = var_new_feature.id)
                                    , 1 ) );

                            END LOOP kind_loop;

                        END IF;

                    END LOOP feature_loop;

                END LOOP information_type_loop;

            END LOOP module_loop;
    END;
$INITIALIZE_FEATURE_MAPPING$;
-- File:        syst_complex_formats.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_formats/ms_syst_data/syst_complex_formats/syst_complex_formats.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_complex_formats
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_complex_formats_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_complex_formats_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_complex_formats_display_name_udx UNIQUE
    ,syst_description
        text
        NOT NULL
    ,user_description
        text
    ,feature_id
        uuid
        NOT NULL
        CONSTRAINT syst_complex_formats_feature_fk
            REFERENCES ms_syst_data.syst_feature_map (id)
    ,syst_defined
        boolean
        NOT NULL DEFAULT FALSE
    ,user_maintainable
        boolean
        NOT NULL DEFAULT TRUE
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
        NOT NULL
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
        NOT NULL
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
);

ALTER TABLE ms_syst_data.syst_complex_formats OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_complex_formats FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_complex_formats TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_complex_formats
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE ms_syst_data.syst_complex_formats IS
$DOC$Establishes definitions for complex data types and their user interface related
formatting.  Complex data types may include concepts such as street addresses,
personal names, and phone numbers; in each of these cases there are typically
multiple fields, but internationally there is no consistent definition of what
fields are available and how they should be ordered or arranged.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_complex_formats.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_complex_formats.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_complex_formats.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_complex_formats.syst_description IS
$DOC$A default description of the format which might include details such as how the
format is used and what kind of functionality might be impacted by choosing
specific format values.

Note that users should not change this value.  For custom descriptions, use the
ms_syst_data.syst_complex_formats.user_description field instead.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_complex_formats.user_description IS
$DOC$A user defined description of the format to support custom user
documentation of the purpose and function of the format.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_complex_formats.feature_id IS
$DOC$A reference to the specific feature of which the format is considered to be
part.  This reference is chiefly used to determine where in the configuration
options the format should appear.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_complex_formats.syst_defined IS
$DOC$If true, this value indicates that the format is considered part of the
application.  Often times, system formats are manageable by users, but the
existence of the format in the system is assumed to exist by the application.
If false, the assumption is that the format was created by users and supports
custom user functionality.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_complex_formats.user_maintainable IS
$DOC$When true, this column indicates that the format is user maintainable;
this might include the ability to add, edit, or remove format values.  When
false, the format is strictly system managed for any functional purpose.
Note that the value of this column doesn't effect the ability to set a
user_description value; the ability to set custom descriptions is always
available for any properly authorized user.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_complex_formats.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_complex_formats.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_complex_formats.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_complex_formats.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_complex_formats.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_complex_formats.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_complex_formats.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
-- File:        syst_complex_format_values.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_formats/ms_syst_data/syst_complex_format_values/syst_complex_format_values.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_complex_format_values
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_complex_format_values_pk PRIMARY KEY
    ,internal_name
        text COLLATE ms_syst_priv.variant_insensitive
        NOT NULL
        CONSTRAINT syst_complex_format_values_internal_name_udx UNIQUE
    ,display_name
        text COLLATE ms_syst_priv.variant_insensitive
        NOT NULL
        CONSTRAINT syst_complex_format_values_display_name_udx UNIQUE
    ,external_name
        text
        NOT NULL
    ,complex_format_id
        uuid
        NOT NULL
        CONSTRAINT syst_complex_format_values_complex_format_fk
            REFERENCES ms_syst_data.syst_complex_formats (id) ON DELETE CASCADE
    ,format_default
        boolean
        NOT NULL DEFAULT FALSE
    ,syst_defined
        boolean
        NOT NULL DEFAULT FALSE
    ,user_maintainable
        boolean
        NOT NULL DEFAULT FALSE
    ,syst_description
        text
        NOT NULL
    ,user_description
        text
    ,sort_order
        integer
        NOT NULL
    ,syst_data
        jsonb
        NOT NULL
    ,syst_form
        jsonb
        NOT NULL
    ,user_data
        jsonb
    ,user_form
        jsonb
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
        NOT NULL
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
        NOT NULL
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
);

ALTER TABLE ms_syst_data.syst_complex_format_values OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_complex_format_values FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_complex_format_values TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_complex_format_values
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE ms_syst_data.syst_complex_format_values IS
$DOC$The list of values provided by an enumeration as well as related behavioral and
informational metadata.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_complex_format_values.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_complex_format_values.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_complex_format_values.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_complex_format_values.external_name IS
$DOC$A non-unique/non-key value used to display to users and external parties where
uniqueness is less of a concern than specific end user presentation.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_complex_format_values.complex_format_id IS
$DOC$The format record with which the value is associated.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_complex_format_values.format_default IS
$DOC$If true, indicates that this value is the default selection from all values
defined for the enumerations.  If false then the value record has no special
significance relative to defaulting.

Note that if a record is inserted or updated in this table with enum_default set
true, and another record already exists for the enumeration with its
enum_default set true, the newly inserted/updated record will take precedence
and the value record previously set to be default will have its enum_default
setting set to false.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_complex_format_values.syst_defined IS
$DOC$If true, indicates that the value was created by the system or system
installation process.  A false value indicates that the record was user created.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_complex_format_values.user_maintainable IS
$DOC$If true, the user may maintain the value including setting user_options or
even setting the record inactive/deleting it.  If false, the value record is
required by the system for correct operation.  The user_description and
user_options columns are always available for user maintenance regardless of
this setting.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_complex_format_values.syst_description IS
$DOC$A system default description describing the value and its use cases within the
enumeration.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_complex_format_values.user_description IS
$DOC$A custom user defined description which overrides the syst_description value
where it would otherwise be used.  If this column is set NULL the
syst_description value will be used.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_complex_format_values.sort_order IS
$DOC$Indicates the sort ordering of the particular value record with the lowest value
sorting first.  When a value record for an enumeration is inserted or updated
and this column is being set to a value which equals another enumeration value
record for the same enumeration, the system assumes that the new record is
being set to precede the existing record and it will be set to sort after the
newly inserted/updated enumeration value.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_complex_format_values.syst_data IS
$DOC$For the system expected data definition this column identifies the individual
fields that make up the complex format type along with the expected type and
other expected metadata for each field.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_complex_format_values.syst_form IS
$DOC$Describes how the individual data fields of the complex format are
presented in user interfaces and printed documents.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_complex_format_values.user_data IS
$DOC$Allows for custom user data fields to be defined in place of the system provided
data in syst_data.  Note that when this column is not null, it replaces the
system definition: it does not augment it.  This means that any system expected
data fields should also appear in the user data.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_complex_format_values.user_form IS
$DOC$Allows for custom user layout of the format data fields in user interfaces and
other user presentations.  Note that when this column is not null, it replaces
the system definition and so any system expected layout elements should also
be accounted for in this user layout.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_complex_format_values.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_complex_format_values.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_complex_format_values.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_complex_format_values.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_complex_format_values.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_complex_format_values.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_complex_format_values.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst_priv.trig_a_iu_complex_format_value_check()
RETURNS trigger AS
$BODY$

-- File:        trig_a_iu_complex_format_value_check.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_formats/ms_syst_priv/trigger_functions/trig_a_iu_complex_format_value_check.eex.sql
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
    var_format_name   text COLLATE ms_syst_priv.variant_insensitive := tg_argv[0];
    var_format_column text COLLATE ms_syst_priv.variant_insensitive := tg_argv[1];
    var_new_json      jsonb                                            := to_jsonb(NEW);

BEGIN

    IF NOT exists( SELECT
                       TRUE
                   FROM ms_syst_data.syst_complex_format_values cev
                   JOIN ms_syst_data.syst_complex_formats ce ON ce.id = cev.complex_format_id
                   WHERE
                         ce.internal_name = var_format_name
                     AND cev.id = ( var_new_json ->> var_format_column )::uuid )
    THEN
        RAISE EXCEPTION
            USING
                MESSAGE =
                    format('The format value %1$s was not found for format %2$s.'
                        ,( var_new_json ->> var_format_column )::uuid
                        ,var_format_name),
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst_priv'
                            ,p_proc_name      => 'trig_a_iu_complex_format_value_check'
                            ,p_exception_name => 'complex_format_value_not_found'
                            ,p_errcode        => 'PM005'
                            ,p_param_data     => to_jsonb(tg_argv)
                            ,p_context_data   =>
                                jsonb_build_object(
                                     'tg_op',         tg_op
                                    ,'tg_when',       tg_when
                                    ,'tg_schema',     tg_table_schema
                                    ,'tg_table_name', tg_table_name)),
                ERRCODE = 'PM005',
                SCHEMA = tg_table_schema,
                TABLE = tg_table_name;
    END IF;

    RETURN NULL;

END;

$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION ms_syst_priv.trig_a_iu_complex_format_value_check()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_priv.trig_a_iu_complex_format_value_check() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_priv.trig_a_iu_complex_format_value_check() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst_priv.trig_a_iu_complex_format_value_check() IS
$DOC$A constraint trigger function to provide foreign key like validation of columns
which reference syst_complex_format_values.  This relationship requires the
additional check so that only values from the desired format are used in
assigning to records.$DOC$;
-- File:        syst_numberings.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_docnum/ms_syst_data/syst_numberings/syst_numberings.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_numberings
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_numberings_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_numberings_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_numberings_display_name_udx UNIQUE
    ,syst_description
        text
        NOT NULL
    ,user_description
        text
    ,feature_id
        uuid
        NOT NULL
        CONSTRAINT syst_numberings_feature_fk
            REFERENCES ms_syst_data.syst_feature_map (id)
    ,syst_defined
        boolean
        NOT NULL DEFAULT FALSE
    ,user_maintainable
        boolean
        NOT NULL DEFAULT TRUE
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
);

ALTER TABLE ms_syst_data.syst_numberings OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_numberings FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_numberings TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_numberings
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE ms_syst_data.syst_numberings IS
$DOC$Records the available numbering sequences in the system.  These may be system
created or user created.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numberings.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numberings.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numberings.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numberings.syst_description IS
$DOC$A default description of the numbering which might include details such as how
the numbering is used.

Note that users should not change this value.  For custom descriptions, use the
ms_syst_data.syst_numberings.user_description field instead.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numberings.user_description IS
$DOC$A user defined description of the numbering to support custom user documentation
of the purpose and function of the numbering.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numberings.feature_id IS
$DOC$A reference to the specific feature of which the numbering is considered to be
part.  This reference is chiefly used to determine where in the configuration
options the numbering should appear.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numberings.syst_defined IS
$DOC$If true, this value indicates that the numbering is considered part of the
application.  Often times, system numberings are manageable by users, but the
existence of the numbering in the system is assumed to exist by the
application.  If false, the assumption is that the numbering was created by
users and supports custom user functionality.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numberings.user_maintainable IS
$DOC$When true, this column indicates that the numbering is user maintainable;
this might include the ability to add, edit, or remove numbering values such as
segments.  When false, the numbering is strictly system managed for any
functional purpose.  Note that the value of this column doesn't effect the
ability to set a user_description value; the ability to set custom descriptions
is always available for any properly authorized user.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numberings.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numberings.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numberings.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numberings.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numberings.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numberings.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numberings.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst_data.trig_a_i_syst_numbering_sequence_create_value()
RETURNS trigger AS
$BODY$

-- File:        trig_a_i_syst_numbering_sequence_create_value.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_docnum/ms_syst_data/syst_numbering_sequences/trig_a_i_syst_numbering_sequence_create_value.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

BEGIN

    INSERT INTO ms_syst_data.syst_numbering_sequence_values
        ( id, next_value )
    VALUES
        ( new.id, CASE sign( new.value_increment )
                      WHEN 1  THEN lower(new.allowed_value_range)
                      WHEN -1 THEN upper(new.allowed_value_range)
                  END );

    RETURN NULL;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION ms_syst_data.trig_a_i_syst_numbering_sequence_create_value()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_data.trig_a_i_syst_numbering_sequence_create_value() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_data.trig_a_i_syst_numbering_sequence_create_value() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst_data.trig_a_i_syst_numbering_sequence_create_value() IS
$DOC$Automatically creates a ms_syst_data.syst_numbering_sequence_values record
based on the configuration of the sequence in the syst_numbering_sequences
record.  If a sequence is incrementing, the minimum value is used set as the
next value; if the sequence is decrementing, the maximum value is used to set
the starting value.$DOC$;
-- File:        syst_numbering_sequences.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_docnum/ms_syst_data/syst_numbering_sequences/syst_numbering_sequences.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_numbering_sequences
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_numbering_sequences_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_numbering_sequences_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_numbering_sequences_display_name_udx UNIQUE
    ,globally_assignable
        boolean
        NOT NULL DEFAULT FALSE
    ,allowed_value_range
        int8range
        NOT NULL DEFAULT int8range(1, 9223372036854775806, '[]')
    ,value_increment
        bigint
        NOT NULL DEFAULT 1
        CONSTRAINT syst_numbering_sequences_value_increment_validation_chk
            CHECK (sign(value_increment) != 0)
    ,style_type
        text
        NOT NULL DEFAULT 'base10'
        CONSTRAINT syst_numbering_segments_numeric_representation_type_chk
            CHECK (style_type IN
                   ('base10', 'base36', 'obfuscated_base36', 'alpha_base26'))
    ,cycle_policy
        text
        NOT NULL DEFAULT 'error'
        CONSTRAINT syst_numbering_segments_sequence_cycle_policy_chk
            CHECK ( cycle_policy IN
                    ( 'cycle', 'error' ) )
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
);

ALTER TABLE ms_syst_data.syst_numbering_sequences OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_numbering_sequences FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_numbering_sequences TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_numbering_sequences
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE TRIGGER a50_trig_a_i_syst_numbering_sequence_create_value
    AFTER INSERT ON ms_syst_data.syst_numbering_sequences
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_data.trig_a_i_syst_numbering_sequence_create_value();

COMMENT ON
    TABLE ms_syst_data.syst_numbering_sequences IS
$DOC$For numbering segments which are driven by a numbering sequence, this record
defines the configuration settings which influence behavior the behavior of the
sequence.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_sequences.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_sequences.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_sequences.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_sequences.globally_assignable IS
$DOC$If true, the numbering sequence may be used by more than one segment or more
than one numbering configuration.  If false, the sequence backs a single,
specific numbering segment.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_sequences.allowed_value_range IS
$DOC$The range of valid values that the sequence may dispense.  By default the
valid range is 1 to 9223372036854775806, though the range may be defined for any
values between -9223372036854775807 and 9223372036854775806, +/- 1 of the
PostgreSQL bigint data type's maximum values.  Please note that the trigger
condition for either cycling the sequence or raising a sequence range exceed
exception is when the next_value column is found to be minimum allowed value -1
or the maximum allowed value +1; the cycle or exception will happen when a
request would be answered with an out-of-range value, not at the time the last
value allowed by the range was consumed.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_sequences.value_increment IS
$DOC$The value by which the number is incremented or decremented when a request for
a numbering sequence value is made.  This value must be set to a non-zero value.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_sequences.style_type IS
$DOC$Indicates the presentation style of the value.  Supported style types are:

    *  base10:            Typical decimal numeric formatting.

    *  base36:            A representation of the value using digits 0-9 & A-Z.

    *  obfuscated_base36: Same as base36 except the number places are mixed in
                          order to obscure the sequence nature of the underlying
                          numbering scheme.  This scheme works best when the
                          allowed_value_range is set to generate numbers with
                          sufficient size to create 6 or more base36 digits.

    *  alpha_base26:      Number values are represented only as alphabetic
                          values (A-Z).  This numbering system is base26 and
                          so does achieve some value compression as compared to
                          base10/decimal.
$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_sequences.cycle_policy IS
$DOC$Indicates what the correct course of action is once a numbering sequence has
reached the limit of its allowed_value_range.  The acceptable values for ths
column are:

    *  cycle: Restart the numbering at the beginning of the range as determined
              by the value_increment.

    *  error: Raise an exception and cease to produce values from the sequence.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_sequences.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_sequences.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_sequences.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_sequences.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_sequences.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_sequences.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_sequences.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
-- File:        syst_numbering_sequence_values.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_docnum/ms_syst_data/syst_numbering_sequence_values/syst_numbering_sequence_values.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_numbering_sequence_values
(
     id
        uuid
        CONSTRAINT syst_numbering_sequence_values_pk PRIMARY KEY
        CONSTRAINT syst_numbering_sequence_values_numbering_sequences_fk
            REFERENCES ms_syst_data.syst_numbering_sequences (id)
    ,next_value
        bigint
);

ALTER TABLE ms_syst_data.syst_numbering_sequence_values OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_numbering_sequence_values FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_numbering_sequence_values TO <%= ms_owner %>;

COMMENT ON
    TABLE ms_syst_data.syst_numbering_sequence_values IS
$DOC$Contains the next value for a parent numbering sequence.

This is a quantitative table which is, one record for one record, related to the
qualitative data table ms_syst_data.syst_numbering_sequences. As such,
records in this table are created automatically when a new
syst_numbering_sequences record is inserted and the primary key in this table is
set to be the same as its parent syst_numbering_sequences record's primary key
value.

Values are consumed from a numbering sequence by calling the function
ms_syst_priv.get_next_sequence_value and can be set to a specific desired
value using function ms_syst_priv.set_next_sequence_value.  These functions
ensure that the correct updating, locking, and validation are applied to the
sequence value.  Direct updating of these records is discouraged.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_sequence_values.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_sequence_values.next_value IS
$DOC$The next value to be returned to callers requesting a number from the
sequence.  Note that consuming a sequence should typically be handled using a
SELECT FOR UPDATE or similar row locking strategy; the assumption being that any
sequence may be supporting a gap-less numbering need in the application.$DOC$;
CREATE OR REPLACE FUNCTION
    ms_syst_priv.get_next_sequence_value( p_numbering_sequence_id uuid )
RETURNS bigint AS
$BODY$

-- File:        get_next_sequence_value.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_docnum/ms_syst_priv/functions/get_next_sequence_value.eex.sql
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
    var_context_data   record;
    var_new_next_value bigint;
    var_return_value   bigint;

BEGIN

    SELECT INTO var_context_data
         sns.id
        ,sns.allowed_value_range
        ,sns.cycle_policy
        ,sns.value_increment
        ,snsv.next_value
    FROM ms_syst_data.syst_numbering_sequences  sns
        JOIN ms_syst_data.syst_numbering_sequence_values snsv
            ON snsv.id = sns.id
    WHERE sns.id = p_numbering_sequence_id
    FOR NO KEY UPDATE OF ms_syst_data.syst_numbering_sequence_values;

    var_return_value   := var_context_data.next_value;

    -- It's possible that next_value + value_increment can exceed both the bounds of the
    -- allowed_value_range and even the data type of next_value.  So we need to test for that and
    -- be sure that we don't create some sort of error condition because we broke the type bounds on
    -- update.
    IF NOT var_context_data.allowed_value_range @> var_context_data.next_value THEN

        CASE var_context_data.cycle_policy
            WHEN 'cycle' THEN

                var_return_value :=
                    CASE sign(var_context_data.value_increment)
                        WHEN 1 THEN lower(var_context_data.allowed_value_range)
                        WHEN -1 THEN upper(var_context_data.allowed_value_range)
                    END;

                var_new_next_value := var_return_value + var_context_data.value_increment;

            WHEN 'error' THEN

                RAISE EXCEPTION
                    USING
                        MESSAGE = 'The requested numbering sequence has exhausted its available ' ||
                                  'values and is not allowed to automatically cycle back to its ' ||
                                  'starting value.',
                        DETAIL  = ms_syst_priv.get_exception_details(
                                     p_proc_schema    => 'ms_syst_priv'
                                    ,p_proc_name      => 'get_next_sequence_value'
                                    ,p_exception_name => 'numbering_sequence_out_of_range'
                                    ,p_errcode        => 'PM006'
                                    ,p_param_data     =>
                                        jsonb_build_object(
                                             'p_numbering_sequence_id'
                                            ,p_numbering_sequence_id)::jsonb
                                    ,p_context_data   =>
                                        jsonb_build_object(
                                             'var_context_data',  to_jsonb(var_context_data))),
                        ERRCODE = 'PM006',
                        SCHEMA  = 'ms_syst_data',
                        TABLE   = 'syst_numbering_sequence_values';

        END CASE;

    ELSIF
        sign(var_context_data.value_increment) = 1 AND
        var_context_data.value_increment > upper(var_context_data.allowed_value_range) -
                                           var_context_data.next_value
    THEN

        var_new_next_value := upper(var_context_data.allowed_value_range) + 1;

    ELSIF
        sign(var_context_data.value_increment) = -1 AND
        abs(var_context_data.value_increment) > var_context_data.next_value -
                                                lower(var_context_data.allowed_value_range)
    THEN

        var_new_next_value := lower(var_context_data.allowed_value_range) - 1;

    ELSE

        var_new_next_value := var_context_data.next_value + var_context_data.value_increment;

    END IF;

    UPDATE ms_syst_data.syst_numbering_sequence_values SET
        next_value = var_new_next_value
    WHERE id = var_context_data.id;

    RETURN var_return_value;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION
    ms_syst_priv.get_next_sequence_value( uuid ) OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION
    ms_syst_priv.get_next_sequence_value( uuid ) FROM public;
GRANT EXECUTE ON FUNCTION
    ms_syst_priv.get_next_sequence_value( uuid ) TO <%= ms_owner %>;

COMMENT ON FUNCTION
    ms_syst_priv.get_next_sequence_value( uuid ) IS
$DOC$Returns the next value for the requested numbering sequence.

If the sequence has exhausted all values in the allowed range of values, this
function will $DOC$;
CREATE OR REPLACE FUNCTION ms_syst_priv.set_next_sequence_values(p_numbering_sequence_id uuid, p_new_value bigint)
RETURNS void AS
$BODY$

-- File:        set_next_sequence_value.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_docnum/ms_syst_priv/functions/set_next_sequence_value.eex.sql
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
    var_context_data record;
BEGIN

    SELECT INTO var_context_data
         NOT p_new_value @> allowed_value_range AS new_value_disallowed
        ,allowed_value_range
    FROM ms_syst_data.syst_numbering_sequences sns
        JOIN ms_syst_data.syst_numbering_sequence_values snsv
            ON snsv.id = sns.id
    WHERE sns.id = p_numbering_sequence_id
    FOR UPDATE OF ms_syst_data.syst_numbering_sequence_values;


    IF var_context_data.new_value_disallowed THEN

        RAISE EXCEPTION
            USING
                MESSAGE = 'The requested new value for the numbering sequence is outside of the ' ||
                          'acceptable range of values. ',
                DETAIL  = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst_priv'
                            ,p_proc_name      => 'set_next_sequence_value'
                            ,p_exception_name => 'numbering_sequence_out_of_range'
                            ,p_errcode        => 'PM007'
                            ,p_param_data     =>
                                jsonb_build_object(
                                     'p_numbering_sequence_id'
                                    ,p_numbering_sequence_id
                                    ,'p_new_value'
                                    ,p_new_value)::jsonb
                            ,p_context_data   =>
                                jsonb_build_object(
                                     'var_context_data',  to_jsonb(var_context_data))),
                ERRCODE = 'PM007',
                SCHEMA  = 'ms_syst_data',
                TABLE   = 'syst_numbering_sequence_values';

    END IF;

    UPDATE ms_syst_data.syst_numbering_sequence_values SET
        next_value = p_new_value
    WHERE id = p_numbering_sequence_id;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION
    ms_syst_priv.set_next_sequence_values( uuid,  bigint )
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION
    ms_syst_priv.set_next_sequence_values( uuid,  bigint ) FROM public;
GRANT EXECUTE ON FUNCTION
    ms_syst_priv.set_next_sequence_values( uuid,  bigint ) TO <%= ms_owner %>;



COMMENT ON FUNCTION
    ms_syst_priv.set_next_sequence_values( uuid, bigint ) IS
$DOC$Set the value of a numbering sequence.  Using this function ensures that the
targeted new value is within the acceptable ranges of the sequence.  Note that
this function is only needed when setting the value to an entirely new value and
it is not needed after a value has been retrieved from the numbering sequence.$DOC$;
-- File:        syst_numbering_segment_types.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_docnum/ms_syst_data/syst_numbering_segment_types/syst_numbering_segment_types.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_numbering_segment_types
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_numbering_segment_types_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_numbering_segment_types_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_numbering_segment_types_display_name_udx UNIQUE
    ,syst_description
        text
        NOT NULL
    ,user_description
        text
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
);

ALTER TABLE ms_syst_data.syst_numbering_segment_types OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_numbering_segment_types FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_numbering_segment_types TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_numbering_segment_types
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE ms_syst_data.syst_numbering_segment_types IS
$DOC$Enumerates the available kinds of segments which may be used to construct an
application numbering system.  Note that as of this writing, these records are
not considered user configurable beyond setting a custom user_description value.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_segment_types.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_segment_types.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_segment_types.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_segment_types.syst_description IS
$DOC$A text describing the capabilities, requirements, and use cases of a given
numbering segment type.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_segment_types.user_description IS
$DOC$A custom user defined description of a numbering segment type which overrides
the system provided description found in syst_description, if provided.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_segment_types.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_segment_types.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_segment_types.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_segment_types.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_segment_types.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_segment_types.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_segment_types.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
-- File:        syst_numbering_segments.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_docnum/ms_syst_data/syst_numbering_segments/syst_numbering_segments.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_numbering_segments
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_numbering_segments_pk PRIMARY KEY
    ,numbering_id
        uuid
        NOT NULL
        CONSTRAINT syst_numbering_segments_numberings_fk
            REFERENCES ms_syst_data.syst_numberings (id) ON DELETE CASCADE
    ,sort_order
        smallint
        NOT NULL DEFAULT 1
    ,numbering_segment_type_id
        uuid
        NOT NULL
        CONSTRAINT syst_numbering_segments_numbering_segment_types_fk
            REFERENCES ms_syst_data.syst_numbering_segment_types (id)
    ,display_length
        smallint
        NOT NULL
        CONSTRAINT syst_numbering_segments_display_length_validation_chk
            CHECK ( display_length >= 0 )
    ,use_padding
        boolean
        NOT NULL DEFAULT TRUE
    ,padding_side
        text
        CONSTRAINT syst_numbering_segments_padding_side_validation_chk
            CHECK ( NOT use_padding OR
                    (padding_side IS NOT NULL AND
                     padding_side IN ('start', 'end')) )
    ,padding_text
        text
        CONSTRAINT syst_numbering_segments_padding_text_validation_chk
            CHECK ( NOT use_padding OR padding_text IS NOT NULL )
    ,fixed_text
        text
        CONSTRAINT syst_numbering_segments_fixed_text_validation_chk
            CHECK ( fixed_text IS NULL OR length(fixed_text) <= display_length )
    ,freetext_validator
        text
    ,enum_id
        uuid
        CONSTRAINT syst_numbering_segments_enums_fk
            REFERENCES ms_syst_data.syst_enums (id)
    ,numbering_sequence_id
        uuid
        CONSTRAINT syst_numbering_segments_numbering_sequences_fk
            REFERENCES ms_syst_data.syst_numbering_sequences (id)
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
    ,CONSTRAINT syst_numbering_segments_numbering_sort_order_udx
        UNIQUE ( numbering_id, sort_order )
);

ALTER TABLE ms_syst_data.syst_numbering_segments OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_numbering_segments FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_numbering_segments TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_numbering_segments
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE ms_syst_data.syst_numbering_segments IS
$DOC$Defines the segments which make up a "numbering" in the application.  Segments $DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_segments.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_segments.sort_order IS
$DOC$Determines the positioning of the segment in the final number constructed from
all segments.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_segments.numbering_segment_type_id IS
$DOC$References the syst_numbering_segment_types table to define the type of
segment represented by the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_segments.display_length IS
$DOC$Sets the presentation length of sequence.  Numbering values that exceed the
display length will raise exceptions.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_segments.use_padding IS
$DOC$If true, any numbering values which would present fewer characters than the
display length will be padded using the padding_text value up to the display
length.  If false, no padding is used and the presentation of the segment may
vary.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_segments.padding_side IS
$DOC$If padding is used, then this value determines on which side of the numbering
value the padding should be applied.  Possible values are:

    * left:  Padding will be added to the left of the numbering value.

    * right: Padding will be added to the right of the numbering value.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_segments.padding_text IS
$DOC$The text to be used in applying padding to numbering values.  If the
padding_text is smaller than the display_length of the segment, the padding text
may be applied repeatedly to fill the unused characters up to the display
length.  If the padding text is larger than the display_length, then any
characters that are beyond the display_length are simply ignored.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_segments.fixed_text IS
$DOC$If the segment is of a fixed text segment type, this column records the
numbering value.  Note that this value must not exceed the display_length value
of the segment.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_segments.freetext_validator IS
$DOC$A regular expression which will allow the application to test whether or not
a presented free text value meets the expectations of the numbering segment.
Such a validation might restrict a free text numbering value to be only numeric
or all upper case, etc.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_segments.enum_id IS
$DOC$If the segment type indicates that the segment gets its value from an
list of values configured in the system's enumerations, this column identified
which enumeration configuration is used to generate the list of values.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_segments.numbering_sequence_id IS
$DOC$If the segment is of a numeric sequence type, this column references the
sequence to be used in generating numbers.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_segments.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_segments.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_segments.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_segments.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_segments.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_segments.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_numbering_segments.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
-- File:        initialize_numbering_segment_types.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_docnum/seed_data/initialize_numbering_segment_types.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

INSERT INTO ms_syst_data.syst_numbering_segment_types
    ( internal_name, display_name, syst_description )
VALUES
    ( 'enumeration'
    , 'List of Values'
    , 'References a configured enumeration which provides choices from which the segment values are drawn.' )
     ,
    ( 'sequence'
    , 'Sequential Number'
    , 'A sequential numbering.  Supports increment/decrement, skip sequencing, and gap-less sequencing.' )
     ,
    ( 'fixed_text'
    , 'Fixed Text'
    , 'A fixed text segment which can be used to define separators, prefixes, suffixes, or other static elements.' )
     ,
    ( 'free_text'
    , 'Free Text'
    , 'Allows users to enter arbitrary text, subject to a pattern matched validation.' )
     ,
    ( 'random', 'Random Number', 'Generates random numbers.' )
     ,
    ( 'sequence_in_prior'
    , 'Sequence In Prior'
    , 'Returns an incrementing sequential number within a grouping defined by the prior segments.' );
-- File:        initialize_enum_login_states.eex.sql
-- Location:    musebms/database/application/msbms/mod_syst/seed_data/initialize_enum_login_states.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

DO
$INIT_ENUM$
BEGIN

PERFORM
    ms_syst_priv.initialize_enum(
        p_enum_def => $INIT_ENUM_LOGIN_STATES$
        {
          "internal_name": "login_states",
          "display_name": "Login States",
          "syst_description": "Defines the life-cycle states in which user login records may exist.",
          "syst_defined": true,
          "user_maintainable": true,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [],
          "enum_items": []
        }
            $INIT_ENUM_LOGIN_STATES$::jsonb);

END;
$INIT_ENUM$;
-- File:        initialize_enum_interaction_types.eex.sql
-- Location:    musebms/database/application/msbms/mod_syst/seed_data/initialize_enum_interaction_types.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

DO
$INIT_ENUM$
BEGIN

PERFORM
    ms_syst_priv.initialize_enum(
        p_enum_def => $INIT_ENUM_INTERACTION_TYPES$
        {
          "internal_name": "interaction_types",
          "display_name": "Interaction Types",
          "syst_description": "Identifies classes of actions that a user or external system may request of the application.",
          "syst_defined": true,
          "user_maintainable": true,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [],
          "enum_items": []
        }
            $INIT_ENUM_INTERACTION_TYPES$::jsonb);

END;
$INIT_ENUM$;
-- File:        initialize_enum_interface_types.eex.sql
-- Location:    musebms/database/application/msbms/mod_syst/seed_data/initialize_enum_interface_types.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

DO
$INIT_ENUM$
BEGIN

PERFORM
    ms_syst_priv.initialize_enum(
        p_enum_def => $INIT_ENUM_INTERFACE_TYPES$
        {
          "internal_name": "interface_types",
          "display_name": "Interface Types",
          "syst_description": "Lists the different supported entry points use to interact with the application.",
          "syst_defined": true,
          "user_maintainable": true,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [],
          "enum_items": []
        }
            $INIT_ENUM_INTERFACE_TYPES$::jsonb);

END;
$INIT_ENUM$;
-- File:        initialize_enum_address_states.eex.sql
-- Location:    musebms/database/application/msbms/mod_brm/seed_data/initialize_enum_address_states.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

DO
$INIT_ENUM$
BEGIN

PERFORM
    ms_syst_priv.initialize_enum(
        p_enum_def => $INIT_ENUM_ADDRESS_STATES$
        {
          "internal_name": "address_states",
          "display_name": "Address States",
          "syst_description": "Defines the life-cycle states for addresses in the system.",
          "syst_defined": true,
          "user_maintainable": true,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [],
          "enum_items": []
        }
            $INIT_ENUM_ADDRESS_STATES$::jsonb);

END;
$INIT_ENUM$;
-- File:        initialize_enum_contact_states.eex.sql
-- Location:    musebms/database/application/msbms/mod_brm/seed_data/initialize_enum_contact_states.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

DO
$INIT_ENUM$
BEGIN

PERFORM
    ms_syst_priv.initialize_enum(
        p_enum_def => $INIT_ENUM_CONTACT_STATES$
        {
          "internal_name": "contact_states",
          "display_name": "Contact States",
          "syst_description": "Establishes the available life-cycle states for contact information.",
          "syst_defined": true,
          "user_maintainable": true,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [],
          "enum_items": []
        }
            $INIT_ENUM_CONTACT_STATES$::jsonb);

END;
$INIT_ENUM$;
-- File:        initialize_enum_contact_types.eex.sql
-- Location:    musebms/database/application/msbms/mod_brm/seed_data/initialize_enum_contact_types.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

DO
$INIT_ENUM$
BEGIN

PERFORM
    ms_syst_priv.initialize_enum(
        p_enum_def => $INIT_ENUM_CONTACT_TYPES$
        {
          "internal_name": "contact_types",
          "display_name": "Contact Types",
          "syst_description": "Identifies the available types of contact that may be associated with a person, entity, or place.",
          "syst_defined": true,
          "user_maintainable": true,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [
            {
              "internal_name": "contact_types_phone",
              "display_name": "Contact Type / Phone",
              "external_name": "Phone",
              "syst_description": "Telephone system dependent communications.  Contacts of this type will include formatting information from the configured phone number formats."
            },
            {
              "internal_name": "contact_types_physical_address",
              "display_name": "Contact Type / Physical Address",
              "external_name": "Physical Address",
              "syst_description": "Street and mailing addresses.  Contacts of this type will include formatting information from the configured street address formats."
            },
            {
              "internal_name": "contact_types_email_address",
              "display_name": "Contact Type / Email Address",
              "external_name": "Email Address",
              "syst_description": "Email address"
            },
            {
              "internal_name": "contact_types_website",
              "display_name": "Contact Type / Website",
              "external_name": "Website",
              "syst_description": "Website URL"
            },
            {
              "internal_name": "contact_types_chat",
              "display_name": "Contact Type / Chat",
              "external_name": "Chat",
              "syst_description": "Chat & messaging user and service."
            },
            {
              "internal_name": "contact_types_social_media",
              "display_name": "Contact Type / Social Media",
              "external_name": "Social Media",
              "syst_description": "Social media account name and service."
            },
            {
              "internal_name": "contact_types_generic",
              "display_name": "Contact Type / Generic",
              "external_name": "Generic",
              "syst_description": "A miscellaneous type to record non-functional, but still needed contact information."
            }
          ],
          "enum_items": [
            {
              "internal_name": "contact_types_sysdef_phone",
              "display_name": "Contact Type / Phone",
              "external_name": "Phone",
              "functional_type_name": "contact_types_phone",
              "enum_default": true,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "Telephone system dependent communications.  Contacts of this type will include formatting information from the configured phone number formats.",
              "syst_options": {}
            },
            {
              "internal_name": "contact_types_sysdef_physical_address",
              "display_name": "Contact Type / Physical Address",
              "external_name": "Physical Address",
              "functional_type_name": "contact_types_physical_address",
              "enum_default": true,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "Street and mailing addresses.  Contacts of this type will include formatting information from the configured street address formats.",
              "syst_options": {}
            },
            {
              "internal_name": "contact_types_sysdef_email_address",
              "display_name": "Contact Type / Email Address",
              "external_name": "Email Address",
              "functional_type_name": "contact_types_email_address",
              "enum_default": true,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "Email address",
              "syst_options": {}
            },
            {
              "internal_name": "contact_types_sysdef_website",
              "display_name": "Contact Type / Website",
              "external_name": "Website",
              "functional_type_name": "contact_types_website",
              "enum_default": true,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "Website URL",
              "syst_options": {}
            },
            {
              "internal_name": "contact_types_sysdef_chat",
              "display_name": "Contact Type / Chat",
              "external_name": "Chat",
              "functional_type_name": "contact_types_chat",
              "enum_default": true,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "Chat & messaging user and service.",
              "syst_options": {}
            },
            {
              "internal_name": "contact_types_sysdef_social_media",
              "display_name": "Contact Type / Social Media",
              "external_name": "Social Media",
              "functional_type_name": "contact_types_social_media",
              "enum_default": true,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "Social media account name and service.",
              "syst_options": {}
            },
            {
              "internal_name": "contact_types_sysdef_generic",
              "display_name": "Contact Type / Generic",
              "external_name": "Generic",
              "functional_type_name": "contact_types_generic",
              "enum_default": true,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "A miscellaneous type to record non-functional, but still needed contact information.",
              "syst_options": {}
            }
          ]
        }
            $INIT_ENUM_CONTACT_TYPES$::jsonb);

END;
$INIT_ENUM$;
-- File:        initialize_enum_entity_person_roles.eex.sql
-- Location:    musebms/database/application/msbms/mod_brm/seed_data/initialize_enum_entity_person_roles.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

DO
$INIT_ENUM$
BEGIN

PERFORM
    ms_syst_priv.initialize_enum(
        p_enum_def => $INIT_ENUM_ENTITY_PERSON_ROLES$
        {
          "internal_name": "entity_person_roles",
          "display_name": "Entity - Person Roles",
          "syst_description": "Defines the various roles which a person may assume on behalf of a given entity.",
          "syst_defined": true,
          "user_maintainable": true,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [],
          "enum_items": []
        }
            $INIT_ENUM_ENTITY_PERSON_ROLES$::jsonb);

END;
$INIT_ENUM$;
-- File:        initialize_enum_entity_place_roles.eex.sql
-- Location:    musebms/database/application/msbms/mod_brm/seed_data/initialize_enum_entity_place_roles.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

DO
$INIT_ENUM$
BEGIN

PERFORM
    ms_syst_priv.initialize_enum(
        p_enum_def => $INIT_ENUM_ENTITY_PLACE_ROLES$
        {
          "internal_name": "entity_place_roles",
          "display_name": "Entity - Place Roles",
          "syst_description": "Defines the different roles that a given place may assume for a specific entity.",
          "syst_defined": true,
          "user_maintainable": true,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [],
          "enum_items": []
        }
            $INIT_ENUM_ENTITY_PLACE_ROLES$::jsonb);

END;
$INIT_ENUM$;
-- File:        initialize_enum_entity_states.eex.sql
-- Location:    musebms/database/application/msbms/mod_brm/seed_data/initialize_enum_entity_states.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

DO
$INIT_ENUM$
BEGIN

PERFORM
    ms_syst_priv.initialize_enum(
        p_enum_def => $INIT_ENUM_ENTITY_STATES$
        {
          "internal_name": "entity_states",
          "display_name": "Entity States",
          "syst_description": "Lifecycle management stages for business entities.",
          "syst_defined": true,
          "user_maintainable": true,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [],
          "enum_items": []
        }
            $INIT_ENUM_ENTITY_STATES$::jsonb);

END;
$INIT_ENUM$;
-- File:        initialize_enum_entity_types.eex.sql
-- Location:    musebms/database/application/msbms/mod_brm/seed_data/initialize_enum_entity_types.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

DO
$INIT_ENUM$
BEGIN

PERFORM
    ms_syst_priv.initialize_enum(
        p_enum_def => $INIT_ENUM_ENTITY_TYPES$
        {
          "internal_name": "entity_types",
          "display_name": "Entity Types",
          "syst_description": "Lists the different kinds of legal business entities with which business is conducted.",
          "syst_defined": true,
          "user_maintainable": true,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [],
          "enum_items": []
        }
            $INIT_ENUM_ENTITY_TYPES$::jsonb);

END;
$INIT_ENUM$;
-- File:        initialize_enum_person_contact_roles.eex.sql
-- Location:    musebms/database/application/msbms/mod_brm/seed_data/initialize_enum_person_contact_roles.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

DO
$INIT_ENUM$
BEGIN

PERFORM
    ms_syst_priv.initialize_enum(
        p_enum_def => $INIT_ENUM_PERSON_CONTACT_ROLES$
        {
          "internal_name": "person_contact_roles",
          "display_name": "Person - Contact Roles",
          "syst_description": "Defines the role that a contact information record may fulfill with a given person.  This could be mailing address, mobile phone contact, primary email, etc.",
          "syst_defined": true,
          "user_maintainable": true,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [],
          "enum_items": []
        }
            $INIT_ENUM_PERSON_CONTACT_ROLES$::jsonb);

END;
$INIT_ENUM$;
-- File:        initialize_enum_person_states.eex.sql
-- Location:    musebms/database/application/msbms/mod_brm/seed_data/initialize_enum_person_states.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

DO
$INIT_ENUM$
BEGIN

PERFORM
    ms_syst_priv.initialize_enum(
        p_enum_def => $INIT_ENUM_PERSON_STATES$
        {
          "internal_name": "person_states",
          "display_name": "Person States",
          "syst_description": "Lifecycle management stages for persons.",
          "syst_defined": true,
          "user_maintainable": true,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [],
          "enum_items": []
        }
            $INIT_ENUM_PERSON_STATES$::jsonb);

END;
$INIT_ENUM$;
-- File:        initialize_enum_person_types.eex.sql
-- Location:    musebms/database/application/msbms/mod_brm/seed_data/initialize_enum_person_types.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

DO
$INIT_ENUM$
BEGIN

PERFORM
    ms_syst_priv.initialize_enum(
        p_enum_def => $INIT_ENUM_PERSON_TYPES$
        {
          "internal_name": "person_types",
          "display_name": "Person Types",
          "syst_description": "A list of the various types of entities may be represented by a person.",
          "syst_defined": true,
          "user_maintainable": true,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [
            {
              "internal_name": "person_types_individual",
              "display_name": "Person Type / Individual",
              "external_name": "Individual",
              "syst_description": "In this case the person record represents an actual person."
            },
            {
              "internal_name": "person_types_function",
              "display_name": "Person Type / Function",
              "external_name": "Function",
              "syst_description": "This type indicates that the person is defining a role where the specific person performing that role is not important.  For example, \"Accounts Receivable\" may be a generic person to contact for payment remission or for the resolution of other payment issues.  The key is the specific person contacted is not important but contacting someone acting in that capacity is."
            }
          ],
          "enum_items": [
            {
              "internal_name": "person_types_sysdef_individual",
              "display_name": "Person Type / Individual",
              "external_name": "Individual",
              "functional_type_name": "person_types_individual",
              "enum_default": true,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "In this case the person record represents an actual person.",
              "syst_options": {}
            },
            {
              "internal_name": "person_types_sysdef_function",
              "display_name": "Person Type / Function",
              "external_name": "Function",
              "functional_type_name": "person_types_function",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "This type indicates that the person is defining a role where the specific person performing that role is not important.  For example, \"Accounts Receivable\" may be a generic person to contact for payment remission or for the resolution of other payment issues.  The key is the specific person contacted is not important but contacting someone acting in that capacity is.",
              "syst_options": {}
            }
          ]
        }
            $INIT_ENUM_PERSON_TYPES$::jsonb);

END;
$INIT_ENUM$;
-- File:        initialize_enum_place_address_roles.eex.sql
-- Location:    musebms/database/application/msbms/mod_brm/seed_data/initialize_enum_place_address_roles.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

DO
$INIT_ENUM$
BEGIN

PERFORM
    ms_syst_priv.initialize_enum(
        p_enum_def => $INIT_ENUM_PLACE_ADDRESS_ROLES$
        {
          "internal_name": "place_address_roles",
          "display_name": "Place - Address Roles",
          "syst_description": "Established the roles which an address may assume related to a parent place.",
          "syst_defined": true,
          "user_maintainable": true,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [],
          "enum_items": []
        }
            $INIT_ENUM_PLACE_ADDRESS_ROLES$::jsonb);

END;
$INIT_ENUM$;
-- File:        initialize_enum_place_states.eex.sql
-- Location:    musebms/database/application/msbms/mod_brm/seed_data/initialize_enum_place_states.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

DO
$INIT_ENUM$
BEGIN

PERFORM
    ms_syst_priv.initialize_enum(
        p_enum_def => $INIT_ENUM_PLACE_STATES$
        {
          "internal_name": "pace_states",
          "display_name": "Place States",
          "syst_description": "Defines the available states which govern the place life-cycle and establishes what capabilities are supported in such states by default.",
          "syst_defined": true,
          "user_maintainable": true,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [],
          "enum_items": []
        }
            $INIT_ENUM_PLACE_STATES$::jsonb);

END;
$INIT_ENUM$;
-- File:        initialize_enum_place_types.eex.sql
-- Location:    musebms/database/application/msbms/mod_brm/seed_data/initialize_enum_place_types.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

DO
$INIT_ENUM$
BEGIN

PERFORM
    ms_syst_priv.initialize_enum(
        p_enum_def => $INIT_ENUM_PLACE_TYPES$
        {
          "internal_name": "pace_types",
          "display_name": "Place Types",
          "syst_description": "Establishes the different kinds of places in which the place may be categorized",
          "syst_defined": true,
          "user_maintainable": true,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [],
          "enum_items": []
        }
            $INIT_ENUM_PLACE_TYPES$::jsonb);

END;
$INIT_ENUM$;
-- File:        initialize_enum_fiscal_period_states.eex.sql
-- Location:    musebms/database/application/msbms/mod_accounting/seed_data/initialize_enum_fiscal_period_states.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

DO
$INIT_ENUM$
BEGIN

PERFORM
    ms_syst_priv.initialize_enum(
        p_enum_def => $INIT_ENUM_FISCAL_PERIOD_STATES$
        {
          "internal_name": "fiscal_period_states",
          "display_name": "Fiscal Period States",
          "syst_description": "Life-cycle management stages for fiscal period records.",
          "syst_defined": true,
          "user_maintainable": true,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [],
          "enum_items": []
        }
            $INIT_ENUM_FISCAL_PERIOD_STATES$::jsonb);

END;
$INIT_ENUM$;
-- File:        initialize_enum_fiscal_year_states.eex.sql
-- Location:    musebms/database/application/msbms/mod_accounting/seed_data/initialize_enum_fiscal_year_states.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

DO
$INIT_ENUM$
BEGIN

PERFORM
    ms_syst_priv.initialize_enum(
        p_enum_def => $INIT_ENUM_FISCAL_YEAR_STATES$
        {
          "internal_name": "fiscal_year_states",
          "display_name": "Fiscal Year States",
          "syst_description": "Life-cycle management stages for fiscal year records.",
          "syst_defined": true,
          "user_maintainable": true,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [],
          "enum_items": []
        }
            $INIT_ENUM_FISCAL_YEAR_STATES$::jsonb);

END;
$INIT_ENUM$;
-- File:        initialize_enum_fiscal_year_types.eex.sql
-- Location:    musebms/database/application/msbms/mod_accounting/seed_data/initialize_enum_fiscal_year_types.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

DO
$INIT_ENUM$
BEGIN

PERFORM
    ms_syst_priv.initialize_enum(
        p_enum_def => $INIT_ENUM_FISCAL_YEAR_TYPES$
        {
          "internal_name": "fiscal_year_types",
          "display_name": "Fiscal Year Types",
          "syst_description": "Enumerates the different supported cadences of periods for fiscal years.",
          "syst_defined": true,
          "user_maintainable": true,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [],
          "enum_items": []
        }
            $INIT_ENUM_FISCAL_YEAR_TYPES$::jsonb);

END;
$INIT_ENUM$;
-- File:        syst_interaction_logs.eex.sql
-- Location:    musebms/database/application/msbms/mod_syst/ms_syst_data/syst_interaction_logs/syst_interaction_logs.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_interaction_logs
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_interaction_logs_pk PRIMARY KEY
    ,interaction_timestamp
        timestamptz
        NOT NULL DEFAULT now()
    ,interaction_type_id
        uuid
        NOT NULL
        CONSTRAINT syst_interaction_logs_interaction_types_fk
            REFERENCES ms_syst_data.syst_enum_items ( id )
    ,interface_type_id
        uuid
        NOT NULL
        CONSTRAINT syst_interaction_logs_interface_types_fk
            REFERENCES ms_syst_data.syst_enum_items ( id )
    ,data
        jsonb
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
        NOT NULL
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
        NOT NULL
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
);

ALTER TABLE ms_syst_data.syst_interaction_logs OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_interaction_logs FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_interaction_logs TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_interaction_logs
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_interaction_types_enum_item_check
    AFTER INSERT ON ms_syst_data.syst_interaction_logs
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('interaction_types', 'interaction_type_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_interaction_types_enum_item_check
    AFTER UPDATE ON ms_syst_data.syst_interaction_logs
    FOR EACH ROW WHEN ( old.interaction_type_id != new.interaction_type_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_enum_item_check(
                'interaction_types', 'interaction_type_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_i_interface_types_enum_item_check
    AFTER INSERT ON ms_syst_data.syst_interaction_logs
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('interface_types', 'interface_type_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_interface_types_enum_item_check
    AFTER UPDATE ON ms_syst_data.syst_interaction_logs
    FOR EACH ROW WHEN ( old.interface_type_id != new.interface_type_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_enum_item_check(
                'interface_types', 'interface_type_id');

CREATE INDEX syst_interaction_logs_interaction_timestamp_idx
    ON ms_syst_data.syst_interaction_logs USING brin (interaction_timestamp);

COMMENT ON
    TABLE ms_syst_data.syst_interaction_logs IS
$DOC$Records interactions to drive both system functionality and to provide usage
telemetry.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_interaction_logs.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_interaction_logs.interaction_timestamp IS
$DOC$The nominal time at which the event being recorded is considered to have
happened.  This is the database transaction start time specifically.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_interaction_logs.interaction_type_id IS
$DOC$The kind of interaction being recorded.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_interaction_logs.interface_type_id IS
$DOC$The origin entry point into the application and from which the activity was
initiated.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_interaction_logs.data IS
$DOC$Optional document style data which may more completely elaborate on the activity
being recorded.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_interaction_logs.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_interaction_logs.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_interaction_logs.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_interaction_logs.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_interaction_logs.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_interaction_logs.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_interaction_logs.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;

COMMENT ON
    INDEX ms_syst_data.syst_interaction_logs_interaction_timestamp_idx IS
$DOC$Allows faster searching of specific actions filtering by time; useful for
rate limiting, etc.$DOC$;
-- File:        mstr_countries.eex.sql
-- Location:    musebms/database/application/msbms/mod_brm/ms_appl_data/mstr_countries/mstr_countries.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_appl_data.mstr_countries
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT mstr_countries_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT mstr_countries_internal_name_udx UNIQUE
    ,display_name
        text
        CONSTRAINT mstr_countries_display_name_udx UNIQUE
    ,external_name
        text
        NOT NULL
    ,official_name_ar
        text
    ,official_name_cn
        text
    ,official_name_en
        text
    ,official_name_es
        text
    ,official_name_fr
        text
    ,official_name_ru
        text
    ,iso3166_1_alpha_2
        text
    ,iso3166_1_alpha_3
        text
    ,iso3166_1_numeric
        text
    ,iso4217_currency_alphabetic_code
        text
    ,iso4217_currency_country_name
        text
    ,iso4217_currency_minor_unit
        text
    ,iso4217_currency_name
        text
    ,iso4217_currency_numeric_code
        text
    ,cldr_display_name
        text
    ,capital
        text
    ,continent
        text
    ,ds
        text
    ,dial
        text
    ,edgar
        text
    ,fips
        text
    ,gaul
        text
    ,geoname_id
        text
    ,global_code
        text
    ,global_name
        text
    ,ioc
        text
    ,itu
        text
    ,intermediate_region_code
        text
    ,intermediate_region_name
        text
    ,languages
        text
    ,marc
        text
    ,region_code
        text
    ,region_name
        text
    ,sub_region_code
        text
    ,sub_region_name
        text
    ,tld
        text
    ,wmo
        text
    ,is_independent
        text
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
        NOT NULL
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
        NOT NULL
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
);

ALTER TABLE ms_appl_data.mstr_countries OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_appl_data.mstr_countries FROM public;
GRANT ALL ON TABLE ms_appl_data.mstr_countries TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_appl_data.mstr_countries
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE ms_appl_data.mstr_countries IS
$DOC$A listing of countries including currency symbology, official names, and other
information concering the country from standards bodies and international
organizations.

The table structure as it now stands is based on the data available at:
https://datahub.io/core/country-codes$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_countries.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_countries.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_countries.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interfaces.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_countries.external_name IS
$DOC$A friendly name for externally facing uses such as in postal addressing which
maynot follow accepted international conventions for naming.  Note that this is
not a key value and has no UNIQUE enforcement.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_countries.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_countries.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_countries.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_countries.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_countries.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_countries.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_countries.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
-- File:        mstr_country_address_format_assocs.eex.sql
-- Location:    musebms/database/application/msbms/mod_brm/ms_appl_data/mstr_country_address_format_assocs/mstr_country_address_format_assocs.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_appl_data.mstr_country_address_format_assocs
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT mstr_country_address_format_assocs_pk PRIMARY KEY
    ,country_id
        uuid
        NOT NULL
        CONSTRAINT mstr_country_address_format_assocs_countries_fk
            REFERENCES ms_appl_data.mstr_countries (id) ON DELETE CASCADE
    ,address_format_id
        uuid
        NOT NULL
        CONSTRAINT mstr_country_address_format_assocs_address_formats_fk
            REFERENCES ms_syst_data.syst_complex_format_values (id) ON DELETE CASCADE
    ,is_default_for_country
        boolean
        NOT NULL DEFAULT false
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
        NOT NULL
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
        NOT NULL
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
);

ALTER TABLE ms_appl_data.mstr_country_address_format_assocs OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_appl_data.mstr_country_address_format_assocs FROM public;
GRANT ALL ON TABLE ms_appl_data.mstr_country_address_format_assocs TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_appl_data.mstr_country_address_format_assocs
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_complex_format_value_check
    AFTER INSERT ON ms_appl_data.mstr_country_address_format_assocs
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_complex_format_value_check('address_formats', 'address_format_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_complex_format_value_check
    AFTER UPDATE ON ms_appl_data.mstr_country_address_format_assocs
    FOR EACH ROW WHEN ( old.address_format_id != new.address_format_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_complex_format_value_check(
                'address_formats', 'address_format_id');


COMMENT ON
    TABLE ms_appl_data.mstr_country_address_format_assocs IS
$DOC$Establishes relationships between address format records and country records and
allows recognizing an address format as the default format for the country.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_country_address_format_assocs.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_country_address_format_assocs.country_id IS
$DOC$Identifies the country with with the address format is being associated.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_country_address_format_assocs.address_format_id IS
$DOC$Identifies the address format which is to be associated with the country.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_country_address_format_assocs.is_default_for_country IS
$DOC$If true, this format should be used as the default format for the country. There
should only ever be one default for any one country_id.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_country_address_format_assocs.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_country_address_format_assocs.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_country_address_format_assocs.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_country_address_format_assocs.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_country_address_format_assocs.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_country_address_format_assocs.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_country_address_format_assocs.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
-- File:        mstr_country_phone_format_assocs.eex.sql
-- Location:    musebms/database/application/msbms/mod_brm/ms_appl_data/mstr_country_phone_format_assocs/mstr_country_phone_format_assocs.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_appl_data.mstr_country_phone_format_assocs
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT mstr_country_phone_format_assocs_pk PRIMARY KEY
    ,country_id
        uuid
        NOT NULL
        CONSTRAINT mstr_country_phone_format_assocs_countries_fk
            REFERENCES ms_appl_data.mstr_countries (id)
    ,phone_format_id
        uuid
        NOT NULL
        CONSTRAINT mstr_country_phone_format_assocs_phone_formats_fk
            REFERENCES ms_syst_data.syst_complex_format_values (id)
    ,is_default_for_country
        boolean
        NOT NULL DEFAULT false
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
        NOT NULL
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
        NOT NULL
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
);

ALTER TABLE ms_appl_data.mstr_country_phone_format_assocs OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_appl_data.mstr_country_phone_format_assocs FROM public;
GRANT ALL ON TABLE ms_appl_data.mstr_country_phone_format_assocs TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_appl_data.mstr_country_phone_format_assocs
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_complex_format_value_check
    AFTER INSERT ON ms_appl_data.mstr_country_phone_format_assocs
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_complex_format_value_check('phone_number_formats', 'phone_format_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_complex_format_value_check
    AFTER UPDATE ON ms_appl_data.mstr_country_phone_format_assocs
    FOR EACH ROW WHEN ( old.phone_format_id != new.phone_format_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_complex_format_value_check(
                'phone_number_formats', 'phone_format_id');

COMMENT ON
    TABLE ms_appl_data.mstr_country_phone_format_assocs IS
$DOC$Establishes relationships between phone format records and country records and
allows recognizing an phone format as the default format for the country.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_country_phone_format_assocs.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_country_phone_format_assocs.country_id IS
$DOC$Identifies the country with with the phone format is being associated.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_country_phone_format_assocs.phone_format_id IS
$DOC$Identifies the phone format which is to be associated with the country.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_country_phone_format_assocs.is_default_for_country IS
$DOC$If true, this format should be used as the default format for the country. There
should only ever be one default for any one country_id.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_country_phone_format_assocs.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_country_phone_format_assocs.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_country_phone_format_assocs.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_country_phone_format_assocs.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_country_phone_format_assocs.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_country_phone_format_assocs.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_country_phone_format_assocs.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
-- File:        mstr_country_name_format_assocs.eex.sql
-- Location:    musebms/database/application/msbms/mod_brm/ms_appl_data/mstr_country_name_format_assocs/mstr_country_name_format_assocs.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_appl_data.mstr_country_name_format_assocs
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT mstr_country_name_format_assocs_pk PRIMARY KEY
    ,country_id
        uuid
        NOT NULL
        CONSTRAINT mstr_country_name_format_assocs_countries_fk
            REFERENCES ms_appl_data.mstr_countries (id)
    ,name_format_id
        uuid
        NOT NULL
        CONSTRAINT mstr_country_name_format_assocs_name_formats_fk
            REFERENCES ms_syst_data.syst_complex_format_values (id)
    ,is_default_for_country
        boolean
        NOT NULL DEFAULT false
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
        NOT NULL
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
        NOT NULL
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
);

ALTER TABLE ms_appl_data.mstr_country_name_format_assocs OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_appl_data.mstr_country_name_format_assocs FROM public;
GRANT ALL ON TABLE ms_appl_data.mstr_country_name_format_assocs TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_appl_data.mstr_country_name_format_assocs
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_complex_format_value_check
    AFTER INSERT ON ms_appl_data.mstr_country_name_format_assocs
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_complex_format_value_check('personal_name_formats', 'name_format_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_complex_format_value_check
    AFTER UPDATE ON ms_appl_data.mstr_country_name_format_assocs
    FOR EACH ROW WHEN ( old.name_format_id != new.name_format_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_complex_format_value_check(
                'personal_name_formats', 'name_format_id');

COMMENT ON
    TABLE ms_appl_data.mstr_country_name_format_assocs IS
$DOC$Establishes relationships between name format records and country records and
allows recognizing a name format as the default format for the country.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_country_name_format_assocs.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_country_name_format_assocs.country_id IS
$DOC$Identifies the country with with the name format is being associated.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_country_name_format_assocs.name_format_id IS
$DOC$Identifies the name format which is to be associated with the country.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_country_name_format_assocs.is_default_for_country IS
$DOC$If true, this format should be used as the default format for the country. There
should only ever be one default for any one country_id.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_country_name_format_assocs.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_country_name_format_assocs.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_country_name_format_assocs.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_country_name_format_assocs.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_country_name_format_assocs.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_country_name_format_assocs.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_country_name_format_assocs.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
-- File:        mstr_entities.eex.sql
-- Location:    musebms/database/application/msbms/mod_brm/ms_appl_data/mstr_entities/mstr_entities.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_appl_data.mstr_entities
(
     id
         uuid
         NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT mstr_entities_pk PRIMARY KEY
    ,owning_entity_id
        uuid
        NOT NULL
        CONSTRAINT mstr_entities_entities_fk
            REFERENCES ms_appl_data.mstr_entities (id)
    ,internal_name
        text
        NOT NULL
        CONSTRAINT mstr_entities_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT mstr_entities_display_name_udx UNIQUE
    ,external_name
        text
        NOT NULL
    ,entity_type_id
        uuid
        NOT NULL
        CONSTRAINT mstr_entities_entity_types_fk
            REFERENCES ms_syst_data.syst_enum_items (id)
    ,entity_state_id
        uuid
        NOT NULL
        CONSTRAINT mstr_entities_entity_states_fk
            REFERENCES ms_syst_data.syst_enum_items (id)
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
        NOT NULL
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
        NOT NULL
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
);

ALTER TABLE ms_appl_data.mstr_entities OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_appl_data.mstr_entities FROM public;
GRANT ALL ON TABLE ms_appl_data.mstr_entities TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_appl_data.mstr_entities
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_entity_types_enum_item_check
    AFTER INSERT ON ms_appl_data.mstr_entities
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('entity_types', 'entity_type_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_entity_types_enum_item_check
    AFTER UPDATE ON ms_appl_data.mstr_entities
    FOR EACH ROW WHEN ( old.entity_type_id != new.entity_type_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_enum_item_check(
                'entity_types', 'entity_type_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_i_entity_states_enum_item_check
    AFTER INSERT ON ms_appl_data.mstr_entities
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('entity_states', 'entity_state_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_entity_states_enum_item_check
    AFTER UPDATE ON ms_appl_data.mstr_entities
    FOR EACH ROW WHEN ( old.entity_state_id != new.entity_state_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_enum_item_check(
                'entity_states', 'entity_state_id');

COMMENT ON
    TABLE ms_appl_data.mstr_entities IS
$DOC$Master list of legal entities with whom the business interacts.  All legal
entities are represented by this table, including the business using this
application itself.  The information stored in this record represents general
information about the entity that is broadly applicable in all contexts which
might use the entity.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entities.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entities.owning_entity_id IS
$DOC$Indicates which managing entity is the owning entity for purposes of default
visibility and usage limitations.  This limitation primarily is evident in
searches and lists.  Explicit assignment of rights to entities, persons,
facilities, etc. that are not the owning entity is still possible and those
rights will prevail over the default access rules for non-owning entities.

There is a special case of owning entity where an entity is self owning.  There
may only be a single entity that is self owning and that, by definition,
establishes that entity as the 'global entity'.  The global entity has global
administrative rights as well as allows access to those persons, facilities, and
entities that it owns effectively making them global to all other managed
entities.  The global entity may be an actual business entity which essentially
owns the MSBMS instance or it may a purely administrative construct for managing
the system.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entities.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entities.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interfaces.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entities.external_name IS
$DOC$A friendly name for externally facing uses such as in communications with the
entity.  Note that this is not a key value and has no UNIQUE enforcement.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entities.entity_type_id IS
$DOC$Defines the kind of entity that is being represented by the record and by
extension the kinds of uses in which the entity may be used.  Application
functionality is determined in part by the configuration of the selected type.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entities.entity_state_id IS
$DOC$Establishes current state of the entity in the established lifecycle of
entity records.  Certain application features and behaviors will depend on
the configuration of the state value selected for a entity record.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entities.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entities.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entities.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entities.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entities.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entities.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entities.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
-- File:        mstr_places.eex.sql
-- Location:    musebms/database/application/msbms/mod_brm/ms_appl_data/mstr_places/mstr_places.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_appl_data.mstr_places
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT mstr_places_pk PRIMARY KEY
    ,owning_entity_id
        uuid
        NOT NULL
        CONSTRAINT mstr_places_entities_fk
            REFERENCES ms_appl_data.mstr_entities (id)
    ,internal_name
        text
        NOT NULL
        CONSTRAINT mstr_places_internal_name_udx UNIQUE
    ,display_name
        text
        CONSTRAINT mstr_places_display_name_udx UNIQUE
    ,external_name
        text
        NOT NULL
    ,place_type_id
        uuid
        NOT NULL
        CONSTRAINT mstr_places_place_types_fk
            REFERENCES ms_syst_data.syst_enum_items (id)
    ,place_state_id
        uuid
        CONSTRAINT mstr_places_place_states_fk
            REFERENCES ms_syst_data.syst_enum_items (id)
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
        NOT NULL
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
        NOT NULL
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
);

ALTER TABLE ms_appl_data.mstr_places OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_appl_data.mstr_places FROM public;
GRANT ALL ON TABLE ms_appl_data.mstr_places TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_appl_data.mstr_places
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_place_states_enum_item_check
    AFTER INSERT ON ms_appl_data.mstr_places
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('place_states', 'place_state_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_place_states_enum_item_check
    AFTER UPDATE ON ms_appl_data.mstr_places
    FOR EACH ROW WHEN ( old.place_state_id != new.place_state_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_enum_item_check(
                'place_states', 'place_state_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_i_place_types_enum_item_check
    AFTER INSERT ON ms_appl_data.mstr_places
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('place_types', 'place_type_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_place_types_enum_item_check
    AFTER UPDATE ON ms_appl_data.mstr_places
    FOR EACH ROW WHEN ( old.place_type_id != new.place_type_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_enum_item_check(
                'place_types', 'place_type_id');

COMMENT ON
    TABLE ms_appl_data.mstr_places IS
$DOC$places are system representations of real world buildings, such as office
buildings, warehouses, factories, or sales centers.  Note that a place may be
associated with multiple addresses which can be assigned roles for different
purposes.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_places.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN   ms_appl_data.mstr_places.owning_entity_id IS
$DOC$Indicates which managing entity owns the place record for the purposes of
default visibility and access.  Any place record owned by the global entity is
by default visible and usable by any managed entity.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_places.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_places.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interfaces.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_places.external_name IS
$DOC$A friendly name for externally facing uses such as in communications with the
place.  Note that this is not a key value and has no UNIQUE enforcement.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_places.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_places.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_places.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_places.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_places.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_places.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_places.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
-- File:        mstr_persons.eex.sql
-- Location:    musebms/database/application/msbms/mod_brm/ms_appl_data/mstr_persons/mstr_persons.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_appl_data.mstr_persons
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT mstr_persons_pk PRIMARY KEY
    ,owning_entity_id
        uuid
        NOT NULL
        CONSTRAINT mstr_persons_entities_fk
            REFERENCES ms_appl_data.mstr_entities (id)
    ,internal_name
        text
        NOT NULL
        CONSTRAINT mstr_persons_internal_name_udx UNIQUE
    ,display_name
        text
        CONSTRAINT mstr_persons_display_name_udx UNIQUE
    ,external_name
        text
        NOT NULL
    ,formatted_name
        jsonb
        NOT NULL DEFAULT '{}'::jsonb
    ,person_type_id
        uuid
        NOT NULL
        CONSTRAINT mstr_persons_person_types_fk
            REFERENCES ms_syst_data.syst_enum_items (id)
    ,person_state_id
        uuid
        CONSTRAINT mstr_persons_person_states_fk
            REFERENCES ms_syst_data.syst_enum_items (id)
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
        NOT NULL
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
        NOT NULL
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
);

ALTER TABLE ms_appl_data.mstr_persons OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_appl_data.mstr_persons FROM public;
GRANT ALL ON TABLE ms_appl_data.mstr_persons TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_appl_data.mstr_persons
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_person_types_enum_item_check
    AFTER INSERT ON ms_appl_data.mstr_persons
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('person_types', 'person_type_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_person_types_enum_item_check
    AFTER UPDATE ON ms_appl_data.mstr_persons
    FOR EACH ROW WHEN ( old.person_type_id != new.person_type_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_enum_item_check(
                'person_types', 'person_type_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_i_person_states_enum_item_check
    AFTER INSERT ON ms_appl_data.mstr_persons
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('person_states', 'person_state_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_person_states_enum_item_check
    AFTER UPDATE ON ms_appl_data.mstr_persons
    FOR EACH ROW WHEN ( old.person_state_id != new.person_state_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_enum_item_check(
                'person_states', 'person_state_id');

COMMENT ON
    TABLE ms_appl_data.mstr_persons IS
$DOC$Represents real people in the world.  Ideally, there is one record in this table
for each person the various entities interact with.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_persons.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN   ms_appl_data.mstr_persons.owning_entity_id IS
$DOC$Indicates which managing entity owns the person record for the purposes of
default visibility and access.  Any person record owned by the global entity is
by default visible and usable by any managed entity.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_persons.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_persons.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interfaces.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_persons.external_name IS
$DOC$A friendly name for externally facing uses such as in communications with the
person.  Note that this is not a key value and has no UNIQUE enforcement.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_persons.formatted_name IS
$DOC$Contains a jsonb object describing the naming fields, field layout, and the
actual values of the user's name.  Note that the format will normally have
originated from the ms_appl_data.syst_name_formats table, but reflects the
name formatting configuration at the time of capture.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_persons.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_persons.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_persons.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_persons.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_persons.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_persons.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_persons.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
-- File:        mstr_contacts.eex.sql
-- Location:    musebms/database/application/msbms/mod_brm/ms_appl_data/mstr_contacts/mstr_contacts.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_appl_data.mstr_contacts
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT mstr_contacts_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT mstr_contacts_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT mstr_contacts_display_name_udx UNIQUE
    ,owning_entity_id
        uuid
        NOT NULL
        CONSTRAINT mstr_contacts_owning_entity_fk
            REFERENCES ms_appl_data.mstr_entities (id) ON DELETE CASCADE
    ,external_name
        text
        NOT NULL
    ,contact_type_id
        uuid
        NOT NULL
        CONSTRAINT mstr_contacts_contact_types_fk
            REFERENCES ms_syst_data.syst_enum_items (id)
    ,contact_state_id
        uuid
        NOT NULL
        CONSTRAINT mstr_contacts_contact_states_fk
            REFERENCES ms_syst_data.syst_enum_items (id)
    ,contact_data
        jsonb
        NOT NULL DEFAULT '{}'::jsonb
    ,contact_notes
        text
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
        NOT NULL
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
        NOT NULL
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
);

ALTER TABLE ms_appl_data.mstr_contacts OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_appl_data.mstr_contacts FROM public;
GRANT ALL ON TABLE ms_appl_data.mstr_contacts TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_appl_data.mstr_contacts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_contact_types_enum_item_check
    AFTER INSERT ON ms_appl_data.mstr_contacts
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('contact_types', 'contact_type_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_contact_types_enum_item_check
    AFTER UPDATE ON ms_appl_data.mstr_contacts
    FOR EACH ROW WHEN ( old.contact_type_id != new.contact_type_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_enum_item_check(
                'contact_types', 'contact_type_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_i_contact_states_enum_item_check
    AFTER INSERT ON ms_appl_data.mstr_contacts
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('contact_states', 'contact_state_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_contact_states_enum_item_check
    AFTER UPDATE ON ms_appl_data.mstr_contacts
    FOR EACH ROW WHEN ( old.contact_state_id != new.contact_state_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_enum_item_check(
                'contact_states', 'contact_state_id');

COMMENT ON
    TABLE ms_appl_data.mstr_contacts IS
$DOC$Represents a single method of contact for a person, entity, place, or other
contextually relevant association.

Note that there is a weakness in this part of the schema design in that contact
information doesn't make sense outside of assignment to a person, facility, or
entity, but such assignment is indirect through role assignments.  This means it
is conceivable that records in this table could become orphaned.  At this stage,
however, it doesn't seem worth it to denormalize the data to record the direct
association.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_contacts.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_contacts.internal_name IS
$DOC$ A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_contacts.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_contacts.owning_entity_id IS
$DOC$Indicates the entity which is the owner or "controlling".   There are a couple
of ways this can be used.  The first case is illustrated by the example of a
managed entity and an staffing entity that is an individual.  The owning entity
in this case will be the managed entity for contacts such as the details of the
person's office address, phone, and email addresses that is used in carrying out
their duties as staff.  The second case is where the entity is in a selling,
purchasing, or banking relationship with the managed entity.  In this case the
owning entity is the entity with which the managed entity has a relationship
since a customer, vendor, or bank determines their own contact details.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_contacts.external_name IS
$DOC$A non-unique/non-key value used to display to users and external parties where
uniqueness is less of a concern than specific end user presentation.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_contacts.contact_state_id IS
$DOC$Establishes the current life-cycle state of the contact record, such as
whether the record is active or not.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_contacts.contact_type_id IS
$DOC$Indicates the type of the contact record.  Contact records store inforamtion of
varying types such as phone numbers, physical addresses, email addresses, etc.
The value in this column establishes which kind of contact data is being stored
and indicates the data processing rules to apply.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_contacts.contact_data IS
$DOC$Contains the actual contact data being stored by the record as well as
associated metadata such as specialized data fields, mapping of the specialized
fields to standard representation for data maintenance, display, printing, and
integration.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_contacts.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_contacts.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_contacts.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_contacts.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_contacts.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_contacts.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_contacts.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
-- File:        mstr_entity_selling_entities.eex.sql
-- Location:    musebms/database/application/msbms/mod_brm/ms_appl_data/mstr_entity_selling_entities/mstr_entity_selling_entities.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_appl_data.mstr_entity_selling_entities
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT mstr_entity_selling_entities_pk PRIMARY KEY
    ,entity_id
        uuid
        NOT NULL
        CONSTRAINT mstr_entity_selling_entities_entity_fk
            REFERENCES ms_appl_data.mstr_entities (id) ON DELETE CASCADE
    ,owning_entity_id
        uuid
        NOT NULL
        CONSTRAINT mstr_entity_selling_entities_owning_entity_fk
            REFERENCES ms_appl_data.mstr_entities (id) ON DELETE CASCADE
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
        NOT NULL
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
        NOT NULL
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
    ,CONSTRAINT mstr_entity_selling_entities_udx
        UNIQUE (entity_id, owning_entity_id)
);

ALTER TABLE ms_appl_data.mstr_entity_selling_entities OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_appl_data.mstr_entity_selling_entities FROM public;
GRANT ALL ON TABLE ms_appl_data.mstr_entity_selling_entities TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_appl_data.mstr_entity_selling_entities
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE ms_appl_data.mstr_entity_selling_entities IS
$DOC$Establishes a customer relationship between an owning entity and its customer
entity.  This record, or its children, will define sales and receivables
behavior when the transaction entity is the owning entity.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_selling_entities.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_selling_entities.entity_id IS
$DOC$Identifies for which entity customer details are being defined.  The terms
in this record define the customer behavior for the entity defined by this
field.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_selling_entities.owning_entity_id IS
$DOC$Identifies the entity that will use the customer terms when processing
selling and receivables transactions with the entity identified in the
entity_id field.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_selling_entities.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_selling_entities.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_selling_entities.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_selling_entities.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_selling_entities.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_selling_entities.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_selling_entities.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
-- File:        mstr_entity_purchasing_entities.eex.sql
-- Location:    musebms/database/application/msbms/mod_brm/ms_appl_data/mstr_entity_purchasing_entities/mstr_entity_purchasing_entities.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_appl_data.mstr_entity_purchasing_entities
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT mstr_entity_purchasing_entities_pk PRIMARY KEY
    ,entity_id
        uuid
        NOT NULL
        CONSTRAINT mstr_entity_purchasing_entities_entity_fk
            REFERENCES ms_appl_data.mstr_entities (id) ON DELETE CASCADE
    ,owning_entity_id
        uuid
        NOT NULL
        CONSTRAINT mstr_entity_purchasing_entities_owning_entity_fk
            REFERENCES ms_appl_data.mstr_entities (id) ON DELETE CASCADE
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
        NOT NULL
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
        NOT NULL
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
    ,CONSTRAINT mstr_entity_purchasing_entities_udx
        UNIQUE (entity_id, owning_entity_id)
);

ALTER TABLE ms_appl_data.mstr_entity_purchasing_entities OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_appl_data.mstr_entity_purchasing_entities FROM public;
GRANT ALL ON TABLE ms_appl_data.mstr_entity_purchasing_entities TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_appl_data.mstr_entity_purchasing_entities
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE ms_appl_data.mstr_entity_purchasing_entities IS
$DOC$Establishes a vendor relationship between an owning entity and its vendor
entity.  This record, or its children, will define purchasing and payables
behavior when the transaction entity is the owning entity.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_purchasing_entities.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_purchasing_entities.entity_id IS
$DOC$Identifies for which entity vendor details are being defined.  The terms
in this record define the customer behavior for the entity defined by this
field.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_purchasing_entities.owning_entity_id IS
$DOC$Identifies the entity that will use the purchasing terms when processing
purchasing and payables transactions with the entity identified in the
entity_id field.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_purchasing_entities.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_purchasing_entities.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_purchasing_entities.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_purchasing_entities.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_purchasing_entities.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_purchasing_entities.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_purchasing_entities.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
-- File:        mstr_entity_staffing_entities.eex.sql
-- Location:    musebms/database/application/msbms/mod_brm/ms_appl_data/mstr_entity_staffing_entities/mstr_entity_staffing_entities.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_appl_data.mstr_entity_staffing_entities
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT mstr_entity_staffing_entities_pk PRIMARY KEY
    ,entity_id
        uuid
        NOT NULL
        CONSTRAINT mstr_entity_staffing_entities_entity_fk
            REFERENCES ms_appl_data.mstr_entities (id) ON DELETE CASCADE
    ,owning_entity_id
        uuid
        NOT NULL
        CONSTRAINT mstr_entity_staffing_entities_owning_entity_fk
            REFERENCES ms_appl_data.mstr_entities (id) ON DELETE CASCADE
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
        NOT NULL
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
        NOT NULL
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
    ,CONSTRAINT mstr_entity_staffing_entities_udx
        UNIQUE (entity_id, owning_entity_id)
);

ALTER TABLE ms_appl_data.mstr_entity_staffing_entities OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_appl_data.mstr_entity_staffing_entities FROM public;
GRANT ALL ON TABLE ms_appl_data.mstr_entity_staffing_entities TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_appl_data.mstr_entity_staffing_entities
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE ms_appl_data.mstr_entity_staffing_entities IS
$DOC$Establishes an employee or contractor relationship between an owning entity and
its employee entity.  This record, or its children, will define the employee
behavior when the transaction entity is the owning entity.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_staffing_entities.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_staffing_entities.entity_id IS
$DOC$Identifies for which entity customer details are being defined.  The terms
in this record define the customer behavior for the entity defined by this
field.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_staffing_entities.owning_entity_id IS
$DOC$Identifies the entity that will use the customer terms when processing
selling and receivables transactions with the entity identified in the
entity_id field.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_staffing_entities.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_staffing_entities.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_staffing_entities.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_staffing_entities.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_staffing_entities.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_staffing_entities.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_staffing_entities.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
-- File:        mstr_entity_banking_entities.eex.sql
-- Location:    musebms/database/application/msbms/mod_brm/ms_appl_data/mstr_entity_banking_entities/mstr_entity_banking_entities.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_appl_data.mstr_entity_banking_entities
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT mstr_entity_banking_entities_pk PRIMARY KEY
    ,entity_id
        uuid
        NOT NULL
        CONSTRAINT mstr_entity_banking_entities_entity_fk
            REFERENCES ms_appl_data.mstr_entities (id) ON DELETE CASCADE
    ,owning_entity_id
        uuid
        NOT NULL
        CONSTRAINT mstr_entity_banking_entities_owning_entity_fk
            REFERENCES ms_appl_data.mstr_entities (id) ON DELETE CASCADE
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
        NOT NULL
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
        NOT NULL
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
    ,CONSTRAINT mstr_entity_banking_entities_udx
        UNIQUE (entity_id, owning_entity_id)
);

ALTER TABLE ms_appl_data.mstr_entity_banking_entities OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_appl_data.mstr_entity_banking_entities FROM public;
GRANT ALL ON TABLE ms_appl_data.mstr_entity_banking_entities TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_appl_data.mstr_entity_banking_entities
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE ms_appl_data.mstr_entity_banking_entities IS
$DOC$Establishes an financial service provider relationship between an owning entity
and a banking related entity.  This record, or its children, will define the
banking behavior when the transaction entity is the owning entity.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_banking_entities.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_banking_entities.entity_id IS
$DOC$Identifies for which entity customer details are being defined.  The terms
in this record define the customer behavior for the entity defined by this
field.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_banking_entities.owning_entity_id IS
$DOC$Identifies the entity that will use the customer terms when processing
selling and receivables transactions with the entity identified in the
entity_id field.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_banking_entities.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_banking_entities.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_banking_entities.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_banking_entities.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_banking_entities.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_banking_entities.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_banking_entities.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
-- File:        mstr_entity_inventory_places.eex.sql
-- Location:    musebms/database/application/msbms/mod_brm/ms_appl_data/mstr_entity_inventory_places/mstr_entity_inventory_places.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_appl_data.mstr_entity_inventory_places
(
     id
         uuid
         NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT mstr_entity_inventory_places_pk PRIMARY KEY
    ,place_id
        uuid
        NOT NULL
        CONSTRAINT mstr_entity_inventory_places_place_fk
            REFERENCES ms_appl_data.mstr_places (id) ON DELETE CASCADE
    ,owning_entity_id
        uuid
        NOT NULL
        CONSTRAINT mstr_entity_inventory_places_owning_entity_fk
            REFERENCES ms_appl_data.mstr_entities (id) ON DELETE CASCADE
    ,receives_external_inventory
        boolean
        NOT NULL DEFAULT false
    ,fulfills_external_inventory
        boolean
        NOT NULL DEFAULT false
    ,receives_internal_inventory
        boolean
        NOT NULL DEFAULT false
    ,fulfills_internal_inventory
        boolean
        NOT NULL DEFAULT false
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
        NOT NULL
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
        NOT NULL
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
);

ALTER TABLE ms_appl_data.mstr_entity_inventory_places OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_appl_data.mstr_entity_inventory_places FROM public;
GRANT ALL ON TABLE ms_appl_data.mstr_entity_inventory_places TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_appl_data.mstr_entity_inventory_places
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE ms_appl_data.mstr_entity_inventory_places IS
$DOC$Establishes one or more inventory relationships between a managed entity and a
place.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_inventory_places.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_inventory_places.place_id IS
$DOC$Identifies the place that will have an inventory relationship with the owning
entity.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_inventory_places.owning_entity_id IS
$DOC$Establishes the entity which has an inventory relationship to the identified
place.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_inventory_places.receives_external_inventory IS
$DOC$If true, this inventory may receive inventory shipments from third parties such
as might originate from purchase order transactions.  If false, this inventory
may not receive inventory from external third parties.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_inventory_places.fulfills_external_inventory IS
$DOC$If true, inventory units may be fulfilled from this place, for this entity. If
false, this inventory may not participate as a source of fulfillment to third
parties.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_inventory_places.receives_internal_inventory IS
$DOC$If true, inventory units may be received into this inventory from other
inventories managed by the system.  If false, other managed inventories will not
be valid sources to replenish stocks in this inventory.  Transferred inventory
would be an example of a transaction requiring the inventory to allow the
processing of internal receipts.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_inventory_places.fulfills_internal_inventory IS
$DOC$If true, inventory units may be fulfilled from this managed inventory to another
inventory managed by the system. If false, the inventory may not serve as the
source of inventory units to other managed inventories.  Transferring inventory
out is an example of a transaction requiring this internal fulfillment ability.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_inventory_places.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_inventory_places.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_inventory_places.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_inventory_places.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_inventory_places.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_inventory_places.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_inventory_places.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
-- File:        mstr_entity_workplace_places.eex.sql
-- Location:    musebms/database/application/msbms/mod_brm/ms_appl_data/mstr_entity_workplace_places/mstr_entity_workplace_places.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_appl_data.mstr_entity_workplace_places
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT mstr_entity_workplace_places_pk PRIMARY KEY
    ,place_id
        uuid
        NOT NULL
        CONSTRAINT mstr_entity_workplace_places_place_fk
            REFERENCES ms_appl_data.mstr_places (id) ON DELETE CASCADE
    ,owning_entity_id
        uuid
        NOT NULL
        CONSTRAINT mstr_entity_workplace_places_owning_entity_fk
            REFERENCES ms_appl_data.mstr_entities (id) ON DELETE CASCADE
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
        NOT NULL
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
        NOT NULL
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
);

ALTER TABLE ms_appl_data.mstr_entity_workplace_places OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_appl_data.mstr_entity_workplace_places FROM public;
GRANT ALL ON TABLE ms_appl_data.mstr_entity_workplace_places TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_appl_data.mstr_entity_workplace_places
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE ms_appl_data.mstr_entity_workplace_places IS
$DOC$Identifies a specific place as being a valid option for person addressing, such
as mailing, etc.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_workplace_places.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_workplace_places.place_id IS
$DOC$Identifies the place which has a workplace relationship with the owning entity.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_workplace_places.owning_entity_id IS
$DOC$Establishes the entity which uses the place as a workplace.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_workplace_places.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_workplace_places.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_workplace_places.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_workplace_places.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_workplace_places.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_workplace_places.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_workplace_places.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
-- File:        mstr_entity_fulfillment_places.eex.sql
-- Location:    musebms/database/application/msbms/mod_brm/ms_appl_data/mstr_entity_fulfillment_places/mstr_entity_fulfillment_places.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_appl_data.mstr_entity_fulfillment_places
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT mstr_entity_fulfillment_places_pk PRIMARY KEY
    ,place_id
        uuid
        NOT NULL
        CONSTRAINT mstr_entity_fulfillment_places_place_fk
            REFERENCES ms_appl_data.mstr_places (id) ON DELETE CASCADE
    ,owning_entity_id
        uuid
        NOT NULL
        CONSTRAINT mstr_entity_fulfillment_places_entity_fk
            REFERENCES ms_appl_data.mstr_entities (id) ON DELETE CASCADE
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
        NOT NULL
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
        NOT NULL
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
);

ALTER TABLE ms_appl_data.mstr_entity_fulfillment_places OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_appl_data.mstr_entity_fulfillment_places FROM public;
GRANT ALL ON TABLE ms_appl_data.mstr_entity_fulfillment_places TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_appl_data.mstr_entity_fulfillment_places
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE ms_appl_data.mstr_entity_fulfillment_places IS
$DOC$Establishes a relationship between an entity and a place allowing the entity to
receive order fulfillment at the identified place; this is "ship-to"
relationship.  Note these places are used as the shipping places in external
fulfillment transactions.  For internal fulfillment transactions, the entity/
inventory/place relationship determines whether or not the place may receive
units.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_fulfillment_places.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_fulfillment_places.place_id IS
$DOC$Establishes that a place may be the destination of external fulfillment
transactions for the entity.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_fulfillment_places.owning_entity_id IS
$DOC$Identifies the owning entity which may receive external fulfillment transaction
inventory units at the place also identified in this record.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_fulfillment_places.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_fulfillment_places.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_fulfillment_places.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_fulfillment_places.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_fulfillment_places.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_fulfillment_places.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_fulfillment_places.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
-- File:        mstr_entity_person_roles.eex.sql
-- Location:    musebms/database/application/msbms/mod_brm/ms_appl_data/mstr_entity_person_roles/mstr_entity_person_roles.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_appl_data.mstr_entity_person_roles
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT mstr_entity_person_roles_pk PRIMARY KEY
    ,person_id
        uuid
        NOT NULL
        CONSTRAINT mstr_entity_person_roles_person_fk
            REFERENCES ms_appl_data.mstr_persons (id) ON DELETE CASCADE
    ,entity_id
        uuid
        NOT NULL
        CONSTRAINT mstr_entity_person_roles_entity_fk
            REFERENCES ms_appl_data.mstr_entities (id) ON DELETE CASCADE
    ,entity_person_role_id
        uuid
        NOT NULL
        CONSTRAINT mstr_entity_person_roles_enum_entity_person_role_fk
            REFERENCES ms_syst_data.syst_enum_items (id)
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
        NOT NULL
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
        NOT NULL
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
    ,CONSTRAINT mstr_entity_person_roles_person_entity_role_udx
        UNIQUE (person_id, entity_id, entity_person_role_id)
);

ALTER TABLE ms_appl_data.mstr_entity_person_roles OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_appl_data.mstr_entity_person_roles FROM public;
GRANT ALL ON TABLE ms_appl_data.mstr_entity_person_roles TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_appl_data.mstr_entity_person_roles
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_entity_person_roles_enum_item_check
    AFTER INSERT ON ms_appl_data.mstr_entity_person_roles
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('entity_person_roles', 'entity_person_role_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_entity_person_roles_enum_item_check
    AFTER UPDATE ON ms_appl_data.mstr_entity_person_roles
    FOR EACH ROW WHEN ( old.entity_person_role_id != new.entity_person_role_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_enum_item_check(
                'entity_person_roles', 'entity_person_role_id');

COMMENT ON
    TABLE ms_appl_data.mstr_entity_person_roles IS
$DOC$Establishes the relationship between individual persons and and entity.  Note
that for now a simple table with the entity, person, and the role assigned is
sufficient for expressing the relationship, though in future it may be
appropriate to have specific relationship tables like entity/entity relationships
should the relationships not be containable in a single attribute describing the
role.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_person_roles.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_person_roles.person_id IS
$DOC$The person that is being assigned a role with the entity.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_person_roles.entity_id IS
$DOC$The entity with which the identified person has a role.  In many regards,
this field identifies the owner of the record.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_person_roles.entity_person_role_id IS
$DOC$Identifies the role being assigned to the person for the identified entity.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_person_roles.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_person_roles.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_person_roles.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_person_roles.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_person_roles.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_person_roles.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_entity_person_roles.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
-- File:        syst_person_logins.eex.sql
-- Location:    musebms/database/application/msbms/mod_syst/ms_syst_data/syst_person_logins/syst_person_logins.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_person_logins
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_person_logins_pk PRIMARY KEY
    ,person_id
        uuid
        NOT NULL
        CONSTRAINT syst_person_logins_person_fk
            REFERENCES ms_appl_data.mstr_persons (id) ON DELETE CASCADE
    ,owning_entity_id
        uuid
        NOT NULL
        CONSTRAINT syst_person_logins_owning_entity_fk
            REFERENCES ms_appl_data.mstr_entities (id) ON DELETE CASCADE
    ,login_state_id
        uuid
        NOT NULL
        CONSTRAINT syst_person_logins_enum_login_state_fk
            REFERENCES ms_syst_data.syst_enum_items (id)
    ,access_account_id
        uuid
        NOT NULL
    ,validity_start_end
        tstzrange
        NOT NULL DEFAULT tstzrange(now(), null, '[)')
    ,last_login
        timestamptz
        NOT NULL DEFAULT '-infinity'
    ,last_attempted_login
        timestamptz
        NOT NULL DEFAULT '-infinity'
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
        NOT NULL
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
        NOT NULL
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
);

ALTER TABLE ms_syst_data.syst_person_logins OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_person_logins FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_person_logins TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_person_logins
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_login_states_enum_item_check
    AFTER INSERT ON ms_syst_data.syst_person_logins
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('login_states', 'login_state_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_login_states_enum_item_check
    AFTER UPDATE ON ms_syst_data.syst_person_logins
    FOR EACH ROW WHEN ( old.login_state_id != new.login_state_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_enum_item_check(
                'login_states', 'login_state_id');

COMMENT ON
    TABLE ms_syst_data.syst_person_logins IS
$DOC$Provides the list of available login identities for people needing access to the
system for any reason.  Identity in this case isn't the person, but the means by
which a person identifies themselves to the system.  A login may be owned by the
entity to which the person record belongs, this is used in selling and
purchasing relationships since a customer or vendor controls their login
details, and also in inactive staffing relationships where on-going employee
portal access may be appropriate.  A login may be owned by the managed entity
such as in the case of an active staffing relationship; this must be true since
the employee login may have more stringent login requirements than is required
for selling and purchasing relationships, or secondary authentication may be
tied to company owned devices that cease to be available once the staffing
relationship terminates.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_person_logins.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_person_logins.person_id IS
$DOC$The person that this login will identify.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_person_logins.owning_entity_id IS
$DOC$The owning entity of this login.  See the table description for the broader
ownership concept.  This will point to the entity responsible for managing the
login.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_person_logins.login_state_id IS
$DOC$Establishes which life-cycle state the login record is in.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_person_logins.access_account_id IS
$DOC$A reference to the global database ms_syst_data.syst_access_accounts table.
Authentication is handled centrally via the global database for all instance
owners, instances, and supported applications.  The reference in this column
indicates which of the global access account records is used for authentication
to this instance.  Authorization, including authorization to connect to the
instance is managed by the instance itself once the system authenticates the
user.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_person_logins.validity_start_end IS
$DOC$Indicates the starting and ending timestamps for which a given login may be
used to access the system, so long as the enum_login_state_id value also
represents a state which allows login attempts.  The allowed times include the
starting time and allow logins up to the ending time, but not including the
ending time itself.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_person_logins.last_login IS
$DOC$The last time the login was used and successfully authenticated.  This doesn't
mean that once authenticated that the user had permission to view data or
perform actions.  A successful login only indicates a successful authentication.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_person_logins.last_attempted_login IS
$DOC$The last time a login attempt was tried.  This value will updated be updated
without regard to the success or failure of the authentication.  An
authentication attempt will be considered as recordable here when both an
identity and an authenticator have both been provided to the system for
evaluation.  Secondary authenticator attempts are not necessary to count as an
attempted authentication; this means, for example, a good username and password
with no attempted answer to a required secondary authentication factor will
still count as an authentication attempt.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_person_logins.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_person_logins.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_person_logins.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_person_logins.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_person_logins.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_person_logins.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_person_logins.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
-- File:        mstr_person_contact_roles.eex.sql
-- Location:    musebms/database/application/msbms/mod_brm/ms_appl_data/mstr_person_contact_roles/mstr_person_contact_roles.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_appl_data.mstr_person_contact_roles
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT mstr_person_contact_roles_pk PRIMARY KEY
    ,person_id
        uuid
        NOT NULL
        CONSTRAINT mstr_person_contact_roles_person_fk
            REFERENCES ms_appl_data.mstr_persons (id) ON DELETE CASCADE
    ,person_contact_role_id
        uuid
        NOT NULL
        CONSTRAINT mstr_person_contact_roles_enum_person_contact_role_fk
            REFERENCES ms_syst_data.syst_enum_items (id)
    ,place_id
        uuid
        CONSTRAINT mstr_person_contact_roles_place_fk
            REFERENCES ms_appl_data.mstr_places (id)
    ,contact_id
        uuid
        NOT NULL
        CONSTRAINT mstr_person_contact_roles_contact_fk
            REFERENCES ms_appl_data.mstr_contacts (id) ON DELETE CASCADE
    ,diag_timestamp_created
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_role_created
        text
        NOT NULL
    ,diag_timestamp_modified
        timestamptz
        NOT NULL DEFAULT now( )
    ,diag_wallclock_modified
        timestamptz
        NOT NULL DEFAULT clock_timestamp( )
    ,diag_role_modified
        text
        NOT NULL
    ,diag_row_version
        bigint
        NOT NULL DEFAULT 1
    ,diag_update_count
        bigint
        NOT NULL DEFAULT 0
);

ALTER TABLE ms_appl_data.mstr_person_contact_roles OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_appl_data.mstr_person_contact_roles FROM public;
GRANT ALL ON TABLE ms_appl_data.mstr_person_contact_roles TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_appl_data.mstr_person_contact_roles
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_person_contact_roles_enum_item_check
    AFTER INSERT ON ms_appl_data.mstr_person_contact_roles
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('person_contact_roles', 'person_contact_role_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_person_contact_roles_enum_item_check
    AFTER UPDATE ON ms_appl_data.mstr_person_contact_roles
    FOR EACH ROW WHEN ( old.person_contact_role_id != new.person_contact_role_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_enum_item_check(
                'person_contact_roles', 'person_contact_role_id');

COMMENT ON
    TABLE ms_appl_data.mstr_person_contact_roles IS
$DOC$Associates individual persons with their contact data and includes an indication $DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_person_contact_roles.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_person_contact_roles.person_id IS
$DOC$Identifies the person which has the relationship to the contact information.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_person_contact_roles.person_contact_role_id IS
$DOC$Indicates a specific use or purpose for the identified contact information.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_person_contact_roles.place_id IS
$DOC$This is an optional value indicating whether the given contact information is
associated with a place.  If so, the place will appear here.  This value will be
null if not.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_person_contact_roles.contact_id IS
$DOC$A reference to the contact information which serves the given role for the given
person.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_person_contact_roles.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_person_contact_roles.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_person_contact_roles.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_person_contact_roles.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_person_contact_roles.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_person_contact_roles.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_appl_data.mstr_person_contact_roles.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
END;
$MIGRATION$;
