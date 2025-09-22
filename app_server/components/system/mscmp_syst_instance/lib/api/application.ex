# Source File: application.ex
# Location:    musebms/app_server/components/system/mscmp_syst_instance/lib/api/application.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystInstance.Application do
  @moduledoc """
  Defines a behaviour and provides support functions for MscmpSystInstance
  compatible Application modules.

  """

  # ==============================================================================================
  # ==============================================================================================
  #
  # Application Management
  #
  # ==============================================================================================
  # ==============================================================================================

  ##############################################################################
  #
  # child_spec
  #
  #

  @doc """
  Returns the child specification of the Application.

  ## Parameters

  * `opts` - Miscellaneous options which the specific Application
      implementation of this Behaviour may define for it's own purposes.
  """
  @callback child_spec(opts :: Keyword.t()) :: Supervisor.child_spec()

  ##############################################################################
  #
  # init
  #
  #

  @doc """
  Initializes the Application, its services, and optionally starts its
  Instances.

  ## Parameters

    * `instances` - Identifies the Application Instances to start, if
      any.

    * `startup_options` - The startup options to use when starting the
      application.  Typically these options will include externally configured
      runtime options such as database connection information.  See
      `MscmpSystOptions` for more.

    * `opts` - Additional options to pass to the Application start process.  The
      specific options available will vary by Application implementation.
  """
  @callback init(
              instances :: MscmpSystInstance.Types.instances(),
              startup_options :: MscmpSystOptions.Types.options(),
              opts :: Keyword.t()
            ) ::
              {:ok, pid()} | {:error, {:already_started, pid()} | {:shutdown, term()} | term()}

  ##############################################################################
  #
  # stop
  #
  #

  @doc """
  Stops the Application services and any of its running Instances.
  """
  @callback stop() :: :ok

  ##############################################################################
  #
  # get_services
  #
  #

  @doc """
  Returns the map of Application services to their runtime names or PIDs.

  An Application may optionally support one or more runtime services, typically
  for the benefit of its own Instances; these might include an Application level
  Registry or PubSub services.
  """
  @callback get_services() :: MscmpSystInstance.Types.services()

  # ==============================================================================================
  # ==============================================================================================
  #
  # Instance Management
  #
  # ==============================================================================================
  # ==============================================================================================

  ##############################################################################
  #
  # create_instance
  #
  #

  @doc """
  Creates a new Application Instance.

  ## Parameters

    * `instance_name` - The name of the Instance to be created.  This name must
      be globally unique amongst Instance Names, including Instances of other
      Applications.  This value is required.

    * `startup_options` - The startup options which provide database connection
      information for where the Instance and its contexts are to be created.
      See `MscmpSystOptions` for more.  This value is required.

    * `opts` - Miscellaneous options which the specific Application
      implementation of this Behaviour may define for it's own purposes.
  """
  @callback create_instance(
              instance_name :: MscmpSystInstance.Types.instance_name(),
              startup_options :: MscmpSystOptions.Types.options(),
              opts :: Keyword.t()
            ) :: :ok | {:error, Exception.t()}

  ##############################################################################
  #
  # upgrade_instances
  #
  #

  @doc """
  Upgrades the identified Application Instances.

  You must ensure that the Application Instances to upgrade have been stopped
  prior to initiating the upgrade with this function.

  The upgrade process will apply any new database migrations to each of the
  targeted Instances and then return a list of each Instance's upgrade status.
  Once upgraded, the Instances many be restarted; this process does not attempt
  to restart Instances.

  ## Parameters

    * `instances` - Identifies the Application Instances to upgrade.

    * `startup_options` - The startup options which provide database connection
      information for the Instance that is to be upgraded.  See
      `MscmpSystOptions` for more.  This value is required.

    * `opts` - Miscellaneous options which the specific Application
      implementation of this Behaviour may define for it's own purposes.
  """
  @callback upgrade_instances(
              instances :: MscmpSystInstance.Types.startable_instances(),
              startup_options :: MscmpSystOptions.Types.options(),
              opts :: Keyword.t()
            ) ::
              {:ok, list(MscmpSystInstance.Types.instance_action_result())}
              | {:error, Exception.t()}

  ##############################################################################
  #
  # delete_instance
  #
  #

  @doc """
  Deletes an existing Application Instance.

  Note that specific Application implementation may impose requirements such as
  Instances to be deleted must be stopped prior to deletion or that they might
  have attributes such as "purge elegible" flags which must be set prior to
  deletion.  As a behaviour, this callback does not hold any opinions on such
  matters.

  ## Parameters

    * `instance_name` - The name of the Instance to be created.  This name must
      be globally unique amongst Instance Names, including Instances of other
      Applications.  This value is required.

    * `startup_options` - The startup options which provide database connection
      information for the Instance and its contexts which are to be deleted.
      See `MscmpSystOptions` for more.  This value is required.

    * `opts` - Miscellaneous options which the specific Application
      implementation of this Behaviour may define for it's own purposes.
  """
  @callback delete_instance(
              instance_name :: MscmpSystInstance.Types.instance_name(),
              startup_options :: MscmpSystOptions.Types.options(),
              opts :: Keyword.t()
            ) :: :ok | {:error, Exception.t()}

  # ==============================================================================================
  # ==============================================================================================
  #
  # Instance Runtime Management
  #
  # ==============================================================================================
  # ==============================================================================================

  ##############################################################################
  #
  # start_instances
  #
  #

  @doc """
  Starts unstarted, but startable, Application Instances.

  ## Parameters

    * `instances` - Identifies the Application Instances to start.

    * `startup_options` - The startup options to use when starting the
      application.  Typically these options will include externally configured
      runtime options such as database connection information.  See
      `MscmpSystOptions` for more.
  """
  @callback start_instances(
              instances :: MscmpSystInstance.Types.startable_instances(),
              startup_options :: MscmpSystOptions.Types.options(),
              opts :: Keyword.t()
            ) ::
              {:ok, list(MscmpSystInstance.Types.instance_action_result())}
              | {:error, Exception.t()}

  ##############################################################################
  #
  # stop_instances
  #
  #

  @doc """
  Stops the identified running Application Instances.

  ## Parameters

    * `instances` - Identifies the Application Instances to stop.
  """
  @callback stop_instances(instances :: MscmpSystInstance.Types.startable_instances()) ::
              {:ok, list(MscmpSystInstance.Types.instance_action_result())}
              | {:error, Exception.t()}

  ##############################################################################
  #
  # get_instance_states
  #
  #

  @doc """
  Retrieves the lifecycle and runtime states of the requested Application
  Instances.

  ## Parameters

    * `instances` - the desired Instances for which to return the runtime state.
  """
  @callback get_instance_states(instances :: MscmpSystInstance.Types.startable_instances()) ::
              list(MscmpSystInstance.Types.instance_state())

  ##############################################################################
  #
  # get_instance_services
  #
  #

  @doc """
  Retrieves a mapping of the known Instance services mapped to a specific
  Instance's runtime identifiers for those services.

  ## Parameters

    * `instance_name` - the Instance for which to return service mappings.
  """
  @callback get_instance_services(instance_name :: MscmpSystInstance.Types.instance_name()) ::
              MscmpSystInstance.Types.services()

  ##############################################################################
  #
  # put_instance
  #
  #

  @doc """
  Establishes the current Instance services which should be used for the current
  process.

  As Instance may start a number of services, including Datastore Contexts
  (database connections), PubSub services, and so on.  This function will set
  the current the map of services to use for the process in the Process
  Dictionary so that any calls to those services will be in the context of the
  "put" Instance's services.

  ## Parameters

    * `instance_name` - the Instance which will service calls for any business
      logic invocation of Instance services.

  ## Returns

  The return value is that of the previous Instance set or `nil` if no previous
  Instance was set.
  """
  @callback put_instance(instance_name :: MscmpSystInstance.Types.instance_name()) ::
              MscmpSystInstance.Types.instance_name() | nil
end
