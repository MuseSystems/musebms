# Source File: mix.exs
# Location:    musebms/components/system/msbms_syst_datastore/mix.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsSystDatastore.MixProject do
  use Mix.Project

  @name :msbms_syst_datastore
  @version "0.1.0"

  @deps [
    # Third Party Dependencies
    {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
    {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
    {:ecto_sql, "~> 3.0"},
    {:ecto, "~> 3.0"},
    {:ex_doc, "~> 0.20", only: :dev, runtime: false},
    {:jason, "~> 1.0"},
    {:postgrex, "~> 0.10"},
    {:toml, "~> 0.7"},
    {:gradient, github: "esl/gradient", only: [:dev], runtime: false},
    {:net_address, "~> 0.2.0"},

    # Muse Systems Business Management System Components
    {:msbms_syst_error, path: "../msbms_syst_error"},
    {:msbms_syst_utils, path: "../msbms_syst_utils"}
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
      docs: [
        name: "MsbmsSystDatastore",
        main: "MsbmsSystDatastore",
        output: "../../../documentation/technical/app_server/msbms_syst_datastore",
        deps: [
          msbms_syst_error: "../../../../documentation/technical/app_server/msbms_syst_error",
          msbms_syst_utils: "../../../../documentation/technical/app_server/msbms_syst_utils"
        ],
        nest_modules_by_prefix: [MsbmsSystDatastore.DbTypes],
        groups_for_functions: [
          "API - Query": &(&1[:section] == :query),
          "API - Runtime": &(&1[:section] == :service_management),
          "API - Datastore Migrations": &(&1[:section] == :datastore_migrations),
          "API - Datastore Management": &(&1[:section] == :datastore_management)
        ],
        groups_for_modules: [
          API: [MsbmsSystDatastore],
          "Supporting Types": [MsbmsSystDatastore.Types],
          "Database Types": [
            MsbmsSystDatastore.DbTypes.DateRange,
            MsbmsSystDatastore.DbTypes.DecimalRange,
            MsbmsSystDatastore.DbTypes.Inet,
            MsbmsSystDatastore.DbTypes.IntegerRange,
            MsbmsSystDatastore.DbTypes.Interval,
            MsbmsSystDatastore.DbTypes.DateTimeRange
          ],
          "Datastore Service": [MsbmsSystDatastore.Datastore],
          "Datastore Context Service": [MsbmsSystDatastore.DatastoreContext],
          Schema: [MsbmsSystDatastore.Schema]
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
end
