# Source File: test.exs
# Location:    musebms/app_server/platform/msplatform/config/test.exs
# Project:     Muse Systems Business Management System
#
# Copyright © Lima Buttgereit Holdings LLC d/b/a Muse Systems
# This file may include content copyrighted and licensed from third parties.
#
# See the LICENSE file in the project root for license terms and conditions.
# See the NOTICE file in the project root for copyright ownership information.
#
# muse.information@musesystems.com :: https://muse.systems

import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :msapp_mcp_web, MsappMcpWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4386],
  secret_key_base: "/htcnJB+SGWj++9Jc8bg/ufeayCmCKHj3gv2ZtJb74uaBEUIz5ULn4VB95uMOII4",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# In test we don't send emails.
config :msapp_mcp, MsappMcp.Runtime.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
