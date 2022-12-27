import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :msapp_platform, MsappPlatformWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "mv5iUQAraa2632jtTcUPbwNZF9sRknhlY1Z0DR5kYZ8ynTBiiF0cpzX7WK9hB+eg",
  server: false

# In test we don't send emails.
config :msapp_platform, MsappPlatform.Mailer,
  adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
