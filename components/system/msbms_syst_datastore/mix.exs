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
    {:toml,
     git: "https://github.com/MuseSystems/toml-elixir.git",
     branch: "feature/typeless-arrays-with-tests"},

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
      elixir: "~> 1.13",
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
            MsbmsSystDatastore.DbTypes.TimestampRange
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
