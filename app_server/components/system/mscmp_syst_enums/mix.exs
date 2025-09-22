# Source File: mix.exs
# Location:    musebms/app_server/components/system/mscmp_syst_enums/mix.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystEnums.MixProject do
  use Mix.Project

  Code.require_file(
    Path.expand("../../../../tools/build_tools/build_config/msbms_build_config.exs", __DIR__)
  )

  @name :mscmp_syst_enums
  @version "0.1.0"

  @third_party_deps [
    :credo,
    :dialyxir,
    :ex_doc,
    :nimble_options
  ]

  @msbms_deps [
    :mscmp_syst_error,
    :mscmp_syst_service,
    :mscmp_syst_telemetry,
    :mscmp_syst_utils,
    :mscmp_syst_utils_data,
    :mscmp_syst_db
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
        name: "MscmpSystEnums",
        main: "MscmpSystEnums",
        output: "../../../../documentation/technical/app_server/mscmp_syst_enums",
        deps: MsbmsBuildConfig.resolve_dep_docs(@msbms_deps),
        groups_for_docs: [
          Enumerations: &(&1[:section] == :enum_data),
          "Enumeration Functional Types": &(&1[:section] == :enum_functional_type_data),
          "Enumeration items": &(&1[:section] == :enum_item_data),
          Runtime: &(&1[:section] == :service_management),
          "Development Support": &(&1[:section] == :development_support)
        ],
        nest_modules_by_prefix: [Msdata],
        groups_for_modules: [
          API: [MscmpSystEnums],
          Data: [
            Msdata.SystEnums,
            Msdata.SystEnumFunctionalTypes,
            Msdata.SystEnumItems
          ],
          "Supporting Types": [MscmpSystEnums.Types],
          Exceptions: [Mserror.EnumsError]
        ]
      ]
    ]
  end

  def application do
    [
      extra_applications: [
        :logger,
        :observer,
        :wx,
        :runtime_tools
      ]
    ]
  end

  defp elixirc_paths(:test), do: elixirc_paths() ++ ["test/support"]
  defp elixirc_paths(:dev), do: elixirc_paths() ++ ["dev_support"]
  defp elixirc_paths(_), do: elixirc_paths()
  defp elixirc_paths(), do: ["lib"]
end
