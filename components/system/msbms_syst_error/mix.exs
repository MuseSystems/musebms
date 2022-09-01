defmodule MsbmsSystError.MixProject do
  use Mix.Project

  @name :msbms_syst_error
  @version "0.1.0"

  @deps [
    # Third Party Dependencies
    {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
    {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
    {:ex_doc, "~> 0.20", only: :dev, runtime: false}

    # Muse Systems Business Management System Components
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
      docs: [
        name: "MsbmsSystError",
        main: "MsbmsSystError",
        output: "../../../documentation/technical/app_server/msbms_syst_error",
        groups_for_functions: [
          "API - Error Parsing": &(&1[:section] == :error_parsing)
        ],
        groups_for_modules: [
          API: [MsbmsSystError],
          "Supporting Types": [MsbmsSystError.Types]
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
