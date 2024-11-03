# Source File: instance_type_context.ex
# Location:    musebms/components/system/mscmp_syst_instance/lib/impl/instance_type_context.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystInstance.Impl.InstanceTypeContext do
  @moduledoc false

  alias MscmpSystInstance.Types

  require Logger

  ##############################################################################
  #
  # update_instance_type_context
  #
  #

  @spec update_instance_type_context(
          Types.instance_type_context_id() | Msdata.SystInstanceTypeContexts.t(),
          Types.instance_type_context_params()
        ) :: {:ok, Msdata.SystInstanceTypeContexts.t()} | {:error, term()}
  def update_instance_type_context(instance_type_context_id, instance_type_context_params)
      when is_binary(instance_type_context_id) do
    case MscmpSystDb.get(Msdata.SystInstanceTypeContexts, instance_type_context_id) do
      nil ->
        {:error, {:not_found, instance_type_context_id}}

      instance_type_context ->
        update_instance_type_context(instance_type_context, instance_type_context_params)
    end
  end

  def update_instance_type_context(
        %Msdata.SystInstanceTypeContexts{} = instance_type_context,
        instance_type_context_params
      ) do
    instance_type_context
    |> Msdata.SystInstanceTypeContexts.update_changeset(instance_type_context_params)
    |> MscmpSystDb.update(returning: true)
  end
end
