defmodule MsbmsSystDatastore.MixProject do
  use Mix.Project

  @name :msbms_syst_datastore
  @version "0.1.0"

  @deps [
    {:postgrex, "~> 0.16"},
    {:jason,    "~> 1.3"},
    {:credo,    "~> 1.6",  only: [:dev, :test], runtime: false},
    {:dialyxir, "~> 1.0",  only: [:dev], runtime: false},
    {:ex_doc,   "~> 0.27", only: :dev, runtime: false},

    {:msbms_syst_error, path: "../msbms_syst_error"},
  ]

  # ------------------------------------------------------------

  def project do
    in_production = Mix.env() == :prod

    [
      app:             @name,
      version:         @version,
      elixir:          "~> 1.13",
      deps:            @deps,
      build_embedded:  in_production,
      start_permanent: in_production
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
