# Source File: component_display_modes.ex
# Location:    musebms/app_server/components/system/mscmp_syst_forms/lib/api/types/component_display_modes.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystForms.Types.ComponentDisplayModes do
  @moduledoc """
  A struct defining the different kinds of display mode data which can be
  communicated to a user interface component.

  User interface components can be configured with a variety of display options,
  called "modes".  Between the functions which generate the effective modes for
  the user interface and the user interface components themselves there must be
  a standard way to communicate and this type defines the structure of that
  communication.

  It is worth noting that the Component will receive its display modes in data
  with this structure.
  """

  alias MscmpSystForms.Types

  defstruct [:component_mode, :border_mode, :text_mode, :label_mode]

  @typedoc """
  A struct defining the different kinds of display mode data which can be
  communicated to a user interface component.

  See `MscmpSystForms.Types.ComponentDisplayModes` for more.
  """
  @type t :: %__MODULE__{
          component_mode: Types.component_modes() | nil,
          border_mode: Types.display_modes() | nil,
          text_mode: Types.display_modes() | list(String.t()) | nil,
          label_mode: Types.display_modes() | list(String.t()) | nil
        }
end
