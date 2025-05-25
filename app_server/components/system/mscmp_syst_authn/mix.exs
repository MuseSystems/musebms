# Source File: mix.exs
# Location:    musebms/app_server/components/system/mscmp_syst_authn/mix.exs
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

  Code.require_file(Path.expand("../../../../tools/build_tools/build_config/msbms_build_config.exs", __DIR__))

  @name :mscmp_syst_authn
  @version "0.1.0"

  @third_party_deps [
    :credo,
    :dialyxir,
    :ex_doc,
    :argon2_elixir,
    :nimble_totp,
    :pathex,
    :timex,
    :jason,
    :nimble_options
  ]

  @msbms_deps [
    :mscmp_syst_utils,
    :mscmp_syst_utils_data,
    :mscmp_syst_error,
    :mscmp_syst_network,
    :mscmp_syst_limiter,
    :mscmp_syst_db,
    :mscmp_syst_enums,
    :mscmp_syst_options,
    :mscmp_syst_instance
  ]

  # ------------------------------------------------------------

  def project do
    in_production = Mix.env() == :prod

    [
      app: @name,
      version: @version,
      elixir: MsbmsBuildConfig.versions().elixir,
      deps: MsbmsBuildConfig.resolve_deps(@third_party_deps ++ @msbms_deps),
      build_embedded: in_production,
      start_permanent: in_production,
      dialyzer: MsbmsBuildConfig.dialyzer_config(),
      elixirc_paths: elixirc_paths(Mix.env()),
      docs: [
        name: "MscmpSystAuthn",
        main: "MscmpSystAuthn",
        output: "../../../../documentation/technical/app_server/mscmp_syst_authn",
        deps: MsbmsBuildConfig.resolve_dep_docs(@msbms_deps),
        groups_for_docs: [
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
        nest_modules_by_prefix: [Msdata, MscmpSystAuthn.Types],
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
          "Supporting Types": [
            MscmpSystAuthn.Types,
            MscmpSystAuthn.Types.AppliedNetworkRule,
            MscmpSystAuthn.Types.AuthenticationState,
            MscmpSystAuthn.Types.AuthenticatorResult,
            MscmpSystAuthn.Types.PasswordRules
          ]
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
