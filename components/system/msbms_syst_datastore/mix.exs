defmodule MsbmsSystDatastore.MixProject do
  use Mix.Project

  @name :msbms_syst_datastore
  @version "0.1.0"

  @deps [
    # Third Party Dependencies
    {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
    {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
    {:ecto_sql, "== 3.7.2"},
    {:ecto, "== 3.7.2"},
    {:ex_doc, "~> 0.20", only: :dev, runtime: false},
    {:jason, "~> 1.0"},
    {:postgrex, "~> 0.10"},
    {:toml, "~> 0.6"},

    # Muse Systems Business Management System Components
    {:msbms_syst_error, path: "../msbms_syst_error"}
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
      dialyzer: @dialyzer_opts
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
