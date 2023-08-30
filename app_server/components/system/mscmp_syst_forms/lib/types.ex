# Source File: types.ex
# Location:    musebms/app_server/components/system/mscmp_syst_forms/lib/types.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystForms.Types do
  @moduledoc """
  Defines the data types, formats, and structures used by `MscmpSysForms`
  module.
  """

  #
  # Note that the ordering of typespecs here is alphabetical.
  #

  @typedoc """
  The identifier type for data binding identifiers.

  Data binding identifiers are used to identify data fields in `Ecto`
  Changesets, `t:Phoenix.HTML.form.t/0` representations of data, form parameters
  as returned on submission, and in `t:MscmpSystForms.Types.FormConfig.t/0`
  form configurations.  All of these representations which are used in different
  contexts will represent the same data and this `binding_id` is the name which
  identifies the data across these logical contexts.
  """
  @type binding_id() :: atom()

  @typedoc """
  A structure defining the different kinds of display mode data which can be
  communicated to a user interface component.

  User interface components can be configured with a variety of display options,
  called "modes".  Between the functions which generate the effective modes for
  the user interface and the user interface components themselves there must be
  a standard way to communicate and this type defines the structure of that
  communication.

  It is worth noting that the Component will receive its display modes in data
  with this structure.
  """
  @type component_display_modes() ::
          %{
            optional(:component_mode) => component_modes(),
            optional(:border_mode) => display_modes(),
            optional(:text_mode) => display_modes() | list(String.t()),
            optional(:label_mode) => display_modes() | list(String.t())
          }

  @typedoc """
  The returned data type of the `MscmpSystForms.get_component_info/2` function.

  The type identifies the specific returned textual information describing the
  component and configured in the Form Configurations.

  See `c:MscmpSystForms.get_form_config/0` for more.
  """
  @type component_info() :: %{label: String.t(), label_link: String.t(), info: String.t()}

  @typedoc """
  Component level modes which govern the behavior of components in terms of
  interactivity, whether or not they may display data, and even if the component
  is visible to users or present in the layout.

  Each component is designed to respond appropriately when one of the following
  component modes are specified.

    * `:removed` - A component in this mode will not be visible and will not
    take space in the layout of a view.

    * `:hidden` - When a component is in this mode, the component is hidden fro
    the user, but will take space in the layout of the view as though it were
    present.

    * `:cleared` - The cleared component mode allows components to be rendered
    into the layout, but input related components will not display any of their
    associated data and will be disabled for any user interactivity.  This is
    used primarily when the user may know that a given field exists, but does
    not have permission to view the data associated with the field.

    * `:processing` - Used when some long running application process involving
    the data of the form or component has started, but not yet finished.  A
    component in processing mode will be disabled from user interaction and will
    likely change its display characteristics as appropriate for the processing
    state.

    * `:visible` - For use when a component should be present and visible on the
    screen and any associated data should be visible to the user, but the
    component should not accept user interactions.  Informally speaking this is
    the mode which enables a "view only" presentation of a component.

    * `:entry` - This component mode allows the component and its associated
    data to be visible to the user as well as allows the user to interact with
    any functionality, such as changing the data value or clicking a button,
    etc.  Informally speaking this is the "edit mode" component mode.


  """
  @type component_modes() :: :removed | :hidden | :cleared | :processing | :visible | :entry

  @typedoc """
  Defines the acceptable validation type values that can be passed in the
  `display_data` parameter of `MscmpSystForms.init_assigns/8` and
  `MscmpSystForms.update_display_data/3`.
  """
  @type data_validation_types() :: :save | :post

  @typedoc """
  A standardized set of modes which govern the styling of MscmpSystForms defined
  web components.

  * `:deemphasis` - Used in cases where we want to specific reduce attention to
  a give element.  For example `:deemphasis` might be used in cases where a web
  component is disabled for entry.  The reduction in "presence" is the greatest
  compared amongst all display modes which reduce visual presence.

  * `:reference` - For reducing attention to informational content as compared
  to actionable elements such as input fields and their labels.  In this case
  we want a visually "present" element, but not one so visually pronounced that
  is distracts from more important elements.

  * `:normal` - This display mode is the primary choice of normal input
  components as well as their labels.  This is true when the elements are active
  and actionable, but require no greater attention that most other elements with
  with they are displayed.

  * `:emphasis` - Used for elements which are active and are of greater
  importance or require more pronounced attention than other elements of the
  same class.  For example, a required input field and its label may be given
  this display mode so they stand out from all other entry fields.  Use of this
  display mode should be carefully considered as if everything is emphasized
  then nothing is.

  * `:warning` - Elements which are in a warning state and where the warning
  state requires greater attention than normal screen elements.  This display
  mode will typically change various colored elements to the established warning
  color.

  * `:alert` - When elements in the interface require heightened attention and
  are either in an error state or in conditions where greater attention than a
  warning is required.  Colored elements will typically assume the established
  alert color when this display mode is set.

  * `:approve` - A normal attention display mode where colored elements will
  assume the established approval colors.

  * `:deny` - A normal attention display mode where colored elements will assume
  the established denial colors.

  * `:info` - A normal attention display mode where colored elements will assume
  the established "information" color scheme.
  """
  @type display_modes() ::
          :deemphasis
          | :reference
          | :normal
          | :emphasis
          | :warning
          | :alert
          | :approve
          | :deny
          | :info

  @typedoc """
  Defines a type for identifying specific elements in user interface forms.

  Under some form processing functions, particularly those dealing with creating
  web user interfaces, `form_id` values may be converted to `t:binary/0`
  representations as they are also used for HTML element `id` attributes (either
  directly or as modified to identify sub-elements of user interface
  components.)
  """
  @type form_id() :: atom()

  @typedoc """
  The structure of data representing Components and their display modes within
  `t:form_state_states/0` structured data.
  """
  @type form_state_components() :: %{required(form_id()) => component_display_modes()}

  @typedoc """
  Defines the type used to express Form State Feature names.
  """
  @type form_state_feature_name() :: atom()

  @typedoc """
  The expressed data structure of Form State Feature configurations.

  Each Form State Feature defines several different points of configuration.

  First a `:default` set of component configurations which act as a fallback
  when a specific Mode/State combination do not fully address a component's
  configuration themselves.  When the `:default` component configuration also
  doesn't address a component, the `t:component_display_modes/0` of last resort
  is used (currently: `%{component_mode: :cleared}`).

  Next we define the `:processing_overrides` that each component should respond
  to when active.

  Finally we define the Modes and States for each named Feature.  We expect that
  each Mode will be represented with a key in this map using the Mode's name;
  the value will be a map in the form dictated by `t:form_state_modes/0`.

  See `c:MscmpSystForms.get_form_modes/0` for more.
  """
  @type form_state_features() :: %{
          required(:default) => form_state_components(),
          required(form_state_feature_name()) => form_state_modes(),
          required(:processing_overrides) => form_state_overrides()
        }

  @typedoc """
  Defines the type used to express Form State Mode names.
  """
  @type form_state_mode_name() :: atom()

  @typedoc """
  The structure defining how Form State Modes are expressed within the Form
  State defined by `t:form_states/0`.

  Each Form State Mode definition returned by `c:MscmpSystForms.get_form_modes/0`
  should be a map of key/value pairs where the key is the Form State Mode Name
  and the values are each a map of the defined Form State States for that Mode.

  See `c:MscmpSystForms.get_form_modes/0` for more.
  """
  @type form_state_modes() :: %{required(form_state_mode_name()) => form_state_states()}

  @typedoc """
  Defines how Components are linked to the Processing Overrides to which they
  are interested in responding.

  Processing overrides are a mechanism to identify that certain processes that
  are expected to be long running are active.  Components in turn can respond to
  the processes they are watching becoming active as they require (usually
  the component becomes inactive while the process is active).
  """
  @type form_state_overrides() :: %{required(form_id()) => list(processing_override_name())}

  @typedoc """
  The type which is used to represent the name of Form State states.
  """
  @type form_state_state_name() :: atom()

  @typedoc """
  The structure of each individual Form State as defined within the
  `t:form_states/0`.

  Form State State definitions returned by `c:MscmpSystForms.get_form_modes/0`
  are expected to come as a map of key/value pairs where the key is the name of
  the Form State State being defined (`t:form_state_state_name/0`) and the
  value is a map of components which define their display modes for the State.

  See `c:MscmpSystForms.get_form_modes/0` for more.
  """
  @type form_state_states() :: %{
          required(form_state_state_name()) => form_state_components()
        }

  @typedoc """
  The data structure describing the configuration of Form States as returned by
  `c:MscmpSystForms.get_form_modes/0`.

  Form State configurations are returned as a map of "Features" where each
  Feature defines its Modes, States, Defaults, and Processing Overrides.

  Each Feature in the Form State is represented in the map using its own name as
  the key.  The common practice is that if a form only supports a single
  Feature, the Feature should be named `:default`; otherwise the Feature Name
  is arbitrary, but should be descriptive.
  """
  @type form_states() :: %{required(form_state_feature_name()) => form_state_features()}

  @typedoc """
  Identifies the available states that an
  `MscmpSystForms.WebComponents.msvalidated_button/1` might take.

    * `:action` - this state indicates that the validating conditions have been
    met and that the button's action may be invoked at user convenience.

    * `:processing` - indicates that an active process which prevents the button
    from correctly reflecting any state other than it is waiting is currently
    underway.  The button will not accept user interaction at this point.

    * `:message` - indicates that the validating condition for the button is not
    yet satisfied.  Any user interaction with the button (clicking it) will
    result in a message indicating that there are unmet conditions.
  """
  @type msvalidated_button_states() :: :action | :processing | :message

  @typedoc """
  A type for naming permissions.

  Forms in the system will at a display level need to have awareness and
  functionality to respect permissions.
  """
  @type permission_name() :: atom()

  @typedoc """
  Defines the type of Processing Override Names.

  Processing overrides are a mechanism to identify that certain processes that
  are expected to be long running are active.  Components in turn can respond to
  the processes they are watching becoming active as they require (usually
  the component becomes inactive while the process is active).
  """
  @type processing_override_name() :: atom()

  @typedoc """
  Establishes the expected data structure of the
  `MscmpSystForms.get_render_configs/5` function return value.

  The `MscmpSystForms.get_render_configs/5` function returns the currently
  renderable configurations for each Component as a map of key/value pairs where
  the key is the `t:form_id()` of the Component and the value is a Component
  Configuration using the `t:MscmpSystForms.Types.ComponentConfig.t/0` data
  structure.
  """
  @type render_configs() :: %{required(form_id()) => MscmpSystForms.Types.ComponentConfig.t()}

  @typedoc """
  Defines the type of the Session Name.

  The Session Name is usually generated via in the router's authentication
  related plug pipelines.  The Session Name is added to the user's browser
  session and becomes the link between that browser session and the extended
  session information stored server side in the database.
  """
  @type session_name() :: String.t()

  @typedoc """
  A definition of the expected Socket or Assigns parameter used in Phoenix.

  The Phoenix Framework has a number of functions which accept Sockets and
  Assigns from different sources which Phoenix generates, but Phoenix doesn't
  formalize this into any sort of typespec.  Our concept is the same as Phoenix
  except that we prefer to have documented types, even if they are limited
  test/compile/run time value.
  """
  @type socket_or_assigns() ::
          Phoenix.Socket.t() | Phoenix.LiveView.Socket.t() | Phoenix.LiveView.Socket.assigns()
end

defmodule MscmpSystForms.Types.FormConfig do
  alias MscmpSystForms.Types

  @moduledoc """
  A struct used by developers to define the abstract structure and configuration
  details of user interface forms and their elements including their
  permissions, data bindings, text strings, as well as their child elements
  which may inherit certain properties such as permissions.

  This would be called a "Definition Time" concern/configuration.

  Note that while it is most typical for form configurations to be associated
  directly with specific user interface elements, the configuration system
  allows for grouping form configuration entries which do not related directly a
  specific user interface element and exist purely to serve as parent to other
  form configurations so that those children can inherit the parent's
  properties.  A common example of this is most forms define an abstract top
  level parent form configuration which defines the default permission for all
  other form elements to inherit from.

  Not all elements on a form must be represented by a `FormConfig` value,
  however any element which must respond to runtime changes in form state,
  processing overrides, or current user permissions must have at least a
  `FormConfig` value defining its `form_id` value.
  """

  @typedoc """
  Defines the attributes available to the developer to create an abstract form
  definition.

  ## Fields

    * `form_id` - identifies the user interface form element to which the
    configuration will be applied.  If this value is `nil` then the
    configuration won't refer to specific element in the user interface, but is
    a virtual or abstract configuration which may serve as parent to other
    concrete element backing configurations.  Note that elements with
    `FormConfigs` defined with `nil` `form_id` values will not appear at all in
    render configurations.

    * `binding_id` - for user interface elements which display application data
    to identify the data field from which to draw values using this identifier.
    If the `binding_id` is `nil` then the element will not be bound to a field
    in the form's backing data.

    * `permission` - the identifier of the permission which this form element
    will test for element access when rendering the form, displaying data, and
    permitting user interaction if the element being configured allows for
    interaction.  This value will be inherited by any child of a configuration
    that doesn't specify its own permission value.

    * `label` - if the user interface element is backed by a component which
    displays a label, such as an `MscmpSystForms.WebComponents.msinput/1`
    component, the text of the label may be set using this value.  If this value
    is `nil` either the label will be blank, not rendered, or determined by
    directly setting the component's `title` value directly in the view layer.
    Note that component's `title` attribute can override the value set in the
    configuration using this configuration.

    * `label_link` - the label of a user interface element may optionally define
    a URL to link to when clicking the label, such as a link to relevant
    documentation.  When this value is not `nil`, the link is the URL to the
    resource to access; when `nil` the label is rendered without a link.
    (*Note that `label_link` is not yet implemented in most components.*)

    * `info` - in some situations, abbreviated additional information for a
    user interface element is made available to the user, for example via the
    `MscmpSystForms.WebComponent.msinfo/1` web component.  This attribute
    configures the text that is displayed to the user in these scenarios.  If
    the value is `nil` then no text is displayed even if it could be.

    * `button_state` - for user interface buttons of type
    `MscmpSystForms.WebComponents.msvalidated_button/1`, this attribute
    configures the default button state.  The available values are defined by
    the type `t:MscmpSystForms.Types.msvalidated_button_states/0`.

    * `children` - A form configuration may optionally identify child
    configurations which will inherit certain attributes and other traits from
    the parent.  Naturally, an element should never be added as a child to
    multiple parent configurations; doing so will result in undefined behaviors.
    Examples of attributes and traits that can be inherited through parent/child
    relationships defined in this field include permissions and component modes.
  """
  @type t() :: %__MODULE__{
          form_id: Types.form_id() | nil,
          binding_id: Types.binding_id() | nil,
          permission: Types.permission_name() | nil,
          label: String.t() | nil,
          label_link: String.t() | nil,
          info: String.t() | nil,
          button_state: Types.msvalidated_button_states() | nil,
          children: list(t()) | [] | nil
        }

  defstruct form_id: nil,
            binding_id: nil,
            permission: nil,
            label: nil,
            label_link: nil,
            info: nil,
            button_state: nil,
            children: []
end

defmodule MscmpSystForms.Types.ComponentConfig do
  alias MscmpSystForms.Types

  @moduledoc """
  An essential data type returned by the system using the
  `MscmpSystForms.get_render_configs/5` function.  That function returns
  a full form aggregate render configuration which is a combination of the
  developer created `t:MscmpSystForms.Types.FormConfig.t/0` values and various
  values determined at runtime such as the current form state,  active
  processing overrides, and current user permissions.

  This would be called a "Render Time" concern/derived configuration.

  The ComponentConfig values created by `MscmpSystForms.get_render_configs/5`
  just described are passed to the view where each Web Component will respond to
  its ComponentConfig value in order to meet the then prevailing view
  requirements.

  > ### Note {: .info}
  > This struct will not typically be created or used directly by a developer
  > creating user forms.  In this sense this struct could be considered an
  > internal implementation concern which shouldn't be part of the public
  > documentation.  However, developers creating components which need to
  > participate in `MscmpSystForms` form processing will need to know how to
  > make their components respond to `ComponentConfig` values so we do include
  > it in the documentation here.
  """

  @typedoc """
  Defines a struct which encapsulates runtime component configurations using
  `MscmpSystForms.get_render_configs/5`.

  ## Fields

    * `form_id` - identifies the user interface form element to which the
    component configuration will be applied.  Note that whereas
    `t:MscmpSystForms.Types.FormConfig.t/0` allows configurations of virtual or
    abstract components, these configurations will never appear as a
    `t:MscmpSystForms.Types.ComponentConfig.t/0` value.  Only concrete
    components with a `form_id` value are allowed to represented by component
    configurations.

    * `binding_id` - for user interface elements which display application data
    to identify the data field from which to draw values using this identifier.
    If the `binding_id` is `nil` then the element will not be bound to a field
    in the form's backing data.

    * `permission` - the identifier of the permission which determined may have
    changed the `modes` value which control element rendering.  This value will
    either be the permission set explicitly for field or that which the element
    inherited through its `MscmpSystForms.Types.FormConfig` parent.  This value
    may also be `nil` in which case permissions didn't influence the `modes`
    value because no permissions were defined to apply.

    * `label` - if set, this value will determine the label text for any Web
    Component which can display a label, such as
    `MscmpSystForms.WebComponents.msinput/1`.  If the component's `title`
    attribute is set directly in the view, it will override any value here.

    * `label_link` - the label of a user interface element may optionally define
    a URL to link to when clicking the label, such as a link to relevant
    documentation.  When this value is not `nil`, the link is the URL to the
    resource to access; when `nil` the label is rendered without a link.
    (*Note that `label_link` is not yet implemented in most components.*)

    * `info` - in some situations, abbreviated additional information for a
    user interface element is made available to the user, for example via the
    `MscmpSystForms.WebComponent.msinfo/1` web component.  This attribute
    configures the text that is displayed to the user in these scenarios.  If
    the value is `nil` then no text is displayed even if it could be.

    * `button_state` - if the component being configured by this value is a
    `MscmpSystForms.WebComponents.msvalidated_button/1` component, the
    `button_state` value will indicate the current display state of the button.
    See `t:MscmpSystForms.Types.msvalidated_button_states/0` for the available
    states.

    * `overrides` - a list of currently active processing overrides. A process
    override is a state which can be set for the form which simply indicates
    that some possibly long running application operation has been started, but
    is not yet finished.  See `MscmpSystForms.start_processing_override/2` for
    more about processing overrides.  The form and its components can respond to
    an active processing override by, for example, changing their display and
    interactivity characteristics until the processing override condition ends.
    If there are no processing overrides active, this value will be an empty
    list.

    * `modes` - the currently computed display modes for the component.  The
    display modes are computed by assessing the prevailing runtime form state
    and user permissions to determine the behavior of the component at render
    time.  These modes are then used by the component when creating the view
    to render.

  """
  @type t() :: %__MODULE__{
          form_id: Types.form_id(),
          binding_id: Types.binding_id() | nil,
          permission: Types.permission_name() | nil,
          label: String.t() | nil,
          label_link: String.t() | nil,
          info: String.t() | nil,
          button_state: Types.msvalidated_button_states() | nil,
          overrides: list(atom()) | nil,
          modes: map()
        }

  defstruct form_id: nil,
            binding_id: nil,
            permission: nil,
            label: nil,
            label_link: nil,
            info: nil,
            button_state: nil,
            overrides: nil,
            modes: nil
end
