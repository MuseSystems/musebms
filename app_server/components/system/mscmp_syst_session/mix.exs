# Source File: mix.exs
# Location:    musebms/app_server/components/system/mscmp_syst_session/mix.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystSession.MixProject do
  use Mix.Project

  @name :mscmp_syst_session
  @version "0.1.0"

  @deps [
    # Third Party Dependencies
    {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
    {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
    {:ex_doc, "~> 0.20", only: :dev, runtime: false},

    # Muse Systems Business Management System Components
    {:mscmp_syst_utils, path: "../mscmp_syst_utils"},
    {:mscmp_syst_error, path: "../mscmp_syst_error"},
    {:mscmp_syst_db, path: "../mscmp_syst_db"}
  ]

  @dialyzer_opts [
    flags: ["-Wunmatched_returns", :error_handling],
    plt_add_apps: [:mix, :ex_unit],
    plt_core_path: "priv/plts",
    plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
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
      elixirc_paths: elixirc_paths(Mix.env()),
      docs: [
        name: "MscmpSystSession",
        main: "MscmpSystSession",
        output: "../../../../documentation/technical/app_server/mscmp_syst_session",
        deps: [
          mscmp_syst_utils: "../../../../documentation/technical/app_server/mscmp_syst_utils",
          mscmp_syst_error: "../../../../documentation/technical/app_server/mscmp_syst_error",
          mscmp_syst_db: "../../../../documentation/technical/app_server/mscmp_syst_db"
        ],
        groups_for_functions: ["Session Management": &(&1[:section] == :session_management)],
        nest_modules_by_prefix: [Msdata],
        groups_for_modules: [
          API: [MscmpSystSession],
          Data: [Msdata.SystSessions],
          "Supporting Types": [MscmpSystSession.Types]
        ]
      ]
    ]
  end

  def application do
    [
      extra_applications: [
        :logger,
        :crypto
      ]
    ]
  end

  defp elixirc_paths(:test), do: elixirc_paths() ++ ["test/support"]
  defp elixirc_paths(:dev), do: elixirc_paths() ++ ["dev_support"]
  defp elixirc_paths(_), do: elixirc_paths()
  defp elixirc_paths(), do: ["lib"]
end
