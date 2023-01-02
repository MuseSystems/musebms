# MscmpSystMcpPerms - MCP Permission Implementation

Implements `MscmpSystPerms` related functionality for the `MssubMcp` subsystem.

The only public API provided by this module are the selector structs which are
used to identify the user context of various Permission related actions.  The
currently defined structs are:

  * `t:MscmpSystMcpPerms.Types.AccessAccountPermsSelector/0`

These structs implement the `MscmpSystPerms.Protocol` and are usable via the
Permissions Protocol API at `MscmpSystPerms`.

For more complete information about Permissions, see the `MscmpSystPerms`
component documentation.
