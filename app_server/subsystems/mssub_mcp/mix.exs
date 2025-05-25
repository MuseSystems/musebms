# Source File: mix.exs
# Location:    musebms/app_server/subsystems/mssub_mcp/mix.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MssubMcp.MixProject do
  use Mix.Project

  Code.require_file(Path.expand("../../../tools/build_tools/build_config/msbms_build_config.exs", __DIR__))

  @name :mssub_mcp
  @version "0.1.0"

  @third_party_deps [
    :credo,
    :dialyxir,
    :ex_doc,
    :nimble_options,
    :phoenix_pubsub
  ]

  @msbms_deps [
    :mscmp_syst_utils,
    :mscmp_syst_error,
    :mscmp_syst_options,
    :mscmp_syst_enums,
    :mscmp_syst_settings,
    :mscmp_syst_instance,
    :mscmp_syst_authn,
    :mscmp_syst_perms,
    :mscmp_syst_mcp_perms,
    :mscmp_syst_session
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
        name: "MssubMcp",
        main: "MssubMcp",
        output: "../../../documentation/technical/app_server/mssub_mcp",
        deps: MsbmsBuildConfig.resolve_dep_docs(@msbms_deps),
        groups_for_docs: [
          "Instance Manager Runtime": &(&1[:section] == :instance_management),
          "Instance Applications": &(&1[:section] == :instance_applications),
          "Instance Types": &(&1[:section] == :instance_type_data),
          Owners: &(&1[:section] == :instance_owner_data),
          Instances: &(&1[:section] == :instance_data),
          "Authentication Enums": &(&1[:section] == :authn_enumerations_data),
          "Access Accounts": &(&1[:section] == :authn_access_account_data),
          "Access Account/Instance Assocs.":
            &(&1[:section] == :authn_access_account_instance_assoc_data),
          "Password Rules": &(&1[:section] == :authn_password_rule_data),
          "Network Rules": &(&1[:section] == :authn_network_rule_data),
          "Account Code": &(&1[:section] == :authn_account_code),
          "Authenticator Management": &(&1[:section] == :authn_authenticator_management),
          Authentication: &(&1[:section] == :authn_authentication),
          "Session Management": &(&1[:section] == :session_management),
          Permissions: &(&1[:section] == :perms_management),
          "MCP Processing": &(&1[:section] == :mcp_processing)
        ],
        groups_for_modules: [
          API: [MssubMcp],
          "Supporting Types": []
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
