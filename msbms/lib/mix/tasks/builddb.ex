defmodule Mix.Tasks.Builddb do
  use Mix.Task

  @shortdoc "Builds the current database sources into their respective starter databases and migrations."
  @spec run(any) :: any
  def run(args) do
    args
    |> OptionParser.parse!(strict: [dbtype: :string])
    |> build_starting_migration

    {:ok}
  end

  defp build_starting_migration({[dbtype: "global"], _}) do
    source_builder("manifest_global.toml", "global")
  end

  defp build_starting_migration({[dbtype: "instance"], _}) do
    source_builder("manifest_instance.toml", "instance")
  end

  defp build_starting_migration({[dbtype: bad_arg], _}) do
    IO.puts(
      "Bad --dbtype argument '#{bad_arg}'.  Please set --dbtype to either 'global' or 'instance'."
    )
  end

  defp source_builder(manifest_file, target_path) do
    qualified_target_path = Path.join(["priv", "database", target_path, "starting_database.sql"])
    qualified_manifest_path = Path.join(["database", manifest_file])

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
      -- Built from manifest: #{qualified_manifest_path}
      -- Built on: #{DateTime.utc_now()}

      DO
      $BUILDSCRIPT$
      BEGIN
      """
    )

    File.stream!(qualified_manifest_path)
    |> Toml.decode_stream!()
    |> Map.get("load_files")
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
