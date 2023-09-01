# Source File: mix.exs
# Location:    musebms/components/system/mscmp_syst_authn/mix.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystAuthn.MixProject do
  use Mix.Project

  @name :mscmp_syst_authn
  @version "0.1.0"

  @deps [
    # Third Party Dependencies
    {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
    {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
    {:ex_doc, "~> 0.20", only: :dev, runtime: false},
    {:argon2_elixir, "~> 3.0"},
    {:nimble_totp, "~> 1.0"},
    {:net_address, "~> 0.3.0"},
    {:pathex, "~> 2.0"},
    {:timex, "~> 3.0"},

    # Muse Systems Business Management System Components
    {:mscmp_syst_utils, path: "../mscmp_syst_utils"},
    {:mscmp_syst_error, path: "../mscmp_syst_error"},
    {:mscmp_syst_limiter, path: "../mscmp_syst_limiter"},
    {:mscmp_syst_db, path: "../mscmp_syst_db"},
    {:mscmp_syst_enums, path: "../mscmp_syst_enums"},
    {:mscmp_syst_options, path: "../mscmp_syst_options"},
    {:mscmp_syst_instance, path: "../mscmp_syst_instance"}
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
      elixir: "~> 1.15",
      deps: @deps,
      build_embedded: in_production,
      start_permanent: in_production,
      dialyzer: @dialyzer_opts,
      elixirc_paths: elixirc_paths(Mix.env()),
      docs: [
        name: "MscmpSystAuthn",
        main: "MscmpSystAuthn",
        output: "../../../../documentation/technical/app_server/mscmp_syst_authn",
        deps: [
          mscmp_syst_db: "../../../../documentation/technical/app_server/mscmp_syst_db",
          mscmp_syst_error: "../../../../documentation/technical/app_server/mscmp_syst_error",
          mscmp_syst_utils: "../../../../documentation/technical/app_server/mscmp_syst_utils",
          mscmp_syst_limiter: "../../../../documentation/technical/app_server/mscmp_syst_limiter",
          mscmp_syst_enums: "../../../../documentation/technical/app_server/mscmp_syst_enums",
          mscmp_syst_options: "../../../../documentation/technical/app_server/mscmp_syst_options",
          mscmp_syst_instance:
            "../../../../documentation/technical/app_server/mscmp_syst_instance"
        ],
        groups_for_functions: [
          "Authenticator Management": &(&1[:section] == :authenticator_management),
          Authentication: &(&1[:section] == :authentication),
          "Account Codes": &(&1[:section] == :account_code),
          "Access Accounts": &(&1[:section] == :access_account_data),
          "Access Account Instance Assocs":
            &(&1[:section] == :access_account_instance_assoc_data),
          "Password Rules": &(&1[:section] == :password_rule_data),
          "Network Rules": &(&1[:section] == :network_rule_data),
          "Enumeration Access": &(&1[:section] == :enumerations_data),
          Runtime: &(&1[:section] == :service_management)
        ],
        nest_modules_by_prefix: [Msdata],
        groups_for_modules: [
          API: [MscmpSystAuthn],
          Data: [
            Msdata.SystAccessAccountInstanceAssocs,
            Msdata.SystAccessAccounts,
            Msdata.SystCredentials,
            Msdata.SystDisallowedHosts,
            Msdata.SystDisallowedPasswords,
            Msdata.SystGlobalNetworkRules,
            Msdata.SystGlobalPasswordRules,
            Msdata.SystIdentities,
            Msdata.SystInstanceNetworkRules,
            Msdata.SystOwnerNetworkRules,
            Msdata.SystOwnerPasswordRules,
            Msdata.SystPasswordHistory
          ],
          "Supporting Types": [MscmpSystAuthn.Types]
        ]
      ]
    ]
  end

  def application do
    [
      extra_applications: [
        :logger,
        :crypto
      ]
    ]
  end

  defp elixirc_paths(:test), do: elixirc_paths() ++ ["test/support"]
  defp elixirc_paths(:dev), do: elixirc_paths() ++ ["dev_support"]
  defp elixirc_paths(_), do: elixirc_paths()
  defp elixirc_paths(), do: ["lib"]
end
