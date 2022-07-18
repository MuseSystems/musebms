# Source File: instance_type_application.ex
# Location:    components/system/msbms_syst_instance_mgr/lib/impl/instance_type_application.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystInstanceMgr.Impl.InstanceTypeApplication do
  alias MsbmsSystInstanceMgr.Data
  alias MsbmsSystInstanceMgr.Types

  require Logger

  @moduledoc false

  @spec create_instance_type_application(Types.instance_type_id(), Types.application_id()) ::
          {:ok, Data.SystInstanceTypeApplications.t()} | {:error, MsbmsSystError.t()}
  def create_instance_type_application(instance_type_id, application_id)
      when is_binary(instance_type_id) and is_binary(application_id) do
    %{instance_type_id: instance_type_id, application_id: application_id}
    |> Data.SystInstanceTypeApplications.insert_changeset()
    |> MsbmsSystDatastore.insert!(returning: true)
    |> then(&{:ok, &1})
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure creating Instance Type Application association.",
          cause: error
        }
      }
  end

  @spec delete_instance_type_application(
          Types.instance_type_application_id()
          | Data.SystInstanceTypeApplications.t()
        ) :: :ok | {:error, MsbmsSystError.t()}
  def delete_instance_type_application(instance_type_application_id)
      when is_binary(instance_type_application_id) do
    MsbmsSystDatastore.get!(Data.SystInstanceTypeApplications, instance_type_application_id)
    |> delete_instance_type_application()
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure deleting Instance Type Application association by ID.",
          cause: error
        }
      }
  end

  def delete_instance_type_application(
        %Data.SystInstanceTypeApplications{} = instance_type_application
      ) do
    MsbmsSystDatastore.delete!(instance_type_application)
    :ok
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure deleting Instance Type Application association.",
          cause: error
        }
      }
  end
end
