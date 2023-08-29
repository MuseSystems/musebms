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

  @doc """
  Returns a list of `t:MscmpSystForms.Types.FormConfig.t/0` structs which
  represent the abstract configuration of the form.

  This function is usually simply returns a hard-coded list of
  `t:MscmpSystForms.Types.FormConfig.t/0` values as defined
  by the form developer.  This function is called by various form rendering
  related functions to get the starting point for each component from which
  `t:MscmpSystForms.Types.ComponentConfig.t/0` values will be created by
  `MscmpSystForms.get_render_configs/5`.

  Note that not all elements in a user interface require representation in the
  form configuration returned by this function.  However, any element not
  included in the form configuration here will be excluded from responding to
  any changes in form state, processing overrides, or user permissions.

  The configurations returned by this function, and the parent/child
  relationships between individual `FormConfig` values, should be structured to
  facilitate the appropriate inheritance of properties from `FormConfig` parent
  to child; the goal being to reduce redundant establishment of those properties
  in the configuration.  This will often times result in the data returned by
  this function being hierarchical and resembling the layout structure of the
  rendered form even though there is no requirement that the structure of these
  configurations are related to the rendered layout in any way.

  ## Examples

  Consider the following example configuration:

  ```elixir
  def get_form_config do
    [
      %FormConfig{
        permission: :form_access_permission,
        label: "Virtual FormConfig",
        children: [
          %FormConfig{
            form_id: :concrete_config_input,
            binding_id: :data_field_input,
            label: "Example Input Field",
          },
          %FormConfig{
            form_id: :concrete_config_submit_button,
            label: "Submit",
            button_state: :message
          }
        ]
      }
    ]
  end
  ```
  At the top level we have a virtual or abstract `FormConfig` value; we know
  it's virtual because it defines no `form_id` value.  This top level value
  exists so that its children can inherit its permission value and its defined
  display modes (see `c:MscmpSystForms.get_form_modes/0`).

  This doesn't mean that the returned configuration represents all elements in
  the rendered form and the parent in this case, being virtual, doesn't
  correspond to any rendered form element at all (that would require a `form_id`
  value being defined).  The overall structure and the virtual element exist to
  purely support the inheritance of configuration and state related values.

  While with the structure in the example above, we can take advantage of
  inherited values, we can selectively override those values as needed.
  Consider this revision of the first example:

  ```elixir
  def get_form_config do
    [
      %FormConfig{
        permission: :form_access_permission,
        label: "Virtual FormConfig",
        children: [
          %FormConfig{
            form_id: :concrete_config_input,
            binding_id: :data_field_input,
            label: "Example Input Field",
          },
          %FormConfig{
            form_id: :concrete_config_submit_button,
            permission: :form_submit_permission,
            label: "Submit",
            button_state: :message
          }
        ]
      }
    ]
  end
  ```

  In the revised example, we don't inherit the the `:form_access_permission`
  value of the parent in `:concrete_config_submit_button` any longer, but now
  check the `:form_submit_permission` permission instead.  The
  `:concrete_config_submit_button` will continue to inherit other values from
  the parent that it has not explicitly overridden.
  """
  @callback get_form_config() :: list(Types.FormConfig.t())

  @doc """
  Returns a map of the recognized form states and the display modes each
  component should take when a given form state is specified.

  The map returned by this function has a basic hierarchical structure where the
  Form State `feature` is at the top level,  the Form State `mode` taking the
  next level, and the Form State `State` being nested under `mode`.  In this
  way each defined `feature` can have one or more `mode` entries and each `mode`
  entry can have one or more `state` entries.

  ```elixir
  %{
    <feature>: %{
      default: %{
        <component_form_id>: %{<default component modes>}
      },
      <mode>: %{
        <state>: %{
          <component_form_id>: %{<component modes>}
        }
      },
      processing_overrides: %{
        <component_form_id>: [<processing override name>]
      }
    }
  }
  ```

  ## Mode Structure Rules & Considerations

  ### Feature Level Map

  The Feature level of the map will accept one or more Feature entries where the
  key for each entry is the name
  (`t:MscmpSystForms.Types.form_state_feature_name/0`) by which the Feature is
  to be referenced elsewhere in the application code.  Most forms are likely to
  only support a single Feature; in this case simply name the Feature
  `:default` as this is the default feature name used when one isn't otherwise
  provided.

  The contents of each Feature's map consist of:

    * a single `:default` key with values establishing the default component
    modes to use when the other Form State modes fail to define a component mode
    for a given component.

    * a `:processing_overrides` key which define the processing overrides the
    various form components should respond to.

    * one or more "modes" where the key is the Mode name
    (`t:MscmpSystForms.Types.form_state_mode_name/0`) and the value is a map of
    Form State States which define the various states supported by that Mode.

  ### Mode Level Map

  The Mode level is expressed as a key/value map where the keys are Form State
  "State" names (`t:MscmpSystForms.Types.form_state_state_name/0`) and the
  values of those keys are the State level maps.  There are no additional
  entries or default values.

  ### State Level Map

  The State level is a simple key/value map where keys are Form State State
  Names (`t:MscmpSystForms.Types.form_state_state_name/0`) and the values are
  maps of component Form IDs (`t:MscmpSystForms.Types.form_id/0`) as keys along
  with their configured component modes
  (`t:MscmpSystForms.Types.component_display_modes/0`) for that given
  Feature/Mode/State combination.

  ## Examples

  Different form elements may take on different display properties as the state
  of the form evolves over time with changes in data or in response to user
  interactions.  This function returns a nested map structure which, based on
  the examples from `c:get_form_config/0`, might look like:

  ```elixir
  %{
    default: %{
      default: %{
        concrete_config_input: %{component_mode: :visible},
        concrete_config_submit_button: %{component_mode: :visible}
      },
      entry: %{
        basic_form_state: %{
          concrete_config_input: %{component_mode: :entry},
          concrete_config_submit_button: %{component_mode: :entry}
        }
      },
      view: %{
        basic_form_state: %{
          concrete_config_input: %{component_mode: :visible},
          concrete_config_submit_button: %{component_mode: :visible}
        }
      },
      processing_overrides: %{
        concrete_config_input: [:process_underway]
        concrete_config_submit_button: [:process_underway]
      }
    }
  }
  ```

  """
  @callback get_form_modes() :: map()

  # Form life-cycle management API

  @doc """
  An initialization sequence run during first, static mount process.

  This callback is intended to define a function called in the first, static
  `c:Phoenix.LiveView.mount/3`.  While `c:preconnect_init/6` can encapsulate any
  logic necessary during this phase of initialization, we would typically see
  the following activities handled:

     * The capture of socket values passed to `c:Phoenix.LiveView.mount/3`,
     such as `session_name` in preparation for calling `init_assigns/8`.

     * The resolution of user permissions required by the form.

     * The loading of backing data from the database for the view or maintenance
     of existing data, or defaulted data in the case of new record creation.

     * Initialization of the Standard Assign Attributes using `init_assigns/8`.

  Naturally, while these would be typical activities to perform in
  `c:preconnect_init/6`, they are not required not is this callback limited to
  running these functions.  Truly, whatever makes sense for the form to process
  during this stage of the form life-cycle is acceptable.

  ## Parameters

    * `socket_or_assigns` - the socket or assigns for the current view.

    * `session_name` - the name of the session.  This value is usually set in
    prior to the view being called and is part of the parameters passed to the
    view.  Ultimately this is the link between the users client and our richer
    sense of session available to the server side view logic.

    * `feature` - the currently prevailing form state feature.  Typically this
    value is passed to `init_assigns/8` for further processing.

    * `mode` - the currently prevailing form state mode.  Typically this value
    is passed to `init_assigns/8` for further processing.

    * `state` - the currently prevailing form state.  Typically this value is
    passed to `init_assigns/8` for further processing.

    * `opts` - the options which might be used here will depended on the how
    this callback is implemented for the form.  Since we often call
    `init_assigns/8` from `c:preconnect_init/6`, the options will simply be the
    same as those and just passed to `init_assigns/8`.
  """
  @callback preconnect_init(
              socket_or_assigns ::
                Phoenix.LiveView.Socket.t() | Phoenix.LiveView.Socket.assigns(),
              session_name :: binary(),
              feature :: atom(),
              mode :: atom(),
              state :: atom(),
              opts :: Keyword.t() | [] | nil
            ) :: Phoenix.LiveView.Socket.t() | Phoenix.LiveView.Socket.assigns()

  @doc """
  An initialization sequence run during the connected, second call to
  `c:Phoenix.LiveView.mount/3`.

  This function currently doesn't have any specific or well defined "typical use
  cases" as does `preconnect_init/6`.

  It is assumed that any required data or configurations were initially set
  using `preconnect_init/6` and are available in the socket assigns passed to
  `c:Phoenix.LiveView.mount/3`.

  ## Parameters

    * `socket_or_assigns` - the socket or assigns for the current view.
  """
  @callback postconnect_init(
              socket_or_assigns :: Phoenix.LiveView.Socket.t() | Phoenix.LiveView.Socket.assigns()
            ) :: Phoenix.LiveView.Socket.t() | Phoenix.LiveView.Socket.assigns()

  # Form data management API
  @doc """
  An `t:Ecto.Changeset.t/0` generating function which validates that a
  given set of data is sufficient for simply saving to the database.

  In many cases in business applications, it is possible to save "work in
  progress" to the database without needing to post a fully committed business
  transaction.  For example, a purchase order may be authored over the course of
  a few days before it is final and ready to send to the vendor; in this case
  we could validate just enough data to make the in-progress purchase order
  distinguishable from other similar orders while not requiring a fully
  executable order and thus allow the author to save their work to the database.
  Later, a transaction ready to be committed in the business sense ("posting")
  can call `c:validate_post/2` to validate that the transaction may be posted as
  a valid business transaction.

  Often times there is no distinction between the "savable" and "postable"
  state.  In these cases, it's best to write the main validate logic in the
  `c:validate_post/2` function and simply delegate this function to that one;
  raising an exception in this function is also an option to force the correct
  call.

  ## Parameters

    * `original_data` - a representation of the starting data using the
    `MscmpSystForms` implementing struct backing the form.  Setting this value
    correctly allows the Changeset to correctly identify changes to the data.

    * `current_data` - a map based representation of the current data which is
    to be validated during the creation of the Changeset.
  """
  @callback validate_save(original_data :: term(), current_data :: map()) :: Ecto.Changeset.t()

  @doc """
  An `t:Ecto.Changeset.t/0` generating function which validates that a
  given set of data is sufficient for posting as a fully fledged business
  transaction.

  This function serves to validate that a form's data fully meets the
  requirements of a complete business transaction.  In cases where
  less-than-ready works in progress should be saveable, the `c:validate_save/2`
  function should be called instead.

  ## Parameters

    * `original_data` - a representation of the starting data using the
    `MscmpSystForms` implementing struct backing the form.  Setting this value
    correctly allows the Changeset to correctly identify changes to the data.

    * `current_data` - a map based representation of the current data which is
    to be validated during the creation of the Changeset.
  """
  @callback validate_post(original_data :: term(), current_data :: map()) :: Ecto.Changeset.t()

  ##############################################################################
  #
  #  Behaviour Dependent API
  #
  ##############################################################################

  @doc section: :form_generation
  @doc """
  Initializes the `MscmpSystForms` standard assign attributes and readies the
  form for rendering.

  Typically this function is called in the implementation of the
  `c:MscmpSystForms.preconnect_init/6` of the form once the user, the user
  permissions, and any starting data for the form has been resolved.

  This function must be called prior to any attempted rendering of the form as
  many user interface components expect values in the Standard Assign Attributes
  to be available.

  In addition to adding the Standard Assign Attributes, this function will
  process the Form Configurations (`c:MscmpSystForms.get_form_config/0`) using
  the Form State parameters (`feature`, `mode`, and `state`) and the current
  user's permissions (`user_perms`)

  ## Standard Assign Attributes:

    * `msrd_instance_id` - the identifier for any single instance of a running
    form.  This supports the use case where a user logged into a single session
    may have multiple instances of the same form open accessing the same data,
    but desiring to also edit that data.  In this case we only allow a single
    instance of the form to be in an editable mode, blocking all other
    instances, including other instances in the same session, from editing the
    data.

    * `msrd_session_name` - the identifier for the user's authenticated session.
    This session name is a reference to the session record in the database which
    contains session oriented data and session management statistics such as
    expiration date/time.  It is by having a valid, authenticated session
    identified by this value that the system knows that the user is
    authenticated.

    * `msrd_form_module` - the `MscmpSystForms` behaviour implementing module
    which backs the form.

    * `msrd_original_data` - the data backing the form at the time the form was
    initialized.  This data does not change as user interacts with the form,
    including changing the form's data, allowing for comparisons, validations,
    and resets of changed data with the starting data.  The original data is a
    struct as defined by the `MscmpSystForms` backing module where the keys are
    the binding ID's of the form data fields.  Note that this data includes all
    form backing data without regard to the current user's data visibility
    permissions.

    * `msrd_current_data` - the data backing the form including any changes
    made by the user or by the system in response to various interactions with
    the form.  As the name suggests this is value represents the current state
    of the data and is the data that must pass any validation attempts and the
    data that will ultimately be saved to the database.  This value is
    represented as a simple map of key/value pairs where the keys are the
    binding ID's of the form data fields. Note that this data includes all form
    backing data without regard to the current user's data visibility
    permissions.

    * `msrd_display_data` - the data used to fill user interface form elements.
    This data is the same as the `msrd_current_data` except that values which
    are disallowed by the user data visibility permissions are excluded and the
    data is represented as a `t:Phoenix.HTML.Form.t/0` value.

    * `msrd_feature` - the currently prevailing form state feature.  The
    "feature" is the highest level determinant of form state, which determines
    how some form user interface components present themselves or allow for
    interactivity.  Typical examples of how the `msrd_feature` of a form might
    be used includes a single form supporting both sales quoting and sales
    ordering: while very similar there are differences in the functionality and
    elements required by these two activities and the `msrd_feature` would tell
    the form which mode was currently in use.  The value is an atom.  See
    `c:MscmpSystForms.get_form_modes/0` for more information

    * `msrd_mode` - the current mode of the form state.  This is typically used
    to distinguish between "view only" form modes and "maintenance" form modes
    which allow a user to change data.  The actual modes implemented by a form
    are not restricted to these purposes and may be arbitrarily defined as the
    form needs dictate. The current `msrd_mode` value is considered a
    subdivision of the current `msrd_feature` value; this means that the same
    `msrd_mode` value may appear to behave differently depending on the current
    value of the `msrd_feature` attribute.  The value is an atom.  See
    `c:MscmpSystForms.get_form_modes/0` for more information

    * `msrd_state` - the current form state within the `msrd_mode`.  "Form
    states" are the most granular level at which form user interface behaviors
    are determined.  This value supports functionality which allows for
    "progressive entry" style forms: forms which only allow certain user inputs
    to be made prior to allowing others which depend on the earlier values, for
    example.  `msrd_state` values are subordinate to the prevailing `msrd_mode`
    value and as such the same `msrd_state` value may exhibit different
    behaviors for differing values of `msrd_mode`.  The value is an atom.  See
    `c:MscmpSystForms.get_form_modes/0` for more information

    * `msrd_overrides` - a list of the currently active processing overrides.
    As a user interacts with a form, there may be certain actions which result
    in longer running processes during which certain user interface interactions
    or data displays should become inactive or indicate some form of "please
    wait" message; the list of active processing overrides indicate that such
    processing exists so that user interface elements may respond as necessary.
    This list is maintained using the
    `MscmpSystForms.start_processing_override/2` and
    `MscmpSystForms.finish_processing_override/2` functions.

    * `msrd_user_perms` - The relevant permission grants of the current user.
    This is a map conforming to the `t:MscmpSystPerms.perm_grants/0` type.  The
    permission grants are used as a filter for determining what the user may see
    in terms of data and do in terms of form functionality.

  ## Parameters

    * `socket_or_assigns` - the socket or assigns for the current view.

    * `session_name` - the name of the session.  This value is usually set in
    prior to the view being called and is part of the parameters passed to the
    view.  Ultimately this is the link between the users client and our richer
    sense of session available to the server side view logic.

    * `module` - the name of the form module backing the form and implementing
    the `MscmpSystForm` behaviour.

    * `feature` - the currently prevailing form state feature.  See the
    `msrd_feature` Standard Assign Attribute description above for more.

    * `mode` - the currently prevailing form state mode.  See the `msrd_mode`
    Standard Assign Attribute description above for more.

    * `state` - the currently prevailing form state.  See the `msrd_state`
    Standard Assign Attribute description above for more.

    * `user_perms` - the current user permission grants which apply to the form.
    See the `msrd_user_perms` Standard Assign Attributes discussion above for
    more.

    * `opts` - this function accepts a number of optional parameters.  The
    available options are:

      * `original_data` - the starting form data, often times as drawn from the
      database.  The data retained here does not reflect changes in the data by
      the user interacting with the form.  All data backing the form is kept in
      this value without regard to the current user's data visibility
      permissions.  The expected value for this option is the starting data as a
      struct defined by the form backing `MscmpSystForms` behaviour implementing
      module.  The default value is an empty struct of the expected type.

      * `current_data` - the current form data reflecting changes made due to
      user interactions which have not yet been committed to the database.  The
      data here is the complete current data, without regard to the user's data
      visibility permissions.  This data given for this parameter is expected to
      be a simple map based on the form backing `MscmpSystForms` implementing
      module.  The default value is a map copied from the `original_data` option
      value.

      * `display_data` - this option will ultimately set the `msrd_display_data`
      Standard Assign Attribute described above.  For the purposes of
      `init_assigns/8`, this value should be a reference to a
      `t:MscmpSystForms.Types.data_validation_types/0` value which will process
      the data provided by the `original_data` and `current_data` options into
      the correct display data for the form, after having applied the user's
      data visibility permissions.

      * `overrides` - this option allows the processing overrides list stored in
      `msrd_overrides` to be populated on initialization.  This could be helpful
      if certain initialization processes themselves are expected to be long
      running.  By default this option is set to an empty list.
  """
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

  @doc section: :form_generation
  @doc """
  Rebuilds component configuration assigns updating the configurations driving
  user interface rendering.

  This function needs to be called after settings which should alter the
  renderable Component Configurations.  For example, changing the form's current
  Form State (feature, mode, or state) will change how the user interface
  components are rendered; after the Form State has been changed this function
  must be called to rebuild the component configuration assigns that actually
  drive the rendering of those components.

  Activities requiring the Component Configurations assigns to be rebuilt
  include:

    * Changing the `msrd_feature`, `msrd_mode`, or `msrd_state` Form State
    values.

    * Updating the `msrd_user_perms` value.

  Most other operations, such as processing form data changes don't require
  Component Configuration rebuilding as they work within the existing
  Component Configurations.

  Rebuilding the Component Configuration assigns is a somewhat expensive process
  and to avoid over-processing these rebuilds its recommended that all changes
  which require a Component Configuration rebuild be performed prior to calling
  `rebuild_component_assigns/1`.
  """
  @spec rebuild_component_assigns(Types.socket_or_assigns()) :: Types.socket_or_assigns()
  defdelegate rebuild_component_assigns(socket_or_assigns), to: Impl.Forms

  @doc section: :form_generation
  @doc """
  Builds current Component Configurations based on the Form Configuration and
  Form Modes definitions in combination with runtime values such as the current
  Form State and the current user's permission grants.

  Render configurations, also called Component Configurations in this
  documentation provide each component in the user interface instructions on how
  to render and what interactivity to accept from the user.

  The Component Configurations generated by this function are returned as a map
  of key/value pairs where the keys are the `t:MscmpSystForms.Types.form_id/0`
  values of the user interface components and the values are
  `t:MscmpSystForms.Types.ComponentConfig.t/0` structs defining the current
  rendering requirements of the components.  Typically this map is merged into
  the assigns of the form so that components can retrieve the configurations at
  render time.

  ## Parameters

    * `module` - the name of the `MscmpSystForms` implementing module which
    backs the form.

    * `feature` - the Form State Feature to reference when building Component
    Configurations.

    * `mode` - the Form State Mode to reference when building Component
    Configurations.

    * `state` - the Form State State to reference when building Component
    Configurations.

    * `perms` - the current user's applicable permission grants for the form.
  """

  @spec get_render_configs(
          module(),
          Types.form_state_feature_name(),
          Types.form_state_mode_name(),
          Types.form_state_state_name(),
          MscmpSystPerms.Types.perm_grants()
        ) :: Types.render_configs()
  defdelegate get_render_configs(module, feature, mode, state, perms), to: Impl.Forms

  @doc section: :form_generation
  @doc """
  Retrieves the textual information (`label`, `label_link`, and `info`)
  field values from the Form Configuration for the identified component.

  This is a convenience function which accepts either a `form_id` value or
  a `binding_id` value and returns the textual information for the
  component if found by the passed identifier.

  ## Parameters

    * `module` - the name of the form module implementing the
    `c:MscmpSystForms.get_form_config/0` callback with which form configuration
    data will be retrieved.

    * `component_id` - this value is either the `form_id` or `binding_id`
    that is associated with the component for which textual information is
    being retrieved.
  """
  @spec get_component_info(module(), Types.form_id() | Types.binding_id()) ::
          Types.component_info() | nil
  defdelegate get_component_info(module, component_id), to: Impl.Forms

  @doc section: :data_management
  @doc """
  Converts a form data Changeset into a `t:Phoenix.HTML.Form.t/0` struct after
  having applied the current user's data visibility permissions.

  Once the current form's data has been validated it must be turned into a form
  that can be rendered.  This function basically wraps the `Phoenix.Ecto`
  implementation of the `Phoenix.HTML.FormData.to_form/2` function so that we
  can apply user data visibility permission to the data prior to the conversion
  of that data into a renderable `t:Phoenix.HTML.Form.t/0` struct.

  ## Parameters

    * `changeset` - an `t:Ecto.Changeset.t/0` struct representing the validated
    data with which to build the form.  Typically this Changeset will be
    generated either by `c:validate_save/2` or `c:validate_post/2`.

    * `perms` - the current user's permission grants as recorded in the Standard
    Assign Attribute `msrd_user_perms`.  See `init_assigns/8` for more.

    * `opts` - while not typically used, there are optional parameters which are
    passed to the `Phoenix.HTML.FormData.to_form/2` function.  The available
    options are documented at `Phoenix.HTML.Form.form_for/4`.  The options here
    have slightly different names to avoid naming collisions.

      * `component_id` - the same as the `id` option of
      `Phoenix.HTML.Form.form_for/4`.

      * `component_method` - the same as the `method` option of
      `Phoenix.HTML.Form.form_for/4`.

      * `component_multipart` - the same as the `multipart` option of
      `Phoenix.HTML.Form.form_for/4`.

      * `component_csrf_token` - the same as the `csrf_token` option of
      `Phoenix.HTML.Form.form_for/4`.

      * `component_errors` - the same as the `errors` option of
      `Phoenix.HTML.Form.form_for/4`.
  """
  @spec to_form(Ecto.Changeset.t(), MscmpSystPerms.Types.perm_grants(), Keyword.t()) ::
          Phoenix.HTML.Form.t()
  defdelegate to_form(changeset, perms, opts \\ []), to: Impl.Forms

  @doc section: :state_management
  @doc """
  Sets the state of `MscmpSystForms.WebComponents.msvalidated_button/1`
  components.

  Validated buttons exist in one of three states defined by
  `t:MscmpSystForms.Types.msvalidated_button_states/0`.  This function will
  set the state of the validated button identified by the `form_id`
  parameters to the state identified by the `button_state` parameters.

  ## Parameters

    * `socket_or_assigns` - the socket or assigns for the current view.

    * `form_id` - the identifier of the component to update.  See
    `c:MscmpSystForms.get_form_config/0` for more about form configuration
    attributes.

    * `button_state` - the state to which the validated button component
    should be set.  Any value defined by the
    `t:MscmpSystForms.Types.msvalidated_button_states/0` type is valid for
    this purpose.
  """
  @spec update_button_state(
          Types.socket_or_assigns(),
          Types.form_id(),
          Types.msvalidated_button_states()
        ) :: Types.socket_or_assigns()
  defdelegate update_button_state(socket_or_assigns, form_id, button_state), to: Impl.Forms

  @doc section: :state_management
  @doc """
  Adds a processing override to the active overrides list.

  Some user interface components are configured to change their presentation and
  interactivity when certain, possibly long running, processes are underway.
  This function adds the value of the `override` parameter to the active
  processes list allowing components interest in that processing state to
  respond accordingly.

  ## Parameters

    * `socket_or_assigns` - the socket or assigns for the current view.

    * `override` - the name of the processing override to activate.
  """
  @spec start_processing_override(Types.socket_or_assigns(), Types.processing_override_name()) ::
          Types.socket_or_assigns()
  defdelegate start_processing_override(socket_or_assigns, override), to: Impl.Forms

  @doc section: :state_management
  @doc """
  Removes a processing override from the active overrides list.

  Once an active operation previously added to the process overrides list has
  completed its processing, this function is used to remove it from the list so
  that any user interface components that are watching for the operation to be
  active can resume their normal behavior.

  ## Parameters

    * `socket_or_assigns` - the socket or assigns for the current view.

    * `override` - the name of the processing override to remove from the active
    process overrides list.
  """
  @spec finish_processing_override(Types.socket_or_assigns(), Types.processing_override_name()) ::
          Types.socket_or_assigns()
  defdelegate finish_processing_override(socket_or_assigns, override), to: Impl.Forms

  @doc section: :data_management
  @doc """
  Updates the display form data with new values.

  The display data of the form, which represents the form's backing data
  after the application of effective user permissions to purge values that
  the user is not entitled to see, is set using this function.  The data is
  stored in the view's assigns as a `t:Phoenix.HTML.Form.t/0` value which is
  then passed to the view for rendering.

  ## Parameters

    * `socket_or_assigns` - the socket or assigns for the current view.

    * `display_data` - this option contains either the new display data to set
    and with which to update the form or indicates the kind of data validation
    to perform on the assigns stored data (`msrd_original_data` &
    `msrd_current_data`; see `MscmpSystForms.init_assigns/8` for more).

        One method for setting the display data is to pass this option to the
        function using actual data.  This data can take the form of either a
        `t:Ecto.Changeset.t/0` value or a `t:Phoenix.HTML.Form.t/0` value. If a
        Changeset is passed, the function will automatically process it into a
        `t:Phoenix.HTML.Form.t/0` struct, applying the permissions currently set
        in the `msrd_user_perms` Standard Assigns Attribute to filter the data.
        If the value to be passed in this option is a `t:Phoenix.HTML.Form.t/0`
        value, the struct should have been generated using
        `MscmpSystForms.to_form/3` so that the user data visibility permissions
        will have been allied.

        The second method is to pass `display_data` as a value referencing a
        display data validation type
        (`t:MscmpSystForms.Types.data_validation_types/0`).  When this method is
        used, the values of the `msrd_current_data` and `msrd_original_data` are
        validated using the standard validation functions
        (`c:MscmpSystForms.validate_save/2` and
        `c:MscmpSystForms.validate_post/2`) and then processed into a
        `t:Phoenix.HTML.Form.t/0` value to save as the new `msrd_display_data`
        value.  Either of the validation types will result in the application of
        user data visibility permissions per the `msrd_user_perms` Standard
        Assigns Attribute.

    * `opts` - this function defines some optionally required parameters
    which are dependent on the `display_data` parameter. When the `display_data`
    value is passed as a `t:MscmpSystForms.Types.data_validation_types/0`
    allowed value the following are required:

      * `original_data` - a struct of values representing the starting data
      initialized on initial form loading and absent any changes the user
      may have made and not yet committed to the database.  This value
      should be available in the standard assigns for `MscmpSystForms` based
      forms.

      * `current_data` - a map of values representing the current data
      backing the form.  This data is complete (unfiltered by user data
      related permissions) and includes any edits made by the user and not
      yet committed to the database.  This value is available in the standard
      assigns for `MscmpSystForms` based forms.

      * `module` - the name of the form module implementing the
      `MscmpSystForm` behaviour and the functions to validate the Changeset.
  """
  @spec update_display_data(
          Types.socket_or_assigns(),
          Ecto.Changeset.t() | Phoenix.HTML.Form.t() | Types.data_validation_types(),
          Keyword.t()
        ) :: Types.socket_or_assigns()
  defdelegate update_display_data(socket_or_assigns, display_data, opts \\ []), to: Impl.Forms

  @doc section: :state_management
  @doc """
  A convenience function which sets the Form State State value on the
  appropriate Standard Assign Attribute.

  This allows only updating the Form State State value of the form, leaving the
  Form State Feature and Mode values unchanged.

  See `set_form_state/4` for more information and caveats.

  ## Parameters

    * `socket_or_assigns` - the socket or assigns for the current view.

    * `state` - the new Form State State to set for the form.
  """
  @spec set_form_state(Types.socket_or_assigns(), Types.form_state_state_name()) ::
          Types.socket_or_assigns()
  defdelegate set_form_state(socket_or_assigns, state), to: Impl.Forms

  @doc section: :state_management
  @doc """
  A convenience function which sets the Form State Mode and State values on the
  appropriate Standard Assign Attributes.

  This allows only updating the Form State Mode and State values of the form,
  leaving the Form State Feature value unchanged.

  See `set_form_state/4` for more information and caveats.

  ## Parameters

    * `socket_or_assigns` - the socket or assigns for the current view.

    * `mode` - the new Form State Mode to set for the form.

    * `state` - the new Form State State to set for the form.
  """
  @spec set_form_state(
          Types.socket_or_assigns(),
          Types.form_state_mode_name(),
          Types.form_state_state_name()
        ) ::
          Types.socket_or_assigns()
  defdelegate set_form_state(socket_or_assigns, mode, state), to: Impl.Forms

  @doc section: :state_management
  @doc """
  A convenience function which sets the Form State Feature, Mode, and State
  values on the appropriate Standard Assign Attributes.

  > ### Note {: .neutral}
  >
  > Using this function does not result in the regeneration of Component
  > Configurations.  This is not done to avoid regenerating Component
  > Configurations multiple times unnecessarily.
  >
  > You must explicitly regenerate the Component Configuration for changes made
  > by this function to be rendered correctly.  This is typically done by
  > calling `rebuild_component_assigns/1` some time after this function has
  > been called.

  For more see `MscmpSystForms.init_assigns/8`.

  ## Parameters

    * `socket_or_assigns` - the socket or assigns for the current view.

    * `feature` - the new Form State Feature to set for the form.

    * `mode` - the new Form State Mode to set for the form.

    * `state` - the new Form State State to set for the form.
  """
  @spec set_form_state(
          Types.socket_or_assigns(),
          Types.form_state_feature_name(),
          Types.form_state_mode_name(),
          Types.form_state_state_name()
        ) ::
          Types.socket_or_assigns()
  defdelegate set_form_state(socket_or_assigns, feature, mode, state), to: Impl.Forms

  ##############################################################################
  #
  #  Msform Extensions
  #
  ##############################################################################

  defmacro __using__(_) do
    quote do
      @behaviour MscmpSystForms

      @doc section: :state_management
      @doc """
      Sets the state of `MscmpSystForms.WebComponents.msvalidated_button/1`
      components.

      Validated buttons exist in one of three states defined by
      `t:MscmpSystForms.Types.msvalidated_button_states/0`.  This function will
      set the state of the validated button identified by the `form_id`
      parameters to the state identified by the `button_state` parameters.

      ## Parameters

        * `socket_or_assigns` - the socket or assigns for the current view.

        * `form_id` - the identifier of the component to update.  See
        `c:MscmpSystForms.get_form_config/0` for more about form configuration
        attributes.

        * `button_state` - the state to which the validated button component
        should be set.  Any value defined by the
        `t:MscmpSystForms.Types.msvalidated_button_states/0` type is valid for
        this purpose.
      """
      @spec update_button_state(
              Types.socket_or_assigns(),
              Types.form_id(),
              Types.msvalidated_button_states()
            ) :: Types.socket_or_assigns()
      defdelegate update_button_state(socket_or_assigns, form_id, button_state),
        to: MscmpSystForms

      @doc section: :state_management
      @doc """
      Adds a processing override to the active overrides list.

      Some user interface components are configured to change their presentation and
      interactivity when certain, possibly long running, processes are underway.
      This function adds the value of the `override` parameter to the active
      processes list allowing components interest in that processing state to
      respond accordingly.

      ## Parameters

        * `socket_or_assigns` - the socket or assigns for the current view.

        * `override` - the name of the processing override to activate.  This value
        will be an atom and will be form implementation specific.
      """
      @spec start_processing_override(Types.socket_or_assigns(), Types.processing_override_name()) ::
              Types.socket_or_assigns()
      defdelegate start_processing_override(socket_or_assigns, override), to: MscmpSystForms

      @doc section: :state_management
      @doc """
      Removes a processing override from the active overrides list.

      Once an active operation previously added to the process overrides list has
      completed its processing, this function is used to remove it from the list so
      that any user interface components that are watching for the operation to be
      active can resume their normal behavior.

      ## Parameters

        * `socket_or_assigns` - the socket or assigns for the current view.

        * `override` - the name of the processing override to remove from the active
        process overrides list.
      """
      @spec finish_processing_override(
              Types.socket_or_assigns(),
              Types.processing_override_name()
            ) :: Types.socket_or_assigns()
      defdelegate finish_processing_override(socket_or_assigns, override), to: MscmpSystForms

      @doc section: :data_management
      @doc """
      Updates the display form data with new values.

      The display data of the form, which represents the form's backing data
      after the application of effective user permissions to purge values that
      the user is not entitled to see, is set using this function.  The data is
      stored in the view's assigns as a `t:Phoenix.HTML.Form.t/0' value which is
      then passed to the view for rendering.

      ## Parameters

        * `socket_or_assigns` - the socket or assigns for the current view.

        * `display_data` - this option contains either the new display data to
        set and with which to update the form or indicates the kind of data
        validation to perform on the assigns stored data (`msrd_original_data` &
        `msrd_current_data`; see `MscmpSystForms.init_assigns/8` for more).

            One method for setting the display data is to pass this option to
            the function using actual data.  This data can take the form of
            either a `t:Ecto.Changeset.t/0` value or a `t:Phoenix.HTML.Form.t/0`
            value. If a Changeset is passed, the function will automatically
            process it into a `t:Phoenix.HTML.Form.t/0` struct, applying the
            permissions currently set in the `msrd_user_perms` Standard Assigns
            Attribute to filter the data. If the value to be passed in this
            option is a `t:Phoenix.HTML.Form.t/0` value, the struct should have
            been generated using `MscmpSystForms.to_form/3` so that the user
            data visibility permissions will have been allied.

            The second method is to pass `display_data` as a value referencing a
            display data validation type
            (`t:MscmpSystForms.Types.data_validation_types/0`).  When this
            method is used, the values of the `msrd_current_data` and
            `msrd_original_data` are validated using the standard validation
            functions (`c:MscmpSystForms.validate_save/2` and
            `c:MscmpSystForms.validate_post/2`) and then processed into a
            `t:Phoenix.HTML.Form.t/0` value to save as the new
            `msrd_display_data` value.  Either of the validation types will
            result in the application of user data visibility permissions per
            the `msrd_user_perms` Standard Assigns Attribute.

        * `opts` - this function defines some optionally required parameters
        which are dependent on the `display_data` parameter. When the
        `display_data` value is passed as a
        `t:MscmpSystForms.Types.data_validation_types/0` allowed value the
        following are required:

          * `original_data` - a struct of values representing the starting data
          initialized on initial form loading and absent any changes the user
          may have made and not yet committed to the database.  This value
          should be available in the standard assigns for `MscmpSystForms` based
          forms.

          * `current_data` - a map of values representing the current data
          backing the form.  This data is complete (unfiltered by user data
          related permissions) and includes any edits made by the user and not
          yet committed to the database.  This value is available in the
          standard assigns for `MscmpSystForms` based forms
      """
      @spec update_display_data(
              Types.socket_or_assigns(),
              Ecto.Changeset.t() | Phoenix.HTML.Form.t(),
              Keyword.t()
            ) :: Types.socket_or_assigns()
      def update_display_data(socket_or_assigns, display_data, opts \\ []) do
        opts = MscmpSystUtils.resolve_options(opts, module: __MODULE__)
        MscmpSystForms.update_display_data(socket_or_assigns, display_data, opts)
      end

      @doc section: :form_generation
      @doc """
      Retrieves the textual information (`label`, `label_link`, and `info`)
      field values from the Form Configuration for the identified component.

      This is a convenience function which accepts either a `form_id` value or
      a `binding_id` value and returns the textual information for the
      component if found by the passed identifier.

      ## Parameters

        * `component_id` - this value is either the `form_id` or `binding_id`
        that is associated with the component for which textual information is
        being retrieved.
      """
      @spec get_component_info(Types.form_id() | Types.binding_id()) ::
              Types.component_info() | nil
      def get_component_info(component_id),
        do: MscmpSystForms.get_component_info(__MODULE__, component_id)
    end
  end
end
