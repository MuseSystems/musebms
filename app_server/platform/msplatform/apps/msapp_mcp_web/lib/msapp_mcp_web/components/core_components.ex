# Source File: core_components.ex
# Location:    musebms/app_server/platform/msplatform/apps/msapp_mcp_web/lib/msapp_mcp_web/components/core_components.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MsappMcpWeb.CoreComponents do
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  import MsappMcpWeb.Gettext

  ################################################################################################
  ##
  ## Muse Systems Core Components
  ##
  ################################################################################################

  #
  # The Muse Systems Core Components here are, perhaps, a bit more than inspired
  # by the stock Phoenix CoreComponents which are created at Phoenix project
  # generation time.  The process has been to take those stock components and
  # then modify or remix them as desired.
  #
  # It's worth noting that, as-is, none of these should be considered final in
  # any sense.  So far, they've just been my learning playground and so are
  # badly organized and thought out.  We'll save a better implementation for
  # the inevitable MscmpSystForms component which will be our more formal set of
  # form building tools.
  #

  attr(:id, :any)
  attr(:name, :any)
  attr(:label, :string, default: nil)

  attr(:type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file hidden month number password
               range radio search select tel text textarea time url week)
  )

  attr(:value, :any)
  attr(:field, :any, doc: "a %Phoenix.HTML.Form{}/field name tuple, for example: {f, :email}")
  attr(:errors, :list)
  attr(:checked, :boolean, doc: "the checked flag for checkbox inputs")
  attr(:prompt, :string, default: nil, doc: "the prompt for select inputs")
  attr(:options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2")
  attr(:multiple, :boolean, default: false, doc: "the multiple flag for select inputs")
  attr(:rest, :global, include: ~w(autocomplete cols disabled form max maxlength min minlength
                                   pattern placeholder readonly required rows size step))

  def msinput(%{field: {f, field}} = assigns) do
    assigns
    |> assign(field: nil)
    |> assign_new(:name, fn ->
      name = Phoenix.HTML.Form.input_name(f, field)
      if assigns.multiple, do: name <> "[]", else: name
    end)
    |> assign_new(:id, fn -> Phoenix.HTML.Form.input_id(f, field) end)
    |> assign_new(:value, fn -> Phoenix.HTML.Form.input_value(f, field) end)
    |> assign_new(:errors, fn -> translate_errors(f.errors || [], field) end)
    |> msinput()
  end

  def msinput(%{type: "checkbox"} = assigns) do
    assigns = assign_new(assigns, :checked, fn -> input_equals?(assigns.value, "true") end)

    ~H"""
    <label phx-feedback-for={@name} class="flex items-center gap-4 text-sm leading-6 text-zinc-600">
      <input type="hidden" name={@name} value="false" />
      <input
        type="checkbox"
        id={@id || @name}
        name={@name}
        value="true"
        checked={@checked}
        class="rounded border-zinc-300 text-zinc-900 focus:ring-zinc-900"
        {@rest}
      />
      <%= @label %>
    </label>
    """
  end

  def msinput(%{type: "select"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label for={@id}><%= @label %></.label>
      <select
        id={@id}
        name={@name}
        class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-zinc-500 focus:border-zinc-500 sm:text-sm"
        multiple={@multiple}
        {@rest}
      >
        <option :if={@prompt} value=""><%= @prompt %></option>
        <%= Phoenix.HTML.Form.options_for_select(@options, @value) %>
      </select>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  def msinput(%{type: "textarea"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label for={@id}><%= @label %></.label>
      <textarea
        id={@id || @name}
        name={@name}
        class={[
          msinput_border(@errors),
          "mt-2 block min-h-[6rem] w-full rounded-lg border-zinc-300 py-[7px] px-[11px]",
          "text-zinc-900 focus:border-zinc-400 focus:outline-none focus:ring-4 focus:ring-zinc-800/5 sm:text-sm sm:leading-6",
          "phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400 phx-no-feedback:focus:ring-zinc-800/5"
        ]}
        {@rest}
      >
    <%= @value %></textarea>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  def msinput(assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <div class="flex space-x-1">
        <.label for={@id}><%= @label %></.label>
        <.msfield_errors :if={@errors != []} id={@id}>
          <:msfield_error_item :for={msg <- @errors}>
            <p><%= msg %></p>
          </:msfield_error_item>
        </.msfield_errors>
      </div>
      <input
        type={@type}
        name={@name}
        id={@id || @name}
        value={@value}
        class={[
          msinput_border(@errors),
          "mt-2 block w-full rounded-lg border-zinc-300 py-[7px] px-[11px]",
          "text-zinc-900 focus:outline-none focus:ring-4 sm:text-sm sm:leading-6",
          "phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400 phx-no-feedback:focus:ring-zinc-800/5"
        ]}
        {@rest}
      />
    </div>
    """
  end

  defp msinput_border([] = _errors),
    do: "border-zinc-300 focus:border-zinc-400 focus:ring-zinc-800/5"

  defp msinput_border([_ | _] = _errors),
    do: "border-rose-400 focus:border-rose-400 focus:ring-rose-400/10"

  attr(:title, :string, required: true)

  slot(:inner_block, required: true)

  def mssection(assigns) do
    ~H"""
    <div class="border-2 rounded-md border-gray-200 m-2">
      <div class="flex">
        <p class="grow-0 border-1 rounded border-gray-200 bg-gray-200 p-1 font-black text-black">
          <%= @title %>
        </p>
        <div class="grow" />
      </div>
      <div class="m-2">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  slot(:mswizard_progress, required: true)
  slot(:mswizard_steps, required: true)
  slot(:mswizard_step_comments, required: true)

  attr(:changeset, :map, required: true)

  def mswizard(assigns) do
    ~H"""
    <div class="flex-1 flex h-full">
      <div class="basis-1/4 mr-2 border-2 border-gray-300">
        <section id="wizard-progress" class="h-full mx-4 my-4">
          <p class="font-black underline text-center">Current Progress</p>
          <nav class="px-8">
            <ol class="list-decimal list-outside">
              <%= render_slot(@mswizard_progress) %>
            </ol>
          </nav>
        </section>
      </div>
      <div class="grow basis-3/4 flex flex-col">
        <section id="wizard-step-form" class="basis-3/4 mb-2 border-2 border-gray-300">
          <.form :let={f} for={@changeset} phx-change="validate" phx-submit="save">
            <%= render_slot(@mswizard_steps, f) %>
          </.form>
        </section>
        <section id="wizard-step-comment" class="basis-1/4 border-2 border-gray-300">
          <div class="p-4">
            <%= render_slot(@mswizard_step_comments) %>
          </div>
        </section>
      </div>
    </div>
    """
  end

  attr(:step, :atom, required: true)
  attr(:current_step, :atom, required: true)

  slot(:inner_block, required: true)

  def mswizard_step_item(assigns) do
    ~H"""
    <li class={if @current_step == @step, do: "font-black py-4", else: "font-normal py-4"}>
      <%= render_slot(@inner_block) %>
    </li>
    """
  end

  attr(:step, :atom, required: true)
  attr(:current_step, :atom, required: true)
  attr(:rest, :global)

  slot(:inner_block, required: true)

  def mswizard_step(assigns) do
    ~H"""
    <div class={unless @current_step == @step, do: "hidden", else: ""}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr(:step, :atom, required: true)
  attr(:current_step, :atom, required: true)

  slot(:inner_block, required: false)

  def mswizard_comment(assigns) do
    ~H"""
    <div class={unless @current_step == @step, do: "hidden"}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr(:id, :any, required: true)

  slot(:msinfo_help)

  def msinfo_widget(assigns) do
    ~H"""
    <div id={@id} class="flex justify-end space-x-2">
      <.modal id={"#{@id}-msinfo"}>
        <:title>Quick Reference</:title>
        <br />
        <%= render_slot(@msinfo_help) %>
      </.modal>
      <button
        type="button"
        phx-click={show_modal("#{@id}-msinfo")}
        disabled={@msinfo_help == []}
        aria-disabled={
          case @msinfo_help do
            [] -> "true"
            _ -> "false"
          end
        }
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 24 24"
          class={msinfo_button_style(:info, @msinfo_help)}
          aria-hidden="true"
          aria-labelledby="title"
          role="graphics-symbol"
        >
          <title><%= gettext("Quick Reference") %></title>
          <desc><%= gettext("A blue circle encompassing a question mark.") %></desc>
          <path
            fill-rule="evenodd"
            d="M2.25 12c0-5.385 4.365-9.75 9.75-9.75s9.75 4.365 9.75 9.75-4.365 9.75-9.75 9.75S2.25 17.385 2.25 12zm11.378-3.917c-.89-.777-2.366-.777-3.255 0a.75.75 0 01-.988-1.129c1.454-1.272 3.776-1.272 5.23 0 1.513 1.324 1.513 3.518 0 4.842a3.75 3.75 0 01-.837.552c-.676.328-1.028.774-1.028 1.152v.75a.75.75 0 01-1.5 0v-.75c0-1.279 1.06-2.107 1.875-2.502.182-.088.351-.199.503-.331.83-.727.83-1.857 0-2.584zM12 18a.75.75 0 100-1.5.75.75 0 000 1.5z"
            clip-rule="evenodd"
          />
        </svg>
      </button>
      <div />
    </div>
    """
  end

  defp msinfo_button_style(_, []), do: "w-8 h-8 fill-gray-300"
  defp msinfo_button_style(:info, [_ | _]), do: "w-8 h-8 fill-blue-600 hover:fill-blue-400"

  attr(:id, :any, required: true)

  slot(:msfield_error_item)

  def msfield_errors(assigns) do
    ~H"""
    <%= if display_field_errors(@msfield_error_item) do %>
      <button type="button" phx-click={show_modal("#{@id}-msfielderror")}>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 20 20"
          fill="currentColor"
          class="w-5 h-5 fill-red-600 hover:fill-red-400"
          aria-hidden="true"
          aria-labelledby="title"
          role="graphics-symbol"
        >
          <title><%= gettext("Validation Errors") %></title>
          <desc><%= gettext("A red circle encompassing an exclamation point.") %></desc>
          <path
            fill-rule="evenodd"
            d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-8-5a.75.75 0 01.75.75v4.5a.75.75 0 01-1.5 0v-4.5A.75.75 0 0110 5zm0 10a1 1 0 100-2 1 1 0 000 2z"
            clip-rule="evenodd"
          />
        </svg>
      </button>
      <.modal id={"#{@id}-msfielderror"}>
        <:title>Field Invalid</:title>
        <div class="flex flex-col space-y-2">
          <%= render_slot(@msfield_error_item) %>
        </div>
      </.modal>
    <% end %>
    """
  end

  defp display_field_errors([_ | _]), do: true
  defp display_field_errors(_), do: false

  attr(:id, :string, required: true)
  attr(:type, :string, default: "button")
  attr(:state, :atom, values: ~w(action processing message)a)
  attr(:class, :string, default: nil)
  attr(:rest, :global, include: ~w(disabled form name value))

  slot(:inner_block, required: true)

  slot :action do
    attr(:click_action, :string)
    attr(:show_icon, :boolean)
  end

  slot :processing do
    attr(:show_icon, :boolean)
  end

  slot :message do
    attr(:show_icon, :boolean)
    attr(:message_title, :string)
    attr(:message_items, :list)
    attr(:message_text, :string)
    attr(:line_title_label, :string)
    attr(:line_item_label, :string)
  end

  # TODO: The msbutton can probably be condensed/cleaned up a fair amount.  For now
  #       this is is working, so lets leave this big case statement for now.

  def msbutton(%{state: :message} = assigns) do
    first_message = List.first(assigns.message)

    assigns =
      assigns
      |> assign(first_message: first_message)
      |> assign_new(:show_icon, fn -> Map.get(first_message, :show_icon, false) end)
      |> assign_new(:message_title, fn -> Map.get(first_message, :message_title, "Error") end)
      |> assign_new(:message_items, fn -> Map.get(first_message, :message_items, nil) end)
      |> assign_new(:message_text, fn -> Map.get(first_message, :message_text, nil) end)
      |> assign_new(:line_title_label, fn -> Map.get(first_message, :line_title_label, nil) end)
      |> assign_new(:line_item_label, fn -> Map.get(first_message, :line_item_label, nil) end)

    ~H"""
    <button
      id={"#{@id}-msbutton-message"}
      type="button"
      class={[
        "phx-submit-loading:opacity-75 rounded-lg border-2 border-zinc-900 bg-zinc-500 hover:bg-zinc-400 py-2 px-3",
        "focus:ring-4 focus:ring-zinc-800",
        "text-sm font-semibold leading-6 text-white active:text-white/80",
        @class
      ]}
      phx-click={show_modal("#{@id}-msbutton-message-modal")}
    >
      <div class="flex space-x-2">
        <div><%= render_slot([@first_message]) %></div>
        <svg
          :if={@show_icon}
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 20 20"
          class="w-5 h-5 fill-red-600 stroke-white"
        >
          <path
            fill-rule="evenodd"
            d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-8-5a.75.75 0 01.75.75v4.5a.75.75 0 01-1.5 0v-4.5A.75.75 0 0110 5zm0 10a1 1 0 100-2 1 1 0 000 2z"
            clip-rule="evenodd"
          />
        </svg>
      </div>
    </button>
    <.modal id={"#{@id}-msbutton-message-modal"}>
      <:title><%= @message_title %></:title>
      <p :if={@message_text} class="mt-4"><%= @message_text %></p>
      <div :if={@message_items} class="m-4">
        <.mslist header_title={@line_title_label} header_item={@line_item_label}>
          <:item :for={item <- condense_message_items(@message_items)} title={item.label}>
            <p><%= Phoenix.HTML.raw(item.message_text) %></p>
          </:item>
        </.mslist>
      </div>
    </.modal>
    """
  end

  def msbutton(%{state: :action} = assigns) do
    first_action = List.first(assigns.action)

    assigns =
      assigns
      |> assign(first_action: first_action)
      |> assign_new(:click_action, fn -> Map.get(first_action, :click_action, nil) end)
      |> assign_new(:show_icon, fn -> Map.get(first_action, :show_icon, false) end)

    ~H"""
    <button
      id={"#{@id}-msbutton-action"}
      type={@type}
      class={[
        "phx-submit-loading:opacity-75 rounded-lg border-2 border-zinc-900 bg-zinc-500 hover:bg-zinc-400 py-2 px-3",
        "focus:ring-4 focus:ring-zinc-800",
        "text-sm font-semibold leading-6 text-white active:text-white/80",
        @class
      ]}
      phx-click={@click_action}
    >
      <div class="flex space-x-2">
        <div><%= render_slot([@first_action]) %></div>
        <svg
          :if={@show_icon}
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 20 20"
          class="w-5 h-5 fill-green-600 stroke-white"
        >
          <path
            fill-rule="evenodd"
            d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.857-9.809a.75.75 0 00-1.214-.882l-3.483 4.79-1.88-1.88a.75.75 0 10-1.06 1.061l2.5 2.5a.75.75 0 001.137-.089l4-5.5z"
            clip-rule="evenodd"
          />
        </svg>
      </div>
    </button>
    """
  end

  def msbutton(%{state: :processing} = assigns) do
    first_processing = List.first(assigns.processing)

    assigns =
      assigns
      |> assign(first_processing: first_processing)
      |> assign_new(:show_icon, fn -> Map.get(first_processing, :show_icon, false) end)

    ~H"""
    <button
      id={"#{@id}-msbutton-processing"}
      type="button"
      class={[
        "phx-submit-loading:opacity-75 rounded-lg border-2 border-zinc-900 bg-zinc-500 hover:bg-zinc-400 py-2 px-3",
        "focus:ring-4 focus:ring-zinc-800",
        "text-sm font-semibold leading-6 text-white active:text-white/80",
        "disabled",
        @class
      ]}
    >
      <div class="flex space-x-2">
        <div><%= render_slot([@first_processing]) %></div>
        <svg
          :if={@show_icon}
          class="animate-spin -ml-1 mr-3 h-5 w-5 text-white "
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
        >
          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4">
          </circle>
          <path
            class="opacity-75"
            fill="currentColor"
            d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
          >
          </path>
        </svg>
      </div>
    </button>
    """
  end

  def msbutton(assigns) do
    ~H"""
    <button
      id={@id}
      type={@type}
      class={[
        "phx-submit-loading:opacity-75 rounded-lg border-2 border-zinc-900 bg-zinc-500 hover:bg-zinc-400 py-2 px-3",
        "focus:ring-4 focus:ring-zinc-800",
        "text-sm font-semibold leading-6 text-white active:text-white/80",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  defp condense_message_items([{_, _} | _] = message_items) do
    form_data = MsdataApi.McpBootstrap.get_data_definition()

    message_items
    |> Keyword.keys()
    |> Enum.uniq()
    |> Enum.reduce([], fn key, acc ->
      message_item_text =
        Keyword.get_values(message_items, key)
        |> Enum.map(&translate_error(&1))
        |> Enum.join("<br/>")

      [%{label: form_data[key][:label], message_text: message_item_text} | acc]
    end)
  end

  defp condense_message_items(message_items), do: message_items

  attr(:header_title, :string, default: nil)
  attr(:header_item, :string, default: nil)

  slot :item, required: true do
    attr(:title, :string, required: true)
  end

  def mslist(assigns) do
    ~H"""
    <div class="mt-14">
      <dl class="-my-4 divide-y divide-zinc-100">
        <div class="flex gap-4 py-4 sm:gap-8">
          <dt class="w-1/4 flex-none font-black text-[0.8125rem] leading-6 text-zinc-800">
            <%= @header_title %>
          </dt>
          <dd class="font-black text-sm leading-6 text-zinc-800"><%= @header_item %></dd>
        </div>
        <div :for={item <- @item} class="flex gap-4 py-4 sm:gap-8">
          <dt class="w-1/4 flex-none text-[0.8125rem] leading-6 text-zinc-500"><%= item.title %></dt>
          <dd class="text-sm leading-6 text-zinc-700"><%= render_slot(item) %></dd>
        </div>
      </dl>
    </div>
    """
  end

  ################################################################################################
  ##
  ## Stock Phoenix Core Components
  ##
  ################################################################################################

  @doc """
  Renders a modal.

  ## Examples

      <.modal id="confirm-modal">
        Are you sure?
        <:confirm>OK</:confirm>
        <:cancel>Cancel</:cancel>
      </.modal>

  JS commands may be passed to the `:on_cancel` and `on_confirm` attributes
  for the caller to react to each button press, for example:

      <.modal id="confirm" on_confirm={JS.push("delete")} on_cancel={JS.navigate(~p"/posts")}>
        Are you sure you?
        <:confirm>OK</:confirm>
        <:cancel>Cancel</:cancel>
      </.modal>
  """
  attr(:id, :string, required: true)
  attr(:show, :boolean, default: false)
  attr(:on_cancel, JS, default: %JS{})
  attr(:on_confirm, JS, default: %JS{})

  slot(:inner_block, required: true)
  slot(:title)
  slot(:subtitle)
  slot(:confirm)
  slot(:cancel)

  def modal(assigns) do
    ~H"""
    <div
      id={@id}
      phx-mounted={@show && show_modal(@id)}
      phx-remove={hide_modal(@id)}
      class="relative z-50 hidden"
    >
      <div id={"#{@id}-bg"} class="fixed inset-0 bg-zinc-50/90 transition-opacity" aria-hidden="true" />
      <div
        class="fixed inset-0 overflow-y-auto"
        aria-labelledby={"#{@id}-title"}
        aria-describedby={"#{@id}-description"}
        role="dialog"
        aria-modal="true"
        tabindex="0"
      >
        <div class="flex min-h-full items-center justify-center">
          <div class="w-full max-w-3xl p-4 sm:p-6 lg:py-8">
            <.focus_wrap
              id={"#{@id}-container"}
              phx-mounted={@show && show_modal(@id)}
              phx-window-keydown={hide_modal(@on_cancel, @id)}
              phx-key="escape"
              phx-click-away={hide_modal(@on_cancel, @id)}
              class="hidden relative rounded-2xl bg-white p-4 shadow-lg shadow-zinc-700/10 ring-1 ring-zinc-700/10 transition"
            >
              <div class="absolute top-6 right-5">
                <button
                  phx-click={hide_modal(@on_cancel, @id)}
                  type="button"
                  class="-m-3 flex-none p-3 opacity-20 hover:opacity-40"
                  aria-label={gettext("close")}
                >
                  <Heroicons.x_mark solid class="h-5 w-5 stroke-current" />
                </button>
              </div>
              <div id={"#{@id}-content"}>
                <header :if={@title != []}>
                  <h1 id={"#{@id}-title"} class="text-lg font-semibold leading-8 text-zinc-800">
                    <%= render_slot(@title) %>
                  </h1>
                  <p
                    :if={@subtitle != []}
                    id={"#{@id}-description"}
                    class="mt-2 text-sm leading-6 text-zinc-600"
                  >
                    <%= render_slot(@subtitle) %>
                  </p>
                </header>
                <%= render_slot(@inner_block) %>
                <div :if={@confirm != [] or @cancel != []} class="ml-6 mb-4 flex items-center gap-5">
                  <.button
                    :for={confirm <- @confirm}
                    id={"#{@id}-confirm"}
                    phx-click={@on_confirm}
                    phx-disable-with
                    class="py-2 px-3"
                  >
                    <%= render_slot(confirm) %>
                  </.button>
                  <.link
                    :for={cancel <- @cancel}
                    phx-click={hide_modal(@on_cancel, @id)}
                    class="text-sm font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
                  >
                    <%= render_slot(cancel) %>
                  </.link>
                </div>
              </div>
            </.focus_wrap>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders flash notices.

  ## Examples

      <.flash kind={:info} flash={@flash} />
      <.flash kind={:info} phx-mounted={show("#flash")}>Welcome Back!</.flash>
  """
  attr(:id, :string, default: "flash", doc: "the optional id of flash container")
  attr(:flash, :map, default: %{}, doc: "the map of flash messages to display")
  attr(:title, :string, default: nil)
  attr(:kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup")
  attr(:autoshow, :boolean, default: true, doc: "whether to auto show the flash on mount")
  attr(:close, :boolean, default: true, doc: "whether the flash can be closed")
  attr(:rest, :global, doc: "the arbitrary HTML attributes to add to the flash container")

  slot(:inner_block, doc: "the optional inner block that renders the flash message")

  def flash(assigns) do
    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-mounted={@autoshow && show("##{@id}")}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
      role="alert"
      class={[
        "fixed hidden top-2 right-2 w-80 sm:w-96 z-50 rounded-lg p-3 shadow-md shadow-zinc-900/5 ring-1",
        @kind == :info && "bg-emerald-50 text-emerald-800 ring-emerald-500 fill-cyan-900",
        @kind == :error && "bg-rose-50 p-3 text-rose-900 shadow-md ring-rose-500 fill-rose-900"
      ]}
      {@rest}
    >
      <p :if={@title} class="flex items-center gap-1.5 text-[0.8125rem] font-semibold leading-6">
        <Heroicons.information_circle :if={@kind == :info} mini class="h-4 w-4" />
        <Heroicons.exclamation_circle :if={@kind == :error} mini class="h-4 w-4" />
        <%= @title %>
      </p>
      <p class="mt-2 text-[0.8125rem] leading-5"><%= msg %></p>
      <button
        :if={@close}
        type="button"
        class="group absolute top-2 right-1 p-2"
        aria-label={gettext("close")}
      >
        <Heroicons.x_mark solid class="h-5 w-5 stroke-current opacity-40 group-hover:opacity-70" />
      </button>
    </div>
    """
  end

  @doc """
  Renders a simple form.

  ## Examples

      <.simple_form :let={f} for={:user} phx-change="validate" phx-submit="save">
        <.input field={{f, :email}} label="Email"/>
        <.input field={{f, :username}} label="Username" />
        <:actions>
          <.button>Save</.button>
        </:actions>
      </.simple_form>
  """
  attr(:for, :any, default: nil, doc: "the datastructure for the form")
  attr(:as, :any, default: nil, doc: "the server side parameter to collect all input under")

  attr(:rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target),
    doc: "the arbitrary HTML attributes to apply to the form tag"
  )

  slot(:inner_block, required: true)
  slot(:actions, doc: "the slot for form actions, such as a submit button")

  def simple_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} as={@as} {@rest}>
      <div class="space-y-8 bg-white mt-10">
        <%= render_slot(@inner_block, f) %>
        <div :for={action <- @actions} class="mt-2 flex items-center justify-between gap-6">
          <%= render_slot(action, f) %>
        </div>
      </div>
    </.form>
    """
  end

  @doc """
  Renders a button.

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go" class="ml-2">Send!</.button>
  """
  attr(:type, :string, default: nil)
  attr(:class, :string, default: nil)
  attr(:rest, :global, include: ~w(disabled form name value))

  slot(:inner_block, required: true)

  def button(assigns) do
    ~H"""
    <button
      type={@type}
      class={[
        "phx-submit-loading:opacity-75 rounded-lg bg-zinc-900 hover:bg-zinc-700 py-2 px-3",
        "text-sm font-semibold leading-6 text-white active:text-white/80",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  @doc """
  Renders a label.
  """
  attr(:for, :string, default: nil)
  slot(:inner_block, required: true)

  def label(assigns) do
    ~H"""
    <label for={@for} class="block text-sm font-semibold leading-6 text-zinc-800">
      <%= render_slot(@inner_block) %>
    </label>
    """
  end

  @doc """
  Renders a header with title.
  """
  attr(:class, :string, default: nil)

  slot(:inner_block, required: true)
  slot(:subtitle)
  slot(:actions)

  def header(assigns) do
    ~H"""
    <header class={[@actions != [] && "flex items-center justify-between gap-6", @class]}>
      <div>
        <h1 class="text-lg font-semibold leading-8 text-zinc-800">
          <%= render_slot(@inner_block) %>
        </h1>
        <p :if={@subtitle != []} class="mt-2 text-sm leading-6 text-zinc-600">
          <%= render_slot(@subtitle) %>
        </p>
      </div>
      <div class="flex-none"><%= render_slot(@actions) %></div>
    </header>
    """
  end

  @doc ~S"""
  Renders a table with generic styling.

  ## Examples

      <.table id="users" rows={@users}>
        <:col :let={user} label="id"><%= user.id %></:col>
        <:col :let={user} label="username"><%= user.username %></:col>
      </.table>
  """
  attr(:id, :string, required: true)
  attr(:row_click, :any, default: nil)
  attr(:rows, :list, required: true)

  slot :col, required: true do
    attr(:label, :string)
  end

  slot(:action, doc: "the slot for showing user actions in the last table column")

  def table(assigns) do
    ~H"""
    <div id={@id} class="overflow-y-auto px-4 sm:overflow-visible sm:px-0">
      <table class="mt-11 w-[40rem] sm:w-full">
        <thead class="text-left text-[0.8125rem] leading-6 text-zinc-500">
          <tr>
            <th :for={col <- @col} class="p-0 pb-4 pr-6 font-normal"><%= col[:label] %></th>
            <th class="relative p-0 pb-4"><span class="sr-only"><%= gettext("Actions") %></span></th>
          </tr>
        </thead>
        <tbody class="relative divide-y divide-zinc-100 border-t border-zinc-200 text-sm leading-6 text-zinc-700">
          <tr
            :for={row <- @rows}
            id={"#{@id}-#{Phoenix.Param.to_param(row)}"}
            class="relative group hover:bg-zinc-50"
          >
            <td
              :for={{col, i} <- Enum.with_index(@col)}
              phx-click={@row_click && @row_click.(row)}
              class={["p-0", @row_click && "hover:cursor-pointer"]}
            >
              <div :if={i == 0}>
                <span class="absolute h-full w-4 top-0 -left-4 group-hover:bg-zinc-50 sm:rounded-l-xl" />
                <span class="absolute h-full w-4 top-0 -right-4 group-hover:bg-zinc-50 sm:rounded-r-xl" />
              </div>
              <div class="block py-4 pr-6">
                <span class={["relative", i == 0 && "font-semibold text-zinc-900"]}>
                  <%= render_slot(col, row) %>
                </span>
              </div>
            </td>
            <td :if={@action != []} class="p-0 w-14">
              <div class="relative whitespace-nowrap py-4 text-right text-sm font-medium">
                <span
                  :for={action <- @action}
                  class="relative ml-4 font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
                >
                  <%= render_slot(action, row) %>
                </span>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  @doc """
  Renders a data list.

  ## Examples

      <.list>
        <:item title="Title"><%= @post.title %></:item>
        <:item title="Views"><%= @post.views %></:item>
      </.list>
  """
  slot :item, required: true do
    attr(:title, :string, required: true)
  end

  def list(assigns) do
    ~H"""
    <div class="mt-14">
      <dl class="-my-4 divide-y divide-zinc-100">
        <div :for={item <- @item} class="flex gap-4 py-4 sm:gap-8">
          <dt class="w-1/4 flex-none text-[0.8125rem] leading-6 text-zinc-500"><%= item.title %></dt>
          <dd class="text-sm leading-6 text-zinc-700"><%= render_slot(item) %></dd>
        </div>
      </dl>
    </div>
    """
  end

  @doc """
  Renders a back navigation link.

  ## Examples

      <.back navigate={~p"/posts"}>Back to posts</.back>
  """
  attr(:navigate, :any, required: true)
  slot(:inner_block, required: true)

  def back(assigns) do
    ~H"""
    <div class="mt-16">
      <.link
        navigate={@navigate}
        class="text-sm font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
      >
        <Heroicons.arrow_left solid class="w-3 h-3 stroke-current inline" />
        <%= render_slot(@inner_block) %>
      </.link>
    </div>
    """
  end

  @doc """
  Generates tag for inlined form input errors.
  """
  def error_tag(form, field) do
    error(%{
      errors: form.errors,
      field: field,
      input_name: Phoenix.HTML.Form.input_name(form, field)
    })
  end

  @doc """
  Generates a generic error message.
  """
  slot(:inner_block, required: true)

  def error(assigns) do
    ~H"""
    <p class="phx-no-feedback:hidden mt-3 flex gap-3 text-sm leading-6 text-rose-600">
      <Heroicons.exclamation_circle mini class="mt-0.5 h-5 w-5 flex-none fill-rose-500" />
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  @doc """
  Translates an error message using gettext.
  """
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

  def translate_changeset_errors(changeset) do
    changeset.errors
    |> Enum.map(fn {key, value} -> "#{key} #{translate_error(value)}" end)
    |> Enum.join("\n")
  end

  @doc """
  Translates the errors for a field from a keyword list of errors.
  """
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end

  defp input_equals?(val1, val2) do
    Phoenix.HTML.html_escape(val1) == Phoenix.HTML.html_escape(val2)
  end

  ## JS Commands

  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      transition:
        {"transition-all transform ease-out duration-300",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all transform ease-in duration-200",
         "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end

  def show_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.show(to: "##{id}")
    |> JS.show(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-out duration-300", "opacity-0", "opacity-100"}
    )
    |> show("##{id}-container")
    |> JS.add_class("overflow-hidden", to: "body")
    |> JS.focus_first(to: "##{id}-content")
  end

  def hide_modal(js \\ %JS{}, id) do
    js
    |> JS.hide(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-in duration-200", "opacity-100", "opacity-0"}
    )
    |> hide("##{id}-container")
    |> JS.hide(to: "##{id}", transition: {"block", "block", "hidden"})
    |> JS.remove_class("overflow-hidden", to: "body")
    |> JS.pop_focus()
  end
end
