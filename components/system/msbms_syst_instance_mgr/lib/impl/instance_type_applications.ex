# Source File: instance_type_applications.ex
# Location:    components/system/msbms_syst_instance_mgr/lib/impl/instance_type_applications.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystInstanceMgr.Impl.InstanceTypeApplications do
  import Ecto.Query

  require Logger

  alias MsbmsSystInstanceMgr.Data
  alias MsbmsSystInstanceMgr.Types

  @moduledoc false

  ######
  #
  # Logic for managing and accessing Instance Type Application data.
  #
  # Instance Type Applications is the notion that not all types of defined
  # instance support all Applications; it's possible but not mandatory.
  #
  # In practice, the only possible operations with these records are creating
  # them, reading them, or deleting them.  Updating them after creation is not
  # valid.
  #
  ######

  @spec list_instance_type_applications(Keyword.t()) ::
          {:ok, [Data.SystInstanceTypeApplications.t()]} | {:error, MsbmsSystError.t()}
  def list_instance_type_applications(opts_given) do
    opts_default = [
      application_id: nil,
      application_name: nil,
      instance_type_id: nil,
      instance_type_name: nil
    ]

    opts = Keyword.merge(opts_given, opts_default, fn _k, v1, _v2 -> v1 end)

    from(ita in Data.SystInstanceTypeApplications,
      as: :instance_type_applications,
      join: a in assoc(ita, :application),
      as: :applications,
      join: it in assoc(ita, :instance_type),
      as: :instance_types,
      order_by: [it.sort_order, a.display_name]
    )
    |> maybe_add_application_name_filter(opts[:application_name])
    |> maybe_add_application_id_filter(opts[:application_id])
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
          message: "Failure retrieving Instance Type Applications.",
          cause: error
        }
      }
  end

  defp maybe_add_application_name_filter(query, nil), do: query

  defp maybe_add_application_name_filter(query, application_name)
       when is_binary(application_name) do
    from([applications: a] in query, where: a.internal_name == ^application_name)
  end

  defp maybe_add_application_id_filter(query, nil), do: query

  defp maybe_add_application_id_filter(query, application_id)
       when is_binary(application_id) do
    from([applications: a] in query, where: a.id == ^application_id)
  end

  defp maybe_add_instance_type_name_filter(query, nil), do: query

  defp maybe_add_instance_type_name_filter(query, instance_type_name)
       when is_binary(instance_type_name) do
    from([instance_types: it] in query, where: it.internal_name == ^instance_type_name)
  end

  defp maybe_add_instance_type_id_filter(query, nil), do: query

  defp maybe_add_instance_type_id_filter(query, instance_type_id)
       when is_binary(instance_type_id) do
    from([instance_types: it] in query, where: it.id == ^instance_type_id)
  end

  @spec create_instance_type_application(Types.instance_type_id(), Types.application_id()) ::
          {:ok, Data.SystInstanceTypeApplications.t()} | {:error, MsbmsSystError.t()}
  def create_instance_type_application(instance_type_id, application_id)
      when is_binary(instance_type_id) and is_binary(application_id) do
    Data.SystInstanceTypeApplications.insert_changeset(%{
      instance_type_id: instance_type_id,
      application_id: application_id
    })
    |> MsbmsSystDatastore.insert!(returning: true)
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure creating new Instance Type Application.",
          cause: error
        }
      }
  end

  @spec delete_instance_type_application(Types.instance_type_application_id()) ::
          {:ok, {non_neg_integer(), nil | [term()]}} | {:error, MsbmsSystError.t()}
  def delete_instance_type_application(instance_type_application_id)
      when is_binary(instance_type_application_id) do
    from(ita in Data.SystInstanceTypeApplications, where: ita.id == ^instance_type_application_id)
    |> MsbmsSystDatastore.delete_all(returning: true)
    |> maybe_instance_type_application_purged()
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure deleting Instance Type Application record.",
          cause: error
        }
      }
  end

  defp maybe_instance_type_application_purged({1, _rows} = delete_result), do: delete_result

  defp maybe_instance_type_application_purged(delete_result) do
    raise MsbmsSystError,
      code: :database_error,
      message: "Failure verifying Instance Type Application record.",
      cause: delete_result
  end
end
