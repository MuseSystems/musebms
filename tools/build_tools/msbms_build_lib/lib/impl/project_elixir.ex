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

  @component_scaffold_path ["scaffolds", "elixir", "component"]

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

  ## Returns
    * `:ok` on successful scaffolding
    * `{:error, message}` if scaffolding fails
  """
  @spec scaffold_component(Path.t(), String.t(), String.t(), keyword()) ::
          :ok | {:error, String.t()}
  def scaffold_component(base_dir, component_name, target_path, opts \\ []) do
    Logger.notice("==msbms_build_lib==::project_elixir::scaffold_component::START")

    # Build bindings for template variable substitution (relative paths)
    bindings = build_bindings(component_name, target_path, opts)

    # Build the actual absolute target directory for scaffolding
    absolute_target_dir = Path.join([base_dir, target_path, component_name])

    scaffold_path = Path.join([:code.priv_dir(:msbms_build_lib)] ++ @component_scaffold_path)

    case process_scaffold(scaffold_path, absolute_target_dir, bindings) do
      :ok ->
        Logger.info("New Elixir component '#{component_name}' created at: #{absolute_target_dir}")
        Logger.notice("==msbms_build_lib==::project_elixir::scaffold_component::DONE")
        :ok

      {:error, reason} ->
        Logger.error("==msbms_build_lib==::project_elixir::scaffold_component::FAILED")
        {:error, reason}
    end
  end

  defp build_bindings(component_name, target_path, opts) do
    default_short_name = derive_short_component_name(component_name)

    # Component path for relative calculations (target_path/component_name)
    resolved_project_path = Path.join(target_path, component_name)
    relative_root_path = build_relative_root_path(resolved_project_path)

    resolved_config_path = Path.join(relative_root_path, Common.elixir_build_config_path())

    resolved_docs_path =
      Path.join([relative_root_path, Common.elixir_docs_root(), component_name])

    resolved_comp_short_name = Keyword.get(opts, :comp_short_name, default_short_name)

    resolved_module_name =
      Keyword.get(opts, :module_name, snake_to_pascal(component_name))

    resolved_module_short_name =
      Keyword.get(opts, :module_short_name, snake_to_pascal(default_short_name))

    resolved_component_display_name =
      Keyword.get(opts, :component_display_name, snake_to_friendly(component_name))

    resolved_component_description =
      Keyword.get(
        opts,
        :component_description,
        "A new Elixir component for the Muse Systems Business Management System."
      )

    [
      comp_name: component_name,
      comp_short_name: resolved_comp_short_name,
      module_name: resolved_module_name,
      module_short_name: resolved_module_short_name,
      project_path: resolved_project_path,
      component_display_name: resolved_component_display_name,
      component_description: resolved_component_description,
      docs_output_path: resolved_docs_path,
      build_config_path: resolved_config_path
    ]
  end

  defp build_relative_root_path(component_path) do
    component_path
    |> Path.split()
    |> length()
    |> then(&List.duplicate("..", &1))
    |> Path.join()
  end

  defp derive_short_component_name(component_name) do
    regex = ~r/^(?<prefix>[a-z]{5})_(?<section>[a-z]{4})_(?<component>.+)$/

    case Regex.named_captures(regex, component_name) do
      %{"component" => component} -> component
      nil -> component_name
    end
  end

  defp snake_to_pascal(name) do
    name
    |> String.split("_")
    |> Enum.map_join("", &String.capitalize/1)
  end

  defp snake_to_friendly(component_name) do
    component_name
    |> String.split("_")
    |> Enum.map_join(" ", &String.capitalize/1)
  end

  defp rename_with_bindings(filename, bindings) do
    Enum.reduce(bindings, filename, fn {key, value}, acc_filename ->
      # Convert key to uppercase string for the tag format, e.g., :comp_name -> "COMP_NAME"
      tag_key_str = key |> Atom.to_string() |> String.upcase()
      tag_to_replace = "__#{tag_key_str}__"
      # Ensure value is a string for replacement
      replacement_value = to_string(value)
      String.replace(acc_filename, tag_to_replace, replacement_value)
    end)
  end

  defp process_scaffold(scaffold_dir, target_dir, bindings) do
    process_scaffold_recursive(scaffold_dir, target_dir, bindings)
  end

  defp process_scaffold_recursive(source_dir, target_dir, bindings) do
    # Ensure target directory exists
    case File.mkdir_p(target_dir) do
      :ok ->
        # Proceed with processing contents
        do_process_scaffold_contents(source_dir, target_dir, bindings)

      {:error, reason} ->
        Logger.error("Failed to create target directory #{target_dir}: #{reason}")
        {:error, "Failed to create target directory #{target_dir}: #{reason}"}
    end
  end

  defp do_process_scaffold_contents(source_dir, target_dir, bindings) do
    case File.ls(source_dir) do
      {:ok, contents} ->
        # Categorize all items in current directory
        {directories, templates, statics} = categorize_scaffold_items(source_dir, contents)

        # Process items, halting on any error
        with :ok <-
               process_directories_recursively(directories, source_dir, target_dir, bindings),
             :ok <- process_all_templates(templates, source_dir, target_dir, bindings),
             :ok <- copy_all_static_files(statics, source_dir, target_dir, bindings) do
          :ok
        else
          # An error from any of the above steps will be caught here
          {:error, _reason} = error -> error
        end

      {:error, reason} ->
        Logger.error("Failed to read scaffold directory #{source_dir}: #{reason}")
        {:error, "Failed to read scaffold directory #{source_dir}: #{reason}"}
    end
  end

  # Helper to process directories recursively
  defp process_directories_recursively(directories, source_dir, target_dir, bindings) do
    Enum.reduce_while(directories, :ok, fn dir_name, _acc ->
      source_child_dir = Path.join(source_dir, dir_name)
      renamed_dir_name = rename_with_bindings(dir_name, bindings)
      target_child_dir = Path.join(target_dir, renamed_dir_name)

      case process_scaffold_recursive(source_child_dir, target_child_dir, bindings) do
        :ok -> {:cont, :ok}
        {:error, _reason} = error -> {:halt, error}
      end
    end)
  end

  # Helper to process all template files
  defp process_all_templates(templates, source_dir, target_dir, bindings) do
    Enum.reduce_while(templates, :ok, fn template_file, _acc ->
      case process_template_file(source_dir, target_dir, template_file, bindings) do
        :ok -> {:cont, :ok}
        {:error, _reason} = error -> {:halt, error}
      end
    end)
  end

  # Helper to copy all static files
  defp copy_all_static_files(statics, source_dir, target_dir, bindings) do
    Enum.reduce_while(statics, :ok, fn static_file, _acc ->
      target_static_file_name = rename_with_bindings(static_file, bindings)

      case copy_static_file(source_dir, target_dir, static_file, target_static_file_name) do
        :ok -> {:cont, :ok}
        {:error, _reason} = error -> {:halt, error}
      end
    end)
  end

  defp categorize_scaffold_items(source_dir, file_names) do
    Enum.reduce(file_names, {[], [], []}, fn file_name, {dirs, templates, statics} ->
      file_path = Path.join(source_dir, file_name)

      cond do
        File.dir?(file_path) ->
          {[file_name | dirs], templates, statics}

        File.regular?(file_path) and String.ends_with?(file_name, ".eex") ->
          {dirs, [file_name | templates], statics}

        File.regular?(file_path) ->
          {dirs, templates, [file_name | statics]}

        true ->
          # Skip other file types (symlinks, etc.)
          {dirs, templates, statics}
      end
    end)
  end

  defp process_template_file(source_dir, target_dir, template_file, bindings) do
    source_path = Path.join(source_dir, template_file)

    # Remove .eex extension for target file
    renamed_template_file = rename_with_bindings(template_file, bindings)
    target_file_name = String.replace_suffix(renamed_template_file, ".eex", "")
    target_path = Path.join(target_dir, target_file_name)

    with {:ok, template_content} <- File.read(source_path),
         {:ok, rendered_content} <-
           evaluate_template(template_content, renamed_template_file, bindings),
         :ok <- File.write(target_path, rendered_content) do
      Logger.debug("Processed template: #{renamed_template_file} -> #{target_file_name}")
      :ok
    else
      {:error, reason} ->
        # Specific error logging for read failures
        # Check if it's not already a file read error reason
        if reason != :eaddrinuse and reason != :eagain and reason != :einval and reason != :enoent do
          Logger.error("Failed to process template file #{renamed_template_file}: #{reason}")
        end

        {:error, "Failed to process template #{renamed_template_file}: #{reason}"}
    end
  end

  defp evaluate_template(template_content, template_file_name, bindings) do
    {:ok, EEx.eval_string(template_content, bindings)}
  rescue
    e in EEx.SyntaxError ->
      Logger.error("EEx syntax error in template #{template_file_name}: #{Exception.message(e)}")

      {:error, "Template syntax error in #{template_file_name}: #{Exception.message(e)}"}

    e ->
      Logger.error("Error evaluating template #{template_file_name}: #{Exception.message(e)}")

      {:error, "Error evaluating template #{template_file_name}: #{Exception.message(e)}"}
  end

  defp copy_static_file(source_dir, target_dir, original_static_file, target_static_file_name) do
    source_path = Path.join(source_dir, original_static_file)
    target_path = Path.join(target_dir, target_static_file_name)

    case File.copy(source_path, target_path) do
      {:ok, _bytes_copied} ->
        Logger.debug("Copied static file: #{original_static_file} -> #{target_static_file_name}")
        :ok

      {:error, reason} ->
        Logger.error(
          "Failed to copy static file #{original_static_file} from #{source_path} to #{target_path}: #{reason}"
        )

        # Ensure a consistent error tuple structure if needed, though File.copy already provides it.
        {:error, "Failed to copy static file #{original_static_file}: #{reason}"}
    end
  end
end
