# Source File: network_rules.ex
# Location:    musebms/components/system/mscmp_syst_authn/lib/impl/network_rules.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystAuthn.Impl.NetworkRules do
  @moduledoc false

  import Msutils.Guards

  import Ecto.Query
  import MscmpSystNetwork.Guards, only: [is_ip: 1]

  alias MscmpSystAuthn.Types
  alias MscmpSystDb.DbTypes

  require Logger

  ##############################################################################
  #
  # host_disallowed
  #
  #

  @spec host_disallowed?(Types.host_address()) :: boolean()
  def host_disallowed?(host_addr) do
    target_host = DbTypes.Inet.from_net_address(host_addr)

    from(dh in Msdata.SystDisallowedHosts, where: dh.host_address == ^target_host)
    |> MscmpSystDb.exists?()
  end

  ##############################################################################
  #
  # create_disallowed_host
  #
  #

  @spec create_disallowed_host(Types.host_address()) ::
          {:ok, :already_disallowed}
          | {:ok, {:disallowed, Msdata.SystDisallowedHosts.t()}}
          | {:error, term()}
  def create_disallowed_host(host_addr) do
    target_host = DbTypes.Inet.from_net_address(host_addr)

    Msdata.SystDisallowedHosts.insert_changeset(target_host)
    |> MscmpSystDb.insert(returning: true)
    |> case do
      {:ok, %Msdata.SystDisallowedHosts{} = record} when is_nil(record.id) ->
        {:ok, :already_disallowed}

      {:ok, %Msdata.SystDisallowedHosts{} = record} ->
        {:ok, {:disallowed, record}}

      error ->
        {:error, {:database_error, error}}
    end
  end

  ##############################################################################
  #
  # delete_disallowed_host_addr
  #
  #

  @spec delete_disallowed_host_addr(Types.host_address()) :: :ok | {:error, term()}
  def delete_disallowed_host_addr(host_addr) do
    target_host = DbTypes.Inet.from_net_address(host_addr)

    from(dh in Msdata.SystDisallowedHosts, where: dh.host_address == ^target_host)
    |> process_disallowed_host_delete()
  end

  ##############################################################################
  #
  # delete_disallowed_host
  #
  #

  @spec delete_disallowed_host(Types.disallowed_host_id() | Msdata.SystDisallowedHosts.t()) ::
          :ok | {:error, term()}
  def delete_disallowed_host(%Msdata.SystDisallowedHosts{} = disallowed_host) do
    from(dh in Msdata.SystDisallowedHosts, where: dh.id == ^disallowed_host.id)
    |> process_disallowed_host_delete()
  end

  def delete_disallowed_host(disallowed_host_id) when is_uuid(disallowed_host_id) do
    from(dh in Msdata.SystDisallowedHosts, where: dh.id == ^disallowed_host_id)
    |> process_disallowed_host_delete()
  end

  defp process_disallowed_host_delete(query) do
    query
    |> MscmpSystDb.delete_all()
    |> case do
      {0, _} -> {:error, :not_found}
      {1, _} -> :ok
      error -> {:error, {:database_error, error}}
    end
  end

  ##############################################################################
  #
  # get_disallowed_host_record_by_id
  #
  #

  @spec get_disallowed_host_record_by_id(Types.disallowed_host_id()) ::
          {:ok, Msdata.SystDisallowedHosts.t()} | {:error, term()}
  def get_disallowed_host_record_by_id(disallowed_host_id) do
    from(dh in Msdata.SystDisallowedHosts, where: dh.id == ^disallowed_host_id)
    |> MscmpSystDb.one()
    |> case do
      nil -> {:error, :not_found}
      record -> {:ok, record}
    end
  end

  ##############################################################################
  #
  # get_disallowed_host_record_by_host
  #
  #

  @spec get_disallowed_host_record_by_host(Types.host_address()) ::
          {:ok, :allowed}
          | {:ok, {:disallowed, Msdata.SystDisallowedHosts.t()}}
          | {:error, term()}
  def get_disallowed_host_record_by_host(host_addr) do
    target_host = DbTypes.Inet.from_net_address(host_addr)

    from(dh in Msdata.SystDisallowedHosts, where: dh.host_address == ^target_host)
    |> MscmpSystDb.one()
    |> case do
      nil -> {:ok, :allowed}
      %Msdata.SystDisallowedHosts{} = record -> {:ok, {:disallowed, record}}
      error -> {:error, {:database_error, error}}
    end
  end

  ##############################################################################
  #
  # get_applied_network_rule
  #
  #

  @spec get_applied_network_rule(
          Types.host_address(),
          MscmpSystInstance.Types.instance_id() | nil,
          MscmpSystInstance.Types.owner_id() | nil
        ) :: {:ok, Types.AppliedNetworkRule.t()} | {:error, term()}
  def get_applied_network_rule(host_addr, instance_id \\ nil, instance_owner_id \\ nil) do
    with {:ok, target_instance_id} <- get_query_uuid(instance_id),
         {:ok, target_owner_id} <- get_query_uuid(instance_owner_id) do
      target_host =
        host_addr
        |> DbTypes.Inet.from_net_address()
        |> DbTypes.Inet.to_postgrex_inet()

      from(
        nr in fragment(
          "ms_syst.get_applied_network_rule(?, ?, ?)",
          ^target_host,
          ^target_instance_id,
          ^target_owner_id
        ),
        select: %{
          precedence: nr.precedence,
          network_rule_id: nr.network_rule_id,
          functional_type: nr.functional_type
        }
      )
      |> MscmpSystDb.one()
      |> case do
        nil ->
          {:error, {:not_found, host_addr}}

        %{} = rule ->
          {:ok,
           %Types.AppliedNetworkRule{
             precedence: String.to_atom(rule.precedence),
             network_rule_id: parse_rule_id(rule.network_rule_id),
             functional_type: String.to_atom(rule.functional_type)
           }}

        invalid_rule ->
          {:error, {:invalid_rule, invalid_rule}}
      end
    end
  end

  defp get_query_uuid(nil), do: {:ok, nil}
  defp get_query_uuid(:bypass), do: {:ok, nil}
  defp get_query_uuid(value) when is_uuid(value), do: Ecto.UUID.dump(value)
  defp get_query_uuid(value), do: {:error, {:invalid_uuid, value}}

  defp parse_rule_id(nil), do: nil
  defp parse_rule_id(rule_id), do: Ecto.UUID.cast!(rule_id)

  ##############################################################################
  #
  # create_global_network_rule
  #
  #

  @spec create_global_network_rule(Types.global_network_rule_params()) ::
          {:ok, Msdata.SystGlobalNetworkRules.t()} | {:error, term()}
  def create_global_network_rule(insert_params) do
    insert_params
    |> maybe_convert_params_net_addresses()
    |> Msdata.SystGlobalNetworkRules.insert_changeset()
    |> MscmpSystDb.insert(returning: true)
  end

  ##############################################################################
  #
  # create_owner_network_rule
  #
  #

  @spec create_owner_network_rule(
          MscmpSystInstance.Types.owner_id(),
          Types.owner_network_rule_params()
        ) ::
          {:ok, Msdata.SystOwnerNetworkRules.t()} | {:error, term()}
  def create_owner_network_rule(owner_id, insert_params) do
    insert_params
    |> maybe_convert_params_net_addresses()
    |> Map.put(:owner_id, owner_id)
    |> Msdata.SystOwnerNetworkRules.insert_changeset()
    |> MscmpSystDb.insert(returning: true)
  end

  ##############################################################################
  #
  # create_instance_network_rule
  #
  #

  @spec create_instance_network_rule(
          MscmpSystInstance.Types.instance_id(),
          Types.instance_network_rule_params()
        ) ::
          {:ok, Msdata.SystInstanceNetworkRules.t()} | {:error, term()}
  def create_instance_network_rule(instance_id, insert_params) do
    insert_params
    |> maybe_convert_params_net_addresses()
    |> Map.put(:instance_id, instance_id)
    |> Msdata.SystInstanceNetworkRules.insert_changeset()
    |> MscmpSystDb.insert(returning: true)
  end

  ##############################################################################
  #
  # update_global_network_rule
  #
  #

  @spec update_global_network_rule(
          Ecto.UUID.t() | Msdata.SystGlobalNetworkRules.t(),
          Types.global_network_rule_params()
        ) ::
          {:ok, Msdata.SystGlobalNetworkRules.t()} | {:error, term()}
  def update_global_network_rule(global_network_rule_id, update_params)
      when is_binary(global_network_rule_id) do
    with {:ok, global_rule} <- get_global_network_rule(global_network_rule_id) do
      update_global_network_rule(global_rule, update_params)
    end
  end

  def update_global_network_rule(
        %Msdata.SystGlobalNetworkRules{} = global_network_rule,
        update_params
      ) do
    resolved_params = maybe_convert_params_net_addresses(update_params)

    global_network_rule
    |> Msdata.SystGlobalNetworkRules.update_changeset(resolved_params)
    |> MscmpSystDb.update(returning: true)
  end

  ##############################################################################
  #
  # update_owner_network_rule
  #
  #

  @spec update_owner_network_rule(
          Ecto.UUID.t() | Msdata.SystOwnerNetworkRules.t(),
          Types.owner_network_rule_params()
        ) ::
          {:ok, Msdata.SystOwnerNetworkRules.t()} | {:error, term()}
  def update_owner_network_rule(owner_network_rule_id, update_params)
      when is_binary(owner_network_rule_id) do
    with {:ok, owner_rule} <- get_owner_network_rule(owner_network_rule_id) do
      update_owner_network_rule(owner_rule, update_params)
    end
  end

  def update_owner_network_rule(
        %Msdata.SystOwnerNetworkRules{} = owner_network_rule,
        update_params
      ) do
    resolved_params = maybe_convert_params_net_addresses(update_params)

    owner_network_rule
    |> Msdata.SystOwnerNetworkRules.update_changeset(resolved_params)
    |> MscmpSystDb.update(returning: true)
  end

  ##############################################################################
  #
  # update_instance_network_rule
  #
  #

  @spec update_instance_network_rule(
          Ecto.UUID.t() | Msdata.SystInstanceNetworkRules.t(),
          Types.instance_network_rule_params()
        ) ::
          {:ok, Msdata.SystInstanceNetworkRules.t()} | {:error, term()}

  def update_instance_network_rule(instance_network_rule_id, update_params)
      when is_binary(instance_network_rule_id) do
    with {:ok, instance_rule} <- get_instance_network_rule(instance_network_rule_id) do
      update_instance_network_rule(instance_rule, update_params)
    end
  end

  def update_instance_network_rule(
        %Msdata.SystInstanceNetworkRules{} = instance_network_rule,
        update_params
      ) do
    resolved_params = maybe_convert_params_net_addresses(update_params)

    instance_network_rule
    |> Msdata.SystInstanceNetworkRules.update_changeset(resolved_params)
    |> MscmpSystDb.update(returning: true)
  end

  ##############################################################################
  #
  # get_global_network_rule
  #
  #

  @spec get_global_network_rule(Ecto.UUID.t()) ::
          {:ok, Msdata.SystGlobalNetworkRules.t()} | {:error, term()}
  def get_global_network_rule(global_network_rule_id) do
    from(gnr in Msdata.SystGlobalNetworkRules, where: gnr.id == ^global_network_rule_id)
    |> MscmpSystDb.one()
    |> case do
      nil -> {:error, {:not_found, global_network_rule_id}}
      global_network_rule -> {:ok, global_network_rule}
    end
  end

  ##############################################################################
  #
  # get_owner_network_rule
  #
  #

  @spec get_owner_network_rule(Ecto.UUID.t()) ::
          {:ok, Msdata.SystOwnerNetworkRules.t()} | {:error, term()}
  def get_owner_network_rule(owner_network_rule_id) do
    from(onr in Msdata.SystOwnerNetworkRules, where: onr.id == ^owner_network_rule_id)
    |> MscmpSystDb.one()
    |> case do
      nil -> {:error, {:not_found, owner_network_rule_id}}
      owner_network_rule -> {:ok, owner_network_rule}
    end
  end

  ##############################################################################
  #
  # get_instance_network_rule
  #
  #

  @spec get_instance_network_rule(Ecto.UUID.t()) ::
          {:ok, Msdata.SystInstanceNetworkRules.t()} | {:error, term()}
  def get_instance_network_rule(instance_network_rule_id) do
    from(inr in Msdata.SystInstanceNetworkRules, where: inr.id == ^instance_network_rule_id)
    |> MscmpSystDb.one()
    |> case do
      nil -> {:error, {:not_found, instance_network_rule_id}}
      instance_network_rule -> {:ok, instance_network_rule}
    end
  end

  ##############################################################################
  #
  # delete_global_network_rule
  #
  #

  @spec delete_global_network_rule(Ecto.UUID.t()) ::
          :ok | {:error, term()}
  def delete_global_network_rule(global_network_rule_id)
      when is_binary(global_network_rule_id) do
    from(gnr in Msdata.SystGlobalNetworkRules, where: gnr.id == ^global_network_rule_id)
    |> MscmpSystDb.delete_all()
    |> case do
      {0, _} -> {:error, {:not_found, global_network_rule_id}}
      {1, _} -> :ok
      cause -> {:error, {:database_error, cause}}
    end
  end

  ##############################################################################
  #
  # delete_owner_network_rule
  #
  #

  @spec delete_owner_network_rule(Ecto.UUID.t()) ::
          :ok | {:error, term()}
  def delete_owner_network_rule(owner_network_rule_id) do
    from(onr in Msdata.SystOwnerNetworkRules, where: onr.id == ^owner_network_rule_id)
    |> MscmpSystDb.delete_all()
    |> case do
      {0, _} -> {:error, {:not_found, owner_network_rule_id}}
      {1, _} -> :ok
      cause -> {:error, {:database_error, cause}}
    end
  end

  ##############################################################################
  #
  # delete_instance_network_rule
  #
  #

  @spec delete_instance_network_rule(Ecto.UUID.t()) ::
          :ok | {:error, term()}
  def delete_instance_network_rule(instance_network_rule_id) do
    from(inr in Msdata.SystInstanceNetworkRules, where: inr.id == ^instance_network_rule_id)
    |> MscmpSystDb.delete_all()
    |> case do
      {0, _} -> {:error, {:not_found, instance_network_rule_id}}
      {1, _} -> :ok
      cause -> {:error, {:database_error, cause}}
    end
  end

  ##############################################################################
  #
  # General use private functions
  #
  #

  defp maybe_convert_params_net_addresses(network_rule_params) do
    network_rule_params
    |> Map.put(
      :ip_host_or_network,
      convert_net_address_to_inet(network_rule_params[:ip_host_or_network])
    )
    |> Map.put(
      :ip_host_range_lower,
      convert_net_address_to_inet(network_rule_params[:ip_host_range_lower])
    )
    |> Map.put(
      :ip_host_range_upper,
      convert_net_address_to_inet(network_rule_params[:ip_host_range_upper])
    )
  end

  defp convert_net_address_to_inet(%DbTypes.Inet{} = address), do: address

  defp convert_net_address_to_inet(address) when is_ip(address),
    do: DbTypes.Inet.from_net_address(address)

  defp convert_net_address_to_inet(_), do: nil
end
