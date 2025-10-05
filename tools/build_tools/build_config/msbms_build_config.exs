# Source File: msbms_build_config.exs
# Location:    musebms/tools/build_tools/msbms_build_config.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsBuildConfig do
  @moduledoc """
  Provides centralized version management for the Muse Systems Business Management
  System components. This module defines version constraints for Elixir, dependencies,
  and other version-related configurations.
  """

  @third_party_deps %{
    argon2_elixir: "~> 4.0",
    credo: {"~> 1.7", [only: [:dev, :test], runtime: false]},
    dialyxir: {"~> 1.4", [only: [:dev, :test], runtime: false]},
    ecto: "~> 3.11",
    ecto_sql: "~> 3.11",
    ex_doc: {"~> 0.31", [only: [:dev, :test], runtime: false]},
    extrace: {"~> 0.5.0", [only: [:dev, :test], runtime: false]},
    gettext: "~> 0.20",
    jason: "~> 1.4",
    nimble_options: "~> 1.0",
    nimble_totp: "~> 1.0",
    pathex: "~> 2.0",
    phoenix: "~> 1.7",
    phoenix_ecto: "~> 4.0",
    phoenix_live_view: "~> 0.19",
    phoenix_pubsub: "~> 2.0",
    postgrex: "~> 0.19",
    telemetry: "~> 1.0",
    timex: "~> 3.0",
    toml: "~> 0.7"
  }

  @msbms_deps %{
    mscmp_syst_authn: [path: "app_server/components/system/mscmp_syst_authn"],
    mscmp_syst_db: [path: "app_server/components/system/mscmp_syst_db"],
    mscmp_syst_enums: [path: "app_server/components/system/mscmp_syst_enums"],
    mscmp_syst_error: [path: "app_server/components/system/mscmp_syst_error"],
    mscmp_syst_forms: [path: "app_server/components/system/mscmp_syst_forms"],
    mscmp_syst_hierarchy: [path: "app_server/components/system/mscmp_syst_hierarchy"],
    mscmp_syst_instance: [path: "app_server/components/system/mscmp_syst_instance"],
    mscmp_syst_interaction: [path: "app_server/components/system/mscmp_syst_interaction"],
    mscmp_syst_limiter: [path: "app_server/components/system/mscmp_syst_limiter"],
    mscmp_syst_mcp_perms: [path: "app_server/components/system/mscmp_syst_mcp_perms"],
    mscmp_syst_nav: [path: "app_server/components/system/mscmp_syst_nav"],
    mscmp_syst_network: [path: "app_server/components/system/mscmp_syst_network"],
    mscmp_syst_options: [path: "app_server/components/system/mscmp_syst_options"],
    mscmp_syst_perms: [path: "app_server/components/system/mscmp_syst_perms"],
    mscmp_syst_service: [path: "app_server/components/system/mscmp_syst_service"],
    mscmp_syst_session: [path: "app_server/components/system/mscmp_syst_session"],
    mscmp_syst_settings: [path: "app_server/components/system/mscmp_syst_settings"],
    mscmp_syst_telemetry: [path: "app_server/components/system/mscmp_syst_telemetry"],
    mscmp_syst_utils: [path: "app_server/components/system/mscmp_syst_utils"],
    mscmp_syst_utils_data: [path: "app_server/components/system/mscmp_syst_utils_data"]
  }

  @msbms_docs %{
    mscmp_syst_authn: "/documentation/technical/app_server/mscmp_syst_authn",
    mscmp_syst_db: "/documentation/technical/app_server/mscmp_syst_db",
    mscmp_syst_enums: "/documentation/technical/app_server/mscmp_syst_enums",
    mscmp_syst_error: "/documentation/technical/app_server/mscmp_syst_error",
    mscmp_syst_forms: "/documentation/technical/app_server/mscmp_syst_forms",
    mscmp_syst_hierarchy: "/documentation/technical/app_server/mscmp_syst_hierarchy",
    mscmp_syst_instance: "/documentation/technical/app_server/mscmp_syst_instance",
    mscmp_syst_interaction: "/documentation/technical/app_server/mscmp_syst_interaction",
    mscmp_syst_limiter: "/documentation/technical/app_server/mscmp_syst_limiter",
    mscmp_syst_mcp_perms: "/documentation/technical/app_server/mscmp_syst_mcp_perms",
    mscmp_syst_nav: "/documentation/technical/app_server/mscmp_syst_nav",
    mscmp_syst_network: "/documentation/technical/app_server/mscmp_syst_network",
    mscmp_syst_options: "/documentation/technical/app_server/mscmp_syst_options",
    mscmp_syst_perms: "/documentation/technical/app_server/mscmp_syst_perms",
    mscmp_syst_service: "/documentation/technical/app_server/mscmp_syst_service",
    mscmp_syst_session: "/documentation/technical/app_server/mscmp_syst_session",
    mscmp_syst_settings: "/documentation/technical/app_server/mscmp_syst_settings",
    mscmp_syst_telemetry: "/documentation/technical/app_server/mscmp_syst_telemetry",
    mscmp_syst_utils: "/documentation/technical/app_server/mscmp_syst_utils",
    mscmp_syst_utils_data: "/documentation/technical/app_server/mscmp_syst_utils_data"
  }

  @all_deps Map.merge(@third_party_deps, @msbms_deps)

  # This assumes that the mix.exs file is in the tools/build_tools/build_config directory.
  @msbms_root_path Path.expand("../../../", __DIR__)

  @doc """
  Returns a map containing all version-related configurations including:
  - Elixir version
  - Dependency versions (Hex, path, and git)
  - Dialyzer options
  - Application version
  """
  def versions do
    %{
      msbms_version: %{
        # Valid release range: 0 - 1_295
        release: 1,

        # Valid version range: 0 - 1_295
        version: 1,

        # Valid update range: 0 - 46_655
        update: 0,

        # Valid sponsor range: 0 - 1_295 Muse System Reserve; 1_296 - 2_176_782_335 General
        sponsor: 820,

        # Valid sponsor modification range: 0 - 46_655
        sponsor_modification: 0
      },
      elixir: "~> 1.18",
      dependencies: @all_deps
    }
  end

  def dialyzer_config do
    [
      flags: ["-Wunmatched_returns", :error_handling],
      plt_add_apps: [:mix, :ex_unit],
      plt_core_path: "priv/plts",
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
    ]
  end

  def msbms_textual_version do
    %{
      release: release,
      version: version,
      update: update,
      sponsor: sponsor,
      sponsor_modification: sponsor_modification
    } = versions().msbms_version

    rr = Integer.to_string(release, 36) |> String.pad_leading(2, "0")
    vv = Integer.to_string(version, 36) |> String.pad_leading(2, "0")
    uuu = Integer.to_string(update, 36) |> String.pad_leading(3, "0")
    ssssss = Integer.to_string(sponsor, 36) |> String.pad_leading(6, "0")
    mmm = Integer.to_string(sponsor_modification, 36) |> String.pad_leading(3, "0")

    Enum.join([rr, vv, uuu, ssssss, mmm], ".")
  end

  def resolve_deps(dep_specs) when is_atom(dep_specs), do: resolve_deps([dep_specs])

  def resolve_deps(dep_specs) when is_list(dep_specs) do
    dep_specs
    |> Enum.reduce([], fn curr_dep, deps ->
      case process_dep(curr_dep) do
        result when not is_nil(result) -> [result | deps]
        _ -> deps
      end
    end)
  end

  defp process_dep(dep) when is_atom(dep) do
    case @all_deps[dep] do
      dep_ver when is_binary(dep_ver) ->
        {dep, dep_ver}

      dep_opts when is_list(dep_opts) ->
        {dep, process_path_dependency(dep_opts)}

      {dep_ver, dep_opts} when is_binary(dep_ver) and is_list(dep_opts) ->
        {dep, dep_ver, dep_opts}

      _ ->
        raise "Dependency #{dep} not found in versions().dependencies"
    end
  end

  defp process_dep({dep, opts}) when is_atom(dep) and is_list(opts) do
    case process_dep(dep) do
      {dep, dep_ver} when is_atom(dep) and is_binary(dep_ver) ->
        {dep, dep_ver, opts}

      {dep, dep_opts} when is_atom(dep) and is_list(dep_opts) ->
        {dep, process_path_dependency(dep_opts)}

      {dep, dep_ver, dep_opts} when is_atom(dep) and is_binary(dep_ver) and is_list(dep_opts) ->
        {dep, dep_ver, opts}

      _ ->
        raise "Dependency processing failure processing #{dep}"
    end
  end

  defp process_path_dependency(opts) do
    case Keyword.fetch(opts, :path) do
      {:ok, component_path} ->
        abs_dep_path = Path.join(@msbms_root_path, component_path)
        Keyword.put(opts, :path, abs_dep_path)

      :error ->
        opts
    end
  end

  def resolve_dep_docs(dep_specs) when is_atom(dep_specs), do: resolve_dep_docs([dep_specs])

  def resolve_dep_docs(dep_specs) when is_list(dep_specs) do
    dep_specs
    |> Enum.map(&process_dep_doc/1)
  end

  defp process_dep_doc(dep) when is_atom(dep) do
    case @msbms_docs[dep] do
      doc_path when is_binary(doc_path) ->
        {dep, doc_path}

      _ ->
        raise "Documentation path not found for #{dep}"
    end
  end
end
