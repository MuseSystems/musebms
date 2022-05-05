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
end
