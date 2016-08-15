include cef_import

const
  CEF_VERSION*       = "3.2743.1444.g7c94121"
  CEF_VERSION_MAJOR* = 3
  CEF_COMMIT_NUMBER* = 1444
  CEF_COMMIT_HASH*   = "7c94121cbb972b524f20893c7f4da6ca5c5c58db"
  COPYRIGHT_YEAR*    = 2016

  CHROME_VERSION_MAJOR* = 52
  CHROME_VERSION_MINOR* = 0
  CHROME_VERSION_BUILD* = 2743
  CHROME_VERSION_PATCH* = 116

  # The API hash is created by analyzing CEF header files for C API type
  # definitions. The hash value will change when header files are modified
  # in a way that may cause binary incompatibility with other builds. The
  # universal hash value will change if any platform is affected whereas the
  # platform hash values will change only if that particular platform is
  # affected.
  CEF_API_HASH_UNIVERSAL* = "23c579707919fa8c7f8d2aaf377ab5f172aebcb3"


when defined(windows):
  const
    CEF_API_HASH_PLATFORM* = "5213018a3b1b0d713242e77b640c1532ba3cea17"
elif defined(MACOSX):
  const
    CEF_API_HASH_PLATFORM* = "ff79e3c76d4203f5679b697faa4a2dffe48713d2"
elif defined(UNIX):
  const
    CEF_API_HASH_PLATFORM* = "8c848e8dcdf713deef4a2606e1c8939822391f0b"

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