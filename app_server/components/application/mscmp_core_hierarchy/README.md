# MscmpCoreHierarchy - Configuration and Validation of Hierarchical Data

<!-- MDOC !-->

API providing a baseline methodology for defining Hierarchies and validating
that implementations of those Hierarchies are valid.

The Hierarchy features supported by this Component are:

  * Providing a Hierarchy definition with which implementations can be
  validated.

  * Support for optionally validated Hierarchies ("structured" vs.
  "unstructured").

  * Support of optional Hierarchy levels.

  * Specification of which Hierarchy levels may be associated with "Leaf Nodes";
  for example a Hierarchy defining an application menu structure may allow for
  levels which only define menu item groupings or may be associated directly
  with actionable application menu items where the menu items are "Leaf Nodes".

  * Protection of in-use Hierarchy definitions to ensure Hierarchy
  implementation operational consistency.

>#### Important Note {: .warning}
>
> While this Component makes certain guarantees about ensuring valid and
> consistent Hierarchy configurations, full consistency depends on Hierarchy
> implementing Components honoring the MscmpCoreHierarchy guarantees.  To point,
> Hierarchy implementations must implement database foreign keys to the
> Hierarchy defining tables and ensures their own data structures are able to be
> validated against the defined Hierarchies.

## Concepts

There are a handful of conceptual ideas that you should be familiar with prior
to working with this Component or one of the Hierarchy implementing Components.


#### Hierarchy

There are two different, but related, meanings assigned to the term "Hierarchy"
in this Component.

In the first instance a Hierarchy is a configuration which establishes a pre-
defined structure for data which can be represented in a tree-like structure.
In this sense of the word we mean the totality of the records which define a
distinct Hierarchy.  This is the more generic and conceptual sense of the word
and it will be the intended meaning in most contexts.

The second meaning of Hierarchy is a more technically focused term referring
specifically to the Hierarchy "header record" as opposed to the Hierarchy Item
records which are the "detail records" defining the levels of the Hierarchy.
This second meaning will be meant more often when dealing with database and
specific technical related concerns, including the specific configuration
options which define the Hierarchy as a whole.

Hierarchies may be "structured" or "unstructured".  Structured Hierarchies
define specific levels of hierarchy which are required to some degree of
Hierarchy implementing Component data.  Unstructured Hierarchies aren't really
Hierarchies at all, but allow implementing Components to optionally allow both
structured and unstructured data without forcing special technical
accommodations for the unstructured data.

#### Hierarchy Types

Hierarchies are assigned to a specific Hierarchy Type.  The Hierarchy Type
establishes the area of system functionality to which the Hierarchy sensibly
applies.  For example, a Hierarchy of "Type Menu" may define and be sensible to
use in with application functions that define the application's user interface
menus whereas a Hierarchy of "Type Product Category" would best be applied to
Hierarchies which define product categorization structures.

#### Hierarchy Items

As mentioned above, Hierarchy Items specify the behaviors of the individual
levels of hierarchy contained by the Hierarchy.  This includes the configuration
points which are applicable to individual levels of the Hierarchy.  Hierarchy
Item records are children of the Hierarchy records.

Hierarchy Items are required to be defined for all structured Hierarchies.
Conversely, Hierarchy Items are prohibited in the context of unstructured
Hierarchies.

#### Hierarchy Implementing Components

As mentioned above, `MscmpCoreHierarchy` doesn't store or define the actual
final data to which the Hierarchy is applied.  This is the responsibility of
other, specialized Components which conform to `MscmpCoreHierarchy`
implementation expectations.
