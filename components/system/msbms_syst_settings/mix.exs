# Source File: mix.exs
# Location:    musebms/components/system/msbms_syst_settings/mix.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystSettings.MixProject do
  use Mix.Project

  @name :msbms_syst_settings
  @version "0.1.0"

  @deps [
    # Third Party Dependencies
    {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
    {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
    {:ex_doc, "~> 0.20", only: :dev, runtime: false},

    # Muse Systems Business Management System Components
    {:msbms_syst_error, path: "../msbms_syst_error"},
    {:msbms_syst_utils, path: "../msbms_syst_utils"},
    {:msbms_syst_datastore, path: "../msbms_syst_datastore"}
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
        name: "MsbmsSystSettings",
        main: "MsbmsSystSettings",
        output: "../../../documentation/technical/app_server/msbms_syst_settings",
        deps: [
          msbms_syst_datastore:
            "../../../../documentation/technical/app_server/msbms_syst_datastore",
          msbms_syst_error: "../../../../documentation/technical/app_server/msbms_syst_error",
          msbms_syst_utils: "../../../../documentation/technical/app_server/msbms_syst_utils"
        ],
        nest_modules_by_prefix: [MsbmsSystSettings.DbTypes],
        groups_for_functions: [
          "API - Settings": &(&1[:section] == :settings_data),
          "API - Runtime": &(&1[:section] == :service_management)
        ],
        groups_for_modules: [
          API: [MsbmsSystSettings],
          "Supporting Types": [MsbmsSystSettings.Types]
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
