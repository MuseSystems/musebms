defmodule MsbmsSystRateLimiter.MixProject do
  use Mix.Project

  @name :msbms_syst_rate_limiter
  @version "0.1.0"

  @deps [
    # Third Party Dependencies
    {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
    {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
    {:ex_doc, "~> 0.20", only: :dev, runtime: false},
    {:hammer_backend_mnesia, "~> 0.5", runtime: false},
    {:hammer, "~> 6.0", runtime: false},

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
      dialyzer: @dialyzer_opts
    ]
  end

  def application do
    [
      extra_applications: [
        :logger,
        :mnesia
      ],
      mod: {MsbmsSystRateLimiter.Runtime.Application, []}
    ]
  end
end