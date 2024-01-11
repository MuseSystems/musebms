#!/usr/bin/pwsh

# Source File: Build-Msbms.ps1
# Location:    musebms/tools/build_tools/Build-Msbms.ps1
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

param (
  [switch]$DocsElixir = $false,
  [switch]$DocsDb = $false,
  [switch]$DocsAll = $false,
  [switch]$CleanLs = $false,
  [switch]$CleanPlt = $false,
  [switch]$CleanBuild = $false,
  [switch]$CleanDeps = $false,
  [switch]$CleanAll = $false,
  [switch]$DepsGet = $false,
  [switch]$DepsUpdate = $false,
  [switch]$All = $false,
  [switch]$AllUpdate = $false,
  [string[]]$Components = @()
)


# Just a sanity check.  This probably can be more robust and correct.

if (
  !(Test-Path -Path "database") -or
  !(Test-Path -Path "app_server") -or
  !(Test-Path -Path "documentation") -or
  (Get-Content LICENSE.md -First 1) -notlike
  "*Muse Systems Business Management System License Agreement*"
) {

  Write-Error "This script must be run from the root path of the project."
  Exit 1

}

$do_deps_update = $DepsUpdate -or $AllUpdate
$do_clean_ls = $CleanLs -or $CleanAll -or $All -or $do_deps_update
$do_clean_plt = $CleanPlt -or $CleanAll -or $All -or $do_deps_update
$do_clean_build = $CleanBuild -or $CleanAll -or $All -or $do_deps_update
$do_clean_deps = $CleanDeps -or $CleanAll -or $All -or $do_deps_update
$do_deps_get = $DepsGet -or $CleanAll -or $All -or $do_deps_update
$do_docs_elixir = $DocsElixir -or $DocsAll -or $All -or $AllUpdate
$do_docs_db = $DocsDb -or $DocsAll -or $All -or $AllUpdate

Import-Module ./tools/build_tools/msbms_build_modules/MsbmsBuildDocs.psm1
Import-Module ./tools/build_tools/msbms_build_modules/MsbmsBuildClean.psm1
Import-Module ./tools/build_tools/msbms_build_modules/MsbmsBuildUpdate.psm1

if ($do_clean_ls) { Initialize-LS( $Components ) }
if ($do_clean_plt) { Initialize-PLT( $Components ) }
if ($do_clean_build) { Initialize-Build( $Components ) }
if ($do_clean_deps) { Initialize-Deps( $Components ) }

if ($do_deps_update) { Update-ElixirDeps( $Components ) }

if ($do_deps_get) { Install-ElixirDeps( $Components ) }

if ($do_docs_elixir) { Build-ElixirDocs( $Components  ) }
if ($do_docs_db) { Build-DbDocs( $Components  ) }

Remove-Module -Name MsbmsBuildClean, MsbmsBuildDocs, MsbmsBuildUpdate
