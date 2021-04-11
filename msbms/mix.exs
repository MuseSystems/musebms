defmodule Msbms.MixProject do
  use Mix.Project

  @name    :msbms
  @version "0.1.0"

  @deps [
    {:mix_test_watch, ">= 0.0.0", only: :dev, runtime: false},
    {:postgrex, ">= 0.0.0"},
    {:ecto, ">= 0.0.0"},
    {:ecto_sql, ">= 0.0.0"},
    {:jason, ">= 0.0.0"},
    {:toml, ">= 0.0.0"},
    {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
  ]

  # ------------------------------------------------------------

  def project do
    in_production = Mix.env == :prod
    [
      app:     @name,
      version: @version,
      elixir:  "~> 1.11",
      deps:    @deps,
      build_embedded:  in_production,
      start_permanent: in_production
    ]
  end

  def application do
    [
      extra_applications: [         # built-in apps that need starting
        :logger
      ],
    ]
  end
end
