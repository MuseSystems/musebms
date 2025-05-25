# Source File: mix.exs
# Location:    musebms/app_server/components/system/mscmp_syst_utils_data/mix.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystUtilsData.MixProject do
  use Mix.Project

  Code.require_file(Path.expand("../../../../tools/build_tools/build_config/msbms_build_config.exs", __DIR__))

  @name :mscmp_syst_utils_data
  @version "0.1.0"

  @third_party_deps [
    :credo,
    :dialyxir,
    :ex_doc,
    :ecto,
    :nimble_options
  ]

  @msbms_deps [
    :mscmp_syst_error
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
        name: "MscmpSystUtilsData",
        main: "Msutils.Data",
        output: "../../../../documentation/technical/app_server/mscmp_syst_utils_data",
        deps: MsbmsBuildConfig.resolve_dep_docs(@msbms_deps),
        groups_for_docs: [
          "Changeset Validators": &(&1[:section] == :changeset_validators),
          "Ets Operations": &(&1[:section] == :ets_operations)
        ],
        groups_for_modules: [
          API: [Msutils.Data],
          Exceptions: [Mserror.DataUtilsError]
        ]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:crypto]
    ]
  end

  defp elixirc_paths(:test), do: elixirc_paths() ++ ["test/support"]
  defp elixirc_paths(_), do: elixirc_paths()
  defp elixirc_paths(), do: ["lib"]
end
