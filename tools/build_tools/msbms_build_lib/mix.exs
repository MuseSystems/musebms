# Source File: mix.exs
# Location:    musebms/tools/build_tools/msbms_build_lib/mix.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsBuildLib.MixProject do
  use Mix.Project

  Code.require_file(Path.expand("../build_config/msbms_build_config.exs", __DIR__))

  @name :msbms_build_lib
  @version "1.2.1"

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
        name: "MsbmsBuildLib",
        main: "MsbmsBuildLib",
        output: "../../../documentation/technical/auxiliary/msbms_build_lib",
        groups_for_docs: [
          "Constants Retrieval": &(&1[:section] == :constants_retrieval),
          "Build Cleaning": &(&1[:section] == :build_cleaning),
          "Build Documentation": &(&1[:section] == :build_documentation),
          "Documentation Generation": &(&1[:section] == :documentation_generation),
          "Dependency Management": &(&1[:section] == :dependency_management),
          "Test Execution": &(&1[:section] == :test_execution),
          "Build Elixir": &(&1[:section] == :build_elixir),
          "Build Migrations": &(&1[:section] == :build_migrations),
          "Project Scaffolding": &(&1[:section] == :project_scaffolding),
          Utility: &(&1[:section] == :utility)
        ],
        groups_for_modules: [
          API: [MsbmsBuildLib],
          "Supporting Types": [MsbmsBuildLib.Types]
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
