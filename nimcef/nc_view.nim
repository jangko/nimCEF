import nc_util, nc_types, cef_view_api
include cef_import

# A Layout handles the sizing of the children of a Panel according to
# implementation-specific heuristics. Methods must be called on the browser
# process UI thread unless otherwise indicated.
wrapAPI(NCLayout, cef_layout, false)

# A Layout manager that arranges child views vertically or horizontally in a
# side-by-side fashion with spacing around and between the child views. The
# child views are always sized according to their preferred size. If the host's
# bounds provide insufficient space, child views will be clamped. Excess space
# will not be distributed. Methods must be called on the browser process UI
# thread unless otherwise indicated.
wrapAPI(NCBoxLayout, cef_box_layout, false)
  
# A simple Layout that causes the associated Panel's one child to be sized to
# match the bounds of its parent. Methods must be called on the browser process
# UI thread unless otherwise indicated.
wrapAPI(NCFillLayout, cef_fill_layout, false)
  
# A View is a rectangle within the views View hierarchy. It is the base
# structure for all Views. All size and position values are in density
# independent pixels (DIP) unless otherwise indicated. Methods must be called
# on the browser process UI thread unless otherwise indicated.
wrapAPI(NCView, cef_view, false)
  
# Returns this Layout as a BoxLayout or NULL if this is not a BoxLayout.
proc AsBoxLayout*(self: NCLayout): NCBoxLayout =
  self.wrapCall(as_box_layout, result)
  
# Returns this Layout as a FillLayout or NULL if this is not a FillLayout.
proc AsFillLayout*(self: NCLayout): NCFillLayout =
  self.wrapCall(as_fill_layout, result)
  
# Returns true (1) if this Layout is valid.
proc IsValid*(self: NCLayout): bool =
  self.wrapCall(is_valid, result)
  
# Set the flex weight for the given |view|. Using the preferred size as the
# basis, free space along the main axis is distributed to views in the ratio
# of their flex weights. Similarly, if the views will overflow the parent,
# space is subtracted in these ratios. A flex of 0 means this view is not
# resized. Flex values must not be negative.
proc SetFlexForView*(self: NCBoxLayout, view: NCView, flex: int) =
  self.wrapCall(set_flex_for_view, view, flex)

# Clears the flex for the given |view|, causing it to use the default flex
# specified via cef_box_layout_tSettings.default_flex.
proc ClearFlexForView*(self: NCBoxLayout, view: NCView) =
  self.wrapCall(clear_flex_for_view, view)