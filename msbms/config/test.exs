import Config
config :logger,
  backends: [:console],
  level: :warn,
  compile_time_purge_level: :info
