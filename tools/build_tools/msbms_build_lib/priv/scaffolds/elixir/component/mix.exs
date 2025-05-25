# Source File: mix.exs
# Location:    musebms/tools/build_tools/msbms_new_project/mix.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsNewProject.MixProject do
  use Mix.Project

  Code.require_file(Path.expand("../msbms_build_config.exs", __DIR__))

  @name :msbms_new_project
  @version "0.1.0"

  @third_party_deps [
    :credo,
    :dialyxir,
    :ex_doc
  ]

  @msbms_deps [:mscmp_syst_error]

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
        name: "MsbmsNewProject",
        main: "MsbmsNewProject",
        output: "../../../../documentation/technical/app_server/msbms_new_project",
        deps: MsbmsBuildConfig.resolve_dep_docs(@msbms_deps),
        groups_for_docs: [
          "New Project": &(&1[:section] == :new_project)
        ],
        groups_for_modules: [
          API: [MsbmsNewProject],
          "Supporting Types": [MsbmsNewProject.Types]
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
