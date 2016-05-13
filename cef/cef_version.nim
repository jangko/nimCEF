include cef/cef_import

const
  CEF_VERSION*       = "3.2623.1395.g3034273"
  CEF_VERSION_MAJOR* = 3
  CEF_COMMIT_NUMBER* = 1395
  CEF_COMMIT_HASH*   = "3034273cb99755b2da07955b1b87ae9c2d035244"
  COPYRIGHT_YEAR*    = 2016

  CHROME_VERSION_MAJOR* = 49
  CHROME_VERSION_MINOR* = 0
  CHROME_VERSION_BUILD* = 2623
  CHROME_VERSION_PATCH* = 87

  # The API hash is created by analyzing CEF header files for C API type
  # definitions. The hash value will change when header files are modified
  # in a way that may cause binary incompatibility with other builds. The
  # universal hash value will change if any platform is affected whereas the
  # platform hash values will change only if that particular platform is
  # affected.
  CEF_API_HASH_UNIVERSAL* = "32c1d3523da124f2dea7b80b92c53c4d4a463c65"


when defined(windows):
  const
    CEF_API_HASH_PLATFORM* = "64b27477b82b44b51ce817522f744fca6768cbbb"
elif defined(MACOSX):
  const
    CEF_API_HASH_PLATFORM* = "e3b9c36454ae5ae4fb3509e17fb6a7d2877c847d"
elif defined(UNIX):
  const
    CEF_API_HASH_PLATFORM* = "87a195efc055fb9f39c84f5ce8199cc8766290e3"

# Returns CEF version information for the libcef library. The |entry|
# parameter describes which version component will be returned:
# 0 - CEF_VERSION_MAJOR
# 1 - CEF_COMMIT_NUMBER
# 2 - CHROME_VERSION_MAJOR
# 3 - CHROME_VERSION_MINOR
# 4 - CHROME_VERSION_BUILD
# 5 - CHROME_VERSION_PATCH

proc cef_version_info*(entry: cint): cint {.cef_import.}

# Returns CEF API hashes for the libcef library. The returned string is owned
# by the library and should not be freed. The |entry| parameter describes which
# hash value will be returned:
# 0 - CEF_API_HASH_PLATFORM
# 1 - CEF_API_HASH_UNIVERSAL
# 2 - CEF_COMMIT_HASH
proc cef_api_hash*(entry: cint): cstring {.cef_import.}