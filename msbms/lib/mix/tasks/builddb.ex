defmodule Mix.Tasks.Builddb do
  use Mix.Task

  @shortdoc "Builds the current starting database into priv/starting_database.sql"
  @spec run(any) :: any
  def run(_) do
    File.rm("priv/starting_database.sql")
    File.touch("priv/starting_database.sql")
    target = File.open!("priv/starting_database.sql", [:append, {:delayed_write, 1024, 20}])

    IO.binwrite(target,
    """
    DO
    $BUILDSCRIPT$
    BEGIN

    """)

    File.stream!("database/manifest.toml")
    |> Toml.decode_stream!()
    |> Map.get("load_files")
    |> Enum.each(fn file ->
      sql = File.read!(Path.join("database", file))
      IO.binwrite(target, sql)
    end)

    IO.binwrite(target,
    """
    END;
    $BUILDSCRIPT$;
    """)

    File.close(target)
  end
end
