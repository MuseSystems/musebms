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

      raise MsbmsSystError,
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

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure creating Disallowed Host.",
          cause: error
        }
      }
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

      raise MsbmsSystError,
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

      raise MsbmsSystError,
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

      raise MsbmsSystError,
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

      raise MsbmsSystError,
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

      raise MsbmsSystError,
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

      raise MsbmsSystError,
        code: :undefined_error,
        message: "Failure retrieving Applied Network Rule.",
        cause: error
  end
  end
end
