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
# MsbmsSystUtils
#

rm -Rf documentation/technical/app_server/msbms_syst_utils
mkdir -p documentation/technical/app_server/msbms_syst_utils
cd components/system/msbms_syst_utils
mix docs
cd ../../../

#
# MsbmsSystError
#

rm -Rf documentation/technical/app_server/msbms_syst_error
mkdir -p documentation/technical/app_server/msbms_syst_error
cd components/system/msbms_syst_error
mix docs
cd ../../../

#
# MsbmsSystDatastore
#

rm -Rf documentation/technical/app_server/msbms_syst_datastore
mkdir -p documentation/technical/app_server/msbms_syst_datastore
cd components/system/msbms_syst_datastore
mix docs
cd ../../../

#
# MsbmsSystOptions
#

rm -Rf documentation/technical/app_server/msbms_syst_options
mkdir -p documentation/technical/app_server/msbms_syst_options
cd components/system/msbms_syst_options
mix docs
cd ../../../

#
# MsbmsSystSettings
#

rm -Rf documentation/technical/app_server/msbms_syst_settings
mkdir -p documentation/technical/app_server/msbms_syst_settings
cd components/system/msbms_syst_settings
mix docs
cd ../../../

#
# MsbmsSystEnums
#

rm -Rf documentation/technical/app_server/msbms_syst_enums
mkdir -p documentation/technical/app_server/msbms_syst_enums
cd components/system/msbms_syst_enums
mix docs
cd ../../../

#
# MsbmsSystInstanceMgr
#

rm -Rf documentation/technical/app_server/msbms_syst_instance_mgr
mkdir -p documentation/technical/app_server/msbms_syst_instance_mgr
cd components/system/msbms_syst_instance_mgr
mix docs
cd ../../../

#
# MsbmsSystRateLimiter
#

rm -Rf documentation/technical/app_server/msbms_syst_rate_limiter
mkdir -p documentation/technical/app_server/msbms_syst_rate_limiter
cd components/system/msbms_syst_rate_limiter
mix docs
cd ../../../

#
# MsbmsSystAuthentication
#

rm -Rf documentation/technical/app_server/msbms_syst_authentication
mkdir -p documentation/technical/app_server/msbms_syst_authentication
cd components/system/msbms_syst_authentication
mix docs
cd ../../../

################################################################################
#
#  Database
#
################################################################################

#
# Global Database
#

# rm -Rf documentation/technical/database/global
# mkdir -p documentation/technical/database/global
# java -jar tools/build_tools/schemaspy/schemaspy-6.1.0.jar -t pgsql11 -dp tools/build_tools/schemaspy/postgresql-42.5.0.jar -db msbms_dev_global -host 127.0.0.1 -port 5432 -schemas msbms_syst,msbms_syst_data,msbms_syst_datastore,msbms_syst_priv  -u documentation -p 'documentation' -o documentation/technical/database/global

#
# Instance Database
#

# rm -Rf documentation/technical/database/instance
# mkdir -p documentation/technical/database/instance
# java -jar tools/build_tools/schemaspy/schemaspy-6.1.0.jar -t pgsql11 -dp tools/build_tools/schemaspy/postgresql-42.5.0.jar -db msbms_dev_instance -host 127.0.0.1 -port 5432 -schemas msbms_appl,msbms_appl_data,msbms_appl_priv,msbms_syst,msbms_syst_data,msbms_syst_datastore,msbms_syst_priv,msbms_user,msbms_user_data,msbms_user_priv -u documentation -p 'documentation' -o documentation/technical/database/instance
