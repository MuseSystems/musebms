# MscmpSystSettings - User Configuration Management

<!-- MDOC !-->

A user options configuration management service.

The Settings Service provides caching and management functions for user
configurable options which govern how the application operates.  Multiple
Settings Service instances may be in operation depending on the needs of the
application; for example, in the case of multi-tenancy, each tenant will have
its own instance of the Setting Service running since each tenant's needs of
the application may unique.

On startup, the Settings Service creates an in memory cache and populates the
cache from the database.  Inquiries for settings are then served from the
cache rather than the database as needed.  Operations which change the
Settings data are written to the database and then updated in the cache.

Settings maintained by this service may be changed by users at any time while
the application is running.  Therefore, any logic depending on the Settings
from this service should be written as to be insensitive to such changes.
Logic should avoid multiple retrievals of the same setting during any one
transaction.
