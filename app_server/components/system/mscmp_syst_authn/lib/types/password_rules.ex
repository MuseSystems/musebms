# Source File: password_rules.ex
# Location:    musebms/app_server/components/system/mscmp_syst_authn/lib/types/password_rules.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystAuthn.Types.PasswordRules do
  @moduledoc """
  Defines a generic Password Rule record allowing Password Rules originating
  from different database sources a common representation.

  Password Rules are defined in two different database tables,
  `Msdata.SystGlobalPasswordRules` and
  `Msdata.SystOwnerPasswordRules`.  This type defines a
  common representation of Password Rule data for those parts of the system that
  apply Password Rules after the applicable Password Rules have been resolved.
  """

  alias MscmpSystAuthn.Types
  alias MscmpSystDb.DbTypes

  defstruct [
    :access_account_id,
    :owner_id,
    :password_length,
    :max_age,
    :require_upper_case,
    :require_lower_case,
    :require_numbers,
    :require_symbols,
    :disallow_recently_used,
    :disallow_compromised,
    :require_mfa,
    :allowed_mfa_types
  ]

  @typedoc """
  Defines a generic Password Rule record allowing Password Rules originating
  from different database sources a common representation.

  ## Attributes

    * `access_account_id` - the Access Account for which the effective Password
    Rules has been resolved.

    * `owner_id` - the Owner record ID of the Owner which owns the Access
    Account.  The Access Account's Owner may have established Password Rules
    which would apply to the Access Account.  A value here does not mean that
    the Owner's rules necessarily are part of the resolved Password Rule, just
    that they would have been considered.

    * `password_length` - the resolved value of type
    `t:MscmpSystDb.DbTypes.IntegerRange.t/0` describing the password
    length in terms of the number of characters.  The lower bound defines the
    minimum number of characters a password may have and the upper bound is the
    most characters that can be added to password.

    * `max_age` - the resolved value of type `t:MscmpSystDb.DbTypes.Interval.t/0`
    which, when added to the `last_updated` value of the Password Credential
    record, sets the expiration date of the password.  After the password's age
    has exceeded it's max age, the password must be reset prior to finalizing
    authentication. A zero interval value here means that password ages are not
    checked.  The zero interval is the default setting.

    * `require_upper_case` - the resolved minimum number of upper case
    characters that a valid password must posses.  A setting of zero here
    disables the requirement.

    * `require_lower_case` - the resolved minimum number of lower case
    characters that a valid password must posses.  A setting of zero here
    disables the requirement.

    * `require_numbers` - the resolved minimum number of number characters that
    a valid password must posses.  A setting of zero here disables the
    requirement.

    * `require_symbols` - the resolved minimum number of symbol characters that
    a valid password must posses.  A setting of zero here disables the
    requirement.

    * `disallow_recently_used` - A positive integer representing the number of
    most recently used passwords to track and prohibit from re-use.  A zero
    setting for this attribute indicates that recently used passwords should not
    be tracked or prohibited.

    * `disallow_compromised` - A boolean value which, if true, indicates that
    any new password requested by a user be first checked against the Disallowed
    Passwords list and, if found on the list, rejected for use.  When set true,
    the system will also check the password against the Disallowed Password list
    on authentication; if found on the list at authentication time, the user
    will be required to reset their password to something value not otherwise
    disallowed.  If set false the Disallowed Password list is not checked.

    * `require_mfa` - A boolean value which indicates if multi-factor
    authentication is required for password authentication.  If true MFA is
    required, otherwise MFA is per user preference.  MFA may not be completely
    disabled.

    * `allowed_mfa_types` - A list of strings identifying the allowed second
    factor methods. Currently only MFA type `credential_types_secondary_totp` is
    available.

  See `MscmpSystAuthn.Types.AuthenticationState` for more.
  """
  @type t :: %__MODULE__{
          access_account_id: Types.access_account_id() | nil,
          owner_id: MscmpSystInstance.Types.owner_id() | nil,
          password_length: DbTypes.IntegerRange.t(),
          max_age: DbTypes.Interval.t(),
          require_upper_case: non_neg_integer(),
          require_lower_case: non_neg_integer(),
          require_numbers: non_neg_integer(),
          require_symbols: non_neg_integer(),
          disallow_recently_used: non_neg_integer(),
          disallow_compromised: boolean(),
          require_mfa: boolean(),
          allowed_mfa_types: list(String.t())
        }
end
