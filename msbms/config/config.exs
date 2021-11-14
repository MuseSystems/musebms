import Config

config :msbms,
  ecto_repos: [Msbms.Repo],
  system_db_name: :msbms_global,
  system_db_login: "msbms_sys_dba",
  db_owner: "msbms_##dbindent##_owner",
  db_app_user: "msbms_##dbindent##_app_user",
  db_app_admin: "msbms_##dbindent##_app_admin",
  db_api_user: "msbms_##dbindent##_api_user",
  db_api_admin: "msbms_##dbindent##_api_admin"


if Mix.env == :dev do
  config :mix_test_watch,
    setup_tasks: ["ecto.reset"],
    ansi_enabled: :ignore,
    clear: true
end

import_config "#{Mix.env}.exs"
