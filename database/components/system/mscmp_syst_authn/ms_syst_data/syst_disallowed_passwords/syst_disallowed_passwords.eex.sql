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

DO
$DOCUMENTATION$
DECLARE
    -- Table
    var_comments_config ms_syst_priv.comments_config_table;

    -- Columns
    var_password_hash ms_syst_priv.comments_config_table_column;

BEGIN

    --
    -- Table Config
    --

    var_comments_config.table_schema    := 'ms_syst_data';
    var_comments_config.table_name      := 'syst_disallowed_passwords';
    var_comments_config.generate_common := FALSE;

    var_comments_config.description :=
$DOC$A list of hashed passwords which are disallowed for use in the system when the
password rule to disallow common/known compromised passwords is enabled.
Currently the expectation is that common passwords will be stored as sha1
hashes.$DOC$;

    --
    -- Column Configs
    --

    var_password_hash.column_name := 'password_hash';
    var_password_hash.description :=
$DOC$The SHA1 hash of the disallowed password.  The reason for using SHA1 here is
that it is compatible with the "Have I Been Pwned" data and API products.  We
also get some reasonable obscuring of possibly private data.$DOC$;

    var_comments_config.columns :=
        ARRAY [ var_password_hash ]::ms_syst_priv.comments_config_table_column[];

    PERFORM ms_syst_priv.generate_comments_table( var_comments_config );

END;
$DOCUMENTATION$;
