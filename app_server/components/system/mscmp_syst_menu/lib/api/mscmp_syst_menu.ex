# Source File: mscmp_syst_menu.ex
# Location:    musebms/app_server/components/system/mscmp_syst_menu/lib/api/mscmp_syst_menu.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystMenu do
  @external_resource "README.md"
  @moduledoc Path.join([__DIR__, "..", "..", "README.md"])
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  alias MscmpSystMenu.Impl
  alias MscmpSystMenu.Types
end
