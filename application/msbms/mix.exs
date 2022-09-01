defmodule Msbms.MixProject do
  use Mix.Project

  @name :msbms
  @version "0.1.0"

  @deps [
    # Third Party Dependencies
    {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
    {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
    {:ex_doc, "~> 0.20", only: :dev, runtime: false},

    # Muse Systems Business Management System Components
    {:msbms_syst_error, path: "../../components/system/msbms_syst_error"},
    {:msbms_syst_options, path: "../../components/system/msbms_syst_options"},
    {:msbms_syst_datastore, path: "../../components/system/msbms_syst_datastore"}
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
      start_permanent: in_production
    ]
  end

  def application do
    [
      mod: {Msbms.Application, []},
      # built-in apps that need starting
      extra_applications: [
        :logger
      ]
    ]
  end
end
