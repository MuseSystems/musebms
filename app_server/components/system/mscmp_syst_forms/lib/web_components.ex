# Source File: web_components.ex
# Location:    musebms/app_server/components/system/mscmp_syst_forms/lib/web_components.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystForms.WebComponents do
  alias MscmpSystForms.Impl.WebComponents

  @moduledoc """
  A set of web components which define the standard application user interface
  "widgets" from which the application is built.
  """

  @doc section: :control_components
  @doc """
  Displays a simple button with which the user may interact.


  """
  defdelegate msbutton(assigns), to: WebComponents.Msbuttons

  @doc section: :control_components
  @doc """
  Provides a three state button where the state is meant to be determined by
  some external condition, such as a form validation.
  """
  defdelegate msvalidated_button(assigns), to: WebComponents.Msbuttons

  @doc section: :container_components
  @doc """
  A generalized container component which provides layouts for and contains
  other user interface elements.
  """
  defdelegate mscontainer(assigns), to: WebComponents.Mscontainers

  @doc section: :container_components
  @doc """
  A specialized container component for containing extended text.
  """
  defdelegate msdisplay(assigns), to: WebComponents.Msdisplays

  @doc section: :utility_components
  @doc """
  A utility component which displays an exclamation mark in a circle in the
  presence of errors.
  """
  defdelegate msfield_errors(assigns), to: WebComponents.MsfieldErrors

  @doc section: :container_components
  @doc """
  A specialized container which defines an HTML form.
  """
  defdelegate msform(assigns), to: WebComponents.Msforms

  @doc section: :utility_components
  @doc """
  A small utility component which gives regularized access to "Heroicons".
  """
  defdelegate msicon(assigns), to: WebComponents.Msicons

  @doc section: :container_components
  @doc """
  A component which provides the capability to include short reference
  documentation in a form.
  """
  defdelegate msinfo(assigns), to: WebComponents.Msinfo

  @doc section: :input_components
  @doc """
  A component which accepts a wide range of textually oriented user input.
  """
  defdelegate msinput(assigns), to: WebComponents.Msinputs

  @doc section: :container_components
  @doc """
  A component which defines a list of entries or other components.
  """
  defdelegate mslist(assigns), to: WebComponents.Mslists

  @doc section: :container_components
  @doc """
  Creates an list entry within an established `mslist/1`.
  """
  defdelegate mslistitem(assigns), to: WebComponents.Mslists

  @doc section: :container_components
  @doc """
  Generates a modal window.
  """
  defdelegate msmodal(assigns), to: WebComponents.Msmodals

  @doc section: :container_components
  @doc """
  A container component which typically encapsulates its contents with a border
  and provides the section a label.
  """
  defdelegate mssection(assigns), to: WebComponents.Mssections
end
