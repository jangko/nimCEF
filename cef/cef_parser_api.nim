import cef_base_api, cef_value_api
include cef_import

# Parse the specified |url| into its component parts. Returns false *(0) if the
# URL is NULL or invalid.
proc cef_parse_url*(url: ptr cef_string, parts: ptr cef_urlparts): cint {.cef_import.}

# Creates a URL from the specified |parts|, which must contain a non-NULL spec
# or a non-NULL host and path *(at a minimum), but not both. Returns false *(0)
# if |parts| isn't initialized as described.
proc cef_create_url*(parts: ptr cef_urlparts, url: ptr cef_string): cint {.cef_import.}

# This is a convenience function for formatting a URL in a concise and human-
# friendly way to help users make security-related decisions *(or in other
# circumstances when people need to distinguish sites, origins, or otherwise-
# simplified URLs from each other). Internationalized domain names *(IDN) may be
# presented in Unicode if the conversion is considered safe. The returned value
# will (a) omit the path for standard schemes, excepting file and filesystem,
# and (b) omit the port if it is the default for the scheme. Do not use this
# for URLs which will be parsed or sent to other applications.

# The resulting string must be freed by calling cef_string_userfree_free*().
proc cef_format_url_for_security_display*(origin_url: ptr cef_string): cef_string_userfree {.cef_import.}

# Returns the mime type for the specified file extension or an NULL string if
# unknown.

# The resulting string must be freed by calling cef_string_userfree_free*().
proc cef_get_mime_type*(extension: ptr cef_string): cef_string_userfree {.cef_import.}

# Get the extensions associated with the given mime type. This should be passed
# in lower case. There could be multiple extensions for a given mime type, like
# "html,htm" for "text/html", or "txt,text,html,..." for "text/*". Any existing
# elements in the provided vector will not be erased.
proc cef_get_extensions_for_mime_type*(mime_type: ptr cef_string, extensions: cef_string_list) {.cef_import.}

# Encodes |data| as a base64 string.
# The resulting string must be freed by calling cef_string_userfree_free*().
proc cef_base64encode*(data: pointer, data_size: csize): cef_string_userfree {.cef_import.}

# Decodes the base64 encoded string |data|. The returned value will be NULL if
# the decoding fails.
proc cef_base64decode*(data: ptr cef_string): ptr cef_binary_value {.cef_import.}

# Escapes characters in |text| which are unsuitable for use as a query
# parameter value. Everything except alphanumerics and -_.!~*'*() will be
# converted to "%XX". If |use_plus| is true *(1) spaces will change to "+". The
# result is basically the same as encodeURIComponent in Javacript.

# The resulting string must be freed by calling cef_string_userfree_free*().
proc cef_uriencode*(text: ptr cef_string, use_plus: cint): cef_string_userfree {.cef_import.}

# Unescapes |text| and returns the result. Unescaping consists of looking for
# the exact pattern "%XX" where each X is a hex digit and converting to the
# character with the numerical value of those digits *(e.g. "i%20=%203%3b"
# unescapes to "i = 3;"). If |convert_to_utf8| is true *(1) this function will
# attempt to interpret the initial decoded result as UTF-8. If the result is
# convertable into UTF-8 it will be returned as converted. Otherwise the
# initial decoded result will be returned.  The |unescape_rule| parameter
# supports further customization the decoding process.

# The resulting string must be freed by calling cef_string_userfree_free*().
proc cef_uridecode*(text: ptr cef_string, convert_to_utf8: cint,
  unescape_rule: cef_uri_unescape_rule): cef_string_userfree {.cef_import.}

# Parses the specified |json_string| and returns a dictionary or list
# representation. If JSON parsing fails this function returns NULL.
proc cef_parse_json*(json_string: ptr cef_string,
  options: cef_json_parser_options): ptr cef_value {.cef_import.}


# Parses the specified |json_string| and returns a dictionary or list
# representation. If JSON parsing fails this function returns NULL and
# populates |error_code_out| and |error_msg_out| with an error code and a
# formatted error message respectively.
proc cef_parse_jsonand_return_error*(
  json_string: ptr cef_string, options: cef_json_parser_options,
  error_code_out: var cef_json_parser_error, error_msg_out: ptr cef_string): ptr cef_value {.cef_import.}

# Generates a JSON string from the specified root |node| which should be a
# dictionary or list value. Returns an NULL string on failure. This function
# requires exclusive access to |node| including any underlying data.

# The resulting string must be freed by calling cef_string_userfree_free*().
proc cef_write_json*(node: ptr cef_value,
  options: cef_json_writer_options): cef_string_userfree {.cef_import.}