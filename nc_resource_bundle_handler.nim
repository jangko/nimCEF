import nc_util, impl/nc_util_impl, cef/cef_resource_bundle_handler_api
import cef/cef_types
include cef/cef_import

# Structure used to implement a custom resource bundle structure. See
# CefSettings for additional options related to resource bundle loading. The
# functions of this structure may be called on multiple threads.
wrapCallback(NCResourceBundleHandler, cef_resource_bundle_handler):
  # Called to retrieve a localized translation for the specified |string_id|.
  # To provide the translation set |string| to the translation string and
  # return true (1). To use the default translation return false (0). Include
  # cef_pack_strings.h for a listing of valid string ID values.
  proc GetLocalizedString*(self: T, string_id: int, str: var string): bool
  
  # Called to retrieve data for the specified scale independent |resource_id|.
  # To provide the resource data set |data| and |data_size| to the data pointer
  # and size respectively and return true (1). To use the default resource data
  # return false (0). The resource data will not be copied and must remain
  # resident in memory. Include cef_pack_resources.h for a listing of valid
  # resource ID values.
  proc GetDataResource*(self: T, resource_id: int, data: var pointer, data_size: var int): bool
  
  # Called to retrieve data for the specified |resource_id| nearest the scale
  # factor |scale_factor|. To provide the resource data set |data| and
  # |data_size| to the data pointer and size respectively and return true (1).
  # To use the default resource data return false (0). The resource data will
  # not be copied and must remain resident in memory. Include
  # cef_pack_resources.h for a listing of valid resource ID values.
  proc GetDataResourceForScale*(self: T, resource_id: int,
  scale_factor: cef_scale_factor, data: var pointer, data_size: var int): bool