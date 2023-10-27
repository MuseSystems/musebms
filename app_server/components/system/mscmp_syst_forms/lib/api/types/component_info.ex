# Source File: component_info.ex
# Location:    musebms/app_server/components/system/mscmp_syst_forms/lib/api/types/component_info.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystForms.Types.ComponentInfo do
  @moduledoc """
  This struct identifies the specific returned textual information describing
  the component and configured in the Form Configurations.
  """

  defstruct [:label, :label_link, :info]

  @typedoc """
  This struct identifies the specific returned textual information describing
  the component and configured in the Form Configurations.

  See `t:MscmpSystForms.Types.ComponentConfig.t/0` for information regarding the
  attributes here.
  """
  @type t :: %__MODULE__{
          label: String.t() | nil,
          label_link: String.t() | nil,
          info: String.t() | nil
        }
end
