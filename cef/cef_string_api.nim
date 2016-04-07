include cef_import

# CEF string type definitions. Whomever allocates |str| is responsible for
# providing an appropriate |dtor| implementation that will free the string in
# the same memory space. When reusing an existing string structure make sure
# to call |dtor| for the old value before assigning new |str| and |dtor|
# values. Static strings will have a NULL |dtor| value. Using the below
# functions if you want this managed for you.
type
  wchar_t* = uint32

  cef_string_wide* = object
    str: ptr wchar_t
    length: csize
    dtor: proc(str: ptr wchar_t) {.cef_callback.}

  cef_string_utf16* = object
    str: ptr uint16
    length: csize
    dtor: proc(str: ptr uint16) {.cef_callback.}

  cef_string_utf8* = object
    str: cstring
    length: csize
    dtor: proc(str: cstring) {.cef_callback.}

# These functions set string values. If |copy| is true (1) the value will be
# copied instead of referenced. It is up to the user to properly manage
# the lifespan of references.

proc cef_string_wide_set*(src: ptr wchar_t, src_len: csize, output: ptr cef_string_wide, copy: cint): cint {.cef_import.}
proc cef_string_utf8_set*(src: cstring, src_len: csize, output: ptr cef_string_utf8, copy: cint): cint {.cef_import.}
proc cef_string_utf16_set*(src: ptr uint16, src_len: csize, output: ptr cef_string_utf16, copy: cint): cint {.cef_import.}

# Convenience macros for copying values.

template cef_string_wide_copy*(src, src_len, output): cint = cef_string_wide_set(src, src_len, output, 1)
template cef_string_utf8_copy*(src, src_len, output): cint = cef_string_utf8_set(src, src_len, output, 1)
template cef_string_utf16_copy*(src, src_len, output): cint = cef_string_utf16_set(src, src_len, output, 1)

# These functions clear string values. The structure itself is not freed.

proc cef_string_wide_clear*(str: ptr cef_string_wide) {.cef_import.}
proc cef_string_utf8_clear*(str: ptr cef_string_utf8) {.cef_import.}
proc cef_string_utf16_clear*(str: ptr cef_string_utf16) {.cef_import.}

# These functions compare two string values with the same results as strcmp().

proc cef_string_wide_cmp*(str1, str2: ptr cef_string_wide): cint {.cef_import.}
proc cef_string_utf8_cmp*(str1, str2: ptr cef_string_utf8): cint {.cef_import.}
proc cef_string_utf16_cmp*(str1, str2: ptr cef_string_utf16): cint {.cef_import.}

# These functions convert between UTF-8, -16, and -32 strings. They are
# potentially slow so unnecessary conversions should be avoided. The best
# possible result will always be written to |output| with the boolean return
# value indicating whether the conversion is 100% valid.

proc cef_string_wide_to_utf8*(src: ptr wchar_t, src_len: csize, output: ptr cef_string_utf8): cint {.cef_import.}
proc cef_string_utf8_to_wide*(src: cstring, src_len: csize, output: ptr cef_string_wide): cint {.cef_import.}
proc cef_string_wide_to_utf16*(src: ptr wchar_t, src_len: csize, output: ptr cef_string_utf16): cint {.cef_import.}
proc cef_string_utf16_to_wide*(src: ptr uint16, src_len: csize, output: ptr cef_string_wide): cint {.cef_import.}
proc cef_string_utf8_to_utf16*(src: cstring, src_len: csize, output: ptr cef_string_utf16): cint {.cef_import.}
proc cef_string_utf16_to_utf8*(src: ptr uint16, src_len: csize, output: ptr cef_string_utf8): cint {.cef_import.}

# These functions convert an ASCII string, typically a hardcoded constant, to a
# Wide/UTF16 string. Use instead of the UTF8 conversion routines if you know
# the string is ASCII.
proc cef_string_ascii_to_wide*(src: cstring, src_len: csize, output: ptr cef_string_wide): cint {.cef_import.}
proc cef_string_ascii_to_utf16*(src: cstring, src_len: csize, output: ptr cef_string_utf16): cint {.cef_import.}
                                         
# It is sometimes necessary for the system to allocate string structures with
# the expectation that the user will free them. The userfree types act as a
# hint that the user is responsible for freeing the structure.

type
  cef_string_userfree_wide* = ptr cef_string_wide
  cef_string_userfree_utf8* = ptr cef_string_utf8
  cef_string_userfree_utf16* = ptr cef_string_utf16

# These functions allocate a new string structure. They must be freed by
# calling the associated free function.

proc cef_string_userfree_wide_alloc*(): cef_string_userfree_wide {.cef_import.}
proc cef_string_userfree_utf8_alloc*(): cef_string_userfree_utf8 {.cef_import.}
proc cef_string_userfree_utf16_alloc*(): cef_string_userfree_utf16 {.cef_import.}

# These functions free the string structure allocated by the associated
# alloc function. Any string contents will first be cleared.

proc cef_string_userfree_wide_free*(str: cef_string_userfree_wide) {.cef_import.}
proc cef_string_userfree_utf8_free*(str: cef_string_userfree_utf8) {.cef_import.}
proc cef_string_userfree_utf16_free*(str: cef_string_userfree_utf16) {.cef_import.}

#use compiler switch -d:??? to select string type
#default to CEF_STRING_TYPE_UTF8

when defined(CEF_STRING_TYPE_UTF8):
  type 
    cef_string* = cef_string_utf8
    cef_char* = char
    cef_string_userfree* = cef_string_userfree_utf8

  template cef_string_set* = cef_string_utf8_set
  template cef_string_copy* = cef_string_utf8_copy
  template cef_string_clear* = cef_string_utf8_clear
  template cef_string_userfree_alloc* = cef_string_userfree_utf8_alloc
  template cef_string_userfree_free* = cef_string_userfree_utf8_free
  template cef_string_from_ascii* = cef_string_utf8_copy
  template cef_string_to_utf8* = cef_string_utf8_copy
  template cef_string_from_utf8* = cef_string_utf8_copy
  template cef_string_to_utf16* = cef_string_utf8_to_utf16
  template cef_string_from_utf16* = cef_string_utf16_to_utf8
  template cef_string_to_wide* = cef_string_utf8_to_wide
  template cef_string_from_wide* = cef_string_wide_to_utf8

elif defined(CEF_STRING_TYPE_WIDE):
  type 
    cef_string* = cef_string_wide
    cef_char* = wchar_t
    cef_string_userfree* = cef_string_userfree_wide
    
  template cef_string_set* = cef_string_wide_set
  template cef_string_copy* = cef_string_wide_copy
  template cef_string_clear* = cef_string_wide_clear
  template cef_string_userfree_alloc* = cef_string_userfree_wide_alloc
  template cef_string_userfree_free* = cef_string_userfree_wide_free
  template cef_string_from_ascii* = cef_string_ascii_to_wide
  template cef_string_to_utf8* = cef_string_wide_to_utf8
  template cef_string_from_utf8* = cef_string_utf8_to_wide
  template cef_string_to_utf16* = cef_string_wide_to_utf16
  template cef_string_from_utf16* = cef_string_utf16_to_wide
  template cef_string_to_wide* = cef_string_wide_copy
  template cef_string_from_wide* = cef_string_wide_copy
  
else:
  type 
    cef_string* = cef_string_utf16
    cef_char* = uint16
    cef_string_userfree* = cef_string_userfree_utf16
    
  template cef_string_set* = cef_string_utf16_set
  template cef_string_copy* = cef_string_utf16_copy
  template cef_string_clear* = cef_string_utf16_clear
  
  template cef_string_userfree_alloc*(): expr = 
    cef_string_userfree_utf16_alloc()
    
  template cef_string_userfree_free*(a: expr) = 
    cef_string_userfree_utf16_free(a)
    
  template cef_string_from_ascii* = cef_string_ascii_to_utf16
  template cef_string_to_utf8* = cef_string_utf16_to_utf8
  
  template cef_string_from_utf8*(a,b,c: expr): expr = 
    cef_string_utf8_to_utf16(a, b, c)
    
  template cef_string_to_utf16* = cef_string_utf16_copy
  template cef_string_from_utf16* = cef_string_utf16_copy
  template cef_string_to_wide* = cef_string_utf16_to_wide
  template cef_string_from_wide* = cef_string_wide_to_utf16