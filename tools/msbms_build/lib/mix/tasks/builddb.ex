defmodule Mix.Tasks.Builddb do
  use Mix.Task

  @glbl_migrations_path "../../components/system/msbms_syst_ds_glbl/priv/database"
  @inst_migrations_path "../../components/system/msbms_syst_ds_inst/priv/database"
  @source_files_path "../../database"

  @shortdoc "Builds the current database sources into their respective migrations."
  @spec run(any) :: any
  def run(args) do
    args
    |> OptionParser.parse!(strict: [dbtype: :string])
    |> build_migrations

    {:ok}
  end

  defp build_migrations({[dbtype: "global"], _}) do
    build_migrations(@source_files_path, @glbl_migrations_path, "global", "manifest_global.toml")
  end

  defp build_migrations({[dbtype: "instance"], _}) do
    build_migrations(@source_files_path, @inst_migrations_path, "instance", "manifest_instance.toml")
  end

  defp build_migrations({[dbtype: bad_arg], _}) do
    IO.puts(
      "Bad --dbtype argument '#{bad_arg}'.  Please set --dbtype to either 'global' or 'instance'."
    )
  end

  defp build_migrations(source_path, migrations_path, kind, manifest_name) do
    migrations_path
    |> File.rm_rf!()

    Path.join(source_path, manifest_name)
    |> get_build_plans()
    |> Enum.each(fn current_plan ->
      generate_migration_from_build_plan(current_plan, kind, migrations_path)
    end)
  end


  defp get_build_plans(manifest_file) do
    manifest_file
    |> File.stream!()
    |> Toml.decode_stream!()
    |> Map.get("build_plans")
  end

  defp generate_migration_from_build_plan(build_plan, target_type, migrations_path) do
    migration_filename =
      target_type <>
        "." <>
        String.pad_leading(Integer.to_string(build_plan["release"], 36), 2, "0") <>
        "." <>
        String.pad_leading(Integer.to_string(build_plan["version"], 36), 2, "0") <>
        "." <>
        String.pad_leading(Integer.to_string(build_plan["update"], 36), 3, "0") <>
        "." <>
        String.pad_leading(Integer.to_string(build_plan["sponsor"], 36), 6, "0") <>
        "." <>
        String.pad_leading(Integer.to_string(build_plan["sponsor_modification"], 36), 3, "0") <>
        ".eex.sql"

    qualified_target_path = Path.join([migrations_path, migration_filename])

    File.mkdir_p(Path.join([migrations_path]))

    target =
      File.open!(qualified_target_path, [
        :exclusive,
        {:delayed_write, 1024, 20}
      ])

    IO.binwrite(
      target,
      """
      -- Migration: #{qualified_target_path}
      -- Built on:  #{DateTime.utc_now()}

      DO
      $BUILDSCRIPT$
      BEGIN
      """
    )

    build_plan["load_files"]
    |> Enum.each(fn file ->
      sql = File.read!(Path.join([@source_files_path, file]))
      IO.binwrite(target, sql)
    end)

    IO.binwrite(
      target,
      """
      END;
      $BUILDSCRIPT$;
      """
    )

    File.close(target)
    IO.puts("Created Migration: #{qualified_target_path}")
  end
end
