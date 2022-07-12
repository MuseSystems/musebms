defmodule MsbmsSystInstanceMgr do
  alias MsbmsSystInstanceMgr.Data
  alias MsbmsSystInstanceMgr.Impl
  alias MsbmsSystInstanceMgr.Runtime
  alias MsbmsSystInstanceMgr.Types

  @moduledoc """
  Functionality allowing for the management of application Instances.

  "Instances" are instances of running application environments.  Instances are
  established to host the application for different purposes, such as for
  running the application for production, training, and testing purposes; or as
  a means to implement multi-tenancy where each tenant application environment
  is an Instance.
  """

  #
  #  Instance Types
  #

  @spec create_instance_type(Types.instance_type_params()) ::
          {:ok, MsbmsSystEnums.Data.SystEnumItems.t()} | {:error, MsbmsSystError.t()}
  defdelegate create_instance_type(instance_type_params), to: Impl.InstanceType

  @spec update_instance_type(Types.instance_type_name(), Types.instance_type_params() | %{}) ::
          {:ok, MsbmsSystEnums.Data.SystEnumItems.t()} | {:error, MsbmsSystError.t()}
  defdelegate update_instance_type(instance_type_name, instance_type_params \\ %{}),
    to: Impl.InstanceType

  @spec delete_instance_type(Types.instance_type_name()) ::
          :ok | {:error, MsbmsSystError.t()}
  defdelegate delete_instance_type(instance_type_name), to: Impl.InstanceType

  #
  # Instance Type Applications
  #

  @spec create_instance_type_application(
          Types.instance_type_id(),
          Types.instance_type_application_id()
        ) :: {:ok, Data.SystInstanceTypeApplications} | {:error, MsbmsSystError.t()}
  defdelegate create_instance_type_application(instance_type_id, application_id),
    to: Impl.InstanceTypeApplication

  @spec delete_instance_type_application(
          Types.instance_type_application_id()
          | Data.SystInstanceTypeApplications.t()
        ) ::
          :ok | {:error, MsbmsSystError.t()}
  defdelegate delete_instance_type_application(instance_type_application),
    to: Impl.InstanceTypeApplication

  #
  # Instance Type Contexts
  #

  @spec update_instance_type_context(
          Types.instance_type_context_id()
          | Data.SystInstanceTypeContexts.t(),
          Types.instance_type_context_params() | %{}
        ) :: {:ok, Data.SystInstanceTypeContexts.t()} | {:error, MsbmsSystError.t()}
  defdelegate update_instance_type_context(
                instance_type_context,
                instance_type_context_params \\ %{}
              ),
              to: Impl.InstanceTypeContext

  #
  # Owners
  #

  @spec create_owner(Types.owner_params()) ::
          {:ok, Data.SystOwners.t()} | {:error, MsbmsSystError.t()}
  defdelegate create_owner(owner_params), to: Impl.Owner

  @spec update_owner(Types.owner_id() | Data.SystOwners.t(), Types.owner_params()) ::
          {:ok, Data.SystOwners.t()} | {:error, MsbmsSystError.t()}
  defdelegate update_owner(owner, update_params), to: Impl.Owner

  @spec purge_owner(Types.owner_id() | Data.SystOwners.t()) :: :ok | {:error, MsbmsSystError.t()}
  defdelegate purge_owner(owner), to: Impl.Owner

  #
  # Instances
  #

  @spec create_instance(Types.instance_params()) ::
          {:ok, Data.SystInstances.t()} | {:error, MsbmsSystError.t()}
  defdelegate create_instance(instance_params), to: Impl.Instance

  defdelegate get_instance_datastore_options(instance, startup_options), to: Impl.Instance

  defdelegate initialize_instance(instance_id, startup_options, opts \\ []), to: Impl.Instance

  defdelegate purge_instance(instance, startup_options), to: Impl.Instance

  #
  # Applications
  #

  defdelegate start_all_applications(startup_options, opts \\ []), to: Runtime.Application

  defdelegate start_application(application, startup_options, opts \\ []), to: Runtime.Application

  defdelegate stop_all_applications(opts \\ []), to: Runtime.Application

  defdelegate stop_application(application, opts \\ []), to: Runtime.Application

  defdelegate start_instance(instance, startup_options, opts \\ []), to: Runtime.Application

  defdelegate stop_instance(instance, opts \\ []), to: Runtime.Application
end
