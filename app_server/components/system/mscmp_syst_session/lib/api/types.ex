# Source File: types.ex
# Location:    musebms/app_server/components/system/mscmp_syst_session/lib/api/types.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystSession.Types do
  @moduledoc """
  Data types defined by and for use with the `McmpSystSession` component.
  """

  @typedoc """
  The internal reference to the session in the store.
  """
  @type session_name :: binary()

  @typedoc """
  The session contents, the final data to be stored after it has been built
  with `Plug.Conn.put_session/3` and the other session manipulating functions.
  """
  @type session_data :: map()

  @type session_params() :: %{
          optional(:internal_name) => session_name(),
          optional(:session_data) => session_data(),
          optional(:session_expires) => DateTime.t()
        }
end
