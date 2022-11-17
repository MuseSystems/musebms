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
