defmodule MsbmsSystAuthentication.MixProject do
  use Mix.Project

  @name :msbms_syst_authentication
  @version "0.1.0"

  @deps [
    # Third Party Dependencies
    {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
    {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
    {:ex_doc, "~> 0.20", only: :dev, runtime: false},
    {:argon2_elixir, "~> 3.0"},
    {:nimble_totp, "~> 0.1.0"},

    # Muse Systems Business Management System Components
    {:msbms_syst_utils, path: "../msbms_syst_utils"},
    {:msbms_syst_error, path: "../msbms_syst_error"},
    {:msbms_syst_rate_limiter, path: "../msbms_syst_rate_limiter"},
    {:msbms_syst_datastore, path: "../msbms_syst_datastore"},
    {:msbms_syst_enums, path: "../msbms_syst_enums"},
    {:msbms_syst_options, path: "../msbms_syst_options"},
    {:msbms_syst_instance_mgr, path: "../msbms_syst_instance_mgr"}
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
      elixirc_paths: elixirc_paths(Mix.env()),
      docs: [
        name: "MsbmsSystAuthentication",
        nest_modules_by_prefix: [MsbmsSystAuthentication.Data],
        main: "MsbmsSystAuthentication",
        groups_for_functions: [
          "API - Runtime": &(&1[:section] == :service_management)
        ],
        groups_for_modules: [
          API: [MsbmsSystAuthentication],
          Data: [],
          "Supporting Types": []
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

  defp elixirc_paths(:test), do: elixirc_paths() ++ ["test/support"]
  defp elixirc_paths(_), do: elixirc_paths()
  defp elixirc_paths(), do: ["lib"]
end
