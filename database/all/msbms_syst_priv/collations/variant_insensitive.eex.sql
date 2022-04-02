-- File:        variant_insensitive.eex.sql
-- Location:    database\all\msbms_syst_priv\collations\variant_insensitive.eex.sql
-- Project:     Muse Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com  :: https://muse.systems

CREATE COLLATION msbms_syst_priv.variant_insensitive (
     PROVIDER      = 'icu'
    ,LOCALE        = 'und-u-ks-level1'
    ,DETERMINISTIC = FALSE
    );

COMMENT ON
    COLLATION msbms_syst_priv.variant_insensitive IS
$DOC$A collation which ignores upper/lower case and certain other types of base
character variants (i.e. e = é).  Mostly this will be used for internal_name
columns.  Please note that there are performance implications and cross system
consistency implications when using this collation.$DOC$;

ALTER COLLATION msbms_syst_priv.variant_insensitive OWNER TO <%= msbms_owner %>;
