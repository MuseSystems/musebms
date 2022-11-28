# Source File: types.ex
# Location:    musebms/components/system/mscmp_syst_instance/lib/types.ex
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
  The data type of the Application ID value.
  """
  @type application_id() :: Ecto.UUID.t()

  @typedoc """
  The data type describing unique naming for known system applications in programmatic contexts.
  """
  @type application_name() :: String.t()

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
  The type of the Instance State ID value.
  """
  @type instance_state_id() :: Ecto.UUID.t()

  @typedoc """
  Type for identifying Instance States by name.
  """
  @type instance_state_name() :: String.t()

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
  @type instance_type_name() :: String.t()

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
end