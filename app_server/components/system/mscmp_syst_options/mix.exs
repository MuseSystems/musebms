# Source File: mix.exs
# Location:    musebms/app_server/components/system/mscmp_syst_options/mix.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystOptions.MixProject do
  use Mix.Project

  Code.require_file(Path.expand("../../../../tools/build_tools/build_config/msbms_build_config.exs", __DIR__))

  @name :mscmp_syst_options
  @version "0.1.0"

  @third_party_deps [
    :credo,
    :dialyxir,
    :ex_doc,
    :toml
  ]

  @msbms_deps [
    :mscmp_syst_error,
    :mscmp_syst_db
  ]

  # ------------------------------------------------------------

  def project do
    in_production = Mix.env() == :prod

    [
      app: @name,
      version: @version,
      elixir: MsbmsBuildConfig.versions().elixir,
      deps: MsbmsBuildConfig.resolve_deps(@third_party_deps ++ @msbms_deps),
      build_embedded: in_production,
      start_permanent: in_production,
      dialyzer: MsbmsBuildConfig.dialyzer_config(),
      docs: [
        name: "MscmpSystOptions",
        main: "MscmpSystOptions",
        output: "../../../../documentation/technical/app_server/mscmp_syst_options",
        deps: MsbmsBuildConfig.resolve_dep_docs(@msbms_deps),
        groups_for_docs: [
          "File Handling": &(&1[:section] == :file_handling),
          Parsing: &(&1[:section] == :options_parsing)
        ],
        groups_for_modules: [
          API: [MscmpSystOptions],
          "Supporting Types": [MscmpSystOptions.Types],
          Exceptions: [Mserror.OptionsError]
        ]
      ]
    ]
  end

  def application do
    [
      extra_applications: [
        :logger
      ]
    ]
  end
end
