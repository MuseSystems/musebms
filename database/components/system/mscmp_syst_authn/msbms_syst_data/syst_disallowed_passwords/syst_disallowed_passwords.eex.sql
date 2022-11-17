-- File:        syst_disallowed_passwords.eex.sql
-- Location:    musebms/database/components/system/mscmp_syst_authn/msbms_syst_data/syst_disallowed_passwords/syst_disallowed_passwords.eex.sql
-- Project:     Muse Systems Business Management System
--
-- Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
-- This file may include content copyrighted and licensed from third parties.
--
-- See the LICENSE file in the project root for license terms and conditions.
-- See the NOTICE file in the project root for copyright ownership information.
--
-- muse.information@musesystems.com :: https://muse.systems
CREATE TABLE msbms_syst_data.syst_disallowed_passwords
(
     password_hash bytea PRIMARY KEY
);

ALTER TABLE msbms_syst_data.syst_disallowed_passwords OWNER TO <%= msbms_owner %>;

REVOKE ALL ON TABLE msbms_syst_data.syst_disallowed_passwords FROM public;
GRANT ALL ON TABLE msbms_syst_data.syst_disallowed_passwords TO <%= msbms_owner %>;

CREATE TRIGGER z99_trig_b_iu_set_diagnostic_columns
    BEFORE INSERT OR UPDATE ON msbms_syst_data.syst_disallowed_passwords
    FOR EACH ROW EXECUTE PROCEDURE msbms_syst_priv.trig_b_iu_set_diagnostic_columns();

COMMENT ON
    TABLE msbms_syst_data.syst_disallowed_passwords IS
$DOC$A list of hashed passwords which are disallowed for use in the system when the
password rule to disallow common/known compromised passwords is enabled.
Currently the expectation is that common passwords will be stored as sha1
hashes.$DOC$;

COMMENT ON
    COLUMN msbms_syst_data.syst_disallowed_passwords.password_hash IS
$DOC$The SHA1 hash of the disallowed password.  The reason for using SHA1 here is
that it is compatible with the "Have I Been Pwned" data and API products.  We
also get some reasonable obscuring of possibly private data.$DOC$;
