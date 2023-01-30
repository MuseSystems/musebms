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
    {:phoenix, "~> 1.7.0-rc.1", override: true},
    {:phoenix_live_view, ">= 0.0.0"},
    {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
    {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
    {:ex_doc, "~> 0.20", only: :dev, runtime: false}
  ]

  @dialyzer_opts [
    flags: ["-Wunmatched_returns", :error_handling, :underspecs],
    plt_add_apps: [:mix]
  ]

  @aliases [setup: ["cmd mix setup"]]

  # ------------------------------------------------------------

  def project do
    in_production = Mix.env() == :prod

    [
      apps_path: @apps_path,
      version: @version,
      elixir: "~> 1.14",
      deps: @deps,
      aliases: @aliases,
      start_permanent: in_production,
      dialyzer: @dialyzer_opts
    ]
  end
end