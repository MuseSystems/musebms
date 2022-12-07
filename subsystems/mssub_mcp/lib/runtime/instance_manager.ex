# Source File: instance_manager.ex
# Location:    musebms/subsystems/mssub_mcp/lib/runtime/instance_manager.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MssubMcp.Runtime.InstanceManager do
  alias MscmpSystInstance.Types, as: InstanceTypes

  @moduledoc false

  use MssubMcp.Macros

  mcp_constants()

  # ==============================================================================================
  #
  # Instance Management
  #
  # ==============================================================================================

  @spec start_all_applications(map(), Keyword.t()) :: :ok | {:error, MscmpSystError.t()}
  mcp_opfn start_all_applications(startup_options, opts) do
    opts =
      Keyword.merge(opts,
        registry_name: @mcp_instances_config.registry_name,
        instance_supervisor_name: @mcp_instances_config.instance_supervisor_name,
        task_supervisor_name: @mcp_instances_config.task_supervisor_name
      )

    MscmpSystInstance.start_all_applications(startup_options, opts)
  end

  @spec start_application(
          InstanceTypes.application_id() | Msdata.SystApplications.t(),
          map(),
          Keyword.t()
        ) ::
          :ok | {:error, MscmpSystError.t()}
  mcp_opfn start_application(application, startup_options, opts) do
    opts =
      Keyword.merge(opts,
        registry_name: @mcp_instances_config.registry_name,
        instance_supervisor_name: @mcp_instances_config.instance_supervisor_name,
        task_supervisor_name: @mcp_instances_config.task_supervisor_name
      )

    MscmpSystInstance.start_application(application, startup_options, opts)
  end

  @spec start_instance(InstanceTypes.instance_id() | Msdata.SystInstances.t(), map(), Keyword.t()) ::
          :ok | {:error, MscmpSystError.t()}
  mcp_opfn start_instance(instance, startup_options, opts) do
    opts =
      Keyword.merge(opts,
        registry_name: @mcp_instances_config.registry_name,
        instance_supervisor_name: @mcp_instances_config.instance_supervisor_name
      )

    MscmpSystInstance.start_instance(instance, startup_options, opts)
  end

  @spec stop_all_applications(Keyword.t()) :: :ok | {:error, MscmpSystError.t()}
  mcp_opfn stop_all_applications(opts) do
    opts = Keyword.merge(opts, registry_name: @mcp_instances_config.registry_name)

    MscmpSystInstance.stop_all_applications(opts)
  end

  @spec stop_application(
          InstanceTypes.application_id() | Msdata.SystApplications.t(),
          Keyword.t()
        ) ::
          :ok | {:error, MscmpSystError.t()}
  mcp_opfn stop_application(application, opts) do
    opts = Keyword.merge(opts, registry_name: @mcp_instances_config.registry_name)

    MscmpSystInstance.stop_application(application, opts)
  end

  @spec stop_instance(InstanceTypes.instance_id() | Msdata.SystInstances.t(), Keyword.t()) ::
          :ok | {:error, MscmpSystError.t()}
  mcp_opfn stop_instance(instance, opts) do
    opts = Keyword.merge(opts, registry_name: @mcp_instances_config.registry_name)

    MscmpSystInstance.stop_instance(instance, opts)
  end

  # ==============================================================================================
  #
  # Applications
  #
  # ==============================================================================================

  @spec get_application_id_by_name(InstanceTypes.application_name()) ::
          InstanceTypes.application_id() | nil
  mcp_opfn get_application_id_by_name(application_name) do
    MscmpSystInstance.get_application_id_by_name(application_name)
  end

  # ==============================================================================================
  #
  # Instance Types
  #
  # ==============================================================================================

  @spec create_instance_type(InstanceTypes.instance_type_params()) ::
          {:ok, Msdata.SystEnumItems.t()} | {:error, MscmpSystError.t()}
  mcp_opfn create_instance_type(instance_type_params) do
    MscmpSystInstance.create_instance_type(instance_type_params)
  end

  @spec get_instance_type_by_name(InstanceTypes.instance_type_name()) ::
          Msdata.SystEnumItems.t() | nil
  mcp_opfn get_instance_type_by_name(instance_type_name) do
    MscmpSystInstance.get_instance_type_by_name(instance_type_name)
  end

  @spec get_instance_type_default() :: Msdata.SystEnumItems.t()
  mcp_opfn get_instance_type_default do
    MscmpSystInstance.get_instance_type_default()
  end

  @spec update_instance_type(
          InstanceTypes.instance_type_name(),
          InstanceTypes.instance_type_params() | %{}
        ) ::
          {:ok, Msdata.SystEnumItems.t()} | {:error, MscmpSystError.t()}
  mcp_opfn update_instance_type(instance_type_name, instance_type_params) do
    MscmpSystInstance.update_instance_type(instance_type_name, instance_type_params)
  end

  @spec delete_instance_type(InstanceTypes.instance_type_name()) ::
          :ok | {:error, MscmpSystError.t()}
  mcp_opfn delete_instance_type(instance_type_name) do
    MscmpSystInstance.delete_instance_type(instance_type_name)
  end

  @spec create_instance_type_application(
          InstanceTypes.instance_type_id(),
          InstanceTypes.application_id()
        ) :: {:ok, Msdata.SystInstanceTypeApplications.t()} | {:error, MscmpSystError.t()}
  mcp_opfn create_instance_type_application(instance_type_id, application_id) do
    MscmpSystInstance.create_instance_type_application(instance_type_id, application_id)
  end

  @spec delete_instance_type_application(
          InstanceTypes.instance_type_application_id()
          | Msdata.SystInstanceTypeApplications.t()
        ) ::
          :ok | {:error, MscmpSystError.t()}
  mcp_opfn delete_instance_type_application(instance_type_application) do
    MscmpSystInstance.delete_instance_type_application(instance_type_application)
  end

  @spec update_instance_type_context(
          InstanceTypes.instance_type_context_id()
          | Msdata.SystInstanceTypeContexts.t(),
          InstanceTypes.instance_type_context_params() | %{}
        ) :: {:ok, Msdata.SystInstanceTypeContexts.t()} | {:error, MscmpSystError.t()}
  mcp_opfn update_instance_type_context(
             instance_type_context,
             instance_type_context_params
           ) do
    MscmpSystInstance.update_instance_type_context(
      instance_type_context,
      instance_type_context_params
    )
  end

  # ==============================================================================================
  #
  # Owners
  #
  # ==============================================================================================

  @spec get_owner_state_by_name(InstanceTypes.owner_state_name()) ::
          Msdata.SystEnumItems.t() | nil
  mcp_opfn get_owner_state_by_name(owner_state_name) do
    MscmpSystInstance.get_owner_state_by_name(owner_state_name)
  end

  @spec get_owner_state_default(InstanceTypes.owner_state_functional_types() | nil) ::
          Msdata.SystEnumItems.t()
  mcp_opfn get_owner_state_default(functional_type \\ nil) do
    MscmpSystInstance.get_owner_state_default(functional_type)
  end

  @spec create_owner(InstanceTypes.owner_params()) ::
          {:ok, Msdata.SystOwners.t()} | {:error, MscmpSystError.t()}
  mcp_opfn create_owner(insert_params) do
    MscmpSystInstance.create_owner(insert_params)
  end

  @spec update_owner(
          InstanceTypes.owner_id() | Msdata.SystOwners.t(),
          InstanceTypes.owner_params()
        ) ::
          {:ok, Msdata.SystOwners.t()} | {:error, MscmpSystError.t()}
  mcp_opfn update_owner(owner, update_params) do
    MscmpSystInstance.update_owner(owner, update_params)
  end

  @spec get_owner_by_name(InstanceTypes.owner_name()) ::
          {:ok, Msdata.SystOwners.t()} | {:error, MscmpSystError.t()}
  mcp_opfn get_owner_by_name(owner_name) do
    MscmpSystInstance.get_owner_by_name(owner_name)
  end

  @spec get_owner_id_by_name(InstanceTypes.owner_name()) ::
          {:ok, InstanceTypes.owner_id()} | {:error, MscmpSystError.t()}
  mcp_opfn get_owner_id_by_name(owner_name) do
    MscmpSystInstance.get_owner_id_by_name(owner_name)
  end

  @spec purge_owner(InstanceTypes.owner_id() | Msdata.SystOwners.t()) ::
          :ok | {:error, MscmpSystError.t()}
  mcp_opfn purge_owner(owner) do
    MscmpSystInstance.purge_owner(owner)
  end

  # ==============================================================================================
  #
  # Instances
  #
  # ==============================================================================================

  @spec get_instance_state_by_name(InstanceTypes.instance_state_name()) ::
          Msdata.SystEnumItems.t() | nil
  mcp_opfn get_instance_state_by_name(instance_state_name) do
    MscmpSystInstance.get_instance_state_by_name(instance_state_name)
  end

  @spec get_instance_state_default(InstanceTypes.instance_state_functional_types() | nil) ::
          Msdata.SystEnumItems.t()
  mcp_opfn get_instance_state_default(functional_type \\ nil) do
    MscmpSystInstance.get_instance_state_default(functional_type)
  end

  @spec create_instance(InstanceTypes.instance_params()) ::
          {:ok, Msdata.SystInstances.t()} | {:error, MscmpSystError.t()}
  mcp_opfn create_instance(insert_params) do
    MscmpSystInstance.create_instance(insert_params)
  end

  @spec get_instance_datastore_options(
          InstanceTypes.instance_id() | Msdata.SystInstances.t(),
          map()
        ) ::
          MscmpSystDb.Types.datastore_options()
  mcp_opfn get_instance_datastore_options(instance, startup_options) do
    MscmpSystInstance.get_instance_datastore_options(instance, startup_options)
  end

  @spec initialize_instance(InstanceTypes.instance_id(), map(), Keyword.t()) ::
          {:ok, Msdata.SystInstances.t()} | {:error, MscmpSystError.t()}
  mcp_opfn initialize_instance(instance_id, startup_options, opts \\ []) do
    MscmpSystInstance.initialize_instance(instance_id, startup_options, opts)
  end

  @spec set_instance_state(Msdata.SystInstances.t(), InstanceTypes.instance_state_id()) ::
          {:ok, Msdata.SystInstances.t()} | {:error, MscmpSystError.t()}
  mcp_opfn set_instance_state(instance, instance_state_id) do
    MscmpSystInstance.set_instance_state(instance, instance_state_id)
  end

  @spec get_default_instance_state_ids() :: Keyword.t()
  mcp_opfn get_default_instance_state_ids() do
    MscmpSystInstance.get_default_instance_state_ids()
  end

  @spec get_instance_by_name(InstanceTypes.instance_name()) ::
          {:ok, Msdata.SystInstances.t()} | {:error, MscmpSystError.t()}
  mcp_opfn get_instance_by_name(instance_name) do
    MscmpSystInstance.get_instance_by_name(instance_name)
  end

  @spec get_instance_id_by_name(InstanceTypes.instance_name()) ::
          {:ok, InstanceTypes.instance_id()} | {:error, MscmpSystError.t()}
  mcp_opfn get_instance_id_by_name(instance_name) do
    MscmpSystInstance.get_instance_id_by_name(instance_name)
  end

  @spec purge_instance(InstanceTypes.instance_id() | Msdata.SystInstances.t(), map()) ::
          :ok | {:error, MscmpSystError.t()}
  mcp_opfn purge_instance(instance, startup_options) do
    MscmpSystInstance.purge_instance(instance, startup_options)
  end
end
