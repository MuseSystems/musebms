# Source File: MsbmsBuildClean.psm1
# Location:    musebms/tools/build_tools/msbms_build_modules/MsbmsBuildClean.psm1
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

function Initialize-LS {
  param ( [string[]]$Components = @() )
  Initialize-ElixirElement -Components $Components -Element "Elixir Language Server"
}

function Initialize-PLT {
  param ( [string[]]$Components = @() )
  Initialize-ElixirElement -Components $Components -Element "Elixir PLT"
}

function Initialize-Build {
  param ( [string[]]$Components = @() )
  Initialize-ElixirElement -Components $Components -Element "Elixir Build"
}

function Initialize-Deps {
  param ( [string[]]$Components = @() )
  Initialize-ElixirElement -Components $Components -Element "Elixir Deps"
}

function Initialize-ElixirElement {
  param ( [string[]]$Components = @(), [string]$Element )

  $element_path = switch -Exact ( $Element ) {
    "Elixir Language Server" { ".elixir_ls" }
    "Elixir PLT" { "priv/plts" }
    "Elixir Build" { "_build" }
    "Elixir Deps" { "deps" }
  }

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
        ( $Components.count -eq 0 ) -or
        ( $Components -contains $_ )
    }

    foreach ( $current_component in $target_components) {

      Write-Host ""
      Write-Host "===========> ${current_component}: Start Initialize ${Element}.  ($(Get-Date -Format "o"))"

      Remove-Item ( Join-Path $start_path $component_path $current_component $element_path ) -Recurse -Force

      Write-Host "===========> ${current_component}: Finish Initialize ${Element}.  ($(Get-Date -Format "o"))"
      Write-Host ""

    }
  }
}

Export-ModuleMember -Function Initialize-LS, Initialize-PLT, Initialize-Build, Initialize-Deps
