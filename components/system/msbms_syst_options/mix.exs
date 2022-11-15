# Source File: mix.exs
# Location:    musebms/components/system/msbms_syst_options/mix.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystOptions.MixProject do
  use Mix.Project

  @name :msbms_syst_options
  @version "0.1.0"

  @deps [
    # Third Party Dependencies
    {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
    {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
    {:ex_doc, "~> 0.20", only: :dev, runtime: false},
    {:toml,
     git: "https://github.com/MuseSystems/toml-elixir.git",
     branch: "feature/typeless-arrays-with-tests"},

    # Muse Systems Business Management System Components
    {:msbms_syst_error, path: "../msbms_syst_error"},
    {:msbms_syst_datastore, path: "../msbms_syst_datastore"}
  ]

  # ------------------------------------------------------------

  def project do
    in_production = Mix.env() == :prod

    [
      app: @name,
      version: @version,
      elixir: "~> 1.14",
      deps: @deps,
      build_embedded: in_production,
      start_permanent: in_production,
      docs: [
        name: "MsbmsSystOptions",
        main: "MsbmsSystOptions",
        output: "../../../documentation/technical/app_server/msbms_syst_options",
        deps: [
          msbms_syst_datastore:
            "../../../../documentation/technical/app_server/msbms_syst_datastore",
          msbms_syst_error: "../../../../documentation/technical/app_server/msbms_syst_error"
        ],
        groups_for_functions: [
          "API - File Handling": &(&1[:section] == :file_handling),
          "API - Parsing": &(&1[:section] == :options_parsing)
        ],
        groups_for_modules: [
          API: [MsbmsSystOptions],
          "Supporting Types": [MsbmsSystOptions.Types]
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
