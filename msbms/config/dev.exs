import Config

config :msbms, Msbms.Repo, [
  database: "msbms_#{Mix.env}",
  username: "msbms_installer",
  password: "msbms_pass",
  hostname: "localhost",
  port: 5432
]
