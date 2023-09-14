# Source File: form_config.ex
# Location:    musebms/app_server/components/system/mscmp_syst_forms/lib/types/form_config.ex
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

defmodule MscmpSystForms.Types.FormConfig do
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

  alias MscmpSystForms.Types

  defstruct [
    :form_id,
    :binding_id,
    :permission,
    :label,
    :label_link,
    :info,
    :button_state,
    children: []
  ]

  @typedoc """
  A struct used by developers to define the abstract structure and configuration
  details of user interface forms and their elements including their
  permissions, data bindings, text strings, as well as their child elements
  which may inherit certain properties such as permissions.

  ## Attributes

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

  Form more see `MscmpSystForms.Types.FormConfig`.
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
end
