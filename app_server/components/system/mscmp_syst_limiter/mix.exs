# Source File: mix.exs
# Location:    musebms/components/system/mscmp_syst_limiter/mix.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystLimiter.MixProject do
  use Mix.Project

  @name :mscmp_syst_limiter
  @version "0.1.0"

  @deps [
    # Third Party Dependencies
    {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
    {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
    {:ex_doc, "~> 0.31", only: :dev, runtime: false},
    {:hammer, "~> 6.1"},

    # Muse Systems Business Management System Components
    {:mscmp_syst_error, path: "../mscmp_syst_error"},
    {:mscmp_syst_utils_string, path: "../mscmp_syst_utils_string"}
  ]

  @dialyzer_opts [
    flags: ["-Wunmatched_returns", :error_handling],
    plt_add_apps: [:mix, :hammer, :ex_unit],
    plt_core_path: "priv/plts",
    plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
  ]

  # ------------------------------------------------------------

  def project do
    in_production = Mix.env() == :prod

    [
      app: @name,
      version: @version,
      elixir: "~> 1.17",
      deps: @deps,
      build_embedded: in_production,
      start_permanent: in_production,
      dialyzer: @dialyzer_opts,
      elixirc_paths: elixirc_paths(Mix.env()),
      docs: [
        name: "MscmpSystLimiter",
        main: "MscmpSystLimiter",
        output: "../../../../documentation/technical/app_server/mscmp_syst_limiter",
        deps: [
          mscmp_syst_error: "../../../../documentation/technical/app_server/mscmp_syst_error",
          mscmp_syst_utils_string:
            "../../../../documentation/technical/app_server/mscmp_syst_utils_string"
        ],
        groups_for_docs: [
          "Rate Limiter": &(&1[:section] == :rate_limiter_data),
          Runtime: &(&1[:section] == :service_management)
        ],
        groups_for_modules: [
          API: [MscmpSystLimiter],
          "Supporting Types": [MscmpSystLimiter.Types]
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

  defp elixirc_paths(:test), do: elixirc_paths() ++ ["test/support"]
  defp elixirc_paths(_), do: elixirc_paths()
  defp elixirc_paths(), do: ["lib"]
end
