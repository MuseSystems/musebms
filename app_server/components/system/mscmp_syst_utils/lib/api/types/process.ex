# Source File: process.ex
# Location:    musebms/app_server/components/system/mscmp_syst_utils/lib/api/types/process.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msutils.Types.Process do
  @moduledoc """
  This module defines process related types used by the MscmpSystUtils library.
  """

  @typedoc """
  The registry to use when either looking up a process `t:pid/0` or
  registering a process's name.

  The currently supported registries are:

  * `:local` - The local registry.  Service names must be atoms.
  * `:global` - The global registry.
  * `{module(), term()}` - A registry module and name.  The registry must
    to usable in `:via` tuple names.  See the `GenServer` documentation
    regarding name registration for details and requirements.
  """
  @type registry :: :local | :global | {module(), term()}

  @typedoc """
  The registry qualified name of a process for use in `t:pid/0` lookups.

  This type is compatible with the `t:GenServer.name/0` type with the
  addition of `t:pid/0` as a valid name.
  """
  @type name :: pid() | atom() | {:global, term()} | {:via, module(), term()}
end
