# MscmpSystAuthn - Global User Authentication

API for the management of user authentication.

This Component provides a global method of authentication for users wishing to
use the system.  General features supported by this Component include:

  * The ability to host user accounts that are managed by specific tenants

  * The ability to host user accounts that are independent of any specific
  tenant (e.g. freelance bookkeepers)

  * Authentication rights for users to specific Application Instances

  * Use of a single user account to authenticate to Application Instances
  owned by different tenants.

  * Individual tenant controls over certain authentication controls such as
  Password Credential complexity or requiring Multi-Factor Authentication

  * The ability to establish "Network Rules" which act as a sort of firewall
  allowing or denying certain origin host IP addresses or networks the right
  to attempt authentication

  * Rate limiting of authentication attempts enforced, independently, by
  identifier and by originating host IP address

Note that this Component doesn't provide a substantial authorization
capability.  Authorization needs are left for higher level, Application
Instance functionality to fulfill.

## Concepts

Below are listed the conceptual ideas that need to be understood to use this
component effectively.  Concepts in this Component depend heavily on a number
of concepts derived from the `MscmpSystInstance` Component so familiarity
with that Component will be helpful in understanding the ideas and functioning
of this authentication component.

#### Access Accounts

An Access Account is the record type which defines a user of the system for
the purposes of authentication.  Ideally, a single Access Account is defined
for any single person in the world that will use the system.  The information
that an Access Account captures about a user is limited to only that essential
to the authentication process; this Component does not provide general
information management for the user as a person.

Access Accounts may be Owned Access Accounts or Unowned Access Accounts.
Owned Access Accounts are the more common kind of account and they are
directly managed by tenants (Owners).  Owned Access Accounts are the kinds of
accounts which are created by an employer to provide their employees access to
the system. Unowned Access Accounts are created directly by a user of the
system and exist independent of any Owner.  Unowned Access Accounts facilitate
independent contractors or freelancers which may need access a variety of
Application Instances owned by different Owners.

#### Identities

An Identity is the means by which we can identify a specific Access Account
using an identifier known to the Access Account holder.  There are different
identifiers and methods of identification depending on the specific
authentication use case being supported.

Identifiers of the same Identifier Type are unique to the Owner/Access Account
combination.  All Unowned Access Accounts are considered as being in the same
Owner group for this purpose.  This means that the Owner of an Access Account
must be known at authentication time since an identifier may be duplicated
between different Owners.

The supported basic Identity Types used for regular authentication are:

  * __Email__ - a typical interactive identification method where a user
  provides an email address as the means of identification.  An Access Account
  may define multiple Email Identities; for example, this can happen when a
  user changes email addresses and the old email address must remain valid
  prior to the new email address being validated by the Access Account holder.
  Email Identities may require validation by the Access Account holder prior
  to the email address being usable for identification purposes.  Unowned
  Access Accounts typically require validation and Owned Access Accounts
  typically will not.  All valid Email Identities use a common Password
  Credential for authenticating the identification.

  * __API Token__ - provides an identification mechanism for other programs to
  access the system on behalf of the Access Account holder.  An Access Account
  holder may define an arbitrary number of API Token Identities and typically
  should have one API Token Identity for each different program that will
  access the system.  API Token Identities require that a specific API Token
  Credential be provided at authentication time.  API Token Identity
  identifiers are usually randomly generated strings of characters.

In addition to the basic Identity Types, there are a number of special purpose
Identity Types:

  * __Account Code__ - provides a simple to use identifier which can be
  provided to third party Owners by an Access Account holder.  The use case
  here is an Access Account holder wants to access an Application Instance
  owned by a different organization than that to which the Access Account
  holder belongs.  The third party Owner must invite the Access Account holder
  to their instance and they issue the invitation to the Access Account
  identified by the provided Account Code.  This allows third party
  identification with necessarily disclosing information such as email
  addresses.  Note that there is no authentication process and no Credential
  for this Identity Type; this Identity Type exists purely for Access Account
  identification.

  * __Validation Token__ - a single use identifier which is created for the
  purpose of validating an Email Identity.  Only one Validation Token may
  exist for any one Email Identity at a time and the Email Identity may not
  already be validated.  The Validation Token Identity also requires a
  specific Validation Token Credential be provided at authentication time.
  Once a Validation Token Identity is successfully authenticated the
  associated Email Identity is immediately usable and the Validation Token
  Identity/Credential pair is deleted from the system.  Validation Token
  Identities are typically created with an expiration timestamp after which
  the Validation Token Identity may no longer be used.

  * __Recovery Token__ - a single use identifier which is created for the
  purpose of initiating Password Credential recovery.  Only a single Recovery
  Token Identity may exist for any Access Account at a time and that Access
  Account must have an existing Password Credential record which can be
  recovered.  The Recovery Token Identity must be authenticated with a
  specific Recovery Token Credential.  On successful authentication of a
  Recovery Token Identity, the Recovery Token Identity/Credential pair is
  immediately deleted from the system.  Recovery Token Identities are
  typically created with an expiration timestamp after which it may not longer
  be used.  Finally note that the existence of a Recovery Token in no way
  prevents the Password Credential from being used in authentication; it is
  expected if a recovery process is started accidentally or in attempt at a
  malicious recovery of the Password Credential, that the Recovery Identity/
  Credential will simply be ignored by the Access Account holder and allowed
  to expire.

#### Credentials

Credentials provide the means for an Access Account holder to prove that they
have correctly identified themselves: that they are who they say they are.
Credentials are the secrets which only the Access Account holder should know
or have the ability to use.

There are a variety of different Credential Types which are typically
associated with a corresponding Identity Type:

  * __Password__ - defines a password for Access Account holders to use during
  interactive authentication attempts.  Typically Password Credentials are
  used in association with Email Identities.  Only a single Password
  Credential may exist for any single Access Account at a time.  Password
  Credentials are subject to Password Rules which are described later.
  Passwords are stored in the system using salted hashes and are not directly
  recoverable; forgotten passwords must be reset through a recovery process.

  * __API Token__ - used to authenticate API Token Identities.  Each API Token
  Credential is associated with a specific API Token Identity and may only
  authenticate that Identity.  API Token Credentials are usually a system
  generated string of random characters.  API Token Credentials are stored in
  the system using salted hashes.  At Credential create time, the creating
  process is provided with the plaintext credential so that it may be
  communicated to the Access Account holder, but is thereafter unrecoverable.

  * __Validation Token__ - behaves in most ways the same as the API Token
  Credential.  They key differences are that each Validation Token Credential
  is associated with a specific Validation Token Identity and that
  authentication using the Credential is a one time event; after a successful
  authentication the Validation Token is deleted from the system.

  * __Recovery Token__ - has all of the same behavioral characteristics of the
  Validation Token Credential except its context of usage is in Password
  Credential Recovery.

>#### Note {: .neutral}
>
> When looking at Credential related code, initialization data, tests, and
> even in other documentation, you will find references to Multi-Factor
> Authentication (MFA) functionality.  There are plans to include MFA
> functionality and some work towards this goal, but that work is currently
> incomplete and deferred until much more of the product is built out.

#### Authenticators

An Authenticator is simply the combination of related Identities and
Credentials.  So, for example, an Access Account holder presenting an
Email/Password combination for authentication is presenting an Email/Password
Authenticator.  The concept isn't terribly important to this Component, but
the term does appear elsewhere in the documentation and so deserves definition.

#### Access Account/Instance Associations

While most authorization activities are outside of the scope of this
Component, one authorization exists that must be granted to an Access Account
prior to its being able to successfully authenticate.   All authentications
are performed in the context of authenticating for access to a specific
Application Instance.  Owners of that Instance must authorize an Access
Account to authenticate to their Instance prior to the authentication process
succeeding (see `MscmpSystInstance` for more on Owners and Instances).

Owned Access Accounts are typically granted access to all or specific
Instances of the Owner which owns the Access Account.  Unowned Access Accounts
are typically invited by an Owner to access a specific Instance and the
Unowned Access Account holder must first accept the invitation to access the
Instance prior to using it; the Access Account holder may also explicitly
decline such an invitation if they so choose.

Both the invitations to access and the permission to access an Instance are
known as Access Account/Instance Associations.  The various attributes of the
Association record determine if an invitation is outstanding, declined, or if
access has been granted.

#### Network Rules

Network Rules are a simple whitelist/blacklist mechanism which evaluates the
apparent origin IP address of an inbound authentication attempt and determines
if that host is allowed to attempt an authentication. Network Rules may be
defined established at the Global level (applicable to all Owners and
Instances), the Owner level, or the Application Instance level.  Each Rule
can be designated to apply to a single host, an IP network, or a simple range
of IP addresses.  When a host is seen for which no Network Rule has been
defined, a system default rule is applied which implicitly allows the
authentication attempt.

A special type of Network Rule called a Disallowed Host also exists.  A
Disallowed Host is exactly as it sounds: a specific originating IP address
which is not allowed to authenticate users to the system.  Disallowed Hosts
are checked on a Global basis and the purpose of the list is to stop hosts
determined to be behaving suspiciously from attempting authentications.
Suspicious behavior is determined using a set of (currently naive) heuristics
which are only evaluated for hosts attempting authentications under the system
default implied Network Rule.

#### Password Rules

Password Rules define the standards that constitute acceptable passwords for
use as Credentials during interactive authentication processes.  A Global
Password Rule exists which sets the minimum requirements that all passwords in
the system must meet before being accept for use.  Owners may each establish
Owner Password Rules which govern the Access Accounts that they own.  Owner
Password Rules may not reduce the stringency demanded of the Global Password
Rules, they can only increase the required stringency for their owned Access
Accounts.  If an Owner defined Password Rule does define a less stringent
standard than demanded by the Global Password Rules, the Global Password Rule
continue to be the one applied.  This evaluation is made rule by rule such
that the effective Password Rules that an Access Account holder sees may be a
mix of the more stringent combination of both the Owner and Global Password
Rules.

>#### Note {: .neutral}
>
> The term "stringency", or "weakening" which appears elsewhere in some
> documentation, must not be understood to necessarily mean a strengthening or
> weakening in security.  For example, an Owner may elect to set password
> rules which require that a password contain at least one each of lower,
> upper, number, and symbol characters.  Such a rule would be more stringent
> than the Global Password Rules default settings which have no such
> complexity requirements but would not be more secure than those default
> rules according to studies on the matter. In fact, defining rules with
> greater stringency may well result in less security than that offered by the
> default Global Password Rules.
>
> Studies which provide further insight:
>
> [Human Generated Passwords – The Impacts of Password Requirements and Presentation Styles (2015)](https://link.springer.com/chapter/10.1007/978-3-319-20376-8_8)
>
> [Practical Recommendations for Stronger, More Usable Passwords Combining Minimum-strength, Minimum-length, and Blocklist Requirements (2020)](https://www.andrew.cmu.edu/user/nicolasc/publications/Tan-CCS20.pdf)

The default Global Password Rules are largely compatible with "Authenticator
Assurance Level 1" as defined by the National Institute of Standards and
Technology's [Special Publication 800-63B](https://pages.nist.gov/800-63-3/sp800-63b.html#sec4).
For guidelines on the specific rules that may be configured, see
`t:MscmpSystAuthn.Types.password_rule_params/0`.  Note that
"Authenticator" in the NIST document context is not the same as we've defined
above.

A special additional type of Global Password Rule exists referred to as the
Disallowed Password list.  This is a list of passwords that are well known or
are known to be compromised and that, because of this, are disallowed from
usage so long as the "Disallow Compromised" rule is in effect.  Disallowed
Passwords are stored as SHA-1 hashes of the password for reasonable
obfuscation of the passwords and for compatibility with services such as those
that are available from services such as "[Have I Been Pwned?](https://haveibeenpwned.com/)".

#### Rate Limits

The system attempts to dissuade brute force hacking efforts by implementing
limits on the number of failed authentication attempts which are allowed.
There are currently two Rate Limits implemented.

The first enforces that an identifier may not be used in any more than five
consecutive failed authentication attempts in any 30 minute period.  After the
fifth failure, the identifier will immediately be prevented from participating
in any further authentication attempts for the remainder of the 30 minute
window.

The second Rate Limit is host IP based.  Any host IP address seen to have 30
consecutive authentication failures over the course of two hours is
automatically added to the Disallowed Hosts list and prevented from further
attempts to authenticate until an administrator removes the host from the
list.  This Rate Limit is only applied to host IP addresses which are only
allowed access due to the implied default Network Rule; any explicitly allowed
host IP address is exempted from this Rate Limit.

Any successful authentication event will reset the counters enforcing either
of the Rate Limits.
