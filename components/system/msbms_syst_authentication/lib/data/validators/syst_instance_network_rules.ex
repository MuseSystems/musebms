# Source File: syst_instance_network_rules.ex
# Location:    musebms/components/system/msbms_syst_authentication/lib/data/validators/syst_instance_network_rules.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystAuthentication.Data.Validators.SystInstanceNetworkRules do
  import Ecto.Changeset

  alias MsbmsSystAuthentication.Data
  alias MsbmsSystAuthentication.Data.Helpers
  alias MsbmsSystAuthentication.Types

  @moduledoc false

  @spec insert_changeset(Types.instance_network_rule_params()) :: Ecto.Changeset.t()
  def insert_changeset(insert_params) do
    resolved_params =
      insert_params
      |> Helpers.SystInstanceNetworkRules.resolve_name_params(:insert)
      |> Helpers.General.resolve_network_rule_params_func_type()

    %Data.SystInstanceNetworkRules{}
    |> cast(resolved_params, [
      :instance_id,
      :ordering,
      :functional_type,
      :ip_host_or_network,
      :ip_host_range_lower,
      :ip_host_range_upper
    ])
    |> validate_common()
    |> validate_functional_type()
    |> validate_network_addresses()
  end

  @spec update_changeset(Data.SystInstanceNetworkRules.t(), Types.instance_network_rule_params()) ::
          Ecto.Changeset.t()
  def update_changeset(instance_network_rule, update_params) do
    resolved_params = Helpers.General.resolve_network_rule_params_func_type(update_params)

    instance_network_rule
    |> cast(resolved_params, [
      :ordering,
      :functional_type,
      :ip_host_or_network,
      :ip_host_range_lower,
      :ip_host_range_upper
    ])
    |> validate_common()
    |> validate_functional_type()
    |> validate_network_addresses()
    |> optimistic_lock(:diag_row_version)
  end

  defp validate_common(changeset) do
    validate_required(changeset, [
      :instance_id,
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

  defp validate_network_addresses(changeset) do
    cidr_addr = get_field(changeset, :ip_host_or_network)
    ip_lower = get_field(changeset, :ip_host_range_lower)
    ip_upper = get_field(changeset, :ip_host_range_upper)

    cidr_range_violation? = !is_nil(cidr_addr) and (!is_nil(ip_lower) or !is_nil(ip_upper))
    range_missing_lower? = is_nil(ip_lower) != is_nil(ip_upper) and is_nil(ip_lower)
    range_missing_upper? = is_nil(ip_lower) != is_nil(ip_upper) and is_nil(ip_upper)

    range_reversed_values? =
      !is_nil(ip_lower) and !is_nil(ip_upper) and ip_lower.address >= ip_upper.address

    changeset
    |> maybe_add_cidr_range_error(cidr_range_violation?)
    |> maybe_add_missing_lower_error(range_missing_lower?)
    |> maybe_add_missing_upper_error(range_missing_upper?)
    |> maybe_add_range_reversed_error(range_reversed_values?)
  end

  defp maybe_add_cidr_range_error(changeset, true) do
    add_error(
      changeset,
      :ip_host_or_network,
      """
      You may specify a CIDR host/network or a simple range of IP addresses,
      but not both in the same rule.
      """
    )
  end

  defp maybe_add_cidr_range_error(changeset, _false), do: changeset

  defp maybe_add_missing_lower_error(changeset, true) do
    add_error(
      changeset,
      :ip_host_range_lower,
      "When specifying a range of IP addresses you must also provide a lower bound."
    )
  end

  defp maybe_add_missing_lower_error(changeset, _false), do: changeset

  defp maybe_add_missing_upper_error(changeset, true) do
    add_error(
      changeset,
      :ip_host_range_upper,
      "When specifying a range of IP addresses you must also provide an upper bound."
    )
  end

  defp maybe_add_missing_upper_error(changeset, _false), do: changeset

  defp maybe_add_range_reversed_error(changeset, true) do
    add_error(
      changeset,
      :ip_host_range_upper,
      """
      When specifying a range of IP addresses the upper bound must be
      greater than the lower bound.
      """
    )
  end

  defp maybe_add_range_reversed_error(changeset, _false), do: changeset
end
