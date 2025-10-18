# Source File: gen_comp_list.ex
# Location:    musebms/tools/build_tools/msbms_build_lib/lib/impl/gen_comp_list.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsbmsBuildLib.Impl.GenCompList do
  @moduledoc false

  # TODO: This is mostly LLM generated and the overall code quality is pretty
  #       poor.  This is not production code in the sense of being part of the
  #       running application, so it's definitely not critical path... but if
  #       we find ourselves having to maintain this much we'll probably want to
  #       clean this up and simplify.

  alias MsbmsBuildLib.Impl.Common

  require Logger

  @default_output_path "documentation/book/content/en/technical/system-components-list.md"

  @doc """
  Generates the system components list documentation file.

  ## Parameters
    * `base_dir` - The base directory path
    * `opts` - Options keyword list:
      * `:output_path` - Output file path (default: "#{@default_output_path}")
      * `:dry_run` - If true, returns content without writing file (default: false)

  ## Returns
    * `{:ok, output_path}` on success when writing file
    * `{:ok, content}` on success when dry_run is true
    * `{:error, message}` on failure
  """
  @spec generate(Path.t(), Keyword.t()) :: {:ok, Path.t() | String.t()} | {:error, String.t()}
  def generate(base_dir, opts \\ []) do
    output_path = Keyword.get(opts, :output_path, @default_output_path)
    full_output_path = Path.join(base_dir, output_path)
    dry_run = Keyword.get(opts, :dry_run, false)

    Logger.info("Generating component list documentation...")

    with {:ok, components} <- discover_all_components(base_dir),
         {:ok, component_data} <- extract_component_data(base_dir, components),
         {:ok, content} <- generate_markdown(component_data) do
      if dry_run do
        Logger.info("Dry run complete - content generated but not written")
        {:ok, content}
      else
        case write_output_file(full_output_path, content) do
          :ok ->
            Logger.info("Successfully generated component list at: #{full_output_path}")
            {:ok, full_output_path}

          {:error, reason} ->
            {:error, reason}
        end
      end
    else
      {:error, reason} -> {:error, reason}
    end
  end

  # Discover all components in the project
  defp discover_all_components(base_dir) do
    component_paths = Common.elixir_component_paths()

    components =
      component_paths
      |> Enum.flat_map(fn path ->
        full_path = Path.join(base_dir, path)

        if File.dir?(full_path) do
          File.ls!(full_path)
          |> Enum.filter(&File.dir?(Path.join(full_path, &1)))
          |> Enum.map(&{&1, Path.join(full_path, &1)})
        else
          []
        end
      end)
      |> Enum.sort_by(fn {name, _path} -> name end)

    if components == [] do
      {:error, "No components found in #{base_dir}"}
    else
      Logger.info("Found #{length(components)} components")
      {:ok, components}
    end
  end

  # Extract data from each component
  defp extract_component_data(base_dir, components) do
    results =
      components
      |> Enum.map(fn {name, path} ->
        Logger.debug("Processing component: #{name}")

        %{
          name: name,
          category: categorize_component(name),
          description: extract_description(path),
          msbms_deps: extract_deps(path, :msbms),
          third_party_deps: extract_deps(path, :third_party),
          api_doc_link: get_api_doc_link(name),
          db_doc_link: get_db_doc_link(base_dir, name)
        }
      end)

    {:ok, results}
  end

  # Categorize component based on naming convention
  defp categorize_component(name) do
    cond do
      String.starts_with?(name, "msplatform") -> :platform
      String.starts_with?(name, "mssub_") -> :subsystem
      String.starts_with?(name, "mscmp_") -> :component
      String.starts_with?(name, "msapp_") -> :application
      true -> :unknown
    end
  end

  # Extract description from README.md
  defp extract_description(component_path) do
    readme_path = Path.join(component_path, "README.md")

    if File.exists?(readme_path) do
      content = File.read!(readme_path)
      extract_description_from_content(content)
    else
      "No description available."
    end
  end

  # Extract description from README content
  defp extract_description_from_content(content) do
    # Extract text between <!-- MDOC !--> and <!-- MDESC !--> (or fallback to first ## heading)
    case Regex.run(~r/<!-- MDOC !-->\s*\n\n(.*?)(?=<!-- MDESC !-->|\n##|\z)/s, content) do
      [_, description] ->
        description
        |> String.trim()
        |> String.replace(~r/\n\n+/, "\n\n")

      nil ->
        extract_fallback_description(content)
    end
  end

  # Fallback description extraction
  defp extract_fallback_description(content) do
    case Regex.run(~r/^#[^\n]+\n\n(.*?)(?=<!-- MDESC !-->|\n##|\z)/s, content) do
      [_, description] -> String.trim(description)
      nil -> "No description available."
    end
  end

  # Extract dependencies from mix.exs
  defp extract_deps(component_path, type) do
    mix_exs_path = Path.join(component_path, "mix.exs")

    if File.exists?(mix_exs_path) do
      content = File.read!(mix_exs_path)
      var_name = get_var_name_for_type(type)
      process_deps_extraction(content, var_name, type, component_path)
    else
      []
    end
  end

  # Get variable name for dependency type
  defp get_var_name_for_type(:msbms), do: "@msbms_deps"
  defp get_var_name_for_type(:third_party), do: "@third_party_deps"

  # Process dependency extraction
  defp process_deps_extraction(content, var_name, type, component_path) do
    case extract_list_from_var(content, var_name) do
      nil ->
        Logger.debug("No #{var_name} found in #{Path.basename(component_path)}")
        []

      deps_content ->
        Logger.debug("Found #{var_name} content: #{inspect(String.slice(deps_content, 0, 100))}")
        parse_and_filter_deps(deps_content, type)
    end
  end

  # Parse and filter dependencies
  defp parse_and_filter_deps(deps_content, type) do
    result =
      deps_content
      |> String.split(~r/[,\n]/)
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == "" or String.starts_with?(&1, "#")))
      |> Enum.map(&extract_dep_name/1)
      |> Enum.reject(&is_nil/1)
      |> apply_type_filter(type)
      |> Enum.sort()

    Logger.debug("Extracted deps: #{inspect(result)}")
    result
  end

  # Apply type-specific filtering
  defp apply_type_filter(deps, :third_party), do: filter_runtime_deps(deps)
  defp apply_type_filter(deps, _type), do: deps

  # Filter out dev/test-only dependencies by checking msbms_build_config.exs
  defp filter_runtime_deps(deps) do
    # Known dev/test-only dependencies that shouldn't appear in production docs
    dev_test_only = ["credo", "dialyxir", "ex_doc", "extrace"]

    Enum.reject(deps, &(&1 in dev_test_only))
  end

  # Extract content between brackets after a variable name
  defp extract_list_from_var(content, var_name) do
    case :binary.match(content, var_name) do
      :nomatch ->
        nil

      {start_pos, _len} ->
        extract_bracketed_content(content, start_pos)
    end
  end

  # Extract content between brackets
  defp extract_bracketed_content(content, start_pos) do
    rest = binary_part(content, start_pos, byte_size(content) - start_pos)

    case :binary.match(rest, "[") do
      :nomatch ->
        nil

      {bracket_pos, _} ->
        find_and_extract_list(content, start_pos, bracket_pos)
    end
  end

  # Find and extract list content
  defp find_and_extract_list(content, start_pos, bracket_pos) do
    list_start = start_pos + bracket_pos + 1
    list_part = binary_part(content, list_start, byte_size(content) - list_start)

    case find_closing_bracket(list_part, 0, 1) do
      nil -> nil
      end_pos -> binary_part(list_part, 0, end_pos)
    end
  end

  # Find the closing bracket position
  defp find_closing_bracket(content, pos, _depth) when pos >= byte_size(content), do: nil

  defp find_closing_bracket(content, pos, depth) do
    case binary_part(content, pos, 1) do
      "[" -> find_closing_bracket(content, pos + 1, depth + 1)
      "]" when depth == 1 -> pos
      "]" -> find_closing_bracket(content, pos + 1, depth - 1)
      _ -> find_closing_bracket(content, pos + 1, depth)
    end
  end

  # Extract dependency name from various formats
  defp extract_dep_name(dep_str) do
    cond do
      # Simple atom: :dep_name
      String.match?(dep_str, ~r/^:([a-z_]+)$/) ->
        case Regex.run(~r/^:([a-z_]+)/, dep_str) do
          [_, name] -> name
          nil -> nil
        end

      # Tuple with options: {:dep_name, ...} or {:dep_name,
      String.match?(dep_str, ~r/^\{:/) ->
        case Regex.run(~r/^\{:([a-z_]+)/, dep_str) do
          [_, name] -> name
          nil -> nil
        end

      true ->
        nil
    end
  end

  # Get API documentation link
  defp get_api_doc_link(name) do
    "/documentation/technical/app_server/#{name}"
  end

  # Get database documentation link if it exists
  defp get_db_doc_link(base_dir, name) do
    db_component_paths = [
      "database/components/system/#{name}",
      "database/components/application/#{name}"
    ]

    exists? =
      Enum.any?(db_component_paths, fn path ->
        File.dir?(Path.join(base_dir, path))
      end)

    if exists? do
      "/documentation/technical/database/#{name}"
    else
      nil
    end
  end

  # Generate markdown content
  defp generate_markdown(component_data) do
    categorized =
      component_data
      |> Enum.group_by(& &1.category)

    content = [
      generate_frontmatter(),
      generate_header(),
      generate_platform_section(categorized[:platform] || []),
      generate_subsystems_section(categorized[:subsystem] || []),
      generate_components_section(categorized[:component] || [])
    ]

    {:ok, Enum.join(content, "\n")}
  end

  # Generate Hugo frontmatter
  defp generate_frontmatter do
    """
    +++
    title = "System Component Listing"
    linkTitle = "System Component Listing"
    description = "Here we begin documenting the system in detail, moving away from purely conceptual discussions to examining more concrete implementation details."

    draft = false

    weight = 30
    +++
    """
  end

  # Generate header section
  defp generate_header do
    """
    {{< alert title="Example Documentation" color="primary" >}}
    If you are reading this documentation to see and/or evaluate examples of this project's documentation, we recommend looking at the [__`MscmpSystAuthn`__](#mscmpsystauthn) Component documentation.  This documentation is reasonably complete and representative of the documentation standards this project hopes to achieve.
    {{< /alert >}}

    ## Overview

    The listing below shows the currently existing Elixir components which make up the application server (`app_server`), their dependencies, and their relationship with each other.

    {{< alert title="Dependency Listings" color="warning" >}}
    Note that only dependencies which are active at runtime in production are listed below. Excluded are those dependencies that are only present to support development or testing.
    {{< /alert >}}


    Each listed Component includes links to its application API documentation.  If the Component depends on the database, a link to the Component specific database documentation and ERD is also included.  Note that the inclusion of the database documentation at the Component level is not meant to imply that each Component requires its own database, but rather to ensure that only the relevant database documentation is presented in the Component context.

    """
  end

  # Generate platform section
  defp generate_platform_section([]) do
    """
    ## Platform

    _(No platform components found)_

    """
  end

  defp generate_platform_section(platforms) do
    platform_entries = Enum.map_join(platforms, "\n", &generate_component_entry(&1, 3))

    """
    ## Platform

    #{platform_entries}
    """
  end

  # Generate subsystems section
  defp generate_subsystems_section([]) do
    """
    ## Subsystems

    _(No subsystem components found)_

    """
  end

  defp generate_subsystems_section(subsystems) do
    subsystem_entries = Enum.map_join(subsystems, "\n", &generate_component_entry(&1, 3))

    """
    ## Subsystems

    #{subsystem_entries}
    """
  end

  # Generate components section
  defp generate_components_section([]) do
    """
    ## Component Documentation

    _(No components found)_
    """
  end

  defp generate_components_section(components) do
    component_entries = Enum.map_join(components, "\n", &generate_component_entry(&1, 3))

    """
    ## Component Documentation

    These Components are listed in "Lower Level Component" to "Higher Level Component" order.  Lower Level Components offer more simple, base level functionality whereas Higher Level Components will offer more complex functionality closer to the final business logic.  Often times Higher Level Components will depend on Lower Level Components.

    #{component_entries}
    """
  end

  # Generate entry for a single component
  defp generate_component_entry(component, heading_level) do
    title = module_name(component.name)

    doc_links = generate_doc_links(component)

    first_party_deps = generate_first_party_deps(component.msbms_deps)
    third_party_deps = generate_third_party_deps(component.third_party_deps)

    heading = String.duplicate("#", heading_level)

    formatted_description =
      component.description
      |> String.split("\n")
      |> Enum.map_join("\n", &("    " <> &1))

    """
      * #{heading} `#{title}`

        #{doc_links}

    #{formatted_description}

    #{first_party_deps}

    #{third_party_deps}
    """
  end

  # Generate documentation links
  defp generate_doc_links(component) do
    api_link = ~s(<a href="#{component.api_doc_link}" target="_blank">API Docs</a>)

    if component.db_doc_link do
      db_link = ~s(<a href="#{component.db_doc_link}" target="_blank">Database Docs & ERD</a>)
      "<sup>(#{api_link}) / (#{db_link})</sup>"
    else
      "<sup>(#{api_link})</sup>"
    end
  end

  # Generate first party dependencies list
  defp generate_first_party_deps([]) do
    """
        * __First Party Dependencies__

          (none)
    """
  end

  defp generate_first_party_deps(deps) do
    dep_links =
      Enum.map_join(deps, ",\n      ", fn dep ->
        anchor = String.downcase(dep) |> String.replace("_", "")
        ~s(<a href="##{anchor}">`#{dep}`</a>)
      end)

    """
        * __First Party Dependencies__

          #{dep_links}
    """
  end

  # Generate third party dependencies list
  defp generate_third_party_deps([]) do
    """
        * __Third Party Dependencies__

          (none)
    """
  end

  defp generate_third_party_deps(deps) do
    dep_links =
      Enum.map_join(deps, ",\n      ", fn dep ->
        ~s(<a href="https://hexdocs.pm/#{dep}" target="_blank">`#{dep}`</a>)
      end)

    """
        * __Third Party Dependencies__

          #{dep_links}
    """
  end

  # Convert component name to module name
  defp module_name(component_name) do
    component_name
    |> String.split("_")
    |> Enum.map_join(&String.capitalize/1)
  end

  # Write output file
  defp write_output_file(output_path, content) do
    # Ensure directory exists
    output_dir = Path.dirname(output_path)
    File.mkdir_p!(output_dir)

    case File.write(output_path, content) do
      :ok ->
        :ok

      {:error, reason} ->
        {:error, "Failed to write output file: #{inspect(reason)}"}
    end
  end
end
