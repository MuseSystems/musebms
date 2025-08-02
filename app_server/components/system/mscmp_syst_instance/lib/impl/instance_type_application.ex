# Source File: instance_type_application.ex
# Location:    musebms/app_server/components/system/mscmp_syst_instance/lib/impl/instance_type_application.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystInstance.Impl.InstanceTypeApplication do
  @moduledoc false

  alias MscmpSystInstance.Types

  ##############################################################################
  #
  # create_instance_type_application
  #
  #

  @spec create_instance_type_application(Types.instance_type_id(), Types.application_id()) ::
          {:ok, Msdata.SystInstanceTypeApplications.t()} | {:error, term()}
  def create_instance_type_application(instance_type_id, application_id)
      when is_binary(instance_type_id) and is_binary(application_id) do
    %{instance_type_id: instance_type_id, application_id: application_id}
    |> Msdata.SystInstanceTypeApplications.insert_changeset()
    |> MscmpSystDb.insert(returning: true)
  end

  ##############################################################################
  #
  # delete_instance_type_application
  #
  #

  @spec delete_instance_type_application(
          Types.instance_type_application_id()
          | Msdata.SystInstanceTypeApplications.t()
        ) :: :ok | {:error, term()}
  def delete_instance_type_application(instance_type_application_id)
      when is_binary(instance_type_application_id) do
    case MscmpSystDb.get(Msdata.SystInstanceTypeApplications, instance_type_application_id) do
      nil ->
        {:error, {:not_found, instance_type_application_id}}

      instance_type_application ->
        delete_instance_type_application(instance_type_application)
    end
  end

  def delete_instance_type_application(
        %Msdata.SystInstanceTypeApplications{} = instance_type_application
      ) do
    with {:ok, _} <- MscmpSystDb.delete(instance_type_application) do
      :ok
    end
  rescue
    Ecto.StaleEntryError ->
      {:error, {:not_found, instance_type_application}}

    error ->
      reraise error, __STACKTRACE__
  end
end
