# Source File: syst_global_password_rules.ex
# Location:    musebms/app_server/components/system/mscmp_syst_authn/lib/api/msdata/syst_global_password_rules.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msdata.SystGlobalPasswordRules do
  @moduledoc """
  Establishes rules defining the minimum allowed password complexity
  on a global, whole system basis.

  Rules defined here may be further strengthened by rules defined by
  `SystOwnerPasswordRules`, but may not be weakened by those definitions.

  Defined in `MscmpSystAuthn`.
  """

  use MscmpSystDb.Schema

  alias MscmpSystAuthn.Impl.Msdata.SystGlobalPasswordRules.Validators
  alias MscmpSystAuthn.Types
  alias MscmpSystDb.DbTypes

  @type t() ::
          %__MODULE__{
            __meta__: Ecto.Schema.Metadata.t(),
            id: Ecto.UUID.t() | nil,
            password_length: DbTypes.IntegerRange.t() | nil,
            max_age: DbTypes.Interval.t() | nil,
            require_upper_case: integer() | nil,
            require_lower_case: integer() | nil,
            require_numbers: integer() | nil,
            require_symbols: integer() | nil,
            disallow_recently_used: integer() | nil,
            disallow_compromised: boolean() | nil,
            require_mfa: boolean() | nil,
            allowed_mfa_types: list(String.t()) | nil,
            diag_timestamp_created: DateTime.t() | nil,
            diag_role_created: String.t() | nil,
            diag_timestamp_modified: DateTime.t() | nil,
            diag_wallclock_modified: DateTime.t() | nil,
            diag_role_modified: String.t() | nil,
            diag_row_version: integer() | nil,
            diag_update_count: integer() | nil
          }

  @schema_prefix "ms_syst"

  schema "syst_global_password_rules" do
    field(:password_length, DbTypes.IntegerRange)
    field(:max_age, DbTypes.Interval)
    field(:require_upper_case, :integer)
    field(:require_lower_case, :integer)
    field(:require_numbers, :integer)
    field(:require_symbols, :integer)
    field(:disallow_recently_used, :integer)
    field(:disallow_compromised, :boolean)
    field(:require_mfa, :boolean)
    field(:allowed_mfa_types, {:array, :string})
    field(:diag_timestamp_created, :utc_datetime)
    field(:diag_role_created, :string, load_in_query: false)
    field(:diag_timestamp_modified, :utc_datetime)
    field(:diag_wallclock_modified, :utc_datetime, load_in_query: false)
    field(:diag_role_modified, :string, load_in_query: false)
    field(:diag_row_version, :integer)
    field(:diag_update_count, :integer, load_in_query: false)
  end

  @spec update_changeset(t(), Types.password_rule_params()) :: Ecto.Changeset.t()
  defdelegate update_changeset(global_password_rule, update_params), to: Validators
end
