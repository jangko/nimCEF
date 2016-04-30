import cef/cef_print_settings_api, nc_util, nc_types

# Structure representing print settings.
type
  NCPrintSettings* = ref object
    handler: ptr cef_print_settings

import impl/nc_util_impl
    
proc GetHandler*(self: NCPrintSettings): ptr cef_print_settings {.inline.} =
  result = self.handler
  
proc nc_wrap*(handler: ptr cef_print_settings): NCPrintSettings =
  new(result, nc_finalizer[NCPrintSettings])
  result.handler = handler
  add_ref(handler)
  
# Returns true (1) if this object is valid. Do not call any other functions
# if this function returns false (0).
proc IsValid*(self: NCPrintSettings): bool =
  result = self.handler.is_valid(self.handler) == 1.cint

# Returns true (1) if the values of this object are read-only. Some APIs may
# expose read-only objects.
proc IsReadOnly*(self: NCPrintSettings): bool =
  result = self.handler.is_read_only(self.handler) == 1.cint

# Returns a writable copy of this object.
proc Copy*(self: NCPrintSettings): NCPrintSettings =
  result = nc_wrap(self.handler.copy(self.handler))

# Set the page orientation.
proc SetOrientation*(self: NCPrintSettings, landscape: bool) =
  self.handler.set_orientation(self.handler, landscape.cint)

# Returns true (1) if the orientation is landscape.
proc IsLandscape*(self: NCPrintSettings): bool =
  result = self.handler.is_landscape(self.handler) == 1.cint

# Set the printer printable area in device units. Some platforms already
# provide flipped area. Set |landscape_needs_flip| to false (0) on those
# platforms to avoid double flipping.
proc set_printer_printable_area*(self: NCPrintSettings,
  physical_size_device_units: ptr cef_size,
  printable_area_device_units: ptr cef_rect,
  landscape_needs_flip: bool) =
  self.handler.set_printer_printable_area(self.handler, physical_size_device_units,
    printable_area_device_units, landscape_needs_flip.cint)

# Set the device name.
proc SetDeviceName*(self: NCPrintSettings, name: string) =
  let cname = to_cef(name)
  self.handler.set_device_name(self.handler, cname)
  nc_free(cname)

# Get the device name.
# The resulting string must be freed by calling string_free().
proc GetDeviceName*(self: NCPrintSettings): string =
  result = to_nim(self.handler.get_device_name(self.handler))

# Set the DPI (dots per inch).
proc SetDpi*(self: NCPrintSettings, dpi: int) =
  self.handler.set_dpi(self.handler, dpi.cint)

# Get the DPI (dots per inch).
proc GetDpi*(self: NCPrintSettings): int =
  result = self.handler.get_dpi(self.handler).int

# Set the page ranges.
proc SetPageRanges*(self: NCPrintSettings, ranges: seq[cef_page_range]) =
  self.handler.set_page_ranges(self.handler, ranges.len.csize, ranges[0].unsafeAddr)

# Returns the number of page ranges that currently exist.
proc GetPageRangesCount*(self: NCPrintSettings): int =
  result = self.handler.get_page_ranges_count(self.handler).int

# Retrieve the page ranges.
proc GetPageRanges*(self: NCPrintSettings): seq[cef_page_range] =
  var count = self.GetPageRangesCount().csize
  result = newSeq[cef_page_range](count.int)
  self.handler.get_page_ranges(self.handler, count, result[0].addr)

# Set whether only the selection will be printed.
proc SetSelectionOnly*(self: NCPrintSettings, selection_only: bool) =
  self.handler.set_selection_only(self.handler, selection_only.cint)

# Returns true (1) if only the selection will be printed.
proc IsSelectionOnly*(self: NCPrintSettings): bool =
  result = self.handler.is_selection_only(self.handler) == 1.cint

# Set whether pages will be collated.
proc SetCollate*(self: NCPrintSettings, collate: bool) =
  self.handler.set_collate(self.handler, collate.cint)

# Returns true (1) if pages will be collated.
proc WillCollate*(self: NCPrintSettings): bool =
  result = self.handler.will_collate(self.handler) == 1.cint

# Set the color model.
proc SetColorModel*(self: NCPrintSettings, model: cef_color_model) =
  self.handler.set_color_model(self.handler, model)

# Get the color model.
proc GetColorModel*(self: NCPrintSettings): cef_color_model =
  result = self.handler.get_color_model(self.handler)

# Set the number of copies.
proc SetCopies*(self: NCPrintSettings, copies: int) =
  self.handler.set_copies(self.handler, copies.cint)

# Get the number of copies.
proc GetCopies*(self: NCPrintSettings): int =
  result = self.handler.get_copies(self.handler).int

# Set the duplex mode.
proc SetDuplexMode*(self: NCPrintSettings, mode: cef_duplex_mode) =
  self.handler.set_duplex_mode(self.handler, mode)

# Get the duplex mode.
proc GetDuplexMode*(self: NCPrintSettings): cef_duplex_mode =
  result = self.handler.get_duplex_mode(self.handler)

# Create a new cef_print_settings_t object.
proc NCPrintSettingsCreate*(): NCPrintSettings =
  result = nc_wrap(cef_print_settings_create())