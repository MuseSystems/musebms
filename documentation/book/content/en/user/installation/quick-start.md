+++
title = "Basic Installation Quick Start Guide"
linkTitle = "Quick Start"
description = "This guide will walk you through the steps to install the software in its most basic configuration.  This type of installation is suitable for demonstration purposes, implementation project team support, or very basic on-premises production application support."
draft = true

weight = 20
+++

The quick start method of installation uses a bootstrapping wizard  built into the application itself to complete most server setup steps.  The bootstrapping process will guide you through:

  1. Creating the `ms_startup_options.toml` file which the application uses for basic startup configurations and to know how to connect to database servers.

  2. Standard database roles used by the application for secure access to the database.

  3. Installing the application database programs into the database server

  4. Creating the application administrator accounts which can then be used for configuring the application for use. 

The bootstrapping wizard described in this quick start guide is optional.  Most steps can be completed manually with greater configurability.  This quick start process is well suited for quickly establishing a "sandbox environment" for demonstration or testing purposes.  The bootstrap wizard will skip any step that it detects as having been already completed, manually or otherwise.

For all but the most simplistic production environments the manual process should be used as you can achieve a more efficient and more secure installation.

## Prerequisites

Installing the Muse Systems Business Management System (Muse BMS) requires a few prerequisites to be satisfied prior to attempting the installation:

  1. A server hosting the database server software which will store the application data and database related programs.

  2. A server to host the application server software.

  3. Connectivity between the application server and the database server. 

  4. Administrative access to manage both servers and the database server software.

  {{% alert title="Note" color="warning" %}}
  While it is possible for the database software and the application software to be installed onto the same server, such a configuration is not recommended for production purposes.  

  An exception to this recommendation is when the server is running virtualization software and the database software and application software are being installed into their own virtual machines. 
  {{% /alert %}}

Not covered here is the installation of server operating system software, the database server software, or any general configuration of those components.  Correct installation and basic configuration of those components are sensitive to details of the environment into which they're being installed which cannot be anticipated here.  Please refer to the appropriate operating system and database server documentation for information on installing and configuring those components for your specific circumstances.

This document will cover any Muse BMS specific operating system or database server software configurations that might be required for the Muse BMS application to properly operate.


## Database Server Preparation

Login database roles required by the application can be created or dropped from time-to-time when performing certain regular administrative activities, such as creating a new "Instance" of the application.  To allow for the secure access of these dynamically created database roles, a special database group role is created at installation time to which the dynamically created login roles are added as members.

To configure PostgreSQL to allow the special role members access, add the following line to the `pg_hba.conf` configuration file of your PostgreSQL server.

```
#
# Muse Systems Business Management System Instance Database Role Access
#
# TYPE  DATABASE        USER            ADDRESS                 METHOD

host    all             +ms_syst_access 0.0.0.0/0               scram-sha-256
```

Once added to the `pg_hba.conf` file, the database server must be `reloaded` for the new configuration to take effect. 

{{% alert title="Note" color="warning" %}}
  * PostgreSQL applies the entries in `pg_hba.conf` in the order in which they appear in the file.  If your application sever is unable to reach the database server, it may be that an earlier `pg_hba.conf` rule is applying before the line we just added.  If this is the case, the rule above will need to be moved toward the start of the file, possibly to the first position.

  * While the configuration entry above should work across a broad spectrum of circumstances, the trade-off is that it is not as secure as it could be.  Consider using `hostssl` instead of `host` to force the connection between the application server and database server to be encrypted.  The network address above will allow any host to attempt connection to the database server, so consider using the specific IP address or network of the application server to prevent unauthorized hosts from attempting connection.

  * It is possible to use the same database server for other purposes than running Muse BMS.  Whether or not this is advisable will depend on the specific use cases being supported and the server specifications.

  * For more about `pg_hba.conf` configuration, please see the <a href="https://www.postgresql.org/docs/15/auth-pg-hba-conf.html" target="_blank">PostgreSQL server documentation</a>. 
{{% /alert %}}

## Application Server Installation

The process of installing the application server software is one largely of decompressing the release archive into the directory of choice on your application server and setting up the startup configuration for your operating system.  The
details of this process will depend on the specific operating system you are planning to use.

### Linux

[Installation instructions for Linux]

### Windows

[Installation instructions for Windows]

## Bootstrap Wizard

The bootstrap wizard guides you through the process of creating the most fundamental configurations required to operate the application.  This includes identifying database servers and creating the initial administrator user account in the application.

{{% alert title="Note" color="warning" %}}
Since the bootstrap wizard runs when there are no application user accounts with which to authenticate/authorize, anyone connecting to the application using a web browser will be permitted to perform configuration and setup steps. 

For this reason do not leave the application running when not actively performing configuration steps.  Ideally, the application network access should be restricted to only those networks used by system administrators until the bootstrapping phase has been completed. 
{{% /alert %}}

