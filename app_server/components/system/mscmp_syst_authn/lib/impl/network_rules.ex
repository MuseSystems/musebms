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

  import Ecto.Query

  alias MscmpSystAuthn.Types
  alias MscmpSystDb.DbTypes

  require IP
  require IP.Subnet
  require Logger

  @spec host_disallowed(Types.host_address()) ::
          {:ok, boolean()} | {:error, MscmpSystError.t() | Exception.t()}
  def host_disallowed(host_addr) when is_tuple(host_addr) do
    {:ok, host_disallowed?(host_addr)}
  rescue
    error -> {:error, error}
  end

  @spec host_disallowed?(Types.host_address()) :: boolean()
  def host_disallowed?(host_addr) when is_tuple(host_addr) do
    target_host = %DbTypes.Inet{address: host_addr}

    from(dh in Msdata.SystDisallowedHosts, where: dh.host_address == ^target_host)
    |> MscmpSystDb.exists?()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      reraise MscmpSystError,
        code: :undefined_error,
        message: "Failure checking if host disallowed.",
        cause: error
  end

  @spec create_disallowed_host(Types.host_address()) ::
          {:ok, Msdata.SystDisallowedHosts.t()} | {:error, MscmpSystError.t()}
  def create_disallowed_host(host_addr) when is_tuple(host_addr) do
    target_host = %DbTypes.Inet{address: host_addr}

    Msdata.SystDisallowedHosts.insert_changeset(target_host)
    |> MscmpSystDb.insert!(returning: true)
    |> then(&{:ok, if(&1.id == nil, do: nil, else: &1)})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure creating Disallowed Host.",
         cause: error
       }}
  end

  @spec delete_disallowed_host_addr(Types.host_address()) ::
          {:ok, :deleted | :not_found} | {:error, MscmpSystError.t() | Exception.t()}
  def delete_disallowed_host_addr(host_addr) when not is_nil(host_addr) do
    {:ok, delete_disallowed_host_addr!(host_addr)}
  rescue
    error -> {:error, error}
  end

  @spec delete_disallowed_host_addr!(Types.host_address()) :: :deleted | :not_found
  def delete_disallowed_host_addr!(host_addr) when not is_nil(host_addr) do
    target_host = %DbTypes.Inet{address: host_addr}

    from(dh in Msdata.SystDisallowedHosts, where: dh.host_address == ^target_host)
    |> process_disallowed_host_delete()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      reraise MscmpSystError,
        code: :undefined_error,
        message: "Failure deleting Disallowed Host by host IP address.",
        cause: error
  end

  @spec delete_disallowed_host(Types.disallowed_host_id() | Msdata.SystDisallowedHosts.t()) ::
          {:ok, :deleted | :not_found} | {:error, MscmpSystError.t() | Exception.t()}
  def delete_disallowed_host(disallowed_host) do
    {:ok, delete_disallowed_host!(disallowed_host)}
  rescue
    error -> {:error, error}
  end

  @spec delete_disallowed_host!(Types.disallowed_host_id() | Msdata.SystDisallowedHosts.t()) ::
          :deleted | :not_found
  def delete_disallowed_host!(%Msdata.SystDisallowedHosts{} = disallowed_host) do
    from(dh in Msdata.SystDisallowedHosts, where: dh.id == ^disallowed_host.id)
    |> process_disallowed_host_delete()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      reraise MscmpSystError,
        code: :undefined_error,
        message: "Failure deleting Disallowed Host.",
        cause: error
  end

  def delete_disallowed_host!(disallowed_host_id) when is_binary(disallowed_host_id) do
    from(dh in Msdata.SystDisallowedHosts, where: dh.id == ^disallowed_host_id)
    |> process_disallowed_host_delete()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      reraise MscmpSystError,
        code: :undefined_error,
        message: "Failure deleting Disallowed Host by ID.",
        cause: error
  end

  defp process_disallowed_host_delete(query) do
    query
    |> MscmpSystDb.delete_all()
    |> case do
      {0, _} ->
        :not_found

      {1, _} ->
        :deleted

      cause ->
        raise MscmpSystError,
          code: :undefined_error,
          message: "Failure deleting Disallowed Host by ID.",
          cause: cause
    end
  end

  @spec get_disallowed_host_record_by_id(Types.disallowed_host_id()) ::
          {:ok, Msdata.SystDisallowedHosts.t()} | {:error, MscmpSystError.t() | Exception.t()}
  def get_disallowed_host_record_by_id(disallowed_host_id) when is_binary(disallowed_host_id) do
    {:ok, get_disallowed_host_record_by_id!(disallowed_host_id)}
  rescue
    error -> {:error, error}
  end

  @spec get_disallowed_host_record_by_id!(Types.disallowed_host_id()) ::
          Msdata.SystDisallowedHosts.t()
  def get_disallowed_host_record_by_id!(disallowed_host_id) when is_binary(disallowed_host_id) do
    from(dh in Msdata.SystDisallowedHosts, where: dh.id == ^disallowed_host_id)
    |> MscmpSystDb.one!()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      reraise MscmpSystError,
        code: :undefined_error,
        message: "Failure retrieving Disallowed Host by ID.",
        cause: error
  end

  @spec get_disallowed_host_record_by_host(Types.host_address()) ::
          {:ok, Msdata.SystDisallowedHosts.t() | nil}
          | {:error, MscmpSystError.t() | Exception.t()}
  def get_disallowed_host_record_by_host(host_addr) when is_tuple(host_addr) do
    {:ok, get_disallowed_host_record_by_host!(host_addr)}
  rescue
    error -> {:error, error}
  end

  @spec get_disallowed_host_record_by_host!(Types.host_address()) ::
          Msdata.SystDisallowedHosts.t() | nil
  def get_disallowed_host_record_by_host!(host_addr) when is_tuple(host_addr) do
    target_host = %DbTypes.Inet{address: host_addr}

    from(dh in Msdata.SystDisallowedHosts, where: dh.host_address == ^target_host)
    |> MscmpSystDb.one()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      reraise MscmpSystError,
        code: :undefined_error,
        message: "Failure retrieving Disallowed Host by host IP address.",
        cause: error
  end

  @spec get_applied_network_rule(
          Types.host_address(),
          MscmpSystInstance.Types.instance_id() | nil,
          MscmpSystInstance.Types.owner_id() | nil
        ) :: {:ok, Types.applied_network_rule()} | {:error, MscmpSystError.t() | Exception.t()}
  def get_applied_network_rule(host_addr, instance_id \\ nil, instance_owner_id \\ nil)
      when is_tuple(host_addr) do
    {:ok, get_applied_network_rule!(host_addr, instance_id, instance_owner_id)}
  rescue
    error -> {:error, error}
  end

  @spec get_applied_network_rule!(
          Types.host_address(),
          MscmpSystInstance.Types.instance_id() | nil,
          MscmpSystInstance.Types.owner_id() | nil
        ) :: Types.applied_network_rule()
  def get_applied_network_rule!(host_addr, instance_id \\ nil, instance_owner_id \\ nil)
      when is_tuple(host_addr) do
    target_host = %DbTypes.Inet{address: host_addr} |> DbTypes.Inet.to_postgrex_inet()

    target_instance_id =
      case instance_id do
        nil -> nil
        :bypass -> nil
        instance_id -> Ecto.UUID.dump!(instance_id)
      end

    target_owner_id =
      if instance_owner_id != nil, do: Ecto.UUID.dump!(instance_owner_id), else: nil

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
    |> MscmpSystDb.one!()
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

      reraise MscmpSystError,
        code: :undefined_error,
        message: "Failure retrieving Applied Network Rule.",
        cause: error
  end

  @spec create_global_network_rule(Types.global_network_rule_params()) ::
          {:ok, Msdata.SystGlobalNetworkRules.t()} | {:error, MscmpSystError.t()}
  def create_global_network_rule(insert_params) do
    insert_params
    |> maybe_convert_params_net_addresses()
    |> Msdata.SystGlobalNetworkRules.insert_changeset()
    |> MscmpSystDb.insert!(returning: true)
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure creating Global Network Rule.",
         cause: error
       }}
  end

  @spec create_owner_network_rule(
          MscmpSystInstance.Types.owner_id(),
          Types.owner_network_rule_params()
        ) ::
          {:ok, Msdata.SystOwnerNetworkRules.t()} | {:error, MscmpSystError.t()}
  def create_owner_network_rule(owner_id, insert_params) when is_binary(owner_id) do
    insert_params
    |> maybe_convert_params_net_addresses()
    |> Map.put(:owner_id, owner_id)
    |> Msdata.SystOwnerNetworkRules.insert_changeset()
    |> MscmpSystDb.insert!(returning: true)
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure creating Owner Network Rule.",
         cause: error
       }}
  end

  @spec create_instance_network_rule(
          MscmpSystInstance.Types.instance_id(),
          Types.instance_network_rule_params()
        ) ::
          {:ok, Msdata.SystInstanceNetworkRules.t()} | {:error, MscmpSystError.t()}
  def create_instance_network_rule(instance_id, insert_params) when is_binary(instance_id) do
    insert_params
    |> maybe_convert_params_net_addresses()
    |> Map.put(:instance_id, instance_id)
    |> Msdata.SystInstanceNetworkRules.insert_changeset()
    |> MscmpSystDb.insert!(returning: true)
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {:error,
       %MscmpSystError{
         code: :undefined_error,
         message: "Failure creating Owner Network Rule.",
         cause: error
       }}
  end

  @spec update_global_network_rule(
          Ecto.UUID.t() | Msdata.SystGlobalNetworkRules.t(),
          Types.global_network_rule_params()
        ) ::
          {:ok, Msdata.SystGlobalNetworkRules.t()} | {:error, MscmpSystError.t() | Exception.t()}
  def update_global_network_rule(global_network_rule, update_params) do
    {:ok, update_global_network_rule!(global_network_rule, update_params)}
  rescue
    error -> {:error, error}
  end

  @spec update_global_network_rule!(
          Ecto.UUID.t() | Msdata.SystGlobalNetworkRules.t(),
          Types.global_network_rule_params()
        ) :: Msdata.SystGlobalNetworkRules.t()
  def update_global_network_rule!(global_network_rule_id, update_params)
      when is_binary(global_network_rule_id) do
    global_network_rule_id
    |> get_global_network_rule!()
    |> update_global_network_rule!(update_params)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      reraise MscmpSystError,
        code: :undefined_error,
        message: "Failure retrieving or updating Global Network Rule.",
        cause: error
  end

  def update_global_network_rule!(
        %Msdata.SystGlobalNetworkRules{} = global_network_rule,
        update_params
      ) do
    resolved_params = maybe_convert_params_net_addresses(update_params)

    global_network_rule
    |> Msdata.SystGlobalNetworkRules.update_changeset(resolved_params)
    |> MscmpSystDb.update!(returning: true)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      reraise MscmpSystError,
        code: :undefined_error,
        message: "Failure updating Global Network Rule.",
        cause: error
  end

  @spec update_owner_network_rule(
          Ecto.UUID.t() | Msdata.SystOwnerNetworkRules.t(),
          Types.owner_network_rule_params()
        ) ::
          {:ok, Msdata.SystOwnerNetworkRules.t()} | {:error, MscmpSystError.t() | Exception.t()}
  def update_owner_network_rule(owner_network_rule, update_params) do
    {:ok, update_owner_network_rule!(owner_network_rule, update_params)}
  rescue
    error -> {:error, error}
  end

  @spec update_owner_network_rule!(
          Ecto.UUID.t() | Msdata.SystOwnerNetworkRules.t(),
          Types.owner_network_rule_params()
        ) :: Msdata.SystOwnerNetworkRules.t()
  def update_owner_network_rule!(owner_network_rule_id, update_params)
      when is_binary(owner_network_rule_id) do
    owner_network_rule_id
    |> get_owner_network_rule!()
    |> update_owner_network_rule!(update_params)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      reraise MscmpSystError,
        code: :undefined_error,
        message: "Failure retrieving or updating Owner Network Rule.",
        cause: error
  end

  def update_owner_network_rule!(
        %Msdata.SystOwnerNetworkRules{} = owner_network_rule,
        update_params
      ) do
    resolved_params = maybe_convert_params_net_addresses(update_params)

    owner_network_rule
    |> Msdata.SystOwnerNetworkRules.update_changeset(resolved_params)
    |> MscmpSystDb.update!(returning: true)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      reraise MscmpSystError,
        code: :undefined_error,
        message: "Failure updating Owner Network Rule.",
        cause: error
  end

  @spec update_instance_network_rule(
          Ecto.UUID.t() | Msdata.SystInstanceNetworkRules.t(),
          Types.instance_network_rule_params()
        ) ::
          {:ok, Msdata.SystInstanceNetworkRules.t()}
          | {:error, MscmpSystError.t() | Exception.t()}
  def update_instance_network_rule(instance_network_rule, update_params) do
    {:ok, update_instance_network_rule!(instance_network_rule, update_params)}
  rescue
    error -> {:error, error}
  end

  @spec update_instance_network_rule!(
          Ecto.UUID.t() | Msdata.SystInstanceNetworkRules.t(),
          Types.instance_network_rule_params()
        ) :: Msdata.SystInstanceNetworkRules.t()
  def update_instance_network_rule!(instance_network_rule_id, update_params)
      when is_binary(instance_network_rule_id) do
    instance_network_rule_id
    |> get_instance_network_rule!()
    |> update_instance_network_rule!(update_params)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      reraise MscmpSystError,
        code: :undefined_error,
        message: "Failure retrieving or updating Instance Network Rule.",
        cause: error
  end

  def update_instance_network_rule!(
        %Msdata.SystInstanceNetworkRules{} = instance_network_rule,
        update_params
      ) do
    resolved_params = maybe_convert_params_net_addresses(update_params)

    instance_network_rule
    |> Msdata.SystInstanceNetworkRules.update_changeset(resolved_params)
    |> MscmpSystDb.update!(returning: true)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      reraise MscmpSystError,
        code: :undefined_error,
        message: "Failure updating Instance Network Rule.",
        cause: error
  end

  @spec get_global_network_rule(Ecto.UUID.t()) ::
          {:ok, Msdata.SystGlobalNetworkRules.t()}
          | {:ok, :not_found}
          | {:error, MscmpSystError.t() | Exception.t()}
  def get_global_network_rule(global_network_rule_id) do
    {:ok, get_global_network_rule!(global_network_rule_id)}
  rescue
    error -> {:error, error}
  end

  @spec get_global_network_rule!(Ecto.UUID.t()) :: Msdata.SystGlobalNetworkRules.t() | :not_found
  def get_global_network_rule!(global_network_rule_id) do
    db_result =
      from(gnr in Msdata.SystGlobalNetworkRules, where: gnr.id == ^global_network_rule_id)
      |> MscmpSystDb.one()

    if db_result == nil, do: :not_found, else: db_result
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      reraise MscmpSystError,
        code: :undefined_error,
        message: "Failure retrieving Global Network Rule.",
        cause: error
  end

  @spec get_owner_network_rule(Ecto.UUID.t()) ::
          {:ok, Msdata.SystOwnerNetworkRules.t()}
          | {:ok, :not_found}
          | {:error, MscmpSystError.t() | Exception.t()}
  def get_owner_network_rule(owner_network_rule_id) do
    {:ok, get_owner_network_rule!(owner_network_rule_id)}
  rescue
    error -> {:error, error}
  end

  @spec get_owner_network_rule!(Ecto.UUID.t()) :: Msdata.SystOwnerNetworkRules.t() | :not_found
  def get_owner_network_rule!(owner_network_rule_id) do
    db_result =
      from(onr in Msdata.SystOwnerNetworkRules, where: onr.id == ^owner_network_rule_id)
      |> MscmpSystDb.one()

    if db_result == nil, do: :not_found, else: db_result
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      reraise MscmpSystError,
        code: :undefined_error,
        message: "Failure retrieving Owner Network Rule.",
        cause: error
  end

  @spec get_instance_network_rule(Ecto.UUID.t()) ::
          {:ok, Msdata.SystInstanceNetworkRules.t()}
          | {:ok, :not_found}
          | {:error, MscmpSystError.t() | Exception.t()}
  def get_instance_network_rule(instance_network_rule_id) do
    {:ok, get_instance_network_rule!(instance_network_rule_id)}
  rescue
    error -> {:error, error}
  end

  @spec get_instance_network_rule!(Ecto.UUID.t()) ::
          Msdata.SystInstanceNetworkRules.t() | :not_found
  def get_instance_network_rule!(instance_network_rule_id) do
    db_result =
      from(inr in Msdata.SystInstanceNetworkRules, where: inr.id == ^instance_network_rule_id)
      |> MscmpSystDb.one()

    if db_result == nil, do: :not_found, else: db_result
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      reraise MscmpSystError,
        code: :undefined_error,
        message: "Failure retrieving Instance Network Rule.",
        cause: error
  end

  @spec delete_global_network_rule(Ecto.UUID.t()) ::
          :ok | {:error, MscmpSystError.t() | Exception.t()}
  def delete_global_network_rule(global_network_rule_id) do
    delete_global_network_rule!(global_network_rule_id)
  rescue
    error -> {:error, error}
  end

  @spec delete_global_network_rule!(Ecto.UUID.t()) :: :ok
  def delete_global_network_rule!(global_network_rule_id)
      when is_binary(global_network_rule_id) do
    from(gnr in Msdata.SystGlobalNetworkRules, where: gnr.id == ^global_network_rule_id)
    |> MscmpSystDb.delete_all()

    :ok
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      reraise MscmpSystError,
        code: :undefined_error,
        message: "Failure deleting Global Network Rule by record ID.",
        cause: error
  end

  @spec delete_owner_network_rule(Ecto.UUID.t()) ::
          :ok | {:error, MscmpSystError.t() | Exception.t()}
  def delete_owner_network_rule(owner_network_rule_id) do
    delete_owner_network_rule!(owner_network_rule_id)
  rescue
    error -> {:error, error}
  end

  @spec delete_owner_network_rule!(Ecto.UUID.t()) :: :ok
  def delete_owner_network_rule!(owner_network_rule_id) when is_binary(owner_network_rule_id) do
    from(gnr in Msdata.SystOwnerNetworkRules, where: gnr.id == ^owner_network_rule_id)
    |> MscmpSystDb.delete_all()

    :ok
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      reraise MscmpSystError,
        code: :undefined_error,
        message: "Failure deleting Owner Network Rule by record ID.",
        cause: error
  end

  @spec delete_instance_network_rule(Ecto.UUID.t()) ::
          :ok | {:error, MscmpSystError.t() | Exception.t()}
  def delete_instance_network_rule(instance_network_rule_id) do
    delete_instance_network_rule!(instance_network_rule_id)
  rescue
    error -> {:error, error}
  end

  @spec delete_instance_network_rule!(Ecto.UUID.t()) :: :ok
  def delete_instance_network_rule!(instance_network_rule_id)
      when is_binary(instance_network_rule_id) do
    from(gnr in Msdata.SystInstanceNetworkRules, where: gnr.id == ^instance_network_rule_id)
    |> MscmpSystDb.delete_all()

    :ok
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      reraise MscmpSystError,
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
