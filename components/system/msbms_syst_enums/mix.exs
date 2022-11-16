# Source File: mix.exs
# Location:    musebms/components/system/msbms_syst_enums/mix.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystEnums.MixProject do
  use Mix.Project

  @name :msbms_syst_enums
  @version "0.1.0"

  @deps [
    # Third Party Dependencies
    {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
    {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
    {:ex_doc, "~> 0.20", only: :dev, runtime: false},
    {:gradient, github: "esl/gradient", only: [:dev], runtime: false},

    # Muse Systems Business Management System Components
    {:mscmp_syst_error, path: "../mscmp_syst_error"},
    {:mscmp_syst_utils, path: "../mscmp_syst_utils"},
    {:mscmp_syst_db, path: "../mscmp_syst_db"}
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
      deps: [
        mscmp_syst_db: "../../../../documentation/technical/app_server/mscmp_syst_db",
        mscmp_syst_error: "../../../../documentation/technical/app_server/mscmp_syst_error",
        mscmp_syst_utils: "../../../../documentation/technical/app_server/mscmp_syst_utils"
      ],
      docs: [
        name: "MsbmsSystEnums",
        main: "MsbmsSystEnums",
        output: "../../../documentation/technical/app_server/msbms_syst_enums",
        nest_modules_by_prefix: [MsbmsSystEnums.DbTypes],
        groups_for_functions: [
          "API - Enumerations": &(&1[:section] == :enum_data),
          "API - Enumeration Functional Types": &(&1[:section] == :enum_functional_type_data),
          "API - Enumeration items": &(&1[:section] == :enum_item_data),
          "API - Runtime": &(&1[:section] == :service_management)
        ],
        groups_for_modules: [
          API: [MsbmsSystEnums],
          Data: [
            MsbmsSystEnums.Data.SystEnums,
            MsbmsSystEnums.Data.SystEnumFunctionalTypes,
            MsbmsSystEnums.Data.SystEnumItems
          ],
          "Supporting Types": [MsbmsSystEnums.Types]
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
  defp elixirc_paths(:dev), do: elixirc_paths() ++ ["dev_support"]
  defp elixirc_paths(_), do: elixirc_paths()
  defp elixirc_paths(), do: ["lib"]
end
