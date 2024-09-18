# Source File: types.ex
# Location:    musebms/app_server/components/system/mscmp_syst_instance/lib/api/types.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystInstance.Types do
  #
  # Note that the ordering of typespecs here is alphabetical.
  #

  @moduledoc """
  Types used by the Instance Manager module.
  """

  @typedoc """
  Defines the data type of the Application Context ID.
  """
  @type application_context_id() :: Ecto.UUID.t()

  @typedoc """
  The data type describing unique naming for known application contexts in programmatic contexts.
  """
  @type application_context_name() :: String.t()

  @typedoc """
  Attributes used in creating or updating Application Context records.
  """
  @type application_context_params() :: %{
          optional(:internal_name) => application_context_name(),
          optional(:display_name) => String.t(),
          optional(:application_id) => application_id(),
          optional(:application_name) => application_name(),
          optional(:description) => String.t(),
          optional(:start_context) => boolean(),
          optional(:login_context) => boolean(),
          optional(:database_owner_context) => boolean()
        }

  @typedoc """
  The data type of the Application ID value.
  """
  @type application_id() :: Ecto.UUID.t()

  @typedoc """
  The data type describing unique naming for known system applications in programmatic contexts.
  """
  @type application_name() :: String.t()

  @typedoc """
  Attributes used in the creation or updating of Application records.
  """
  @type application_params() :: %{
          optional(:internal_name) => application_name(),
          optional(:display_name) => String.t(),
          optional(:syst_description) => String.t()
        }

  @typedoc """
  The data type describing the record ID value of the Instance Context record.
  """
  @type instance_context_id() :: Ecto.UUID.t()

  @typedoc """
  Defines the data type representing Instance Context names.
  """
  @type instance_context_name() :: String.t()

  @typedoc """
  Attributes accepted for the creation or change of Instance Context records.

  Each Instance should have Instance Context records matched to its parent
  Application's Contexts, setting value specific for the Instance.
  """
  @type instance_context_params :: %{
          optional(:start_context) => boolean(),
          optional(:db_pool_size) => non_neg_integer(),
          optional(:context_code) => binary()
        }

  @typedoc """
  Defines the type of the Instance record ID value.
  """
  @type instance_id() :: Ecto.UUID.t()

  @typedoc """
  Type for identifying individual known system instances.
  """
  @type instance_name() :: String.t()

  @typedoc """
  A map definition which allows for the maintenance of system instance records.
  """
  @type instance_params() :: %{
          optional(:internal_name) => instance_name(),
          optional(:display_name) => String.t(),
          optional(:dbserver_name) => String.t(),
          optional(:application_id) => Ecto.UUID.t(),
          optional(:application_name) => application_name(),
          optional(:instance_code) => binary(),
          optional(:instance_type_id) => Ecto.UUID.t(),
          optional(:instance_type_name) => instance_type_name(),
          optional(:instance_state_id) => Ecto.UUID.t(),
          optional(:instance_state_name) => instance_state_name(),
          optional(:owner_id) => Ecto.UUID.t(),
          optional(:owner_name) => owner_name(),
          optional(:owning_instance_id) => Ecto.UUID.t(),
          optional(:owning_instance_name) => instance_name()
        }

  @type instance_runtime_state() :: :started | :stopped

  @typedoc """
  Expresses a specific Instance, its runtime state, and the functional type of
  its runtime state.
  """
  @type instance_state() ::
          {instance_name(), {:ok, instance_runtime_state()} | {:error, MscmpSystError.t()}}

  @typedoc """
  Establishes the available Instance state functional types understood by the
  module.

    * `:instance_states_uninitialized` - The Instance definition record has been
    created, but the corresponding Instance has not been created on the database
    server and is awaiting processing.

    * `:instance_states_initializing` - The process of creating the Instance has
    been started.

    * `:instance_states_initialized` - The Instance Datastore has been
    initialized meaning the Instance Datastore has been created on the database
    server, but has not yet been finalized as being "active".

    * `:instance_states_active` - The Instance is created and usable by users.

    * `:instance_states_migrating` - The Instance Datastore is in the process of
    being updated to the latest version of the schema.

    * `:instance_states_suspended` - The Instance is not available for regular
    use, though some limited functionality may be available.  The Instance is
    likely visible to users for this reason.

    * `:instance_states_inactive` - The Instance is not available for any use
    and would not typically be visible to users for any purpose.

    * `:instance_states_failed` - The Instance startup process has failed to
    start the Instance for some reason and requires intervention.

    * `:instance_states_purge_eligible` - The Instance is not available for any
      use, not visible to users and subject to be completely deleted from the
      system at any point in time.
  """
  @type instance_state_functional_types ::
          :instance_states_uninitialized
          | :instance_states_initializing
          | :instance_states_initialized
          | :instance_states_active
          | :instance_states_migrating
          | :instance_states_suspended
          | :instance_states_inactive
          | :instance_states_failed
          | :instance_states_purge_eligible

  @typedoc """
  The type of the Instance State ID value.
  """
  @type instance_state_id() :: Ecto.UUID.t()

  @typedoc """
  Type for identifying Instance States by name.
  """
  @type instance_state_name() :: MscmpSystEnums.Types.enum_item_name()

  @typedoc """
  The required data for maintaining Instance States.

  Note that when creating new instance states, the `internal_name`,
  `display_name`, `external_name`, `user_description`, and
  `functional_type_name` fields are required.  On updates of an existing
  instance state, those fields are optional.
  """
  @type instance_state_params :: %{
          optional(:internal_name) => MscmpSystEnums.Types.enum_item_name(),
          optional(:display_name) => String.t(),
          optional(:external_name) => String.t(),
          optional(:user_description) => String.t(),
          optional(:enum_default) => boolean(),
          optional(:functional_type_name) => MscmpSystEnums.Types.enum_functional_type_name()
        }

  @typedoc """
  The data type of the Instance Type Application record ID.
  """
  @type instance_type_application_id() :: Ecto.UUID.t()

  @typedoc """
  Defines the creation parameters for Instance Type Application records.

    * `instance_type_id` - the record ID of the parent Instance Type record.
    This field is required.

    * `application_id` - the record ID of the Application record being
    associated with the parent Instance Type.
  """
  @type instance_type_application_params() :: %{
          instance_type_id: instance_type_id(),
          application_id: application_id()
        }

  @typedoc """
  Defines the data type of the Instance Type Context ID.
  """
  @type instance_type_context_id() :: Ecto.UUID.t()

  @typedoc """
  The required data for maintaining Instance Type Contexts.
  """
  @type instance_type_context_params :: %{
          optional(:instance_type_id) => Ecto.UUID.t(),
          optional(:instance_type_name) => instance_type_name(),
          optional(:application_context_id) => Ecto.UUID.t(),
          optional(:application_context_name) => application_context_name(),
          optional(:default_db_pool_size) => non_neg_integer()
        }

  @typedoc """
  Expected data structure for Instance Type user_options data.

  Instance Type user options currently define which server pools are allowed to
  host Instances of the Instance Type.
  """
  @type instance_type_default_options :: %{required(:allowed_server_pools) => list(String.t())}

  @typedoc """
  Type of the Instance Type ID value.
  """
  @type instance_type_id() :: Ecto.UUID.t()

  @typedoc """
  Type for identifying instance type names.
  """
  @type instance_type_name() :: MscmpSystEnums.Types.enum_item_name()

  @typedoc """
  The required data for maintaining Instance Types.

  Note that when creating new instance types, the `internal_name`,
  `display_name`, `external_name`, `user_description`, and `user_options` fields
  are required.  On updates of an existing instance type, those fields are
  optional.
  """
  @type instance_type_params :: %{
          optional(:internal_name) => MscmpSystEnums.Types.enum_item_name(),
          optional(:display_name) => String.t(),
          optional(:external_name) => String.t(),
          optional(:user_description) => String.t(),
          optional(:user_options) => instance_type_default_options(),
          optional(:enum_default) => boolean()
        }

  @typedoc """
  Type for Owner record ID values.
  """
  @type owner_id() :: binary()

  @typedoc """
  Type for programmatic the unique identification of system owner records.
  """
  @type owner_name() :: String.t()

  @typedoc """
  Defines a map which may be used to maintain system owner records.
  """
  @type owner_params() :: %{
          optional(:internal_name) => owner_name(),
          optional(:display_name) => String.t(),
          optional(:owner_state_id) => Ecto.UUID.t()
        }

  @typedoc """
  Defines the available owner state functional types which the module recognizes.

    * `:owner_states_active` - The owner is active and available for normal use.

    * `:owner_states_suspended` - The owner is not available for regular use,
      though some limited functionality may be available.  The owner is likely
      visible to users for this reason.

    * `:owner_states_inactive` - The owner is not available for any use and
      would not typically be visible tp users for any purpose.

    * `:owner_states_purge_eligible` - The owner is not available for any use,
      not visible to users and subject to be completely deleted from the system
      at any point in time.
  """
  @type owner_state_functional_types ::
          :owner_states_active
          | :owner_states_suspended
          | :owner_states_inactive
          | :owner_states_purge_eligible

  @typedoc """
  The required data for maintaining Owner States.

  Note that when creating new owner states, the `internal_name`, `display_name`,
  `external_name`, `user_description`, and `functional_type_name` fields are
  required.  On updates of an existing instance state, those fields are
  optional.
  """
  @type owner_state_params :: %{
          optional(:internal_name) => MscmpSystEnums.Types.enum_item_name(),
          optional(:display_name) => String.t(),
          optional(:external_name) => String.t(),
          optional(:user_description) => String.t(),
          optional(:enum_default) => boolean(),
          optional(:functional_type_name) => MscmpSystEnums.Types.enum_functional_type_name()
        }

  @typedoc """
  Type for identifying Owner States by name.
  """
  @type owner_state_name() :: MscmpSystEnums.Types.enum_item_name()

  @typedoc """
  Defines the identification mechanism for the services of an Application or an
  Instance.

  This is differentiated from `t:service_name/0` in that a `service_name` is the
  generic name of a service that an Application or Instance is expected to
  provided whereas the `service_locator` is a running instance of the service.
  """
  @type service_locator :: Supervisor.name() | GenServer.name()

  @typedoc """
  Defines the generic name of a service that an Application or Instance is
  expected to provide.

  This is differentiated from `t:service_locator/0` in that a `service_name` is the
  generic identifier for a type of service, while a `service_locator` represents
  a specific running instance of that service.
  """
  @type service_name() :: atom()

  @typedoc """
  Represents a mapping of provided service names to the identifiers of the
  running instances of those services.

  The `t:service_name/0` key is a generic identifier for a type of service that
  an Application or Instance is expected to provide.  The `t:service_locator/0`
  value provides the running process identifier implementing that service.
  """
  @type services() :: %{optional(service_name()) => service_locator()}

  @typedoc """
  Defines the acceptable forms for identifying Instances to be subjected to an
  action, such as starting or stopping.

  The following values are available:

    * `:none`: No Instances will be affected, effectively making the action a
      no-op from an Instance management perspective.

    *  `:all`: All qualifying Instances will be subjected to the action.

    * A list of Instance Names
  """
  @type target_instances() :: :none | :all | list(instance_name())

  @typedoc """
  Expresses a specific Instance, its runtime state, and the functional type of
  its runtime state.
  """
  @type target_instance_result() ::
          {instance_name(),
           {:ok, :upgraded} | {:ok, instance_runtime_state()} | {:error, MscmpSystError.t()}}
end
