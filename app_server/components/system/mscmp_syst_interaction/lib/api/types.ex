# Source File: types.ex
# Location:    musebms/app_server/components/system/mscmp_syst_interaction/lib/api/types.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystInteraction.Types do
  @moduledoc """
  Simple types defined and used by the MscmpSystInteraction Component.
  """

  alias MscmpSystInteraction.Types

  #
  # Note that the ordering of typespecs here is alphabetical.
  #

  @type context_mode() :: :unlocked | {:locked, locking_agent()} | :maintenance

  @typedoc """
  The Internal Name of an Interaction Context.
  """
  @type context_name() :: String.t()

  @type context_data() ::
          {context_name(), context_mode(), Types.ContextConfig.t()}

  @type locking_agent() :: :system | term() | nil

  @typedoc """
  The valid forms of service name acceptable to identify the Interaction Context
  service.

  Currently we expect the service name to be an atom, though we expect that any
  of a simple local name, the :global registry, or the Registry module to be
  used for service registration. Any registry compatible with those options
  should also work.
  """
  @type service_name() :: GenServer.name() | nil

  @typedoc """
  The available modes in which instances of the Interaction State management
  GenServer can be operating.  The available modes are:

  * `new` - the data being represented is "new" in the sense that the user is
  creating the data rather than simply viewing or maintaining existing data.

  * `existing` - the data is based on preexisting data retrieved from the
  database or similar.
  """
  @type state_modes() :: :new | :read | :change
end
