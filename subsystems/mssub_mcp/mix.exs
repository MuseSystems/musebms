# Source File: mix.exs
# Location:    musebms/subsystems/mssub_mcp/mix.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MssubMcp.MixProject do
  use Mix.Project

  @name :mssub_mcp
  @version "0.1.0"

  @deps [
    # Third Party Dependencies
    {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
    {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
    {:ex_doc, "~> 0.20", only: :dev, runtime: false},
    {:gradient, github: "esl/gradient", only: [:dev], runtime: false},

    # Muse Systems Business Management System Components
    {:mscmp_syst_utils, path: "../../components/system/mscmp_syst_utils"},
    {:mscmp_syst_error, path: "../../components/system/mscmp_syst_error"},
    {:mscmp_syst_options, path: "../../components/system/mscmp_syst_options"},
    {:mscmp_syst_enums, path: "../../components/system/mscmp_syst_enums"},
    {:mscmp_syst_settings, path: "../../components/system/mscmp_syst_settings"},
    {:mscmp_syst_instance, path: "../../components/system/mscmp_syst_instance"},
    {:mscmp_syst_authn, path: "../../components/system/mscmp_syst_authn"}
  ]

  @dialyzer_opts [
    flags: ["-Wunmatched_returns", :error_handling, :underspecs],
    plt_add_apps: [:mix]
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
      dialyzer: @dialyzer_opts,
      elixirc_paths: elixirc_paths(Mix.env()),
      docs: [
        name: "MssubMcp",
        main: "MssubMcp",
        output: "../../documentation/technical/app_server/mssub_mcp",
        deps: [
          mscmp_syst_db: "../mscmp_syst_db",
          mscmp_syst_error: "../mscmp_syst_error",
          mscmp_syst_utils: "../mscmp_syst_utils",
          mscmp_syst_limiter: "../mscmp_syst_limiter",
          mscmp_syst_enums: "../mscmp_syst_enums",
          mscmp_syst_options: "../mscmp_syst_options",
          mscmp_syst_instance: "../mscmp_syst_instance",
          mscmp_syst_authn: "../mscmp_syst_authn"
        ],
        groups_for_functions: [],
        groups_for_modules: [
          API: [MssubMcp],
          "Supporting Types": []
        ]
      ]
    ]
  end

  def application do
    [
      extra_applications: [
        :logger,
        :crypto,
        :mnesia
      ],
      mod: {MssubMcp.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: elixirc_paths() ++ ["test/support"]
  defp elixirc_paths(:dev), do: elixirc_paths() ++ ["dev_support"]
  defp elixirc_paths(_), do: elixirc_paths()
  defp elixirc_paths(), do: ["lib"]
end
