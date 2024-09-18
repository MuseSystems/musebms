# Source File: helpers.ex
# Location:    musebms/app_server/components/system/mscmp_syst_instance/lib/impl/msdata/helpers.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystInstance.Impl.Msdata.Helpers do
  @moduledoc false

  @option_defs [
    min_internal_name_length: [
      type: :non_neg_integer,
      default: 6,
      doc: "Minimum length for internal names"
    ],
    max_internal_name_length: [
      type: :pos_integer,
      default: 64,
      doc: "Maximum length for internal names"
    ],
    min_display_name_length: [
      type: :non_neg_integer,
      default: 6,
      doc: "Minimum length for display names"
    ],
    max_display_name_length: [
      type: :pos_integer,
      default: 64,
      doc: "Maximum length for display names"
    ],
    min_context_code_length: [
      type: :non_neg_integer,
      default: 8,
      doc: "Minimum length for context codes"
    ],
    max_context_code_length: [
      type: :pos_integer,
      default: 64,
      doc: "Maximum length for context codes"
    ],
    min_instance_code_length: [
      type: :non_neg_integer,
      default: 8,
      doc: "Minimum length for instance codes"
    ],
    max_instance_code_length: [
      type: :pos_integer,
      default: 64,
      doc: "Maximum length for instance codes"
    ]
  ]

  @spec validator_options(list(atom())) :: Macro.t()
  defmacro validator_options(option_names) do
    wanted_opts = Keyword.take(@option_defs, option_names)

    quote do
      unquote(Macro.escape(NimbleOptions.new!(wanted_opts)))
    end
  end
end
