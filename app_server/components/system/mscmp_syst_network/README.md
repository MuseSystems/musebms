# MscmpSystNetwork - Simple IP Address Utility Library

<!-- MDOC !-->

Simple IP address handling and convenience functionality.

IP addresses in Erlang, and by extension Elixir, are expressed as tuples with an element reserved
for each segment of the IP address.  This works well enough, but departs from the standard CIDR
notation used by most professionals.  In fact, the Erlang/Elixir standard library for dealing with
IP addresses only deals with addresses and sockets; excluded are representations or utilities for
dealing with sub-nets.

This Component aims to make it simpler to work with IP addresses, allowing for CIDR notation
parsing and for the ability to recognize sub-nets.

## Prior Work

The `MscmpSystNetwork` library was inspired by and is a re-working of Lambda, Inc.'s' and Isaac
Yonemoto's [`net_address`](https://github.com/ityonemo/net_address) Elixir library.  The Muse
Systems  Business Management System originally used the `net_address` library, but the library
appears to no longer be maintained and so is being replaced by `MscmpSystNetwork` in the MuseBMS
project. `MscmpSystNetwork` does use some code from `net_address`.  `MscmpSystNetwork` offers
significantly less functionality than `net_address` as much of that library's functionality is not
needed in the MuseBMS.

This library is also influenced by Bryan Weber's [`inet_cidr`](https://github.com/Cobenian/inet_cidr)
Elixir library, though to a much lesser extent than `net_address`.

In the end, much of the heavy lifting is done by the Erlang [`:inet`](https://www.erlang.org/doc/man/inet.html)
library.
