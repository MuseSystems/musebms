# Source File: mix.exs
# Location:    musebms/app_server/platform/msplatform/mix.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msplatform.MixProject do
  use Mix.Project

  @apps_path "apps"
  @version "0.1.0"

  @deps [
    # Third Party Dependencies
    {:phoenix_live_view, "~> 0.19"},
    {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
    {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
    {:ex_doc, "~> 0.20", only: :dev, runtime: false}
  ]

  @dialyzer_opts [
    flags: ["-Wunmatched_returns", :error_handling, :underspecs],
    plt_add_apps: [:mix, :ex_unit]
  ]

  @aliases [setup: ["cmd mix setup"]]

  # ------------------------------------------------------------

  def project do
    in_production = Mix.env() == :prod

    [
      name: "Msplatform",
      apps_path: @apps_path,
      version: @version,
      elixir: "~> 1.15",
      deps: @deps,
      aliases: @aliases,
      start_permanent: in_production,
      dialyzer: @dialyzer_opts,
      docs: [
        output: "../../../documentation/technical/app_server/msplatform",
        deps: [],
        groups_for_functions: [],
        nest_modules_by_prefix: [],
        groups_for_modules: []
      ],
      releases: [
        msplatform: [
          applications: [
            msapp_mcp: :permanent,
            msapp_mcp_web: :permanent
          ]
        ]
      ]
    ]
  end
end
