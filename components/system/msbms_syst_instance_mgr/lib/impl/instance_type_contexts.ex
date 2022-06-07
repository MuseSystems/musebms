# Source File: instance_type_contexts.ex
# Location:    components/system/msbms_syst_instance_mgr/lib/impl/instance_type_contexts.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystInstanceMgr.Impl.InstanceTypeContexts do
  import Ecto.Query

  require Logger

  alias MsbmsSystInstanceMgr.Data
  alias MsbmsSystInstanceMgr.Types

  @moduledoc false

  @spec get_instance_type_contexts(
          Keyword.t(
            instance_type_name: Types.instance_type_name() | nil,
            instance_type_id: Ecto.UUID.t() | nil
          )
        ) ::
          {:ok, [Data.SystInstanceTypeContexts.t()]} | {:error, MsbmsSystError.t()}
  def get_instance_type_contexts(opts_given) do
    opts_default = [
      instance_type_name: nil,
      instance_type_id: nil
    ]

    opts = Keyword.merge(opts_given, opts_default, fn _k, v1, _v2 -> v1 end)

    instance_type_context_base_query()
    |> order_by([instance_type: it, application_context: ac], [it.sort_order, ac.display_name])
    |> maybe_add_instance_type_name_filter(opts[:instance_type_name])
    |> maybe_add_instance_type_id_filter(opts[:instance_type_id])
    |> MsbmsSystDatastore.all()
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure retrieving Instance Type Contexts.",
          cause: error
        }
      }
  end

  defp maybe_add_instance_type_name_filter(query, nil), do: query

  defp maybe_add_instance_type_name_filter(query, instance_type_name)
       when is_binary(instance_type_name) do
    from([instance_type: it] in query, where: it.internal_name == ^instance_type_name)
  end

  defp maybe_add_instance_type_id_filter(query, nil), do: query

  defp maybe_add_instance_type_id_filter(query, instance_type_id)
       when is_binary(instance_type_id) do
    from([instance_type: it] in query, where: it.id == ^instance_type_id)
  end

  @spec get_instance_type_context_by_id(Types.instance_type_context_id()) ::
          {:ok, Data.SystApplicationContexts.t()} | {:error, MsbmsSystError.t()}
  def get_instance_type_context_by_id(instance_type_context_id)
      when is_binary(instance_type_context_id) do
    instance_type_context_base_query()
    |> where([instance_type_contexts: itc], itc.id == ^instance_type_context_id)
    |> MsbmsSystDatastore.one!()
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure retrieving Instance Type Context by ID.",
          cause: error
        }
      }
  end

  defp instance_type_context_base_query() do
    from(itc in Data.SystInstanceTypeContexts,
      as: :instance_type_contexts,
      join: it in assoc(itc, :instance_type),
      as: :instance_type,
      join: ac in assoc(itc, :application_context),
      as: :application_context,
      preload: [instance_type: it, application_context: ac]
    )
  end

  @spec set_instance_type_context_db_pool_size(
          Types.instance_type_context_id(),
          non_neg_integer()
        ) ::
          {:ok, Data.SystInstanceTypeContexts.t()} | {:error, MsbmsSystError.t()}
  def set_instance_type_context_db_pool_size(instance_type_context_id, default_db_pool_size) do
    MsbmsSystDatastore.get!(Data.SystInstanceTypeContexts, instance_type_context_id)
    |> Data.SystInstanceTypeContexts.update_changeset(%{
      default_db_pool_size: default_db_pool_size
    })
    |> MsbmsSystDatastore.update!(returning: true)
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure updating Instance Type Context.",
          cause: error
        }
      }
  end
end
