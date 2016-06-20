include cef_import

const
  CEF_VERSION*       = "3.2704.1427.g95055fe"
  CEF_VERSION_MAJOR* = 3
  CEF_COMMIT_NUMBER* = 1427
  CEF_COMMIT_HASH*   = "95055fe5c355a899dbd6f4fca3f6bae68f80055b"
  COPYRIGHT_YEAR*    = 2016

  CHROME_VERSION_MAJOR* = 51
  CHROME_VERSION_MINOR* = 0
  CHROME_VERSION_BUILD* = 2704
  CHROME_VERSION_PATCH* = 84

  # The API hash is created by analyzing CEF header files for C API type
  # definitions. The hash value will change when header files are modified
  # in a way that may cause binary incompatibility with other builds. The
  # universal hash value will change if any platform is affected whereas the
  # platform hash values will change only if that particular platform is
  # affected.
  CEF_API_HASH_UNIVERSAL* = "a4358963bc66adefedbf3008a83007e89afffab9"


when defined(windows):
  const
    CEF_API_HASH_PLATFORM* = "770131916655f914b4659d82ef08993bf9cfdc22"
elif defined(MACOSX):
  const
    CEF_API_HASH_PLATFORM* = "95517cba92239cc69c4267a649c6dad0781f245c"
elif defined(UNIX):
  const
    CEF_API_HASH_PLATFORM* = "5963da3614d469320c9cc726ce7d838280132c26"

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