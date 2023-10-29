# Source File: mix.exs
# Location:    musebms/app_server/platform/msplatform/apps/msapp_mcp/mix.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsappMcp.MixProject do
  use Mix.Project

  @name :msapp_mcp
  @version "0.1.0"

  @deps [
    # Third Party Dependencies
    {:phoenix_pubsub, "~> 2.1"},
    {:swoosh, "~> 1.3"},
    {:finch, "~> 0.13"},
    {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
    {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
    {:ex_doc, "~> 0.20", only: :dev, runtime: false},

    # Muse Systems Business Management System Components
    {:mscmp_syst_error, path: "../../../../components/system/mscmp_syst_error", override: true},
    {:mscmp_syst_options,
     path: "../../../../components/system/mscmp_syst_options", override: true},
    {:mscmp_syst_network,
     path: "../../../../components/system/mscmp_syst_network", override: true},
    {:mscmp_syst_forms, path: "../../../../components/system/mscmp_syst_forms", override: true},
    {:mscmp_syst_perms, path: "../../../../components/system/mscmp_syst_perms", override: true},
    {:mssub_mcp, path: "../../../../subsystems/mssub_mcp", override: true}
  ]

  @dialyzer_opts [
    flags: ["-Wunmatched_returns", :error_handling],
    plt_add_apps: [:mix]
  ]

  @aliases [setup: ["deps.get"]]

  # ------------------------------------------------------------

  def project do
    in_production = Mix.env() == :prod

    [
      app: @name,
      version: @version,
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.15",
      deps: @deps,
      start_permanent: in_production,
      dialyzer: @dialyzer_opts,
      docs: [
        output: "../../../../../documentation/technical/app_server/msapp_mcp",
        deps: [],
        groups_for_functions: [],
        nest_modules_by_prefix: [],
        groups_for_modules: []
      ],
      elixirc_paths: elixirc_paths(Mix.env()),
      aliases: @aliases
    ]
  end

  def application do
    [
      mod: {MsappMcp.Runtime.Application, []},
      extra_applications: [
        :logger,
        :runtime_tools,
        :crypto
      ]
    ]
  end

  defp elixirc_paths(:test), do: elixirc_paths() ++ ["test/support"]
  defp elixirc_paths(:dev), do: elixirc_paths() ++ ["dev_support"]
  defp elixirc_paths(_), do: elixirc_paths()
  defp elixirc_paths(), do: ["lib"]
end
