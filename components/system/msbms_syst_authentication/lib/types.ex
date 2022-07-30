# Source File: types.ex
# Location:    musebms/components/system/msbms_syst_authentication/lib/types.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https: //muse.systems

defmodule MsbmsSystAuthentication.Types do
  #
  # Note that the ordering of typespecs here is alphabetical.
  #

  @moduledoc """
  Types used by the Authentication module.
  """

  @type access_account_id() :: Ecto.UUID.t()

  @type access_account_name() :: String.t()

  @type access_account_params() :: %{
          optional(:internal_name) => access_account_name(),
          optional(:external_name) => String.t(),
          optional(:owning_owner_id) => MsbmsSystInstanceMgr.Types.owner_id(),
          optional(:owning_owner_name) => MsbmsSystInstanceMgr.Types.owner_name(),
          optional(:allow_global_logins) => boolean(),
          optional(:access_account_state_id) => access_account_state_id(),
          optional(:access_account_state_name) => access_account_name()
        }

  @type access_account_state_id() :: MsbmsSystEnums.Types.enum_item_id()

  @type access_account_state_name() :: MsbmsSystEnums.Types.enum_item_name()

  @type credential_type_id() :: MsbmsSystEnums.Types.enum_item_id()

  @type credential_type_name() :: MsbmsSystEnums.Types.enum_item_name()

  @type identity_id() :: Ecto.UUID.t()

  @type identity_type_id() :: MsbmsSystEnums.Types.enum_item_id()
end
