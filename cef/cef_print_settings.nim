import cef_base
include cef_import

# Structure representing print settings.
type
  cef_print_settings* = object
    base*: cef_base
  
    # Returns true (1) if this object is valid. Do not call any other functions
    # if this function returns false (0).
    is_valid*: proc(self: ptr cef_print_settings): cint {.cef_callback.}
  
    # Returns true (1) if the values of this object are read-only. Some APIs may
    # expose read-only objects.
    is_read_only*: proc(self: ptr cef_print_settings): cint {.cef_callback.}
  
    # Returns a writable copy of this object.
    copy*: proc(self: ptr cef_print_settings): ptr cef_print_settings {.cef_callback.}
  
    # Set the page orientation.
    set_orientation*: proc(self: ptr cef_print_settings, landscape: cint) {.cef_callback.}
  
    # Returns true (1) if the orientation is landscape.
    is_landscape*: proc(self: ptr cef_print_settings): cint {.cef_callback.}
  
    # Set the printer printable area in device units. Some platforms already
    # provide flipped area. Set |landscape_needs_flip| to false (0) on those
    # platforms to avoid double flipping.
    set_printer_printable_area*: proc(self: ptr cef_print_settings,
      physical_size_device_units: ptr cef_size,
      printable_area_device_units: ptr cef_rect,
      landscape_needs_flip: cint) {.cef_callback.}
  
    # Set the device name.
    set_device_name*: proc(self: ptr cef_print_settings,
      name: ptr cef_string) {.cef_callback.}
  
    # Get the device name.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_device_name*: proc(self: ptr cef_print_settings): cef_string_userfree {.cef_callback.}
  
    # Set the DPI (dots per inch).
    set_dpi*: proc(self: ptr cef_print_settings, dpi: cint) {.cef_callback.}
  
    # Get the DPI (dots per inch).
    get_dpi*: proc(self: ptr cef_print_settings): cint {.cef_callback.}
  
    # Set the page ranges.
    set_page_ranges*: proc(self: ptr cef_print_settings,
      rangesCount: csize, ranges: ptr cef_page_range) {.cef_callback.}
  
    # Returns the number of page ranges that currently exist.
    get_page_ranges_count*: proc(self: ptr cef_print_settings): csize {.cef_callback.}
  
    # Retrieve the page ranges.
    get_page_ranges*: proc(self: ptr cef_print_settings,
      rangesCount: var csize, ranges: var cef_page_range) {.cef_callback.}
  
    # Set whether only the selection will be printed.
    set_selection_only*: proc(self: ptr cef_print_settings,
      selection_only: cint) {.cef_callback.}
  
    # Returns true (1) if only the selection will be printed.
    is_selection_only*: proc(self: ptr cef_print_settings): cint {.cef_callback.}
  
    # Set whether pages will be collated.
    set_collate*: proc(self: ptr cef_print_settings, collate: cint) {.cef_callback.}
  
    # Returns true (1) if pages will be collated.
    will_collate*: proc(self: ptr cef_print_settings): cint {.cef_callback.}
  
    # Set the color model.
    set_color_model*: proc(self: ptr cef_print_settings,
      model: cef_color_model) {.cef_callback.}
  
    # Get the color model.
    get_color_model*: proc(self: ptr cef_print_settings): cef_color_model {.cef_callback.}
  
    # Set the number of copies.
    set_copies*: proc(self: ptr cef_print_settings, copies: cint) {.cef_callback.}
  
    # Get the number of copies.
    get_copies*: proc(self: ptr cef_print_settings): cint {.cef_callback.}
  
    # Set the duplex mode.
    set_duplex_mode*: proc(self: ptr cef_print_settings,
      mode: cef_duplex_mode) {.cef_callback.}
  
    # Get the duplex mode.
    get_duplex_mode*: proc(self: ptr cef_print_settings): cef_duplex_mode {.cef_callback.}

# Create a new cef_print_settings_t object.
proc cef_print_settings_create*(): ptr cef_print_settings {.cef_import.}