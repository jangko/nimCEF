import cef_base
include cef_import

type
  # Structure used to implement a custom resource bundle structure. See
  # CefSettings for additional options related to resource bundle loading. The
  # functions of this structure may be called on multiple threads.
  cef_resource_bundle_handler* = object
    # Base structure.
    base*: cef_base

    # Called to retrieve a localized translation for the specified |string_id|.
    # To provide the translation set |string| to the translation string and
    # return true (1). To use the default translation return false (0). Include
    # cef_pack_strings.h for a listing of valid string ID values.
    get_localized_string*: proc(self: ptr cef_resource_bundle_handler, string_id: int,
      str: ptr cef_string): int {.cef_callback.}

    # Called to retrieve data for the specified scale independent |resource_id|.
    # To provide the resource data set |data| and |data_size| to the data pointer
    # and size respectively and return true (1). To use the default resource data
    # return false (0). The resource data will not be copied and must remain
    # resident in memory. Include cef_pack_resources.h for a listing of valid
    # resource ID values.
    get_data_resource*: proc(self: ptr cef_resource_bundle_handler, resource_id: int, data: ptr pointer,
      data_size: var csize): int {.cef_callback.}

    # Called to retrieve data for the specified |resource_id| nearest the scale
    # factor |scale_factor|. To provide the resource data set |data| and
    # |data_size| to the data pointer and size respectively and return true (1).
    # To use the default resource data return false (0). The resource data will
    # not be copied and must remain resident in memory. Include
    # cef_pack_resources.h for a listing of valid resource ID values.
    get_data_resource_for_scale*: proc(self: ptr cef_resource_bundle_handler, resource_id: int,
      scale_factor: cef_scale_factor, data: ptr pointer, data_size: var csize): int {.cef_callback.}
