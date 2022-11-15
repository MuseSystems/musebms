cd ~/source/products/musebms
cd components/system/msbms_syst_error
rm -Rf _build; rm -Rf deps
mix deps.clean --all; mix deps.update --all; mix deps.get
cd ../../../
cd components/system/msbms_syst_utils
rm -Rf _build; rm -Rf deps
mix deps.clean --all; mix deps.update --all; mix deps.get
cd ../../../
cd components/system/msbms_syst_options
rm -Rf _build; rm -Rf deps
mix deps.clean --all; mix deps.update --all; mix deps.get
cd ../../../
cd components/system/msbms_syst_datastore
rm -Rf _build; rm -Rf deps
mix deps.clean --all; mix deps.update --all; mix deps.get
cd ../../../
cd components/system/msbms_syst_settings
rm -Rf _build; rm -Rf deps
mix deps.clean --all; mix deps.update --all; mix deps.get
cd ../../../
cd components/system/msbms_syst_enums
rm -Rf _build; rm -Rf deps
mix deps.clean --all; mix deps.update --all; mix deps.get
cd ../../../
cd components/system/msbms_syst_instance_mgr
rm -Rf _build; rm -Rf deps
mix deps.clean --all; mix deps.update --all; mix deps.get
cd ../../../
cd application/msbms
rm -Rf _build; rm -Rf deps
mix deps.clean --all; mix deps.update --all; mix deps.get
cd ~/source/products/musebms

################################################################################


cd ~/source/products/musebms
cd components/system/msbms_syst_error
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; mix compile; mix dialyzer.clean; mix dialyzer --plt
cd ../../../
cd components/system/msbms_syst_utils
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; mix compile; mix dialyzer.clean; mix dialyzer --plt
cd ../../../
cd components/system/msbms_syst_options
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; mix compile; mix dialyzer.clean; mix dialyzer --plt
cd ../../../
cd components/system/msbms_syst_rate_limiter
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; mix compile; mix dialyzer.clean; mix dialyzer --plt
cd ../../../
cd components/system/msbms_syst_datastore
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; mix compile; mix dialyzer.clean; mix dialyzer --plt
cd ../../../
cd components/system/msbms_syst_settings
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; mix compile; mix dialyzer.clean; mix dialyzer --plt
cd ../../../
cd components/system/msbms_syst_enums
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; mix compile; mix dialyzer.clean; mix dialyzer --plt
cd ../../../
cd components/system/msbms_syst_instance_mgr
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; mix compile; mix dialyzer.clean; mix dialyzer --plt
cd ../../../
cd components/system/msbms_syst_authentication
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; mix compile; mix dialyzer.clean; mix dialyzer --plt
cd ../../../
cd application/msbms
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; mix compile; mix dialyzer.clean; mix dialyzer --plt
cd ~/source/products/musebms

===========================

cd ~/source/products/musebms
cd components/system/msbms_syst_error
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.get; mix compile; mix dialyzer --plt &
cd ../../../
cd components/system/msbms_syst_utils
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.get; mix compile; mix dialyzer --plt &
cd ../../../
cd components/system/msbms_syst_options
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.get; mix compile; mix dialyzer --plt &
cd ../../../
cd components/system/msbms_syst_rate_limiter
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.get; mix compile; mix dialyzer --plt &
cd ../../../
cd components/system/msbms_syst_datastore
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.get; mix compile; mix dialyzer --plt &
cd ../../../
cd components/system/msbms_syst_settings
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.get; mix compile; mix dialyzer --plt &
cd ../../../
cd components/system/msbms_syst_enums
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.get; mix compile; mix dialyzer --plt &
cd ../../../
cd components/system/msbms_syst_instance_mgr
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.get; mix compile; mix dialyzer --plt &
cd ../../../
cd application/msbms
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.get; mix compile; mix dialyzer --plt &
cd ~/source/products/musebms

=============================


cd ~/source/products/musebms
cd components/system/msbms_syst_error
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; mix compile
cd ../../../
cd components/system/msbms_syst_utils
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; mix compile
cd ../../../
cd components/system/msbms_syst_options
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; mix compile
cd ../../../
cd components/system/msbms_syst_rate_limiter
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; mix compile
cd ../../../
cd components/system/msbms_syst_datastore
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; mix compile
cd ../../../
cd components/system/msbms_syst_settings
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; mix compile
cd ../../../
cd components/system/msbms_syst_enums
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; mix compile
cd ../../../
cd components/system/msbms_syst_instance_mgr
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; mix compile
cd ../../../
cd components/system/msbms_syst_authentication
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; mix compile
cd ../../../
cd application/msbms
rm -Rf _build; rm -Rf .elixir_ls; rm -Rf deps
mix deps.clean --all; mix deps.unlock --all; mix deps.get; mix compile
cd ~/source/products/musebms
cd components/system/msbms_syst_error
mix dialyzer.clean; mix dialyzer --plt
cd ../../../
cd components/system/msbms_syst_options
mix dialyzer.clean; mix dialyzer --plt
cd ../../../
cd components/system/msbms_syst_rate_limiter
mix dialyzer.clean; mix dialyzer --plt
cd ../../../
cd components/system/msbms_syst_datastore
mix dialyzer.clean; mix dialyzer --plt
cd ../../../
cd components/system/msbms_syst_settings
mix dialyzer.clean; mix dialyzer --plt
cd ../../../
cd components/system/msbms_syst_enums
mix dialyzer.clean; mix dialyzer --plt
cd ../../../
cd components/system/msbms_syst_instance_mgr
mix dialyzer.clean; mix dialyzer --plt
cd ../../../
cd components/system/msbms_syst_authentication
mix dialyzer.clean; mix dialyzer --plt
cd ../../../
cd application/msbms
mix dialyzer.clean; mix dialyzer --plt
cd ~/source/products/musebms
