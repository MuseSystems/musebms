# Source File: mix.exs
# Location:    musebms/app_server/components/system/mscmp_syst_error/mix.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystError.MixProject do
  use Mix.Project

  Code.require_file(
    Path.expand("../../../../tools/build_tools/build_config/msbms_build_config.exs", __DIR__)
  )

  @name :mscmp_syst_error
  @version "0.1.0"

  @third_party_deps [
    :credo,
    :dialyxir,
    :ex_doc
  ]

  # ------------------------------------------------------------

  def project do
    in_production = Mix.env() == :prod

    [
      app: @name,
      version: @version,
      elixir: MsbmsBuildConfig.versions().elixir,
      deps: MsbmsBuildConfig.resolve_deps(@third_party_deps),
      build_embedded: in_production,
      start_permanent: in_production,
      dialyzer: MsbmsBuildConfig.dialyzer_config(),
      elixirc_paths: elixirc_paths(Mix.env()),
      docs: [
        name: "MscmpSystError",
        main: "MscmpSystError",
        output: "../../../../documentation/technical/app_server/mscmp_syst_error",
        groups_for_docs: [
          "Error Parsing": &(&1[:section] == :error_parsing)
        ],
        groups_for_modules: [
          API: [MscmpSystError],
          "Supporting Types": [MscmpSystError.Types]
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
