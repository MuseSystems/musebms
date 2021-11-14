defmodule Mix.Tasks.Builddb do
  use Mix.Task

  @shortdoc "Builds the current database sources into their respective migrations."
  @spec run(any) :: any
  def run(args) do
    args
    |> OptionParser.parse!(strict: [dbtype: :string])
    |> build_migrations

    {:ok}
  end

  defp build_migrations({[dbtype: "global"], _}) do
    get_build_plans("manifest_global.toml")
    |> Enum.each(fn current_plan -> generate_migration_from_build_plan(current_plan, "global") end)
  end

  defp build_migrations({[dbtype: "instance"], _}) do
    get_build_plans("manifest_instance.toml")
    |> Enum.each(fn current_plan ->
      generate_migration_from_build_plan(current_plan, "instance")
    end)
  end

  defp build_migrations({[dbtype: bad_arg], _}) do
    IO.puts(
      "Bad --dbtype argument '#{bad_arg}'.  Please set --dbtype to either 'global' or 'instance'."
    )
  end

  defp get_build_plans(manifest_file) do
    qualified_manifest_path = Path.join(["database", manifest_file])

    File.stream!(qualified_manifest_path)
    |> Toml.decode_stream!()
    |> Map.get("build_plans")
  end

  defp generate_migration_from_build_plan(build_plan, target_type) do
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

    qualified_target_path = Path.join(["priv", "database", target_type, migration_filename])

    IO.puts(qualified_target_path)

    File.rm(qualified_target_path)
    File.touch(qualified_target_path)

    target =
      File.open!(qualified_target_path, [
        :append,
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
      sql = File.read!(Path.join(["database", file]))
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
  end
end
