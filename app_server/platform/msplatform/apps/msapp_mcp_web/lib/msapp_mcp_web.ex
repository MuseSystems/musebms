defmodule MsappMcpWeb do
  @external_resource "README.md"
  @moduledoc Path.join([__DIR__, "..", "README.md"])
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  def static_paths,
    do: ~w(assets fonts images documentation favicon.svg robots.txt)

  def router do
    quote do
      use Phoenix.Router, helpers: false

      # Import common connection and controller functions to use in pipelines
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def controller do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json],
        layouts: [html: MsappMcpWeb.Layouts]

      import Plug.Conn
      import MsappMcpWeb.Gettext

      unquote(verified_routes())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {MsappMcpWeb.Layouts, :app}

      unquote(html_helpers())
    end
  end

  def bootstrap_live_view do
    quote do
      use Phoenix.LiveView,
        layout: {MsappMcpWeb.Layouts, :bootstrap}

      unquote(html_helpers())
    end
  end

  def login_live_view do
    quote do
      use Phoenix.LiveView,
        layout: {MsappMcpWeb.Layouts, :login}

      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())
    end
  end

  def html do
    quote do
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # HTML escaping functionality
      import Phoenix.HTML

      # Core UI components and translation
      import MsappMcpWeb.CoreComponents
      import MscmpSystForms.WebComponents
      import MsappMcpWeb.Gettext

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS

      # Routes generation with the ~p sigil
      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: MsappMcpWeb.Endpoint,
        router: MsappMcpWeb.Router,
        statics: MsappMcpWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
