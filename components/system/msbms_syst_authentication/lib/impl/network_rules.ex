# Source File: network_rules.ex
# Location:    musebms/components/system/msbms_syst_authentication/lib/impl/network_rules.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystAuthentication.Impl.NetworkRules do
  import Ecto.Query

  alias MsbmsSystAuthentication.Data
  alias MsbmsSystAuthentication.Types
  alias MsbmsSystDatastore.DbTypes

  require IP
  require IP.Subnet
  require Logger

  @moduledoc false

  @spec host_disallowed(Types.host_address()) ::
          {:ok, boolean()} | {:error, MsbmsSystError.t() | Exception.t()}
  def host_disallowed(host_addr) when is_tuple(host_addr) do
    {:ok, host_disallowed?(host_addr)}
  rescue
    error -> {:error, error}
  end

  @spec host_disallowed?(Types.host_address()) :: boolean()
  def host_disallowed?(host_addr) when is_tuple(host_addr) do
    target_host = %DbTypes.Inet{address: host_addr}

    from(dh in Data.SystDisallowedHosts, where: dh.host_address == ^target_host)
    |> MsbmsSystDatastore.exists?()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      reraise MsbmsSystError,
        code: :undefined_error,
        message: "Failure checking if host disallowed.",
        cause: error
  end

  @spec create_disallowed_host(Types.host_address()) ::
          {:ok, Data.SystDisallowedHosts.t()} | {:error, MsbmsSystError.t({})}
  def create_disallowed_host(host_addr) when is_tuple(host_addr) do
    target_host = %DbTypes.Inet{address: host_addr}

    Data.SystDisallowedHosts.insert_changeset(target_host)
    |> MsbmsSystDatastore.insert!(returning: true)
    |> then(&{:ok, if(&1.id == nil, do: nil, else: &1)})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MsbmsSystError{
         code: :undefined_error,
         message: "Failure creating Disallowed Host.",
         cause: error
       }}
  end

  @spec delete_disallowed_host_addr(Types.host_address()) ::
          {:ok, :deleted | :not_found} | {:error, MsbmsSystError.t() | Exception.t()}
  def delete_disallowed_host_addr(host_addr) when not is_nil(host_addr) do
    {:ok, delete_disallowed_host_addr!(host_addr)}
  rescue
    error -> {:error, error}
  end

  @spec delete_disallowed_host_addr!(Types.host_address()) :: :deleted | :not_found
  def delete_disallowed_host_addr!(host_addr) when not is_nil(host_addr) do
    target_host = %DbTypes.Inet{address: host_addr}

    from(dh in Data.SystDisallowedHosts, where: dh.host_address == ^target_host)
    |> process_disallowed_host_delete()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      reraise MsbmsSystError,
        code: :undefined_error,
        message: "Failure deleting Disallowed Host by host IP address.",
        cause: error
  end

  @spec delete_disallowed_host(Types.disallowed_host_id() | Data.SystDisallowedHosts.t()) ::
          {:ok, :deleted | :not_found} | {:error, MsbmsSystError.t() | Exception.t()}
  def delete_disallowed_host(disallowed_host) do
    {:ok, delete_disallowed_host!(disallowed_host)}
  rescue
    error -> {:error, error}
  end

  @spec delete_disallowed_host!(Types.disallowed_host_id() | Data.SystDisallowedHosts.t()) ::
          :deleted | :not_found
  def delete_disallowed_host!(%Data.SystDisallowedHosts{} = disallowed_host) do
    from(dh in Data.SystDisallowedHosts, where: dh.id == ^disallowed_host.id)
    |> process_disallowed_host_delete()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      reraise MsbmsSystError,
        code: :undefined_error,
        message: "Failure deleting Disallowed Host.",
        cause: error
  end

  def delete_disallowed_host!(disallowed_host_id) when is_binary(disallowed_host_id) do
    from(dh in Data.SystDisallowedHosts, where: dh.id == ^disallowed_host_id)
    |> process_disallowed_host_delete()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      reraise MsbmsSystError,
        code: :undefined_error,
        message: "Failure deleting Disallowed Host by ID.",
        cause: error
  end

  defp process_disallowed_host_delete(query) do
    query
    |> MsbmsSystDatastore.delete_all()
    |> case do
      {0, _} ->
        :not_found

      {1, _} ->
        :deleted

      cause ->
        raise MsbmsSystError,
          code: :undefined_error,
          message: "Failure deleting Disallowed Host by ID.",
          cause: cause
    end
  end

  @spec get_disallowed_host_record_by_id(Types.disallowed_host_id()) ::
          {:ok, Data.SystDisallowedHosts.t()} | {:error, MsbmsSystError.t() | Exception.t()}
  def get_disallowed_host_record_by_id(disallowed_host_id) when is_binary(disallowed_host_id) do
    {:ok, get_disallowed_host_record_by_id!(disallowed_host_id)}
  rescue
    error -> {:error, error}
  end

  @spec get_disallowed_host_record_by_id!(Types.disallowed_host_id()) ::
          Data.SystDisallowedHosts.t()
  def get_disallowed_host_record_by_id!(disallowed_host_id) when is_binary(disallowed_host_id) do
    from(dh in Data.SystDisallowedHosts, where: dh.id == ^disallowed_host_id)
    |> MsbmsSystDatastore.one!()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      reraise MsbmsSystError,
        code: :undefined_error,
        message: "Failure retrieving Disallowed Host by ID.",
        cause: error
  end

  @spec get_disallowed_host_record_by_host(Types.host_address()) ::
          {:ok, Data.SystDisallowedHosts.t() | nil} | {:error, MsbmsSystError.t() | Exception.t()}
  def get_disallowed_host_record_by_host(host_addr) when is_tuple(host_addr) do
    {:ok, get_disallowed_host_record_by_host!(host_addr)}
  rescue
    error -> {:error, error}
  end

  @spec get_disallowed_host_record_by_host!(Types.host_address()) ::
          Data.SystDisallowedHosts.t() | nil
  def get_disallowed_host_record_by_host!(host_addr) when is_tuple(host_addr) do
    target_host = %DbTypes.Inet{address: host_addr}

    from(dh in Data.SystDisallowedHosts, where: dh.host_address == ^target_host)
    |> MsbmsSystDatastore.one()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      reraise MsbmsSystError,
        code: :undefined_error,
        message: "Failure retrieving Disallowed Host by host IP address.",
        cause: error
  end

  @spec get_applied_network_rule(
          Types.host_address(),
          MsbmsSystInstanceMgr.Types.instance_id() | nil,
          MsbmsSystInstanceMgr.Types.owner_id() | nil
        ) :: {:ok, Types.applied_network_rule()} | {:error, MsbmsSystError.t() | Exception.t()}
  def get_applied_network_rule(host_addr, instance_id \\ nil, instance_owner_id \\ nil)
      when is_tuple(host_addr) do
    {:ok, get_applied_network_rule!(host_addr, instance_id, instance_owner_id)}
  rescue
    error -> {:error, error}
  end

  @spec get_applied_network_rule!(
          Types.host_address(),
          MsbmsSystInstanceMgr.Types.instance_id() | nil,
          MsbmsSystInstanceMgr.Types.owner_id() | nil
        ) :: Types.applied_network_rule()
  def get_applied_network_rule!(host_addr, instance_id \\ nil, instance_owner_id \\ nil)
      when is_tuple(host_addr) do
    target_host = %DbTypes.Inet{address: host_addr} |> DbTypes.Inet.to_postgrex_inet()
    target_instance_id = if instance_id != nil, do: Ecto.UUID.dump!(instance_id), else: nil

    target_owner_id =
      if instance_owner_id != nil, do: Ecto.UUID.dump!(instance_owner_id), else: nil

    from(
      nr in fragment(
        "msbms_syst.get_applied_network_rule(?, ?, ?)",
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
    |> MsbmsSystDatastore.one!()
    |> then(
      &%{
        precedence: String.to_atom(&1.precedence),
        network_rule_id:
          if(&1.network_rule_id != nil, do: Ecto.UUID.cast!(&1.network_rule_id), else: nil),
        functional_type: String.to_atom(&1.functional_type)
      }
    )
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      reraise MsbmsSystError,
        code: :undefined_error,
        message: "Failure retrieving Applied Network Rule.",
        cause: error
  end

  @spec create_global_network_rule(Types.global_network_rule_params()) ::
          {:ok, Data.SystGlobalNetworkRules.t()} | {:error, MsbmsSystError.t()}
  def create_global_network_rule(insert_params) do
    insert_params
    |> maybe_convert_params_net_addresses()
    |> Data.SystGlobalNetworkRules.insert_changeset()
    |> MsbmsSystDatastore.insert!(returning: true)
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MsbmsSystError{
         code: :undefined_error,
         message: "Failure creating Global Network Rule.",
         cause: error
       }}
  end

  @spec create_owner_network_rule(
          MsbmsSystInstanceMgr.Types.owner_id(),
          Types.owner_network_rule_params()
        ) ::
          {:ok, Data.SystOwnerNetworkRules.t()} | {:error, MsbmsSystError.t()}
  def create_owner_network_rule(owner_id, insert_params) when is_binary(owner_id) do
    insert_params
    |> maybe_convert_params_net_addresses()
    |> Map.put(:owner_id, owner_id)
    |> Data.SystOwnerNetworkRules.insert_changeset()
    |> MsbmsSystDatastore.insert!(returning: true)
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MsbmsSystError{
         code: :undefined_error,
         message: "Failure creating Owner Network Rule.",
         cause: error
       }}
  end

  @spec create_instance_network_rule(
          MsbmsSystInstanceMgr.Types.instance_id(),
          Types.instance_network_rule_params()
        ) ::
          {:ok, Data.SystInstanceNetworkRules.t()} | {:error, MsbmsSystError.t()}
  def create_instance_network_rule(instance_id, insert_params) when is_binary(instance_id) do
    insert_params
    |> maybe_convert_params_net_addresses()
    |> Map.put(:instance_id, instance_id)
    |> Data.SystInstanceNetworkRules.insert_changeset()
    |> MsbmsSystDatastore.insert!(returning: true)
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MsbmsSystError{
         code: :undefined_error,
         message: "Failure creating Owner Network Rule.",
         cause: error
       }}
  end

  @spec update_global_network_rule(
          Ecto.UUID.t() | Data.SystGlobalNetworkRules.t(),
          Types.global_network_rule_params()
        ) :: {:ok, Data.SystGlobalNetworkRules.t()} | {:error, MsbmsSystError.t() | Exception.t()}
  def update_global_network_rule(global_network_rule, update_params) do
    {:ok, update_global_network_rule!(global_network_rule, update_params)}
  rescue
    error -> {:error, error}
  end

  @spec update_global_network_rule!(
          Ecto.UUID.t() | Data.SystGlobalNetworkRules.t(),
          Types.global_network_rule_params()
        ) :: Data.SystGlobalNetworkRules.t()
  def update_global_network_rule!(global_network_rule_id, update_params)
      when is_binary(global_network_rule_id) do
    global_network_rule_id
    |> get_global_network_rule!()
    |> update_global_network_rule!(update_params)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      reraise MsbmsSystError,
        code: :undefined_error,
        message: "Failure retrieving or updating Global Network Rule.",
        cause: error
  end

  def update_global_network_rule!(
        %Data.SystGlobalNetworkRules{} = global_network_rule,
        update_params
      ) do
    resolved_params = maybe_convert_params_net_addresses(update_params)

    global_network_rule
    |> Data.SystGlobalNetworkRules.update_changeset(resolved_params)
    |> MsbmsSystDatastore.update!(returning: true)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      reraise MsbmsSystError,
        code: :undefined_error,
        message: "Failure updating Global Network Rule.",
        cause: error
  end

  @spec update_owner_network_rule(
          Ecto.UUID.t() | Data.SystOwnerNetworkRules.t(),
          Types.owner_network_rule_params()
        ) :: {:ok, Data.SystOwnerNetworkRules.t()} | {:error, MsbmsSystError.t() | Exception.t()}
  def update_owner_network_rule(owner_network_rule, update_params) do
    {:ok, update_owner_network_rule!(owner_network_rule, update_params)}
  rescue
    error -> {:error, error}
  end

  @spec update_owner_network_rule!(
          Ecto.UUID.t() | Data.SystOwnerNetworkRules.t(),
          Types.owner_network_rule_params()
        ) :: Data.SystOwnerNetworkRules.t()
  def update_owner_network_rule!(owner_network_rule_id, update_params)
      when is_binary(owner_network_rule_id) do
    owner_network_rule_id
    |> get_owner_network_rule!()
    |> update_owner_network_rule!(update_params)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      reraise MsbmsSystError,
        code: :undefined_error,
        message: "Failure retrieving or updating Owner Network Rule.",
        cause: error
  end

  def update_owner_network_rule!(
        %Data.SystOwnerNetworkRules{} = owner_network_rule,
        update_params
      ) do
    resolved_params = maybe_convert_params_net_addresses(update_params)

    owner_network_rule
    |> Data.SystOwnerNetworkRules.update_changeset(resolved_params)
    |> MsbmsSystDatastore.update!(returning: true)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      reraise MsbmsSystError,
        code: :undefined_error,
        message: "Failure updating Owner Network Rule.",
        cause: error
  end

  @spec update_instance_network_rule(
          Ecto.UUID.t() | Data.SystInstanceNetworkRules.t(),
          Types.instance_network_rule_params()
        ) ::
          {:ok, Data.SystInstanceNetworkRules.t()} | {:error, MsbmsSystError.t() | Exception.t()}
  def update_instance_network_rule(instance_network_rule, update_params) do
    {:ok, update_instance_network_rule!(instance_network_rule, update_params)}
  rescue
    error -> {:error, error}
  end

  @spec update_instance_network_rule!(
          Ecto.UUID.t() | Data.SystInstanceNetworkRules.t(),
          Types.instance_network_rule_params()
        ) :: Data.SystInstanceNetworkRules.t()
  def update_instance_network_rule!(instance_network_rule_id, update_params)
      when is_binary(instance_network_rule_id) do
    instance_network_rule_id
    |> get_instance_network_rule!()
    |> update_instance_network_rule!(update_params)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      reraise MsbmsSystError,
        code: :undefined_error,
        message: "Failure retrieving or updating Instance Network Rule.",
        cause: error
  end

  def update_instance_network_rule!(
        %Data.SystInstanceNetworkRules{} = instance_network_rule,
        update_params
      ) do
    resolved_params = maybe_convert_params_net_addresses(update_params)

    instance_network_rule
    |> Data.SystInstanceNetworkRules.update_changeset(resolved_params)
    |> MsbmsSystDatastore.update!(returning: true)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      reraise MsbmsSystError,
        code: :undefined_error,
        message: "Failure updating Instance Network Rule.",
        cause: error
  end

  @spec get_global_network_rule(Ecto.UUID.t()) ::
          {:ok, Data.SystGlobalNetworkRules.t()}
          | {:ok, :not_found}
          | {:error, MsbmsSystError.t() | Exception.t()}
  def get_global_network_rule(global_network_rule_id) do
    {:ok, get_global_network_rule!(global_network_rule_id)}
  rescue
    error -> {:error, error}
  end

  @spec get_global_network_rule!(Ecto.UUID.t()) :: Data.SystGlobalNetworkRules.t() | :not_found
  def get_global_network_rule!(global_network_rule_id) do
    db_result =
      from(gnr in Data.SystGlobalNetworkRules, where: gnr.id == ^global_network_rule_id)
      |> MsbmsSystDatastore.one()

    if db_result == nil, do: :not_found, else: db_result
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      reraise MsbmsSystError,
        code: :undefined_error,
        message: "Failure retrieving Global Network Rule.",
        cause: error
  end

  @spec get_owner_network_rule(Ecto.UUID.t()) ::
          {:ok, Data.SystOwnerNetworkRules.t()}
          | {:ok, :not_found}
          | {:error, MsbmsSystError.t() | Exception.t()}
  def get_owner_network_rule(owner_network_rule_id) do
    {:ok, get_owner_network_rule!(owner_network_rule_id)}
  rescue
    error -> {:error, error}
  end

  @spec get_owner_network_rule!(Ecto.UUID.t()) :: Data.SystOwnerNetworkRules.t() | :not_found
  def get_owner_network_rule!(owner_network_rule_id) do
    db_result =
      from(onr in Data.SystOwnerNetworkRules, where: onr.id == ^owner_network_rule_id)
      |> MsbmsSystDatastore.one()

    if db_result == nil, do: :not_found, else: db_result
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      reraise MsbmsSystError,
        code: :undefined_error,
        message: "Failure retrieving Owner Network Rule.",
        cause: error
  end

  @spec get_instance_network_rule(Ecto.UUID.t()) ::
          {:ok, Data.SystInstanceNetworkRules.t()}
          | {:ok, :not_found}
          | {:error, MsbmsSystError.t() | Exception.t()}
  def get_instance_network_rule(instance_network_rule_id) do
    {:ok, get_instance_network_rule!(instance_network_rule_id)}
  rescue
    error -> {:error, error}
  end

  @spec get_instance_network_rule!(Ecto.UUID.t()) ::
          Data.SystInstanceNetworkRules.t() | :not_found
  def get_instance_network_rule!(instance_network_rule_id) do
    db_result =
      from(inr in Data.SystInstanceNetworkRules, where: inr.id == ^instance_network_rule_id)
      |> MsbmsSystDatastore.one()

    if db_result == nil, do: :not_found, else: db_result
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      reraise MsbmsSystError,
        code: :undefined_error,
        message: "Failure retrieving Instance Network Rule.",
        cause: error
  end

  @spec delete_global_network_rule(Ecto.UUID.t()) ::
          :ok | {:error, MsbmsSystError.t() | Exception.t()}
  def delete_global_network_rule(global_network_rule_id) do
    delete_global_network_rule!(global_network_rule_id)
  rescue
    error -> {:error, error}
  end

  @spec delete_global_network_rule!(Ecto.UUID.t()) :: :ok
  def delete_global_network_rule!(global_network_rule_id)
      when is_binary(global_network_rule_id) do
    from(gnr in Data.SystGlobalNetworkRules, where: gnr.id == ^global_network_rule_id)
    |> MsbmsSystDatastore.delete_all()

    :ok
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      reraise MsbmsSystError,
        code: :undefined_error,
        message: "Failure deleting Global Network Rule by record ID.",
        cause: error
  end

  @spec delete_owner_network_rule(Ecto.UUID.t()) ::
          :ok | {:error, MsbmsSystError.t() | Exception.t()}
  def delete_owner_network_rule(owner_network_rule_id) do
    delete_owner_network_rule!(owner_network_rule_id)
  rescue
    error -> {:error, error}
  end

  @spec delete_owner_network_rule!(Ecto.UUID.t()) :: :ok
  def delete_owner_network_rule!(owner_network_rule_id) when is_binary(owner_network_rule_id) do
    from(gnr in Data.SystOwnerNetworkRules, where: gnr.id == ^owner_network_rule_id)
    |> MsbmsSystDatastore.delete_all()

    :ok
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      reraise MsbmsSystError,
        code: :undefined_error,
        message: "Failure deleting Owner Network Rule by record ID.",
        cause: error
  end

  @spec delete_instance_network_rule(Ecto.UUID.t()) ::
          :ok | {:error, MsbmsSystError.t() | Exception.t()}
  def delete_instance_network_rule(instance_network_rule_id) do
    delete_instance_network_rule!(instance_network_rule_id)
  rescue
    error -> {:error, error}
  end

  @spec delete_instance_network_rule!(Ecto.UUID.t()) :: :ok
  def delete_instance_network_rule!(instance_network_rule_id)
      when is_binary(instance_network_rule_id) do
    from(gnr in Data.SystInstanceNetworkRules, where: gnr.id == ^instance_network_rule_id)
    |> MsbmsSystDatastore.delete_all()

    :ok
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      reraise MsbmsSystError,
        code: :undefined_error,
        message: "Failure deleting Instance Network Rule by record ID.",
        cause: error
  end

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

  defp convert_net_address_to_inet(address)
       when IP.is_ip(address) or IP.Subnet.is_subnet(address),
       do: DbTypes.Inet.from_net_address(address)

  defp convert_net_address_to_inet(_), do: nil
end
