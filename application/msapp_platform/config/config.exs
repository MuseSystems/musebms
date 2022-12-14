# Source File: config.exs
# Location:    musebms/application/msapp_platform/config/config.exs
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

# The supported Muse Systems Application Subsystems
config :msapp_platform, MsappPlatform.StartupOptions, path: "ms_startup_options.toml"

# Configure Mnesia for MscmpSystLimiter use
config :mnesia, dir: '.mnesia'

# Configures the endpoint
config :msapp_platform, MsappPlatformWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: MsappPlatformWeb.ErrorHTML, json: MsappPlatformWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: MsappPlatform.PubSub,
  live_view: [signing_salt: "62YHV9sO"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :msapp_platform, MsappPlatform.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.41",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.1.8",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
