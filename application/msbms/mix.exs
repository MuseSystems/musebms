# Source File: mix.exs
# Location:    musebms/application/msbms/mix.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule Msbms.MixProject do
  use Mix.Project

  @name :msbms
  @version "0.1.0"

  @deps [
    # Third Party Dependencies
    {:phoenix, "~> 1.7.0-rc.0", override: true},
    {:phoenix_html, "~> 3.0"},
    {:phoenix_live_reload, "~> 1.2", only: :dev},
    {:phoenix_live_view, "~> 0.18.3"},
    {:heroicons, "~> 0.5"},
    {:floki, ">= 0.30.0", only: :test},
    {:phoenix_live_dashboard, "~> 0.7.2"},
    {:esbuild, "~> 0.5", runtime: Mix.env() == :dev},
    {:tailwind, "~> 0.1.8", runtime: Mix.env() == :dev},
    {:swoosh, "~> 1.3"},
    {:finch, "~> 0.13"},
    {:telemetry_metrics, "~> 0.6"},
    {:telemetry_poller, "~> 1.0"},
    {:gettext, "~> 0.20"},
    {:jason, "~> 1.2"},
    {:plug_cowboy, "~> 2.5"},
    {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
    {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
    {:ex_doc, "~> 0.20", only: :dev, runtime: false},
    {:gradient, github: "esl/gradient", only: [:dev], runtime: false},

    # Muse Systems Business Management System Components
    {:mssub_mcp, path: "../../subsystems/mssub_mcp"}
  ]

  @dialyzer_opts [
    flags: ["-Wunmatched_returns", :error_handling, :underspecs],
    plt_add_apps: [:mix]
  ]

  # Aliases were defined in the original phx.new mix.exs.  Not sure how
  # important or necessary they are... I expect not very, but am keeping them
  # just in case.
  @aliases [
    setup: ["deps.get"],
    "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"]
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
      aliases: @aliases,
      dialyzer: @dialyzer_opts,
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  def application do
    [
      mod: {Msbms.Application, []},
      # built-in apps that need starting
      extra_applications: [:logger, :runtime_tools, :crypto, :mnesia]
    ]
  end

  defp elixirc_paths(:dev), do: elixirc_paths() ++ ["dev_support"]
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: elixirc_paths()
  defp elixirc_paths(), do: ["lib"]
end
