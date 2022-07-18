# Source File: instance_type_context.ex
# Location:    components/system/msbms_syst_instance_mgr/lib/impl/instance_type_context.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystInstanceMgr.Impl.InstanceTypeContext do
  alias MsbmsSystInstanceMgr.Data
  alias MsbmsSystInstanceMgr.Types

  require Logger

  @moduledoc false

  @spec update_instance_type_context(
          Types.instance_type_context_id() | Data.SystInstanceTypeContexts.t(),
          Types.instance_type_context_params()
        ) :: {:ok, Data.SystInstanceTypeContexts.t()} | {:error, MsbmsSystError.t()}
  def update_instance_type_context(instance_type_context_id, instance_type_context_params)
      when is_binary(instance_type_context_id) do
    MsbmsSystDatastore.get!(Data.SystInstanceTypeContexts, instance_type_context_id)
    |> update_instance_type_context(instance_type_context_params)
  rescue
    error ->
      Logger.error(Exception.format(:error, error, __STACKTRACE__))

      {
        :error,
        %MsbmsSystError{
          code: :undefined_error,
          message: "Failure updating Instance Type Context by ID.",
          cause: error
        }
      }
  end

  def update_instance_type_context(
        %Data.SystInstanceTypeContexts{} = instance_type_context,
        instance_type_context_params
      ) do
    instance_type_context
    |> Data.SystInstanceTypeContexts.update_changeset(instance_type_context_params)
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