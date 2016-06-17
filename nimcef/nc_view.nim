import nc_util, nc_types, cef_view_api, nc_image, nc_menu_model
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
wrapAPI(NCBoxLayout, cef_box_layout, false, NCLayout)

# A simple Layout that causes the associated Panel's one child to be sized to
# match the bounds of its parent. Methods must be called on the browser process
# UI thread unless otherwise indicated.
wrapAPI(NCFillLayout, cef_fill_layout, false, NCLayout)

# A View is a rectangle within the views View hierarchy. It is the base
# structure for all Views. All size and position values are in density
# independent pixels (DIP) unless otherwise indicated. Methods must be called
# on the browser process UI thread unless otherwise indicated.
wrapAPI(NCView, cef_view, false)

# A View hosting a cef_browser_t instance. Methods must be called on the
# browser process UI thread unless otherwise indicated.
wrapAPI(NCBrowserView, cef_browser_view, false, NCView)

# A View representing a button. Depending on the specific type, the button
# could be implemented by a native control or custom rendered. Methods must be
# called on the browser process UI thread unless otherwise indicated.
wrapAPI(NCButton, cef_button, false, NCView)

# A Panel is a container in the views hierarchy that can contain other Views as
# children. Methods must be called on the browser process UI thread unless
# otherwise indicated.
wrapAPI(NCPanel, cef_panel, false, NCView)

# A ScrollView will show horizontal and/or vertical scrollbars when necessary
# based on the size of the attached content view. Methods must be called on the
# browser process UI thread unless otherwise indicated.
wrapAPI(NCScrollView, cef_scroll_view, false, NCView)

# A Textfield supports editing of text. This control is custom rendered with no
# platform-specific code. Methods must be called on the browser process UI
# thread unless otherwise indicated.
wrapAPI(NCTextField, cef_textfield, false, NCView)

# A Window is a top-level Window/widget in the Views hierarchy. By default it
# will have a non-client area with title bar, icon and buttons that supports
# moving and resizing. All size and position values are in density independent
# pixels (DIP) unless otherwise indicated. Methods must be called on the
# browser process UI thread unless otherwise indicated.
wrapAPI(NCWindow, cef_window, false, NCPanel)

# LabelButton is a button with optional text and/or icon. Methods must be
# called on the browser process UI thread unless otherwise indicated.
wrapAPI(NCLabelButton, cef_label_button, false, NCButton)

# This structure typically, but not always, corresponds to a physical display
# connected to the system. A fake Display may exist on a headless system, or a
# Display may correspond to a remote, virtual display. All size and position
# values are in density independent pixels (DIP) unless otherwise indicated.
# Methods must be called on the browser process UI thread unless otherwise
# indicated.
wrapAPI(NCDisplay, cef_display, false)

# MenuButton is a button with optional text, icon and/or menu marker that shows
# a menu when clicked with the left mouse button. All size and position values
# are in density independent pixels (DIP) unless otherwise indicated. Methods
# must be called on the browser process UI thread unless otherwise indicated.
wrapAPI(NCMenuButton, cef_menu_button, false, NCLabelButton)

# Implement this structure to handle view events. The functions of this
# structure will be called on the browser process UI thread unless otherwise
# indicated.
wrapAPI(NCViewDelegate, cef_view_delegate, false)

# Returns this Layout as a BoxLayout or NULL if this is not a BoxLayout.
proc asBoxLayout*(self: NCLayout): NCBoxLayout =
  self.wrapCall(as_box_layout, result)

# Returns this Layout as a FillLayout or NULL if this is not a FillLayout.
proc asFillLayout*(self: NCLayout): NCFillLayout =
  self.wrapCall(as_fill_layout, result)

# Returns true (1) if this Layout is valid.
proc isValid*(self: NCLayout): bool =
  self.wrapCall(is_valid, result)

# Set the flex weight for the given |view|. Using the preferred size as the
# basis, free space along the main axis is distributed to views in the ratio
# of their flex weights. Similarly, if the views will overflow the parent,
# space is subtracted in these ratios. A flex of 0 means this view is not
# resized. Flex values must not be negative.
proc setFlexForView*(self: NCBoxLayout, view: NCView, flex: int) =
  self.wrapCall(set_flex_for_view, view, flex)

# Clears the flex for the given |view|, causing it to use the default flex
# specified via cef_box_layout_tSettings.default_flex.
proc clearFlexForView*(self: NCBoxLayout, view: NCView) =
  self.wrapCall(clear_flex_for_view, view)

# Returns this View as a BrowserView or NULL if this is not a BrowserView.
proc asBrowserView*(self: NCView): NCBrowserView =
  self.wrapCall(as_browser_view, result)

# Returns this View as a Button or NULL if this is not a Button.
proc asButton*(self: NCView): NCButton =
  self.wrapCall(as_button, result)

# Returns this View as a Panel or NULL if this is not a Panel.
proc asPanel*(self: NCView): NCPanel =
  self.wrapCall(as_panel, result)

# Returns this View as a ScrollView or NULL if this is not a ScrollView.
proc asScrollView*(self: NCView): NCScrollView =
  self.wrapCall(as_scroll_view, result)

# Returns this View as a Textfield or NULL if this is not a Textfield.
proc asTextField*(self: NCView): NCTextField =
  self.wrapCall(as_textfield, result)

# Returns the type of this View as a string. Used primarily for testing
# purposes.
proc getTypeString*(self: NCView): string =
  self.wrapCall(get_type_string, result)

# Returns a string representation of this View which includes the type and
# various type-specific identifying attributes. If |include_children| is true
# (1) any child Views will also be included. Used primarily for testing
# purposes.
proc toString*(self: NCView, include_children: bool): string =
  self.wrapCall(to_string, result, include_children)

# Returns true (1) if this View is valid.
proc isValid*(self: NCView): bool =
  self.wrapCall(is_valid, result)

# Returns true (1) if this View is currently attached to another View. A View
# can only be attached to one View at a time.
proc isAttached*(self: NCView): bool =
  self.wrapCall(is_attached, result)

# Returns true (1) if this View is the same as |that| View.
proc isSame*(self, that: NCView): bool =
  self.wrapCall(is_same, result, that)

# Returns the delegate associated with this View, if any.
proc getDelegate*(self: NCView): NCViewDelegate =
  self.wrapCall(get_delegate, result)

# Returns the top-level Window hosting this View, if any.
proc getWindow*(self: NCView): NCWindow =
  self.wrapCall(get_window, result)

# Returns the ID for this View.
proc getId*(self: NCView): int =
  self.wrapCall(get_id, result)

# Sets the ID for this View. ID should be unique within the subtree that you
# intend to search for it. 0 is the default ID for views.
proc setId*(self: NCView, id: int) =
  self.wrapCall(set_id, id)

# Returns the View that contains this View, if any.
proc getParentView*(self: NCView): NCView =
  self.wrapCall(get_parent_view, result)

# Recursively descends the view tree starting at this View, and returns the
# first child that it encounters with the given ID. Returns NULL if no
# matching child view is found.
proc getViewForId*(self: NCView, id: int): NCView =
  self.wrapCall(get_view_for_id, result, id)

# Sets the bounds (size and position) of this View. Position is in parent
# coordinates.
proc setBounds*(self: NCView, bounds: NCRect) =
  self.wrapCall(set_bounds, bounds)

# Returns the bounds (size and position) of this View. Position is in parent
# coordinates.
proc getBounds*(self: NCView): NCRect =
  self.wrapCall(get_bounds, result)

# Returns the bounds (size and position) of this View. Position is in screen
# coordinates.
proc getBoundsInScreen*(self: NCView): NCRect =
  self.wrapCall(get_bounds_in_screen, result)

# Sets the size of this View without changing the position.
proc setSize*(self: NCView, size: NCSize) =
  self.wrapCall(set_size, size)

# Returns the size of this View.
proc getSize*(self: NCView): NCSize =
  self.wrapCall(get_size, result)

# Sets the position of this View without changing the size. |position| is in
# parent coordinates.
proc setPosition*(self: NCView, position: NCPoint) =
  self.wrapCall(set_position, position)

# Returns the position of this View. Position is in parent coordinates.
proc getPosition*(self: NCView): NCPoint =
  self.wrapCall(get_position, result)

# Returns the size this View would like to be if enough space is available.
proc getPreferredSize*(self: NCView): NCSize =
  self.wrapCall(get_preferred_size, result)

# Size this View to its preferred size.
proc sizeToPreferredSize*(self: NCView) =
  self.wrapCall(size_to_preferred_size)

# Returns the minimum size for this View.
proc getMinimumSize*(self: NCView): NCSize =
  self.wrapCall(get_minimum_size, result)

# Returns the maximum size for this View.
proc getMaximumSize*(self: NCView): NCSize =
  self.wrapCall(get_maximum_size, result)

# Returns the height necessary to display this View with the provided width.
proc getHeightForWidth*(self: NCView, width: int): int =
  self.wrapCall(get_height_for_width, result, width)

# Indicate that this View and all parent Views require a re-layout. This
# ensures the next call to layout() will propagate to this View even if the
# bounds of parent Views do not change.
proc invalidateLayout*(self: NCView) =
  self.wrapCall(invalidate_layout)

# Sets whether this View is visible. Windows are hidden by default and other
# views are visible by default. This View and any parent views must be set as
# visible for this View to be drawn in a Window. If this View is set as
# hidden then it and any child views will not be drawn and, if any of those
# views currently have focus, then focus will also be cleared. Painting is
# scheduled as needed. If this View is a Window then calling this function is
# equivalent to calling the Window show() and hide() functions.
proc setVisible*(self: NCView, visible: bool) =
  self.wrapCall(set_visible, visible)

# Returns whether this View is visible. A view may be visible but still not
# drawn in a Window if any parent views are hidden. If this View is a Window
# then a return value of true (1) indicates that this Window is currently
# visible to the user on-screen. If this View is not a Window then call
# is_drawn() to determine whether this View and all parent views are visible
# and will be drawn.
proc isVisible*(self: NCView): bool =
  self.wrapCall(is_visible, result)

# Returns whether this View is visible and drawn in a Window. A view is drawn
# if it and all parent views are visible. If this View is a Window then
# calling this function is equivalent to calling is_visible(). Otherwise, to
# determine if the containing Window is visible to the user on-screen call
# is_visible() on the Window.
proc isDrawn*(self: NCView): bool =
  self.wrapCall(is_drawn, result)

# Set whether this View is enabled. A disabled View does not receive keyboard
# or mouse inputs. If |enabled| differs from the current value the View will
# be repainted. Also, clears focus if the focused View is disabled.
proc setEnabled*(self: NCView, enabled: bool) =
  self.wrapCall(set_enabled, enabled)

# Returns whether this View is enabled.
proc isEnabled*(self: NCView): bool =
  self.wrapCall(is_enabled, result)

# Sets whether this View is capable of taking focus. It will clear focus if
# the focused View is set to be non-focusable. This is false (0) by default
# so that a View used as a container does not get the focus.
proc setFocusable*(self: NCView, focusable: bool) =
  self.wrapCall(set_focusable, focusable)

# Returns true (1) if this View is focusable, enabled and drawn.
proc isFocusable*(self: NCView): bool =
  self.wrapCall(is_focusable, result)

# Return whether this View is focusable when the user requires full keyboard
# access, even though it may not be normally focusable.
proc isAccessibilityFocusable*(self: NCView): bool =
  self.wrapCall(is_accessibility_focusable, result)

# Request keyboard focus. If this View is focusable it will become the
# focused View.
proc requestFocus*(self: NCView) =
  self.wrapCall(request_focus)

# Sets the background color for this View.
proc setBackgroundColor*(self: NCView, color: cef_color) =
  self.wrapCall(set_background_color, color)

# Returns the background color for this View.
proc getBackgroundColor*(self: NCView): cef_color =
  self.wrapCall(get_background_color, result)

# Convert |point| from this View's coordinate system to that of the screen.
# This View must belong to a Window when calling this function. Returns true
# (1) if the conversion is successful or false (0) otherwise. Use
# cef_display_t::convert_point_to_pixels() after calling this function if
# further conversion to display-specific pixel coordinates is desired.
proc convertPointToScreen*(self: NCView, point: var NCPoint): bool =
  self.wrapCall(convert_point_to_screen, result, point)

# Convert |point| to this View's coordinate system from that of the screen.
# This View must belong to a Window when calling this function. Returns true
# (1) if the conversion is successful or false (0) otherwise. Use
# cef_display_t::convert_point_from_pixels() before calling this function if
# conversion from display-specific pixel coordinates is necessary.
proc convertPointFromScreen*(self: NCView, point: var NCPoint): bool =
  self.wrapCall(convert_point_from_screen, result, point)

# Convert |point| from this View's coordinate system to that of the Window.
# This View must belong to a Window when calling this function. Returns true
# (1) if the conversion is successful or false (0) otherwise.
proc convertPointToWindow*(self: NCView, point: var NCPoint): bool =
  self.wrapCall(convert_point_to_window, result, point)

# Convert |point| to this View's coordinate system from that of the Window.
# This View must belong to a Window when calling this function. Returns true
# (1) if the conversion is successful or false (0) otherwise.
proc convertPointFromWindow*(self: NCView, point: var NCPoint): bool =
  self.wrapCall(convert_point_from_window, result, point)

# Convert |point| from this View's coordinate system to that of |view|.
# |view| needs to be in the same Window but not necessarily the same view
# hierarchy. Returns true (1) if the conversion is successful or false (0)
# otherwise.
proc convertPointToView*(self, view: NCView, point: var NCPoint): bool =
  self.wrapCall(convert_point_to_view, result, view, point)

# Convert |point| to this View's coordinate system from that |view|. |view|
# needs to be in the same Window but not necessarily the same view hierarchy.
# Returns true (1) if the conversion is successful or false (0) otherwise.
proc convertPointFromView*(self, view: NCView, point: var NCPoint): bool =
  self.wrapCall(convert_point_from_view, result, view, point)

# Returns the cef_browser_t hosted by this BrowserView. Will return NULL if
# the browser has not yet been created or has already been destroyed.
proc getBrowser*(self: NCBrowserView): NCBrowser =
  self.wrapCall(get_browser, result)

# Returns this Button as a LabelButton or NULL if this is not a LabelButton.
proc asLabelButton*(self: NCButton): NCLabelButton =
  self.wrapCall(as_label_button, result)

# Sets the current display state of the Button.
proc setState*(self: NCButton, state: cef_button_state) =
  self.wrapCall(set_state, state)

# Returns the current display state of the Button.
proc getState*(self: NCButton): cef_button_state =
  self.wrapCall(get_state, result)

# Sets the tooltip text that will be displayed when the user hovers the mouse
# cursor over the Button.
proc setTooltipText*(self: NCButton, tooltip_text: string) =
  self.wrapCall(set_tooltip_text, tooltip_text)

# Sets the accessible name that will be exposed to assistive technology (AT).
proc setAccessibleName*(self: NCButton, name: string) =
  self.wrapCall(set_accessible_name, name)

# Returns this Panel as a Window or NULL if this is not a Window.
proc asWindow*(self: NCPanel): NCWindow =
  self.wrapCall(as_window, result)

# Set this Panel's Layout to FillLayout and return the FillLayout object.
proc setToFillLayout*(self: NCPanel): NCFillLayout =
  self.wrapCall(set_to_fill_layout, result)

# Set this Panel's Layout to BoxLayout and return the BoxLayout object.
proc setToBoxLayout*(self: NCPanel, settings: NCBoxLayoutSettings): NCBoxLayout =
  self.wrapCall(set_to_box_layout, result, settings)

# Get the Layout.
proc getLayout*(self: NCPanel): NCLayout =
  self.wrapCall(get_layout, result)

# Lay out the child Views (set their bounds based on sizing heuristics
# specific to the current Layout).
proc layout*(self: NCPanel) =
  self.wrapCall(layout)

# Add a child View.
proc addChildView*(self: NCPanel, view: NCView) =
  self.wrapCall(add_child_view, view)

# Add a child View at the specified |index|. If |index| matches the result of
# GetChildCount() then the View will be added at the end.
proc addChildViewAt*(self: NCPanel, view: NCView, index: int) =
  self.wrapCall(add_child_view_at, view, index)

# Move the child View to the specified |index|. A negative value for |index|
# will move the View to the end.
proc reorderChildView*(self: NCPanel, view: NCView, index: int) =
  self.wrapCall(reorder_child_view, view, index)

# Remove a child View. The View can then be added to another Panel.
proc removeChildView*(self: NCPanel, view: NCView) =
  self.wrapCall(remove_child_view, view)

# Remove all child Views. The removed Views will be deleted if the client
# holds no references to them.
proc removeAllChildViews*(self: NCPanel) =
  self.wrapCall(remove_all_child_views)

# Returns the number of child Views.
proc getChildViewCount*(self: NCPanel): int =
  self.wrapCall(get_child_view_count, result)

# Returns the child View at the specified |index|.
proc getChildViewAt*(self: NCPanel, index: int): NCView =
  self.wrapCall(get_child_view_at, result, index)

# Set the content View. The content View must have a specified size (e.g. via
# cef_view_t::SetBounds or cef_view_tDelegate::GetPreferredSize).
proc setContentView*(self: NCScrollView, view: NCView) =
  self.wrapCall(set_content_view, view)

# Returns the content View.
proc getContentView*(self: NCScrollView): NCView =
  self.wrapCall(get_content_view, result)

# Returns the visible region of the content View.
proc getVisibleContentRect*(self: NCScrollView): NCRect =
  self.wrapCall(get_visible_content_rect, result)

# Returns true (1) if the horizontal scrollbar is currently showing.
proc hasHorizontalScrollbar*(self: NCScrollView): bool =
  self.wrapCall(has_horizontal_scrollbar, result)

# Returns the height of the horizontal scrollbar.
proc getHorizontalScrollbarHeight*(self: NCScrollView): bool =
  self.wrapCall(get_horizontal_scrollbar_height, result)

# Returns true (1) if the vertical scrollbar is currently showing.
proc hasVerticalScrollbar*(self: NCScrollView): bool =
  self.wrapCall(has_vertical_scrollbar, result)

# Returns the width of the vertical scrollbar.
proc getVerticalScrollbarWidth*(self: NCScrollView): int =
  self.wrapCall(get_vertical_scrollbar_width, result)

# Sets whether the text will be displayed as asterisks.
proc setPasswordInput*(self: NCTextField, password_input: bool) =
  self.wrapCall(set_password_input, password_input)

# Returns true (1) if the text will be displayed as asterisks.
proc isPasswordInput*(self: NCTextField): bool =
  self.wrapCall(is_password_input, result)

# Sets whether the text will read-only.
proc setReadOnly*(self: NCTextField, read_only: bool) =
  self.wrapCall(set_read_only, read_only)

# Returns true (1) if the text is read-only.
proc isReadOnly*(self: NCTextField): bool =
  self.wrapCall(is_read_only, result)

# Returns the currently displayed text.
proc getText*(self: NCTextField): string =
  self.wrapCall(get_text, result)

# Sets the contents to |text|. The cursor will be moved to end of the text if
# the current position is outside of the text range.
proc setText*(self: NCTextField, text: string) =
  self.wrapCall(set_text, text)

# Appends |text| to the previously-existing text.
proc appendText*(self: NCTextField, text: string) =
  self.wrapCall(append_text, text)

# Inserts |text| at the current cursor position replacing any selected text.
proc insertOrReplaceText*(self: NCTextField, text: string) =
  self.wrapCall(insert_or_replace_text, text)

# Returns true (1) if there is any selected text.
proc hasSelection*(self: NCTextField): bool =
  self.wrapCall(has_selection, result)

# Returns the currently selected text.
proc getSelectedText*(self: NCTextField): string =
  self.wrapCall(get_selected_text, result)

# Selects all text. If |reversed| is true (1) the range will end at the
# logical beginning of the text; this generally shows the leading portion of
# text that overflows its display area.
proc selectAll*(self: NCTextField, reversed: bool) =
  self.wrapCall(select_all, reversed)

# Clears the text selection and sets the caret to the end.
proc clearSelection*(self: NCTextField) =
  self.wrapCall(clear_selection)

# Returns the selected logical text range.
proc getSelectedRange*(self: NCTextField): NCRange =
  self.wrapCall(get_selected_range, result)

# Selects the specified logical text range.
proc selectRange*(self: NCTextField, the_range: NCRange) =
  self.wrapCall(select_range, the_range)

# Returns the current cursor position.
proc getCursorPosition*(self: NCTextField): int =
  self.wrapCall(get_cursor_position, result)

# Sets the text color.
proc setTextColor*(self: NCTextField, color: cef_color) =
  self.wrapCall(set_text_color, color)

# Returns the text color.
proc getTextColor*(self: NCTextField): cef_color =
  self.wrapCall(get_text_color, result)

# Sets the selection text color.
proc setSelectionText_color*(self: NCTextField, color: cef_color) =
  self.wrapCall(set_selection_text_color, color)

# Returns the selection text color.
proc getSelectionTextColor*(self: NCTextField): cef_color =
  self.wrapCall(get_selection_text_color, result)

# Sets the selection background color.
proc setSelectionBackgroundColor*(self: NCTextField, color: cef_color) =
  self.wrapCall(set_selection_background_color, color)

# Returns the selection background color.
proc getSelectionBackgroundColor*(self: NCTextField): cef_color =
  self.wrapCall(get_selection_background_color, result)

# Sets the font list. The format is "<FONT_FAMILY_LIST>,[STYLES] <SIZE>",
# where: - FONT_FAMILY_LIST is a comma-separated list of font family names, -
# STYLES is an optional space-separated list of style names (case-sensitive
#   "Bold" and "Italic" are supported), and
# - SIZE is an integer font size in pixels with the suffix "px".
#
# Here are examples of valid font description strings: - "Arial, Helvetica,
# Bold Italic 14px" - "Arial, 14px"
proc setFontList*(self: NCTextField,font_list: string) =
  self.wrapCall(set_font_list, font_list)

# Applies |color| to the specified |range| without changing the default
# color. If |range| is NULL the color will be set on the complete text
# contents.
proc applyTextColor*(self: NCTextField, color: cef_color, the_range: NCRange) =
  self.wrapCall(apply_text_color, color, the_range)

# Applies |style| to the specified |range| without changing the default
# style. If |add| is true (1) the style will be added, otherwise the style
# will be removed. If |range| is NULL the style will be set on the complete
# text contents.
proc applyTextStyle*(self: NCTextField,
  style: cef_text_style, add: bool, the_range: NCRange) =
  self.wrapCall(apply_text_style, style, add, the_range)

# Returns true (1) if the action associated with the specified command id is
# enabled. See additional comments on execute_command().
proc isCommandEnabled*(self: NCTextField, command_id: int): bool =
  self.wrapCall(is_command_enabled, result, command_id)

# Performs the action associated with the specified command id. Valid values
# include IDS_APP_UNDO, IDS_APP_REDO, IDS_APP_CUT, IDS_APP_COPY,
# IDS_APP_PASTE, IDS_APP_DELETE, IDS_APP_SELECT_ALL, IDS_DELETE_* and
# IDS_MOVE_*. See include/cef_pack_strings.h for definitions.
proc executeCommand*(self: NCTextField, command_id: int): bool =
  self.wrapCall(execute_command, result, command_id)

# Clears Edit history.
proc clearEditHistory*(self: NCTextField) =
  self.wrapCall(clear_edit_history)

# Sets the placeholder text that will be displayed when the Textfield is
# NULL.
proc setPlaceholderText*(self: NCTextField, text: string) =
  self.wrapCall(set_placeholder_text, text)

# Returns the placeholder text that will be displayed when the Textfield is
# NULL.
proc getPlaceholderText*(self: NCTextField): string =
  self.wrapCall(get_placeholder_text, result)

# Sets the placeholder text color.
proc setPlaceholderTextColor*(self: NCTextField, color: cef_color) =
  self.wrapCall(set_placeholder_text_color, color)

# Returns the placeholder text color.
proc getPlaceholderTextColor*(self: NCTextField): cef_color =
  self.wrapCall(get_placeholder_text_color, result)

# Set the accessible name that will be exposed to assistive technology (AT).
proc setAccessibleName*(self: NCTextField, name: string) =
  self.wrapCall(set_accessible_name, name)

# Show the Window.
proc show*(self: NCWindow) =
  self.wrapCall(show)

# Hide the Window.
proc hide*(self: NCWindow) =
  self.wrapCall(hide)

# Sizes the Window to |size| and centers it in the current display.
proc centerWindow*(self: NCWindow, size: NCSize) =
  self.wrapCall(center_window, size)

# Close the Window.
proc close*(self: NCWindow) =
  self.wrapCall(close)

# Returns true (1) if the Window has been closed.
proc isClosed*(self: NCWindow): bool =
  self.wrapCall(is_closed, result)

# Activate the Window, assuming it already exists and is visible.
proc activate*(self: NCWindow) =
  self.wrapCall(activate)

# Deactivate the Window, making the next Window in the Z order the active
# Window.
proc deactivate*(self: NCWindow) =
  self.wrapCall(deactivate)

# Returns whether the Window is the currently active Window.
proc isActive*(self: NCWindow): bool =
  self.wrapCall(is_active, result)

# Bring this Window to the top of other Windows in the Windowing system.
proc bringToTop*(self: NCWindow) =
  self.wrapCall(bring_to_top)

# Set the Window to be on top of other Windows in the Windowing system.
proc setAlwaysOnTop*(self: NCWindow, on_top: bool) =
  self.wrapCall(set_always_on_top, on_top)

# Returns whether the Window has been set to be on top of other Windows in
# the Windowing system.
proc isAlwaysOnTop*(self: NCWindow): bool =
  self.wrapCall(is_always_on_top, result)

# Maximize the Window.
proc maximize*(self: NCWindow) =
  self.wrapCall(maximize)

# Minimize the Window.
proc minimize*(self: NCWindow) =
  self.wrapCall(minimize)

# Restore the Window.
proc restore*(self: NCWindow) =
  self.wrapCall(restore)

# Set fullscreen Window state.
proc setFullscreen*(self: NCWindow, fullscreen: bool) =
  self.wrapCall(set_fullscreen, fullscreen)

# Returns true (1) if the Window is maximized.
proc isMaximized*(self: NCWindow): bool =
  self.wrapCall(is_maximized, result)

# Returns true (1) if the Window is minimized.
proc isMinimized*(self: NCWindow): bool =
  self.wrapCall(is_minimized, result)

# Returns true (1) if the Window is fullscreen.
proc isFullscreen*(self: NCWindow): bool =
  self.wrapCall(is_fullscreen, result)

# Set the Window title.
proc setTitle*(self: NCWindow, title: string) =
  self.wrapCall(set_title, title)

# Get the Window title.
proc getTitle*(self: NCWindow): string =
  self.wrapCall(get_title, result)

# Set the Window icon. This should be a 16x16 icon suitable for use in the
# Windows's title bar.
proc setWindowIcon*(self: NCWindow, image: NCImage) =
  self.wrapCall(set_window_icon, image)

# Get the Window icon.
proc getWindowIcon*(self: NCWindow): NCImage =
  self.wrapCall(get_window_icon, result)

# Set the Window App icon. This should be a larger icon for use in the host
# environment app switching UI. On Windows, this is the ICON_BIG used in Alt-
# Tab list and Windows taskbar. The Window icon will be used by default if no
# Window App icon is specified.
proc setWindowAppIcon*(self: NCWindow, image: NCImage) =
  self.wrapCall(set_window_app_icon, image)

# Get the Window App icon.
proc getWindowAppIcon*(self: NCWindow): NCImage =
  self.wrapCall(get_window_app_icon, result)

# Show a menu with contents |menu_model|. |screen_point| specifies the menu
# position in screen coordinates. |anchor_position| specifies how the menu
# will be anchored relative to |screen_point|.
proc showMenu*(self: NCWindow,
  menu_model: NCMenuModel, screen_point: NCPoint,
  anchor_position: cef_menu_anchor_position) =
  self.wrapCall(show_menu, menu_model, screen_point, anchor_position)

# Cancel the menu that is currently showing, if any.
proc cancelMenu*(self: NCWindow) =
  self.wrapCall(cancel_menu)

# Returns the Display that most closely intersects the bounds of this Window.
# May return NULL if this Window is not currently displayed.
proc getDisplay*(self: NCWindow): NCDisplay =
  self.wrapCall(get_display, result)

# Returns the bounds (size and position) of this Window's client area.
# Position is in screen coordinates.
proc getClientAreaBoundsInScreen*(self: NCWindow): NCRect =
  self.wrapCall(get_client_area_bounds_in_screen, result)

# Set the regions where mouse events will be intercepted by this Window to
# support drag operations. Call this function with an NULL vector to clear
# the draggable regions. The draggable region bounds should be in window
# coordinates.
proc set_draggable_regions*(self: NCWindow, regions: seq[NCDraggableRegion]) =
  self.wrapCall(set_draggable_regions, regions)

# Retrieve the platform window handle for this Window.
proc getWindowHandle*(self: NCWindow): cef_window_handle =
  self.wrapCall(get_window_handle, result)

# Simulate a key press. |key_code| is the VKEY_* value from Chromium's
# ui/events/keycodes/keyboard_codes.h header (VK_* values on Windows).
# |event_flags| is some combination of EVENTFLAG_SHIFT_DOWN,
# EVENTFLAG_CONTROL_DOWN and/or EVENTFLAG_ALT_DOWN. This function is exposed
# primarily for testing purposes.
proc sendKeyPess*(self: NCWindow, keyCode: int, eventFlags: uint32) =
  self.wrapCall(send_key_press, keyCode, eventFlags)

# Simulate a mouse move. The mouse cursor will be moved to the specified
# (screen_x, screen_y) position. This function is exposed primarily for
# testing purposes.
proc sendMouseMove*(self: NCWindow, screen_x, screen_y: int) =
  self.wrapCall(send_mouse_move, screen_x, screen_y)

# Simulate mouse down and/or mouse up events. |button| is the mouse button
# type. If |mouse_down| is true (1) a mouse down event will be sent. If
# |mouse_up| is true (1) a mouse up event will be sent. If both are true (1)
# a mouse down event will be sent followed by a mouse up event (equivalent to
# clicking the mouse button). The events will be sent using the current
# cursor position so make sure to call send_mouse_move() first to position
# the mouse. This function is exposed primarily for testing purposes.
proc sendMouseEvents*(self: NCWindow,
  button: cef_mouse_button_type, mouse_down, mouse_up: bool) =
  self.wrapCall(send_mouse_events, button, mouse_down, mouse_up)

# Returns this LabelButton as a MenuButton or NULL if this is not a
# MenuButton.
proc asMenuButton*(self: NCLabelButton): NCMenuButton =
  self.wrapCall(as_menu_button, result)

# Sets the text shown on the LabelButton. By default |text| will also be used
# as the accessible name.
proc setText*(self: NCLabelButton, text: string) =
  self.wrapCall(set_text, text)

# Returns the text shown on the LabelButton.
proc getText*(self: NCLabelButton): string =
  self.wrapCall(get_text, result)

# Sets the image shown for |button_state|. When this Button is drawn if no
# image exists for the current state then the image for
# cef_button_state_NORMAL, if any, will be shown.
proc setImage*(self: NCLabelButton, state: cef_button_state, image: NCImage) =
  self.wrapCall(set_image, state, image)

# Returns the image shown for |button_state|. If no image exists for that
# state then the image for cef_button_state_NORMAL will be returned.
proc getImage*(self: NCLabelButton, state: cef_button_state): NCImage =
  self.wrapCall(get_image, result, state)

# Sets the text color shown for the specified button |for_state| to |color|.
proc setTextColor*(self: NCLabelButton, for_state: cef_button_state, color: cef_color) =
  self.wrapCall(set_text_color, for_state, color)

# Sets the text colors shown for the non-disabled states to |color|.
proc setEnabledTextColors*(self: NCLabelButton, color: cef_color) =
  self.wrapCall(set_enabled_text_colors, color)

# Sets the font list. The format is "<FONT_FAMILY_LIST>,[STYLES] <SIZE>",
# where: - FONT_FAMILY_LIST is a comma-separated list of font family names, -
# STYLES is an optional space-separated list of style names (case-sensitive
#   "Bold" and "Italic" are supported), and
# - SIZE is an integer font size in pixels with the suffix "px".
#
# Here are examples of valid font description strings: - "Arial, Helvetica,
# Bold Italic 14px" - "Arial, 14px"
proc setFontList*(self: NCLabelButton, font_list: string) =
  self.wrapCall(set_font_list, font_list)

# Sets the horizontal alignment; reversed in RTL. Default is
# CEF_HORIZONTAL_ALIGNMENT_CENTER.
proc setHorizontalAlignment*(self: NCLabelButton, alignment: cef_horizontal_alignment) =
  self.wrapCall(set_horizontal_alignment, alignment)

# Reset the minimum size of this LabelButton to |size|.
proc setMinimumSize*(self: NCLabelButton, size: NCSize) =
  self.wrapCall(set_minimum_size, size)

# Reset the maximum size of this LabelButton to |size|.
proc setMaximumSize*(self: NCLabelButton, size: NCSize) =
  self.wrapCall(set_maximum_size, size)

# Returns the unique identifier for this Display.
proc getId*(self: NCDisplay): int64 =
  self.wrapCall(get_id, result)

# Returns this Display's device pixel scale factor. This specifies how much
# the UI should be scaled when the actual output has more pixels than
# standard displays (which is around 100~120dpi). The potential return values
# differ by platform.
proc getDeviceScaleFactor*(self: NCDisplay): float =
  self.wrapCall(get_device_scale_factor, result)

# Convert |point| from density independent pixels (DIP) to pixel coordinates
# using this Display's device scale factor.
proc vconvertPointToPixels*(self: NCDisplay, point: var NCPoint) =
  self.wrapCall(vconvert_point_to_pixels, point)

# Convert |point| from pixel coordinates to density independent pixels (DIP)
# using this Display's device scale factor.
proc vconvertPointFromPixels*(self: NCDisplay, point: var NCPoint) =
  self.wrapCall(vconvert_point_from_pixels, point)

# Returns this Display's bounds. This is the full size of the display.
proc getBounds*(self: NCDisplay): NCRect =
  self.wrapCall(get_bounds, result)

# Returns this Display's work area. This excludes areas of the display that
# are occupied for window manager toolbars, etc.
proc getWorkArea*(self: NCDisplay): NCRect =
  self.wrapCall(get_work_area, result)

# Returns this Display's rotation in degrees.
proc getRotation*(self: NCDisplay): int =
  self.wrapCall(get_rotation, result)

# Show a menu with contents |menu_model|. |screen_point| specifies the menu
# position in screen coordinates. |anchor_position| specifies how the menu
# will be anchored relative to |screen_point|. This function should be called
# from cef_menu_button_delegate_t::on_menu_button_pressed().
proc showMenu*(self: NCMenuButton, menuModel: NCMenuModel, screenPoint: NCPoint,
  anchorPosition: cef_menu_anchor_position) =
  self.wrapCall(show_menu, menuModel, screenPoint, anchorPosition)
