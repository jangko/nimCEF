import cef/cef_parser_api, cef/cef_types, nc_util, nc_values

type
  NCUrlParts* = object
    # The complete URL specification.
    spec*: string
  
    # Scheme component not including the colon (e.g., "http").
    scheme*: string
  
    # User name component.
    username*: string
      
    # Password component.
    password*: string
  
    # Host component. This may be a hostname, an IPv4 address or an IPv6 literal
    # surrounded by square brackets (e.g., "[2001:db8::1]").
    host*: string
  
    # Port number component.
    port*: string
  
    # Origin contains just the scheme, host, and port from a URL. Equivalent to
    # clearing any username and password, replacing the path with a slash, and
    # clearing everything after that. This value will be empty for non-standard
    # URLs.
    origin*: string
      
    # Path component including the first slash following the host.
    path*: string
  
    # Query string component (i.e., everything following the '?').
    query*: string
    
proc cef_to_nim(cparts: ptr cef_urlparts, parts: var NCUrlParts) =
  parts.spec = $cparts.spec.addr
  parts.scheme = $cparts.scheme.addr
  parts.username = $cparts.username.addr
  parts.password = $cparts.password.addr
  parts.host = $cparts.host.addr
  parts.port = $cparts.port.addr
  parts.origin = $cparts.origin.addr
  parts.path = $cparts.path.addr
  parts.query = $cparts.query.addr
  
  cef_string_clear(cparts.spec.addr)
  cef_string_clear(cparts.scheme.addr)
  cef_string_clear(cparts.username.addr)
  cef_string_clear(cparts.password.addr)
  cef_string_clear(cparts.host.addr)
  cef_string_clear(cparts.port.addr)
  cef_string_clear(cparts.origin.addr)
  cef_string_clear(cparts.path.addr)
  cef_string_clear(cparts.query.addr)
  
# Parse the specified |url| into its component parts. Returns false *(0) if the
# URL is NULL or invalid.  
proc NCParseUrl*(url: string, parts: var NCUrlParts): bool =
  let curl = to_cef_string(url)
  var cparts: cef_urlparts
  result = cef_parse_url(curl, cparts.addr) == 1.cint
  cef_string_userfree_free(curl)
  if result: cef_to_nim(cparts.addr, parts)

proc nim_to_cef(parts: NCUrlParts, cparts: var cef_urlparts) =
  cparts.spec <= parts.spec
  cparts.scheme <= parts.scheme
  cparts.username <= parts.username
  cparts.password <= parts.password
  cparts.host <= parts.host
  cparts.port <= parts.port
  cparts.origin <= parts.origin
  cparts.path <= parts.path
  cparts.query <= parts.query
  
proc clear(cparts: var cef_urlparts) =
  cef_string_clear(cparts.spec.addr)
  cef_string_clear(cparts.scheme.addr)
  cef_string_clear(cparts.username.addr)
  cef_string_clear(cparts.password.addr)
  cef_string_clear(cparts.host.addr)
  cef_string_clear(cparts.port.addr)
  cef_string_clear(cparts.origin.addr)
  cef_string_clear(cparts.path.addr)
  cef_string_clear(cparts.query.addr)

# Creates a URL from the specified |parts|, which must contain a non-NULL spec
# or a non-NULL host and path *(at a minimum), but not both. Returns false *(0)
# if |parts| isn't initialized as described.
proc NCCreateUrl*(parts: NCUrlParts, url: var string): bool =
  var curl: cef_string
  var cparts: cef_urlparts
  nim_to_cef(parts, cparts)
  result = cef_create_url(cparts.addr, curl.addr) == 1.cint
  url = $curl.addr
  cef_string_clear(curl.addr)
  cparts.clear
  
# This is a convenience function for formatting a URL in a concise and human-
# friendly way to help users make security-related decisions *(or in other
# circumstances when people need to distinguish sites, origins, or otherwise-
# simplified URLs from each other). Internationalized domain names *(IDN) may be
# presented in Unicode if |languages| accepts the Unicode representation. The
# returned value will *(a) omit the path for standard schemes, excepting file
# and filesystem, and *(b) omit the port if it is the default for the scheme. Do
# not use this for URLs which will be parsed or sent to other applications.

# The resulting string must be freed by calling string_free*().
proc NCFormatUrlForSecurityDisplay*(origin_url, languages: string): string =
  let curl = to_cef_string(origin_url)
  let clang = to_cef_string(languages)
  result = to_nim_string(cef_format_url_for_security_display(curl, clang))
  cef_string_userfree_free(curl)
  cef_string_userfree_free(clang)

# Returns the mime type for the specified file extension or an NULL string if
# unknown.

# The resulting string must be freed by calling string_free*().
proc NCGetMimeType*(extension: string): string =
  let cext = to_Cef_string(extension)
  result = to_nim_string(cef_get_mime_type(cext))
  cef_string_userfree_free(cext)

# Get the extensions associated with the given mime type. This should be passed
# in lower case. There could be multiple extensions for a given mime type, like
# "html,htm" for "text/html", or "txt,text,html,..." for "text/*". Any existing
# elements in the provided vector will not be erased.
proc NCGetExtensionsForMimeType*(mime_type: string): seq[string] =
  let cmime = to_cef_string(mime_type)
  var clist = cef_string_list_alloc()
  cef_get_extensions_for_mime_type(cmime, clist)
  cef_string_userfree_free(cmime)
  result = to_nim_and_free(clist)

# Encodes |data| as a base64 string.
# The resulting string must be freed by calling string_free*().
proc NCBase64Encode*(data: pointer, data_size: int): string =
  result = to_nim_string(cef_base64encode(data, data_size.csize))

# Decodes the base64 encoded string |data|. The returned value will be NULL if
# the decoding fails.
proc NCBase64Decode*(data: string): string =
  let cdata = to_cef_string(data)
  var bin = cef_base64decode(cdata)
  if bin == nil: return nil
  cef_string_userfree_free(cdata)
  result = newString(bin.GetSize())
  if bin.GetData(result.cstring, result.len, 0) != result.len: doAssert(false)
  release(bin)

# Escapes characters in |text| which are unsuitable for use as a query
# parameter value. Everything except alphanumerics and -_.!~*'*() will be
# converted to "%XX". If |use_plus| is true *(1) spaces will change to "+". The
# result is basically the same as encodeURIComponent in Javacript.

# The resulting string must be freed by calling string_free*().
proc NCUriEncode*(text: string, use_plus: bool): string =
  let ctext = to_cef_string(text)
  result = to_nim_string(cef_uriencode(ctext, use_plus.cint))
  cef_string_userfree_free(ctext)

type
  # URI unescape rules passed to CefURIDecode().
  NCUriUnescapeRule* = enum
    # Don't unescape anything special, but all normal unescaping will happen.
    # This is a placeholder and can't be combined with other flags (since it's
    # just the absence of them). All other unescape rules imply "normal" in
    # addition to their special meaning. Things like escaped letters, digits,
    # and most symbols will get unescaped with this mode.
    NC_UU_NORMAL

    # Convert %20 to spaces. In some places where we're showing URLs, we may
    # want this. In places where the URL may be copied and pasted out, then
    # you wouldn't want this since it might not be interpreted in one piece
    # by other applications.
    NC_UU_SPACES

    # Unescapes various characters that will change the meaning of URLs,
    # including '%', '+', '&', '/', '#'. If we unescaped these characters, the
    # resulting URL won't be the same as the source one. This flag is used when
    # generating final output like filenames for URLs where we won't be
    # interpreting as a URL and want to do as much unescaping as possible.
    NC_UU_URL_SPECIAL_CHARS
  
    # Unescapes control characters such as %01. This INCLUDES NULLs. This is
    # used for rare cases such as data: URL decoding where the result is binary
    # data. This flag also unescapes BiDi control characters.
    # DO NOT use CONTROL_CHARS if the URL is going to be displayed in the UI
    # for security reasons.
    NC_UU_CONTROL_CHARS

    # URL queries use "+" for space. This flag controls that replacement.
    NC_UU_REPLACE_PLUS_WITH_SPACE

  NCUUR = set[NCUriUnescapeRule]
  
const
  # Don't unescape anything at all.
  NC_UU_NONE*: NCUUR = {}
  NC_UU_ALL* = {NC_UU_NORMAL, NC_UU_SPACES, NC_UU_URL_SPECIAL_CHARS, NC_UU_CONTROL_CHARS, NC_UU_REPLACE_PLUS_WITH_SPACE}

proc to_cef(rule: NCUUR): cef_uri_unescape_rule =
  var res: int = 0
  if NC_UU_NORMAL in rule: res = res or UU_NORMAL.ord
  if NC_UU_SPACES in rule: res = res or UU_SPACES.ord
  if NC_UU_URL_SPECIAL_CHARS in rule: res = res or UU_URL_SPECIAL_CHARS.ord
  if NC_UU_CONTROL_CHARS in rule: res = res or UU_CONTROL_CHARS.ord
  if NC_UU_REPLACE_PLUS_WITH_SPACE in rule: res = res or UU_REPLACE_PLUS_WITH_SPACE.ord
  result = cast[cef_uri_unescape_rule](res)
  
# Unescapes |text| and returns the result. Unescaping consists of looking for
# the exact pattern "%XX" where each X is a hex digit and converting to the
# character with the numerical value of those digits *(e.g. "i%20=%203%3b"
# unescapes to "i = 3;"). If |convert_to_utf8| is true *(1) this function will
# attempt to interpret the initial decoded result as UTF-8. If the result is
# convertable into UTF-8 it will be returned as converted. Otherwise the
# initial decoded result will be returned.  The |unescape_rule| parameter
# supports further customization the decoding process.

# The resulting string must be freed by calling string_free*().
proc NCUriDecode*(text: string, convert_to_utf8: bool, unescape_rule: NCUUR): string =
  let ctext = to_cef_string(text)
  result = to_nim_string(cef_uridecode(ctext, convert_to_utf8.cint, to_cef(unescape_rule)))
  cef_string_userfree_free(ctext)

# Parses |string| which represents a CSS color value. If |strict| is true *(1)
# strict parsing rules will be applied. Returns true *(1) on success or false
# *(0) on error. If parsing succeeds |color| will be set to the color value
# otherwise |color| will remain unchanged.
proc NCParseCssColor*(str: string, strict: int, color: var cef_color): bool =
  let cstr = to_cef_string(str)
  result = cef_parse_csscolor(cstr, strict.cint, color) == 1.cint
  cef_string_userfree_free(cstr)

type
  # Options that can be passed to CefParseJSON.
  NCJsonParserOptions* = enum
    # Parses the input strictly according to RFC 4627. See comments in Chromium's
    # base/json/json_reader.h file for known limitations/deviations from the RFC.
    NC_JSON_PARSER_RFC

    # Allows commas to exist after the last element in structures.
    NC_JSON_PARSER_ALLOW_TRAILING_COMMAS
    
  NCJPO* = set[NCJsonParserOptions]
  
proc to_cef(flags: NCJPO): cef_json_parser_options =
  var res: int = 0
  if NC_JSON_PARSER_RFC in flags: res = res or JSON_PARSER_RFC.int
  if NC_JSON_PARSER_ALLOW_TRAILING_COMMAS in flags: res = res or JSON_PARSER_ALLOW_TRAILING_COMMAS.int
  result = cast[cef_json_parser_options](res)

# Parses the specified |json_string| and returns a dictionary or list
# representation. If JSON parsing fails this function returns NULL.
proc NCParseJson*(json_string: string, options: NCJPO): NCValue =
  let cstr = to_cef_string(json_string)
  result = cef_parse_json(cstr, to_cef(options))
  cef_string_userfree_free(cstr)

# Parses the specified |json_string| and returns a dictionary or list
# representation. If JSON parsing fails this function returns NULL and
# populates |error_code_out| and |error_msg_out| with an error code and a
# formatted error message respectively.
proc NCParseJsonAndReturnError*(json_string: string, options: NCJPO,
  error_code_out: var cef_json_parser_error, error_msg_out: var string): NCValue =
  let cstr = to_cef_string(json_string)
  var cmsg: cef_string
  result = cef_parse_jsonand_return_error(cstr, to_cef(options), error_code_out, cmsg.addr)
  cef_string_userfree_free(cstr)
  error_msg_out = $cmsg.addr
  cef_string_clear(cmsg.addr)

  
type
  # Options that can be passed to  CefWriteJSON.
  NCJsonWriterOptions* = enum
    # Default behavior.
    NC_JSON_WRITER_DEFAULT
  
    # This option instructs the writer that if a Binary value is encountered,
    # the value (and key if within a dictionary) will be omitted from the
    # output, and success will be returned. Otherwise, if a binary value is
    # encountered, failure will be returned.
    NC_JSON_WRITER_OMIT_BINARY_VALUES

    # This option instructs the writer to write doubles that have no fractional
    # part as a normal integer (i.e., without using exponential notation
    # or appending a '.0') as long as the value is within the range of a
    # 64-bit cint.
    NC_JSON_WRITER_OMIT_DOUBLE_TYPE_PRESERVATION

    # Return a slightly nicer formatted json string (pads with whitespace to
    # help with readability).
    NC_JSON_WRITER_PRETTY_PRINT
  
  NCJWO* = set[NCJsonWriterOptions]
  
proc to_cef(flags: NCJWO): cef_json_writer_options =
  var res: int = 0
  if NC_JSON_WRITER_DEFAULT in flags: res = res or JSON_WRITER_DEFAULT.int
  if NC_JSON_WRITER_OMIT_BINARY_VALUES in flags: res = res or JSON_WRITER_OMIT_BINARY_VALUES.int
  if NC_JSON_WRITER_OMIT_DOUBLE_TYPE_PRESERVATION in flags: res = res or JSON_WRITER_OMIT_DOUBLE_TYPE_PRESERVATION.int
  if NC_JSON_WRITER_PRETTY_PRINT in flags: res = res or JSON_WRITER_PRETTY_PRINT.int
  result = cast[cef_json_writer_options](res)
  
# Generates a JSON string from the specified root |node| which should be a
# dictionary or list value. Returns an NULL string on failure. This function
# requires exclusive access to |node| including any underlying data.

# The resulting string must be freed by calling string_free*().
proc NCWriteJson*(node: NCValue, options: NCJWO): string =
  result = to_nim_string(cef_write_json(node, to_cef(options)))