-- Migration: priv/database/mssub_mcp/mssub_mcp.01.01.000.0000MS.000.eex.sql
-- Built on:  2022-12-10 13:56:05.205316Z

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
-- File:        initial_privileges.eex.sql
-- Location:    musebms/database/subsystems/mssub_mcp/dbinit/initial_privileges.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

GRANT USAGE ON SCHEMA ms_syst TO <%= ms_appusr %>;
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
-- Location:    musebms/database/application/msmcp/components/ms_syst_settings/privileges.eex.sql
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
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_settings() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_settings() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_settings() TO <%= ms_appusr %>;
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
-- Location:    musebms/database/application/msmcp/components/ms_syst_enums/privileges.eex.sql
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
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_enums() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_enums() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_enums() TO <%= ms_appusr %>;

-- syst_enum_functional_types

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_enum_functional_types TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_enum_functional_types() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_enum_functional_types() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_enum_functional_types() TO <%= ms_appusr %>;

-- syst_enum_items

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_enum_items TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_enum_items() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_enum_items() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_enum_items() TO <%= ms_appusr %>;
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
-- Location:    musebms/database/application/msmcp/gen_seed_data/initialize_feature_mapping.eex.sql
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
    ( 'global_module'
    , 'Modules'
    , 'nonassignable'
    , 'Broad, top level feature grouping.'
    , TRUE
    , FALSE )
     ,
    ( 'global_kind'
    , 'Kinds'
    , 'assignable'
    , 'Identifies different kinds of mappable features such as forms, settings, or enumerations.'
    , TRUE
    , FALSE );

--------------------------------------------------------------------------------
-- 01 - Global Settings Module
--------------------------------------------------------------------------------

-- Module Definition

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
    ( 'global_settings'
    , 'Global Settings'
    , 'Global Settings'
    , ( SELECT id
        FROM ms_syst_data.syst_feature_map_levels
        WHERE internal_name = 'global_module' )
    , NULL
    , TRUE
    , FALSE
    , TRUE
    , 'Global settings which define behaviors for the system, including across instances.'
    , 1 );

-- Kinds Definition

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
    ( 'global_settings_settings'
    , 'Global Settings/Settings'
    , 'Settings'
    , ( SELECT id
        FROM ms_syst_data.syst_feature_map_levels
        WHERE internal_name = 'global_kind' )
    , ( SELECT id FROM ms_syst_data.syst_feature_map WHERE internal_name = 'global_settings' )
    , TRUE
    , FALSE
    , TRUE
    , 'Global settings which define behaviors for the system, including across instances.'
    , 1 );

--------------------------------------------------------------------------------
-- 02 - Global Authentication Module
--------------------------------------------------------------------------------

-- Module Definition

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
    ( 'global_authentication'
    , 'Global Authentication'
    , 'Global Authentication'
    , ( SELECT id
        FROM ms_syst_data.syst_feature_map_levels
        WHERE internal_name = 'global_module' )
    , NULL
    , TRUE
    , FALSE
    , TRUE
    , 'Functionality related to managing and providing global user authentication.'
    , 2 );

-- Kinds Definition

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
    ( 'global_authentication_settings'
    , 'Global Authentication/Settings'
    , 'Settings'
    , ( SELECT id
        FROM ms_syst_data.syst_feature_map_levels
        WHERE internal_name = 'global_kind' )
    , ( SELECT id
        FROM ms_syst_data.syst_feature_map
        WHERE internal_name = 'global_authentication' )
    , TRUE
    , FALSE
    , TRUE
    , 'Global settings which define system wide authentication behaviors.'
    , 1 )
     ,
    ( 'global_authentication_enumerations'
    , 'Global Authentication/Enumerations'
    , 'Enumerations'
    , ( SELECT id FROM ms_syst_data.syst_feature_map_levels WHERE internal_name = 'global_kind' )
    , ( SELECT id
        FROM ms_syst_data.syst_feature_map
        WHERE internal_name = 'global_authentication' )
    , TRUE
    , FALSE
    , TRUE
    , 'Lists of values which are available in support of global user authentication.'
    , 2 );

--------------------------------------------------------------------------------
-- 03 - Global Instance Management Module
--------------------------------------------------------------------------------

-- Module Definition

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
    ( 'global_instance_management'
    , 'Global Instance Management'
    , 'Global Instance Management'
    , ( SELECT id
        FROM ms_syst_data.syst_feature_map_levels
        WHERE internal_name = 'global_module' )
    , NULL
    , TRUE
    , FALSE
    , TRUE
    , 'Management of individual instances from the Global context.'
    , 3 );

-- Kinds Definition

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
    ( 'global_instance_management_settings'
    , 'Global Instance Management/Settings'
    , 'Settings'
    , ( SELECT id FROM ms_syst_data.syst_feature_map_levels WHERE internal_name = 'global_kind' )
    , ( SELECT id
        FROM ms_syst_data.syst_feature_map
        WHERE internal_name = 'global_instance_management' )
    , TRUE
    , FALSE
    , TRUE
    , 'Settings which define behaviors for global instance management.'
    , 1 )
     ,
    ( 'global_instance_management_enumerations'
    , 'Global Instance Management/Enumerations'
    , 'Enumerations'
    , ( SELECT id FROM ms_syst_data.syst_feature_map_levels WHERE internal_name = 'global_kind' )
    , ( SELECT id
        FROM ms_syst_data.syst_feature_map
        WHERE internal_name = 'global_authentication' )
    , TRUE
    , FALSE
    , TRUE
    , 'Lists of values available for global instance management as applicable.'
    , 2 );
CREATE OR REPLACE FUNCTION ms_syst_data.trig_b_d_syst_applications_delete_contexts()
RETURNS trigger AS
$BODY$

-- File:        trig_b_d_syst_applications_delete_contexts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst_data/syst_applications/trig_b_d_syst_applications_delete_contexts.eex.sql
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

    ALTER TABLE ms_syst_data.syst_application_contexts
        DISABLE TRIGGER c50_trig_b_d_syst_application_contexts_validate_owner_context;

    DELETE FROM ms_syst_data.syst_application_contexts WHERE application_id = old.id;

    ALTER TABLE ms_syst_data.syst_application_contexts
        ENABLE TRIGGER c50_trig_b_d_syst_application_contexts_validate_owner_context;

    RETURN old;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION ms_syst_data.trig_b_d_syst_applications_delete_contexts()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_data.trig_b_d_syst_applications_delete_contexts() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_data.trig_b_d_syst_applications_delete_contexts() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst_data.trig_b_d_syst_applications_delete_contexts() IS
$DOC$Deletes the Application Contexts prior to deleting the Application record
itself.  This is needed because the trigger preventing datastore context owner
contexts to be deleted must be disabled prior to the delete.$DOC$;
-- File:        syst_applications.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst_data/syst_applications/syst_applications.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_applications
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_applications_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_applications_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_applications_display_name_udx UNIQUE
    ,syst_description
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
);

ALTER TABLE ms_syst_data.syst_applications OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_applications FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_applications TO <%= ms_owner %>;

CREATE TRIGGER b50_trig_b_d_syst_applications_delete_contexts
    BEFORE DELETE ON ms_syst_data.syst_applications
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_data.trig_b_d_syst_applications_delete_contexts();

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_applications
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE ms_syst_data.syst_applications IS
$DOC$Describes the known applications which is managed by the global database and
authentication infrastructure.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_applications.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_applications.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_applications.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_applications.syst_description IS
$DOC$A system default description describing the application being represented by the
record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_applications.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_applications.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_applications.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_applications.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_applications.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_applications.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_applications.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst_data.trig_b_iud_syst_application_contexts_validate_owner_context()
RETURNS trigger AS
$BODY$

-- File:        trig_b_iud_syst_application_contexts_validate_owner_context.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst_data/syst_application_contexts/trig_b_iud_syst_application_contexts_validate_owner_context.eex.sql
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

    IF tg_op = 'DELETE' THEN

        IF old.database_owner_context THEN
            RAISE EXCEPTION
                USING
                    MESSAGE = 'You may not delete the designated database owner ' ||
                              'context for an Application from the database.',
                    DETAIL = ms_syst_priv.get_exception_details(
                                 p_proc_schema    => 'ms_syst'
                                ,p_proc_name      => 'trig_b_iud_syst_application_contexts_validate_owner_context'
                                ,p_exception_name => 'invalid_duplicate'
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

        RETURN old;

    END IF;

    IF tg_op = 'UPDATE' THEN

        IF
            new.database_owner_context != old.database_owner_context
        THEN
            RAISE EXCEPTION
                USING
                    MESSAGE = 'The database owner context designation may ' ||
                              'only be set on INSERT.',
                    DETAIL = ms_syst_priv.get_exception_details(
                                 p_proc_schema    => 'ms_syst'
                                ,p_proc_name      => 'trig_b_iud_syst_application_contexts_validate_owner_context'
                                ,p_exception_name => 'invalid_duplicate'
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

    END IF;

    IF tg_op IN ('INSERT', 'UPDATE') THEN

        -- There may only be one database owner context for any one application.
        IF
            new.database_owner_context AND
            exists( SELECT
                        TRUE
                    FROM ms_syst_data.syst_application_contexts sac
                    WHERE
                          sac.application_id = new.application_id
                      AND sac.id != new.id
                      AND sac.database_owner_context)
        THEN
            RAISE EXCEPTION
                USING
                    MESSAGE = 'Each Application may only have one Application Context ' ||
                              'defined as being the database owner.',
                    DETAIL = ms_syst_priv.get_exception_details(
                                 p_proc_schema    => 'ms_syst'
                                ,p_proc_name      => 'trig_b_iud_syst_application_contexts_validate_owner_context'
                                ,p_exception_name => 'invalid_duplicate'
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

        -- Database context owners may not be login contexts nor may they be
        -- started
        IF new.database_owner_context AND (new.login_context OR new.start_context) THEN
            RAISE EXCEPTION
                USING
                    MESSAGE = 'A database owner context may not be a login ' ||
                              'context nor may it be started.',
                    DETAIL = ms_syst_priv.get_exception_details(
                                 p_proc_schema    => 'ms_syst'
                                ,p_proc_name      => 'trig_b_iud_syst_application_contexts_validate_owner_context'
                                ,p_exception_name => 'invalid_duplicate'
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

        RETURN new;

    END IF;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION ms_syst_data.trig_b_iud_syst_application_contexts_validate_owner_context()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_data.trig_b_iud_syst_application_contexts_validate_owner_context() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_data.trig_b_iud_syst_application_contexts_validate_owner_context() TO <%= ms_owner %>;


COMMENT ON FUNCTION ms_syst_data.trig_b_iud_syst_application_contexts_validate_owner_context() IS
$DOC$Validates database_owner_context values based on the pre-existing state of the database $DOC$;
-- File:        syst_application_contexts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst_data/syst_application_contexts/syst_application_contexts.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_application_contexts
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_application_contexts_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_application_contexts_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_application_contexts_display_name_udx UNIQUE
    ,application_id
        uuid
        NOT NULL
        CONSTRAINT syst_application_contexts_applications_fk
            REFERENCES ms_syst_data.syst_applications (id)
            ON DELETE CASCADE
    ,description
        text
        NOT NULL
    ,start_context
        boolean
        NOT NULL DEFAULT FALSE
    ,login_context
        boolean
        NOT NULL DEFAULT FALSE
    ,database_owner_context
        boolean
        NOT NULL DEFAULT FALSE
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

ALTER TABLE ms_syst_data.syst_application_contexts OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_application_contexts FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_application_contexts TO <%= ms_owner %>;

CREATE TRIGGER c50_trig_b_d_syst_application_contexts_validate_owner_context
    BEFORE DELETE ON ms_syst_data.syst_application_contexts
    FOR EACH ROW
    WHEN (old.database_owner_context)
EXECUTE PROCEDURE ms_syst_data.trig_b_iud_syst_application_contexts_validate_owner_context();

CREATE TRIGGER c50_trig_b_i_syst_application_contexts_validate_owner_context
    BEFORE INSERT ON ms_syst_data.syst_application_contexts
    FOR EACH ROW
EXECUTE PROCEDURE ms_syst_data.trig_b_iud_syst_application_contexts_validate_owner_context();

CREATE TRIGGER c50_trig_b_u_syst_application_contexts_validate_owner_context
    BEFORE UPDATE ON ms_syst_data.syst_application_contexts
    FOR EACH ROW
    WHEN (new.database_owner_context AND old.database_owner_context != new.database_owner_context)
EXECUTE PROCEDURE ms_syst_data.trig_b_iud_syst_application_contexts_validate_owner_context();

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_application_contexts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE ms_syst_data.syst_application_contexts IS
$DOC$Applications are written with certain security and connection
characteristics in mind which correlate to database roles used by the
application for establishing connections.  This table defines the datastore
contexts the application is expecting so that Instance records can be validated
against the expectations.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_application_contexts.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_application_contexts.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_application_contexts.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_application_contexts.application_id IS
$DOC$References the ms_syst_data.syst_applications record which owns the
context.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_application_contexts.start_context IS
$DOC$Indicates whether or not the system should start the context for any Instances
of the application.  If true, any Instance of the Application will start its
associated context so long as it is enabled at the Instance level.  If false,
the context is disabled for all Instances in the Application regardless of their
individual settings.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_application_contexts.login_context IS
$DOC$Indicates whether or not the Application Context is used for making
connections to the database.  If true, each associated Instance Context is
created as a role in the database with the LOGIN privilege; if false, the
role is created in the database as a NOLOGIN role.  Most often non-login
Application Contexts are created to serve as the database role owning database
objects.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_application_contexts.database_owner_context IS
$DOC$Indicates if the Application Context represents the database role used for object
ownership.  If true, the Application Context does represent the ownership role
and should also be defined as a login_context = FALSE context.  If false, the
role is not used for database object ownership.  Note that there should only
ever be one Application Context defined as database_owner_context = TRUE for any
one Application.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_application_contexts.description IS
$DOC$A user visible description of the application context, its role in the
application, uses, and any other helpful text.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_application_contexts.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_application_contexts.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_application_contexts.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_application_contexts.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_application_contexts.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_application_contexts.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_application_contexts.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst_data.trig_a_i_syst_instance_type_apps_create_inst_type_contexts()
RETURNS trigger AS
$BODY$

-- File:        trig_a_i_syst_instance_type_apps_create_inst_type_contexts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst_data/syst_instance_type_applications/trig_a_i_syst_instance_type_apps_create_inst_type_contexts.eex.sql
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

    INSERT INTO ms_syst_data.syst_instance_type_contexts
        ( instance_type_application_id, application_context_id, default_db_pool_size )
    SELECT
        new.id
      , id
      , 0
    FROM ms_syst_data.syst_application_contexts
    WHERE application_id = new.application_id;

    RETURN new;
END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION ms_syst_data.trig_a_i_syst_instance_type_apps_create_inst_type_contexts()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_data.trig_a_i_syst_instance_type_apps_create_inst_type_contexts() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_data.trig_a_i_syst_instance_type_apps_create_inst_type_contexts() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst_data.trig_a_i_syst_instance_type_apps_create_inst_type_contexts() IS
$DOC$When a new association between an Application and an Instance Type is made by
inserting a record into this table, Instance Type Contexts are automatically
created by this function based on the Application Context records defined at the
time of INSERT into this table.  The default default_db_pool_size value is 0.

After the fact changes to Contexts must be managed manually.$DOC$;
-- File:        syst_instance_type_applications.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst_data/syst_instance_type_applications/syst_instance_type_applications.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_instance_type_applications
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_instance_type_applications_pk PRIMARY KEY
    ,instance_type_id
        uuid
        NOT NULL
        CONSTRAINT syst_instance_type_applications_instance_types_fk
            REFERENCES ms_syst_data.syst_enum_items (id)
            ON DELETE CASCADE
    ,application_id
        uuid
        NOT NULL
        CONSTRAINT syst_instance_type_applications_applications_fk
            REFERENCES ms_syst_data.syst_applications (id)
            ON DELETE CASCADE
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
    ,CONSTRAINT syst_instance_type_applications_instance_type_applications_udx
        UNIQUE (instance_type_id, application_id)
);

ALTER TABLE ms_syst_data.syst_instance_type_applications OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_instance_type_applications FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_instance_type_applications TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_instance_type_applications
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_instance_types_enum_item_check
    AFTER INSERT ON ms_syst_data.syst_instance_type_applications
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('instance_types', 'instance_type_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_instance_types_enum_item_check
    AFTER UPDATE ON ms_syst_data.syst_instance_type_applications
    FOR EACH ROW WHEN ( old.instance_type_id != new.instance_type_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_enum_item_check('instance_types', 'instance_type_id');

CREATE TRIGGER b50_trig_a_i_syst_instance_type_apps_create_inst_type_contexts
    AFTER INSERT ON ms_syst_data.syst_instance_type_applications
    FOR EACH ROW
        EXECUTE PROCEDURE ms_syst_data.trig_a_i_syst_instance_type_apps_create_inst_type_contexts();

COMMENT ON
    TABLE ms_syst_data.syst_instance_type_applications IS
$DOC$A many-to-many relation indicating which Instance Types are usable for each
Application.

Note that creating ms_syst_data.syst_application_contexts records prior to
inserting an Instance Type/Application association into this table is
recommended as default Instance Type Context records can be created
automatically on INSERT into this table so long as the supporting data is
available.  After insert here, manipulations of what Contexts Applications
require must be handled manually.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_type_applications.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_type_applications.instance_type_id IS
$DOC$A reference to the Instance Type being associated to an Application.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_type_applications.application_id IS
$DOC$A reference to the Application being associated with the Instance Type.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_type_applications.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_type_applications.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_type_applications.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_type_applications.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_type_applications.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_type_applications.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_type_applications.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
-- File:        syst_owners.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst_data/syst_owners/syst_owners.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_owners
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_owners_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_owners_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_owners_display_name_udx UNIQUE
    ,owner_state_id
        uuid
        NOT NULL
        CONSTRAINT syst_owner_owner_states_fk
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

ALTER TABLE ms_syst_data.syst_owners OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_owners FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_owners TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_owners
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_owner_states_enum_item_check
    AFTER INSERT ON ms_syst_data.syst_owners
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('owner_states', 'owner_state_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_owner_states_enum_item_check
    AFTER UPDATE ON ms_syst_data.syst_owners
    FOR EACH ROW WHEN ( old.owner_state_id != new.owner_state_id )EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('owner_states', 'owner_state_id');

COMMENT ON
    TABLE ms_syst_data.syst_owners IS
$DOC$Identifies instance owners.  Instance owners are typically the clients which
have commissioned the use of an application instance.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owners.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owners.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owners.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owners.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owners.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owners.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owners.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owners.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owners.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owners.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst_data.trig_a_i_syst_instances_create_instance_contexts()
RETURNS trigger AS
$BODY$

-- File:        trig_a_i_syst_instances_create_instance_contexts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst_data/syst_instances/trig_a_i_syst_instances_create_instance_contexts.eex.sql
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

    INSERT INTO ms_syst_data.syst_instance_contexts
        ( internal_name
        , instance_id
        , application_context_id
        , start_context
        , db_pool_size
        , context_code )
    SELECT
        new.internal_name || '_' || sac.internal_name
      , new.id
      , sac.id
      , sac.login_context
      , sitc.default_db_pool_size
      , public.gen_random_bytes( 16 )
    FROM
        ms_syst_data.syst_owners so,
        ms_syst_data.syst_application_contexts sac
            JOIN ms_syst_data.syst_instance_type_contexts sitc
                ON sitc.application_context_id = sac.id
            JOIN ms_syst_data.syst_applications sa
                ON sa.id = sac.application_id
            JOIN ms_syst_data.syst_instance_type_applications sita
                ON sita.id = sitc.instance_type_application_id
    WHERE
          so.id = new.owner_id
      AND sita.instance_type_id = new.instance_type_id
      AND sa.id = new.application_id;

    RETURN new;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION ms_syst_data.trig_a_i_syst_instances_create_instance_contexts()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_data.trig_a_i_syst_instances_create_instance_contexts() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_data.trig_a_i_syst_instances_create_instance_contexts() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst_data.trig_a_i_syst_instances_create_instance_contexts() IS
$DOC$Creates Instance Context records based on existing Application Contexts and Instance Type Contexts.$DOC$;
-- File:        syst_instances.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst_data/syst_instances/syst_instances.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_instances
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_instances_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_instances_internal_name_udx UNIQUE
    ,display_name
        text
        NOT NULL
        CONSTRAINT syst_instances_display_name_udx UNIQUE
    ,application_id
        uuid
        NOT NULL
        CONSTRAINT syst_instances_applications_fk
            REFERENCES ms_syst_data.syst_applications (id)
    ,instance_type_id
        uuid
        NOT NULL
        CONSTRAINT syst_instances_enum_instance_type_fk
            REFERENCES ms_syst_data.syst_enum_items (id)
    ,instance_state_id
        uuid
        NOT NULL
        CONSTRAINT syst_instances_enum_instance_state_fk
            REFERENCES ms_syst_data.syst_enum_items (id)
    ,owner_id
        uuid
        NOT NULL
        CONSTRAINT syst_instances_owners_fk
            REFERENCES ms_syst_data.syst_owners (id)
    ,owning_instance_id
        uuid
        CONSTRAINT syst_instances_owning_instance_fk
            REFERENCES ms_syst_data.syst_instances (id)
        CONSTRAINT syst_instances_self_ownership_chk
            CHECK (owning_instance_id IS NULL OR owning_instance_id != id)
    ,dbserver_name
        text
    ,instance_code
        bytea
        NOT NULL
    ,instance_options
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

ALTER TABLE ms_syst_data.syst_instances OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_instances FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_instances TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_instances
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_instance_types_enum_item_check
    AFTER INSERT ON ms_syst_data.syst_instances
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('instance_types', 'instance_type_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_instance_types_enum_item_check
    AFTER UPDATE ON ms_syst_data.syst_instances
    FOR EACH ROW WHEN ( old.instance_type_id != new.instance_type_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_enum_item_check(
                'instance_types', 'instance_type_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_i_instance_states_enum_item_check
    AFTER INSERT ON ms_syst_data.syst_instances
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('instance_states', 'instance_state_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_instance_states_enum_item_check
    AFTER UPDATE ON ms_syst_data.syst_instances
    FOR EACH ROW WHEN ( old.instance_state_id != new.instance_state_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_enum_item_check(
                'instance_states', 'instance_state_id');

CREATE TRIGGER b50_trig_a_i_syst_instances_create_instance_contexts
    AFTER INSERT ON ms_syst_data.syst_instances
    FOR EACH ROW
        EXECUTE PROCEDURE ms_syst_data.trig_a_i_syst_instances_create_instance_contexts();

COMMENT ON
    TABLE ms_syst_data.syst_instances IS
$DOC$Defines known application instances and provides their configuration settings.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instances.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instances.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instances.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instances.application_id IS
$DOC$Indicates an instance of which application is being described by the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instances.instance_type_id IS
$DOC$Indicates the type of the instance.  This can designate instances as being
production or non-production, or make other functional differences between
instances created for different reasons based on the assigned instance type.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instances.instance_state_id IS
$DOC$Establishes the current life-cycle state of the instance record.  This can
determine functionality such as if the instance is usable, visible, or if it may
be purged from the database completely.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instances.owner_id IS
$DOC$Identifies the owner of the instance.  The owner is the entity which
commissioned the instance and is the "user" of the instance.  Owners have
nominal management rights over their instances, such as which access accounts
and which credential types are allowed to be used to authenticate to the owner's
instances.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instances.owning_instance_id IS
$DOC$In some cases, an instance is considered subordinate to another instance.  For
example, consider a production environment and a related sandbox environment.
The existence of the sandbox doesn't have real meaning without being associated
with some sort of production instance where the real work is performed.  This
kind of association becomes clearer in SaaS environments where a primary
instance is contracted for, but other supporting instances, such as a sandbox,
should follow certain account related actions of the primary.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instances.dbserver_name IS
$DOC$Identifies on which database server the instance is hosted. If empty, no
server has been assigned and the instance is unstartable.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instances.instance_code IS
$DOC$This is a random sequence of bytes intended for use in certain algorithmic
credential generation.  Note that losing this value may prevent the Instance
from being started due to bad credentials; there may be other consequences as
well.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instances.instance_options IS
$DOC$A key/value store of values which define application or instance specific
options.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instances.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instances.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instances.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instances.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instances.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instances.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instances.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
-- File:        syst_instance_type_contexts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst_data/syst_instance_type_contexts/syst_instance_type_contexts.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_instance_type_contexts
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_instance_type_contexts_pk PRIMARY KEY
    ,instance_type_application_id
        uuid
        NOT NULL
        CONSTRAINT syst_instance_type_contexts_inst_type_app_fk
            REFERENCES ms_syst_data.syst_instance_type_applications (id)
            ON DELETE CASCADE
    ,application_context_id
        uuid
        NOT NULL
        CONSTRAINT syst_instance_type_contexts_application_contexts_fk
            REFERENCES ms_syst_data.syst_application_contexts (id)
            ON DELETE CASCADE
    ,default_db_pool_size
        integer
        NOT NULL DEFAULT 0
        CONSTRAINT syst_instance_type_contexts_default_db_pool_size_chk
            CHECK ( default_db_pool_size >= 0 )
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
    ,CONSTRAINT syst_instance_type_contexts_instance_types_applications_udx
        UNIQUE (instance_type_application_id, application_context_id)
);

ALTER TABLE ms_syst_data.syst_instance_type_contexts OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_instance_type_contexts FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_instance_type_contexts TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_instance_type_contexts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE ms_syst_data.syst_instance_type_contexts IS
$DOC$Establishes Instance Type defaults for each of an Application's defined
datastore contexts.  In practice, these records are used in the creation of
Instance Context records, but do not establish a direct relationship; records in
this table simply inform us what Instance Contexts should exist and give us
default values to use in their creation.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_type_contexts.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_type_contexts.instance_type_application_id IS
$DOC$The Instance Type/Application association to which the context definition
belongs.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_type_contexts.application_context_id IS
$DOC$The Application Context which is being represented in the Instance Type.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_type_contexts.default_db_pool_size IS
$DOC$A default pool size which is assigned to new Instances of the Instance Type
unless the creator of the Instance specifies a different value.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_type_contexts.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_type_contexts.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_type_contexts.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_type_contexts.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_type_contexts.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_type_contexts.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_type_contexts.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
-- File:        syst_instance_contexts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst_data/syst_instance_contexts/syst_instance_contexts.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_instance_contexts
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_instance_contexts_pk PRIMARY KEY
    ,internal_name
        text COLLATE ms_syst_priv.variant_insensitive
        NOT NULL
        CONSTRAINT syst_instance_contexts_internal_name_udx UNIQUE
    ,instance_id
        uuid
        NOT NULL
        CONSTRAINT syst_instance_contexts_instances_fk
            REFERENCES ms_syst_data.syst_instances (id)
            ON DELETE CASCADE
    ,application_context_id
        uuid
        NOT NULL
        CONSTRAINT syst_instance_contexts_application_contexts_fk
            REFERENCES ms_syst_data.syst_application_contexts (id)
            ON DELETE CASCADE
    ,start_context
        boolean
        NOT NULl DEFAULT false
    ,db_pool_size
        integer
        NOT NULL DEFAULT 0
        CONSTRAINT syst_instance_contexts_db_pool_size_chk
            CHECK ( db_pool_size >= 0 )
    ,context_code
        bytea
        NOT NULL
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

ALTER TABLE ms_syst_data.syst_instance_contexts OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_instance_contexts FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_instance_contexts TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_instance_contexts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE ms_syst_data.syst_instance_contexts IS
$DOC$Instance specific settings which determine how each Instance connects to the
defined Application Contexts.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_contexts.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_contexts.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_contexts.instance_id IS
$DOC$Identifies the parent Instance for which Instance Contexts are being defined.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_contexts.application_context_id IS
$DOC$Identifies the Application Context which is being defined for the Instance.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_contexts.start_context IS
$DOC$If true, indicates that the Instance Context should be started, so long as the
Application Context record is also set to allow context starting.  If false, the
Instance Context not be started, even if the related Application Context is set
to allow context starts.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_contexts.db_pool_size IS
$DOC$If the Application Context is a login datastore context, this value establishes
how many database connections to open on behalf of this Instance Context.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_contexts.context_code IS
$DOC$An Instance Context specific series of bytes which are used in algorithmic
credential generation.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_contexts.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_contexts.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_contexts.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_contexts.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_contexts.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_contexts.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_contexts.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_i_syst_applications()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_applications.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst/api_views/syst_applications/trig_i_i_syst_applications.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

BEGIN

    INSERT INTO ms_syst_data.syst_applications
        ( internal_name
        , display_name
        , syst_description)
    VALUES
        ( new.internal_name
        , new.display_name
        , new.syst_description)
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_i_syst_applications()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_applications() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_applications() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_i_syst_applications() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_applications API View for INSERT operations.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_u_syst_applications()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_applications.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst/api_views/syst_applications/trig_i_u_syst_applications.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

BEGIN

    IF
        new.internal_name != old.internal_name
    THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'The requested data update included changes to fields disallowed ' ||
                          'by the business rules of the API View.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst'
                            ,p_proc_name      => 'trig_i_u_syst_applications'
                            ,p_exception_name => 'invalid_api_view_call'
                            ,p_errcode        => 'PM008'
                            ,p_param_data     =>
                                jsonb_build_object('new', to_jsonb(new), 'old', to_jsonb(old))
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

    UPDATE ms_syst_data.syst_applications
    SET
          display_name     = new.display_name
        , syst_description = new.syst_description
    WHERE id = new.id
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_u_syst_applications()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_applications() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_applications() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_u_syst_applications() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_appliations API View for UPDATE operations.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_d_syst_applications()
RETURNS trigger AS
$BODY$

-- File:        trig_i_d_syst_applications.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst/api_views/syst_applications/trig_i_d_syst_applications.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

BEGIN

    RAISE EXCEPTION
        USING
            MESSAGE = 'Records may not be deleted using this API view.',
            DETAIL = ms_syst_priv.get_exception_details(
                         p_proc_schema    => 'ms_syst'
                        ,p_proc_name      => 'trig_i_d_syst_applications'
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

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_d_syst_applications()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_applications() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_applications() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_d_syst_applications() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_applications API View for DELETE operations.$DOC$;
-- File:        syst_applications.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst/api_views/syst_applications/syst_applications.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE VIEW ms_syst.syst_applications AS
    SELECT
        id
       ,internal_name
       ,display_name
       ,syst_description
       ,diag_timestamp_created
       ,diag_role_created
       ,diag_timestamp_modified
       ,diag_wallclock_modified
       ,diag_role_modified
       ,diag_row_version
       ,diag_update_count
    FROM ms_syst_data.syst_applications;

ALTER VIEW ms_syst.syst_applications OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_applications FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_applications
    INSTEAD OF INSERT ON ms_syst.syst_applications
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_applications();

CREATE TRIGGER a50_trig_i_u_syst_applications
    INSTEAD OF UPDATE ON ms_syst.syst_applications
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_applications();

CREATE TRIGGER a50_trig_i_d_syst_applications
    INSTEAD OF DELETE ON ms_syst.syst_applications
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_applications();

COMMENT ON
    VIEW ms_syst.syst_applications IS
$DOC$Describes the known applications which are managed by the global database and
authentication infrastructure.

This API View allows the application to read and maintain data according to well defined
application business rules.

Attempts at invalid data maintenance via this API may result in the invalid
changes being ignored or may raise an exception.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_i_syst_application_contexts()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_application_contexts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst/api_views/syst_application_contexts/trig_i_i_syst_application_contexts.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

BEGIN

    INSERT INTO ms_syst_data.syst_application_contexts
        ( internal_name
        , display_name
        , application_id
        , description
        , start_context
        , login_context
        , database_owner_context )
    VALUES
        ( new.internal_name
        , new.display_name
        , new.application_id
        , new.description
        , new.start_context
        , new.login_context
        , new.database_owner_context )
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_i_syst_application_contexts()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_application_contexts() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_application_contexts() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_i_syst_application_contexts() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_application_contexts API View for INSERT operations.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_u_syst_application_contexts()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_application_contexts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst/api_views/syst_application_contexts/trig_i_u_syst_application_contexts.eex.sql
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
        new.internal_name          != old.internal_name OR
        new.application_id         != old.application_id OR
        new.login_context          != old.login_context OR
        new.database_owner_context != old.database_owner_context
    THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'The requested data update included changes to fields disallowed ' ||
                          'by the business rules of the API View.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst'
                            ,p_proc_name      => 'trig_i_u_syst_application_contexts'
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

    UPDATE ms_syst_data.syst_application_contexts
    SET
          start_context = new.start_context
        , display_name  = new.display_name
        , description   = new.description
    WHERE id = new.id
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_u_syst_application_contexts()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_application_contexts() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_application_contexts() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_u_syst_application_contexts() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_application_contexts API View for UPDATE operations.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_d_syst_application_contexts()
RETURNS trigger AS
$BODY$

-- File:        trig_i_d_syst_application_contexts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst/api_views/syst_application_contexts/trig_i_d_syst_application_contexts.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

BEGIN

    DELETE FROM ms_syst_data.syst_application_contexts WHERE id = old.id RETURNING * INTO old;

    RETURN old;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_d_syst_application_contexts()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_application_contexts() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_application_contexts() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_d_syst_application_contexts() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_application_contexts API View for DELETE operations.$DOC$;
-- File:        syst_application_contexts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst/api_views/syst_application_contexts/syst_application_contexts.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE VIEW ms_syst.syst_application_contexts AS
SELECT
    id
  , internal_name
  , display_name
  , application_id
  , description
  , start_context
  , login_context
  , database_owner_context
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM ms_syst_data.syst_application_contexts;

ALTER VIEW ms_syst.syst_application_contexts OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_application_contexts FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_application_contexts
    INSTEAD OF INSERT ON ms_syst.syst_application_contexts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_application_contexts();

CREATE TRIGGER a50_trig_i_u_syst_application_contexts
    INSTEAD OF UPDATE ON ms_syst.syst_application_contexts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_application_contexts();

CREATE TRIGGER a50_trig_i_d_syst_application_contexts
    INSTEAD OF DELETE ON ms_syst.syst_application_contexts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_application_contexts();

COMMENT ON
    VIEW ms_syst.syst_application_contexts IS
$DOC$Applications are written with certain security and connection
characteristics in mind which correlate to database roles used by the
application for establishing connections.  This table defines the datastore
contexts the application is expecting so that Instance records can be validated
against the expectations.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_i_syst_owners()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_owners.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst/api_views/syst_owners/trig_i_i_syst_owners.eex.sql
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

    INSERT INTO ms_syst_data.syst_owners
        ( internal_name, display_name, owner_state_id )
    VALUES
        ( new.internal_name, new.display_name, new.owner_state_id )
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_i_syst_owners()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_owners() FROM public;

COMMENT ON FUNCTION ms_syst.trig_i_i_syst_owners() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_owners API View for INSERT operations.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_u_syst_owners()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_owners.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst/api_views/syst_owners/trig_i_u_syst_owners.eex.sql
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

    UPDATE ms_syst_data.syst_owners SET
        internal_name  = new.internal_name
      , display_name   = new.display_name
      , owner_state_id = new.owner_state_id
    WHERE id = new.id
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_u_syst_owners()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_owners() FROM public;

COMMENT ON FUNCTION ms_syst.trig_i_u_syst_owners() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_owners API View for UPDATE operations.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_d_syst_owners()
RETURNS trigger AS
$BODY$

-- File:        trig_i_d_syst_owners.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst/api_views/syst_owners/trig_i_d_syst_owners.eex.sql
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
        exists( SELECT
                    TRUE
                FROM ms_syst_data.syst_enum_functional_types seft
                WHERE
                      seft.enum_id = old.owner_state_id
                  AND seft.internal_name != 'owner_states_purge_eligible' )
    THEN

        RAISE EXCEPTION
            USING
                MESSAGE = 'You cannot delete an owner that is not in a purge ' ||
                          'eligible owner state using this API view.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst'
                            ,p_proc_name      => 'trig_i_d_syst_owners'
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

    DELETE FROM ms_syst_data.syst_owners WHERE id = old.id RETURNING * INTO old;

    RETURN old;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_d_syst_owners()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_owners() FROM public;

COMMENT ON FUNCTION ms_syst.trig_i_d_syst_owners() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_owners API View for DELETE operations.$DOC$;
-- File:        syst_owners.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst/api_views/syst_owners/syst_owners.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE VIEW ms_syst.syst_owners AS
    SELECT
        id
      , internal_name
      , display_name
      , owner_state_id
      , diag_timestamp_created
      , diag_role_created
      , diag_timestamp_modified
      , diag_wallclock_modified
      , diag_role_modified
      , diag_row_version
      , diag_update_count
    FROM ms_syst_data.syst_owners;

ALTER VIEW ms_syst.syst_owners OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_owners FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_owners
    INSTEAD OF INSERT ON ms_syst.syst_owners
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_owners();

CREATE TRIGGER a50_trig_i_u_syst_owners
    INSTEAD OF UPDATE ON ms_syst.syst_owners
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_owners();

CREATE TRIGGER a50_trig_i_d_syst_owners
    INSTEAD OF DELETE ON ms_syst.syst_owners
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_owners();

COMMENT ON
    VIEW ms_syst.syst_owners IS
$DOC$Identifies instance owners.  Instance owners are typically the clients which
have commissioned the use of an application instance.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owners.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.

This column is read only and not maintainable via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owners.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owners.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owners.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.

This column is read only and not maintainable via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owners.diag_role_created IS
$DOC$The database role which created the record.

This column is read only and not maintainable via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owners.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.

This column is read only and not maintainable via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owners.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.

This column is read only and not maintainable via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owners.diag_role_modified IS
$DOC$The database role which modified the record.

This column is read only and not maintainable via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owners.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.

This column is read only and not maintainable via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owners.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.

This column is read only and not maintainable via this API view.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_i_syst_instance_type_applications()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_instance_type_applications.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst/api_views/syst_instance_type_applications/trig_i_i_syst_instance_type_applications.eex.sql
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

    INSERT INTO ms_syst_data.syst_instance_type_applications
        ( instance_type_id, application_id )
    VALUES
        ( new.instance_type_id, new.application_id )
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_i_syst_instance_type_applications()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_instance_type_applications() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_instance_type_applications() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_i_syst_instance_type_applications() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_enum_items API View for INSERT operations.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_u_syst_instance_type_applications()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_instance_type_applications.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst/api_views/syst_instance_type_applications/trig_i_u_syst_instance_type_applications.eex.sql
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

    RAISE EXCEPTION
        USING
            MESSAGE = 'No fields are updatable via this API view for this relation.',
            DETAIL = ms_syst_priv.get_exception_details(
                         p_proc_schema    => 'ms_syst'
                        ,p_proc_name      => 'trig_i_u_syst_instance_type_applications'
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

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_u_syst_instance_type_applications()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_instance_type_applications() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_instance_type_applications() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_u_syst_instance_type_applications() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_enum_items API View for UPDATE operations.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_d_syst_instance_type_applications()
RETURNS trigger AS
$BODY$

-- File:        trig_i_d_syst_instance_type_applications.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst/api_views/syst_instance_type_applications/trig_i_d_syst_instance_type_applications.eex.sql
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

    DELETE
    FROM ms_syst_data.syst_instance_type_applications
    WHERE id = old.id
    RETURNING * INTO old;

    RETURN old;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_d_syst_instance_type_applications()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_instance_type_applications() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_instance_type_applications() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_d_syst_instance_type_applications() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_enum_items API View for DELETE operations.$DOC$;
-- File:        syst_instance_type_applications.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst/api_views/syst_instance_type_applications/syst_instance_type_applications.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE VIEW ms_syst.syst_instance_type_applications AS
SELECT
    id
  , instance_type_id
  , application_id
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM ms_syst_data.syst_instance_type_applications;

ALTER VIEW ms_syst.syst_instance_type_applications OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_instance_type_applications FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_instance_type_applications
    INSTEAD OF INSERT ON ms_syst.syst_instance_type_applications
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_instance_type_applications();

CREATE TRIGGER a50_trig_i_u_syst_instance_type_applications
    INSTEAD OF UPDATE ON ms_syst.syst_instance_type_applications
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_instance_type_applications();

CREATE TRIGGER a50_trig_i_d_syst_instance_type_applications
    INSTEAD OF DELETE ON ms_syst.syst_instance_type_applications
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_instance_type_applications();

COMMENT ON
    VIEW ms_syst.syst_instance_type_applications IS
$DOC$A many-to-many relation indicating which Instance Types are usable for each
Application.

Note that creating ms_syst_data.syst_application_contexts records prior to
inserting an Instance Type/Application association into this table is
recommended as default Instance Type Context records can be created
automatically on INSERT into this table so long as the supporting data is
available.  After insert here, manipulations of what Contexts Applications
require must be handled manually.

Also note that this API view only allows for INSERT or DELETE operations to be
performed on the data.  UPDATE operations are not valid and will cause an
exception to be raised.

This API View allows the application to create and read the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_type_applications.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.

This value may not be updated via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_type_applications.instance_type_id IS
$DOC$A reference to the Instance Type being associated to an Application.

This value must be set on INSERT and may not be updated later via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_type_applications.application_id IS
$DOC$A reference to the Application being associated with the Instance Type.

This value must be set on INSERT and may not be updated later via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_type_applications.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_type_applications.diag_role_created IS
$DOC$The database role which created the record.

This value may not be updated via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_type_applications.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.

This value may not be updated via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_type_applications.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.

This value may not be updated via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_type_applications.diag_role_modified IS
$DOC$The database role which modified the record.

This value may not be updated via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_type_applications.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.

This value may not be updated via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_type_applications.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.

This value may not be updated via this API view.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_i_syst_instance_type_contexts()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_instance_type_contexts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst/api_views/syst_instance_type_contexts/trig_i_i_syst_instance_type_contexts.eex.sql
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

    RAISE EXCEPTION
        USING
            MESSAGE = 'Records are created automatically at ' ||
                      'ms_syst_data.syst_instance_type_applications INSERT ' ||
                      'time and may not be inserted via this API view.',
            DETAIL = ms_syst_priv.get_exception_details(
                         p_proc_schema    => 'ms_syst'
                        ,p_proc_name      => 'trig_i_i_syst_instance_type_contexts'
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

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_i_syst_instance_type_contexts()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_instance_type_contexts() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_instance_type_contexts() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_i_syst_instance_type_contexts() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_enum_items API View for INSERT operations.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_u_syst_instance_type_contexts()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_instance_type_contexts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst/api_views/syst_instance_type_contexts/trig_i_u_syst_instance_type_contexts.eex.sql
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
        new.instance_type_application_id != old.instance_type_application_id OR
        new.application_context_id       != old.application_context_id
    THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'The requested data update included changes to fields disallowed ' ||
                          'by the business rules of the API View.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst'
                            ,p_proc_name      => 'trig_i_u_syst_instance_type_contexts'
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

    UPDATE ms_syst_data.syst_instance_type_contexts
    SET default_db_pool_size = new.default_db_pool_size
    WHERE id = new.id
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_u_syst_instance_type_contexts()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_instance_type_contexts() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_instance_type_contexts() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_u_syst_instance_type_contexts() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_enum_items API View for UPDATE operations.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_d_syst_instance_type_contexts()
RETURNS trigger AS
$BODY$

-- File:        trig_i_d_syst_instance_type_contexts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst/api_views/syst_instance_type_contexts/trig_i_d_syst_instance_type_contexts.eex.sql
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

BEGIN

    RAISE EXCEPTION
        USING
            MESSAGE = 'Records are deleted automatically at ' ||
                      'ms_syst_data.syst_instance_type_applications DELETE ' ||
                      'time and may not be deleted via this API view.',
            DETAIL = ms_syst_priv.get_exception_details(
                         p_proc_schema    => 'ms_syst'
                        ,p_proc_name      => 'trig_i_i_syst_instance_type_contexts'
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

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_d_syst_instance_type_contexts()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_instance_type_contexts() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_instance_type_contexts() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_d_syst_instance_type_contexts() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_enum_items API View for DELETE operations.$DOC$;
-- File:        syst_instance_type_contexts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst/api_views/syst_instance_type_contexts/syst_instance_type_contexts.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE VIEW ms_syst.syst_instance_type_contexts AS
SELECT
    id
  , instance_type_application_id
  , application_context_id
  , default_db_pool_size
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM ms_syst_data.syst_instance_type_contexts;

ALTER VIEW ms_syst.syst_instance_type_contexts OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_instance_type_contexts FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_instance_type_contexts
    INSTEAD OF INSERT ON ms_syst.syst_instance_type_contexts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_instance_type_contexts();

CREATE TRIGGER a50_trig_i_u_syst_instance_type_contexts
    INSTEAD OF UPDATE ON ms_syst.syst_instance_type_contexts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_instance_type_contexts();

CREATE TRIGGER a50_trig_i_d_syst_instance_type_contexts
    INSTEAD OF DELETE ON ms_syst.syst_instance_type_contexts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_instance_type_contexts();

COMMENT ON
    VIEW ms_syst.syst_instance_type_contexts IS
$DOC$Establishes Instance Type defaults for each of an Application's defined
datastore contexts.  In practice, these records are used in the creation of
Instance Context records, but do not establish a direct relationship; records in
this table simply inform us what Instance Contexts should exist and give us
default values to use in their creation.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instance_type_contexts.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.

This column is read only and not maintainable via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instance_type_contexts.instance_type_application_id IS
$DOC$The Instance Type/Application association to which the context definition
belongs.

This API view will allow INSERT operations for this column, but not UPDATE.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instance_type_contexts.application_context_id IS
$DOC$The Application Context which is being represented in the Instance Type.

This API view will allow INSERT operations for this column, but not UPDATE.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instance_type_contexts.default_db_pool_size IS
$DOC$A default pool size which is assigned to new Instances of the Instance Type
unless the creator of the Instance specifies a different value.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instance_type_contexts.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.

This column is read only and not maintainable via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instance_type_contexts.diag_role_created IS
$DOC$The database role which created the record.

This column is read only and not maintainable via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instance_type_contexts.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.

This column is read only and not maintainable via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instance_type_contexts.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.

This column is read only and not maintainable via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instance_type_contexts.diag_role_modified IS
$DOC$The database role which modified the record.

This column is read only and not maintainable via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instance_type_contexts.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.

This column is read only and not maintainable via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instance_type_contexts.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.

This column is read only and not maintainable via this API view.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_i_syst_instances()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_instances.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst/api_views/syst_instances/trig_i_i_syst_instances.eex.sql
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

    INSERT INTO ms_syst_data.syst_instances
        ( internal_name
        , display_name
        , application_id
        , instance_type_id
        , instance_state_id
        , owner_id
        , owning_instance_id
        , dbserver_name
        , instance_code
        , instance_options )
    VALUES
        ( new.internal_name
        , new.display_name
        , new.application_id
        , new.instance_type_id
        , new.instance_state_id
        , new.owner_id
        , new.owning_instance_id
        , new.dbserver_name
        , new.instance_code
        , new.instance_options )
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_i_syst_instances()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_instances() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_instances() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_i_syst_instances() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_instances API View for INSERT operations.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_u_syst_instances()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_instances.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst/api_views/syst_instances/trig_i_u_syst_instances.eex.sql
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
        new.internal_name      != old.internal_name OR
        new.application_id     != old.application_id OR
        new.instance_type_id   != old.instance_type_id OR
        new.owner_id           != old.owner_id OR
        new.owning_instance_id != old.owning_instance_id
    THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'The requested data update included changes to fields disallowed ' ||
                          'by the business rules of the API View.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst'
                            ,p_proc_name      => 'trig_i_u_syst_instances'
                            ,p_exception_name => 'invalid_api_view_call'
                            ,p_errcode        => 'PM008'
                            ,p_param_data     => jsonb_build_object('new', new, 'old', old)
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

    UPDATE ms_syst_data.syst_instances
    SET
        display_name      = new.display_name
      , instance_state_id = new.instance_state_id
      , dbserver_name     = new.dbserver_name
      , instance_code     = new.instance_code
      , instance_options  = new.instance_options
    WHERE id = new.id
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_u_syst_instances()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_instances() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_instances() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_u_syst_instances() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_instances API View for UPDATE operations.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_d_syst_instances()
RETURNS trigger AS
$BODY$

-- File:        trig_i_d_syst_instances.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst/api_views/syst_instances/trig_i_d_syst_instances.eex.sql
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

    DELETE FROM ms_syst_data.syst_instances WHERE id = old.id RETURNING * INTO old;

    RETURN old;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_d_syst_instances()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_instances() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_instances() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_d_syst_instances() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_instances API View for DELETE operations.$DOC$;
-- File:        syst_instances.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst/api_views/syst_instances/syst_instances.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE VIEW ms_syst.syst_instances AS
SELECT
    id
  , internal_name
  , display_name
  , application_id
  , instance_type_id
  , instance_state_id
  , owner_id
  , owning_instance_id
  , dbserver_name
  , instance_code
  , instance_options
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM ms_syst_data.syst_instances;

ALTER VIEW ms_syst.syst_instances OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_instances FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_instances
    INSTEAD OF INSERT ON ms_syst.syst_instances
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_instances();

CREATE TRIGGER a50_trig_i_u_syst_instances
    INSTEAD OF UPDATE ON ms_syst.syst_instances
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_instances();

CREATE TRIGGER a50_trig_i_d_syst_instances
    INSTEAD OF DELETE ON ms_syst.syst_instances
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_instances();

COMMENT ON
    VIEW ms_syst.syst_instances IS
$DOC$Defines known application instances and provides their configuration settings.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instances.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.

This value may not be updated via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instances.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instances.display_name IS
$DOC$A friendly name and candidate key for the record, suitable for use in user
interactions$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instances.application_id IS
$DOC$Indicates an instance of which application is being described by the record.

Once set, this value may may not be updated via this API view later.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instances.instance_type_id IS
$DOC$Indicates the type of the instance.  This can designate instances as being
production or non-production, or make other functional differences between
instances created for different reasons based on the assigned instance type.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instances.instance_state_id IS
$DOC$Establishes the current life-cycle state of the instance record.  This can
determine functionality such as if the instance is usable, visible, or if it may
be purged from the database completely.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instances.owner_id IS
$DOC$Identifies the owner of the instance.  The owner is the entity which
commissioned the instance and is the "user" of the instance.  Owners have
nominal management rights over their instances, such as which access accounts
and which credential types are allowed to be used to authenticate to the owner's
instances.

Once set, this value may not be updated via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instances.owning_instance_id IS
$DOC$In some cases, an instance is considered subordinate to another instance.  For
example, consider a production environment and a related sandbox environment.
The existence of the sandbox doesn't have real meaning without being associated
with some sort of production instance where the real work is performed.  This
kind of association becomes clearer in SaaS environments where a primary
instance is contracted for, but other supporting instances, such as a sandbox,
should follow certain account related actions of the primary.

Once set, this value may not be updated via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instances.dbserver_name IS
$DOC$Identifies on which database server the instance is hosted. If empty, no
server has been assigned and the instance is unstartable.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instances.instance_code IS
$DOC$This is a random sequence of bytes intended for use in certain algorithmic
credential generation.  Note that losing this value may prevent the Instance
from being started due to bad credentials; there may be other consequences as
well.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instances.instance_options IS
$DOC$A key/value store of values which define application or instance specific
options.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instances.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instances.diag_role_created IS
$DOC$The database role which created the record.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instances.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instances.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instances.diag_role_modified IS
$DOC$The database role which modified the record.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instances.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instances.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.

This value is read only from this API view.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_i_syst_instance_contexts()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_instance_contexts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst/api_views/syst_instance_contexts/trig_i_i_syst_instance_contexts.eex.sql
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

    RAISE EXCEPTION
        USING
            MESSAGE = 'Records in this table are created automatically when ' ||
                      'its parent records are created.  Direct creation via ' ||
                      'this API view is not supported.',
            DETAIL = ms_syst_priv.get_exception_details(
                         p_proc_schema    => 'ms_syst'
                        ,p_proc_name      => 'trig_i_i_syst_instance_contexts'
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

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_i_syst_instance_contexts()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_instance_contexts() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_instance_contexts() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_i_syst_instance_contexts() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_instance_contexts API View for INSERT operations.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_u_syst_instance_contexts()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_instance_contexts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst/api_views/syst_instance_contexts/trig_i_u_syst_instance_contexts.eex.sql
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
        new.internal_name          != old.internal_name OR
        new.instance_id            != old.instance_id OR
        new.application_context_id != old.application_context_id
    THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'The requested data update included changes to fields disallowed ' ||
                          'by the business rules of the API View.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst'
                            ,p_proc_name      => 'trig_i_u_syst_instance_contexts'
                            ,p_exception_name => 'invalid_api_view_call'
                            ,p_errcode        => 'PM008'
                            ,p_param_data     =>
                                jsonb_build_object('new', to_jsonb(new), 'old', to_jsonb(old))
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

    UPDATE ms_syst_data.syst_instance_contexts
    SET
        start_context = new.start_context
      , db_pool_size  = new.db_pool_size
      , context_code  = new.context_code
    WHERE id = new.id
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_u_syst_instance_contexts()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_instance_contexts() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_instance_contexts() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_u_syst_instance_contexts() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_instance_contexts API View for UPDATE operations.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_d_syst_instance_contexts()
RETURNS trigger AS
$BODY$

-- File:        trig_i_d_syst_instance_contexts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst/api_views/syst_instance_contexts/trig_i_d_syst_instance_contexts.eex.sql
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

    RAISE EXCEPTION
        USING
            MESSAGE = 'Records in this table are deleted automatically when ' ||
                      'its parent records are deleted.  Direct deletion via ' ||
                      'this API view is not supported.',
            DETAIL = ms_syst_priv.get_exception_details(
                         p_proc_schema    => 'ms_syst'
                        ,p_proc_name      => 'trig_i_d_syst_instance_contexts'
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

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_d_syst_instance_contexts()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_instance_contexts() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_instance_contexts() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_d_syst_instance_contexts() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_instance_contexts API View for DELETE operations.$DOC$;
-- File:        syst_instance_contexts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/ms_syst/api_views/syst_instance_contexts/syst_instance_contexts.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE VIEW ms_syst.syst_instance_contexts AS
SELECT
    id
  , internal_name
  , instance_id
  , application_context_id
  , start_context
  , db_pool_size
  , context_code
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM ms_syst_data.syst_instance_contexts;

ALTER VIEW ms_syst.syst_instance_contexts OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_instance_contexts FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_instance_contexts
    INSTEAD OF INSERT ON ms_syst.syst_instance_contexts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_instance_contexts();

CREATE TRIGGER a50_trig_i_u_syst_instance_contexts
    INSTEAD OF UPDATE ON ms_syst.syst_instance_contexts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_instance_contexts();

CREATE TRIGGER a50_trig_i_d_syst_instance_contexts
    INSTEAD OF DELETE ON ms_syst.syst_instance_contexts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_instance_contexts();

COMMENT ON
    VIEW ms_syst.syst_instance_contexts IS
$DOC$Instance specific settings which determine how each Instance connects to the
defined Application Contexts.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instance_contexts.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.

This column is read only and not maintainable via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instance_contexts.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.

This column's value must be set on INSERT, but may not be updated later using
this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instance_contexts.instance_id IS
$DOC$Identifies the parent Instance for which Instance Contexts are being defined.

This column's value must be set on INSERT, but may not be updated later using
this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instance_contexts.application_context_id IS
$DOC$Identifies the Application Context which is being defined for the Instance.

This column's value must be set on INSERT, but may not be updated later using
this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instance_contexts.start_context IS
$DOC$If true, indicates that the Instance Context should be started, so long as the
Application Context record is also set to allow context starting.  If false, the
Instance Context not be started, even if the related Application Context is set
to allow context starts.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instance_contexts.db_pool_size IS
$DOC$If the Application Context is a login datastore context, this value establishes
how many database connections to open on behalf of this Instance Context.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instance_contexts.context_code IS
$DOC$An Instance Context specific series of bytes which are used in algorithmic
credential generation.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instance_contexts.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.

This column is read only and not maintainable via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instance_contexts.diag_role_created IS
$DOC$The database role which created the record.

This column is read only and not maintainable via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instance_contexts.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.

This column is read only and not maintainable via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instance_contexts.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.

This column is read only and not maintainable via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instance_contexts.diag_role_modified IS
$DOC$The database role which modified the record.

This column is read only and not maintainable via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instance_contexts.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.

This column is read only and not maintainable via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instance_contexts.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.

This column is read only and not maintainable via this API view.$DOC$;
-- File:        initialize_enum_owner_states.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/seed_data/initialize_enum_owner_states.eex.sql
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
        p_enum_def => $INIT_ENUM_OWNER_STATES$
        {
          "internal_name": "owner_states",
          "display_name": "Owner States",
          "syst_description": "Enumerates the life-cycle states that an owner record might exist in.  Chiefly, this has to do with whether or not a particular owner is considered active or not.",
          "syst_defined": true,
          "user_maintainable": true,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [
            {
              "internal_name": "owner_states_active",
              "display_name": "Owner State / Active",
              "external_name": "Active",
              "syst_description": "The owner is active and available for normal use."
            },
            {
              "internal_name": "owner_states_suspended",
              "display_name": "Owner State / Suspended",
              "external_name": "Suspended",
              "syst_description": "The owner is not available for regular use, though some limited functionality may be available.  The owner is likely visible to users for this reason."
            },
            {
              "internal_name": "owner_states_inactive",
              "display_name": "Owner State / Inactive",
              "external_name": "Inactive",
              "syst_description": "The owner is not available for any use and would not typically be visible tp users for any purpose."
            },
            {
              "internal_name": "owner_states_purge_eligible",
              "display_name": "Owner State / Purge Eligible",
              "external_name": "Purge Eligible",
              "syst_description": "The owner is not available for any use, not visible to users and subject to be completely deleted from the system at any point in time."
            }
          ],
          "enum_items": [
            {
              "internal_name": "owner_states_sysdef_active",
              "display_name": "Owner State / Active",
              "external_name": "Active",
              "functional_type_name": "owner_states_active",
              "enum_default": true,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "The owner account is active and all associated records are considered active unless otherwise indicated.",
              "syst_options": {}
            },
            {
              "internal_name": "owner_states_sysdef_suspended",
              "display_name": "Owner State / Suspended",
              "external_name": "Suspended",
              "functional_type_name": "owner_states_suspended",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "The owner related instances or users are not available for regular use, though some limited functionality may be available.  The owner instances and some access is likely visible to users for this reason.  This status supersedes any instance or user specific state.",
              "syst_options": {}
            },
            {
              "internal_name": "owner_states_sysdef_inactive",
              "display_name": "Owner State / Inactive",
              "external_name": "Inactive",
              "functional_type_name": "owner_states_inactive",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "The owner account is not available for any use and would not typically be visible to users for any purpose.",
              "syst_options": {}
            },
            {
              "internal_name": "owner_states_sysdef_purge_eligible",
              "display_name": "Owner State / Purge Eligible",
              "external_name": "Purge Eligible",
              "functional_type_name": "owner_states_purge_eligible",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "The instance is not available for any use, not visible to users and subject to be completely deleted from the system at any point in time.",
              "syst_options": {}
            }
          ]
        }
            $INIT_ENUM_OWNER_STATES$::jsonb);

END;
$INIT_ENUM$;
-- File:        initialize_enum_instance_states.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/seed_data/initialize_enum_instance_states.eex.sql
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
        p_enum_def => $INIT_ENUM_INSTANCE_STATES$
        {
          "internal_name": "instance_states",
          "display_name": "Instance States",
          "syst_description": "Establishes the available states in the life-cycle of a system instance (ms_syst_data.syst_instances) record, including some direction of state related system functionality.",
          "syst_defined": true,
          "user_maintainable": true,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [
            {
              "internal_name": "instance_states_uninitialized",
              "display_name": "Instance State / Uninitialized",
              "external_name": "Uninitialized",
              "syst_description": "The instance definition record has been created, but the corresponding instance has not been created on the database server and is awaiting processing."
            },
            {
              "internal_name": "instance_states_initializing",
              "display_name": "Instance State / Initializing",
              "external_name": "Initializing",
              "syst_description": "The process of creating the instance has been started."
            },
            {
              "internal_name": "instance_states_initialized",
              "display_name": "Instance State / Initialized",
              "external_name": "Initialized",
              "syst_description": "Indicates that the Instance is initialized, but not yet active."
            },
            {
              "internal_name": "instance_states_active",
              "display_name": "Instance State / Active",
              "external_name": "Active",
              "syst_description": "The instance is created and usable by users."
            },
            {
              "internal_name": "instance_states_migrating",
              "display_name": "Instance State / Migrating",
              "external_name": "Migrating",
              "syst_description": "Indicates that the Instance is being migrated to the most recent application version."
            },
            {
              "internal_name": "instance_states_suspended",
              "display_name": "Instance State / Suspended",
              "external_name": "Suspended",
              "syst_description": "The instance is not available for regular use, though some limited functionality may be available.  The instance is likely visible to users for this reason."
            },
            {
              "internal_name": "instance_states_inactive",
              "display_name": "Instance State / Inactive",
              "external_name": "Inactive",
              "syst_description": "The instance is not available for any use and would not typically be visible tp users for any purpose."
            },
            {
              "internal_name": "instance_states_failed",
              "display_name": "Instance State / Failed",
              "external_name": "Failed",
              "syst_description": "The instance is in an error state and is not available for use."
            },
            {
              "internal_name": "instance_states_purge_eligible",
              "display_name": "Instance State / Purge Eligible",
              "external_name": "Purge Eligible",
              "syst_description": "The instance is not available for any use, not visible to users and subject to be completely deleted from the system at any point in time."
            }
          ],
          "enum_items": [
            {
              "internal_name": "instance_states_sysdef_uninitialized",
              "display_name": "Instance State / Uninitialized",
              "external_name": "Uninitialized",
              "functional_type_name": "instance_states_uninitialized",
              "enum_default": true,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "The instance definition record has been created, but the corresponding instance has not been created on the database server and is awaiting processing.",
              "syst_options": {}
            },
            {
              "internal_name": "instance_states_sysdef_initializing",
              "display_name": "Instance State / Initializing",
              "external_name": "Initializing",
              "functional_type_name": "instance_states_initializing",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "The process of creating the instance has been started.",
              "syst_options": {}
            },
            {
              "internal_name": "instance_states_sysdef_initialized",
              "display_name": "Instance State / Initialized",
              "external_name": "Initialized",
              "functional_type_name": "instance_states_initialized",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "Indicates that the Instance is initialized, but not yet active.",
              "syst_options": {}
            },
            {
              "internal_name": "instance_states_sysdef_active",
              "display_name": "Instance State / Active",
              "external_name": "Active",
              "functional_type_name": "instance_states_active",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "The instance is created and usable by users.",
              "syst_options": {}
            },
            {
              "internal_name": "instance_states_sysdef_migrating",
              "display_name": "Instance State / Migrating",
              "external_name": "Initialized",
              "functional_type_name": "instance_states_migrating",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "Indicates that the Instance is being migrated to the most recent application version.",
              "syst_options": {}
            },
            {
              "internal_name": "instance_states_sysdef_suspended",
              "display_name": "Instance State / Suspended",
              "external_name": "Suspended",
              "functional_type_name": "instance_states_suspended",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "The instance is not available for regular use, though some limited functionality may be available.  The instance is likely visible to users for this reason.",
              "syst_options": {}
            },
            {
              "internal_name": "instance_states_sysdef_inactive",
              "display_name": "Instance State / Inactive",
              "external_name": "Inactive",
              "functional_type_name": "instance_states_inactive",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "The instance is not available for any use and would not typically be visible tp users for any purpose.",
              "syst_options": {}
            },
            {
              "internal_name": "instance_states_sysdef_failed",
              "display_name": "Instance State / Failed",
              "external_name": "Inactive",
              "functional_type_name": "instance_states_failed",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "The instance is in an error state and is not available for use.",
              "syst_options": {}
            },
            {
              "internal_name": "instance_states_sysdef_purge_eligible",
              "display_name": "Instance State / Purge Eligible",
              "external_name": "Purge Eligible",
              "functional_type_name": "instance_states_purge_eligible",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "The instance is not available for any use, not visible to users and subject to be completely deleted from the system at any point in time.",
              "syst_options": {}
            }
          ]
        }
            $INIT_ENUM_INSTANCE_STATES$::jsonb);

END;
$INIT_ENUM$;
-- File:        initialize_enum_instance_types.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_instance/seed_data/initialize_enum_instance_types.eex.sql
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

    PERFORM ms_syst_priv.initialize_enum(
        p_enum_def =>
            $INIT_ENUM_INSTANCE_TYPES$
            {
              "internal_name": "instance_types",
              "display_name": "Instance Types",
              "syst_description": "Defines the available kinds of instances and specifies their capabilities.  This typing works both for simple informational categorization as well as functional concerns within the application.",
              "syst_defined": true,
              "user_maintainable": true,
              "default_syst_options": null,
              "default_user_options": null,
              "functional_types": [],
              "enum_items": []
            }
            $INIT_ENUM_INSTANCE_TYPES$::jsonb );

END;
$INIT_ENUM$;
-- File:        privileges.eex.sql
-- Location:    musebms/database/application/msmcp/components/ms_syst_instance_mgr/privileges.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

--
-- MscmpSystInstance
--

-- syst_applications

GRANT SELECT, INSERT, UPDATE ON TABLE ms_syst.syst_applications TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_applications() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_applications() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_applications() TO <%= ms_appusr %>;

-- syst_application_contexts

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_application_contexts TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_application_contexts() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_application_contexts() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_application_contexts() TO <%= ms_appusr %>;

-- syst_owners

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_owners TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_owners() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_owners() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_owners() TO <%= ms_appusr %>;

-- syst_instance_type_applications

GRANT SELECT, INSERT, DELETE ON TABLE ms_syst.syst_instance_type_applications TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_instance_type_applications() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_instance_type_applications() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_instance_type_applications() TO <%= ms_appusr %>;

-- syst_instance_type_contexts

GRANT SELECT, UPDATE ON TABLE ms_syst.syst_instance_type_contexts TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_instance_type_contexts() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_instance_type_contexts() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_instance_type_contexts() TO <%= ms_appusr %>;

-- syst_instances

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_instances TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_instances() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_instances() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_instances() TO <%= ms_appusr %>;

-- syst_instance_contexts

GRANT SELECT, UPDATE ON TABLE ms_syst.syst_instance_contexts TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_instance_contexts() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_instance_contexts() TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_instance_contexts() TO <%= ms_appusr %>;
-- File:        initialize_enum_instance_types.eex.sql
-- Location:    musebms/database/subsystems/mssub_mcp/gen_seed_data/initialize_enum_instance_types.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

INSERT INTO ms_syst_data.syst_enum_items
    ( internal_name
    , display_name
    , external_name
    , enum_id
    , enum_default
    , syst_defined
    , user_maintainable
    , syst_description
    , sort_order )
VALUES
    ( 'instance_types_sysdef_standard'
    , 'Instance Types / Standard'
    , 'Standard'
    , ( SELECT id
        FROM ms_syst_data.syst_enums
        WHERE internal_name = 'instance_types' )
    , TRUE
    , TRUE
    , TRUE
    , 'A simple type representing the most typical kind of Instance.'
    , 1 );
-- File:        initialize_enum_access_account_states.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/seed_data/initialize_enum_access_account_states.eex.sql
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
        p_enum_def => $INIT_ENUM_ACCESS_ACCOUNT_STATES$
        {
          "internal_name": "access_account_states",
          "display_name": "Access Account States",
          "syst_description": "Enumerates the available states which describe the life-cycle of the access account records.",
          "syst_defined": true,
          "user_maintainable": true,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [
            {
              "internal_name": "access_account_states_pending",
              "display_name": "Access Account State / Pending",
              "external_name": "Pending",
              "syst_description": "Indicates that the access account is pending validation.  When pending validation, new access accounts have been created, but verification that contact information such as the account holder's email address is valid, has not been completed.  When in pending status, the account cannot be used for regular authentication until verification has been completed."
            },
            {
              "internal_name": "access_account_states_active",
              "display_name": "Access Account State / Active",
              "external_name": "Active",
              "syst_description": "The access account is active and is considered active."
            },
            {
              "internal_name": "access_account_states_suspended",
              "display_name": "Access Account State / Suspended",
              "external_name": "Suspended",
              "syst_description": "The access account is currently suspended and not usable for regular system access.  Some basic maintenance functions may still be available to suspended access accounts as appropriate."
            },
            {
              "internal_name": "access_account_states_inactive",
              "display_name": "Access Account State / Inactive",
              "external_name": "Inactive",
              "syst_description": "The access account is not available for any use and would not typically be visible to users for any purpose."
            },
            {
              "internal_name": "access_account_states_purge_eligible",
              "display_name": "Access Account State / Purge Eligible",
              "external_name": "Purge Eligible",
              "syst_description": "The access account is not available for any use, not visible to users and subject to be completely deleted from the system at any point in time."
            }
          ],
          "enum_items": [
            {
              "internal_name": "access_account_states_sysdef_pending",
              "display_name": "Access Account State / Pending",
              "external_name": "Pending",
              "functional_type_name": "access_account_states_pending",
              "enum_default": true,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "Indicates that the access account is pending validation.  When pending validation, new access accounts have been created, but verification that contact information such as the account holder's email address is valid, has not been completed.  When in pending status, the account cannot be used for regular authentication until verification has been completed.",
              "syst_options": {}
            },
            {
              "internal_name": "access_account_states_sysdef_active",
              "display_name": "Access Account State / Active",
              "external_name": "Active",
              "functional_type_name": "access_account_states_active",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "The access account is active and is considered active.",
              "syst_options": {}
            },
            {
              "internal_name": "access_account_states_sysdef_suspended",
              "display_name": "Access Account State / Suspended",
              "external_name": "Suspended",
              "functional_type_name": "access_account_states_suspended",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "The access account is currently suspended and not usable for regular system access.  Some basic maintenance functions may still be available to suspended access accounts as appropriate.",
              "syst_options": {}
            },
            {
              "internal_name": "access_account_states_sysdef_inactive",
              "display_name": "Access Account State / Inactive",
              "external_name": "Inactive",
              "functional_type_name": "access_account_states_inactive",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "The access account is not available for any use and would not typically be visible to users for any purpose.",
              "syst_options": {}
            },
            {
              "internal_name": "access_account_states_sysdef_purge_eligible",
              "display_name": "Access Account State / Purge Eligible",
              "external_name": "Purge Eligible",
              "functional_type_name": "access_account_states_purge_eligible",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "The access account is not available for any use, not visible to users and subject to be completely deleted from the system at any point in time.",
              "syst_options": {}
            }
          ]
        }
            $INIT_ENUM_ACCESS_ACCOUNT_STATES$::jsonb);

END;
$INIT_ENUM$;
-- File:        initialize_enum_credential_types.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/seed_data/initialize_enum_credential_types.eex.sql
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
        p_enum_def => $INIT_ENUM_CREDENTIAL_TYPES$
        {
          "internal_name": "credential_types",
          "display_name": "Credential Types",
          "syst_description": "Established the various kinds of credentials that are available for verifying an identity.",
          "syst_defined": true,
          "user_maintainable": true,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [
            {
              "internal_name": "credential_types_password",
              "display_name": "Credential Type / Password",
              "external_name": "Password",
              "syst_description": "A simple user provided password."
            },
            {
              "internal_name": "credential_types_mfa_totp",
              "display_name": "Credential Type / Multi-factor, TOTP",
              "external_name": "MFA - TOTP",
              "syst_description": "Second factor authenticator for TOTP credentials."
            },
            {
              "internal_name": "credential_types_mfa_totp_recovery_code",
              "display_name": "Credential Type / Multi-factor, TOTP Recovery Code",
              "external_name": "MFA - TOTP Recovery Code",
              "syst_description": "Recovery codes for TOTP authenticator device loss support."
            },
            {
              "internal_name": "credential_types_mfa_known_host",
              "display_name": "Credential Type / Multi-factor, Known Host",
              "external_name": "MFA - Know Hosts",
              "syst_description": "When a user has been fully authenticated on a device, the user may elect to remember the device for a period of time and will not be prompted for secondary authentication when using that device.  This credential type assumes stored information on the device is sufficient to meet the multi-factor requirement."
            },
            {
              "internal_name": "credential_types_token_api",
              "display_name": "Credential Type / API Token",
              "external_name": "API Token",
              "syst_description": "Persistent tokens used for API access and similar automated systems access.  Typically this credential type would allow application access per the access account user's authorizations."
            },
            {
              "internal_name": "credential_types_token_validation",
              "display_name": "Credential Type / Validation Token",
              "external_name": "Validation Token",
              "syst_description": "A token based credential where the user is performing an identifier validation.  This credential type is restricted for use only in the validation process and should not be used for providing other application related functionality."
            },
            {
              "internal_name": "credential_types_token_recovery",
              "display_name": "Credential Type / Recovery Token",
              "external_name": "Recovery Token",
              "syst_description": "A token based credential where the user is requesting to recover from loss of another credential type, such as password recovery.  These credentials should be time limited and unusable for other authentication scenarios."
            }
          ],
          "enum_items": [
            {
              "internal_name": "credential_types_sysdef_password",
              "display_name": "Credential Type / Password",
              "external_name": "Password",
              "functional_type_name": "credential_types_password",
              "enum_default": true,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "A simple user provided password.",
              "syst_options": {}
            },
            {
              "internal_name": "credential_types_sysdef_mfa_totp",
              "display_name": "Credential Type / Multi-factor, TOTP",
              "external_name": "MFA - TOTP",
              "functional_type_name": "credential_types_mfa_totp",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "Second factor authenticator for TOTP credentials.",
              "syst_options": {}
            },
            {
              "internal_name": "credential_types_sysdef_mfa_totp_recovery_code",
              "display_name": "Credential Type / Multi-factor, TOTP Recovery Code",
              "external_name": "MFA - TOTP Recovery Code",
              "functional_type_name": "credential_types_mfa_totp_recovery_code",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "Recovery codes for TOTP authenticator device loss support.",
              "syst_options": {}
            },
            {
              "internal_name": "credential_types_sysdef_mfa_known_host",
              "display_name": "Credential Type / Multi-factor, Known Host",
              "external_name": "MFA - Know Hosts",
              "functional_type_name": "credential_types_mfa_known_host",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "When a user has been fully authenticated on a device, the user may elect to remember the device for a period of time and will not be prompted for secondary authentication when using that device.  This credential type assumes stored information on the device is sufficient to meet the multi-factor requirement.",
              "syst_options": {}
            },
            {
              "internal_name": "credential_types_sysdef_token_api",
              "display_name": "Credential Type / API Token",
              "external_name": "API Token",
              "functional_type_name": "credential_types_token_api",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "Persistent tokens used for API access and similar automated systems access.  Typically this credential type would allow application access per the access account user's authorizations.",
              "syst_options": {}
            },
            {
              "internal_name": "credential_types_sysdef_token_validation",
              "display_name": "Credential Type / Validation Token",
              "external_name": "Validation Token",
              "functional_type_name": "credential_types_token_validation",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "A token based credential where the user is performing an identifier validation.  This credential type is restricted for use only in the validation process and should not be used for providing other application related functionality.",
              "syst_options": {}
            },
            {
              "internal_name": "credential_types_sysdef_token_recovery",
              "display_name": "Credential Type / Recovery Token",
              "external_name": "Recovery Token",
              "functional_type_name": "credential_types_token_recovery",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": true,
              "syst_description": "A token based credential where the user is requesting to recover from loss of another credential type, such as password recovery.  These credentials should be time limited and unusable for other authentication scenarios.",
              "syst_options": {}
            }
          ]
        }
            $INIT_ENUM_CREDENTIAL_TYPES$::jsonb);

END;
$INIT_ENUM$;
-- File:        initialize_enum_identity_types.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/seed_data/initialize_enum_identity_types.eex.sql
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
        p_enum_def => $INIT_ENUM_IDENTITY_TYPES$
        {
          "internal_name": "identity_types",
          "display_name": "Identity Types",
          "syst_description": "Established the various kinds of credentials that are available for verifying an identity.",
          "syst_defined": true,
          "user_maintainable": false,
          "default_syst_options": null,
          "default_user_options": null,
          "functional_types": [
            {
              "internal_name": "identity_types_email",
              "display_name": "Identity Type / Email",
              "external_name": "Email",
              "syst_description": "This identity type indicates the sort of user name a human user would enter into a login form to identify themselves. The user identifier will always be an email address.  This identity may only be used for interactive logins and explicitly not for in scenarios where you would use token credential types for authentication."
            },
            {
              "internal_name": "identity_types_account",
              "display_name": "Identity Type / Account",
              "external_name": "Account",
              "syst_description": "Account IDs are system generated IDs which can be used similar to user name, but can be given to third parties, such as the administrator of an application instance for the purpose of being granted user access to the instance, without also disclosing personal ID information such as an email address.  These IDs are typical simple and easy to provide via verbal or written communication.  This ID type is not allowed for login."
            },
            {
              "internal_name": "identity_types_api",
              "display_name": "Identity Type / API",
              "external_name": "API",
              "syst_description": "A system generated ID for use in identifying the user account in automated access scenarios.  This kind of ID differs from the account_id in that it is significantly larger than an account ID would be and may only be used with token credential types."
            },
            {
              "internal_name": "identity_types_validation",
              "display_name": "Identity Type / Validation",
              "external_name": "Validation",
              "syst_description": "A one time use identifier which, along with a one time use credential, validates that an access account has been setup correctly."
            },
            {
              "internal_name": "identity_types_password_recovery",
              "display_name": "Identity Type / Password Recovery",
              "external_name": "Password Recovery",
              "syst_description": "A one time use identifier which, along with a one time use credential, allows a user to reset their password after alternative method of authentication."
            }
          ],
          "enum_items": [
            {
              "internal_name": "identity_types_sysdef_email",
              "display_name": "Identity Type / Email",
              "external_name": "Email",
              "functional_type_name": "identity_types_email",
              "enum_default": true,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": false,
              "syst_description": "This identity type indicates the sort of user name a human user would enter into a login form to identify themselves. The user identifier will always be an email address.  This identity may only be used for interactive logins and explicitly not for in scenarios where you would use token credential types for authentication.",
              "syst_options": {}
            },
            {
              "internal_name": "identity_types_sysdef_account",
              "display_name": "Identity Type / Account",
              "external_name": "Account",
              "functional_type_name": "identity_types_account",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": false,
              "syst_description": "Account IDs are system generated IDs which can be used similar to user name, but can be given to third parties, such as the administrator of an application instance for the purpose of being granted user access to the instance, without also disclosing personal ID information such as an email address.  These IDs are typical simple and easy to provide via verbal or written communication.  This ID type is not allowed for login.",
              "syst_options": {}
            },
            {
              "internal_name": "identity_types_sysdef_api",
              "display_name": "Identity Type / API",
              "external_name": "API",
              "functional_type_name": "identity_types_api",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": false,
              "syst_description": "A system generated ID for use in identifying the user account in automated access scenarios.  This kind of ID differs from the account_id in that it is significantly larger than an account ID would be and may only be used with token credential types.",
              "syst_options": {}
            },
            {
              "internal_name": "identity_types_sysdef_validation",
              "display_name": "Identity Type / Validation",
              "external_name": "Validation",
              "functional_type_name": "identity_types_validation",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": false,
              "syst_description": "A one time use identifier which, along with a one time use credential, validates that an access account has been setup correctly.",
              "syst_options": {}
            },
            {
              "internal_name": "identity_types_sysdef_password_recovery",
              "display_name": "Identity Type / Password Recovery",
              "external_name": "Password Recovery",
              "functional_type_name": "identity_types_password_recovery",
              "enum_default": false,
              "functional_type_default": true,
              "syst_defined": true,
              "user_maintainable": false,
              "syst_description": "A one time use identifier which, along with a one time use credential, validates that an access account has been setup correctly.",
              "syst_options": {}
            }
          ]
        }
            $INIT_ENUM_IDENTITY_TYPES$::jsonb);

END;
$INIT_ENUM$;
-- File:        syst_access_accounts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst_data/syst_access_accounts/syst_access_accounts.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_access_accounts
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_access_accounts_pk PRIMARY KEY
    ,internal_name
        text
        NOT NULL
        CONSTRAINT syst_access_accounts_internal_name_udx UNIQUE
    ,external_name
        text
        NOT NULL
    ,owning_owner_id
        uuid
        CONSTRAINT syst_access_accounts_owners_fk
            REFERENCES ms_syst_data.syst_owners (id) ON DELETE CASCADE
    ,allow_global_logins
        boolean
        NOT NULL DEFAULT false
    ,access_account_state_id
        uuid
        NOT NULL
        CONSTRAINT syst_access_accounts_access_account_states_fk
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

ALTER TABLE ms_syst_data.syst_access_accounts OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_access_accounts FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_access_accounts TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_access_accounts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_access_account_states_enum_item_check
    AFTER INSERT ON ms_syst_data.syst_access_accounts
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check(
            'access_account_states', 'access_account_state_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_access_account_states_enum_item_check
    AFTER UPDATE ON ms_syst_data.syst_access_accounts
    FOR EACH ROW WHEN ( old.access_account_state_id != new.access_account_state_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_enum_item_check(
                'access_account_states', 'access_account_state_id');

COMMENT ON
    TABLE ms_syst_data.syst_access_accounts IS
$DOC$Contains the known login accounts which are used solely for the purpose of
authentication of users.  Authorization is handled on a per-instance basis
within the application.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_access_accounts.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_access_accounts.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_access_accounts.external_name IS
$DOC$Provides a user visible name for display purposes only.  This field is not
unique and may not be used as a key.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_access_accounts.owning_owner_id IS
$DOC$Associates the access account with a specific owner.  This allows for access
accounts which are identified and managed exclusively by a given owner.

When this field is NULL, the assumption is that it's an independent access
account.  An independent access account may be used, for example, by third party
accountants that need to access the instances of different owners.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_access_accounts.allow_global_logins IS
$DOC$When true, allows an access account to log into the system without having
an owner or instance specified in the login process.  This use case supports
access accounts which are independently managed, such as might be the case for
external bookkeepers.  When false, the access account is more tightly bound to a
specific owner and so only a specific owner and instances should be evaluated at
login time.

The need for this distinction arises when considering logins for access account
holders such as customers or vendors.  In these cases access to the owner's
environment should appear to be unique, but they may use the same identifier as
used for a different, but unrelated, owner.  In this case you have multiple
access accounts with possibly the same identifier; to resolve the conflict, it
is required therefore to know which owner or instance the access accounts holder
is trying to access.  In the allow global case we can just ask the account
holder but in the disallow global case we need to know it in advance.

Another way to think about global logins is in relation to user interface.  A
global login interface may present the user with a choice of instance owners and
then their instances whereas the non-global login user must go directly to the
login interface for a specific owner (be that URL or other client-side specific
identification.)$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_access_accounts.access_account_state_id IS
$DOC$The current life-cycle state of the access account.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_access_accounts.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_access_accounts.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_access_accounts.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_access_accounts.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_access_accounts.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_access_accounts.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_access_accounts.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst_data.trig_b_i_syst_identities_validate_uniqueness()
RETURNS trigger AS
$BODY$

-- File:        trig_b_i_syst_identities_check_uniqueness.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst_data/syst_identities/trig_b_i_syst_identities_check_uniqueness.eex.sql
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
    -- TODO: This trigger may be replaced by a unique index once PostgreSQL 15
    --       becomes our standard.  That version will allow the option to treat
    --       null values as a single value rather than each null distinct from
    --       all others, which matches our resolution scope definition here.
    IF
        exists( SELECT
                    TRUE
                FROM ms_syst_data.syst_access_accounts saa_this
                    LEFT JOIN ms_syst_data.syst_access_accounts saa_other
                          ON saa_this.owning_owner_id IS NOT DISTINCT FROM saa_other.owning_owner_id AND
                             saa_this.id IS DISTINCT FROM saa_other.id
                    LEFT JOIN ms_syst_data.syst_identities si_any
                          ON ( si_any.access_account_id = saa_other.id OR
                               si_any.access_account_id = saa_this.id ) AND
                             si_any.identity_type_id = new.identity_type_id
                WHERE
                      saa_this.id = new.access_account_id
                  AND si_any.account_identifier = new.account_identifier
            )
    THEN

        RAISE EXCEPTION
            USING
                MESSAGE = 'The identity already matches that of a different access account '
                          'in the same scope of identity resolution.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst_data'
                            ,p_proc_name      => 'trig_b_i_syst_identities_validate_uniqueness'
                            ,p_exception_name => 'duplicate_identity'
                            ,p_errcode        => 'PM002'
                            ,p_param_data     => jsonb_build_object(
                                 'access_account_id', new.access_account_id
                                ,'account_identifier', new.account_identifier
                            )
                            ,p_context_data   =>
                                jsonb_build_object(
                                     'tg_op',         tg_op
                                    ,'tg_when',       tg_when
                                    ,'tg_schema',     tg_table_schema
                                    ,'tg_table_name', tg_table_name)),
                ERRCODE = 'PM002',
                SCHEMA = tg_table_schema,
                TABLE = tg_table_name;

    END IF;

    RETURN NEW;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION ms_syst_data.trig_b_i_syst_identities_validate_uniqueness()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_data.trig_b_i_syst_identities_validate_uniqueness() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_data.trig_b_i_syst_identities_validate_uniqueness() TO <%= ms_owner %>;


COMMENT ON FUNCTION ms_syst_data.trig_b_i_syst_identities_validate_uniqueness() IS
$DOC$Provides a check that each ms_syst_data.syst_identities.account_identifier
value is unique for each owner's access accounts or unique amongst unowned
access accounts.$DOC$;
-- File:        syst_identities.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst_data/syst_identities/syst_identities.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_identities
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_identities_pk PRIMARY KEY
    ,access_account_id
        uuid
        NOT NULL
        CONSTRAINT syst_identities_access_accounts_fk
            REFERENCES ms_syst_data.syst_access_accounts (id) ON DELETE CASCADE
    ,identity_type_id
        uuid
        NOT NULL
        CONSTRAINT syst_identities_identity_types_fk
            REFERENCES ms_syst_data.syst_enum_items (id) ON DELETE CASCADE
    ,account_identifier
        text
        NOT NULL
    ,validated
        timestamptz
    ,validates_identity_id
        uuid
        CONSTRAINT syst_identities_validates_identities_fk
            REFERENCES ms_syst_data.syst_identities (id) ON DELETE CASCADE
        CONSTRAINT syst_identities_validates_identities_udx UNIQUE
    ,validation_requested
        timestamptz
    ,identity_expires
        timestamptz
    ,external_name
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

ALTER TABLE ms_syst_data.syst_identities OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_identities FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_identities TO <%= ms_owner %>;

CREATE TRIGGER a50_trig_b_i_syst_identities_validate_uniqueness
    BEFORE INSERT ON ms_syst_data.syst_identities
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_data.trig_b_i_syst_identities_validate_uniqueness();

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_identities
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_identity_types_enum_item_check
    AFTER INSERT ON ms_syst_data.syst_identities
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('identity_types', 'identity_type_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_identity_types_enum_item_check
    AFTER UPDATE ON ms_syst_data.syst_identities
    FOR EACH ROW WHEN ( old.identity_type_id != new.identity_type_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_enum_item_check(
                'identity_types', 'identity_type_id');

COMMENT ON
    TABLE ms_syst_data.syst_identities IS
$DOC$The identities with which access accounts are identified to the system.  The
most common example of an identity would be a user name such as an email
address.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_identities.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_identities.access_account_id IS
$DOC$The ID of the access account to be identified the identifier record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_identities.identity_type_id IS
$DOC$The kind of identifier being described by the record.  Note that this value
influences the kind of credentials that can be used to complete the
authentication process.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_identities.account_identifier IS
$DOC$The actual identifier which identifies a user or system to the system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_identities.validated IS
$DOC$The timestamp at which the identity was validated for use.  Depending on the
requirements of the identity functional type, the timestamp here may be set as
the time of the identity creation or it may set when the access account holder
actually makes a formal verification.  A null value here indicates that the
identity is not validated by the access account holder and is not able to be
used for authentication to the system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_identities.validates_identity_id IS
$DOC$Each identity requiring validation will require its own validation.  Since
validation requests are also single use identities, we need to know which
permanent identifier is being validate.  This column points to the identifier
that is being validated.  When the current identifier is not being used for
validation, this field is null.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_identities.validation_requested IS
$DOC$The timestamp on which the validation request was issued to the access account
holder.  This value will be null if the identity did not require validation.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_identities.identity_expires IS
$DOC$The timestamp at which the identity record expires.  For validation and
recovery identities this would be the time of validation/recovery request
expiration.  For perpetual identity types, this value will be NULL.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_identities.external_name IS
$DOC$An optional external identifier for use in user displays and similar scenarios.
This value is not unique and not suitable for anything more than informal record
identification by the user.  Some identity types may record a default value
automatically in this column.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_identities.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_identities.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_identities.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_identities.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_identities.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_identities.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_identities.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;

CREATE INDEX syst_identities_account_type_identifier_idx
    ON ms_syst_data.syst_identities USING btree
        ( identity_type_id, access_account_id, account_identifier );

CREATE INDEX syst_identities_access_account_idx
    ON ms_syst_data.syst_identities USING btree ( access_account_id );
CREATE OR REPLACE FUNCTION ms_syst_data.trig_a_d_syst_credentials_delete_identity()
RETURNS trigger AS
$BODY$

-- File:        trig_a_d_syst_credentials_delete_identity.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst_data/syst_credentials/trig_a_d_syst_credentials_delete_identity.eex.sql
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

BEGIN
    -- Note that currently for all credential types which expect a
    -- credential_for_identity_id value, the correct course of action here is to
    -- delete the associated identity record.  If this assumption should change,
    -- such as if we should directly associate email identities with password
    -- credentials, this logic will need to consider the credential type since
    -- emails would not be deleted in all scenarios (passwords are recoverable).

    DELETE FROM ms_syst_data.syst_identities WHERE id = old.credential_for_identity_id;

    RETURN NULL;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION ms_syst_data.trig_a_d_syst_credentials_delete_identity()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_data.trig_a_d_syst_credentials_delete_identity() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_data.trig_a_d_syst_credentials_delete_identity() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst_data.trig_a_d_syst_credentials_delete_identity() IS
$DOC$Deletes the syst_identities record associated with a newly deleted
syst_credentials record.

For those credential types that expect a relationship to syst_identities via the
syst_credentials.credential_for_identity_id column, the specific identifier and
credential data are closely related and updates to one or the other makes no
sense.  The correct process for updating such a pair is to delete both of the
existing identity and credential records and simply generate a new pair.
Deleting identity records achieves this goal via the constraint on the
credential_for_identity_id definition (ON DELETE CASCADE), but deleting a
credential has no automatic deletion feature thus this trigger.$DOC$;
-- File:        syst_credentials.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst_data/syst_credentials/syst_credentials.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_credentials
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_credentials_pk PRIMARY KEY
    ,access_account_id
        uuid
        NOT NULL
        CONSTRAINT syst_credentials_access_accounts_fk
            REFERENCES ms_syst_data.syst_access_accounts (id) ON DELETE CASCADE
    ,credential_type_id
        uuid
        NOT NULL
        CONSTRAINT syst_credentials_credential_types_fk
            REFERENCES ms_syst_data.syst_enum_items (id)
    ,credential_for_identity_id
        uuid
        CONSTRAINT syst_credentials_for_identities_fk
            REFERENCES ms_syst_data.syst_identities (id) ON DELETE CASCADE
    ,CONSTRAINT syst_credentials_udx
        UNIQUE NULLS NOT DISTINCT
            (access_account_id, credential_type_id, credential_for_identity_id)
    ,credential_data
        text
        NOT NULL
    ,last_updated
        timestamptz
        NOT NULL DEFAULT now( )
    ,force_reset
        timestamptz
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

ALTER TABLE ms_syst_data.syst_credentials OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_credentials FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_credentials TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_credentials
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

CREATE CONSTRAINT TRIGGER a50_trig_a_i_credential_types_enum_item_check
    AFTER INSERT ON ms_syst_data.syst_credentials
    FOR EACH ROW EXECUTE PROCEDURE
        ms_syst_priv.trig_a_iu_enum_item_check('credential_types', 'credential_type_id');

CREATE CONSTRAINT TRIGGER a50_trig_a_u_credential_types_enum_item_check
    AFTER UPDATE ON ms_syst_data.syst_credentials
    FOR EACH ROW WHEN ( old.credential_type_id != new.credential_type_id)
        EXECUTE PROCEDURE
            ms_syst_priv.trig_a_iu_enum_item_check(
                'credential_types', 'credential_type_id');

CREATE CONSTRAINT TRIGGER b50_trig_a_d_syst_credentials_delete_identity
    AFTER DELETE ON ms_syst_data.syst_credentials
    FOR EACH ROW WHEN ( old.credential_for_identity_id IS NOT NULL)
    EXECUTE PROCEDURE ms_syst_data.trig_a_d_syst_credentials_delete_identity();

COMMENT ON
    TABLE ms_syst_data.syst_credentials IS
$DOC$Hosts the credentials by which a user or external system will prove its identity.
Note that not all credential types are available for authentication with all
identity types.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_credentials.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_credentials.access_account_id IS
$DOC$The access account for which the credential is to be used.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_credentials.credential_type_id IS
$DOC$The kind of credential that the record represents.  Note that the behavior and
use cases of the credential may have specific processing and handling
requirements based on the functional type of the credential type.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_credentials.credential_for_identity_id IS
$DOC$When an access account identity is created for either identity validation or
access account recovery, a single use identity is created as well as a single
use credential.  In this specific case, the one time use credential and the one
time use identity are linked.  This is especially important in recovery
scenarios to ensure that only the correct recovery communication can recover the
account.  This field identifies the which identity is associated with the
credential.

For regular use identities, there are no special credential requirements that
would be needed to for a link and the value in this column should be null.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_credentials.credential_data IS
$DOC$The actual data which supports verifying the presented identity in relation to
the access account.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_credentials.last_updated IS
$DOC$For credential types where rules regarding updating may apply, such as common
passwords, this column indicates when the credential was last updated (timestamp
of last password change, for example).   This field is explicitly not for dating
trivial or administrative changes which don't actually materially change the
credential data; please consult the appropriate diagnostic fields for those use
cases.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_credentials.force_reset IS
$DOC$Indicates whether or not certain credential types, such as passwords, must be
updated.  When NOT NULL, the user must update their credential on the next
login; when NULL updating the credential is not being administratively forced.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_credentials.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_credentials.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_credentials.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_credentials.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_credentials.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_credentials.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_credentials.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
-- File:        syst_access_account_instance_assocs.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst_data/syst_access_account_instance_assocs/syst_access_account_instance_assocs.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE TABLE ms_syst_data.syst_access_account_instance_assocs
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_access_account_instance_assocs_pk PRIMARY KEY
    ,access_account_id
        uuid
        NOT NULL
        CONSTRAINT syst_access_account_instance_assocs_access_accounts_fk
            REFERENCES ms_syst_data.syst_access_accounts (id) ON DELETE CASCADE
    ,instance_id
        uuid
        NOT NULL
        CONSTRAINT syst_access_account_instance_assocs_instances_fk
            REFERENCES ms_syst_data.syst_instances (id) ON DELETE CASCADE
    ,CONSTRAINT syst_access_account_instance_assoc_a_c_i_udx
        UNIQUE ( access_account_id, instance_id )
    ,access_granted
        timestamptz
    ,invitation_issued
        timestamptz
    ,invitation_expires
        timestamptz
    ,invitation_declined
        timestamptz
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

ALTER TABLE ms_syst_data.syst_access_account_instance_assocs OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_access_account_instance_assocs FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_access_account_instance_assocs TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_access_account_instance_assocs
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE ms_syst_data.syst_access_account_instance_assocs IS
$DOC$Associates access accounts with the instances for which they are allowed to
authenticate to.  Note that being able to authenticate to an instance is not the
same as having authorized rights within the instance; authorization is handled
by the instance directly.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_access_account_instance_assocs.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_access_account_instance_assocs.access_account_id IS
$DOC$The access account which is being granted authentication rights to the given
instance.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_access_account_instance_assocs.instance_id IS
$DOC$The identity of the instance to which authentication rights is being granted.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_access_account_instance_assocs.access_granted IS
$DOC$The timestamp at which access to the instance was granted and active.  If
the access did not require the access invitation process, this value will
typically reflect the creation timestamp of the record.  If the invitation was
required, it will reflect the time when the access account holder actually
accepted the invitation to access the instance.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_access_account_instance_assocs.invitation_issued IS
$DOC$When inviting unowned, independent access accounts such as might be used by an
external bookkeeper, the grant of access by the instance owner is
not immediately effective but must also be approved by the access account holder
being granted access.  The timestamp in this column indicates when the
invitation to connect to the instance was issued.

If the value in this column is null, the assumption is that no invitation was
required to grant the access to the access account.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_access_account_instance_assocs.invitation_expires IS
$DOC$The timestamp at which the invitation to access a given instance expires.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_access_account_instance_assocs.invitation_declined IS
$DOC$The timestamp at which the access account holder explicitly declined the
invitation to access the given instance.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_access_account_instance_assocs.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_access_account_instance_assocs.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_access_account_instance_assocs.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_access_account_instance_assocs.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_access_account_instance_assocs.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_access_account_instance_assocs.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_access_account_instance_assocs.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
-- File:        syst_disallowed_hosts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst_data/syst_disallowed_hosts/syst_disallowed_hosts.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE ms_syst_data.syst_disallowed_hosts
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_disallowed_hosts_pk PRIMARY KEY
    ,host_address
        inet
        NOT NULL
        CONSTRAINT syst_disallowed_hosts_host_address_udx UNIQUE
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

ALTER TABLE ms_syst_data.syst_disallowed_hosts OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_disallowed_hosts FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_disallowed_hosts TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_disallowed_hosts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE ms_syst_data.syst_disallowed_hosts IS
$DOC$A simple listing of "banned" IP address which are not allowed to authenticate
their users to the system.  This registry differs from the syst_*_network_rules
tables in that IP addresses here are registered as the result of automatic
system heuristics whereas the network rules are direct expressions of system
administrator intent.  The timing between these two mechanisms is also different
in that records in this table are evaluated prior to an authentication attempt
and most network rules are processed in the authentication attempt sequence.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_disallowed_hosts.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_disallowed_hosts.host_address IS
$DOC$The IP address of the host disallowed from attempting to authenticate Access
Accounts.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_disallowed_hosts.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_disallowed_hosts.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_disallowed_hosts.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_disallowed_hosts.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_disallowed_hosts.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_disallowed_hosts.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_disallowed_hosts.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst_data.trig_a_iu_syst_global_network_rule_ordering()
RETURNS trigger AS
$BODY$

-- File:        trig_a_iu_syst_global_network_rule_ordering.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst_data/syst_global_network_rules/trig_a_iu_syst_global_network_rule_ordering.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

BEGIN

    UPDATE ms_syst_data.syst_global_network_rules
    SET ordering = ordering + 1
    WHERE ordering = new.ordering AND id != new.id;

    RETURN null;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION ms_syst_data.trig_a_iu_syst_global_network_rule_ordering()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_data.trig_a_iu_syst_global_network_rule_ordering() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_data.trig_a_iu_syst_global_network_rule_ordering() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst_data.trig_a_iu_syst_global_network_rule_ordering() IS
$DOC$Ensures that the ordering of network rules is maintained and that ordering
values are not duplicated.$DOC$;
-- File:        syst_global_network_rules.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst_data/syst_global_network_rules/syst_global_network_rules.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE ms_syst_data.syst_global_network_rules
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_global_network_rules_pk PRIMARY KEY
    ,ordering
        integer
        NOT NULL
        CONSTRAINT syst_global_network_rules_ordering_udx UNIQUE DEFERRABLE INITIALLY DEFERRED
    ,functional_type
        text
        NOT NULL
        CONSTRAINT syst_global_network_rules_functional_type_chk
            CHECK ( functional_type IN ( 'allow', 'deny' ) )
    ,ip_host_or_network
        inet
    ,ip_host_range_lower
        inet
    ,ip_host_range_upper
        inet
    ,CONSTRAINT syst_global_network_rules_host_or_range_chk
        CHECK (
            ( ip_host_or_network IS NOT NULL AND
                ip_host_range_lower IS NULL AND
                ip_host_range_upper IS NULL) OR
            ( ip_host_or_network IS NULL AND
                ip_host_range_lower IS NOT NULL AND
                ip_host_range_upper IS NOT NULL)
            )
    ,CONSTRAINT syst_global_network_rules_ip_range_family_chk
        CHECK (
            family(ip_host_range_lower) = family(ip_host_range_upper)
            )
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

ALTER TABLE ms_syst_data.syst_global_network_rules OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_global_network_rules FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_global_network_rules TO <%= ms_owner %>;

CREATE TRIGGER b50_trig_a_iu_syst_global_network_rule_ordering
    AFTER INSERT OR UPDATE ON ms_syst_data.syst_global_network_rules
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_data.trig_a_iu_syst_global_network_rule_ordering();

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_global_network_rules
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE ms_syst_data.syst_global_network_rules IS
$DOC$Defines firewall-like rules that are global in scope indicating which IP
addresses are allowed to attempt authentication and which are not.  This also
includes the concept of global defaults applied to new Owner IP address rules.
These rules are applied in their defined ordering prior to all other rule sets.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_global_network_rules.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_global_network_rules.ordering IS
$DOC$Defines the order in which IP rules are applied.  Lower values are applied
prior to higher values.

When a new record is inserted with an existing ordering value, it is treated as
"insert before" the existing record and the existing record's ordering is
increased by one; this reordering process is recursive until there are no more
ordering value conflicts.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_global_network_rules.functional_type IS
$DOC$Indicates how the system will interpret the IP address rule.  The valid
functional types are:

    * `allow` - the rule is explicitly allowing an IP address, network, or
    range of IP addresses to continue in the authentication process.

    * `deny` - the rule is explicitly rejecting an IP address, network, or
    range of IP addresses from the authentication process.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_global_network_rules.ip_host_or_network IS
$DOC$An IPv4 or IPv6 IP address or network block expressed using standard CIDR
notation.

If this value is given you should not provide an IP host address range in the
ip_host_range_lower/ip_host_range_upper columns.  Providing range column values
when this column is not null will result in a consistency check failure.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_global_network_rules.ip_host_range_lower IS
$DOC$An IPv4 or IPv6 IP host address which is the lower bound (inclusive) of a
range of IP addresses.

If the value in this column is not null a value must also be provided for the
ip_host_range_upper column.  Both ip_host_range_lower and ip_host_range_upper
must be of the same IP family (IPv4 or IPv6).$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_global_network_rules.ip_host_range_upper IS
$DOC$An IPv4 or IPv6 IP host address which is the upper bound (inclusive) of a
range of IP addresses.

If the value in this column is not null a value must also be provided for the
ip_host_range_lower column.  Both ip_host_range_lower and ip_host_range_upper
must be of the same IP family (IPv4 or IPv6).$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_global_network_rules.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_global_network_rules.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_global_network_rules.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_global_network_rules.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_global_network_rules.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_global_network_rules.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_global_network_rules.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst_data.trig_a_iu_syst_owner_network_rule_ordering()
RETURNS trigger AS
$BODY$

-- File:        trig_a_iu_syst_owner_network_rule_ordering.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst_data/syst_owner_network_rules/trig_a_iu_syst_owner_network_rule_ordering.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

BEGIN

    UPDATE ms_syst_data.syst_owner_network_rules
    SET ordering = ordering + 1
    WHERE owner_id = new.owner_id AND ordering = new.ordering AND id != new.id;

    RETURN null;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION ms_syst_data.trig_a_iu_syst_owner_network_rule_ordering()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_data.trig_a_iu_syst_owner_network_rule_ordering() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_data.trig_a_iu_syst_owner_network_rule_ordering() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst_data.trig_a_iu_syst_owner_network_rule_ordering() IS
$DOC$Ensures that the ordering of network rules is maintained and that ordering
values are not duplicated.$DOC$;
-- File:        syst_owner_network_rules.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst_data/syst_owner_network_rules/syst_owner_network_rules.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE ms_syst_data.syst_owner_network_rules
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_owner_network_rules_pk PRIMARY KEY
    ,owner_id
        uuid
        NOT NULL
        CONSTRAINT syst_owner_network_rules_owner_fk
            REFERENCES ms_syst_data.syst_owners ( id )
            ON DELETE CASCADE
    ,ordering
        integer
        NOT NULL
    ,CONSTRAINT syst_owner_network_rules_owner_ordering_udx
        UNIQUE ( owner_id, ordering ) DEFERRABLE INITIALLY DEFERRED
    ,functional_type
        text
        NOT NULL
        CONSTRAINT syst_owner_network_rules_functional_type_chk
            CHECK ( functional_type IN ( 'allow', 'deny' ) )
    ,ip_host_or_network
        inet
    ,ip_host_range_lower
        inet
    ,ip_host_range_upper
        inet
    ,CONSTRAINT syst_owner_network_rules_host_or_range_chk
        CHECK (
            ( ip_host_or_network IS NOT NULL AND
                ip_host_range_lower IS NULL AND
                ip_host_range_upper IS NULL) OR
            ( ip_host_or_network IS NULL AND
                ip_host_range_lower IS NOT NULL AND
                ip_host_range_upper IS NOT NULL)
            )
    ,CONSTRAINT syst_owner_network_rules_ip_range_family_chk
        CHECK (
            family(ip_host_range_lower) = family(ip_host_range_upper)
            )
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

ALTER TABLE ms_syst_data.syst_owner_network_rules OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_owner_network_rules FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_owner_network_rules TO <%= ms_owner %>;

CREATE TRIGGER b50_trig_a_iu_syst_owner_network_rule_ordering
    AFTER INSERT OR UPDATE ON ms_syst_data.syst_owner_network_rules
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_data.trig_a_iu_syst_owner_network_rule_ordering();

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_owner_network_rules
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE ms_syst_data.syst_owner_network_rules IS
$DOC$Defines firewall-like rules, scoped to specific owners, indicating which IP
addresses are allowed to attempt authentication and which are not.  These rules
are applied in their defined order after all global_network_rules and before all
instance_network_rules.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_network_rules.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN  ms_syst_data.syst_owner_network_rules.owner_id IS
$DOC$The database identifier of the Owner record for whom the Network Rule is
being defined.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_network_rules.ordering IS
$DOC$Defines the order in which IP rules are applied.  Lower values are applied
prior to higher values.

All records are ordered using unique ordering values within each owner value.
When a new Owner Network Rule is inserted with the ordering value of an
existing Onwer Network Rule record for the same Owner, the system will assume
the new record should be "inserted before" the existing record.  Therefore the
existing record will be reordered behind the new record by incremeneting the
existing record's ordering value by one.  This reordering process happens
recursively until there are no ordering value conflicts for any of an Owner's
Network Rule records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_network_rules.functional_type IS
$DOC$Indicates how the system will interpret the IP address rule.  The valid
functional types are:

    * `allow` - the rule is explicitly allowing an IP address, network, or
    range of IP addresses to continue in the authentication process.

    * `deny` - the rule is explicitly rejecting an IP address, network, or
    range of IP addresses from the authentication process.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_network_rules.ip_host_or_network IS
$DOC$An IPv4 or IPv6 IP address or network block expressed using standard CIDR
notation.

If this value is given you should not provide an IP host address range in the
ip_host_range_lower/ip_host_range_upper columns.  Providing range column values
when this column is not null will result in a consistency check failure.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_network_rules.ip_host_range_lower IS
$DOC$An IPv4 or IPv6 IP host address which is the lower bound (inclusive) of a
range of IP addresses.

If the value in this column is not null a value must also be provided for the
ip_host_range_upper column.  Both ip_host_range_lower and ip_host_range_upper
must be of the same IP family (IPv4 or IPv6).$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_network_rules.ip_host_range_upper IS
$DOC$An IPv4 or IPv6 IP host address which is the upper bound (inclusive) of a
range of IP addresses.

If the value in this column is not null a value must also be provided for the
ip_host_range_lower column.  Both ip_host_range_lower and ip_host_range_upper
must be of the same IP family (IPv4 or IPv6).$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_network_rules.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_network_rules.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_network_rules.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_network_rules.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_network_rules.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_network_rules.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_network_rules.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst_data.trig_a_iu_syst_instance_network_rule_ordering()
RETURNS trigger AS
$BODY$

-- File:        trig_a_iu_syst_instance_network_rule_ordering.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst_data/syst_instance_network_rules/trig_a_iu_syst_instance_network_rule_ordering.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

BEGIN

    UPDATE ms_syst_data.syst_instance_network_rules
    SET ordering = ordering + 1
    WHERE instance_id = new.instance_id AND ordering = new.ordering AND id != new.id;

    RETURN null;

END;
$BODY$
LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION ms_syst_data.trig_a_iu_syst_instance_network_rule_ordering()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst_data.trig_a_iu_syst_instance_network_rule_ordering() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst_data.trig_a_iu_syst_instance_network_rule_ordering() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst_data.trig_a_iu_syst_instance_network_rule_ordering() IS
$DOC$Ensures that the ordering of network rules is maintained and that ordering
values are not duplicated.$DOC$;
-- File:        syst_instance_network_rules.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst_data/syst_instance_network_rules/syst_instance_network_rules.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE ms_syst_data.syst_instance_network_rules
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_instance_network_rules_pk PRIMARY KEY
    ,instance_id
        uuid
        NOT NULL
        CONSTRAINT syst_instance_network_rules_instance_fk
            REFERENCES ms_syst_data.syst_instances ( id )
            ON DELETE CASCADE
    ,ordering
        integer
        NOT NULL
    ,CONSTRAINT syst_instance_network_rules_instance_ordering_udx
        UNIQUE ( instance_id, ordering ) DEFERRABLE INITIALLY DEFERRED
    ,functional_type
        text
        NOT NULL
        CONSTRAINT syst_instance_network_rules_functional_type_chk
            CHECK ( functional_type IN ( 'allow', 'deny' ) )
    ,ip_host_or_network
        inet
    ,ip_host_range_lower
        inet
    ,ip_host_range_upper
        inet
    ,CONSTRAINT syst_instance_network_rules_host_or_range_chk
        CHECK (
            ( ip_host_or_network IS NOT NULL AND
                ip_host_range_lower IS NULL AND
                ip_host_range_upper IS NULL) OR
            ( ip_host_or_network IS NULL AND
                ip_host_range_lower IS NOT NULL AND
                ip_host_range_upper IS NOT NULL)
            )
    ,CONSTRAINT syst_instance_network_rules_ip_range_family_chk
        CHECK (
            family(ip_host_range_lower) = family(ip_host_range_upper)
            )
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

ALTER TABLE ms_syst_data.syst_instance_network_rules OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_instance_network_rules FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_instance_network_rules TO <%= ms_owner %>;

CREATE TRIGGER b50_trig_a_iu_syst_instance_network_rule_ordering
    AFTER INSERT OR UPDATE ON ms_syst_data.syst_instance_network_rules
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_data.trig_a_iu_syst_instance_network_rule_ordering();

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_instance_network_rules
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE ms_syst_data.syst_instance_network_rules IS
$DOC$Defines firewall-like rules, scoped to specific instances, indicating which IP
addresses are allowed to attempt authentication and which are not.  These rules
are applied in their defined order after all global_network_rules and
owner_network_rules.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_network_rules.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN  ms_syst_data.syst_instance_network_rules.instance_id IS
$DOC$The database identifier of the Instance record for whom the Network Rule is
being defined.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_network_rules.ordering IS
$DOC$Defines the order in which IP rules are applied.  Lower values are applied
prior to higher values.

All records are ordered using unique ordering values within each Owner value.
When a new Owner Network Rule is inserted with the ordering value of an
existing Owner Network Rule record for the same Owner, the system will assume
the new record should be "inserted before" the existing record.  Therefore the
existing record will be reordered behind the new record by incremeneting the
existing record's ordering value by one.  This reordering process happens
recursively until there are no ordering value conflicts for any of an Owner's
Network Rule records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_network_rules.functional_type IS
$DOC$Indicates how the system will interpret the IP address rule.  The valid
functional types are:

    * `allow` - the rule is explicitly allowing an IP address, network, or
    range of IP addresses to continue in the authentication process.

    * `deny` - the rule is explicitly rejecting an IP address, network, or
    range of IP addresses from the authentication process.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_network_rules.ip_host_or_network IS
$DOC$An IPv4 or IPv6 IP address or network block expressed using standard CIDR
notation.

If this value is given you should not provide an IP host address range in the
ip_host_range_lower/ip_host_range_upper columns.  Providing range column values
when this column is not null will result in a consistency check failure.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_network_rules.ip_host_range_lower IS
$DOC$An IPv4 or IPv6 IP host address which is the lower bound (inclusive) of a
range of IP addresses.

If the value in this column is not null a value must also be provided for the
ip_host_range_upper column.  Both ip_host_range_lower and ip_host_range_upper
must be of the same IP family (IPv4 or IPv6).$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_network_rules.ip_host_range_upper IS
$DOC$An IPv4 or IPv6 IP host address which is the upper bound (inclusive) of a
range of IP addresses.

If the value in this column is not null a value must also be provided for the
ip_host_range_lower column.  Both ip_host_range_lower and ip_host_range_upper
must be of the same IP family (IPv4 or IPv6).$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_network_rules.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_network_rules.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_network_rules.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_network_rules.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_network_rules.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_network_rules.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_instance_network_rules.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
CREATE OR REPLACE
    FUNCTION ms_syst_priv.get_applied_network_rule(   p_host_addr         inet
                                                       , p_instance_id       uuid
                                                       , p_instance_owner_id uuid )
    RETURNS table
            (
                precedence          text,
                network_rule_id     uuid,
                functional_type     text,
                ip_host_or_network  inet,
                ip_host_range_lower inet,
                ip_host_range_upper inet
            )
AS
$BODY$

-- File:        get_applied_network_rule.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst_priv/functions/get_applied_network_rule.eex.sql
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
        rule.precedence
      , rule.network_rule_id
      , rule.functional_type
      , rule.ip_host_or_network
      , rule.ip_host_range_lower
      , rule.ip_host_range_upper
    FROM ( SELECT
               1            AS precedence_sort
             , 'disallowed' AS precedence
             , 1            AS ordering
             , id           AS network_rule_id
             , 'deny'       AS functional_type
             , host_address AS ip_host_or_network
             , NULL         AS ip_host_range_lower
             , NULL         AS ip_host_range_upper
           FROM ms_syst_data.syst_disallowed_hosts
           WHERE host_address = p_host_addr
           UNION
           SELECT
               2        AS precedence_sort
             , 'global' AS precedence
             , ordering
             , id       AS network_rule_id
             , functional_type
             , ip_host_or_network
             , ip_host_range_lower
             , ip_host_range_upper
           FROM ms_syst_data.syst_global_network_rules
           WHERE
               ( ip_host_or_network >>= p_host_addr OR
                 p_host_addr BETWEEN ip_host_range_lower AND ip_host_range_upper )
           UNION
           SELECT
               3          AS precedence_sort
             , 'instance' AS precedence
             , ordering
             , id         AS network_rule_id
             , functional_type
             , ip_host_or_network
             , ip_host_range_lower
             , ip_host_range_upper
           FROM ms_syst_data.syst_instance_network_rules
           WHERE
                 instance_id = p_instance_id
             AND ( ip_host_or_network >>= p_host_addr OR
                   p_host_addr BETWEEN ip_host_range_lower AND ip_host_range_upper )
           UNION
           SELECT
               4                AS precedence_sort
             , 'instance_owner' AS precedence
             , ordering
             , id               AS network_rule_id
             , functional_type
             , ip_host_or_network
             , ip_host_range_lower
             , ip_host_range_upper
           FROM ms_syst_data.syst_owner_network_rules
           WHERE
                   owner_id = coalesce( p_instance_owner_id, ( SELECT owner_id
                                                               FROM ms_syst_data.syst_instances
                                                               WHERE id = p_instance_id ) )
             AND   ( ip_host_or_network >>= p_host_addr OR
                     p_host_addr BETWEEN ip_host_range_lower AND ip_host_range_upper )
           UNION
           SELECT
               5                 AS precedence_sort
             , 'implied'         AS precedence
             , 1                 AS ordering
             , NULL              AS network_rule_id
             , 'allow'           AS functional_type
             , '0.0.0.0/0'::inet AS ip_host_or_network
             , NULL              AS ip_host_range_lower
             , NULL              AS ip_host_range_upper
           ORDER BY precedence_sort, ordering
           LIMIT 1 ) rule;

$BODY$
LANGUAGE sql STABLE;

ALTER FUNCTION
    ms_syst_priv.get_applied_network_rule(
          p_host_addr         inet
        , p_instance_id       uuid
        , p_instance_owner_id uuid )
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION
    ms_syst_priv.get_applied_network_rule(
          p_host_addr         inet
        , p_instance_id       uuid
        , p_instance_owner_id uuid )
    FROM PUBLIC;

GRANT EXECUTE ON FUNCTION
    ms_syst_priv.get_applied_network_rule(
          p_host_addr         inet
        , p_instance_id       uuid
        , p_instance_owner_id uuid )
    TO <%= ms_owner %>;

COMMENT ON FUNCTION
    ms_syst_priv.get_applied_network_rule(
          p_host_addr         inet
        , p_instance_id       uuid
        , p_instance_owner_id uuid ) IS
$DOC$Applies all of the applicable network rules for a host and returns the governing
record for the identified host.

The returned rule is chosen by identifying which rules apply to the host based
on the provided Instance related parameters and then limiting the return to the
rule with the highest precedence.  Currently the precedence is defined as:

    1 - Disallowed Hosts: Globally disallowed or "banned" hosts are always
        checked first and no later rule can override the denial.  Only removing
        the host from the syst_disallowed_hosts table can reverse this denial.

    2 - Global Rules: These are rules applied to all Instances without
        exception.

    3 - Instance Rules: Rules defined by Instance Owners and are the most
        granular rule level available (p_instance_id).

    4 - Instance Owner Rules: Applied to all Instances owned by the identified
        Owner (p_instance_owner_id).

    5 - Global Implied Default Rule: When no explicitly defined network has been
        found for a host this rule will apply implicitly.  The current rule
        grants access from any host.

Finally note that this function returns the best matching rule for the provided
parameters.  This means that when p_host_addr is provided but neither of
p_instance_id or p_instance_owner_id are provided, the host can only be
evaluated against the Disallowed Hosts and the Global Network Rules which isn't
sufficient for a complete validation of a host's access to an Instance; such
incomplete checks can be useful to avoid more expensive authentication processes
later if the host is just going to be denied access due to global network rules.
Providing only p_instance_owner_id will include the Global and Owner defined
rules, but not the Instance specific rules.  If p_instance_id is provided that
is sufficient that is sufficient for testing all the applicable rules since the
Instance Owner ID can be derived using just p_instance_id parameter.$DOC$;
-- File:        syst_global_password_rules.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst_data/syst_global_password_rules/syst_global_password_rules.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE ms_syst_data.syst_global_password_rules
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_global_password_rules_pk PRIMARY KEY
    ,password_length
        int4range
        NOT NULL DEFAULT int4range(8, 64, '[]')
    ,max_age
        interval
        NOT NULL DEFAULT '0 days'::interval
    ,require_upper_case
        integer
        NOT NULL DEFAULT 0
    ,require_lower_case
        integer
        NOT NULL DEFAULT 0
    ,require_numbers
        integer
        NOT NULL DEFAULT 0
    ,require_symbols
        integer
        NOT NULL DEFAULT 0
    ,disallow_recently_used
        integer
        NOT NULL DEFAULT 0
    ,disallow_compromised
        boolean
        NOT NULL DEFAULT TRUE
    ,require_mfa
        boolean
        NOT NULL DEFAULT TRUE
    ,allowed_mfa_types
        text[]
        NOT NULL DEFAULT ARRAY[]::text[]
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

ALTER TABLE ms_syst_data.syst_global_password_rules OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_global_password_rules FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_global_password_rules TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_global_password_rules
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE ms_syst_data.syst_global_password_rules IS
$DOC$Establishes a minimum standard for password credential complexity globally.
Individual Owners may define more restrictive complexity requirements for their
own accounts and instances, but may not weaken those defined globally.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_global_password_rules.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_global_password_rules.password_length IS
$DOC$An integer range of acceptable password lengths with the lower bound
representing the minimum length and the upper bound representing the maximum
password length.   Length is determined on a per character basis, not a per
byte basis.

A zero or negative value on either bound indicates that the bound check is
disabled.  Note that disabling a bound may still result in a bounds check using
the application defined default for the bound.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_global_password_rules.max_age IS
$DOC$An interval indicating the maximum allowed age of a password.  Any password
older than this interval will typically result in the user being forced to
update their password prior to being allowed access to other functionality. The
specific user workflow will depend on the implementation details of application.

An interval of 0 time disables the check and passwords may be of any age.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_global_password_rules.require_upper_case IS
$DOC$Establishes the minimum number of upper case characters that are required to be
present in the password.  Setting this value to 0 disables the requirement for
upper case characters.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_global_password_rules.require_lower_case IS
$DOC$Establishes the minimum number of lower case characters that are required to be
present in the password.  Setting this value to 0 disables the requirement for
lower case characters.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_global_password_rules.require_numbers IS
$DOC$Establishes the minimum number of numeric characters that are required to be
present in the password.  Setting this value to 0 disables the requirement for
numeric characters.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_global_password_rules.require_symbols IS
$DOC$Establishes the minimum number of non-alphanumeric characters that are required
to be present in the password.  Setting this value to 0 disables the requirement
for non-alphanumeric characters.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_global_password_rules.disallow_recently_used IS
$DOC$When passwords are changed, this value determines how many prior passwords
should be checked in order to prevent password re-use.  Setting this value to
zero or a negative number will disable the recently used password check.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_global_password_rules.disallow_compromised IS
$DOC$When true new passwords submitted through the change password process will be
checked against a list of common passwords and passwords known to have been
compromised and disallow their use as password credentials in the system.

When false submitted passwords are not checked as being common or against known
compromised passwords; such passwords would therefore be usable in the system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_global_password_rules.require_mfa IS
$DOC$When true, an approved multi-factor authentication method must be used in
addition to the password credential.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_global_password_rules.allowed_mfa_types IS
$DOC$A array of the approved multi-factor authentication methods.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_global_password_rules.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_global_password_rules.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_global_password_rules.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_global_password_rules.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_global_password_rules.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_global_password_rules.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_global_password_rules.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
-- File:        syst_owner_password_rules.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst_data/syst_owner_password_rules/syst_owner_password_rules.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE ms_syst_data.syst_owner_password_rules
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_owner_password_rules_pk PRIMARY KEY
    ,owner_id
        uuid
        NOT NULL
        CONSTRAINT syst_owner_password_rules_owner_fk
            REFERENCES ms_syst_data.syst_owners ( id )
            ON DELETE CASCADE
        CONSTRAINT syst_owner_password_rules_owner_udx UNIQUE
    ,password_length
        int4range
        NOT NULL DEFAULT int4range(8, 64, '[]')
    ,max_age
        interval
        NOT NULL DEFAULT '0 days'::interval
    ,require_upper_case
        integer
        NOT NULL DEFAULT 0
    ,require_lower_case
        integer
        NOT NULL DEFAULT 0
    ,require_numbers
        integer
        NOT NULL DEFAULT 0
    ,require_symbols
        integer
        NOT NULL DEFAULT 0
    ,disallow_recently_used
        integer
        NOT NULL DEFAULT 0
    ,disallow_compromised
        boolean
        NOT NULL DEFAULT TRUE
    ,require_mfa
        boolean
        NOT NULL DEFAULT TRUE
    ,allowed_mfa_types
        text[]
        NOT NULL DEFAULT ARRAY[]::text[]
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

ALTER TABLE ms_syst_data.syst_owner_password_rules OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_owner_password_rules FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_owner_password_rules TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_owner_password_rules
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE ms_syst_data.syst_owner_password_rules IS
$DOC$Defines the password credential complexity standard for a given Owner.  While
Owners may define stricter standards than the global password credential
complexity standard, looser standards than the global will not have any effect
and the global standard will be used instead.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_password_rules.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_password_rules.owner_id IS
$DOC$Defined the relationship with a specific Owner for whom the password rule the
specific rule is being defined.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_password_rules.password_length IS
$DOC$An integer range of acceptable password lengths with the lower bound
representing the minimum length and the upper bound representing the maximum
password length.   Length is determined on a per character basis, not a per
byte basis.

A zero or negative value on either bound indicates that the bound check is
disabled.  Note that disabling a bound may still result in a bounds check using
the application defined default for the bound.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_password_rules.max_age IS
$DOC$An interval indicating the maximum allowed age of a password.  Any password
older than this interval will typically result in the user being forced to
update their password prior to being allowed access to other functionality. The
specific user workflow will depend on the implementation details of application.

An interval of 0 time disables the check and passwords may be of any age.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_password_rules.require_upper_case IS
$DOC$Establishes the minimum number of upper case characters that are required to be
present in the password.  Setting this value to 0 disables the requirement for
upper case characters.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_password_rules.require_lower_case IS
$DOC$Establishes the minimum number of lower case characters that are required to be
present in the password.  Setting this value to 0 disables the requirement for
lower case characters.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_password_rules.require_numbers IS
$DOC$Establishes the minimum number of numeric characters that are required to be
present in the password.  Setting this value to 0 disables the requirement for
numeric characters.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_password_rules.require_symbols IS
$DOC$Establishes the minimum number of non-alphanumeric characters that are required
to be present in the password.  Setting this value to 0 disables the requirement
for non-alphanumeric characters.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_password_rules.disallow_recently_used IS
$DOC$When passwords are changed, this value determines how many prior passwords
should be checked in order to prevent password re-use.  Setting this value to
zero or a negative number will disable the recently used password check.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_password_rules.disallow_compromised IS
$DOC$When true new passwords submitted through the change password process will be
checked against a list of common passwords and passwords known to have been
compromised and disallow their use as password credentials in the system.

When false submitted passwords are not checked as being common or against known
compromised passwords; such passwords would therefore be usable in the system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_password_rules.require_mfa IS
$DOC$When true, an approved multi-factor authentication method must be used in
addition to the password credential.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_password_rules.allowed_mfa_types IS
$DOC$A array of the approved multi-factor authentication methods.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_password_rules.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_password_rules.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_password_rules.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_password_rules.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_password_rules.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_password_rules.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_owner_password_rules.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;
-- File:        syst_disallowed_passwords.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst_data/syst_disallowed_passwords/syst_disallowed_passwords.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems
CREATE TABLE ms_syst_data.syst_disallowed_passwords
(
     password_hash bytea PRIMARY KEY
);

ALTER TABLE ms_syst_data.syst_disallowed_passwords OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_disallowed_passwords FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_disallowed_passwords TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_disallowed_passwords
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE ms_syst_data.syst_disallowed_passwords IS
$DOC$A list of hashed passwords which are disallowed for use in the system when the
password rule to disallow common/known compromised passwords is enabled.
Currently the expectation is that common passwords will be stored as sha1
hashes.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_disallowed_passwords.password_hash IS
$DOC$The SHA1 hash of the disallowed password.  The reason for using SHA1 here is
that it is compatible with the "Have I Been Pwned" data and API products.  We
also get some reasonable obscuring of possibly private data.$DOC$;
-- File:        syst_password_history.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst_data/syst_password_history/syst_password_history.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE TABLE ms_syst_data.syst_password_history
(
     id
        uuid
        NOT NULL DEFAULT uuid_generate_v1( )
        CONSTRAINT syst_password_history_pk PRIMARY KEY
    ,access_account_id
        uuid
        NOT NULL
        CONSTRAINT syst_password_history_access_account_fk
            REFERENCES ms_syst_data.syst_access_accounts ( id )
            ON DELETE CASCADE
    ,credential_data
        text
        NOT NULL
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

ALTER TABLE ms_syst_data.syst_password_history OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst_data.syst_password_history FROM public;
GRANT ALL ON TABLE ms_syst_data.syst_password_history TO <%= ms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON ms_syst_data.syst_password_history
    FOR EACH ROW EXECUTE PROCEDURE ms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE ms_syst_data.syst_password_history IS
$DOC$Keeps the history of access account prior passwords for enforcing the reuse
password rule.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_password_history.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_password_history.access_account_id IS
$DOC$The Access Account to which the password history record belongs.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_password_history.credential_data IS
$DOC$The previously hashed password recorded for reuse comparisons.  This is the same
format as the existing active password credential.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_password_history.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_password_history.diag_role_created IS
$DOC$The database role which created the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_password_history.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_password_history.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_password_history.diag_role_modified IS
$DOC$The database role which modified the record.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_password_history.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.$DOC$;

COMMENT ON
    COLUMN ms_syst_data.syst_password_history.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.$DOC$;

CREATE INDEX syst_password_history_access_account_idx ON ms_syst_data.syst_password_history ( access_account_id );
-- File:        initialize_syst_global_password_rules.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/seed_data/initialize_syst_global_password_rules.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

-- Currently, there will only be one record possible in the
-- syst_global_password_rules table.  This record is expected to exist and to be
-- updated with current rule set.
--
-- The defaults here are based on the NIST Special Publication 800-63B and
-- are expected to be compatible with the "Authenticator Assurance Level 1"
-- standard it defines. (https://pages.nist.gov/800-63-3/sp800-63b.html)

INSERT INTO ms_syst_data.syst_global_password_rules
    ( password_length
    , max_age
    , require_upper_case
    , require_lower_case
    , require_numbers
    , require_symbols
    , disallow_recently_used
    , disallow_compromised
    , require_mfa
    , allowed_mfa_types )
VALUES
    ( int4range( 8, 128, '[]' )
    , interval '0 days'
    , 0
    , 0
    , 0
    , 0
    , 0
    , TRUE
    , FALSE
    , ARRAY['credential_types_secondary_totp']::text[] );
CREATE OR REPLACE FUNCTION ms_syst.trig_i_i_syst_access_accounts()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_access_accounts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_access_accounts/trig_i_i_syst_access_accounts.eex.sql
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

    INSERT INTO ms_syst_data.syst_access_accounts
        ( internal_name
        , external_name
        , owning_owner_id
        , allow_global_logins
        , access_account_state_id)
    VALUES
        ( new.internal_name
        , new.external_name
        , new.owning_owner_id
        , new.allow_global_logins
        , new.access_account_state_id)
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_i_syst_access_accounts()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_access_accounts() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_access_accounts() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_i_syst_access_accounts() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_access_accounts API View for INSERT operations.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_u_syst_access_accounts()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_access_accounts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_access_accounts/trig_i_u_syst_access_accounts.eex.sql
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
        new.owning_owner_id IS DISTINCT FROM old.owning_owner_id
    THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'The requested data update included changes to fields disallowed ' ||
                          'by the business rules of the API View.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst'
                            ,p_proc_name      => 'trig_i_u_syst_access_accounts'
                            ,p_exception_name => 'invalid_api_view_call'
                            ,p_errcode        => 'PM008'
                            ,p_param_data     => jsonb_build_object('new', new, 'old', old)
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

    UPDATE ms_syst_data.syst_access_accounts
    SET
        internal_name           = new.internal_name
      , external_name           = new.external_name
      , allow_global_logins     = new.allow_global_logins
      , access_account_state_id = new.access_account_state_id
    WHERE id = new.id
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_u_syst_access_accounts()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_access_accounts() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_access_accounts() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_u_syst_access_accounts() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_access_accounts API View for UPDATE operations.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_d_syst_access_accounts()
RETURNS trigger AS
$BODY$

-- File:        trig_i_d_syst_access_accounts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_access_accounts/trig_i_d_syst_access_accounts.eex.sql
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

    DELETE FROM ms_syst_data.syst_access_accounts WHERE id = old.id RETURNING * INTO old;

    RETURN old;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_d_syst_access_accounts()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_access_accounts() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_access_accounts() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_d_syst_access_accounts() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_access_accounts API View for DELETE operations.$DOC$;
-- File:        syst_access_accounts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_access_accounts/syst_access_accounts.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE VIEW ms_syst.syst_access_accounts AS
    SELECT
          id
        , internal_name
        , external_name
        , owning_owner_id
        , allow_global_logins
        , access_account_state_id
        , diag_timestamp_created
        , diag_role_created
        , diag_timestamp_modified
        , diag_wallclock_modified
        , diag_role_modified
        , diag_row_version
        , diag_update_count
    FROM ms_syst_data.syst_access_accounts;

ALTER VIEW ms_syst.syst_access_accounts OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_access_accounts FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_access_accounts
    INSTEAD OF INSERT ON ms_syst.syst_access_accounts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_access_accounts();

CREATE TRIGGER a50_trig_i_u_syst_access_accounts
    INSTEAD OF UPDATE ON ms_syst.syst_access_accounts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_access_accounts();

CREATE TRIGGER a50_trig_i_d_syst_access_accounts
    INSTEAD OF DELETE ON ms_syst.syst_access_accounts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_access_accounts();

COMMENT ON
    VIEW ms_syst.syst_access_accounts IS
$DOC$Contains the known login accounts which are used solely for the purpose of
authentication of users.  Authorization is handled on a per-instance basis
within the application.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_accounts.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.

This value may not be updated via this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_accounts.internal_name IS
$DOC$A candidate key useful for programmatic references to individual records.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_accounts.external_name IS
$DOC$Provides a user visible name for display purposes only.  This field is not
unique and may not be used as a key.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_accounts.owning_owner_id IS
$DOC$Associates the access account with a specific owner.  This allows for access
accounts which are identified and managed exclusively by a given owner.

When this field is NULL, the assumption is that it's an independent access
account.  An independent access account may be used, for example, by third party
accountants that need to access the instances of different owners.

This value may only be set on INSERT via this API view.  UPDATEs to this value
are not allowed after record creation.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_accounts.allow_global_logins IS
$DOC$When true, allows an access account to log into the system without having
an owner or instance specified in the login process.  This use case supports
access accounts which are independently managed, such as might be the case for
external bookkeepers.  When false, the access account is more tightly bound to a
specific owner and so only a specific owner and instances should be evaluated at
login time.

The need for this distinction arises when considering logins for access account
holders such as customers or vendors.  In these cases access to the owner's
environment should appear to be unique, but they may use the same identifier as
used for a different, but unrelated, owner.  In this case you have multiple
access accounts with possibly the same identifier; to resolve the conflict, it
is required therefore to know which owner or instance the access accounts holder
is trying to access.  In the allow global case we can just ask the account
holder but in the disallow global case we need to know it in advance.

Another way to think about global logins is in relation to user interface.  A
global login interface may present the user with a choice of instance owners and
then their instances whereas the non-global login user must go directly to the
login interface for a specific owner (be that URL or other client-side specific
identification.)$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_accounts.access_account_state_id IS
$DOC$The current life-cycle state of the access account.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_accounts.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_accounts.diag_role_created IS
$DOC$The database role which created the record.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_accounts.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_accounts.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_accounts.diag_role_modified IS
$DOC$The database role which modified the record.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_accounts.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_accounts.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.

This value is read only from this API view.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_i_syst_access_account_instance_assocs()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_access_account_instance_assocs.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_access_account_instance_assocs/trig_i_i_syst_access_account_instance_assocs.eex.sql
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

    INSERT INTO ms_syst_data.syst_access_account_instance_assocs
        ( access_account_id
        , instance_id
        , access_granted
        , invitation_issued
        , invitation_expires
        , invitation_declined )
    VALUES
        ( new.access_account_id
        , new.instance_id
        , new.access_granted
        , new.invitation_issued
        , new.invitation_expires
        , new.invitation_declined )
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_i_syst_access_account_instance_assocs()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_access_account_instance_assocs() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_access_account_instance_assocs() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_i_syst_access_account_instance_assocs() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_access_account_instance_assocs API View for INSERT operations.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_u_syst_access_account_instance_assocs()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_access_account_instance_assocs.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_access_account_instance_assocs/trig_i_u_syst_access_account_instance_assocs.eex.sql
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
        new.access_account_id  != old.access_account_id OR
        new.instance_id        != old.instance_id
    THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'The requested data update included changes to fields disallowed ' ||
                          'by the business rules of the API View.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst'
                            ,p_proc_name      => 'trig_i_u_syst_access_account_instance_assocs'
                            ,p_exception_name => 'invalid_api_view_call'
                            ,p_errcode        => 'PM008'
                            ,p_param_data     => jsonb_build_object('new', new, 'old', old)
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

    UPDATE ms_syst_data.syst_access_account_instance_assocs
    SET
        access_granted      = new.access_granted
      , invitation_issued   = new.invitation_issued
      , invitation_expires  = new.invitation_expires
      , invitation_declined = new.invitation_declined
    WHERE id = new.id
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_u_syst_access_account_instance_assocs()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_access_account_instance_assocs() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_access_account_instance_assocs() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_u_syst_access_account_instance_assocs() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_access_account_instance_assocs API View for UPDATE operations.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_d_syst_access_account_instance_assocs()
RETURNS trigger AS
$BODY$

-- File:        trig_i_d_syst_access_account_instance_assocs.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_access_account_instance_assocs/trig_i_d_syst_access_account_instance_assocs.eex.sql
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

    DELETE
    FROM ms_syst_data.syst_access_account_instance_assocs
    WHERE id = old.id
    RETURNING * INTO old;

    RETURN old;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_d_syst_access_account_instance_assocs()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_access_account_instance_assocs() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_access_account_instance_assocs() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_d_syst_access_account_instance_assocs() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_access_account_instance_assocs API View for DELETE operations.$DOC$;
-- File:        syst_access_account_instance_assocs.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_access_account_instance_assocs/syst_access_account_instance_assocs.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE VIEW ms_syst.syst_access_account_instance_assocs AS
SELECT
    id
  , access_account_id
  , instance_id
  , access_granted
  , invitation_issued
  , invitation_expires
  , invitation_declined
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM ms_syst_data.syst_access_account_instance_assocs;

ALTER VIEW ms_syst.syst_access_account_instance_assocs OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_access_account_instance_assocs FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_access_account_instance_assocs
    INSTEAD OF INSERT ON ms_syst.syst_access_account_instance_assocs
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_access_account_instance_assocs();

CREATE TRIGGER a50_trig_i_u_syst_access_account_instance_assocs
    INSTEAD OF UPDATE ON ms_syst.syst_access_account_instance_assocs
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_access_account_instance_assocs();

CREATE TRIGGER a50_trig_i_d_syst_access_account_instance_assocs
    INSTEAD OF DELETE ON ms_syst.syst_access_account_instance_assocs
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_access_account_instance_assocs();

COMMENT ON
    VIEW ms_syst.syst_access_account_instance_assocs IS
$DOC$Associates access accounts with the instances for which they are allowed to
authenticate to.  Note that being able to authenticate to an instance is not the
same as having authorized rights within the instance; authorization is handled
by the instance directly.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_account_instance_assocs.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_account_instance_assocs.access_account_id IS
$DOC$The access account which is being granted authentication rights to the given
instance.

This value may only be set on INSERT via this API view.  UPDATEs to this value
are not allowed after record creation.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_account_instance_assocs.instance_id IS
$DOC$The identity of the instance to which authentication rights is being granted.

This value may only be set on INSERT via this API view.  UPDATEs to this value
are not allowed after record creation.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_account_instance_assocs.access_granted IS
$DOC$The timestamp at which access to the instance was granted and active.  If
the access did not require the access invitation process, this value will
typically reflect the creation timestamp of the record.  If the invitation was
required, it will reflect the time when the access account holder actually
accepted the invitation to access the instance.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_account_instance_assocs.invitation_issued IS
$DOC$When inviting unowned, independent access accounts such as might be used by an
external bookkeeper, the grant of access by the instance owner is
not immediately effective but must also be approved by the access account holder
being granted access.  The timestamp in this column indicates when the
invitation to connect to the instance was issued.

If the value in this column is null, the assumption is that no invitation was
required to grant the access to the access account.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_account_instance_assocs.invitation_expires IS
$DOC$The timestamp at which the invitation to access a given instance expires.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_account_instance_assocs.invitation_declined IS
$DOC$The timestamp at which the access account holder explicitly declined the
invitation to access the given instance.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_account_instance_assocs.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_account_instance_assocs.diag_role_created IS
$DOC$The database role which created the record.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_account_instance_assocs.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_account_instance_assocs.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_account_instance_assocs.diag_role_modified IS
$DOC$The database role which modified the record.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_account_instance_assocs.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_access_account_instance_assocs.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.

This value is read only from this API view.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_i_syst_identities()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_identities.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_identities/trig_i_i_syst_identities.eex.sql
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

    INSERT INTO ms_syst_data.syst_identities
        ( access_account_id
        , identity_type_id
        , account_identifier
        , validated
        , validates_identity_id
        , validation_requested
        , identity_expires
        , external_name )
    VALUES
        ( new.access_account_id
        , new.identity_type_id
        , new.account_identifier
        , new.validated
        , new.validates_identity_id
        , new.validation_requested
        , new.identity_expires
        , new.external_name )
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_i_syst_identities()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_identities() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_identities() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_i_syst_identities() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_identities API View for INSERT operations.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_u_syst_identities()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_identities.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_identities/trig_i_u_syst_identities.eex.sql
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
        new.access_account_id     != old.access_account_id OR
        new.identity_type_id      != old.identity_type_id OR
        new.account_identifier    != old.account_identifier OR
        new.validates_identity_id != old.validates_identity_id
    THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'The requested data update included changes to fields disallowed ' ||
                          'by the business rules of the API View.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst'
                            ,p_proc_name      => 'trig_i_u_syst_identities'
                            ,p_exception_name => 'invalid_api_view_call'
                            ,p_errcode        => 'PM008'
                            ,p_param_data     => jsonb_build_object('new', new, 'old', old)
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

    UPDATE ms_syst_data.syst_identities
    SET
        validated            = new.validated
      , validation_requested = new.validation_requested
      , identity_expires     = new.identity_expires
      , external_name        = new.external_name
    WHERE id = new.id
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_u_syst_identities()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_identities() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_identities() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_u_syst_identities() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_instances API View for UPDATE operations.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_d_syst_identities()
RETURNS trigger AS
$BODY$

-- File:        trig_i_d_syst_identities.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_identities/trig_i_d_syst_identities.eex.sql
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

    DELETE FROM ms_syst_data.syst_identities WHERE id = old.id RETURNING * INTO old;

    RETURN old;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_d_syst_identities()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_identities() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_identities() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_d_syst_identities() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_identities API View for DELETE operations.$DOC$;
-- File:        syst_identities.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_identities/syst_identities.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE VIEW ms_syst.syst_identities AS
SELECT
    id
  , access_account_id
  , identity_type_id
  , account_identifier
  , validated
  , validates_identity_id
  , validation_requested
  , identity_expires
  , external_name
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM ms_syst_data.syst_identities;

ALTER VIEW ms_syst.syst_identities OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_identities FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_identities
    INSTEAD OF INSERT ON ms_syst.syst_identities
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_identities();

CREATE TRIGGER a50_trig_i_u_syst_identities
    INSTEAD OF UPDATE ON ms_syst.syst_identities
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_identities();

CREATE TRIGGER a50_trig_i_d_syst_identities
    INSTEAD OF DELETE ON ms_syst.syst_identities
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_identities();

COMMENT ON
    VIEW ms_syst.syst_identities IS
$DOC$The identities with which access accounts are identified to the system.  The
most common example of an identity would be a user name such as an email
address.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_identities.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_identities.access_account_id IS
$DOC$The ID of the access account to be identified the identifier record.

This value may only be set on INSERT via this API view.  UPDATEs to this value
are not allowed after record creation.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_identities.identity_type_id IS
$DOC$The kind of identifier being described by the record.  Note that this value
influences the kind of credentials that can be used to complete the
authentication process.

This value may only be set on INSERT via this API view.  UPDATEs to this value
are not allowed after record creation.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_identities.account_identifier IS
$DOC$The actual identifier which identifies a user or system to the system.

This value may only be set on INSERT via this API view.  UPDATEs to this value
are not allowed after record creation.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_identities.validated IS
$DOC$The timestamp at which the identity was validated for use.  Depending on the
requirements of the identity functional type, the timestamp here may be set as
the time of the identity creation or it may set when the access account holder
actually makes a formal verification.  A null value here indicates that the
identity is not validated by the access account holder and is not able to be
used for authentication to the system.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_identities.validates_identity_id IS
$DOC$Each identity requiring validation will require its own validation.  Since
validation requests are also single use identities, we need to know which
permanent identifier is being validate.  This column points to the identifier
that is being validated.  When the current identifier is not being used for
validation, this field is null.

This value may only be set on INSERT via this API view.  UPDATEs to this value
are not allowed after record creation.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_identities.validation_requested IS
$DOC$The timestamp on which the validation request was issued to the access account
holder.  This value will be null if the identity did not require validation.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_identities.identity_expires IS
$DOC$The timestamp at which the identity record expires.  For validation and
recovery identities this would be the time of validation/recovery request
expiration.  For perpetual identity types, this value will be NULL.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_identities.external_name IS
$DOC$An optional external identifier for use in user displays and similar scenarios.
This value is not unique and not suitable for anything more than informal record
identification by the user.  Some identity types may record a default value
automatically in this column.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_identities.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_identities.diag_role_created IS
$DOC$The database role which created the record.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_identities.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_identities.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_identities.diag_role_modified IS
$DOC$The database role which modified the record.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_identities.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_identities.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.

This value is read only from this API view.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_i_syst_credentials()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_credentials.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_credentials/trig_i_i_syst_credentials.eex.sql
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

    INSERT INTO ms_syst_data.syst_credentials
        ( access_account_id
        , credential_type_id
        , credential_for_identity_id
        , credential_data
        , last_updated
        , force_reset )
    VALUES
        ( new.access_account_id
        , new.credential_type_id
        , new.credential_for_identity_id
        , new.credential_data
        , new.last_updated
        , new.force_reset )
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_i_syst_credentials()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_credentials() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_credentials() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_i_syst_credentials() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_credentials API View for INSERT operations.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_u_syst_credentials()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_credentials.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_credentials/trig_i_u_syst_credentials.eex.sql
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
        new.access_account_id          != old.access_account_id OR
        new.credential_type_id         != old.credential_type_id OR
        new.credential_for_identity_id != old.credential_for_identity_id
    THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'The requested data update included changes to fields disallowed ' ||
                          'by the business rules of the API View.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst'
                            ,p_proc_name      => 'trig_i_u_syst_credentials'
                            ,p_exception_name => 'invalid_api_view_call'
                            ,p_errcode        => 'PM008'
                            ,p_param_data     => jsonb_build_object('new', new, 'old', old)
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

    UPDATE ms_syst_data.syst_credentials
    SET
        credential_data = new.credential_data
      , last_updated    = new.last_updated
      , force_reset     = new.force_reset
    WHERE id = new.id
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_u_syst_credentials()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_credentials() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_credentials() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_u_syst_credentials() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_credentials API View for UPDATE operations.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_d_syst_credentials()
RETURNS trigger AS
$BODY$

-- File:        trig_i_d_syst_credentials.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_credentials/trig_i_d_syst_credentials.eex.sql
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

    DELETE FROM ms_syst_data.syst_credentials WHERE id = old.id RETURNING * INTO old;

    RETURN old;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_d_syst_credentials()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_credentials() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_credentials() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_d_syst_credentials() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_credentials API View for DELETE operations.$DOC$;
-- File:        syst_credentials.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_credentials/syst_credentials.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE VIEW ms_syst.syst_credentials AS
SELECT
    id
  , access_account_id
  , credential_type_id
  , credential_for_identity_id
  , credential_data
  , last_updated
  , force_reset
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM ms_syst_data.syst_credentials;

ALTER VIEW ms_syst.syst_credentials OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_credentials FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_credentials
    INSTEAD OF INSERT ON ms_syst.syst_credentials
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_credentials();

CREATE TRIGGER a50_trig_i_u_syst_credentials
    INSTEAD OF UPDATE ON ms_syst.syst_credentials
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_credentials();

CREATE TRIGGER a50_trig_i_d_syst_credentials
    INSTEAD OF DELETE ON ms_syst.syst_credentials
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_credentials();

COMMENT ON
    VIEW ms_syst.syst_credentials IS
$DOC$Hosts the credentials by which a user or external system will prove its identity.
Note that not all credential types are available for authentication with all
identity types.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_credentials.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_credentials.access_account_id IS
$DOC$The access account for which the credential is to be used.

This value may only be set on INSERT via this API view.  UPDATEs to this value
are not allowed after record creation.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_credentials.credential_type_id IS
$DOC$The kind of credential that the record represents.  Note that the behavior and
use cases of the credential may have specific processing and handling
requirements based on the functional type of the credential type.

This value may only be set on INSERT via this API view.  UPDATEs to this value
are not allowed after record creation.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_credentials.credential_for_identity_id IS
$DOC$When an access account identity is created for either identity validation or
access account recovery, a single use identity is created as well as a single
use credential.  In this specific case, the one time use credential and the one
time use identity are linked.  This is especially important in recovery
scenarios to ensure that only the correct recovery communication can recover the
account.  This field identifies the which identity is associated with the
credential.

For regular use identities, there are no special credential requirements that
would be needed to for a link and the value in this column should be null.

This value may only be set on INSERT via this API view.  UPDATEs to this value
are not allowed after record creation.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_credentials.credential_data IS
$DOC$The actual data which supports verifying the presented identity in relation to
the access account.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_credentials.last_updated IS
$DOC$For credential types where rules regarding updating may apply, such as common
passwords, this column indicates when the credential was last updated (timestamp
of last password change, for example).   This field is explicitly not for dating
trivial or administrative changes which don't actually materially change the
credential data; please consult the appropriate diagnostic fields for those use
cases.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_credentials.force_reset IS
$DOC$Indicates whether or not certain credential types, such as passwords, must be
updated.  When NOT NULL, the user must update their credential on the next
login; when NULL updating the credential is not being administratively forced.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_credentials.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_credentials.diag_role_created IS
$DOC$The database role which created the record.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_credentials.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_credentials.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_credentials.diag_role_modified IS
$DOC$The database role which modified the record.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_credentials.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_credentials.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.

This value is read only from this API view.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_i_syst_global_network_rules()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_global_network_rules.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_global_network_rules/trig_i_i_syst_global_network_rules.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

BEGIN

    INSERT INTO ms_syst_data.syst_global_network_rules
        ( ordering
        , functional_type
        , ip_host_or_network
        , ip_host_range_lower
        , ip_host_range_upper )
    VALUES
        ( new.ordering
        , new.functional_type
        , new.ip_host_or_network
        , new.ip_host_range_lower
        , new.ip_host_range_upper )
    RETURNING
        id, ordering, functional_type, ip_host_or_network, ip_host_range_lower,
        ip_host_range_upper,
        family( coalesce( ip_host_or_network, ip_host_range_lower ) ),
        diag_timestamp_created, diag_role_created, diag_timestamp_modified,
        diag_wallclock_modified, diag_role_modified, diag_row_version,
        diag_update_count INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_i_syst_global_network_rules()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_global_network_rules() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_global_network_rules() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_i_syst_global_network_rules() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_global_network_rules API View for INSERT operations.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_u_syst_global_network_rules()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_global_network_rules.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_global_network_rules/trig_i_u_syst_global_network_rules.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

BEGIN

    IF new.ip_family     != old.ip_family THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'The requested data update included changes to fields disallowed ' ||
                          'by the business rules of the API View.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst'
                            ,p_proc_name      => 'trig_i_u_syst_global_network_rules'
                            ,p_exception_name => 'invalid_api_view_call'
                            ,p_errcode        => 'PM008'
                            ,p_param_data     => jsonb_build_object('new', new, 'old', old)
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

    UPDATE ms_syst_data.syst_global_network_rules
    SET
        ordering            = new.ordering
      , functional_type     = new.functional_type
      , ip_host_or_network  = new.ip_host_or_network
      , ip_host_range_lower = new.ip_host_range_lower
      , ip_host_range_upper = new.ip_host_range_upper
    WHERE id = new.id
    RETURNING
        id, ordering, functional_type, ip_host_or_network, ip_host_range_lower,
        ip_host_range_upper,
        family( coalesce( ip_host_or_network, ip_host_range_lower ) ),
        diag_timestamp_created, diag_role_created, diag_timestamp_modified,
        diag_wallclock_modified, diag_role_modified, diag_row_version,
        diag_update_count INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_u_syst_global_network_rules()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_global_network_rules() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_global_network_rules() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_u_syst_global_network_rules() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_global_network_rules API View for UPDATE operations.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_d_syst_global_network_rules()
RETURNS trigger AS
$BODY$

-- File:        trig_i_d_syst_global_network_rules.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_global_network_rules/trig_i_d_syst_global_network_rules.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

BEGIN

    DELETE
    FROM ms_syst_data.syst_global_network_rules
    WHERE id = old.id
    RETURNING
        id, ordering, functional_type, ip_host_or_network, ip_host_range_lower,
        ip_host_range_upper,
        family( coalesce( ip_host_or_network, ip_host_range_lower ) ),
        diag_timestamp_created, diag_role_created, diag_timestamp_modified,
        diag_wallclock_modified, diag_role_modified, diag_row_version,
        diag_update_count INTO old;

    RETURN old;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_d_syst_global_network_rules()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_global_network_rules() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_global_network_rules() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_d_syst_global_network_rules() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_global_network_rules API View for DELETE operations.$DOC$;
-- File:        syst_global_network_rules.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_global_network_rules/syst_global_network_rules.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE VIEW ms_syst.syst_global_network_rules AS
SELECT
    id
  , ordering
  , functional_type
  , ip_host_or_network
  , ip_host_range_lower
  , ip_host_range_upper
  , family( coalesce( ip_host_or_network, ip_host_range_lower ) ) AS ip_family
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM ms_syst_data.syst_global_network_rules;

ALTER VIEW ms_syst.syst_global_network_rules OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_global_network_rules FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_global_network_rules
    INSTEAD OF INSERT ON ms_syst.syst_global_network_rules
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_global_network_rules();

CREATE TRIGGER a50_trig_i_u_syst_global_network_rules
    INSTEAD OF UPDATE ON ms_syst.syst_global_network_rules
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_global_network_rules();

CREATE TRIGGER a50_trig_i_d_syst_global_network_rules
    INSTEAD OF DELETE ON ms_syst.syst_global_network_rules
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_global_network_rules();

COMMENT ON
    VIEW ms_syst.syst_global_network_rules IS
$DOC$Defines firewall-like rules that are global in scope indicating which IP
addresses are allowed to attempt authentication and which are not.  This also
includes the concept of global defaults applied to new Owner IP address rules.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_global_network_rules.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_global_network_rules.ordering IS
$DOC$Defines the order in which IP rules are applied.  Lower values are applied
prior to higher values.

When a new record is inserted with an existing ordering value, it is treated as
"insert before" the existing record and the existing record's ordering is
increased by one; this reordering process is recursive until there are no more
ordering value conflicts.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_global_network_rules.functional_type IS
$DOC$Indicates how the system will interpret the IP address rule.  The valid
functional types are:

    * `allow` - the rule is explicitly allowing an IP address, network, or
    range of IP addresses to continue in the authentication process.

    * `deny` - the rule is explicitly rejecting an IP address, network, or
    range of IP addresses from the authentication process.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_global_network_rules.ip_host_or_network IS
$DOC$An IPv4 or IPv6 IP address or network block expressed using standard CIDR
notation.

If this value is given you should not provide an IP host address range in the
ip_host_range_lower/ip_host_range_upper columns.  Providing range column values
when this column is not null will result in a consistency check failure.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_global_network_rules.ip_host_range_lower IS
$DOC$An IPv4 or IPv6 IP host address which is the lower bound (inclusive) of a
range of IP addresses.

If the value in this column is not null a value must also be provided for the
ip_host_range_upper column.  Both ip_host_range_lower and ip_host_range_upper
must be of the same IP family (IPv4 or IPv6).$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_global_network_rules.ip_host_range_upper IS
$DOC$An IPv4 or IPv6 IP host address which is the upper bound (inclusive) of a
range of IP addresses.

If the value in this column is not null a value must also be provided for the
ip_host_range_lower column.  Both ip_host_range_lower and ip_host_range_upper
must be of the same IP family (IPv4 or IPv6).$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_global_network_rules.ip_family IS
$DOC$
Indicates which IP family (IPv4/IPv6) for which the record defines a rule.

This value is read only from this API view.
$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_global_network_rules.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_global_network_rules.diag_role_created IS
$DOC$The database role which created the record.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_global_network_rules.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_global_network_rules.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_global_network_rules.diag_role_modified IS
$DOC$The database role which modified the record.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_global_network_rules.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_global_network_rules.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.

This value is read only from this API view.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_i_syst_owner_network_rules()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_owner_network_rules.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_owner_network_rules/trig_i_i_syst_owner_network_rules.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

BEGIN

    INSERT INTO ms_syst_data.syst_owner_network_rules
        ( owner_id
        , ordering
        , functional_type
        , ip_host_or_network
        , ip_host_range_lower
        , ip_host_range_upper )
    VALUES
        ( new.owner_id
        , new.ordering
        , new.functional_type
        , new.ip_host_or_network
        , new.ip_host_range_lower
        , new.ip_host_range_upper )
    RETURNING id
        , owner_id
        , ordering
        , functional_type
        , ip_host_or_network
        , ip_host_range_lower
        , ip_host_range_upper
        , family( coalesce( ip_host_or_network, ip_host_range_lower ) ) AS ip_family
        , diag_timestamp_created
        , diag_role_created
        , diag_timestamp_modified
        , diag_wallclock_modified
        , diag_role_modified
        , diag_row_version
        , diag_update_count INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_i_syst_owner_network_rules()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_owner_network_rules() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_owner_network_rules() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_i_syst_owner_network_rules() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_owner_network_rules API View for INSERT operations.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_u_syst_owner_network_rules()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_owner_network_rules.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_owner_network_rules/trig_i_u_syst_owner_network_rules.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

BEGIN

    IF
        new.owner_id  != old.owner_id OR
        new.ip_family != old.ip_family
    THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'The requested data update included changes to fields disallowed ' ||
                          'by the business rules of the API View.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst'
                            ,p_proc_name      => 'trig_i_u_syst_owner_network_rules'
                            ,p_exception_name => 'invalid_api_view_call'
                            ,p_errcode        => 'PM008'
                            ,p_param_data     => jsonb_build_object('new', new, 'old', old)
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

    UPDATE ms_syst_data.syst_owner_network_rules
    SET
        ordering            = new.ordering
      , functional_type     = new.functional_type
      , ip_host_or_network  = new.ip_host_or_network
      , ip_host_range_lower = new.ip_host_range_lower
      , ip_host_range_upper = new.ip_host_range_upper
    WHERE id = new.id
    RETURNING id
        , owner_id
        , ordering
        , functional_type
        , ip_host_or_network
        , ip_host_range_lower
        , ip_host_range_upper
        , family( coalesce( ip_host_or_network, ip_host_range_lower ) ) AS ip_family
        , diag_timestamp_created
        , diag_role_created
        , diag_timestamp_modified
        , diag_wallclock_modified
        , diag_role_modified
        , diag_row_version
        , diag_update_count INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_u_syst_owner_network_rules()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_owner_network_rules() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_owner_network_rules() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_u_syst_owner_network_rules() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_owner_network_rules API View for UPDATE operations.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_d_syst_owner_network_rules()
RETURNS trigger AS
$BODY$

-- File:        trig_i_d_syst_owner_network_rules.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_owner_network_rules/trig_i_d_syst_owner_network_rules.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

BEGIN

    DELETE
    FROM ms_syst_data.syst_owner_network_rules
    WHERE id = old.id
    RETURNING id
        , owner_id
        , ordering
        , functional_type
        , ip_host_or_network
        , ip_host_range_lower
        , ip_host_range_upper
        , family( coalesce( ip_host_or_network, ip_host_range_lower ) ) AS ip_family
        , diag_timestamp_created
        , diag_role_created
        , diag_timestamp_modified
        , diag_wallclock_modified
        , diag_role_modified
        , diag_row_version
        , diag_update_count INTO old;

    RETURN old;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_d_syst_owner_network_rules()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_owner_network_rules() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_owner_network_rules() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_d_syst_owner_network_rules() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_owner_network_rules API View for DELETE operations.$DOC$;
-- File:        syst_owner_network_rules.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_owner_network_rules/syst_owner_network_rules.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE VIEW ms_syst.syst_owner_network_rules AS
SELECT
    id
  , owner_id
  , ordering
  , functional_type
  , ip_host_or_network
  , ip_host_range_lower
  , ip_host_range_upper
  , family( coalesce( ip_host_or_network, ip_host_range_lower ) ) AS ip_family
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM ms_syst_data.syst_owner_network_rules;

ALTER VIEW ms_syst.syst_owner_network_rules OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_owner_network_rules FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_owner_network_rules
    INSTEAD OF INSERT ON ms_syst.syst_owner_network_rules
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_owner_network_rules();

CREATE TRIGGER a50_trig_i_u_syst_owner_network_rules
    INSTEAD OF UPDATE ON ms_syst.syst_owner_network_rules
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_owner_network_rules();

CREATE TRIGGER a50_trig_i_d_syst_owner_network_rules
    INSTEAD OF DELETE ON ms_syst.syst_owner_network_rules
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_owner_network_rules();

COMMENT ON
    VIEW ms_syst.syst_owner_network_rules IS
$DOC$Defines firewall-like rules that are global in scope indicating which IP
addresses are allowed to attempt authentication and which are not.  This also
includes the concept of global defaults applied to new Owner IP address rules.
These rules are applied in their defined ordering after the global_network_rules
and before the instance_network_rules.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_network_rules.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN  ms_syst.syst_owner_network_rules.owner_id IS
$DOC$The database identifier of the Owner record for whom the Network Rule is
being defined.

This value may only be set at record insertion time using this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_network_rules.ordering IS
$DOC$Defines the order in which IP rules are applied.  Lower values are applied
prior to higher values.  Note that all values of ordering should be unique
within each of the two types of rules, template and non-template types.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_network_rules.functional_type IS
$DOC$Indicates how the system will interpret the IP address rule.  The valid
functional types are:

    * `allow` - the rule is explicitly allowing an IP address, network, or
    range of IP addresses to continue in the authentication process.

    * `deny` - the rule is explicitly rejecting an IP address, network, or
    range of IP addresses from the authentication process.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_network_rules.ip_host_or_network IS
$DOC$An IPv4 or IPv6 IP address or network block expressed using standard CIDR
notation.

If this value is given you should not provide an IP host address range in the
ip_host_range_lower/ip_host_range_upper columns.  Providing range column values
when this column is not null will result in a consistency check failure.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_network_rules.ip_host_range_lower IS
$DOC$An IPv4 or IPv6 IP host address which is the lower bound (inclusive) of a
range of IP addresses.

If the value in this column is not null a value must also be provided for the
ip_host_range_upper column.  Both ip_host_range_lower and ip_host_range_upper
must be of the same IP family (IPv4 or IPv6).$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_network_rules.ip_host_range_upper IS
$DOC$An IPv4 or IPv6 IP host address which is the upper bound (inclusive) of a
range of IP addresses.

If the value in this column is not null a value must also be provided for the
ip_host_range_lower column.  Both ip_host_range_lower and ip_host_range_upper
must be of the same IP family (IPv4 or IPv6).$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_network_rules.ip_family IS
$DOC$
Indicates which IP family (IPv4/IPv6) for which the record defines a rule.

This value is read only from this API view.
$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_network_rules.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_network_rules.diag_role_created IS
$DOC$The database role which created the record.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_network_rules.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_network_rules.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_network_rules.diag_role_modified IS
$DOC$The database role which modified the record.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_network_rules.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_network_rules.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.

This value is read only from this API view.$DOC$;
CREATE OR REPLACE
    FUNCTION ms_syst.get_applied_network_rule(   p_host_addr         inet
                                                  , p_instance_id       uuid DEFAULT NULL
                                                  , p_instance_owner_id uuid DEFAULT NULL )
    RETURNS table
            (
                precedence          text,
                network_rule_id     uuid,
                functional_type     text,
                ip_host_or_network  inet,
                ip_host_range_lower inet,
                ip_host_range_upper inet
            )
AS
$BODY$

-- File:        get_applied_network_rule.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/functions/get_applied_network_rule.eex.sql
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
        precedence
      , network_rule_id
      , functional_type
      , ip_host_or_network
      , ip_host_range_lower
      , ip_host_range_upper
    FROM
        ms_syst_priv.get_applied_network_rule(
              p_host_addr         => p_host_addr
            , p_instance_id       => p_instance_id
            , p_instance_owner_id => p_instance_owner_id);

$BODY$
    LANGUAGE sql
    STABLE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION
    ms_syst.get_applied_network_rule(
          p_host_addr         inet
        , p_instance_id       uuid
        , p_instance_owner_id uuid )
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION
    ms_syst.get_applied_network_rule(
          p_host_addr         inet
        , p_instance_id       uuid
        , p_instance_owner_id uuid )
    FROM PUBLIC;

GRANT EXECUTE ON FUNCTION
    ms_syst.get_applied_network_rule(
          p_host_addr         inet
        , p_instance_id       uuid
        , p_instance_owner_id uuid )
    TO <%= ms_owner %>;

COMMENT ON FUNCTION
    ms_syst.get_applied_network_rule(
          p_host_addr         inet
        , p_instance_id       uuid
        , p_instance_owner_id uuid ) IS
$DOC$Applies all of the applicable network rules for a host and returns the governing
record for the identified host.

The returned rule is chosen by identifying which rules apply to the host based
on the provided Instance related parameters and then limiting the return to the
rule with the highest precedence.  Currently the precedence is defined as:

    1 - Disallowed Hosts: Globally disallowed or "banned" hosts are always
        checked first and no later rule can override the denial.  Only removing
        the host from the syst_disallowed_hosts table can reverse this denial.

    2 - Global Rules: These are rules applied to all Instances without
        exception.

    3 - Instance Rules: Rules defined by Instance Owners and are the most
        granular rule level available (p_instance_id).

    4 - Instance Owner Rules: Applied to all Instances owned by the identified
        Owner (p_instance_owner_id).

    5 - Global Implied Default Rule: When no explicitly defined network has been
        found for a host this rule will apply implicitly.  The current rule
        grants access from any host.

Finally note that this function returns the best matching rule for the provided
parameters.  This means that when p_host_addr is provided but neither of
p_instance_id or p_instance_owner_id are provided, the host can only be
evaluated against the Disallowed Hosts and the Global Network Rules which isn't
sufficient for a complete validation of a host's access to an Instance; such
incomplete checks can be useful to avoid more expensive authentication processes
later if the host is just going to be denied access due to global network rules.
Providing only p_instance_owner_id will include the Global and Owner defined
rules, but not the Instance specific rules.  If p_instance_id is provided that
is sufficient that is sufficient for testing all the applicable rules since the
Instance Owner ID can be derived using just p_instance_id parameter.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_i_syst_instance_network_rules()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_instance_network_rules.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_instance_network_rules/trig_i_i_syst_instance_network_rules.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

BEGIN

    INSERT INTO ms_syst_data.syst_instance_network_rules
        ( instance_id
        , ordering
        , functional_type
        , ip_host_or_network
        , ip_host_range_lower
        , ip_host_range_upper )
    VALUES
        ( new.instance_id
        , new.ordering
        , new.functional_type
        , new.ip_host_or_network
        , new.ip_host_range_lower
        , new.ip_host_range_upper )
    RETURNING id
        , instance_id
        , ordering
        , functional_type
        , ip_host_or_network
        , ip_host_range_lower
        , ip_host_range_upper
        , family( coalesce( ip_host_or_network, ip_host_range_lower ) ) AS ip_family
        , diag_timestamp_created
        , diag_role_created
        , diag_timestamp_modified
        , diag_wallclock_modified
        , diag_role_modified
        , diag_row_version
        , diag_update_count INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_i_syst_instance_network_rules()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_instance_network_rules() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_instance_network_rules() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_i_syst_instance_network_rules() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_instance_network_rules API View for INSERT operations.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_u_syst_instance_network_rules()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_instance_network_rules.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_instance_network_rules/trig_i_u_syst_instance_network_rules.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

BEGIN

    IF
        new.instance_id != old.instance_id OR
        new.ip_family   != old.ip_family
    THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'The requested data update included changes to fields disallowed ' ||
                          'by the business rules of the API View.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst'
                            ,p_proc_name      => 'trig_i_u_syst_instance_network_rules'
                            ,p_exception_name => 'invalid_api_view_call'
                            ,p_errcode        => 'PM008'
                            ,p_param_data     => jsonb_build_object('new', new, 'old', old)
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

    UPDATE ms_syst_data.syst_instance_network_rules
    SET
        ordering            = new.ordering
      , functional_type     = new.functional_type
      , ip_host_or_network  = new.ip_host_or_network
      , ip_host_range_lower = new.ip_host_range_lower
      , ip_host_range_upper = new.ip_host_range_upper
    WHERE id = new.id
    RETURNING id
        , instance_id
        , ordering
        , functional_type
        , ip_host_or_network
        , ip_host_range_lower
        , ip_host_range_upper
        , family( coalesce( ip_host_or_network, ip_host_range_lower ) ) AS ip_family
        , diag_timestamp_created
        , diag_role_created
        , diag_timestamp_modified
        , diag_wallclock_modified
        , diag_role_modified
        , diag_row_version
        , diag_update_count INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_u_syst_instance_network_rules()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_instance_network_rules() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_instance_network_rules() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_u_syst_instance_network_rules() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_instance_network_rules API View for UPDATE operations.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_d_syst_instance_network_rules()
RETURNS trigger AS
$BODY$

-- File:        trig_i_d_syst_instance_network_rules.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_instance_network_rules/trig_i_d_syst_instance_network_rules.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

BEGIN

    DELETE
    FROM ms_syst_data.syst_instance_network_rules
    WHERE id = old.id
    RETURNING id
        , instance_id
        , ordering
        , functional_type
        , ip_host_or_network
        , ip_host_range_lower
        , ip_host_range_upper
        , family( coalesce( ip_host_or_network, ip_host_range_lower ) ) AS ip_family
        , diag_timestamp_created
        , diag_role_created
        , diag_timestamp_modified
        , diag_wallclock_modified
        , diag_role_modified
        , diag_row_version
        , diag_update_count INTO old;

    RETURN old;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_d_syst_instance_network_rules()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_instance_network_rules() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_instance_network_rules() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_d_syst_instance_network_rules() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_instance_network_rules API View for DELETE operations.$DOC$;
-- File:        syst_instance_network_rules.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_instance_network_rules/syst_instance_network_rules.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE VIEW ms_syst.syst_instance_network_rules AS
SELECT
    id
  , instance_id
  , ordering
  , functional_type
  , ip_host_or_network
  , ip_host_range_lower
  , ip_host_range_upper
  , family( coalesce( ip_host_or_network, ip_host_range_lower ) ) AS ip_family
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM ms_syst_data.syst_instance_network_rules;

ALTER VIEW ms_syst.syst_instance_network_rules OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_instance_network_rules FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_instance_network_rules
    INSTEAD OF INSERT ON ms_syst.syst_instance_network_rules
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_instance_network_rules();

CREATE TRIGGER a50_trig_i_u_syst_instance_network_rules
    INSTEAD OF UPDATE ON ms_syst.syst_instance_network_rules
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_instance_network_rules();

CREATE TRIGGER a50_trig_i_d_syst_instance_network_rules
    INSTEAD OF DELETE ON ms_syst.syst_instance_network_rules
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_instance_network_rules();

COMMENT ON
    VIEW ms_syst.syst_instance_network_rules IS
$DOC$Defines firewall-like rules that are global in scope indicating which IP
addresses are allowed to attempt authentication and which are not.  This also
includes the concept of global defaults applied to new Instance IP address
rules. These rules are applied in their defined ordering after all other rule
sets.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instance_network_rules.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN  ms_syst.syst_instance_network_rules.instance_id IS
$DOC$The database identifier of the Instance record for whom the Network Rule is
being defined.

This value may only be set at record insertion time using this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instance_network_rules.ordering IS
$DOC$Defines the order in which IP rules are applied.  Lower values are applied
prior to higher values.  Note that all values of ordering should be unique
within each of the two types of rules, template and non-template types.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instance_network_rules.functional_type IS
$DOC$Indicates how the system will interpret the IP address rule.  The valid
functional types are:

    * `allow` - the rule is explicitly allowing an IP address, network, or
    range of IP addresses to continue in the authentication process.

    * `deny` - the rule is explicitly rejecting an IP address, network, or
    range of IP addresses from the authentication process.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instance_network_rules.ip_host_or_network IS
$DOC$An IPv4 or IPv6 IP address or network block expressed using standard CIDR
notation.

If this value is given you should not provide an IP host address range in the
ip_host_range_lower/ip_host_range_upper columns.  Providing range column values
when this column is not null will result in a consistency check failure.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instance_network_rules.ip_host_range_lower IS
$DOC$An IPv4 or IPv6 IP host address which is the lower bound (inclusive) of a
range of IP addresses.

If the value in this column is not null a value must also be provided for the
ip_host_range_upper column.  Both ip_host_range_lower and ip_host_range_upper
must be of the same IP family (IPv4 or IPv6).$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instance_network_rules.ip_host_range_upper IS
$DOC$An IPv4 or IPv6 IP host address which is the upper bound (inclusive) of a
range of IP addresses.

If the value in this column is not null a value must also be provided for the
ip_host_range_lower column.  Both ip_host_range_lower and ip_host_range_upper
must be of the same IP family (IPv4 or IPv6).$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instance_network_rules.ip_family IS
$DOC$
Indicates which IP family (IPv4/IPv6) for which the record defines a rule.

This value is read only from this API view.
$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instance_network_rules.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instance_network_rules.diag_role_created IS
$DOC$The database role which created the record.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instance_network_rules.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instance_network_rules.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instance_network_rules.diag_role_modified IS
$DOC$The database role which modified the record.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instance_network_rules.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_instance_network_rules.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.

This value is read only from this API view.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_i_syst_disallowed_hosts()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_disallowed_hosts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_disallowed_hosts/trig_i_i_syst_disallowed_hosts.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

BEGIN

    INSERT INTO ms_syst_data.syst_disallowed_hosts
        ( host_address )
    VALUES
        ( new.host_address )
    ON CONFLICT (host_address) DO NOTHING
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_i_syst_disallowed_hosts()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_disallowed_hosts() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_disallowed_hosts() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_i_syst_disallowed_hosts() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_disallowed_hosts API View for INSERT operations.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_u_syst_disallowed_hosts()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_disallowed_hosts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_disallowed_hosts/trig_i_u_syst_disallowed_hosts.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

BEGIN

    RAISE EXCEPTION
        USING
            MESSAGE = 'This API view does not allow for record updates for ' ||
                      'this table.',
            DETAIL = ms_syst_priv.get_exception_details(
                         p_proc_schema    => 'ms_syst'
                        ,p_proc_name      => 'trig_i_u_syst_disallowed_hosts'
                        ,p_exception_name => 'invalid_api_view_call'
                        ,p_errcode        => 'PM008'
                        ,p_param_data     => jsonb_build_object('new', new, 'old', old)
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

ALTER FUNCTION ms_syst.trig_i_u_syst_disallowed_hosts()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_disallowed_hosts() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_disallowed_hosts() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_u_syst_disallowed_hosts() IS
$DOC$trig_i_u_syst_password_history.eex.sql$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_d_syst_disallowed_hosts()
RETURNS trigger AS
$BODY$

-- File:        trig_i_d_syst_disallowed_hosts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_disallowed_hosts/trig_i_d_syst_disallowed_hosts.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

BEGIN

    DELETE FROM ms_syst_data.syst_disallowed_hosts WHERE id = old.id RETURNING * INTO old;

    RETURN old;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_d_syst_disallowed_hosts()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_disallowed_hosts() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_disallowed_hosts() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_d_syst_disallowed_hosts() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_disallowed_hosts API View for DELETE operations.$DOC$;
-- File:        syst_disallowed_hosts.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_disallowed_hosts/syst_disallowed_hosts.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE VIEW ms_syst.syst_disallowed_hosts AS
SELECT
    id
  , host_address
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM ms_syst_data.syst_disallowed_hosts;

ALTER VIEW ms_syst.syst_disallowed_hosts OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_disallowed_hosts FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_disallowed_hosts
    INSTEAD OF INSERT ON ms_syst.syst_disallowed_hosts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_disallowed_hosts();

CREATE TRIGGER a50_trig_i_u_syst_disallowed_hosts
    INSTEAD OF UPDATE ON ms_syst.syst_disallowed_hosts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_disallowed_hosts();

CREATE TRIGGER a50_trig_i_d_syst_disallowed_hosts
    INSTEAD OF DELETE ON ms_syst.syst_disallowed_hosts
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_disallowed_hosts();

COMMENT ON
    VIEW ms_syst.syst_disallowed_hosts IS
$DOC$A listing of IP addresses which are not allowed to attempt authentication.  This
registry differs from the syst_*_network_rules tables in that IP addresses here
are registered as the result of automatic system heuristics whereas the network
rules are direct expressions of system administrator intent.  The timing between
these two mechanisms is also different in that records in this table are
evaluated prior to an authentication attempt and most network rules are
processed in the authentication attempt sequence.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_disallowed_hosts.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_disallowed_hosts.host_address IS
$DOC$The IP address of the host disallowed from attempting to authenticate Access
Accounts.

The value in this column must be set on insert, but may not be updated later via
this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_disallowed_hosts.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_disallowed_hosts.diag_role_created IS
$DOC$The database role which created the record.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_disallowed_hosts.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_disallowed_hosts.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_disallowed_hosts.diag_role_modified IS
$DOC$The database role which modified the record.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_disallowed_hosts.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_disallowed_hosts.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.

This value is read only from this API view.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_i_syst_global_password_rules()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_global_password_rules.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_global_password_rules/trig_i_i_syst_global_password_rules.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

BEGIN

    RAISE EXCEPTION
        USING
            MESSAGE = 'This API view does not allow for record inserts for ' ||
                      'this table.',
            DETAIL = ms_syst_priv.get_exception_details(
                         p_proc_schema    => 'ms_syst'
                        ,p_proc_name      => 'trig_i_i_syst_global_password_rules'
                        ,p_exception_name => 'invalid_api_view_call'
                        ,p_errcode        => 'PM008'
                        ,p_param_data     => jsonb_build_object('new', new, 'old', old)
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

ALTER FUNCTION ms_syst.trig_i_i_syst_global_password_rules()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_global_password_rules() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_global_password_rules() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_i_syst_global_password_rules() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_global_password_rules API View for INSERT operations.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_u_syst_global_password_rules()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_global_password_rules.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_global_password_rules/trig_i_u_syst_global_password_rules.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

BEGIN

    UPDATE ms_syst_data.syst_global_password_rules
    SET
        password_length        = new.password_length
      , max_age                = new.max_age
      , require_upper_case     = new.require_upper_case
      , require_lower_case     = new.require_lower_case
      , require_numbers        = new.require_numbers
      , require_symbols        = new.require_symbols
      , disallow_recently_used = new.disallow_recently_used
      , disallow_compromised   = new.disallow_compromised
      , require_mfa            = new.require_mfa
      , allowed_mfa_types      = new.allowed_mfa_types
    WHERE id = new.id
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_u_syst_global_password_rules()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_global_password_rules() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_global_password_rules() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_u_syst_global_password_rules() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_global_password_rules API View for UPDATE operations.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_d_syst_global_password_rules()
RETURNS trigger AS
$BODY$

-- File:        trig_i_d_syst_global_password_rules.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_global_password_rules/trig_i_d_syst_global_password_rules.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

BEGIN

    RAISE EXCEPTION
        USING
            MESSAGE = 'This API view does not allow for record deletes for ' ||
                      'this table.',
            DETAIL = ms_syst_priv.get_exception_details(
                         p_proc_schema    => 'ms_syst'
                        ,p_proc_name      => 'trig_i_d_syst_global_password_rules'
                        ,p_exception_name => 'invalid_api_view_call'
                        ,p_errcode        => 'PM008'
                        ,p_param_data     => jsonb_build_object('new', new, 'old', old)
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

ALTER FUNCTION ms_syst.trig_i_d_syst_global_password_rules()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_global_password_rules() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_global_password_rules() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_d_syst_global_password_rules() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_global_password_rules API View for DELETE operations.$DOC$;
-- File:        syst_global_password_rules.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_global_password_rules/syst_global_password_rules.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE VIEW ms_syst.syst_global_password_rules AS
SELECT
    id
  , password_length
  , max_age
  , require_upper_case
  , require_lower_case
  , require_numbers
  , require_symbols
  , disallow_recently_used
  , disallow_compromised
  , require_mfa
  , allowed_mfa_types
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM ms_syst_data.syst_global_password_rules;

ALTER VIEW ms_syst.syst_global_password_rules OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_global_password_rules FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_global_password_rules
    INSTEAD OF INSERT ON ms_syst.syst_global_password_rules
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_global_password_rules();

CREATE TRIGGER a50_trig_i_u_syst_global_password_rules
    INSTEAD OF UPDATE ON ms_syst.syst_global_password_rules
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_global_password_rules();

CREATE TRIGGER a50_trig_i_d_syst_global_password_rules
    INSTEAD OF DELETE ON ms_syst.syst_global_password_rules
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_global_password_rules();

COMMENT ON
    VIEW ms_syst.syst_global_password_rules IS
$DOC$Establishes a minimum standard for password credential complexity globally.
Individual Owners may define more restrictive complexity requirements for their
own accounts and instances, but may not weaken those defined globally.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_global_password_rules.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_global_password_rules.password_length IS
$DOC$An integer range of acceptable password lengths with the lower bound
representing the minimum length and the upper bound representing the maximum
password length.   Length is determined on a per character basis, not a per
byte basis.

A zero or negative value on either bound indicates that the bound check is
disabled.  Note that disabling a bound may still result in a bounds check using
the application defined default for the bound.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_global_password_rules.max_age IS
$DOC$An interval indicating the maximum allowed age of a password.  Any password
older than this interval will typically result in the user being forced to
update their password prior to being allowed access to other functionality. The
specific user workflow will depend on the implementation details of application.

An interval of 0 time disables the check and passwords may be of any age.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_global_password_rules.require_upper_case IS
$DOC$Establishes the minimum number of upper case characters that are required to be
present in the password.  Setting this value to 0 disables the requirement for
upper case characters.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_global_password_rules.require_lower_case IS
$DOC$Establishes the minimum number of lower case characters that are required to be
present in the password.  Setting this value to 0 disables the requirement for
lower case characters.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_global_password_rules.require_numbers IS
$DOC$Establishes the minimum number of numeric characters that are required to be
present in the password.  Setting this value to 0 disables the requirement for
numeric characters.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_global_password_rules.require_symbols IS
$DOC$Establishes the minimum number of non-alphanumeric characters that are required
to be present in the password.  Setting this value to 0 disables the requirement
for non-alphanumeric characters.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_global_password_rules.disallow_recently_used IS
$DOC$When passwords are changed, this value determines how many prior passwords
should be checked in order to prevent password re-use.  Setting this value to
zero or a negative number will disable the recently used password check.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_global_password_rules.disallow_compromised IS
$DOC$When true new passwords submitted through the change password process will be
checked against a list of common passwords and passwords known to have been
compromised and disallow their use as password credentials in the system.

When false submitted passwords are not checked as being common or against known
compromised passwords; such passwords would therefore be usable in the system.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_global_password_rules.require_mfa IS
$DOC$When true, an approved multi-factor authentication method must be used in
addition to the password credential.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_global_password_rules.allowed_mfa_types IS
$DOC$A array of the approved multi-factor authentication methods.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_global_password_rules.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_global_password_rules.diag_role_created IS
$DOC$The database role which created the record.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_global_password_rules.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_global_password_rules.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_global_password_rules.diag_role_modified IS
$DOC$The database role which modified the record.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_global_password_rules.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_global_password_rules.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.

This value is read only from this API view.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_i_syst_owner_password_rules()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_owner_password_rules.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_owner_password_rules/trig_i_i_syst_owner_password_rules.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

BEGIN

    INSERT INTO ms_syst_data.syst_owner_password_rules
        ( owner_id
        , password_length
        , max_age
        , require_upper_case
        , require_lower_case
        , require_numbers
        , require_symbols
        , disallow_recently_used
        , disallow_compromised
        , require_mfa
        , allowed_mfa_types )
    VALUES
        ( new.owner_id
        , new.password_length
        , new.max_age
        , new.require_upper_case
        , new.require_lower_case
        , new.require_numbers
        , new.require_symbols
        , new.disallow_recently_used
        , new.disallow_compromised
        , new.require_mfa
        , new.allowed_mfa_types )
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_i_syst_owner_password_rules()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_owner_password_rules() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_owner_password_rules() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_i_syst_owner_password_rules() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_owner_password_rules API View for INSERT operations.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_u_syst_owner_password_rules()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_owner_password_rules.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_owner_password_rules/trig_i_u_syst_owner_password_rules.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

BEGIN

    IF new.owner_id != old.owner_id THEN
        RAISE EXCEPTION
            USING
                MESSAGE = 'The requested data update included changes to fields disallowed ' ||
                          'by the business rules of the API View.',
                DETAIL = ms_syst_priv.get_exception_details(
                             p_proc_schema    => 'ms_syst'
                            ,p_proc_name      => 'trig_i_u_syst_owner_password_rules'
                            ,p_exception_name => 'invalid_api_view_call'
                            ,p_errcode        => 'PM008'
                            ,p_param_data     => jsonb_build_object('new', new, 'old', old)
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

    UPDATE ms_syst_data.syst_owner_password_rules
    SET
        password_length        = new.password_length
      , max_age                = new.max_age
      , require_upper_case     = new.require_upper_case
      , require_lower_case     = new.require_lower_case
      , require_numbers        = new.require_numbers
      , require_symbols        = new.require_symbols
      , disallow_recently_used = new.disallow_recently_used
      , disallow_compromised   = new.disallow_compromised
      , require_mfa            = new.require_mfa
      , allowed_mfa_types      = new.allowed_mfa_types
    WHERE id = new.id
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_u_syst_owner_password_rules()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_owner_password_rules() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_owner_password_rules() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_u_syst_owner_password_rules() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_owner_password_rules API View for UPDATE operations.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_d_syst_owner_password_rules()
RETURNS trigger AS
$BODY$

-- File:        trig_i_d_syst_owner_password_rules.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_owner_password_rules/trig_i_d_syst_owner_password_rules.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

BEGIN

    DELETE FROM ms_syst_data.syst_owner_password_rules WHERE id = old.id RETURNING * INTO old;

    RETURN old;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_d_syst_owner_password_rules()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_owner_password_rules() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_owner_password_rules() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_d_syst_owner_password_rules() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_owner_password_rules API View for DELETE operations.$DOC$;
-- File:        syst_owner_password_rules.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_owner_password_rules/syst_owner_password_rules.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE VIEW ms_syst.syst_owner_password_rules AS
SELECT
    id
  , owner_id
  , password_length
  , max_age
  , require_upper_case
  , require_lower_case
  , require_numbers
  , require_symbols
  , disallow_recently_used
  , disallow_compromised
  , require_mfa
  , allowed_mfa_types
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM ms_syst_data.syst_owner_password_rules;

ALTER VIEW ms_syst.syst_owner_password_rules OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_owner_password_rules FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_owner_password_rules
    INSTEAD OF INSERT ON ms_syst.syst_owner_password_rules
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_owner_password_rules();

CREATE TRIGGER a50_trig_i_u_syst_owner_password_rules
    INSTEAD OF UPDATE ON ms_syst.syst_owner_password_rules
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_owner_password_rules();

CREATE TRIGGER a50_trig_i_d_syst_owner_password_rules
    INSTEAD OF DELETE ON ms_syst.syst_owner_password_rules
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_owner_password_rules();

COMMENT ON
    VIEW ms_syst.syst_owner_password_rules IS
$DOC$Defines the password credential complexity standard for a given Owner.  While
Owners may define stricter standards than the global password credential
complexity standard, looser standards than the global will not have any effect
and the global standard will be used instead.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_password_rules.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_password_rules.password_length IS
$DOC$An integer range of acceptable password lengths with the lower bound
representing the minimum length and the upper bound representing the maximum
password length.   Length is determined on a per character basis, not a per
byte basis.

A zero or negative value on either bound indicates that the bound check is
disabled.  Note that disabling a bound may still result in a bounds check using
the application defined default for the bound.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_password_rules.owner_id IS
$DOC$Defined the relationship with a specific Owner for whom the password rule the
specific rule is being defined.

The value in this column must be set on insert, but may not be updated later via
this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_password_rules.max_age IS
$DOC$An interval indicating the maximum allowed age of a password.  Any password
older than this interval will typically result in the user being forced to
update their password prior to being allowed access to other functionality. The
specific user workflow will depend on the implementation details of application.

An interval of 0 time disables the check and passwords may be of any age.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_password_rules.require_upper_case IS
$DOC$Establishes the minimum number of upper case characters that are required to be
present in the password.  Setting this value to 0 disables the requirement for
upper case characters.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_password_rules.require_lower_case IS
$DOC$Establishes the minimum number of lower case characters that are required to be
present in the password.  Setting this value to 0 disables the requirement for
lower case characters.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_password_rules.require_numbers IS
$DOC$Establishes the minimum number of numeric characters that are required to be
present in the password.  Setting this value to 0 disables the requirement for
numeric characters.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_password_rules.require_symbols IS
$DOC$Establishes the minimum number of non-alphanumeric characters that are required
to be present in the password.  Setting this value to 0 disables the requirement
for non-alphanumeric characters.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_password_rules.disallow_recently_used IS
$DOC$When passwords are changed, this value determines how many prior passwords
should be checked in order to prevent password re-use.  Setting this value to
zero or a negative number will disable the recently used password check.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_password_rules.disallow_compromised IS
$DOC$When true new passwords submitted through the change password process will be
checked against a list of common passwords and passwords known to have been
compromised and disallow their use as password credentials in the system.

When false submitted passwords are not checked as being common or against known
compromised passwords; such passwords would therefore be usable in the system.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_password_rules.require_mfa IS
$DOC$When true, an approved multi-factor authentication method must be used in
addition to the password credential.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_password_rules.allowed_mfa_types IS
$DOC$A array of the approved multi-factor authentication methods.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_password_rules.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_password_rules.diag_role_created IS
$DOC$The database role which created the record.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_password_rules.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_password_rules.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_password_rules.diag_role_modified IS
$DOC$The database role which modified the record.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_password_rules.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_owner_password_rules.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.

This value is read only from this API view.$DOC$;
-- File:        trig_i_i_syst_disallowed_passwords.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_disallowed_passwords/trig_i_i_syst_disallowed_passwords.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE OR REPLACE FUNCTION ms_syst.trig_i_i_syst_disallowed_passwords()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_disallowed_passwords.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_disallowed_passwords/trig_i_i_syst_disallowed_passwords.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

BEGIN

    INSERT INTO ms_syst_data.syst_disallowed_passwords
        ( password_hash )
    VALUES
        ( new.password_hash )
    ON CONFLICT ( password_hash ) DO NOTHING
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_i_syst_disallowed_passwords()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_disallowed_passwords() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_disallowed_passwords() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_i_syst_disallowed_passwords() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_disallowed_passwords API View for INSERT operations.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_u_syst_disallowed_passwords()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_disallowed_passwords.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_disallowed_passwords/trig_i_u_syst_disallowed_passwords.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

BEGIN

    RAISE EXCEPTION
        USING
            MESSAGE = 'This API view does not allow for record updates for ' ||
                      'this table.',
            DETAIL = ms_syst_priv.get_exception_details(
                         p_proc_schema    => 'ms_syst'
                        ,p_proc_name      => 'trig_i_u_syst_disallowed_passwords'
                        ,p_exception_name => 'invalid_api_view_call'
                        ,p_errcode        => 'PM008'
                        ,p_param_data     => jsonb_build_object('new', new, 'old', old)
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

ALTER FUNCTION ms_syst.trig_i_u_syst_disallowed_passwords()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_disallowed_passwords() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_disallowed_passwords() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_u_syst_disallowed_passwords() IS
$DOC$Enforces that update operations are not permitted via this API.$DOC$;
-- File:        trig_i_d_syst_disallowed_passwords.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_disallowed_passwords/trig_i_d_syst_disallowed_passwords.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE OR REPLACE FUNCTION ms_syst.trig_i_d_syst_disallowed_passwords()
RETURNS trigger AS
$BODY$

-- File:        trig_i_d_syst_disallowed_passwords.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_disallowed_passwords/trig_i_d_syst_disallowed_passwords.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

BEGIN

    DELETE FROM ms_syst_data.syst_disallowed_passwords
    WHERE password_hash = old.password_hash
    RETURNING * INTO old;

    RETURN old;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_d_syst_disallowed_passwords()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_disallowed_passwords() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_disallowed_passwords() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_d_syst_disallowed_passwords() IS
$DOC$Enforces that DELETE operations are not permitted via this API.$DOC$;
-- File:        syst_disallowed_passwords.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_disallowed_passwords/syst_disallowed_passwords.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE VIEW ms_syst.syst_disallowed_passwords AS
SELECT password_hash FROM ms_syst_data.syst_disallowed_passwords;

ALTER VIEW ms_syst.syst_disallowed_passwords OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_disallowed_passwords FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_disallowed_passwords
    INSTEAD OF INSERT ON ms_syst.syst_disallowed_passwords
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_disallowed_passwords();

CREATE TRIGGER a50_trig_i_u_syst_disallowed_passwords
    INSTEAD OF UPDATE ON ms_syst.syst_disallowed_passwords
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_disallowed_passwords();

CREATE TRIGGER a50_trig_i_d_syst_disallowed_passwords
    INSTEAD OF DELETE ON ms_syst.syst_disallowed_passwords
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_disallowed_passwords();

COMMENT ON
    VIEW ms_syst.syst_disallowed_passwords IS
$DOC$A list of hashed passwords which are disallowed for use in the system when the
password rule to disallow common/known compromised passwords is enabled.
Currently the expectation is that common passwords will be stored as sha1
hashes.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_i_syst_password_history()
RETURNS trigger AS
$BODY$

-- File:        trig_i_i_syst_password_history.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_password_history/trig_i_i_syst_password_history.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

BEGIN

    INSERT INTO ms_syst_data.syst_password_history
        ( access_account_id, credential_data )
    VALUES
        ( new.access_account_id, new.credential_data )
    RETURNING * INTO new;

    RETURN new;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_i_syst_password_history()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_password_history() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_password_history() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_i_syst_password_history() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_password_history API View for INSERT operations.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_u_syst_password_history()
RETURNS trigger AS
$BODY$

-- File:        trig_i_u_syst_password_history.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_password_history/trig_i_u_syst_password_history.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

BEGIN

    RAISE EXCEPTION
        USING
            MESSAGE = 'This API view does not allow for record updates for ' ||
                      'this table.',
            DETAIL = ms_syst_priv.get_exception_details(
                         p_proc_schema    => 'ms_syst'
                        ,p_proc_name      => 'trig_i_u_syst_password_history'
                        ,p_exception_name => 'invalid_api_view_call'
                        ,p_errcode        => 'PM008'
                        ,p_param_data     => jsonb_build_object('new', new, 'old', old)
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

ALTER FUNCTION ms_syst.trig_i_u_syst_password_history()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_password_history() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_password_history() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_u_syst_password_history() IS
$DOC$Enforces that update operations are not permitted via this API.$DOC$;
CREATE OR REPLACE FUNCTION ms_syst.trig_i_d_syst_password_history()
RETURNS trigger AS
$BODY$

-- File:        trig_i_d_syst_password_history.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_password_history/trig_i_d_syst_password_history.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

BEGIN

    DELETE FROM ms_syst_data.syst_password_history WHERE id = old.id RETURNING * INTO old;

    RETURN old;

END;
$BODY$
    LANGUAGE plpgsql
    VOLATILE
    SECURITY DEFINER
    SET search_path TO ms_syst, pg_temp;

ALTER FUNCTION ms_syst.trig_i_d_syst_password_history()
    OWNER TO <%= ms_owner %>;

REVOKE EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_password_history() FROM public;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_password_history() TO <%= ms_owner %>;

COMMENT ON FUNCTION ms_syst.trig_i_d_syst_password_history() IS
$DOC$An INSTEAD OF trigger function which applies business rules when using the
syst_password_history API View for DELETE operations.$DOC$;
-- File:        syst_password_history.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/ms_syst/api_views/syst_password_history/syst_password_history.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

CREATE VIEW ms_syst.syst_password_history AS
SELECT
    id
  , access_account_id
  , credential_data
  , diag_timestamp_created
  , diag_role_created
  , diag_timestamp_modified
  , diag_wallclock_modified
  , diag_role_modified
  , diag_row_version
  , diag_update_count
FROM ms_syst_data.syst_password_history;

ALTER VIEW ms_syst.syst_password_history OWNER TO <%= ms_owner %>;

REVOKE ALL ON TABLE ms_syst.syst_password_history FROM PUBLIC;

CREATE TRIGGER a50_trig_i_i_syst_password_history
    INSTEAD OF INSERT ON ms_syst.syst_password_history
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_i_syst_password_history();

CREATE TRIGGER a50_trig_i_u_syst_password_history
    INSTEAD OF UPDATE ON ms_syst.syst_password_history
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_u_syst_password_history();

CREATE TRIGGER a50_trig_i_d_syst_password_history
    INSTEAD OF DELETE ON ms_syst.syst_password_history
    FOR EACH ROW EXECUTE PROCEDURE ms_syst.trig_i_d_syst_password_history();

COMMENT ON
    VIEW ms_syst.syst_password_history IS
$DOC$Keeps the history of access account prior passwords for enforcing the reuse
password rule.

This API View allows the application to read and maintain the data according to
well defined application business rules.  Using this API view for updates to
data is the preferred method of data maintenance in the course of normal usage.

Only user maintainable values may be maintained via this API.  System created or
maintained data is not maintainable via this view.  Attempts at invalid data
maintenance via this API may result in the invalid changes being ignored or may
raise an exception.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_password_history.id IS
$DOC$The record's primary key.  The definitive identifier of the record in the
system.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_password_history.access_account_id IS
$DOC$The Access Account to which the password history record belongs.

The value in this column must be set on insert, but may not be updated later via
this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_password_history.credential_data IS
$DOC$The previously hashed password recorded for reuse comparisons.  This is the same
format as the existing active password credential.

The value in this column must be set on insert, but may not be updated later via
this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_password_history.diag_timestamp_created IS
$DOC$The database server date/time when the transaction which created the record
started.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_password_history.diag_role_created IS
$DOC$The database role which created the record.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_password_history.diag_timestamp_modified IS
$DOC$The database server date/time when the transaction which modified the record
started.  This field will be the same as diag_timestamp_created for inserted
records.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_password_history.diag_wallclock_modified IS
$DOC$The database server date/time at the moment the record was actually modified.
For long running transactions this time may be significantly later than the
value of diag_timestamp_modified.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_password_history.diag_role_modified IS
$DOC$The database role which modified the record.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_password_history.diag_row_version IS
$DOC$The current version of the row.  The value here indicates how many actual
data changes have been made to the row.  If an update of the row leaves all data
fields the same, disregarding the updates to the diag_* columns, the row version
is not updated, nor are any updates made to the other diag_* columns other than
diag_update_count.

This value is read only from this API view.$DOC$;

COMMENT ON
    COLUMN ms_syst.syst_password_history.diag_update_count IS
$DOC$Records the number of times the record has been updated regardless as to if
the update actually changed any data.  In this way needless or redundant record
updates can be found.  This row starts at 0 and therefore may be the same as the
diag_row_version - 1.

This value is read only from this API view.$DOC$;
-- File:        privileges.eex.sql
-- Location:    musebms/database/subsystems/mssub_mcp/components/mscmp_syst_authn/privileges.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems

--
-- MscmpSystAuthn
--

-- syst_access_accounts

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_access_accounts TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_access_accounts TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_access_accounts TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_access_accounts TO <%= ms_appusr %>;

-- syst_access_account_instance_assocs

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_access_account_instance_assocs TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_access_account_instance_assocs TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_access_account_instance_assocs TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_access_account_instance_assocs TO <%= ms_appusr %>;

-- syst_identities

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_identities TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_identities TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_identities TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_identities TO <%= ms_appusr %>;

-- syst_credentials

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_credentials TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_credentials TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_credentials TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_credentials TO <%= ms_appusr %>;

-- syst_global_network_rules

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_global_network_rules TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_global_network_rules TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_global_network_rules TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_global_network_rules TO <%= ms_appusr %>;

-- syst_owner_network_rules

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_owner_network_rules TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_owner_network_rules TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_owner_network_rules TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_owner_network_rules TO <%= ms_appusr %>;

-- syst_instance_network_rules

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_instance_network_rules TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_instance_network_rules TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_instance_network_rules TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_instance_network_rules TO <%= ms_appusr %>;

-- syst_disallowed_hosts

GRANT SELECT, INSERT, DELETE ON TABLE ms_syst.syst_disallowed_hosts TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_disallowed_hosts TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_disallowed_hosts TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_disallowed_hosts TO <%= ms_appusr %>;

-- syst_global_password_rules

GRANT SELECT, UPDATE ON TABLE ms_syst.syst_global_password_rules TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_global_password_rules TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_global_password_rules TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_global_password_rules TO <%= ms_appusr %>;

-- syst_owner_password_rules

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ms_syst.syst_owner_password_rules TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_owner_password_rules TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_owner_password_rules TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_owner_password_rules TO <%= ms_appusr %>;

-- syst_disallowed_passwords

GRANT SELECT, INSERT, DELETE ON TABLE ms_syst.syst_disallowed_passwords TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_disallowed_passwords TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_disallowed_passwords TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_disallowed_passwords TO <%= ms_appusr %>;

-- syst_password_history

GRANT SELECT, INSERT, DELETE ON TABLE ms_syst.syst_password_history TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_i_syst_password_history TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_u_syst_password_history TO <%= ms_appusr %>;
GRANT EXECUTE ON FUNCTION ms_syst.trig_i_d_syst_password_history TO <%= ms_appusr %>;

-- Functions

GRANT EXECUTE
  ON FUNCTION ms_syst.get_applied_network_rule( p_host_addr         inet
                                              , p_instance_id       uuid
                                              , p_instance_owner_id uuid )
  TO <%= ms_appusr %>;
END;
$MIGRATION$;
