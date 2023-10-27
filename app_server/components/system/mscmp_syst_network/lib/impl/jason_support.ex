# Source File: jason_support.ex
# Location:    musebms/app_server/components/system/mscmp_syst_network/lib/impl/jason_support.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystNetwork.Impl.JasonSupport do
  @moduledoc false

  import MscmpSystNetwork.Guards, only: [is_ip: 1]

  alias MscmpSystNetwork.Types

  # TODO: :noward_function is too broad an exclusion, but the only one that
  #       seems to work.  Dialyzer is complaining about :extra_range, but I
  #       can't find any magic that is either 1) a valid exclusion, 2) actually
  #       does what is expected.  In all cases either I get an error about
  #       invalid options in the attribute or the thing that looks like it might
  #       work, doesn't.  Sigh.  Try and get some guidance: the Erlang and
  #       Elixir documentation is just wholly inadequate to understand what
  #       dialyzer wants to hear from me.

  @dialyzer {:nowarn_function, encode: 2}
  @spec encode(Types.addr_structs(), Jason.Encoder.opts()) :: iodata()
  def encode(addr, opts) when is_ip(addr),
    do: addr |> MscmpSystNetwork.to_string() |> Jason.Encode.string(opts)
end
