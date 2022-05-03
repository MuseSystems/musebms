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
end
