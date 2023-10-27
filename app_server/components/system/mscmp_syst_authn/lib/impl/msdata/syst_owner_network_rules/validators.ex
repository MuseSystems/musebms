# Source File: validators.ex
# Location:    musebms/app_server/components/system/mscmp_syst_authn/lib/impl/msdata/syst_owner_network_rules/validators.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystAuthn.Impl.Msdata.SystOwnerNetworkRules.Validators do
  @moduledoc false

  import Ecto.Changeset

  alias MscmpSystAuthn.Impl.Msdata.Helpers
  alias MscmpSystAuthn.Types

  @spec insert_changeset(Types.owner_network_rule_params()) :: Ecto.Changeset.t()
  def insert_changeset(insert_params) do
    resolved_params =
      insert_params
      |> resolve_name_params(:insert)
      |> Helpers.resolve_network_rule_params_func_type()

    %Msdata.SystOwnerNetworkRules{}
    |> cast(resolved_params, [
      :owner_id,
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

  @spec update_changeset(Msdata.SystOwnerNetworkRules.t(), Types.owner_network_rule_params()) ::
          Ecto.Changeset.t()
  def update_changeset(owner_network_rule, update_params) do
    resolved_params = Helpers.resolve_network_rule_params_func_type(update_params)

    owner_network_rule
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
      :owner_id,
      :ordering,
      :functional_type
    ])
    |> foreign_key_constraint(:owner_id, name: :syst_owner_network_rules_owner_fk)
    |> unique_constraint([:owner_id, :ordering],
      name: :syst_owner_network_rules_owner_ordering_udx
    )
    |> check_constraint(:functional_type, name: :syst_owner_network_rules_functional_type_chk)
    |> check_constraint(:ip_host_or_network, name: :syst_owner_network_rules_host_or_range_chk)
    |> check_constraint(:ip_host_range_lower, name: :syst_owner_network_rules_ip_range_family_chk)
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

  defp resolve_name_params(network_rule_params, _operation),
    do: Helpers.resolve_owner_id(network_rule_params)
end
