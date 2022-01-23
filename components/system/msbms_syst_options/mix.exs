defmodule MsbmsSystOptions.MixProject do
 use Mix.Project

  @name :msbms_syst_options
  @version "0.1.0"

  @deps [
    {:credo,            "~> 1.6",  only: [:dev, :test], runtime: false},
    {:dialyxir,         "~> 1.0",  only: [:dev], runtime: false},
    {:ex_doc,           "~> 0.27", only: :dev, runtime: false},
    {:toml,             ">= 0.0.0"},

    {:msbms_syst_error, path: "../msbms_syst_error"}
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
