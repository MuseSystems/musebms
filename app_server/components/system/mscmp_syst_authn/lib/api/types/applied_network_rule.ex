# Source File: applied_network_rule.ex
# Location:    musebms/app_server/components/system/mscmp_syst_authn/lib/api/types/applied_network_rule.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystAuthn.Types.AppliedNetworkRule do
  @moduledoc """
  Represents the return value of functions which evaluate whether or not a
  specific originating host IP address is allowed to attempt an authentication.

  When an authentication is attempted, a number of different rules and data
  sources may determine what kind of connection is allowed based on the host IP
  address from which the attempt appears to be originating and the destination
  Instance for which the authentication is being processed.  To normalize the
  return from the evaluation of these different network based evaluations we
  define a simplified `t:applied_network_rule/0` value to represent the
  actionable data of the evaluation.
  """

  alias MscmpSystAuthn.Types

  @enforce_keys [:precedence, :network_rule_id, :functional_type]
  @derive Jason.Encoder
  defstruct [:precedence, :network_rule_id, :functional_type]

  @typedoc """
  Represents the return value of functions which evaluate whether or not a
  specific originating host IP address is allowed to attempt an authentication.

  ## Attributes

    * `precedence` - this will indicate the precedence of the applied Network
    Rule.  This value can aid in identifying the origin of a given applied
    allowance or denial.

    * `network_rule_id` - this is the record ID of the rule which was evaluated
    to govern the authentication attempt.  Which specific relation the ID refers
    to will depend on the specific precedence of the rule applied.  This value
    may be `nil` if the implied default Network Rule is applied since, by
    definition, this means no other explicitly defined Network Rule was found.

    * `functional_type` - May be either `:allow` or `:deny`.  `:allow` means
    that the Network Rule evaluation allows the host IP address to attempt
    authentication.  `:deny` indicates that the host IP address may not attempt
    an authentication.

  See `MscmpSystAuthn.Types.AppliedNetworkRule` for more.
  """
  @type t :: %__MODULE__{
          precedence: Types.network_rule_precedence(),
          network_rule_id: Ecto.UUID.t() | nil,
          functional_type: Types.network_rule_functional_type()
        }
end
