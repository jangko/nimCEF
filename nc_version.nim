import cef/cef_version

# Returns CEF version information for the libcef library. The |entry|
# parameter describes which version component will be returned:
type
  NC_VERSION_INFO_INDEX* = enum
    NC_VERSION_MAJOR
    NC_COMMIT_NUMBER
    CHROME_VERSION_MAJOR
    CHROME_VERSION_MINOR
    CHROME_VERSION_BUILD
    CHROME_VERSION_PATCH

  NC_API_HASH_INDEX* = enum
    NC_API_HASH_PLATFORM
    NC_API_HASH_UNIVERSAL
    NC_COMMIT_HASH

proc NCVersionInfo*(entry: NC_VERSION_INFO_INDEX): int =
  result = cef_version_info(entry.cint).int

# Returns CEF API hashes for the libcef library. The returned string is owned
# by the library and should not be freed. The |entry| parameter describes which
# hash value will be returned:
proc NCApiHash*(entry: NC_API_HASH_INDEX): string =
  result = $cef_api_hash(entry.cint)