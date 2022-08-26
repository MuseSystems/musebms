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
    plt_add_apps: [:mix, :hammer, :hammer_backend_mnesia]
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
      elixirc_paths: elixirc_paths(Mix.env()),
      docs: [
        name: "MsbmsSystRateLimiter",
        main: "MsbmsSystRateLimiter",
        output: "../../../documentation/technical/app_server/msbms_syst_rate_limiter",
        deps: [
          msbms_syst_error: "../../../../documentation/technical/app_server/msbms_syst_error",
          msbms_syst_utils: "../../../../documentation/technical/app_server/msbms_syst_utils"
        ],
        groups_for_functions: [
          "API - Rate Limiter": &(&1[:section] == :rate_limiter_data),
          "API - Runtime": &(&1[:section] == :service_management)
        ],
        groups_for_modules: [
          API: [MsbmsSystRateLimiter],
          "Supporting Types": [MsbmsSystRateLimiter.Types]
        ]
      ]
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

  defp elixirc_paths(:test), do: elixirc_paths() ++ ["test/support"]
  defp elixirc_paths(_), do: elixirc_paths()
  defp elixirc_paths(), do: ["lib"]
end
