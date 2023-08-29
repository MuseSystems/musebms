# Source File: forms.ex
# Location:    musebms/app_server/components/system/mscmp_syst_forms/lib/impl/forms.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystForms.Impl.Forms do
  alias MscmpSystForms.Types
  alias MscmpSystForms.Types.ComponentConfig
  alias MscmpSystForms.Types.FormConfig

  import Phoenix.Component, only: [assign: 2, assign: 3]

  @moduledoc false

  @default_perm :default_permission
  @default_modes %{component_mode: :cleared}

  @spec init_assigns(
          Types.socket_or_assigns(),
          Types.session_name(),
          module(),
          Types.form_state_feature_name(),
          Types.form_state_mode_name(),
          Types.form_state_state_name(),
          MscmpSystPerms.Types.perm_grants(),
          Keyword.t() | []
        ) :: Types.socket_or_assigns()
  def init_assigns(
        socket_or_assigns,
        session_name,
        module,
        feature,
        mode,
        state,
        user_perms,
        opts
      ) do
    opts =
      MscmpSystUtils.resolve_options(opts,
        module: module,
        original_data: struct(module),
        current_data: struct(module) |> Map.from_struct(),
        display_data: :save,
        overrides: []
      )

    form_data = resolve_display_data(opts[:display_data], user_perms, opts)

    component_configs = get_render_configs(module, feature, mode, state, user_perms)

    base_render_config = %{
      msrd_instance_id: MscmpSystUtils.get_random_string(16, :mixed_alphanum),
      msrd_session_name: session_name,
      msrd_form_module: module,
      msrd_original_data: opts[:original_data],
      msrd_current_data: opts[:current_data],
      msrd_display_data: form_data,
      msrd_feature: feature,
      msrd_mode: mode,
      msrd_state: state,
      msrd_overrides: opts[:overrides],
      msrd_user_perms: user_perms
    }

    socket_or_assigns
    |> assign(component_configs)
    |> assign(base_render_config)
  end

  @spec rebuild_component_assigns(Types.socket_or_assigns()) :: Types.socket_or_assigns()
  def rebuild_component_assigns(socket_or_assigns) do
    working_assigns = get_working_assigns(socket_or_assigns)

    updated_render_configs =
      get_render_configs(
        working_assigns.msrd_form_module,
        working_assigns.msrd_feature,
        working_assigns.msrd_mode,
        working_assigns.msrd_state,
        working_assigns.msrd_user_perms
      )

    assign(socket_or_assigns, updated_render_configs)
  end

  @spec get_render_configs(
          module(),
          Types.form_state_feature_name(),
          Types.form_state_mode_name(),
          Types.form_state_state_name(),
          MscmpSystPerms.Types.perm_grants()
        ) :: Types.render_configs()
  def get_render_configs(module, feature, mode, state, user_perms) do
    form_configs = module.get_form_config()
    form_modes = module.get_form_modes()

    state_modes =
      Map.merge(
        form_modes.default.default || %{},
        form_modes[feature][mode][state]
      )

    component_processing_overrides = form_modes[feature][:processing_overrides] || %{}

    process_form_configs(
      form_configs,
      state_modes,
      component_processing_overrides,
      user_perms,
      @default_perm,
      @default_modes
    )
  end

  defp process_form_configs(
         [_ | _] = configs,
         modes,
         overrides,
         user_perms,
         default_perm,
         default_modes
       ) do
    Enum.reduce(configs, %{}, fn config, render_items ->
      process_form_configs(
        config,
        render_items,
        modes,
        overrides,
        user_perms,
        default_perm,
        default_modes
      )
    end)
  end

  defp process_form_configs(
         %FormConfig{form_id: nil, children: [_ | _]} = config,
         render_items,
         modes,
         overrides,
         user_perms,
         default_perm,
         default_modes
       ) do
    effective_perm = config.permission || default_perm
    effective_modes = Map.get(modes, config.form_id, default_modes)

    Enum.reduce(config.children, render_items, fn config, render_items ->
      process_form_configs(
        config,
        render_items,
        modes,
        overrides,
        user_perms,
        effective_perm,
        effective_modes
      )
    end)
  end

  # TODO: This function head being called might be indicative of a poorly
  #       constructed form configuration entry; we should warn/log on this
  #       condition once we have our logging strategy figured out.
  defp process_form_configs(%FormConfig{form_id: nil}, render_items, _, _, _, _, _),
    do: render_items

  defp process_form_configs(
         %FormConfig{form_id: form_id} = config,
         render_items,
         modes,
         overrides,
         user_perms,
         default_perm,
         default_modes
       )
       when is_atom(form_id) do
    effective_perm = config.permission || default_perm
    effective_modes = Map.get(modes, config.form_id, default_modes)
    component_overrides = overrides[config.form_id] || []
    perm_grants = user_perms[effective_perm] || %{view_scope: :deny, maint_scope: :deny}

    render_modes = apply_permissions(effective_modes, perm_grants)

    # Get a starting render configuration for the current item.

    curr_render_config = %ComponentConfig{
      form_id: config.form_id,
      binding_id: config.binding_id,
      permission: effective_perm,
      label: config.label,
      label_link: config.label_link,
      info: config.info,
      button_state: config.button_state,
      overrides: component_overrides,
      modes: render_modes
    }

    updated_render_items =
      case render_items[config.form_id] do
        nil ->
          Map.put_new(render_items, config.form_id, curr_render_config)

        render_item ->
          raise MscmpSystError,
            code: :undefined_error,
            message: "Render item key already exists.",
            cause: %{params: %{form_id: config.form_id, config: config, render_item: render_item}}
      end

    Enum.reduce(config.children, updated_render_items, fn config, render_items ->
      process_form_configs(
        config,
        render_items,
        modes,
        overrides,
        user_perms,
        effective_perm,
        effective_modes
      )
    end)
  end

  defp apply_permissions(%{component_mode: comp_mode} = curr_modes, %{view_scope: :deny})
       when comp_mode in [:visible, :entry, :processing],
       do: Map.replace(curr_modes, :component_mode, :cleared)

  defp apply_permissions(%{component_mode: :entry} = curr_modes, %{maint_scope: :deny}),
    do: Map.replace(curr_modes, :component_mode, :visible)

  defp apply_permissions(curr_modes, _), do: curr_modes

  @spec update_display_data(
          Types.socket_or_assigns(),
          Ecto.Changeset.t() | Phoenix.HTML.Form.t(),
          Keyword.t()
        ) :: Types.socket_or_assigns()
  def update_display_data(socket_or_assigns, display_data, opts) do
    working_assigns = get_working_assigns(socket_or_assigns)

    updated_display_data =
      resolve_display_data(display_data, working_assigns.msrd_user_perms, opts)

    assign(socket_or_assigns, :msrd_display_data, updated_display_data)
  end

  @spec to_form(Ecto.Changeset.t(), MscmpSystPerms.Types.perm_grants(), Keyword.t()) ::
          Phoenix.HTML.Form.t()
  def to_form(changeset, user_perms, opts) do
    msform_module = changeset.data.__struct__
    data_perms = get_data_perms(msform_module)

    form_opts =
      Keyword.take(opts, [
        :component_id,
        :component_method,
        :component_multipart,
        :component_csrf_token,
        :component_errors
      ])
      |> Enum.reduce([], fn {k, v}, acc ->
        cond do
          v == nil -> acc
          k == :component_id -> Keyword.put(acc, :id, v)
          k == :component_method -> Keyword.put(acc, :method, v)
          k == :component_multipart -> Keyword.put(acc, :multipart, v)
          k == :component_csrf_token -> Keyword.put(acc, :csrf_token, v)
          k == :component_errors -> Keyword.put(acc, :errors, v)
        end
      end)

    filtered_data =
      changeset.data
      |> Map.from_struct()
      |> Enum.reduce(%{}, fn {k, v}, data ->
        data_permission = data_perms[k]
        user_perm_grants = user_perms[data_permission]
        apply_data_perm(data, k, v, user_perm_grants)
      end)

    filtered_changes =
      Enum.reduce(changeset.changes, %{}, fn {k, v}, acc ->
        data_permission = data_perms[k]
        user_perm_grants = user_perms[data_permission]
        apply_data_perm(acc, k, v, user_perm_grants)
      end)

    filtered_changeset =
      Map.merge(changeset, %{
        data: struct(msform_module, filtered_data),
        changes: filtered_changes
      })

    Phoenix.HTML.FormData.to_form(filtered_changeset, form_opts)
  end

  defp apply_data_perm(data, _, _, nil), do: data
  defp apply_data_perm(data, :__struct__, _, _), do: data
  defp apply_data_perm(data, key, value, %{view_scope: :all}), do: Map.put(data, key, value)
  defp apply_data_perm(data, key, _, _), do: Map.put(data, key, nil)

  defp get_data_perms(module), do: module.get_form_config() |> process_data_perms(@default_perm)

  defp process_data_perms([_ | _] = configs, default_perm) do
    Enum.reduce(configs, %{}, fn config, perm_items ->
      process_data_perms(config, perm_items, default_perm)
    end)
  end

  defp process_data_perms(
         %FormConfig{binding_id: nil, children: [_ | _]} = config,
         perm_items,
         default_perm
       ) do
    effective_perm = config.permission || default_perm

    Enum.reduce(config.children, perm_items, fn config, perm_items ->
      process_data_perms(config, perm_items, effective_perm)
    end)
  end

  defp process_data_perms(%FormConfig{binding_id: nil}, perm_items, _),
    do: perm_items

  defp process_data_perms(%FormConfig{} = config, perm_items, default_perm) do
    effective_perm = config.permission || default_perm

    updated_perm_items =
      case perm_items[config.binding_id] do
        nil ->
          Map.put_new(perm_items, config.binding_id, effective_perm)

        render_item ->
          raise MscmpSystError,
            code: :undefined_error,
            message: "Render item key already exists.",
            cause: %{params: %{form_id: config.form_id, config: config, render_item: render_item}}
      end

    Enum.reduce(config.children, updated_perm_items, fn config, perm_items ->
      process_data_perms(config, perm_items, effective_perm)
    end)
  end

  defp resolve_display_data(validator, user_perms, opts)
       when validator in [:save, :post] do
    opts =
      MscmpSystUtils.resolve_options(opts,
        original_data: nil,
        current_data: nil,
        module: nil
      )

    cond do
      opts[:module] == nil ->
        raise MscmpSystError,
          code: :undefined_error,
          message: "You must provide the module option when display data must be validated.",
          cause: %{parameters: %{validator: validator, user_perms: user_perms, opts: opts}}

      opts[:original_data] == nil ->
        raise MscmpSystError,
          code: :undefined_error,
          message:
            "You must provide the original_data option when display data must be validated.",
          cause: %{parameters: %{validator: validator, user_perms: user_perms, opts: opts}}

      opts[:current_data] == nil ->
        raise MscmpSystError,
          code: :undefined_error,
          message:
            "You must provide the current_data option when display data must be validated.",
          cause: %{parameters: %{validator: validator, user_perms: user_perms, opts: opts}}

      true ->
        nil
    end

    selected_validator =
      case validator do
        :save -> :validate_save
        :post -> :validate_post
      end

    changeset =
      apply(opts[:module], selected_validator, [opts[:original_data], opts[:current_data]])
      |> Map.put(:action, opts[:changeset_action])

    resolve_display_data(changeset, user_perms, opts)
  end

  defp resolve_display_data(%Ecto.Changeset{} = changeset, user_perms, opts) do
    opts = MscmpSystUtils.resolve_options(opts, changeset_action: :validate)

    changeset
    |> Map.put(:action, opts[:changeset_action])
    |> to_form(user_perms, opts)
  end

  defp resolve_display_data(%Phoenix.HTML.Form{} = display_data, _, _), do: display_data

  @spec update_button_state(
          Types.socket_or_assigns(),
          Types.form_id(),
          Types.msvalidated_button_states()
        ) :: Types.socket_or_assigns()
  def update_button_state(socket_or_assigns, form_id, button_state)
      when is_atom(form_id) and button_state in [:action, :processing, :message] do
    socket_or_assigns
    |> case do
      %Phoenix.LiveView.Socket{assigns: assigns} -> assigns[form_id]
      %{} = assigns -> assigns[form_id]
    end
    |> Map.put(:button_state, button_state)
    |> then(&assign(socket_or_assigns, form_id, &1))
  end

  @spec start_processing_override(Types.socket_or_assigns(), Types.processing_override_name()) ::
          Types.socket_or_assigns()
  def start_processing_override(socket_or_assigns, override) when is_atom(override) do
    working_assigns = get_working_assigns(socket_or_assigns)

    if Enum.member?(working_assigns.msrd_overrides, override) do
      socket_or_assigns
    else
      updated_processing = [override | working_assigns.msrd_overrides]
      assign(socket_or_assigns, :msrd_overrides, updated_processing)
    end
  end

  @spec finish_processing_override(Types.socket_or_assigns(), Types.processing_override_name()) ::
          Types.socket_or_assigns()
  def finish_processing_override(socket_or_assigns, override) when is_atom(override) do
    working_assigns = get_working_assigns(socket_or_assigns)

    if Enum.member?(working_assigns.msrd_overrides, override) do
      updated_processing = Enum.reject(working_assigns.msrd_overrides, &(&1 == override))
      assign(socket_or_assigns, :msrd_overrides, updated_processing)
    else
      socket_or_assigns
    end
  end

  @spec get_component_info(module(), Types.form_id() | Types.binding_id()) ::
          Types.component_info() | nil
  def get_component_info(module, component_id),
    do: module.get_form_config() |> find_component_config(component_id)

  defp find_component_config([_ | _] = form_configs, component_id) do
    Enum.reduce_while(
      form_configs,
      nil,
      fn config, default ->
        case find_component_config(config, component_id) do
          %{} = component_config -> {:halt, component_config}
          nil -> {:cont, default}
        end
      end
    )
  end

  defp find_component_config(
         %{form_id: candidate_form_id} = form_config,
         %{form_id: form_id}
       )
       when candidate_form_id == form_id do
    %{
      label: form_config.label,
      label_link: form_config.label_link,
      info: form_config.info
    }
  end

  defp find_component_config(
         %{binding_id: candidate_binding_id} = form_config,
         %{binding_id: binding_id}
       )
       when candidate_binding_id == binding_id do
    %{
      label: form_config.label,
      label_link: form_config.label_link,
      info: form_config.info
    }
  end

  defp find_component_config(%{children: [_ | _] = children}, component_id),
    do: find_component_config(children, component_id)

  defp find_component_config(_, _), do: nil

  @spec set_form_state(Types.socket_or_assigns(), Types.form_state_state_name()) ::
          Types.socket_or_assigns()
  def set_form_state(socket_or_assigns, state) do
    wa = get_working_assigns(socket_or_assigns)
    set_form_state(socket_or_assigns, wa.msrd_feature, wa.msrd_mode, state)
  end

  @spec set_form_state(
          Types.socket_or_assigns(),
          Types.form_state_mode_name(),
          Types.form_state_state_name()
        ) ::
          Types.socket_or_assigns()
  def set_form_state(socket_or_assigns, mode, state) do
    wa = get_working_assigns(socket_or_assigns)
    set_form_state(socket_or_assigns, wa.msrd_feature, mode, state)
  end

  @spec set_form_state(
          Types.socket_or_assigns(),
          Types.form_state_feature_name(),
          Types.form_state_mode_name(),
          Types.form_state_state_name()
        ) ::
          Types.socket_or_assigns()
  def set_form_state(socket_or_assigns, feature, mode, state),
    do: assign(socket_or_assigns, %{msrd_feature: feature, msrd_mode: mode, msrd_state: state})

  defp get_working_assigns(%Phoenix.LiveView.Socket{assigns: assigns}), do: assigns
  defp get_working_assigns(%{msrd_instance_id: id} = assigns) when is_binary(id), do: assigns
end
