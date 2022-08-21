# Source File: syst_global_network_rules.ex
# Location:    musebms/components/system/msbms_syst_authentication/lib/data/validators/syst_global_network_rules.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystAuthentication.Data.Validators.SystGlobalNetworkRules do
  import Ecto.Changeset

  alias MsbmsSystAuthentication.Data
  alias MsbmsSystAuthentication.Types

  @moduledoc false

  @spec insert_changeset(Types.global_network_rule_params()) :: Ecto.Changeset.t()
  def insert_changeset(insert_params) do
    %Data.SystGlobalNetworkRules{}
    |> cast(insert_params, [
      :template_rule,
      :ordering,
      :functional_type,
      :ip_host_or_network,
      :ip_host_range_lower,
      :ip_host_range_upper
    ])
    |> validate_common()
    |> validate_functional_type()
    |> validate_cidr_or_range()
  end

  @spec update_changeset(Data.SystGlobalNetworkRules.t(), Types.global_network_rule_params()) ::
          Ecto.Changeset.t()
  def update_changeset(global_network_rule, update_params) do
    global_network_rule
    |> cast(update_params, [
      :template_rule,
      :ordering,
      :functional_type,
      :ip_host_or_network,
      :ip_host_range_lower,
      :ip_host_range_upper
    ])
    |> validate_common()
    |> validate_functional_type()
    |> validate_cidr_or_range()
    |> optimistic_lock(:diag_row_version)
  end

  defp validate_common(changeset) do
    validate_required(changeset, [
      :template_rule,
      :ordering,
      :functional_type
    ])
  end

  defp validate_functional_type(changeset) do
    case get_field(changeset, :functional_type) do
      func_type when func_type in ["allow", "deny"] ->
        changeset

      func_type when is_binary(func_type) ->
        add_error(
          changeset,
          :functional_type,
          "An unknown network rule functional type was provided."
        )

      _ ->
        add_error(
          changeset,
          :functional_type,
          "An invalid network rule functional type was provided."
        )
    end
  end

  defp validate_cidr_or_range(changeset) do
    cidr_addr = get_field(changeset, :ip_host_or_network)
    ip_lower = get_field(changeset, :ip_host_range_lower)
    ip_upper = get_field(changeset, :ip_host_range_upper)

    cond do
      !is_nil(cidr_addr) and (!is_nil(ip_lower) or !is_nil(ip_lower)) ->
        add_error(
          changeset,
          :ip_host_or_network,
          """
          You may specify a CIDR host/network or a simple range of IP addresses,
          but not both in the same rule.
          """
        )

      is_nil(ip_lower) != is_nil(ip_upper) and is_nil(ip_lower) ->
        add_error(
          changeset,
          :ip_host_range_lower,
          "When specifying a range of IP addresses you must also provide a lower bound."
        )

      is_nil(ip_lower) != is_nil(ip_upper) and is_nil(ip_upper) ->
        add_error(
          changeset,
          :ip_host_range_upper,
          "When specifying a range of IP addresses you must also provide an upper bound."
        )

      !is_nil(ip_lower) and !is_nil(ip_upper) and ip_lower.address >= ip_upper.address ->
        add_error(
          changeset,
          :ip_host_range_upper,
          """
          When specifying a range of IP addresses the upper bound must be
          greater than the lower bound.
          """
        )

      true ->
        changeset
    end
  end
end
