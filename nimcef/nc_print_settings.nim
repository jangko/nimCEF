import nc_util, nc_types

# Structure representing print settings.
wrapAPI(NCPrintSettings, cef_print_settings)

# Returns true (1) if this object is valid. Do not call any other functions
# if this function returns false (0).
proc IsValid*(self: NCPrintSettings): bool =
  self.wrapCall(is_valid, result)

# Returns true (1) if the values of this object are read-only. Some APIs may
# expose read-only objects.
proc IsReadOnly*(self: NCPrintSettings): bool =
  self.wrapCall(is_read_only, result)

# Returns a writable copy of this object.
proc Copy*(self: NCPrintSettings): NCPrintSettings =
  self.wrapCall(copy, result)

# Set the page orientation.
proc SetOrientation*(self: NCPrintSettings, landscape: bool) =
  self.wrapCall(set_orientation, landscape)

# Returns true (1) if the orientation is landscape.
proc IsLandscape*(self: NCPrintSettings): bool =
  self.wrapCall(is_landscape, result)

# Set the printer printable area in device units. Some platforms already
# provide flipped area. Set |landscape_needs_flip| to false (0) on those
# platforms to avoid double flipping.
proc SetPrinterPrintableArea*(self: NCPrintSettings, physical_size_device_units: NCSize,
  printable_area_device_units: NCRect, landscape_needs_flip: bool) =
  self.wrapCall(set_printer_printable_area, physical_size_device_units,
    printable_area_device_units, landscape_needs_flip)

# Set the device name.
proc SetDeviceName*(self: NCPrintSettings, name: string) =
  self.wrapCall(set_device_name, name)

# Get the device name.
proc GetDeviceName*(self: NCPrintSettings): string =
  self.wrapCall(get_device_name, result)

# Set the DPI (dots per inch).
proc SetDpi*(self: NCPrintSettings, dpi: int) =
  self.wrapCall(set_dpi, dpi)

# Get the DPI (dots per inch).
proc GetDpi*(self: NCPrintSettings): int =
  self.wrapCall(get_dpi, result)

# Set the page ranges.
proc SetPageRanges*(self: NCPrintSettings, ranges: seq[NCPageRange]) =
  self.wrapCall(set_page_ranges, ranges)

# Returns the number of page ranges that currently exist.
proc GetPageRangesCount*(self: NCPrintSettings): int =
  self.wrapCall(get_page_ranges_count, result)

# Retrieve the page ranges.
proc GetPageRanges*(self: NCPrintSettings): seq[NCPageRange] =
  var count = self.GetPageRangesCount()
  self.wrapCall(get_page_ranges, result, count)

# Set whether only the selection will be printed.
proc SetSelectionOnly*(self: NCPrintSettings, selection_only: bool) =
  self.wrapCall(set_selection_only, selection_only)

# Returns true (1) if only the selection will be printed.
proc IsSelectionOnly*(self: NCPrintSettings): bool =
  self.wrapCall(is_selection_only, result)

# Set whether pages will be collated.
proc SetCollate*(self: NCPrintSettings, collate: bool) =
  self.wrapCall(set_collate, collate)

# Returns true (1) if pages will be collated.
proc WillCollate*(self: NCPrintSettings): bool =
  self.wrapCall(will_collate, result)

# Set the color model.
proc SetColorModel*(self: NCPrintSettings, model: cef_color_model) =
  self.wrapCall(set_color_model, model)

# Get the color model.
proc GetColorModel*(self: NCPrintSettings): cef_color_model =
  self.wrapCall(get_color_model, result)

# Set the number of copies.
proc SetCopies*(self: NCPrintSettings, copies: int) =
  self.wrapCall(set_copies, copies)

# Get the number of copies.
proc GetCopies*(self: NCPrintSettings): int =
  self.wrapCall(get_copies, result)

# Set the duplex mode.
proc SetDuplexMode*(self: NCPrintSettings, mode: cef_duplex_mode) =
  self.wrapCall(set_duplex_mode, mode)

# Get the duplex mode.
proc GetDuplexMode*(self: NCPrintSettings): cef_duplex_mode =
  self.wrapCall(get_duplex_mode, result)

# Create a new cef_print_settings_t object.
proc NCPrintSettingsCreate*(): NCPrintSettings =
  wrapProc(cef_print_settings_create, result)