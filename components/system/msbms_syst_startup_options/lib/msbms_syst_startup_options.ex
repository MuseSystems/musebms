defmodule MsbmsSystStartupOptions do

  alias MsbmsSystStartupOptions.Impl.StartupOptions

  @moduledoc """
  API for working with the msbms_startup_options.toml file.
  """
  defdelegate get_global_dbserver_name(),                             to: StartupOptions
  defdelegate get_global_dbserver_name(startup_options_file_path),    to: StartupOptions
  defdelegate get_global_dbserver(),                                  to: StartupOptions
  defdelegate get_global_dbserver(startup_options_file_path),         to: StartupOptions
  defdelegate get_dbserver(dbserver_name),                            to: StartupOptions
  defdelegate get_dbserver(startup_options_file_path, dbserver_name), to: StartupOptions
  defdelegate get_dbserver_list(),                                    to: StartupOptions
  defdelegate get_dbserver_list(startup_options_file_path),           to: StartupOptions
  defdelegate validate_startup_options,                               to: StartupOptions
  defdelegate validate_dbserver_options(dbserver_name),               to: StartupOptions
end
