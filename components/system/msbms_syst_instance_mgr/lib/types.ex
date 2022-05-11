# Source File: types.ex
# Location:    components/system/msbms_syst_instance_mgr/lib/types.ex
# Project:     msbms
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystInstanceMgr.Types do
  @moduledoc """
  Types used by the Instance Manager module.
  """

  @typedoc """
  The data type describing unique naming for known system applications in programmatic contexts.
  """
  @type application_name() :: String.t()

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
  Type for identifying individual known system instances.
  """
  @type instance_name() :: String.t()

  @typedoc """
  Type for identifying instance type names.
  """
  @type instance_type_name() :: String.t()

  @typedoc """
  A map definition which allows for the maintenance of system instance records.
  """
  @type instance_params() :: %{
          optional(:internal_name) => instance_name(),
          optional(:display_name) => String.t(),
          optional(:dbserver_name) => String.t(),
          optional(:db_app_context_pool_size) => integer(),
          optional(:db_api_context_pool_size) => integer(),
          optional(:instance_code_id) => Ecto.UUID.t(),
          optional(:application_id) => Ecto.UUID.t(),
          optional(:instance_type_id) => Ecto.UUID.t(),
          optional(:instance_state_id) => Ecto.UUID.t(),
          optional(:owner_id) => Ecto.UUID.t(),
          optional(:owning_instance_id) => Ecto.UUID.t()
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
  @type owner_state :: %{
          optional(:internal_name) => MsbmsSystEnums.Types.enum_item_name(),
          optional(:display_name) => String.t(),
          optional(:external_name) => String.t(),
          optional(:user_description) => String.t(),
          optional(:enum_default) => boolean(),
          optional(:functional_type_name) => MsbmsSystEnums.Types.enum_functional_type_name()
        }

  @typedoc """
  Establishes the available instance state functional types understood by the
  module.

    * `:instance_states_uninitialized` - The instance definition record has been
      created, but the corresponding instance has not been created on the
      database server and is awaiting processing.

    * `:instance_states_initializing` - The process of creating the instance has
      been started.

    * `:instance_states_active` - The instance is created and usable by users.

    * `:instance_states_suspended` - The instance is not available for regular
      use, though some limited functionality may be available.  The instance is
      likely visible to users for this reason.

    * `:instance_states_inactive` - The instance is not available for any use
      and would not typically be visible tp users for any purpose.

    * `:instance_states_purge_eligible` - The instance is not available for any
      use, not visible to users and subject to be completely deleted from the
      system at any point in time.
  """
  @type instance_state_functional_types ::
          :instance_states_uninitialized
          | :instance_states_initializing
          | :instance_states_active
          | :instance_states_suspended
          | :instance_states_inactive
          | :instance_states_purge_eligible

  @typedoc """
  Defines the data which is returned by the `MsbmsSystInstanceMgr.list_instances/1`
  function.
  """
  @type instances_list_item :: %{
          instance_id: Ecto.UUID.t(),
          instance_internal_name: instance_name(),
          instance_display_name: String.t(),
          instance_owning_instance_id: Ecto.UUID.t(),
          instance_options: map(),
          instance_type_id: Ecto.UUID.t(),
          instance_type_display_name: String.t(),
          instance_type_external_name: String.t(),
          instance_state_id: Ecto.UUID.t(),
          instance_state_display_name: String.t(),
          instance_state_external_name: String.t(),
          instance_state_functional_type_id: Ecto.UUID.t(),
          instance_state_functional_type_name: MsbmsSystEnums.Types.enum_functional_type_name(),
          owner_id: Ecto.UUID.t(),
          owner_display_name: String.t(),
          owner_state_display_name: String.t(),
          owner_state_functional_type_name: MsbmsSystEnums.Types.enum_functional_type_name(),
          owner_state_functional_type_display_name: String.t(),
          application_id: Ecto.UUID.t(),
          application_display_name: String.t(),
          application_syst_description: String.t()
        }

  @typedoc """
  Expected data structure for Instance Type user_options data.

  Instance Type user options serve two purposes.  First the are used to define
  which datastore contexts are expected to exist for any instance of a given
  type and they set default connection pool sizes for those contexts.

  Ultimately, these values end up at the `MsbmsSystInstanceMgr.Data.SystInstances`
  record in the `instance_options` field.  However, the values defined here for
  the Instance Type are only a subset of the fields expected in
  `instance_options`.
  """
  @type instance_type_default_options :: %{
          required(:datastore_contexts) =>
            list(%{
              id: MsbmsSystDatastore.Types.context_id(),
              db_pool_size: integer()
            })
        }

  @typedoc """
  The required data for maintaining Instance Types.

  Note that when creating new instance types, the `internal_name`,
  `display_name`, `external_name`, `user_description`, and `user_options` fields
  are required.  On updates of an existing instance type, those fields are
  optional.
  """
  @type instance_type :: %{
          optional(:internal_name) => MsbmsSystEnums.Types.enum_item_name(),
          optional(:display_name) => String.t(),
          optional(:external_name) => String.t(),
          optional(:user_description) => String.t(),
          optional(:user_options) => instance_type_default_options(),
          optional(:enum_default) => boolean()
        }

  @typedoc """
  The required data for maintaining Instance States.

  Note that when creating new instance states, the `internal_name`,
  `display_name`, `external_name`, `user_description`, and
  `functional_type_name` fields are required.  On updates of an existing
  instance state, those fields are optional.
  """
  @type instance_state :: %{
          optional(:internal_name) => MsbmsSystEnums.Types.enum_item_name(),
          optional(:display_name) => String.t(),
          optional(:external_name) => String.t(),
          optional(:user_description) => String.t(),
          optional(:enum_default) => boolean(),
          optional(:functional_type_name) => MsbmsSystEnums.Types.enum_functional_type_name()
        }
end
