#!/bin/bash

# This script expects to be run from the main project directory as all paths are
# relative to that starting point.

mkdir -p documentation/technical/database
mkdir -p documentation/user/TheBook
mkdir -p documentation/project

################################################################################
#
#  Application Server
#
################################################################################

#
# MscmpSystUtils
#

rm -Rf documentation/technical/app_server/mscmp_syst_utils
mkdir -p documentation/technical/app_server/mscmp_syst_utils
cd components/system/mscmp_syst_utils
mix docs
cd ../../../

#
# MscmpSystError
#

rm -Rf documentation/technical/app_server/mscmp_syst_error
mkdir -p documentation/technical/app_server/mscmp_syst_error
cd components/system/mscmp_syst_error
mix docs
cd ../../../

#
# MscmpSystDb
#

rm -Rf documentation/technical/app_server/mscmp_syst_db
mkdir -p documentation/technical/app_server/mscmp_syst_db
cd components/system/mscmp_syst_db
mix docs
cd ../../../

#
# MscmpSystOptions
#

rm -Rf documentation/technical/app_server/mscmp_syst_options
mkdir -p documentation/technical/app_server/mscmp_syst_options
cd components/system/mscmp_syst_options
mix docs
cd ../../../

#
# MscmpSystSettings
#

rm -Rf documentation/technical/app_server/mscmp_syst_settings
mkdir -p documentation/technical/app_server/mscmp_syst_settings
cd components/system/mscmp_syst_settings
mix docs
cd ../../../

#
# MscmpSystEnums
#

rm -Rf documentation/technical/app_server/mscmp_syst_enums
mkdir -p documentation/technical/app_server/mscmp_syst_enums
cd components/system/mscmp_syst_enums
mix docs
cd ../../../

#
# MscmpSystInstance
#

rm -Rf documentation/technical/app_server/mscmp_syst_instance
mkdir -p documentation/technical/app_server/mscmp_syst_instance
cd components/system/mscmp_syst_instance
mix docs
cd ../../../

#
# MscmpSystLimiter
#

rm -Rf documentation/technical/app_server/mscmp_syst_limiter
mkdir -p documentation/technical/app_server/mscmp_syst_limiter
cd components/system/mscmp_syst_limiter
mix docs
cd ../../../

#
# MscmpSystAuthn
#

rm -Rf documentation/technical/app_server/mscmp_syst_authn
mkdir -p documentation/technical/app_server/mscmp_syst_authn
cd components/system/mscmp_syst_authn
mix docs
cd ../../../

#
# MssubMcp
#

rm -Rf documentation/technical/app_server/mssub_mcp
mkdir -p documentation/technical/app_server/mssub_mcp
cd subsystems/mssub_mcp
mix docs
cd ../../

################################################################################
#
#  Database
#
################################################################################

#
# Master Control Program Database
#

# rm -Rf documentation/technical/database/mssub_mcp
# mkdir -p documentation/technical/database/mssub_mcp
# java -jar tools/build_tools/schemaspy/schemaspy-6.1.0.jar -t pgsql11 -dp tools/build_tools/schemaspy/postgresql-42.5.0.jar -db mssub_mcp -host 127.0.0.1 -port 5432 -schemas ms_syst,ms_syst_data,ms_syst_db,ms_syst_priv  -u documentation -p 'documentation' -o documentation/technical/database/mssub_mcp

#
# Muse Systems Business Management System Database
#

# rm -Rf documentation/technical/database/mssub_bms
# mkdir -p documentation/technical/database/mssub_bms
# java -jar tools/build_tools/schemaspy/schemaspy-6.1.0.jar -t pgsql11 -dp tools/build_tools/schemaspy/postgresql-42.5.0.jar -db msbms_dev -host 127.0.0.1 -port 5432 -schemas ms_appl,ms_appl_data,ms_appl_priv,ms_syst,ms_syst_data,ms_syst_db,ms_syst_priv,ms_user,ms_user_data,ms_user_priv -u documentation -p 'documentation' -o documentation/technical/database/mssub_bms
