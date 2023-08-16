# Source File: msicons.ex
# Location:    musebms/app_server/components/system/mscmp_syst_forms/lib/impl/web_components/msicons.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystForms.Impl.WebComponents.Msicons do
  use Phoenix.Component

  @moduledoc false

  attr(:name, :string, required: true)
  attr(:class, :string, default: nil)

  def msicon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end
end
