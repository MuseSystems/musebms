# Source File: mscmp_syst_app_subsystem.ex
# Location:    musebms/components/system/mscmp_syst_app_subsystem/lib/mscmp_syst_app_subsystem.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystAppSubsystem do
  @external_resource "README.md"

  @moduledoc File.read!(Path.join([__DIR__, "..", "README.md"]))

  alias MscmpSystAppSubsystem.Types

  @doc """
  Allows for the retrieval of required data with which to bootstrap the
  Application Subsystem in the database.
  """
  @callback app_spec() :: Types.application()
end
