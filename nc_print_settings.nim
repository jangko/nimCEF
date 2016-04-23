import cef/cef_print_settings_api, nc_util, nc_types

# Structure representing print settings.
type
  NCPrintSettings* = ptr cef_print_settings
  
# Returns true (1) if this object is valid. Do not call any other functions
# if this function returns false (0).
proc IsValid*(self: NCPrintSettings): bool =
  result = self.is_valid(self) == 1.cint

# Returns true (1) if the values of this object are read-only. Some APIs may
# expose read-only objects.
proc IsReadOnly*(self: NCPrintSettings): bool =
  result = self.is_read_only(self) == 1.cint

# Returns a writable copy of this object.
proc Copy*(self: NCPrintSettings): NCPrintSettings =
  result = self.copy(self)

# Set the page orientation.
proc SetOrientation*(self: NCPrintSettings, landscape: bool) =
  self.set_orientation(self, landscape.cint)

# Returns true (1) if the orientation is landscape.
proc IsLandscape*(self: NCPrintSettings): bool =
  result = self.is_landscape(self) == 1.cint

# Set the printer printable area in device units. Some platforms already
# provide flipped area. Set |landscape_needs_flip| to false (0) on those
# platforms to avoid double flipping.
proc set_printer_printable_area*(self: NCPrintSettings,
  physical_size_device_units: ptr cef_size,
  printable_area_device_units: ptr cef_rect,
  landscape_needs_flip: bool) =
  self.set_printer_printable_area(self, physical_size_device_units,
    printable_area_device_units, landscape_needs_flip.cint)

# Set the device name.
proc SetDeviceName*(self: NCPrintSettings, name: string) =
  let cname = to_cef(name)
  self.set_device_name(self, cname)
  cef_string_userfree_free(cname)

# Get the device name.
# The resulting string must be freed by calling string_free().
proc GetDeviceName*(self: NCPrintSettings): string =
  result = to_nim(self.get_device_name(self))

# Set the DPI (dots per inch).
proc SetDpi*(self: NCPrintSettings, dpi: int) =
  self.set_dpi(self, dpi.cint)

# Get the DPI (dots per inch).
proc GetDpi*(self: NCPrintSettings): int =
  result = self.get_dpi(self).int

# Set the page ranges.
proc SetPageRanges*(self: NCPrintSettings, ranges: seq[cef_page_range]) =
  self.set_page_ranges(self, ranges.len.csize, ranges[0].unsafeAddr)

# Returns the number of page ranges that currently exist.
proc GetPageRangesCount*(self: NCPrintSettings): int =
  result = self.get_page_ranges_count(self).int

# Retrieve the page ranges.
proc GetPageRanges*(self: NCPrintSettings): seq[cef_page_range] =
  var count = self.GetPageRangesCount().csize
  result = newSeq[cef_page_range](count.int)
  self.get_page_ranges(self, count, result[0].addr)

# Set whether only the selection will be printed.
proc SetSelectionOnly*(self: NCPrintSettings, selection_only: bool) =
  self.set_selection_only(self, selection_only.cint)

# Returns true (1) if only the selection will be printed.
proc IsSelectionOnly*(self: NCPrintSettings): bool =
  result = self.is_selection_only(self) == 1.cint

# Set whether pages will be collated.
proc SetCollate*(self: NCPrintSettings, collate: bool) =
  self.set_collate(self, collate.cint)

# Returns true (1) if pages will be collated.
proc WillCollate*(self: NCPrintSettings): bool =
  result = self.will_collate(self) == 1.cint

# Set the color model.
proc SetColorModel*(self: NCPrintSettings, model: cef_color_model) =
  self.set_color_model(self, model)

# Get the color model.
proc GetColorModel*(self: NCPrintSettings): cef_color_model =
  result = self.get_color_model(self)

# Set the number of copies.
proc SetCopies*(self: NCPrintSettings, copies: int) =
  self.set_copies(self, copies.cint)

# Get the number of copies.
proc GetCopies*(self: NCPrintSettings): int =
  result = self.get_copies(self).int

# Set the duplex mode.
proc SetDuplexMode*(self: NCPrintSettings, mode: cef_duplex_mode) =
  self.set_duplex_mode(self, mode)

# Get the duplex mode.
proc GetDuplexMode*(self: NCPrintSettings): cef_duplex_mode =
  result = self.get_duplex_mode(self)

# Create a new cef_print_settings_t object.
proc NCPrintSettingsCreate*(): NCPrintSettings =
  result = cef_print_settings_create()