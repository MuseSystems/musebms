# Source File: MsbmsBuildUpdate.psm1
# Location:    musebms/tools/build_tools/msbms_build_modules/MsbmsBuildUpdate.psm1
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

function Install-ElixirDeps {
  param ( [string[]]$Components = @() )

  $start_path = Get-Location

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
      Write-Host "===========> ${current_component}: Start Elixir deps install.  ($(Get-Date -Format "o"))"

      Push-Location -Path ( Join-Path $start_path $component_path $current_component  )

      mix deps.get

      Pop-Location

      Write-Host "===========> ${current_component}: Finish Elixir deps install.  ($(Get-Date -Format "o"))"
      Write-Host ""
    }
  }
}

function Update-ElixirDeps {
  param ( [string[]]$Components = @() )

  $start_path = Get-Location

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
      Write-Host "===========> ${current_component}: Start Elixir deps update.  ($(Get-Date -Format "o"))"

      Push-Location -Path ( Join-Path $start_path $component_path $current_component  )

      mix deps.update --all

      Pop-Location

      Write-Host "===========> ${current_component}: Finish Elixir deps update.  ($(Get-Date -Format "o"))"
      Write-Host ""
    }
  }
}
