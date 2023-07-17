# Source File: helpers.ex
# Location:    musebms/app_server/components/system/mscmp_syst_forms/lib/impl/web_components/helpers/helpers.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystForms.Impl.WebComponents.Helpers do
  alias MscmpSystForms.Types
  alias MscmpSystForms.Types.ComponentConfig

  import MscmpSystForms.Impl.Gettext

  @moduledoc false

  ##############################################################################
  #
  # Component Helpers
  #
  ##############################################################################

  @spec get_least_component_mode(Types.component_mode(), Types.component_mode()) ::
          Types.component_mode()
  def get_least_component_mode(mode_left, mode_right),
    do: get_least_component_mode([mode_left, mode_right])

  @spec get_least_component_mode(list(Types.component_mode())) :: Types.component_mode()
  def get_least_component_mode([_ | _] = mode_list) do
    cond do
      :removed in mode_list -> :removed
      :hidden in mode_list -> :hidden
      :cleared in mode_list -> :cleared
      :processing in mode_list -> :processing
      :visible in mode_list -> :visible
      :entry in mode_list -> :entry
    end
  end

  ##############################################################################
  #
  # Background Mode Helpers
  #
  ##############################################################################

  @spec get_background_classes(Types.display_mode() | list(String.t()) | nil) :: list(String.t())
  def get_background_classes([_ | _] = classes), do: classes

  def get_background_classes(display_mode) when is_atom(display_mode),
    do: get_background_classes(display_mode, :standard)

  @spec get_background_classes(Types.display_mode() | nil, :standard | :inverted) ::
          list(String.t())
  def get_background_classes(:deemphasis, :standard), do: ~w(bg-color-deemphasis)
  def get_background_classes(:reference, :standard), do: ~w(bg-color-reference)
  def get_background_classes(:normal, :standard), do: ~w(bg-color-reference)
  def get_background_classes(:emphasis, :standard), do: ~w(bg-color-emphasis)
  def get_background_classes(:warning, :standard), do: ~w(bg-color-warning)
  def get_background_classes(:alert, :standard), do: ~w(bg-color-alert)
  def get_background_classes(:approve, :standard), do: ~w(bg-color-approve)
  def get_background_classes(:deny, :standard), do: ~w(bg-color-deny)
  def get_background_classes(:info, :standard), do: ~w(bg-color-info)
  def get_background_classes(_, :standard), do: ~w(bg-color-normal)
  def get_background_classes(:deemphasis, :inverted), do: ~w(bg-color-deemphasis-inverted)
  def get_background_classes(:reference, :inverted), do: ~w(bg-color-reference-inverted)
  def get_background_classes(:normal, :inverted), do: ~w(bg-color-reference-inverted)
  def get_background_classes(:emphasis, :inverted), do: ~w(bg-color-emphasis-inverted)
  def get_background_classes(:warning, :inverted), do: ~w(bg-color-warning-inverted)
  def get_background_classes(:alert, :inverted), do: ~w(bg-color-alert-inverted)
  def get_background_classes(:approve, :inverted), do: ~w(bg-color-approve-inverted)
  def get_background_classes(:deny, :inverted), do: ~w(bg-color-deny-inverted)
  def get_background_classes(:info, :inverted), do: ~w(bg-color-info-inverted)
  def get_background_classes(_, :inverted), do: ~w(bg-color-normal-inverted)

  ##############################################################################
  #
  # Border Mode Helpers
  #
  ##############################################################################

  # The idea here is to make border + padding = spacing constant.  This way if
  # we add a border to something, we won't see the container contents shifting
  # around (that's the idea anyway).

  @spec get_border_classes(Types.display_mode() | list(String.t()) | nil) :: list(String.t())
  def get_border_classes([_ | _] = classes), do: classes
  def get_border_classes(:deemphasis), do: ~w(border-2 p-1 border-color-deemphasis)
  def get_border_classes(:reference), do: ~w(border-2 p-1 border-color-reference)
  def get_border_classes(:normal), do: ~w(border-2 p-1 border-color-reference)
  def get_border_classes(:emphasis), do: ~w(border-2 border-double p-0.5 border-color-emphasis)
  def get_border_classes(:warning), do: ~w(border-2 border-double p-0.5 border-color-warning)
  def get_border_classes(:alert), do: ~w(border-2 border-double p-0.5 border-color-alert)
  def get_border_classes(:approve), do: ~w(border-2 p-1 border-color-approve)
  def get_border_classes(:deny), do: ~w(border-2 p-1 border-color-deny)
  def get_border_classes(:info), do: ~w(border-2 p-1 border-color-info)
  def get_border_classes(_), do: ~w(p-1.5)

  ##############################################################################
  #
  # Text Mode Helpers
  #
  ##############################################################################

  @spec get_text_classes(Types.display_mode() | list(String.t()) | nil) :: list(String.t())
  def get_text_classes([_ | _] = classes), do: classes

  def get_text_classes(:deemphasis),
    do: ~w(font-serif font-normal text-base text-color-deemphasis)

  def get_text_classes(:reference), do: ~w(font-serif font-normal text-color-reference)
  def get_text_classes(:normal), do: ~w(font-serif font-normal text-color-normal)
  def get_text_classes(:emphasis), do: ~w(font-serif font-bold text-color-emphasis)
  def get_text_classes(:warning), do: ~w(font-serif font-bold text-color-warning)
  def get_text_classes(:alert), do: ~w(font-serif font-black text-color-alert)
  def get_text_classes(:approve), do: ~w(font-serif font-bold text-color-approve)
  def get_text_classes(:deny), do: ~w(font-serif font-bold text-color-deny)
  def get_text_classes(:info), do: ~w(font-serif font-normal text-color-info)
  def get_text_classes(_), do: ~w(font-serif font-normal text-color-normal)

  ##############################################################################
  #
  # Label Mode Helpers
  #
  ##############################################################################

  @spec get_label_classes(Types.display_mode() | list(String.t()) | nil) :: list(String.t())
  def get_label_classes([_ | _] = classes), do: classes

  def get_label_classes(display_mode) when is_atom(display_mode),
    do: get_label_classes(display_mode, :standard)

  @spec get_label_classes(Types.display_mode() | nil, :standard | :inverted) :: list(String.t())
  def get_label_classes(:deemphasis, :standard),
    do: ~w(font-sans text-sm font-normal text-color-deemphasis)

  def get_label_classes(:reference, :standard),
    do: ~w(font-sans text-sm font-normal text-color-reference)

  def get_label_classes(:normal, :standard),
    do: ~w(font-sans text-sm font-semibold text-color-normal)

  def get_label_classes(:emphasis, :standard),
    do: ~w(font-sans text-sm font-bold text-color-emphasis)

  def get_label_classes(:warning, :standard),
    do: ~w(font-sans text-sm font-bold text-color-warning)

  def get_label_classes(:alert, :standard), do: ~w(font-sans text-sm font-black text-color-alert)

  def get_label_classes(:approve, :standard),
    do: ~w(font-sans text-sm font-bold text-color-approve)

  def get_label_classes(:deny, :standard), do: ~w(font-sans text-sm font-bold text-color-deny)
  def get_label_classes(:info, :standard), do: ~w(font-sans text-sm font-normal text-color-info)
  def get_label_classes(_, :standard), do: ~w(font-sans text-sm font-normal text-color-normal)

  def get_label_classes(:deemphasis, :inverted),
    do: ~w(font-sans text-sm font-normal text-color-deemphasis-inverted)

  def get_label_classes(:reference, :inverted),
    do: ~w(font-sans text-sm font-normal text-color-reference-inverted)

  def get_label_classes(:normal, :inverted),
    do: ~w(font-sans text-sm font-semibold text-color-normal-inverted)

  def get_label_classes(:emphasis, :inverted),
    do: ~w(font-sans text-sm font-bold text-color-emphasis-inverted)

  def get_label_classes(:warning, :inverted),
    do: ~w(font-sans text-sm font-bold text-color-warning-inverted)

  def get_label_classes(:alert, :inverted),
    do: ~w(font-sans text-sm font-black text-color-alert-inverted)

  def get_label_classes(:approve, :inverted),
    do: ~w(font-sans text-sm font-bold text-color-approve-inverted)

  def get_label_classes(:deny, :inverted),
    do: ~w(font-sans text-sm font-bold text-color-deny-inverted)

  def get_label_classes(:info, :inverted),
    do: ~w(font-sans text-sm font-normal text-color-info-inverted)

  def get_label_classes(_, :inverted),
    do: ~w(font-sans text-sm font-normal text-color-normal-inverted)

  ##############################################################################
  #
  # Color Helpers
  #
  ##############################################################################

  @spec get_color_name(Types.display_mode() | nil) :: String.t()
  def get_color_name(:reference), do: "color-reference"
  def get_color_name(:normal), do: "color-normal"
  def get_color_name(:emphasis), do: "color-emphasis"
  def get_color_name(:warning), do: "color-warning"
  def get_color_name(:alert), do: "color-alert"
  def get_color_name(:approve), do: "color-approve"
  def get_color_name(:deny), do: "color-deny"
  def get_color_name(:info), do: "color-info"
  def get_color_name(_), do: "color-normal"

  ##############################################################################
  #
  # Error Translation
  #
  ##############################################################################

  # This is largely just cut/paste from Phoenix CoreComponents.

  def translate_error({msg, opts}) do
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

  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end

  def resolve_modes(component_config, attr_modes, default_modes, active_overrides) do
    given_modes =
      unless component_config == nil do
        (component_config.modes || attr_modes || %{})
        |> maybe_apply_processing_override(component_config.overrides, active_overrides)
      else
        attr_modes || %{}
      end

    Map.merge(default_modes, given_modes)
  end

  defp maybe_apply_processing_override(
         %{component_mode: :entry} = modes,
         overrides,
         active_overrides
       ) do
    if Enum.any?(active_overrides, &Enum.member?(overrides, &1)),
      do: Map.put(modes, :component_mode, :visible),
      else: modes
  end

  defp maybe_apply_processing_override(modes, _, _), do: modes

  def resolve_form_id(%{component_config: %ComponentConfig{form_id: form_id}})
      when is_atom(form_id),
      do: Atom.to_string(form_id)

  def resolve_form_id(%{id: id}) when is_binary(id), do: id

  def resolve_form_id(assigns) do
    raise MscmpSystError,
      code: :undefined_error,
      message:
        "Missing component ID value.  You must either set the 'id' attribute or a valid 'component_config' attribute.",
      cause: %{params: %{assigns: assigns}}
  end
end
