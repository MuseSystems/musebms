# Source File: mix.exs
# Location:    musebms/app_server/components/system/mscmp_syst_db/mix.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystDb.MixProject do
  use Mix.Project

  Code.require_file(Path.expand("../../../../tools/build_tools/build_config/msbms_build_config.exs", __DIR__))

  @name :mscmp_syst_db
  @version "0.1.0"

  @third_party_deps [
    :credo,
    :dialyxir,
    :ex_doc,
    :ecto_sql,
    :ecto,
    :jason,
    :postgrex,
    :toml,
    :nimble_options,
    :telemetry
  ]

  @msbms_deps [
    :mscmp_syst_error,
    :mscmp_syst_utils,
    :mscmp_syst_network
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
        name: "MscmpSystDb",
        main: "MscmpSystDb",
        output: "../../../../documentation/technical/app_server/mscmp_syst_db",
        deps: MsbmsBuildConfig.resolve_dep_docs(@msbms_deps),
        nest_modules_by_prefix: [MscmpSystDb.DbTypes, MscmpSystDb.Types],
        groups_for_docs: [
          Query: &(&1[:section] == :query),
          "Datastore Management": &(&1[:section] == :datastore_management),
          "Datastore Migrations": &(&1[:section] == :datastore_migrations),
          Runtime: &(&1[:section] == :service_management),
          "Development Support": &(&1[:section] == :development_support),
          Utility: &(&1[:section] == :utility)
        ],
        groups_for_modules: [
          API: [MscmpSystDb],
          "Supporting Types": [
            MscmpSystDb.Types,
            MscmpSystDb.Types.ContextState,
            MscmpSystDb.Types.DatastoreContext,
            MscmpSystDb.Types.DatastoreOptions,
            MscmpSystDb.Types.DbServer,
            MscmpSystDb.Types.BoundsCompareResult
          ],
          "Database Types": [
            MscmpSystDb.DbTypes.DateRange,
            MscmpSystDb.DbTypes.DecimalRange,
            MscmpSystDb.DbTypes.Inet,
            MscmpSystDb.DbTypes.IntegerRange,
            MscmpSystDb.DbTypes.Interval,
            MscmpSystDb.DbTypes.DateTimeRange
          ],
          "Datastore Service": [MscmpSystDb.Datastore],
          "Datastore Context Service": [MscmpSystDb.DatastoreContext],
          Schema: [MscmpSystDb.Schema],
          Exceptions: [Mserror.DbError]
        ]
      ]
    ]
  end

  def application do
    [
      extra_applications: [
        :logger,
        :debugger,
        :runtime_tools,
        :wx
      ]
    ]
  end

  defp elixirc_paths(:test), do: elixirc_paths() ++ ["test/support"]
  defp elixirc_paths(:dev), do: elixirc_paths() ++ ["dev_support"]
  defp elixirc_paths(_), do: elixirc_paths()
  defp elixirc_paths(), do: ["lib"]
end
