# Source File: mix.exs
# Location:    musebms/components/system/mscmp_syst_error/mix.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystError.MixProject do
  use Mix.Project

  @name :mscmp_syst_error
  @version "0.1.0"

  @deps [
    # Third Party Dependencies
    {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
    {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
    {:ex_doc, "~> 0.20", only: :dev, runtime: false},
    {:gradient, github: "esl/gradient", only: [:dev], runtime: false}

    # Muse Systems Business Management System Components
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
        name: "MscmpSystError",
        main: "MscmpSystError",
        output: "../../../../documentation/technical/app_server/mscmp_syst_error",
        groups_for_functions: [
          "Error Parsing": &(&1[:section] == :error_parsing)
        ],
        groups_for_modules: [
          API: [MscmpSystError],
          "Supporting Types": [MscmpSystError.Types]
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
