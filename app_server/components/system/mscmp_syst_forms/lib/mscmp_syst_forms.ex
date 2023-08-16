defmodule MscmpSystForms do
  alias MscmpSystForms.Impl
  alias MscmpSystForms.Types

  @external_resource "README.md"

  @moduledoc File.read!(Path.join([__DIR__, "..", "README.md"]))

  ##############################################################################
  #
  #  Forms Behaviour (for Msforms)
  #
  ##############################################################################

  # Form Definition

  @callback get_form_config() :: list(Types.FormConfig.t())

  @callback get_form_modes() :: map()

  # Form life-cycle management API

  @callback preconnect_init(
              socket_or_assigns ::
                Phoenix.LiveView.Socket.t() | Phoenix.LiveView.Socket.assigns(),
              session_name :: binary(),
              feature :: atom(),
              mode :: atom(),
              state :: atom(),
              opts :: Keyword.t() | [] | nil
            ) :: Phoenix.LiveView.Socket.t() | Phoenix.LiveView.Socket.assigns()

  @callback postconnect_init(
              socket_or_assigns :: Phoenix.LiveView.Socket.t() | Phoenix.LiveView.Socket.assigns()
            ) :: Phoenix.LiveView.Socket.t() | Phoenix.LiveView.Socket.assigns()

  # Form data management API
  @callback validate_save(term(), map()) :: Ecto.Changeset.t()

  @callback validate_post(term(), map()) :: Ecto.Changeset.t()

  # Form session management API

  # Form definition parsing/checking API

  ##############################################################################
  #
  #  Behaviour Dependent API
  #
  ##############################################################################

  defdelegate init_assigns(
                socket_or_assigns,
                session_name,
                module,
                feature,
                mode,
                state,
                user_perms,
                opts \\ []
              ),
              to: Impl.Forms

  defdelegate rebuild_component_assigns(socket_or_assigns), to: Impl.Forms

  defdelegate get_render_configs(module, feature, mode, state, perms), to: Impl.Forms

  defdelegate get_component_info(module, form_id), to: Impl.Forms

  defdelegate to_form(changeset, perms, opts \\ []), to: Impl.Forms

  defdelegate update_button_state(socket_or_assigns, form_id, button_state), to: Impl.Forms

  defdelegate start_processing_override(socket_or_assigns, override), to: Impl.Forms

  defdelegate finish_processing_override(socket_or_assigns, override), to: Impl.Forms

  defdelegate update_display_data(socket_or_assigns, display_data, opts \\ []), to: Impl.Forms

  defdelegate set_form_state(socket_or_assigns, state), to: Impl.Forms
  defdelegate set_form_state(socket_or_assigns, mode, state), to: Impl.Forms
  defdelegate set_form_state(socket_or_assigns, feature, mode, state), to: Impl.Forms

  ##############################################################################
  #
  #  Msform Extensions
  #
  ##############################################################################

  defmacro __using__(_) do
    quote do
      @behaviour MscmpSystForms

      defdelegate update_button_state(socket_or_assigns, form_id, button_state),
        to: MscmpSystForms

      defdelegate start_processing_override(socket_or_assigns, override), to: MscmpSystForms

      defdelegate finish_processing_override(socket_or_assigns, override), to: MscmpSystForms

      defdelegate update_display_data(socket_or_assigns, display_data, opts \\ []),
        to: MscmpSystForms

      def get_component_info(form_id), do: MscmpSystForms.get_component_info(__MODULE__, form_id)
    end
  end
end
