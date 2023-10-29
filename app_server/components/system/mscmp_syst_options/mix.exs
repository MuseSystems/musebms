# Source File: mix.exs
# Location:    musebms/components/system/mscmp_syst_options/mix.exs
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

  @name :mscmp_syst_options
  @version "0.1.0"

  @deps [
    # Third Party Dependencies
    {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
    {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
    {:ex_doc, "~> 0.20", only: :dev, runtime: false},
    {:toml, "~> 0.7"},

    # Muse Systems Business Management System Components
    {:mscmp_syst_error, path: "../mscmp_syst_error"},
    {:mscmp_syst_db, path: "../mscmp_syst_db"}
  ]

  @dialyzer_opts [
    flags: ["-Wunmatched_returns", :error_handling, :underspecs],
    plt_add_apps: [:mix, :ex_unit]
  ]

  # ------------------------------------------------------------

  def project do
    in_production = Mix.env() == :prod

    [
      app: @name,
      version: @version,
      elixir: "~> 1.15",
      deps: @deps,
      build_embedded: in_production,
      start_permanent: in_production,
      dialyzer: @dialyzer_opts,
      docs: [
        name: "MscmpSystOptions",
        main: "MscmpSystOptions",
        output: "../../../../documentation/technical/app_server/mscmp_syst_options",
        deps: [
          mscmp_syst_db: "../../../../documentation/technical/app_server/mscmp_syst_db",
          mscmp_syst_error: "../../../../documentation/technical/app_server/mscmp_syst_error"
        ],
        groups_for_functions: [
          "File Handling": &(&1[:section] == :file_handling),
          Parsing: &(&1[:section] == :options_parsing)
        ],
        groups_for_modules: [
          API: [MscmpSystOptions],
          "Supporting Types": [MscmpSystOptions.Types]
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
