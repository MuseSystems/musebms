# Source File: context.ex
# Location:    musebms/app_server/components/system/mscmp_syst_error/lib/api/types/context.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystError.Types.Context do
  @moduledoc """
  Defines the Context data which a MscmpSystError exception can be associated
  with in a standard way.

  Note that one should not expect that any given exception will provide context
  data, but it is expected that any exception which does provide context data
  will use this module's definitions and structure.
  """

  @typedoc """
  Represents the context associated with a MscmpSystError exception.

  ## Attributes

    * `:parameters`: A map of function parameters and their values which were
      in effect when the error was encountered.

    * `:origin`: A tuple containing the module, function, and arity where the
      error originated, or `nil` if unknown.

    * `:supporting_data`: Any additional data that might be relevant to the
      error or exception, or `nil` if not provided.
  """
  @type t :: %__MODULE__{
          parameters: map() | nil,
          origin: {module(), function(), arity()} | nil,
          supporting_data: term() | nil
        }

  defstruct parameters: nil,
            origin: nil,
            supporting_data: nil
end
