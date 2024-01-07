# Source File: MsbmsBuildDocs.psm1
# Location:    musebms/tools/build_tools/msbms_build_modules/MsbmsBuildDocs.psm1
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

function Build-ElixirDocs {
  param ( [string[]]$Components = @() )

  $start_path = Get-Location

  $elixir_docs_root = "documentation/technical/app_server"

  $elixir_component_paths = @(
    "app_server/components/system"
    "app_server/components/application"
    "app_server/subsystems"
    "app_server/platform"
  ) | Where-Object { Test-Path $_ -PathType Container }

  foreach ( $component_path in $elixir_component_paths) {
    $target_components =
    Get-ChildItem $component_path -Directory |
    Split-Path -Leaf |
    Where-Object {
        ( $null -eq $Components ) -or
        ( @($Components).count -eq 0 ) -or
        ( $Components -contains $_ )
    }

    foreach ( $current_component in $target_components) {
      Write-Host ""
      Write-Host "===========> ${current_component}: Start Elixir docs build.  ($(Get-Date -Format "o"))"

      Remove-Item ( Join-Path $start_path $elixir_docs_root $current_component  ) -Recurse -Force

      Push-Location -Path ( Join-Path $start_path $component_path $current_component  )

      mix docs

      Pop-Location

      Write-Host "===========> ${current_component}: Finish Elixir docs build.  ($(Get-Date -Format "o"))"
      Write-Host ""
    }
  }
}

function Build-DbDocs {
  param ( [string[]]$Components = @() )

  $start_path = Get-Location

  $db_source_root = "database"

  $db_docs_root = "documentation/technical/database"

  $elixir_component_paths = @(
    "app_server/components/system"
    "app_server/components/application"
    "app_server/subsystems"
    "app_server/platform"
  ) | Where-Object { Test-Path $_ -PathType Container }

  foreach ( $component_path in $elixir_component_paths) {
    $target_components =
    Get-ChildItem $component_path -Directory |
    Split-Path -Leaf |
    Where-Object {
        ( $null -eq $Components ) -or
        ( @($Components).count -eq 0 ) -or
        ( $Components -contains $_ )
    }

    foreach ( $current_component in $target_components) {
      $component_buildplan_name = "buildplans.${current_component}_db_docs.toml"

      $component_buildplan_path = Join-Path $start_path $db_source_root $component_buildplan_name

      $component_docs_path = Join-Path $start_path $db_docs_root $current_component

      if (! ( Test-Path -Path $component_buildplan_path -PathType Leaf ) ) { continue }

      Write-Host ""
      Write-Host "===========> ${current_component}: Start DB docs build.  ($(Get-Date -Format "o"))"

      Remove-Item $component_docs_path -Recurse -Force

      Push-Location -Path ( Join-Path $start_path $component_path $current_component  )

      mix loaddb `
        --build `
        --clean `
        --type "${current_component}_db_docs" `
        --db-name "${current_component}" `
        --source "$(Join-Path $start_path $db_source_root)"

      java `
        -jar "${start_path}/tools/build_tools/schemaspy/schemaspy-6.2.4.jar" `
        -t pgsql11 `
        -dp "${start_path}/tools/build_tools/schemaspy/postgresql-42.7.1.jar" `
        -db "${current_component}" `
        -host 127.0.0.1 `
        -port 5432 `
        -all `
        -schemaSpec "ms_.+" `
        -norows `
        -imageformat svg `
        -nopages `
        -noimplied `
        -u "ms_documentation_role" `
        -p "ms_documentation_password" `
        -o "${component_docs_path}"

      mix dropdb `
        --clean `
        --type "${current_component}_db_docs" `
        --db-name "${current_component}"

      Pop-Location

      Write-Host "===========> ${current_component}: Finish DB docs build.  ($(Get-Date -Format "o"))"
      Write-Host ""
    }
  }
}
