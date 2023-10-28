# Source File: mix.exs
# Location:    musebms/app_server/components/system/mscmp_syst_forms/mix.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystForms.MixProject do
  use Mix.Project

  @name :mscmp_syst_forms
  @version "0.1.0"

  @deps [
    # Third Party Dependencies
    {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
    {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
    {:ex_doc, "~> 0.20", only: :dev, runtime: false},
    {:phoenix, "~> 1.7"},
    {:phoenix_live_view, "~> 0.19"},
    {:phoenix_ecto, "~> 4.0"},
    {:gettext, "~> 0.20"},

    # Muse Systems Business Management System Components
    {:mscmp_syst_utils, path: "../mscmp_syst_utils"},
    {:mscmp_syst_error, path: "../mscmp_syst_error"},
    {:mscmp_syst_perms, path: "../mscmp_syst_perms"}
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
      elixir: "~> 1.15",
      deps: @deps,
      build_embedded: in_production,
      start_permanent: in_production,
      dialyzer: @dialyzer_opts,
      elixirc_paths: elixirc_paths(Mix.env()),
      docs: [
        name: "MscmpSystForms",
        main: "MscmpSystForms",
        output: "../../../../documentation/technical/app_server/mscmp_syst_forms",
        deps: [
          mscmp_syst_utils: "../../../../documentation/technical/app_server/mscmp_syst_utils",
          mscmp_syst_error: "../../../../documentation/technical/app_server/mscmp_syst_error",
          mscmp_syst_db: "../../../../documentation/technical/app_server/mscmp_syst_db"
        ],
        groups_for_functions: [
          Containers: &(&1[:section] == :container_components),
          Controls: &(&1[:section] == :control_components),
          Inputs: &(&1[:section] == :input_components),
          Utility: &(&1[:section] == :utility_components),
          "Form Definition": &(&1[:section] == :form_definition),
          "Form Generation": &(&1[:section] == :form_generation),
          "Form Data Management": &(&1[:section] == :data_management),
          "State Management": &(&1[:section] == :state_management),
          Macros: &(&1[:section] == :macros)
        ],
        nest_modules_by_prefix: [MscmpSystForms.WebComponents],
        groups_for_modules: [
          API: [MscmpSystForms],
          "Web Components": [MscmpSystForms.WebComponents],
          "Supporting Types": [
            MscmpSystForms.Types,
            MscmpSystForms.Types.ComponentConfig,
            MscmpSystForms.Types.FormConfig
          ]
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
