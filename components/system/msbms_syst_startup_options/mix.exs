defmodule MsbmsSystStartupOptions.MixProject do
 use Mix.Project

  @name :msbms_syst_startup_options
  @version "0.1.0"

  @deps [
    {:ecto,      ">= 0.0.0"},
    {:toml,      ">= 0.0.0"},
    {:dialyxir,  "~> 1.0", only: [:dev], runtime: false},
    {:credo,     "~> 1.6", only: [:dev, :test], runtime: false}
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
