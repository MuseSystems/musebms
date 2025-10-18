# Source File: test_selector.ex
# Location:    musebms/app_server/components/system/mscmp_syst_perms/test/support/test_selector.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystPerms.TestSelector do
  @moduledoc """
  A dummy selector struct used only for test/dev environments to satisfy the
  MscmpSystPerms.Protocol implementation requirement in Elixir 1.19+.

  This implementation exists solely to quiet compiler warnings about protocols
  that are defined but not implemented. It should not be used in production code.
  """

  defstruct [:id]

  @type t() :: %__MODULE__{
          id: binary()
        }
end

defimpl MscmpSystPerms.Protocol, for: MscmpSystPerms.TestSelector do
  @moduledoc """
  Dummy implementation of MscmpSystPerms.Protocol for the TestSelector struct.

  This implementation is used only in test/dev environments to satisfy Elixir
  1.19+ protocol implementation requirements. All functions return empty/minimal
  valid responses.
  """

  alias MscmpSystPerms.Types

  @impl MscmpSystPerms.Protocol
  @spec get_effective_perm_grants(MscmpSystPerms.TestSelector.t(), Keyword.t()) ::
          {:ok, Types.perm_grants()} | {:error, Exception.t()}
  def get_effective_perm_grants(_selector, _opts) do
    {:ok, %{}}
  end

  @impl MscmpSystPerms.Protocol
  @spec list_perm_grants(MscmpSystPerms.TestSelector.t(), Keyword.t()) ::
          {:ok, [Msdata.SystPermRoles.t()]} | {:error, Exception.t()}
  def list_perm_grants(_selector, _opts) do
    {:ok, []}
  end

  @impl MscmpSystPerms.Protocol
  @spec list_perm_denials(MscmpSystPerms.TestSelector.t(), Keyword.t()) ::
          {:ok, [Msdata.SystPerms.t()] | []} | {:error, Exception.t()}
  def list_perm_denials(_selector, _opts) do
    {:ok, []}
  end

  @impl MscmpSystPerms.Protocol
  @spec grant_perm_role(MscmpSystPerms.TestSelector.t(), Types.perm_role_id()) ::
          :ok | {:error, Exception.t()}
  def grant_perm_role(_selector, _perm_role_id) do
    :ok
  end

  @impl MscmpSystPerms.Protocol
  @spec revoke_perm_role(MscmpSystPerms.TestSelector.t(), Types.perm_role_id()) ::
          :ok | {:error, Exception.t()}
  def revoke_perm_role(_selector, _perm_role_id) do
    :ok
  end
end
