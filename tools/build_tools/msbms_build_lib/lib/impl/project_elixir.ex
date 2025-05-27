# Source File: project_elixir.ex
# Location:    musebms/tools/build_tools/msbms_build_lib/lib/impl/project_elixir.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsBuildLib.Impl.ProjectElixir do
  @moduledoc false

  alias MsbmsBuildLib.Impl.Common

  require Logger

  @scaffold_template_path "priv/scaffolds/elixir/component"

  ##############################################################################
  #
  # scaffold_component
  #
  #

  @doc """
  Scaffold a new Elixir component from templates.

  Creates a new Elixir component project structure based on the standard
  templates, with all files properly configured for the new component.

  ## Parameters
    * `base_dir` - The base directory path where the project is located
    * `component_name` - The name of the component (e.g., "mscmp_new_feature")
    * `target_path` - The relative path where the component should be created
    * `opts` - Optional configuration options

  ## Options
    * `:component_display_name` - Human-friendly name for the component
    * `:component_description` - Brief description of the component
    * `:component_section` - Documentation section atom

  ## Returns
    * `:ok` on successful scaffolding
    * `{:error, message}` if scaffolding fails
  """
  @spec scaffold_component(Path.t(), String.t(), String.t(), keyword()) ::
          :ok | {:error, String.t()}
  def scaffold_component(base_dir, component_name, target_path, opts \\ []) do
    Logger.notice("==msbms_build_lib==::project_elixir::scaffold_component::START")

    with {:ok, template_vars} <-
           build_template_variables(component_name, target_path, opts),
         {:ok, target_dir} <- create_target_directory(base_dir, target_path, component_name),
         :ok <- copy_and_process_templates(template_vars, target_dir) do
      Logger.notice("==msbms_build_lib==::project_elixir::scaffold_component::DONE")
      Logger.info("New Elixir component '#{component_name}' created at: #{target_dir}")
      :ok
    else
      {:error, reason} ->
        Logger.error("==msbms_build_lib==::project_elixir::scaffold_component::FAILED")
        {:error, reason}
    end
  end

  ##############################################################################
  #
  # Private Functions
  #
  #

  defp build_template_variables(component_name, target_path, opts) do
    with {:ok, docs_output_path} <- build_docs_output_path(target_path, component_name) do
      # Derive names with command line overrides
      default_short_name = derive_short_component_name(component_name)

      template_vars = [
        comp_name: component_name,
        comp_short_name: Keyword.get(opts, :comp_short_name, default_short_name),
        module_name:
          Keyword.get(opts, :module_name, derive_module_name_from_string(component_name)),
        module_short_name:
          Keyword.get(
            opts,
            :module_short_name,
            derive_module_name_from_string(default_short_name)
          ),
        project_path: Path.join(target_path, component_name),
        component_display_name:
          Keyword.get(opts, :component_display_name, humanize_name(component_name)),
        component_description:
          Keyword.get(
            opts,
            :component_description,
            "A new Elixir component for the Muse Systems Business Management System."
          ),
        component_section:
          Keyword.get(opts, :component_section, derive_section_atom(component_name)),
        docs_output_path: docs_output_path,
        build_config_path: build_build_config_path(target_path, component_name)
      ]

      {:ok, template_vars}
    end
  end

  defp derive_short_component_name(component_name) do
    # Handle the pattern: msxxx_yyyy_<component_name> -> <component_name>
    case String.split(component_name, "_") do
      [prefix1, prefix2 | rest] ->
        if String.starts_with?(prefix1, "ms") and String.length(prefix1) > 2 and
             String.length(prefix2) > 0 and length(rest) > 0 do
          Enum.join(rest, "_")
        else
          component_name
        end

      _ ->
        # Fallback: if pattern doesn't match, use full name
        component_name
    end
  end

  defp derive_module_name_from_string(name) do
    name
    |> String.split("_")
    |> Enum.map_join("", &String.capitalize/1)
  end

  defp humanize_name(component_name) do
    component_name
    |> String.split("_")
    |> Enum.map_join(" ", &String.capitalize/1)
  end

  defp derive_section_atom(component_name) do
    component_name
    |> String.replace("mscmp_", "")
    |> String.replace("msapp_", "")
    |> String.replace("mssub_", "")
    |> String.to_atom()
  end

  defp build_docs_output_path(target_path, component_name) do
    # Calculate relative path from component to docs directory
    component_path = Path.join(target_path, component_name)
    docs_root = Common.elixir_docs_root()

    # Count directory levels to go back to base
    levels_up = component_path |> Path.split() |> length()
    back_path = List.duplicate("..", levels_up) |> Path.join()

    docs_path = Path.join([back_path, docs_root, component_name])
    {:ok, docs_path}
  end

  defp build_build_config_path(target_path, component_name) do
    # Calculate relative path from component to build config file
    component_path = Path.join(target_path, component_name)

    # Count directory levels to go back to project root
    levels_up = component_path |> Path.split() |> length()
    back_path = List.duplicate("..", levels_up) |> Path.join()

    # Path to build config from project root
    Path.join([back_path, "tools/build_tools/build_config/msbms_build_config.exs"])
  end

  defp create_target_directory(base_dir, target_path, component_name) do
    target_dir = Path.join([base_dir, target_path, component_name])

    if File.exists?(target_dir) do
      {:error, "Target directory already exists: #{target_dir}"}
    else
      case File.mkdir_p(target_dir) do
        :ok -> {:ok, target_dir}
        {:error, reason} -> {:error, "Failed to create target directory: #{reason}"}
      end
    end
  end

  defp copy_and_process_templates(template_vars, target_dir) do
    template_dir = get_template_directory()

    if File.dir?(template_dir) do
      process_template_directory(template_dir, target_dir, template_vars, "")
    else
      {:error, "Template directory not found: #{template_dir}"}
    end
  end

  defp get_template_directory do
    # Get the path to the template directory relative to this application
    app_dir = Application.app_dir(:msbms_build_lib)
    Path.join(app_dir, @scaffold_template_path)
  end

  defp process_template_directory(source_dir, target_dir, template_vars, relative_path) do
    case File.ls(source_dir) do
      {:ok, entries} ->
        Enum.reduce_while(entries, :ok, fn entry, _acc ->
          process_directory_entry(entry, source_dir, target_dir, template_vars, relative_path)
        end)

      {:error, reason} ->
        {:error, "Failed to list directory #{source_dir}: #{reason}"}
    end
  end

  defp process_directory_entry(entry, source_dir, target_dir, template_vars, relative_path) do
    source_path = Path.join(source_dir, entry)
    target_path = Path.join(target_dir, process_filename(entry, template_vars))

    cond do
      File.dir?(source_path) ->
        process_subdirectory(source_path, target_path, template_vars, relative_path, entry)

      String.ends_with?(entry, ".eex") ->
        process_template_entry(source_path, target_path, template_vars)

      true ->
        process_regular_file(source_path, target_path)
    end
  end

  defp process_subdirectory(source_path, target_path, template_vars, relative_path, entry) do
    case File.mkdir_p(target_path) do
      :ok ->
        case process_template_directory(
               source_path,
               target_path,
               template_vars,
               Path.join(relative_path, entry)
             ) do
          :ok -> {:cont, :ok}
          error -> {:halt, error}
        end

      {:error, reason} ->
        {:halt, {:error, "Failed to create directory #{target_path}: #{reason}"}}
    end
  end

  defp process_template_entry(source_path, target_path, template_vars) do
    case process_template_file(source_path, target_path, template_vars) do
      :ok -> {:cont, :ok}
      error -> {:halt, error}
    end
  end

  defp process_regular_file(source_path, target_path) do
    case File.cp(source_path, target_path) do
      :ok -> {:cont, :ok}
      {:error, reason} -> {:halt, {:error, "Failed to copy file #{source_path}: #{reason}"}}
    end
  end

  defp process_filename(filename, template_vars) do
    # Replace __KEY_NAME__ placeholders with values from template_vars
    processed_filename =
      Enum.reduce(template_vars, filename, fn {key, value}, acc ->
        placeholder = "__#{String.upcase(to_string(key))}__"
        String.replace(acc, placeholder, to_string(value))
      end)

    # Remove .eex extension
    String.replace(processed_filename, ".eex", "")
  end

  defp process_template_file(source_path, target_path, template_vars) do
    # Remove .eex extension from target path
    final_target_path = String.replace_suffix(target_path, ".eex", "")

    case File.read(source_path) do
      {:ok, template_content} ->
        try do
          processed_content = EEx.eval_string(template_content, template_vars)

          case File.write(final_target_path, processed_content) do
            :ok -> :ok
            {:error, reason} -> {:error, "Failed to write file #{final_target_path}: #{reason}"}
          end
        rescue
          e ->
            {:error, "Failed to process template #{source_path}: #{Exception.message(e)}"}
        end

      {:error, reason} ->
        {:error, "Failed to read template #{source_path}: #{reason}"}
    end
  end
end
