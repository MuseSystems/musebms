# Source File: mix.exs
# Location:    musebms/components/system/msbms_syst_instance_mgr/mix.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystInstanceMgr.MixProject do
  use Mix.Project

  @name :msbms_syst_instance_mgr
  @version "0.1.0"

  @deps [
    # Third Party Dependencies
    {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
    {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
    {:ex_doc, "~> 0.20", only: :dev, runtime: false},
    {:gradient, github: "esl/gradient", only: [:dev], runtime: false},

    # Muse Systems Business Management System Components
    {:mscmp_syst_utils, path: "../mscmp_syst_utils"},
    {:mscmp_syst_error, path: "../mscmp_syst_error"},
    {:mscmp_syst_db, path: "../mscmp_syst_db"},
    {:mscmp_syst_enums, path: "../mscmp_syst_enums"},
    {:mscmp_syst_options, path: "../mscmp_syst_options"}
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
        name: "MsbmsSystInstanceMgr",
        nest_modules_by_prefix: [MsbmsSystInstanceMgr.Data],
        main: "MsbmsSystInstanceMgr",
        output: "../../../documentation/technical/app_server/msbms_syst_instance_mgr",
        deps: [
          mscmp_syst_utils: "../../../../documentation/technical/app_server/mscmp_syst_utils",
          mscmp_syst_error: "../../../../documentation/technical/app_server/mscmp_syst_error",
          mscmp_syst_db: "../../../../documentation/technical/app_server/mscmp_syst_db",
          mscmp_syst_enums: "../../../../documentation/technical/app_server/mscmp_syst_enums",
          mscmp_syst_options: "../../../../documentation/technical/app_server/mscmp_syst_options"
        ],
        groups_for_functions: [
          "API - Runtime": &(&1[:section] == :service_management),
          "API - Instances": &(&1[:section] == :instance_data),
          "API - Instance Types": &(&1[:section] == :instance_type_data),
          "API - Owners": &(&1[:section] == :owner_data)
        ],
        groups_for_modules: [
          API: [MsbmsSystInstanceMgr],
          Data: [
            MsbmsSystInstanceMgr.Data.SystApplicationContexts,
            MsbmsSystInstanceMgr.Data.SystApplications,
            MsbmsSystInstanceMgr.Data.SystInstanceContexts,
            MsbmsSystInstanceMgr.Data.SystInstanceTypeApplications,
            MsbmsSystInstanceMgr.Data.SystInstanceTypeContexts,
            MsbmsSystInstanceMgr.Data.SystInstances,
            MsbmsSystInstanceMgr.Data.SystOwners
          ],
          "Supporting Types": [MsbmsSystInstanceMgr.Types]
        ]
      ]
    ]
  end

  def application do
    [
      extra_applications: [
        :logger
      ],
      mod: {MsbmsSystInstanceMgr.Runtime.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: elixirc_paths() ++ ["test/support"]
  defp elixirc_paths(:dev), do: elixirc_paths() ++ ["dev_support"]
  defp elixirc_paths(_), do: elixirc_paths()
  defp elixirc_paths(), do: ["lib"]
end
