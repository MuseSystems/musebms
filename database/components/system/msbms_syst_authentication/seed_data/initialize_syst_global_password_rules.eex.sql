-- File:        initialize_syst_global_password_rules.eex.sql
-- Location:    musebms/database/components/system/msbms_syst_authentication/seed_data/initialize_syst_global_password_rules.eex.sql
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

INSERT INTO msbms_syst_data.syst_global_password_rules
    ( password_length
    , max_age
    , require_upper_case
    , require_lower_case
    , require_numbers
    , require_symbols
    , disallow_recently_used
    , disallow_known_compromised
    , require_mfa
    , allowed_mfa_types )
VALUES
    ( int4range( 8, 512, '[]' )
    , interval '0 days'
    , 0
    , 0
    , 0
    , 0
    , 0
    , TRUE
    , FALSE
    , ARRAY['credential_types_secondary_totp']::text[] );
