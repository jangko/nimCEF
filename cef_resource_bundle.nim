import cef_base
include cef_import

type
  # Structure used for retrieving resources from the resource bundle (*.pak)
  # files loaded by CEF during startup or via the cef_resource_bundle_tHandler
  # returned from cef_app_t::GetResourceBundleHandler. See CefSettings for
  # additional options related to resource bundle loading. The functions of this
  # structure may be called on any thread unless otherwise indicated.
  cef_resource_bundle* = object
    # Base structure.
    base*: cef_base

    # Returns the localized string for the specified |string_id| or an NULL
    # string if the value is not found. Include cef_pack_strings.h for a listing
    # of valid string ID values.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_localized_string*: proc(self: ptr cef_resource_bundle, string_id: int): cef_string_userfree {.cef_callback.}

    # Retrieves the contents of the specified scale independent |resource_id|. If
    # the value is found then |data| and |data_size| will be populated and this
    # function will return true (1). If the value is not found then this function
    # will return false (0). The returned |data| pointer will remain resident in
    # memory and should not be freed. Include cef_pack_resources.h for a listing
    # of valid resource ID values.
    get_data_resource*: proc(self: ptr cef_resource_bundle,
      resource_id: int, data: ptr pointer, data_size: var csize): int {.cef_callback.}
  
    # Retrieves the contents of the specified |resource_id| nearest the scale
    # factor |scale_factor|. Use a |scale_factor| value of SCALE_FACTOR_NONE for
    # scale independent resources or call GetDataResource instead. If the value
    # is found then |data| and |data_size| will be populated and this function
    # will return true (1). If the value is not found then this function will
    # return false (0). The returned |data| pointer will remain resident in
    # memory and should not be freed. Include cef_pack_resources.h for a listing
    # of valid resource ID values.
    get_data_resource_for_scale*: proc(self: ptr cef_resource_bundle, resource_id: int,
      scale_factor: cef_scale_factor, data: ptr pointer, data_size: var csize): int {.cef_callback.}

# Returns the global resource bundle instance.
proc cef_resource_bundle_get_global*(): ptr cef_resource_bundle {.cef_import.}

