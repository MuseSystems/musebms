# Source File: msinputs.ex
# Location:    musebms/app_server/components/system/mscmp_syst_forms/lib/impl/web_components/msinputs.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

# Note that substantial portions of the code below are copied from the default
# Phoenix core components template (v 1.7.1) with modifications for our uses.
#
# https://github.com/phoenixframework/phoenix/blob/v1.7.1/installer/templates/phx_web/components/core_components.ex

defmodule MscmpSystForms.Impl.WebComponents.Msinputs do
  use Phoenix.Component

  alias MscmpSystForms.Impl.WebComponents
  alias MscmpSystForms.Impl.WebComponents.Helpers
  alias MscmpSystForms.Types.ComponentConfig

  @moduledoc false

  @default_modes %{
    component_mode: :entry,
    border_mode: [],
    text_mode: :normal,
    label_mode: :normal
  }

  @default_layout ~w(flex flex-col)
  @default_alignment ~w(items-stretch justify-items-stretch)
  @default_sizing ~w()
  @default_spacing ~w(m-1)

  attr(:id, :string)
  attr(:component_config, ComponentConfig)
  attr(:active_overrides, :list, default: [])
  attr(:modes, :map, default: @default_modes)
  attr(:layout, :list, default: @default_layout)
  attr(:alignment, :list, default: @default_alignment)
  attr(:sizing, :list, default: @default_sizing)
  attr(:spacing, :list, default: @default_spacing)
  attr(:extra_classes, :list, default: [])

  attr(:field_name, :any)
  attr(:title, :string, default: nil)
  attr(:value, :any)

  attr(:type, :atom,
    default: :text,
    values: ~w(text email password integer)a
  )

  attr(:field, Phoenix.HTML.FormField)

  attr(:validation_delay, :integer, default: 2000)

  attr(:errors, :list, default: [])
  attr(:checked, :boolean, doc: "the checked flag for checkbox inputs")
  attr(:prompt, :string, default: nil, doc: "the prompt for select inputs")
  attr(:options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2")

  attr(:autocomplete, :boolean, default: true)
  attr(:cols, :integer, default: 20)
  attr(:rows, :integer, default: 5)

  attr(:numeric_max, :float)
  attr(:numeric_min, :float)
  attr(:numeric_increment, :float)

  attr(:maxlength, :integer, default: 20)
  attr(:minlength, :integer, default: 0)
  attr(:fieldsize, :integer, default: 20)

  def msinput(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    resolved_id = Helpers.resolve_form_id(assigns)

    resolved_modes =
      Helpers.resolve_modes(
        assigns[:component_config],
        assigns.modes,
        @default_modes,
        assigns.active_overrides
      )

    resolved_title =
      cond do
        is_binary(assigns.title) -> assigns.title
        not is_nil(assigns[:component_config]) -> assigns.component_config.label
        true -> "(Field Unlabelled)"
      end

    input_classes = [
      ~w(mt-2 block w-full rounded-lg py-[7px] px-[11px] disabled:bg-color-deemphasis),
      msinput_border(assigns.errors)
    ]

    label_classes = Helpers.get_label_classes(resolved_modes.label_mode)

    component_classes = [
      assigns.layout,
      assigns.sizing,
      assigns.spacing,
      assigns.alignment,
      get_component_classes(resolved_modes.component_mode)
    ]

    assigns
    |> assign(:resolved_title, resolved_title)
    |> assign(:resolved_id, resolved_id)
    |> assign(:field, nil)
    |> assign(:errors, Enum.map(field.errors, &translate_error(&1)))
    |> assign(:label_classes, label_classes)
    |> assign(:input_classes, input_classes)
    |> assign(:component_classes, component_classes)
    |> assign(:disabled, resolved_modes.component_mode in [:visible, :cleared, :removed])
    |> assign(:hidden, resolved_modes.component_mode == :removed)
    |> assign(:input_attribs, [])
    |> assign_new(:field_name, fn ->
      if assigns.type == :multiselect, do: field.name <> "[]", else: field.name
    end)
    |> assign_new(:value, fn -> field.value end)
    |> msinput()
  end

  def msinput(assigns) do
    assigns =
      assigns
      |> maybe_add_integer_attributes()
      |> maybe_add_decimal_attributes()
      |> maybe_add_common_attributes()
      |> set_html_type_for_mstype()

    ~H"""
    <div id={@resolved_id} phx-feedback-for={@field_name} class={@component_classes}>
      <div class="flex space-x-1">
        <label for={"#{@resolved_id}-msinput"} class={@label_classes}><%= @resolved_title %></label>
        <WebComponents.MsfieldErrors.msfield_errors :if={@errors != []} id={"#{@resolved_id}-errors"}>
          <:msfield_error_item :for={msg <- @errors}>
            <p><%= msg %></p>
          </:msfield_error_item>
        </WebComponents.MsfieldErrors.msfield_errors>
      </div>
      <input
        id={"#{@resolved_id}-msinput"}
        type={@html_type}
        name={@field_name}
        value={@value}
        class={[@input_classes, ""]}
        {@input_attribs}
        disabled={@disabled == true}
        hidden={@hidden == true}
        autocomplete={@autocomplete == true}
        phx-debounce={@validation_delay}
      />
    </div>
    """
  end

  defp get_component_classes(:removed), do: ~w(hidden)
  defp get_component_classes(:cleared), do: ~w(invisible)
  defp get_component_classes(_), do: []

  defp maybe_add_integer_attributes(%{type: :integer} = assigns) do
    assigns.input_attribs
    |> maybe_add_integer_increment_attrib(assigns[:numeric_increment])
    |> maybe_add_integer_max_attrib(assigns[:numeric_max])
    |> maybe_add_integer_min_attrib(assigns[:numeric_min])
    |> then(&assign(assigns, :input_attribs, &1))
  end

  defp maybe_add_integer_attributes(assigns), do: assigns

  defp maybe_add_integer_increment_attrib(input_attribs, value) when is_integer(value),
    do: [{:step, value} | input_attribs]

  defp maybe_add_integer_increment_attrib(input_attribs, nil), do: input_attribs

  defp maybe_add_integer_max_attrib(input_attribs, value) when is_integer(value),
    do: [{:max, value} | input_attribs]

  defp maybe_add_integer_max_attrib(input_attribs, nil), do: input_attribs

  defp maybe_add_integer_min_attrib(input_attribs, value) when is_integer(value),
    do: [{:min, value} | input_attribs]

  defp maybe_add_integer_min_attrib(input_attribs, nil), do: input_attribs

  defp maybe_add_decimal_attributes(%{type: :decimal} = assigns) do
    assigns.input_attribs
    |> maybe_add_decimal_increment_attrib(assigns[:numeric_increment])
    |> maybe_add_decimal_max_attrib(assigns[:numeric_max])
    |> maybe_add_decimal_min_attrib(assigns[:numeric_min])
    |> then(&assign(assigns, :input_attribs, &1))
  end

  defp maybe_add_decimal_attributes(assigns), do: assigns

  defp maybe_add_decimal_increment_attrib(input_attribs, value) when is_float(value),
    do: [{:step, value} | input_attribs]

  defp maybe_add_decimal_increment_attrib(input_attribs, nil), do: input_attribs

  defp maybe_add_decimal_max_attrib(input_attribs, value) when is_float(value),
    do: [{:max, value} | input_attribs]

  defp maybe_add_decimal_max_attrib(input_attribs, nil), do: input_attribs

  defp maybe_add_decimal_min_attrib(input_attribs, value) when is_float(value),
    do: [{:min, value} | input_attribs]

  defp maybe_add_decimal_min_attrib(input_attribs, nil), do: input_attribs

  defp maybe_add_common_attributes(assigns) do
    assigns.input_attribs
    |> maybe_add_maxlength_attrib(assigns[:maxlength])
    |> maybe_add_minlength_attrib(assigns[:minlength])
    |> maybe_add_fieldsize_attrib(assigns[:fieldsize])
    |> then(&assign(assigns, :input_attribs, &1))
  end

  defp maybe_add_maxlength_attrib(input_attribs, value) when is_integer(value),
    do: [{:maxlength, value} | input_attribs]

  defp maybe_add_maxlength_attrib(input_attribs, nil), do: input_attribs

  defp maybe_add_minlength_attrib(input_attribs, value) when is_integer(value),
    do: [{:minlength, value} | input_attribs]

  defp maybe_add_minlength_attrib(input_attribs, nil), do: input_attribs

  defp maybe_add_fieldsize_attrib(input_attribs, value) when is_integer(value),
    do: [{:size, value} | input_attribs]

  defp maybe_add_fieldsize_attrib(input_attribs, nil), do: input_attribs

  defp set_html_type_for_mstype(%{type: :password} = assigns),
    do: assign(assigns, :html_type, "password")

  defp set_html_type_for_mstype(%{type: :email} = assigns),
    do: assign(assigns, :html_type, "email")

  defp set_html_type_for_mstype(assigns), do: assign(assigns, :html_type, "text")

  defp msinput_border([] = _errors),
    do: ~w(border-color-reference focus:border-normal focus:ring-color-emphasis/5)

  defp msinput_border([_ | _] = _errors),
    do: ~w(border-color-alert focus:border-color-alert focus:ring-color-alert/10)

  defp translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate "is invalid" in the "errors" domain
    #     dgettext("errors", "is invalid")
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # Because the error messages we show in our forms and APIs
    # are defined inside Ecto, we need to translate them dynamically.
    # This requires us to call the Gettext module passing our gettext
    # backend as first argument.
    #
    # Note we use the "errors" domain, which means translations
    # should be written to the errors.po file. The :count option is
    # set by Ecto and indicates we should also apply plural rules.
    if count = opts[:count] do
      Gettext.dngettext(MsappMcpWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(MsappMcpWeb.Gettext, "errors", msg, opts)
    end
  end
end
