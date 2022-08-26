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
