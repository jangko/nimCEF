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
#[
# Returns this View as a BrowserView or NULL if this is not a BrowserView.
proc as_browser_view*(self: NCView): NCBrowserView =

# Returns this View as a Button or NULL if this is not a Button.
proc as_button*(self: NCView): NCButton =

# Returns this View as a Panel or NULL if this is not a Panel.
proc as_panel*(self: NCView): NCPanel =

# Returns this View as a ScrollView or NULL if this is not a ScrollView.
proc as_scroll_view*(self: NCView): NCScrollView =

# Returns this View as a Textfield or NULL if this is not a Textfield.
proc as_textfield*(self: NCView): NCTextField =

# Returns the type of this View as a string. Used primarily for testing
# purposes.
proc get_type_string*(self: NCView): string =

# Returns a string representation of this View which includes the type and
# various type-specific identifying attributes. If |include_children| is true
# (1) any child Views will also be included. Used primarily for testing
# purposes.
proc to_string*(self: NCView, include_children: bool): string =

# Returns true (1) if this View is valid.
proc is_valid*(self: NCView): bool =

# Returns true (1) if this View is currently attached to another View. A View
# can only be attached to one View at a time.
proc is_attached*(self: NCView): bool =

# Returns true (1) if this View is the same as |that| View.
proc is_same*(self, that: NCView): bool =

# Returns the delegate associated with this View, if any.
proc get_delegate*(self: NCView): NCViewDelegate =

# Returns the top-level Window hosting this View, if any.
proc get_window*(self: NCView): NCWindow =

# Returns the ID for this View.
proc get_id*(self: NCView): int =

# Sets the ID for this View. ID should be unique within the subtree that you
# intend to search for it. 0 is the default ID for views.
proc set_id*(self: NCView, id: int) =

# Returns the View that contains this View, if any.
proc get_parent_view*(self: NCView): NCView =

# Recursively descends the view tree starting at this View, and returns the
# first child that it encounters with the given ID. Returns NULL if no
# matching child view is found.
proc get_view_for_id*(self: NCView, id: int): NCView =

# Sets the bounds (size and position) of this View. Position is in parent
# coordinates.
proc set_bounds*(self: NCView, bounds: NCRect) =

# Returns the bounds (size and position) of this View. Position is in parent
# coordinates.
proc get_bounds*(self: NCView): NCRect =

# Returns the bounds (size and position) of this View. Position is in screen
# coordinates.
proc get_bounds_in_screen*(self: NCView): NCRect =

# Sets the size of this View without changing the position.
proc set_size*(self: NCView, size: NCSize) =

# Returns the size of this View.
proc get_size*(self: NCView): NCSize =

# Sets the position of this View without changing the size. |position| is in
# parent coordinates.
proc set_position*(self: NCView, position: NCPoint) =

# Returns the position of this View. Position is in parent coordinates.
proc get_position*(self: NCView): NCPoint =

# Returns the size this View would like to be if enough space is available.
proc get_preferred_size*(self: NCView): NCSize =

# Size this View to its preferred size.
proc size_to_preferred_size*(self: NCView) =

# Returns the minimum size for this View.
proc get_minimum_size*(self: NCView): NCSize =

# Returns the maximum size for this View.
proc get_maximum_size*(self: NCView): NCSize =

# Returns the height necessary to display this View with the provided width.
proc get_height_for_width*(self: NCView, width: int): int =

# Indicate that this View and all parent Views require a re-layout. This
# ensures the next call to layout() will propagate to this View even if the
# bounds of parent Views do not change.
proc invalidate_layout*(self: NCView) =

# Sets whether this View is visible. Windows are hidden by default and other
# views are visible by default. This View and any parent views must be set as
# visible for this View to be drawn in a Window. If this View is set as
# hidden then it and any child views will not be drawn and, if any of those
# views currently have focus, then focus will also be cleared. Painting is
# scheduled as needed. If this View is a Window then calling this function is
# equivalent to calling the Window show() and hide() functions.
proc set_visible*(self: NCView, visible: bool) =

# Returns whether this View is visible. A view may be visible but still not
# drawn in a Window if any parent views are hidden. If this View is a Window
# then a return value of true (1) indicates that this Window is currently
# visible to the user on-screen. If this View is not a Window then call
# is_drawn() to determine whether this View and all parent views are visible
# and will be drawn.
proc is_visible*(self: NCView): bool =

# Returns whether this View is visible and drawn in a Window. A view is drawn
# if it and all parent views are visible. If this View is a Window then
# calling this function is equivalent to calling is_visible(). Otherwise, to
# determine if the containing Window is visible to the user on-screen call
# is_visible() on the Window.
proc is_drawn*(self: NCView): bool =

# Set whether this View is enabled. A disabled View does not receive keyboard
# or mouse inputs. If |enabled| differs from the current value the View will
# be repainted. Also, clears focus if the focused View is disabled.
proc set_enabled*(self: NCView, enabled: bool) =

# Returns whether this View is enabled.
proc is_enabled*(self: NCView): bool =

# Sets whether this View is capable of taking focus. It will clear focus if
# the focused View is set to be non-focusable. This is false (0) by default
# so that a View used as a container does not get the focus.
proc set_focusable*(self: NCView, focusable: bool) =

# Returns true (1) if this View is focusable, enabled and drawn.
proc is_focusable*(self: NCView): bool =

# Return whether this View is focusable when the user requires full keyboard
# access, even though it may not be normally focusable.
proc is_accessibility_focusable*(self: NCView): bool =

# Request keyboard focus. If this View is focusable it will become the
# focused View.
proc request_focus*(self: NCView) =

# Sets the background color for this View.
proc set_background_color*(self: NCView, color: cef_color) =

# Returns the background color for this View.
proc get_background_color*(self: NCView): cef_color =

# Convert |point| from this View's coordinate system to that of the screen.
# This View must belong to a Window when calling this function. Returns true
# (1) if the conversion is successful or false (0) otherwise. Use
# cef_display_t::convert_point_to_pixels() after calling this function if
# further conversion to display-specific pixel coordinates is desired.
proc convert_point_to_screen*(self: NCView, point: NCPoint): bool =

# Convert |point| to this View's coordinate system from that of the screen.
# This View must belong to a Window when calling this function. Returns true
# (1) if the conversion is successful or false (0) otherwise. Use
# cef_display_t::convert_point_from_pixels() before calling this function if
# conversion from display-specific pixel coordinates is necessary.
proc convert_point_from_screen*(self: NCView, point: NCPoint): bool =

# Convert |point| from this View's coordinate system to that of the Window.
# This View must belong to a Window when calling this function. Returns true
# (1) if the conversion is successful or false (0) otherwise.
proc convert_point_to_window*(self: NCView, point: NCPoint): bool =

# Convert |point| to this View's coordinate system from that of the Window.
# This View must belong to a Window when calling this function. Returns true
# (1) if the conversion is successful or false (0) otherwise.
proc convert_point_from_window*(self: NCView, point: NCPoint): bool =

# Convert |point| from this View's coordinate system to that of |view|.
# |view| needs to be in the same Window but not necessarily the same view
# hierarchy. Returns true (1) if the conversion is successful or false (0)
# otherwise.
proc convert_point_to_view*(self, view: NCView, point: NCPoint): bool =

# Convert |point| to this View's coordinate system from that |view|. |view|
# needs to be in the same Window but not necessarily the same view hierarchy.
# Returns true (1) if the conversion is successful or false (0) otherwise.
proc convert_point_from_view*(self, view: NCView, point: NCPoint): bool =


# Returns the cef_browser_t hosted by this BrowserView. Will return NULL if
# the browser has not yet been created or has already been destroyed.

proc get_browser(self: NCBrowserView): NCBrowser =


# Returns this Button as a LabelButton or NULL if this is not a LabelButton.
proc as_label_button*(self: NCButton): NCLabelButton =

# Sets the current display state of the Button.
proc set_state*(self: NCButton, state: cef_button_state) =

# Returns the current display state of the Button.
proc get_state*(self: NCButton): cef_button_state =

# Sets the tooltip text that will be displayed when the user hovers the mouse
# cursor over the Button.
proc set_tooltip_text*(self: NCButton, tooltip_text: string) =

# Sets the accessible name that will be exposed to assistive technology (AT).
proc set_accessible_name*(self: NCButton, name: string) =


# Returns this Panel as a Window or NULL if this is not a Window.
proc as_window*(self: NCPanel): NCWindow =

# Set this Panel's Layout to FillLayout and return the FillLayout object.
proc set_to_fill_layout*(self: NCPanel): NCFillLayout =

# Set this Panel's Layout to BoxLayout and return the BoxLayout object.
proc set_to_box_layout*(self: NCPanel, settings: NCBoxLayoutSettings): NCBoxLayout =

# Get the Layout.
proc get_layout*(self: NCPanel): NCLayout =

# Lay out the child Views (set their bounds based on sizing heuristics
# specific to the current Layout).
proc layout*(self: NCPanel) =

# Add a child View.
proc add_child_view*(self: NCPanel, view: NCView) =

# Add a child View at the specified |index|. If |index| matches the result of
# GetChildCount() then the View will be added at the end.
proc add_child_view_at*(self: NCPanel, view: NCView, index: int) =

# Move the child View to the specified |index|. A negative value for |index|
# will move the View to the end.
proc reorder_child_view*(self: NCPanel, view: NCView, index: int) =

# Remove a child View. The View can then be added to another Panel.
proc remove_child_view*(self: NCPanel, view: NCView) =

# Remove all child Views. The removed Views will be deleted if the client
# holds no references to them.
proc remove_all_child_views*(self: NCPanel) =

# Returns the number of child Views.
proc get_child_view_count*(self: NCPanel): int =

# Returns the child View at the specified |index|.
proc get_child_view_at*(self: NCPanel, index: int): NCView =


# Set the content View. The content View must have a specified size (e.g. via
# cef_view_t::SetBounds or cef_view_tDelegate::GetPreferredSize).
proc set_content_view*(self: NCScrollView, view: NCView) =

# Returns the content View.
proc get_content_view*(self: NCScrollView): NCView =

# Returns the visible region of the content View.
proc get_visible_content_rect*(self: NCScrollView): NCRect =

# Returns true (1) if the horizontal scrollbar is currently showing.
proc has_horizontal_scrollbar*(self: NCScrollView): bool =

# Returns the height of the horizontal scrollbar.
proc get_horizontal_scrollbar_height*(self: NCScrollView): bool =

# Returns true (1) if the vertical scrollbar is currently showing.
proc has_vertical_scrollbar*(self: NCScrollView): bool =

# Returns the width of the vertical scrollbar.
proc get_vertical_scrollbar_width*(self: NCScrollView): int =


# Sets whether the text will be displayed as asterisks.
proc set_password_input*(self: NCTextField, password_input: bool) =

# Returns true (1) if the text will be displayed as asterisks.
proc is_password_input*(self: NCTextField): bool =

# Sets whether the text will read-only.
proc set_read_only*(self: NCTextField, read_only: bool) =

# Returns true (1) if the text is read-only.
proc is_read_only*(self: NCTextField): bool =

# Returns the currently displayed text.

proc get_text*(self: NCTextField): string =

# Sets the contents to |text|. The cursor will be moved to end of the text if
# the current position is outside of the text range.
proc set_text*(self: NCTextField, text: string) =

# Appends |text| to the previously-existing text.
proc append_text*(self: NCTextField, text: string) =

# Inserts |text| at the current cursor position replacing any selected text.
proc insert_or_replace_text*(self: NCTextField, text: string) =

# Returns true (1) if there is any selected text.
proc has_selection*(self: NCTextField): bool =

# Returns the currently selected text.
proc get_selected_text*(self: NCTextField): string =

# Selects all text. If |reversed| is true (1) the range will end at the
# logical beginning of the text; this generally shows the leading portion of
# text that overflows its display area.
proc select_all*(self: NCTextField, reversed: bool) =

# Clears the text selection and sets the caret to the end.
proc clear_selection*(self: NCTextField) =

# Returns the selected logical text range.
proc get_selected_range*(self: NCTextField): NCRange =

# Selects the specified logical text range.
proc select_range*(self: NCTextField, the_range: NCRange) =

# Returns the current cursor position.
proc get_cursor_position*(self: NCTextField): int =

# Sets the text color.
proc set_text_color*(self: NCTextField, color: cef_color) =

# Returns the text color.
proc get_text_color*(self: NCTextField): cef_color =

# Sets the selection text color.
proc set_selection_text_color*(self: NCTextField, color: cef_color) =

# Returns the selection text color.
proc get_selection_text_color*(self: NCTextField): cef_color =

# Sets the selection background color.
proc set_selection_background_color*(self: NCTextField, color: cef_color) =

# Returns the selection background color.
proc get_selection_background_color*(self: NCTextField): cef_color =

# Sets the font list. The format is "<FONT_FAMILY_LIST>,[STYLES] <SIZE>",
# where: - FONT_FAMILY_LIST is a comma-separated list of font family names, -
# STYLES is an optional space-separated list of style names (case-sensitive
#   "Bold" and "Italic" are supported), and
# - SIZE is an integer font size in pixels with the suffix "px".
#
# Here are examples of valid font description strings: - "Arial, Helvetica,
# Bold Italic 14px" - "Arial, 14px"
proc set_font_list*(self: NCTextField,font_list: string) =

# Applies |color| to the specified |range| without changing the default
# color. If |range| is NULL the color will be set on the complete text
# contents.
proc apply_text_color*(self: NCTextField, color: cef_color, the_range: NCRange) =

# Applies |style| to the specified |range| without changing the default
# style. If |add| is true (1) the style will be added, otherwise the style
# will be removed. If |range| is NULL the style will be set on the complete
# text contents.
proc apply_text_style*(self: NCTextField,
  style: cef_text_style, add: int, the_range: NCRange) =

# Returns true (1) if the action associated with the specified command id is
# enabled. See additional comments on execute_command().
proc is_command_enabled*(self: NCTextField, command_id: int): bool =

# Performs the action associated with the specified command id. Valid values
# include IDS_APP_UNDO, IDS_APP_REDO, IDS_APP_CUT, IDS_APP_COPY,
# IDS_APP_PASTE, IDS_APP_DELETE, IDS_APP_SELECT_ALL, IDS_DELETE_* and
# IDS_MOVE_*. See include/cef_pack_strings.h for definitions.
proc execute_command*(self: NCTextField, command_id: int): bool =

# Clears Edit history.
proc clear_edit_history*(self: NCTextField) =

# Sets the placeholder text that will be displayed when the Textfield is
# NULL.
proc set_placeholder_text*(self: NCTextField, text: string) =

# Returns the placeholder text that will be displayed when the Textfield is
# NULL.

proc get_placeholder_text*(self: NCTextField): string =

# Sets the placeholder text color.
proc set_placeholder_text_color*(self: NCTextField, color: cef_color) =

# Returns the placeholder text color.
proc get_placeholder_text_color*(self: NCTextField): cef_color =

# Set the accessible name that will be exposed to assistive technology (AT).
proc set_accessible_name*(self: NCTextField, name: string) =


# Show the Window.
proc show*(self: NCWindow) =

# Hide the Window.
proc hide*(self: NCWindow) =

# Sizes the Window to |size| and centers it in the current display.
proc center_window*(self: NCWindow, size: NCSize) =

# Close the Window.
proc close*(self: NCWindow) =

# Returns true (1) if the Window has been closed.
proc is_closed*(self: NCWindow): bool =

# Activate the Window, assuming it already exists and is visible.
proc activate*(self: NCWindow) =

# Deactivate the Window, making the next Window in the Z order the active
# Window.
proc deactivate*(self: NCWindow) =

# Returns whether the Window is the currently active Window.
proc is_active*(self: NCWindow): bool =

# Bring this Window to the top of other Windows in the Windowing system.
proc bring_to_top*(self: NCWindow) =

# Set the Window to be on top of other Windows in the Windowing system.
proc set_always_on_top*(self: NCWindow, on_top: bool) =

# Returns whether the Window has been set to be on top of other Windows in
# the Windowing system.
proc is_always_on_top*(self: NCWindow): bool =

# Maximize the Window.
proc maximize*(self: NCWindow) =

# Minimize the Window.
proc minimize*(self: NCWindow) =

# Restore the Window.
proc restore*(self: NCWindow) =

# Set fullscreen Window state.
proc set_fullscreen*(self: NCWindow, fullscreen: bool) =

# Returns true (1) if the Window is maximized.
proc is_maximized*(self: NCWindow): bool =

# Returns true (1) if the Window is minimized.
proc is_minimized*(self: NCWindow): bool =

# Returns true (1) if the Window is fullscreen.
proc is_fullscreen*(self: NCWindow): bool =

# Set the Window title.
proc set_title*(self: NCWindow, title: string) =

# Get the Window title.

proc get_title*(self: NCWindow): string =

# Set the Window icon. This should be a 16x16 icon suitable for use in the
# Windows's title bar.
proc set_window_icon*(self: NCWindow, image: NCImage) =

# Get the Window icon.
proc get_window_icon*(self: NCWindow): NCImage =

# Set the Window App icon. This should be a larger icon for use in the host
# environment app switching UI. On Windows, this is the ICON_BIG used in Alt-
# Tab list and Windows taskbar. The Window icon will be used by default if no
# Window App icon is specified.
proc set_window_app_icon*(self: NCWindow, image: NCImage) =

# Get the Window App icon.
proc get_window_app_icon*(self: NCWindow): NCImage =

# Show a menu with contents |menu_model|. |screen_point| specifies the menu
# position in screen coordinates. |anchor_position| specifies how the menu
# will be anchored relative to |screen_point|.
proc show_menu*(self: NCWindow,
  menu_model: ptr cef_menu_model, screen_point: NCPoint,
  anchor_position: cef_menu_anchor_position) =

# Cancel the menu that is currently showing, if any.
proc cancel_menu*(self: NCWindow) =

# Returns the Display that most closely intersects the bounds of this Window.
# May return NULL if this Window is not currently displayed.
proc get_display*(self: NCWindow): NCDisplay =

# Returns the bounds (size and position) of this Window's client area.
# Position is in screen coordinates.
proc get_client_area_bounds_in_screen*(self: NCWindow): NCRect =

# Set the regions where mouse events will be intercepted by this Window to
# support drag operations. Call this function with an NULL vector to clear
# the draggable regions. The draggable region bounds should be in window
# coordinates.
proc set_draggable_regions*(self: NCWindow,
  regionsCount: int, regions: NCDraggableRegion) =

# Retrieve the platform window handle for this Window.
proc get_window_handle*(self: NCWindow): cef_window_handle =

# Simulate a key press. |key_code| is the VKEY_* value from Chromium's
# ui/events/keycodes/keyboard_codes.h header (VK_* values on Windows).
# |event_flags| is some combination of EVENTFLAG_SHIFT_DOWN,
# EVENTFLAG_CONTROL_DOWN and/or EVENTFLAG_ALT_DOWN. This function is exposed
# primarily for testing purposes.
proc send_key_press*(self: NCWindow, key_code: int, event_flags: uint32) =

# Simulate a mouse move. The mouse cursor will be moved to the specified
# (screen_x, screen_y) position. This function is exposed primarily for
# testing purposes.
proc send_mouse_move*(self: NCWindow, screen_x, screen_y: int) =

# Simulate mouse down and/or mouse up events. |button| is the mouse button
# type. If |mouse_down| is true (1) a mouse down event will be sent. If
# |mouse_up| is true (1) a mouse up event will be sent. If both are true (1)
# a mouse down event will be sent followed by a mouse up event (equivalent to
# clicking the mouse button). The events will be sent using the current
# cursor position so make sure to call send_mouse_move() first to position
# the mouse. This function is exposed primarily for testing purposes.
proc send_mouse_events*(self: NCWindow,
  button: cef_mouse_button_type, mouse_down, mouse_up: bool) =


# Returns this LabelButton as a MenuButton or NULL if this is not a
# MenuButton.
proc as_menu_button*(self: NCLabelButton): NCMenuButton =

# Sets the text shown on the LabelButton. By default |text| will also be used
# as the accessible name.
proc set_text*(self: NCLabelButton, text: string) =

# Returns the text shown on the LabelButton.

proc get_text*(self: NCLabelButton): string =

# Sets the image shown for |button_state|. When this Button is drawn if no
# image exists for the current state then the image for
# cef_button_state_NORMAL, if any, will be shown.
proc set_image*(self: NCLabelButton, state: cef_button_state, image: NCImage) =

# Returns the image shown for |button_state|. If no image exists for that
# state then the image for cef_button_state_NORMAL will be returned.
proc get_image*(self: NCLabelButton, state: cef_button_state): NCImage =

# Sets the text color shown for the specified button |for_state| to |color|.
proc set_text_color*(self: NCLabelButton, for_state: cef_button_state, color: cef_color) =

# Sets the text colors shown for the non-disabled states to |color|.
proc set_enabled_text_colors*(self: NCLabelButton, color: cef_color) =

# Sets the font list. The format is "<FONT_FAMILY_LIST>,[STYLES] <SIZE>",
# where: - FONT_FAMILY_LIST is a comma-separated list of font family names, -
# STYLES is an optional space-separated list of style names (case-sensitive
#   "Bold" and "Italic" are supported), and
# - SIZE is an integer font size in pixels with the suffix "px".
#
# Here are examples of valid font description strings: - "Arial, Helvetica,
# Bold Italic 14px" - "Arial, 14px"
proc set_font_list*(self: NCLabelButton, font_list: string) =

# Sets the horizontal alignment; reversed in RTL. Default is
# CEF_HORIZONTAL_ALIGNMENT_CENTER.
proc set_horizontal_alignment*(self: NCLabelButton, alignment: cef_horizontal_alignment) =

# Reset the minimum size of this LabelButton to |size|.
proc set_minimum_size*(self: NCLabelButton, size: NCSize) =

# Reset the maximum size of this LabelButton to |size|.
proc set_maximum_size*(self: NCLabelButton, size: NCSize) =


# Returns the unique identifier for this Display.
proc get_id*(self: NCDisplay): int64 =

# Returns this Display's device pixel scale factor. This specifies how much
# the UI should be scaled when the actual output has more pixels than
# standard displays (which is around 100~120dpi). The potential return values
# differ by platform.
proc get_device_scale_factor*(self: NCDisplay): float =

# Convert |point| from density independent pixels (DIP) to pixel coordinates
# using this Display's device scale factor.
proc vconvert_point_to_pixels*(self: NCDisplay, point: NCPoint) =

# Convert |point| from pixel coordinates to density independent pixels (DIP)
# using this Display's device scale factor.
proc vconvert_point_from_pixels*(self: NCDisplay, point: NCPoint) =

# Returns this Display's bounds. This is the full size of the display.
proc get_bounds*(self: NCDisplay): NCRect =

# Returns this Display's work area. This excludes areas of the display that
# are occupied for window manager toolbars, etc.
proc get_work_area*(self: NCDisplay): NCRect =

# Returns this Display's rotation in degrees.
proc get_rotation*(self: NCDisplay): int =


# Show a menu with contents |menu_model|. |screen_point| specifies the menu
# position in screen coordinates. |anchor_position| specifies how the menu
# will be anchored relative to |screen_point|. This function should be called
# from cef_menu_button_delegate_t::on_menu_button_pressed().
proc show_menu*(self: NCMenuButton,
  menu_model: ptr cef_menu_model, screen_point: NCPoint,
  anchor_position: cef_menu_anchor_position) =]#