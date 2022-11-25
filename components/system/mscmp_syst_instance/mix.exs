# Source File: mix.exs
# Location:    musebms/components/system/mscmp_syst_instance/mix.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystInstance.MixProject do
  use Mix.Project

  @name :mscmp_syst_instance
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
        name: "MscmpSystInstance",
        nest_modules_by_prefix: [MscmpSystInstance.Data],
        main: "MscmpSystInstance",
        output: "../../../documentation/technical/app_server/mscmp_syst_instance",
        deps: [
          mscmp_syst_utils: "../../../../documentation/technical/app_server/mscmp_syst_utils",
          mscmp_syst_error: "../../../../documentation/technical/app_server/mscmp_syst_error",
          mscmp_syst_db: "../../../../documentation/technical/app_server/mscmp_syst_db",
          mscmp_syst_enums: "../../../../documentation/technical/app_server/mscmp_syst_enums",
          mscmp_syst_options: "../../../../documentation/technical/app_server/mscmp_syst_options"
        ],
        groups_for_functions: [
          Owners: &(&1[:section] == :owner_data),
          "Instance Types": &(&1[:section] == :instance_type_data),
          Instances: &(&1[:section] == :instance_data),
          Runtime: &(&1[:section] == :service_management)
        ],
        groups_for_modules: [
          API: [MscmpSystInstance],
          Data: [
            Msdata.SystApplicationContexts,
            Msdata.SystApplications,
            Msdata.SystInstanceContexts,
            Msdata.SystInstanceTypeApplications,
            Msdata.SystInstanceTypeContexts,
            Msdata.SystInstances,
            Msdata.SystOwners
          ],
          "Supporting Types": [MscmpSystInstance.Types]
        ]
      ]
    ]
  end

  def application do
    [
      extra_applications: [
        :logger
      ],
      mod: {MscmpSystInstance.Runtime.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: elixirc_paths() ++ ["test/support"]
  defp elixirc_paths(:dev), do: elixirc_paths() ++ ["dev_support"]
  defp elixirc_paths(_), do: elixirc_paths()
  defp elixirc_paths(), do: ["lib"]
end
