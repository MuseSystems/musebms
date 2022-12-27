cd ~/source/products/musebms
cd app_server/components/system/mscmp_syst_error
rm -Rf _build; rm -Rf deps
mix deps.clean --all; mix deps.update --all; mix deps.get
cd ../../../../
cd app_server/components/system/mscmp_syst_utils
rm -Rf _build; rm -Rf deps
mix deps.clean --all; mix deps.update --all; mix deps.get
cd ../../../../
cd app_server/components/system/mscmp_syst_options
rm -Rf _build; rm -Rf deps
mix deps.clean --all; mix deps.update --all; mix deps.get
cd ../../../../
cd app_server/components/system/mscmp_syst_limiter
rm -Rf _build; rm -Rf deps
mix deps.clean --all; mix deps.update --all; mix deps.get
cd ../../../../
cd app_server/components/system/mscmp_syst_db
rm -Rf _build; rm -Rf deps
mix deps.clean --all; mix deps.update --all; mix deps.get
cd ../../../../
cd app_server/components/system/mscmp_syst_settings
rm -Rf _build; rm -Rf deps
mix deps.clean --all; mix deps.update --all; mix deps.get
cd ../../../../
cd app_server/components/system/mscmp_syst_enums
rm -Rf _build; rm -Rf deps
mix deps.clean --all; mix deps.update --all; mix deps.get
cd ../../../../
cd app_server/components/system/mscmp_syst_perms
rm -Rf _build; rm -Rf deps
mix deps.clean --all; mix deps.update --all; mix deps.get
cd ../../../../
cd app_server/components/system/mscmp_syst_instance
rm -Rf _build; rm -Rf deps
mix deps.clean --all; mix deps.update --all; mix deps.get
cd ../../../../
cd app_server/components/system/mscmp_syst_authn
rm -Rf _build; rm -Rf deps
mix deps.clean --all; mix deps.update --all; mix deps.get
cd ../../../../
cd app_server/subsystems/mssub_mcp
rm -Rf _build; rm -Rf deps
mix deps.clean --all; mix deps.update --all; mix deps.get
cd ../../../
cd app_server/subsystems/mssub_bms
rm -Rf _build; rm -Rf deps
mix deps.clean --all; mix deps.update --all; mix deps.get
cd ../../../
cd app_server/platform/msapp_platform
rm -Rf _build; rm -Rf deps
mix deps.clean --all; mix deps.update --all; mix deps.get
cd ~/source/products/musebms

################################################################################


cd ~/source/products/musebms
cd app_server/components/system/mscmp_syst_error
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; MIX_ENV=test mix compile; MIX_ENV=dev mix compile; mix dialyzer.clean; mix dialyzer --plt
cd ../../../../
cd app_server/components/system/mscmp_syst_utils
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; MIX_ENV=test mix compile; MIX_ENV=dev mix compile; mix dialyzer.clean; mix dialyzer --plt
cd ../../../../
cd app_server/components/system/mscmp_syst_options
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; MIX_ENV=test mix compile; MIX_ENV=dev mix compile; mix dialyzer.clean; mix dialyzer --plt
cd ../../../../
cd app_server/components/system/mscmp_syst_limiter
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; MIX_ENV=test mix compile; MIX_ENV=dev mix compile; mix dialyzer.clean; mix dialyzer --plt
cd ../../../../
cd app_server/components/system/mscmp_syst_db
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; MIX_ENV=test mix compile; MIX_ENV=dev mix compile; mix dialyzer.clean; mix dialyzer --plt
cd ../../../../
cd app_server/components/system/mscmp_syst_settings
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; MIX_ENV=test mix compile; MIX_ENV=dev mix compile; mix dialyzer.clean; mix dialyzer --plt
cd ../../../../
cd app_server/components/system/mscmp_syst_enums
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; MIX_ENV=test mix compile; MIX_ENV=dev mix compile; mix dialyzer.clean; mix dialyzer --plt
cd ../../../../
cd app_server/components/system/mscmp_syst_perms
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; MIX_ENV=test mix compile; MIX_ENV=dev mix compile; mix dialyzer.clean; mix dialyzer --plt
cd ../../../../
cd app_server/components/system/mscmp_syst_instance
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; MIX_ENV=test mix compile; MIX_ENV=dev mix compile; mix dialyzer.clean; mix dialyzer --plt
cd ../../../../
cd app_server/components/system/mscmp_syst_authn
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; MIX_ENV=test mix compile; MIX_ENV=dev mix compile; mix dialyzer.clean; mix dialyzer --plt
cd ../../../../
cd app_server/subsystems/mssub_mcp
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; MIX_ENV=test mix compile; MIX_ENV=dev mix compile; mix dialyzer.clean; mix dialyzer --plt
cd ../../../
cd app_server/subsystems/mssub_bms
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; MIX_ENV=test mix compile; MIX_ENV=dev mix compile; mix dialyzer.clean; mix dialyzer --plt
cd ../../../
cd app_server/platform/msapp_platform
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; MIX_ENV=test mix compile; MIX_ENV=dev mix compile; mix dialyzer.clean; mix dialyzer --plt
cd ~/source/products/musebms

===========================

cd ~/source/products/musebms
cd app_server/components/system/mscmp_syst_error
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.get; MIX_ENV=test mix compile; mix dialyzer.clean; mix dialyzer --plt &
cd ../../../../
cd app_server/components/system/mscmp_syst_utils
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.get; MIX_ENV=test mix compile; mix dialyzer.clean; mix dialyzer --plt &
cd ../../../../
cd app_server/components/system/mscmp_syst_options
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.get; MIX_ENV=test mix compile; mix dialyzer.clean; mix dialyzer --plt &
cd ../../../../
cd app_server/components/system/mscmp_syst_limiter
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.get; MIX_ENV=test mix compile; mix dialyzer.clean; mix dialyzer --plt &
cd ../../../../
cd app_server/components/system/mscmp_syst_db
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.get; MIX_ENV=test mix compile; mix dialyzer.clean; mix dialyzer --plt &
cd ../../../../
cd app_server/components/system/mscmp_syst_settings
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.get; MIX_ENV=test mix compile; mix dialyzer.clean; mix dialyzer --plt &
cd ../../../../
cd app_server/components/system/mscmp_syst_enums
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.get; MIX_ENV=test mix compile; mix dialyzer.clean; mix dialyzer --plt &
cd ../../../../
cd app_server/components/system/mscmp_syst_perms
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.get; MIX_ENV=test mix compile; mix dialyzer.clean; mix dialyzer --plt &
cd ../../../../
cd app_server/components/system/mscmp_syst_instance
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.get; MIX_ENV=test mix compile; mix dialyzer.clean; mix dialyzer --plt &
cd ../../../../
cd app_server/components/system/mscmp_syst_authn
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.get; MIX_ENV=test mix compile; mix dialyzer.clean; mix dialyzer --plt &
cd ../../../../
cd app_server/subsystems/mssub_mcp
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.get; MIX_ENV=test mix compile; mix dialyzer.clean; mix dialyzer --plt &
cd ../../../
cd app_server/subsystems/mssub_bms
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.get; MIX_ENV=test mix compile; mix dialyzer.clean; mix dialyzer --plt &
cd ../../../
cd app_server/platform/msapp_platform
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.get; MIX_ENV=test mix compile; mix dialyzer.clean; mix dialyzer --plt &
cd ~/source/products/musebms

=============================


cd ~/source/products/musebms
cd app_server/components/system/mscmp_syst_error
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; MIX_ENV=test mix compile
cd ../../../../
cd app_server/components/system/mscmp_syst_utils
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; MIX_ENV=test mix compile
cd ../../../../
cd app_server/components/system/mscmp_syst_options
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; MIX_ENV=test mix compile
cd ../../../../
cd app_server/components/system/mscmp_syst_limiter
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; MIX_ENV=test mix compile
cd ../../../../
cd app_server/components/system/mscmp_syst_db
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; MIX_ENV=test mix compile
cd ../../../../
cd app_server/components/system/mscmp_syst_settings
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; MIX_ENV=test mix compile
cd ../../../../
cd app_server/components/system/mscmp_syst_enums
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; MIX_ENV=test mix compile
cd ../../../../
cd app_server/components/system/mscmp_syst_perms
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; MIX_ENV=test mix compile
cd ../../../../
cd app_server/components/system/mscmp_syst_instance
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; MIX_ENV=test mix compile
cd ../../../../
cd app_server/components/system/mscmp_syst_authn
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; MIX_ENV=test mix compile
cd ../../../../
cd app_server/subsystems/mssub_mcp
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; MIX_ENV=test mix compile
cd ../../../
cd app_server/subsystems/mssub_bms
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; MIX_ENV=test mix compile
cd ../../../
cd app_server/platform/msapp_platform
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; MIX_ENV=test mix compile
cd ~/source/products/musebms
cd app_server/components/system/mscmp_syst_error
mix dialyzer.clean; mix dialyzer --plt
cd ../../../../
cd app_server/components/system/mscmp_syst_utils
mix dialyzer.clean; mix dialyzer --plt
cd ../../../../
cd app_server/components/system/mscmp_syst_options
mix dialyzer.clean; mix dialyzer --plt
cd ../../../../
cd app_server/components/system/mscmp_syst_limiter
mix dialyzer.clean; mix dialyzer --plt
cd ../../../../
cd app_server/components/system/mscmp_syst_db
mix dialyzer.clean; mix dialyzer --plt
cd ../../../../
cd app_server/components/system/mscmp_syst_settings
mix dialyzer.clean; mix dialyzer --plt
cd ../../../../
cd app_server/components/system/mscmp_syst_enums
mix dialyzer.clean; mix dialyzer --plt
cd ../../../../
cd app_server/components/system/mscmp_syst_perms
mix dialyzer.clean; mix dialyzer --plt
cd ../../../../
cd app_server/components/system/mscmp_syst_instance
mix dialyzer.clean; mix dialyzer --plt
cd ../../../../
cd app_server/components/system/mscmp_syst_authn
mix dialyzer.clean; mix dialyzer --plt
cd ../../../../
cd app_server/subsystems/mssub_mcp
mix dialyzer.clean; mix dialyzer --plt
cd ../../../
cd app_server/subsystems/mssub_bms
mix dialyzer.clean; mix dialyzer --plt
cd ../../../
cd app_server/platform/msapp_platform
mix dialyzer.clean; mix dialyzer --plt
cd ~/source/products/musebms

===========================

cd ~/source/products/musebms
cd app_server/components/system/mscmp_syst_error
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.get; MIX_ENV=test mix compile; mix test --trace
cd ../../../../
cd app_server/components/system/mscmp_syst_utils
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.get; MIX_ENV=test mix compile; mix test --trace
cd ../../../../
cd app_server/components/system/mscmp_syst_options
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.get; MIX_ENV=test mix compile; mix test --trace
cd ../../../../
cd app_server/components/system/mscmp_syst_limiter
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.get; MIX_ENV=test mix compile; mix test --trace
cd ../../../../
cd app_server/components/system/mscmp_syst_db
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.get; MIX_ENV=test mix compile; mix test --trace
cd ../../../../
cd app_server/components/system/mscmp_syst_settings
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.get; MIX_ENV=test mix compile; mix test --trace
cd ../../../../
cd app_server/components/system/mscmp_syst_enums
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.get; MIX_ENV=test mix compile; mix test --trace
cd ../../../../
cd app_server/components/system/mscmp_syst_perms
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.get; MIX_ENV=test mix compile; mix test --trace
cd ../../../../
cd app_server/components/system/mscmp_syst_instance
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.get; MIX_ENV=test mix compile; mix test --trace
cd ../../../../
cd app_server/components/system/mscmp_syst_authn
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.get; MIX_ENV=test mix compile; mix test --trace
cd ../../../../
cd app_server/subsystems/mssub_mcp
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.get; MIX_ENV=test mix compile; mix test --trace
cd ../../../
cd app_server/subsystems/mssub_bms
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.get; MIX_ENV=test mix compile; mix test --trace
cd ../../../
cd app_server/platform/msapp_platform
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.get; MIX_ENV=test mix compile; mix test --trace
cd ~/source/products/musebms

=============================

cd ~/source/products/musebms
cd app_server/components/system/mscmp_syst_error
mix credo --strict; mix dialyzer
cd ../../../../
cd app_server/components/system/mscmp_syst_utils
mix credo --strict; mix dialyzer
cd ../../../../
cd app_server/components/system/mscmp_syst_options
mix credo --strict; mix dialyzer
cd ../../../../
cd app_server/components/system/mscmp_syst_limiter
mix credo --strict; mix dialyzer
cd ../../../../
cd app_server/components/system/mscmp_syst_db
mix credo --strict; mix dialyzer
cd ../../../../
cd app_server/components/system/mscmp_syst_settings
mix credo --strict; mix dialyzer
cd ../../../../
cd app_server/components/system/mscmp_syst_enums
mix credo --strict; mix dialyzer
cd ../../../../
cd app_server/components/system/mscmp_syst_perms
mix credo --strict; mix dialyzer
cd ../../../../
cd app_server/components/system/mscmp_syst_instance
mix credo --strict; mix dialyzer
cd ../../../../
cd app_server/components/system/mscmp_syst_authn
mix credo --strict; mix dialyzer
cd ../../../../
cd app_server/subsystems/mssub_mcp
mix credo --strict; mix dialyzer
cd ../../../
cd app_server/subsystems/mssub_bms
mix credo --strict; mix dialyzer
cd ../../../
cd app_server/platform/msapp_platform
mix credo --strict; mix dialyzer
cd ~/source/products/musebms
