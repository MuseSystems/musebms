# Source File: types.ex
# Location:    musebms/app_server/components/system/mscmp_syst_forms/lib/types.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystForms.Types do
  @type display_mode() ::
          :deemphasis
          | :reference
          | :normal
          | :emphasis
          | :warning
          | :alert
          | :approve
          | :deny
          | :info

  @type component_mode() :: :removed | :hidden | :cleared | :processing | :visible | :entry
end

defmodule MscmpSystForms.Types.FormConfig do
  @type t() :: %__MODULE__{
          form_id: atom() | nil,
          binding_id: atom() | nil,
          permission: atom() | nil,
          label: String.t() | nil,
          label_link: String.t() | nil,
          info: String.t() | nil,
          button_state: atom() | nil,
          children: list(t()) | [] | nil
        }

  defstruct form_id: nil,
            binding_id: nil,
            permission: nil,
            label: nil,
            label_link: nil,
            info: nil,
            button_state: nil,
            children: []
end

defmodule MscmpSystForms.Types.ComponentConfig do
  @type t() :: %__MODULE__{
          form_id: atom() | nil,
          binding_id: atom() | nil,
          permission: atom() | nil,
          label: String.t() | nil,
          label_link: String.t() | nil,
          info: String.t() | nil,
          button_state: atom() | nil,
          overrides: list(atom()) | nil,
          modes: map()
        }

  defstruct form_id: nil,
            binding_id: nil,
            permission: nil,
            label: nil,
            label_link: nil,
            info: nil,
            button_state: nil,
            overrides: nil,
            modes: nil
end
