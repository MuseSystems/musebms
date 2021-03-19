import Config

config :msbms, Msbms.Repo, [
  database: "msbms_#{Mix.env}",
  username: "msbms_installer",
  password: "msbms_pass",
  hostname: "localhost"
]

config :logger,
  backends: [:console],
  level: :warn,
  compile_time_purge_level: :info
