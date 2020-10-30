import cef_base_api, cef_types, cef_browser_api, cef_image_api, cef_menu_model_api
import cef_client_api
include cef_import

type
  # A Layout handles the sizing of the children of a Panel according to
  # implementation-specific heuristics. Methods must be called on the browser
  # process UI thread unless otherwise indicated.
  cef_layout* = object of cef_base
    # Returns this Layout as a BoxLayout or NULL if this is not a BoxLayout.
    as_box_layout*: proc(self: ptr cef_layout): ptr cef_box_layout {.cef_callback.}

    # Returns this Layout as a FillLayout or NULL if this is not a FillLayout.
    as_fill_layout*: proc(self: ptr cef_layout): ptr cef_fill_layout {.cef_callback.}

    # Returns true (1) if this Layout is valid.
    is_valid*: proc(self: ptr cef_layout): cint {.cef_callback.}

  # A Layout manager that arranges child views vertically or horizontally in a
  # side-by-side fashion with spacing around and between the child views. The
  # child views are always sized according to their preferred size. If the host's
  # bounds provide insufficient space, child views will be clamped. Excess space
  # will not be distributed. Methods must be called on the browser process UI
  # thread unless otherwise indicated.
  cef_box_layout* = object of cef_layout
    # Set the flex weight for the given |view|. Using the preferred size as the
    # basis, free space along the main axis is distributed to views in the ratio
    # of their flex weights. Similarly, if the views will overflow the parent,
    # space is subtracted in these ratios. A flex of 0 means this view is not
    # resized. Flex values must not be negative.
    set_flex_for_view*: proc(self: ptr cef_box_layout,
      view: ptr cef_view, flex: int) {.cef_callback.}

    # Clears the flex for the given |view|, causing it to use the default flex
    # specified via cef_box_layout_tSettings.default_flex.
    clear_flex_for_view*: proc(self: ptr cef_box_layout,
      view: ptr cef_view) {.cef_callback.}

  # A simple Layout that causes the associated Panel's one child to be sized to
  # match the bounds of its parent. Methods must be called on the browser process
  # UI thread unless otherwise indicated.
  cef_fill_layout* = object of cef_layout

  # A View is a rectangle within the views View hierarchy. It is the base
  # structure for all Views. All size and position values are in density
  # independent pixels (DIP) unless otherwise indicated. Methods must be called
  # on the browser process UI thread unless otherwise indicated.
  cef_view* = object of cef_base
    # Returns this View as a BrowserView or NULL if this is not a BrowserView.
    as_browser_view*: proc(self: ptr cef_view): ptr cef_browser_view {.cef_callback.}

    # Returns this View as a Button or NULL if this is not a Button.
    as_button*: proc(self: ptr cef_view): ptr cef_button {.cef_callback.}

    # Returns this View as a Panel or NULL if this is not a Panel.
    as_panel*: proc(self: ptr cef_view): ptr cef_panel {.cef_callback.}

    # Returns this View as a ScrollView or NULL if this is not a ScrollView.
    as_scroll_view*: proc(self: ptr cef_view): ptr cef_scroll_view {.cef_callback.}

    # Returns this View as a Textfield or NULL if this is not a Textfield.
    as_textfield*: proc(self: ptr cef_view): ptr cef_textfield {.cef_callback.}

    # Returns the type of this View as a string. Used primarily for testing
    # purposes.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_type_string*: proc(self: ptr cef_view): cef_string_userfree {.cef_callback.}

    # Returns a string representation of this View which includes the type and
    # various type-specific identifying attributes. If |include_children| is true
    # (1) any child Views will also be included. Used primarily for testing
    # purposes.
    # The resulting string must be freed by calling cef_string_userfree_free().
    to_string*: proc(self: ptr cef_view, include_children: cint): cef_string_userfree {.cef_callback.}

    # Returns true (1) if this View is valid.
    is_valid*: proc(self: ptr cef_view): cint {.cef_callback.}

    # Returns true (1) if this View is currently attached to another View. A View
    # can only be attached to one View at a time.
    is_attached*: proc(self: ptr cef_view): cint {.cef_callback.}

    # Returns true (1) if this View is the same as |that| View.
    is_same*: proc(self, that: ptr cef_view): cint {.cef_callback.}

    # Returns the delegate associated with this View, if any.
    get_delegate*: proc(self: ptr cef_view): ptr cef_view_delegate {.cef_callback.}

    # Returns the top-level Window hosting this View, if any.
    get_window*: proc(self: ptr cef_view): ptr cef_window {.cef_callback.}

    # Returns the ID for this View.
    get_id*: proc(self: ptr cef_view): cint {.cef_callback.}

    # Sets the ID for this View. ID should be unique within the subtree that you
    # intend to search for it. 0 is the default ID for views.
    set_id*: proc(self: ptr cef_view, id: cint) {.cef_callback.}

    # Returns the View that contains this View, if any.
    get_parent_view*: proc(self: ptr cef_view): ptr cef_view {.cef_callback.}

    # Recursively descends the view tree starting at this View, and returns the
    # first child that it encounters with the given ID. Returns NULL if no
    # matching child view is found.
    get_view_for_id*: proc(self: ptr cef_view, id: cint): ptr cef_view {.cef_callback.}

    # Sets the bounds (size and position) of this View. Position is in parent
    # coordinates.
    set_bounds*: proc(self: ptr cef_view, bounds: ptr cef_rect) {.cef_callback.}

    # Returns the bounds (size and position) of this View. Position is in parent
    # coordinates.
    get_bounds*: proc(self: ptr cef_view): cef_rect {.cef_callback.}

    # Returns the bounds (size and position) of this View. Position is in screen
    # coordinates.
    get_bounds_in_screen*: proc(self: ptr cef_view): cef_rect {.cef_callback.}

    # Sets the size of this View without changing the position.
    set_size*: proc(self: ptr cef_view, size: ptr cef_size) {.cef_callback.}

    # Returns the size of this View.
    get_size*: proc(self: ptr cef_view): cef_size {.cef_callback.}

    # Sets the position of this View without changing the size. |position| is in
    # parent coordinates.
    set_position*: proc(self: ptr cef_view, position: ptr cef_point) {.cef_callback.}

    # Returns the position of this View. Position is in parent coordinates.
    get_position*: proc(self: ptr cef_view): cef_point {.cef_callback.}

    # Returns the size this View would like to be if enough space is available.
    get_preferred_size*: proc(self: ptr cef_view): cef_size {.cef_callback.}

    # Size this View to its preferred size.
    size_to_preferred_size*: proc(self: ptr cef_view) {.cef_callback.}

    # Returns the minimum size for this View.
    get_minimum_size*: proc(self: ptr cef_view): cef_size {.cef_callback.}

    # Returns the maximum size for this View.
    get_maximum_size*: proc(self: ptr cef_view): cef_size {.cef_callback.}

    # Returns the height necessary to display this View with the provided width.
    get_height_for_width*: proc(self: ptr cef_view, width: cint): cint {.cef_callback.}

    # Indicate that this View and all parent Views require a re-layout. This
    # ensures the next call to layout() will propagate to this View even if the
    # bounds of parent Views do not change.
    invalidate_layout*: proc(self: ptr cef_view) {.cef_callback.}

    # Sets whether this View is visible. Windows are hidden by default and other
    # views are visible by default. This View and any parent views must be set as
    # visible for this View to be drawn in a Window. If this View is set as
    # hidden then it and any child views will not be drawn and, if any of those
    # views currently have focus, then focus will also be cleared. Painting is
    # scheduled as needed. If this View is a Window then calling this function is
    # equivalent to calling the Window show() and hide() functions.
    set_visible*: proc(self: ptr cef_view, visible: cint) {.cef_callback.}

    # Returns whether this View is visible. A view may be visible but still not
    # drawn in a Window if any parent views are hidden. If this View is a Window
    # then a return value of true (1) indicates that this Window is currently
    # visible to the user on-screen. If this View is not a Window then call
    # is_drawn() to determine whether this View and all parent views are visible
    # and will be drawn.
    is_visible*: proc(self: ptr cef_view): cint {.cef_callback.}

    # Returns whether this View is visible and drawn in a Window. A view is drawn
    # if it and all parent views are visible. If this View is a Window then
    # calling this function is equivalent to calling is_visible(). Otherwise, to
    # determine if the containing Window is visible to the user on-screen call
    # is_visible() on the Window.
    is_drawn*: proc(self: ptr cef_view): cint {.cef_callback.}

    # Set whether this View is enabled. A disabled View does not receive keyboard
    # or mouse inputs. If |enabled| differs from the current value the View will
    # be repainted. Also, clears focus if the focused View is disabled.
    set_enabled*: proc(self: ptr cef_view, enabled: cint) {.cef_callback.}

    # Returns whether this View is enabled.
    is_enabled*: proc(self: ptr cef_view): cint {.cef_callback.}

    # Sets whether this View is capable of taking focus. It will clear focus if
    # the focused View is set to be non-focusable. This is false (0) by default
    # so that a View used as a container does not get the focus.
    set_focusable*: proc(self: ptr cef_view, focusable: cint) {.cef_callback.}

    # Returns true (1) if this View is focusable, enabled and drawn.
    is_focusable*: proc(self: ptr cef_view): cint {.cef_callback.}

    # Return whether this View is focusable when the user requires full keyboard
    # access, even though it may not be normally focusable.
    is_accessibility_focusable*: proc(self: ptr cef_view): cint {.cef_callback.}

    # Request keyboard focus. If this View is focusable it will become the
    # focused View.
    request_focus*: proc(self: ptr cef_view) {.cef_callback.}

    # Sets the background color for this View.
    set_background_color*: proc(self: ptr cef_view, color: cef_color) {.cef_callback.}

    # Returns the background color for this View.
    get_background_color*: proc(self: ptr cef_view): cef_color {.cef_callback.}

    # Convert |point| from this View's coordinate system to that of the screen.
    # This View must belong to a Window when calling this function. Returns true
    # (1) if the conversion is successful or false (0) otherwise. Use
    # cef_display_t::convert_point_to_pixels() after calling this function if
    # further conversion to display-specific pixel coordinates is desired.
    convert_point_to_screen*: proc(self: ptr cef_view, point: ptr cef_point): cint {.cef_callback.}

    # Convert |point| to this View's coordinate system from that of the screen.
    # This View must belong to a Window when calling this function. Returns true
    # (1) if the conversion is successful or false (0) otherwise. Use
    # cef_display_t::convert_point_from_pixels() before calling this function if
    # conversion from display-specific pixel coordinates is necessary.
    convert_point_from_screen*: proc(self: ptr cef_view, point: ptr cef_point): cint {.cef_callback.}

    # Convert |point| from this View's coordinate system to that of the Window.
    # This View must belong to a Window when calling this function. Returns true
    # (1) if the conversion is successful or false (0) otherwise.
    convert_point_to_window*: proc(self: ptr cef_view, point: ptr cef_point): cint {.cef_callback.}

    # Convert |point| to this View's coordinate system from that of the Window.
    # This View must belong to a Window when calling this function. Returns true
    # (1) if the conversion is successful or false (0) otherwise.
    convert_point_from_window*: proc(self: ptr cef_view, point: ptr cef_point): cint {.cef_callback.}

    # Convert |point| from this View's coordinate system to that of |view|.
    # |view| needs to be in the same Window but not necessarily the same view
    # hierarchy. Returns true (1) if the conversion is successful or false (0)
    # otherwise.
    convert_point_to_view*: proc(self, view: ptr cef_view, point: ptr cef_point): cint {.cef_callback.}

    # Convert |point| to this View's coordinate system from that |view|. |view|
    # needs to be in the same Window but not necessarily the same view hierarchy.
    # Returns true (1) if the conversion is successful or false (0) otherwise.
    convert_point_from_view*: proc(self, view: ptr cef_view, point: ptr cef_point): cint {.cef_callback.}

  # A View hosting a cef_browser_t instance. Methods must be called on the
  # browser process UI thread unless otherwise indicated.
  cef_browser_view* = object of cef_view
    # Returns the cef_browser_t hosted by this BrowserView. Will return NULL if
    # the browser has not yet been created or has already been destroyed.

    get_browser*: proc(self: ptr cef_browser_view): ptr cef_browser {.cef_callback.}

  # A View representing a button. Depending on the specific type, the button
  # could be implemented by a native control or custom rendered. Methods must be
  # called on the browser process UI thread unless otherwise indicated.
  cef_button* = object of cef_view
    # Returns this Button as a LabelButton or NULL if this is not a LabelButton.
    as_label_button*: proc(self: ptr cef_button): ptr cef_label_button {.cef_callback.}

    # Sets the current display state of the Button.
    set_state*: proc(self: ptr cef_button, state: cef_button_state) {.cef_callback.}

    # Returns the current display state of the Button.
    get_state*: proc(self: ptr cef_button): cef_button_state {.cef_callback.}

    # Sets the tooltip text that will be displayed when the user hovers the mouse
    # cursor over the Button.
    set_tooltip_text*: proc(self: ptr cef_button, tooltip_text: ptr cef_string) {.cef_callback.}

    # Sets the accessible name that will be exposed to assistive technology (AT).
    set_accessible_name*: proc(self: ptr cef_button, name: ptr cef_string) {.cef_callback.}

  # A Panel is a container in the views hierarchy that can contain other Views as
  # children. Methods must be called on the browser process UI thread unless
  # otherwise indicated.
  cef_panel* = object of cef_view
    # Returns this Panel as a Window or NULL if this is not a Window.
    as_window*: proc(self: ptr cef_panel): ptr cef_window {.cef_callback.}

    # Set this Panel's Layout to FillLayout and return the FillLayout object.
    set_to_fill_layout*: proc(self: ptr cef_panel): ptr cef_fill_layout {.cef_callback.}

    # Set this Panel's Layout to BoxLayout and return the BoxLayout object.
    set_to_box_layout*: proc(self: ptr cef_panel,
      settings: ptr cef_box_layout_settings): ptr cef_box_layout {.cef_callback.}

    # Get the Layout.
    get_layout*: proc(self: ptr cef_panel): ptr cef_layout {.cef_callback.}

    # Lay out the child Views (set their bounds based on sizing heuristics
    # specific to the current Layout).
    layout*: proc(self: ptr cef_panel) {.cef_callback.}

    # Add a child View.
    add_child_view*: proc(self: ptr cef_panel, view: ptr cef_view) {.cef_callback.}

    # Add a child View at the specified |index|. If |index| matches the result of
    # GetChildCount() then the View will be added at the end.
    add_child_view_at*: proc(self: ptr cef_panel,
      view: ptr cef_view, index: cint) {.cef_callback.}

    # Move the child View to the specified |index|. A negative value for |index|
    # will move the View to the end.
    reorder_child_view*: proc(self: ptr cef_panel,
      view: ptr cef_view, index: cint) {.cef_callback.}

    # Remove a child View. The View can then be added to another Panel.
    remove_child_view*: proc(self: ptr cef_panel, view: ptr cef_view) {.cef_callback.}

    # Remove all child Views. The removed Views will be deleted if the client
    # holds no references to them.
    remove_all_child_views*: proc(self: ptr cef_panel) {.cef_callback.}

    # Returns the number of child Views.
    get_child_view_count*: proc(self: ptr cef_panel): csize_t {.cef_callback.}

    # Returns the child View at the specified |index|.
    get_child_view_at*: proc(self: ptr cef_panel, index: cint): ptr cef_view {.cef_callback.}

  # A ScrollView will show horizontal and/or vertical scrollbars when necessary
  # based on the size of the attached content view. Methods must be called on the
  # browser process UI thread unless otherwise indicated.
  cef_scroll_view* = object of cef_view
    # Set the content View. The content View must have a specified size (e.g. via
    # cef_view_t::SetBounds or cef_view_tDelegate::GetPreferredSize).
    set_content_view*: proc(self: ptr cef_scroll_view, view: ptr cef_view) {.cef_callback.}

    # Returns the content View.
    get_content_view*: proc(self: ptr cef_scroll_view): ptr cef_view {.cef_callback.}

    # Returns the visible region of the content View.
    get_visible_content_rect*: proc(self: ptr cef_scroll_view): cef_rect {.cef_callback.}

    # Returns true (1) if the horizontal scrollbar is currently showing.
    has_horizontal_scrollbar*: proc(self: ptr cef_scroll_view): cint {.cef_callback.}

    # Returns the height of the horizontal scrollbar.
    get_horizontal_scrollbar_height*: proc(self: ptr cef_scroll_view): cint {.cef_callback.}

    # Returns true (1) if the vertical scrollbar is currently showing.
    has_vertical_scrollbar*: proc(self: ptr cef_scroll_view): cint {.cef_callback.}

    # Returns the width of the vertical scrollbar.
    get_vertical_scrollbar_width*: proc(self: ptr cef_scroll_view): cint {.cef_callback.}

  # A Textfield supports editing of text. This control is custom rendered with no
  # platform-specific code. Methods must be called on the browser process UI
  # thread unless otherwise indicated.
  cef_textfield* = object of cef_view
    # Sets whether the text will be displayed as asterisks.
    set_password_input*: proc(self: ptr cef_textfield, password_input: cint) {.cef_callback.}

    # Returns true (1) if the text will be displayed as asterisks.
    is_password_input*: proc(self: ptr cef_textfield): cint {.cef_callback.}

    # Sets whether the text will read-only.
    set_read_only*: proc(self: ptr cef_textfield, read_only: cint) {.cef_callback.}

    # Returns true (1) if the text is read-only.
    is_read_only*: proc(self: ptr cef_textfield): cint {.cef_callback.}

    # Returns the currently displayed text.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_text*: proc(self: ptr cef_textfield): cef_string_userfree {.cef_callback.}

    # Sets the contents to |text|. The cursor will be moved to end of the text if
    # the current position is outside of the text range.
    set_text*: proc(self: ptr cef_textfield, text: ptr cef_string) {.cef_callback.}

    # Appends |text| to the previously-existing text.
    append_text*: proc(self: ptr cef_textfield, text: ptr cef_string) {.cef_callback.}

    # Inserts |text| at the current cursor position replacing any selected text.
    insert_or_replace_text*: proc(self: ptr cef_textfield,
      text: ptr cef_string) {.cef_callback.}

    # Returns true (1) if there is any selected text.
    has_selection*: proc(self: ptr cef_textfield): cint {.cef_callback.}

    # Returns the currently selected text.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_selected_text*: proc(self: ptr cef_textfield): cef_string_userfree {.cef_callback.}

    # Selects all text. If |reversed| is true (1) the range will end at the
    # logical beginning of the text; this generally shows the leading portion of
    # text that overflows its display area.
    select_all*: proc(self: ptr cef_textfield, reversed: cint) {.cef_callback.}

    # Clears the text selection and sets the caret to the end.
    clear_selection*: proc(self: ptr cef_textfield) {.cef_callback.}

    # Returns the selected logical text range.
    get_selected_range*: proc(self: ptr cef_textfield): cef_range {.cef_callback.}

    # Selects the specified logical text range.
    select_range*: proc(self: ptr cef_textfield, the_range: ptr cef_range) {.cef_callback.}

    # Returns the current cursor position.
    get_cursor_position*: proc(self: ptr cef_textfield): csize_t {.cef_callback.}

    # Sets the text color.
    set_text_color*: proc(self: ptr cef_textfield, color: cef_color) {.cef_callback.}

    # Returns the text color.
    get_text_color*: proc(self: ptr cef_textfield): cef_color {.cef_callback.}

    # Sets the selection text color.
    set_selection_text_color*: proc(self: ptr cef_textfield, color: cef_color) {.cef_callback.}

    # Returns the selection text color.
    get_selection_text_color*: proc(self: ptr cef_textfield): cef_color {.cef_callback.}

    # Sets the selection background color.
    set_selection_background_color*: proc(
      self: ptr cef_textfield, color: cef_color) {.cef_callback.}

    # Returns the selection background color.
    get_selection_background_color*: proc(self: ptr cef_textfield): cef_color {.cef_callback.}

    # Sets the font list. The format is "<FONT_FAMILY_LIST>,[STYLES] <SIZE>",
    # where: - FONT_FAMILY_LIST is a comma-separated list of font family names, -
    # STYLES is an optional space-separated list of style names (case-sensitive
    #   "Bold" and "Italic" are supported), and
    # - SIZE is an integer font size in pixels with the suffix "px".
    #
    # Here are examples of valid font description strings: - "Arial, Helvetica,
    # Bold Italic 14px" - "Arial, 14px"
    set_font_list*: proc(self: ptr cef_textfield,font_list: ptr cef_string) {.cef_callback.}

    # Applies |color| to the specified |range| without changing the default
    # color. If |range| is NULL the color will be set on the complete text
    # contents.
    apply_text_color*: proc(self: ptr cef_textfield, color: cef_color, the_range: ptr cef_range) {.cef_callback.}

    # Applies |style| to the specified |range| without changing the default
    # style. If |add| is true (1) the style will be added, otherwise the style
    # will be removed. If |range| is NULL the style will be set on the complete
    # text contents.
    apply_text_style*: proc(self: ptr cef_textfield,
      style: cef_text_style, add: int, the_range: ptr cef_range) {.cef_callback.}

    # Returns true (1) if the action associated with the specified command id is
    # enabled. See additional comments on execute_command().
    is_command_enabled*: proc(self: ptr cef_textfield, command_id: cint): cint {.cef_callback.}

    # Performs the action associated with the specified command id. Valid values
    # include IDS_APP_UNDO, IDS_APP_REDO, IDS_APP_CUT, IDS_APP_COPY,
    # IDS_APP_PASTE, IDS_APP_DELETE, IDS_APP_SELECT_ALL, IDS_DELETE_* and
    # IDS_MOVE_*. See include/cef_pack_strings.h for definitions.
    execute_command*: proc(self: ptr cef_textfield, command_id: cint): cint {.cef_callback.}

    # Clears Edit history.
    clear_edit_history*: proc(self: ptr cef_textfield) {.cef_callback.}

    # Sets the placeholder text that will be displayed when the Textfield is
    # NULL.
    set_placeholder_text*: proc(self: ptr cef_textfield, text: ptr cef_string) {.cef_callback.}

    # Returns the placeholder text that will be displayed when the Textfield is
    # NULL.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_placeholder_text*: proc(self: ptr cef_textfield): cef_string_userfree {.cef_callback.}

    # Sets the placeholder text color.
    set_placeholder_text_color*: proc(self: ptr cef_textfield,
      color: cef_color) {.cef_callback.}

    # Returns the placeholder text color.
    get_placeholder_text_color*: proc(self: ptr cef_textfield): cef_color {.cef_callback.}

    # Set the accessible name that will be exposed to assistive technology (AT).
    set_accessible_name*: proc(self: ptr cef_textfield,
      name: ptr cef_string) {.cef_callback.}

  # A Window is a top-level Window/widget in the Views hierarchy. By default it
  # will have a non-client area with title bar, icon and buttons that supports
  # moving and resizing. All size and position values are in density independent
  # pixels (DIP) unless otherwise indicated. Methods must be called on the
  # browser process UI thread unless otherwise indicated.
  cef_window* = object of cef_panel
    # Show the Window.
    show*: proc(self: ptr cef_window) {.cef_callback.}

    # Hide the Window.
    hide*: proc(self: ptr cef_window) {.cef_callback.}

    # Sizes the Window to |size| and centers it in the current display.
    center_window*: proc(self: ptr cef_window, size: ptr cef_size) {.cef_callback.}

    # Close the Window.
    close*: proc(self: ptr cef_window) {.cef_callback.}

    # Returns true (1) if the Window has been closed.
    is_closed*: proc(self: ptr cef_window): cint {.cef_callback.}

    # Activate the Window, assuming it already exists and is visible.
    activate*: proc(self: ptr cef_window) {.cef_callback.}

    # Deactivate the Window, making the next Window in the Z order the active
    # Window.
    deactivate*: proc(self: ptr cef_window) {.cef_callback.}

    # Returns whether the Window is the currently active Window.
    is_active*: proc(self: ptr cef_window): cint {.cef_callback.}

    # Bring this Window to the top of other Windows in the Windowing system.
    bring_to_top*: proc(self: ptr cef_window) {.cef_callback.}

    # Set the Window to be on top of other Windows in the Windowing system.
    set_always_on_top*: proc(self: ptr cef_window, on_top: cint) {.cef_callback.}

    # Returns whether the Window has been set to be on top of other Windows in
    # the Windowing system.
    is_always_on_top*: proc(self: ptr cef_window): cint {.cef_callback.}

    # Maximize the Window.
    maximize*: proc(self: ptr cef_window) {.cef_callback.}

    # Minimize the Window.
    minimize*: proc(self: ptr cef_window) {.cef_callback.}

    # Restore the Window.
    restore*: proc(self: ptr cef_window) {.cef_callback.}

    # Set fullscreen Window state.
    set_fullscreen*: proc(self: ptr cef_window, fullscreen: cint) {.cef_callback.}

    # Returns true (1) if the Window is maximized.
    is_maximized*: proc(self: ptr cef_window): cint {.cef_callback.}

    # Returns true (1) if the Window is minimized.
    is_minimized*: proc(self: ptr cef_window): cint {.cef_callback.}

    # Returns true (1) if the Window is fullscreen.
    is_fullscreen*: proc(self: ptr cef_window): cint {.cef_callback.}

    # Set the Window title.
    set_title*: proc(self: ptr cef_window, title: ptr cef_string) {.cef_callback.}

    # Get the Window title.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_title*: proc(self: ptr cef_window): cef_string_userfree {.cef_callback.}

    # Set the Window icon. This should be a 16x16 icon suitable for use in the
    # Windows's title bar.
    set_window_icon*: proc(self: ptr cef_window, image: ptr cef_image) {.cef_callback.}

    # Get the Window icon.
    get_window_icon*: proc(self: ptr cef_window): ptr cef_image {.cef_callback.}

    # Set the Window App icon. This should be a larger icon for use in the host
    # environment app switching UI. On Windows, this is the ICON_BIG used in Alt-
    # Tab list and Windows taskbar. The Window icon will be used by default if no
    # Window App icon is specified.
    set_window_app_icon*: proc(self: ptr cef_window, image: ptr cef_image) {.cef_callback.}

    # Get the Window App icon.
    get_window_app_icon*: proc(self: ptr cef_window): ptr cef_image {.cef_callback.}

    # Show a menu with contents |menu_model|. |screen_point| specifies the menu
    # position in screen coordinates. |anchor_position| specifies how the menu
    # will be anchored relative to |screen_point|.
    show_menu*: proc(self: ptr cef_window,
      menu_model: ptr cef_menu_model, screen_point: ptr cef_point,
      anchor_position: cef_menu_anchor_position) {.cef_callback.}

    # Cancel the menu that is currently showing, if any.
    cancel_menu*: proc(self: ptr cef_window) {.cef_callback.}

    # Returns the Display that most closely intersects the bounds of this Window.
    # May return NULL if this Window is not currently displayed.
    get_display*: proc(self: ptr cef_window): ptr cef_display {.cef_callback.}

    # Returns the bounds (size and position) of this Window's client area.
    # Position is in screen coordinates.
    get_client_area_bounds_in_screen*: proc(self: ptr cef_window): cef_rect {.cef_callback.}

    # Set the regions where mouse events will be intercepted by this Window to
    # support drag operations. Call this function with an NULL vector to clear
    # the draggable regions. The draggable region bounds should be in window
    # coordinates.
    set_draggable_regions*: proc(self: ptr cef_window,
      regionsCount: csize_t, regions: ptr cef_draggable_region) {.cef_callback.}

    # Retrieve the platform window handle for this Window.
    get_window_handle*: proc(self: ptr cef_window): cef_window_handle {.cef_callback.}

    # Simulate a key press. |key_code| is the VKEY_* value from Chromium's
    # ui/events/keycodes/keyboard_codes.h header (VK_* values on Windows).
    # |event_flags| is some combination of EVENTFLAG_SHIFT_DOWN,
    # EVENTFLAG_CONTROL_DOWN and/or EVENTFLAG_ALT_DOWN. This function is exposed
    # primarily for testing purposes.
    send_key_press*: proc(self: ptr cef_window, key_code: cint, event_flags: uint32) {.cef_callback.}

    # Simulate a mouse move. The mouse cursor will be moved to the specified
    # (screen_x, screen_y) position. This function is exposed primarily for
    # testing purposes.
    send_mouse_move*: proc(self: ptr cef_window, screen_x, screen_y: cint) {.cef_callback.}

    # Simulate mouse down and/or mouse up events. |button| is the mouse button
    # type. If |mouse_down| is true (1) a mouse down event will be sent. If
    # |mouse_up| is true (1) a mouse up event will be sent. If both are true (1)
    # a mouse down event will be sent followed by a mouse up event (equivalent to
    # clicking the mouse button). The events will be sent using the current
    # cursor position so make sure to call send_mouse_move() first to position
    # the mouse. This function is exposed primarily for testing purposes.
    send_mouse_events*: proc(self: ptr cef_window,
      button: cef_mouse_button_type, mouse_down, mouse_up: cint) {.cef_callback.}

  # LabelButton is a button with optional text and/or icon. Methods must be
  # called on the browser process UI thread unless otherwise indicated.
  cef_label_button* = object of cef_button
    # Returns this LabelButton as a MenuButton or NULL if this is not a
    # MenuButton.
    as_menu_button*: proc(self: ptr cef_label_button): ptr cef_menu_button {.cef_callback.}

    # Sets the text shown on the LabelButton. By default |text| will also be used
    # as the accessible name.
    set_text*: proc(self: ptr cef_label_button, text: ptr cef_string) {.cef_callback.}

    # Returns the text shown on the LabelButton.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_text*: proc(self: ptr cef_label_button): cef_string_userfree {.cef_callback.}

    # Sets the image shown for |button_state|. When this Button is drawn if no
    # image exists for the current state then the image for
    # cef_button_state_NORMAL, if any, will be shown.
    set_image*: proc(self: ptr cef_label_button,
      state: cef_button_state, image: ptr cef_image) {.cef_callback.}

    # Returns the image shown for |button_state|. If no image exists for that
    # state then the image for cef_button_state_NORMAL will be returned.
    get_image*: proc(self: ptr cef_label_button, state: cef_button_state): ptr cef_image {.cef_callback.}

    # Sets the text color shown for the specified button |for_state| to |color|.
    set_text_color*: proc(self: ptr cef_label_button,
      for_state: cef_button_state, color: cef_color) {.cef_callback.}

    # Sets the text colors shown for the non-disabled states to |color|.
    set_enabled_text_colors*: proc(self: ptr cef_label_button,
      color: cef_color) {.cef_callback.}

    # Sets the font list. The format is "<FONT_FAMILY_LIST>,[STYLES] <SIZE>",
    # where: - FONT_FAMILY_LIST is a comma-separated list of font family names, -
    # STYLES is an optional space-separated list of style names (case-sensitive
    #   "Bold" and "Italic" are supported), and
    # - SIZE is an integer font size in pixels with the suffix "px".
    #
    # Here are examples of valid font description strings: - "Arial, Helvetica,
    # Bold Italic 14px" - "Arial, 14px"
    set_font_list*: proc(self: ptr cef_label_button,
      font_list: ptr cef_string) {.cef_callback.}

    # Sets the horizontal alignment; reversed in RTL. Default is
    # CEF_HORIZONTAL_ALIGNMENT_CENTER.
    set_horizontal_alignment*: proc(
      self: ptr cef_label_button, alignment: cef_horizontal_alignment) {.cef_callback.}

    # Reset the minimum size of this LabelButton to |size|.
    set_minimum_size*: proc(self: ptr cef_label_button,
      size: ptr cef_size) {.cef_callback.}

    # Reset the maximum size of this LabelButton to |size|.
    set_maximum_size*: proc(self: ptr cef_label_button,
      size: ptr cef_size) {.cef_callback.}

  # This structure typically, but not always, corresponds to a physical display
  # connected to the system. A fake Display may exist on a headless system, or a
  # Display may correspond to a remote, virtual display. All size and position
  # values are in density independent pixels (DIP) unless otherwise indicated.
  # Methods must be called on the browser process UI thread unless otherwise
  # indicated.
  cef_display* = object of cef_base
    # Returns the unique identifier for this Display.
    get_id*: proc(self: ptr cef_display): int64 {.cef_callback.}

    # Returns this Display's device pixel scale factor. This specifies how much
    # the UI should be scaled when the actual output has more pixels than
    # standard displays (which is around 100~120dpi). The potential return values
    # differ by platform.
    get_device_scale_factor*: proc(self: ptr cef_display): cfloat {.cef_callback.}

    # Convert |point| from density independent pixels (DIP) to pixel coordinates
    # using this Display's device scale factor.
    vconvert_point_to_pixels*: proc(self: ptr cef_display,
      point: ptr cef_point) {.cef_callback.}

    # Convert |point| from pixel coordinates to density independent pixels (DIP)
    # using this Display's device scale factor.
    vconvert_point_from_pixels*: proc(self: ptr cef_display,
      point: ptr cef_point) {.cef_callback.}

    # Returns this Display's bounds. This is the full size of the display.
    get_bounds*: proc(self: ptr cef_display): cef_rect {.cef_callback.}

    # Returns this Display's work area. This excludes areas of the display that
    # are occupied for window manager toolbars, etc.
    get_work_area*: proc(self: ptr cef_display): cef_rect {.cef_callback.}

    # Returns this Display's rotation in degrees.
    get_rotation*: proc(self: ptr cef_display): cint {.cef_callback.}

  # MenuButton is a button with optional text, icon and/or menu marker that shows
  # a menu when clicked with the left mouse button. All size and position values
  # are in density independent pixels (DIP) unless otherwise indicated. Methods
  # must be called on the browser process UI thread unless otherwise indicated.
  cef_menu_button* = object of cef_label_button
    # Show a menu with contents |menu_model|. |screen_point| specifies the menu
    # position in screen coordinates. |anchor_position| specifies how the menu
    # will be anchored relative to |screen_point|. This function should be called
    # from cef_menu_button_delegate_t::on_menu_button_pressed().
    show_menu*: proc(self: ptr cef_menu_button,
      menu_model: ptr cef_menu_model, screen_point: ptr cef_point,
      anchor_position: cef_menu_anchor_position) {.cef_callback.}

  # Implement this structure to handle view events. The functions of this
  # structure will be called on the browser process UI thread unless otherwise
  # indicated.
  cef_view_delegate* = object of cef_base
    # Return the preferred size for |view|. The Layout will use this information
    # to determine the display size.
    get_preferred_size*: proc(self: ptr cef_view_delegate, view: ptr cef_view): cef_size {.cef_callback.}

    # Return the minimum size for |view|.
    get_minimum_size*: proc(self: ptr cef_view_delegate, view: ptr cef_view): cef_size {.cef_callback.}

    # Return the maximum size for |view|.
    get_maximum_size*: proc(self: ptr cef_view_delegate, view: ptr cef_view): cef_size {.cef_callback.}

    # Return the height necessary to display |view| with the provided |width|. If
    # not specified the result of get_preferred_size().height will be used by
    # default. Override if |view|'s preferred height depends upon the width (for
    # example, with Labels).
    get_height_for_width*: proc(self: ptr cef_view_delegate,
      view: ptr cef_view, width: cint): cint {.cef_callback.}

    # Called when the parent of |view| has changed. If |view| is being added to
    # |parent| then |added| will be true (1). If |view| is being removed from
    # |parent| then |added| will be false (0). If |view| is being reparented the
    # remove notification will be sent before the add notification. Do not modify
    # the view hierarchy in this callback.
    on_parent_view_changed*: proc(self: ptr cef_view_delegate,
      view: ptr cef_view, added: cint, parent: ptr cef_view) {.cef_callback.}

    # Called when a child of |view| has changed. If |child| is being added to
    # |view| then |added| will be true (1). If |child| is being removed from
    # |view| then |added| will be false (0). If |child| is being reparented the
    # remove notification will be sent to the old parent before the add
    # notification is sent to the new parent. Do not modify the view hierarchy in
    # this callback.
    on_child_view_changed*: proc(self: ptr cef_view_delegate,
      view: ptr cef_view, added: cint, child: ptr cef_view) {.cef_callback.}

  # Implement this structure to handle BrowserView events. The functions of this
  # structure will be called on the browser process UI thread unless otherwise
  # indicated.
  cef_browser_view_delegate* = object of cef_view_delegate
    # Called when |browser| associated with |browser_view| is created. This
    # function will be called after cef_life_span_handler_t::on_after_created()
    # is called for |browser| and before on_popup_browser_view_created() is
    # called for |browser|'s parent delegate if |browser| is a popup.
    on_browser_created*: proc(self: ptr cef_browser_view_delegate,
      browser_view: ptr cef_browser_view, browser: ptr cef_browser) {.cef_callback.}

    # Called when |browser| associated with |browser_view| is destroyed. Release
    # all references to |browser| and do not attempt to execute any functions on
    # |browser| after this callback returns. This function will be called before
    # cef_life_span_handler_t::on_before_close() is called for |browser|.
    on_browser_destroyed*: proc(self: ptr cef_browser_view_delegate,
      browser_view: ptr cef_browser_view, browser: ptr cef_browser) {.cef_callback.}

    # Called before a new popup BrowserView is created. The popup originated from
    # |browser_view|. |settings| and |client| are the values returned from
    # cef_life_span_handler_t::on_before_popup(). |is_devtools| will be true (1)
    # if the popup will be a DevTools browser. Return the delegate that will be
    # used for the new popup BrowserView.
    get_delegate_for_popup_browser_view*: proc(self: ptr cef_browser_view_delegate,
      browser_view: ptr cef_browser_view, settings: ptr cef_browser_settings,
      client: ptr cef_client, is_devtools: cint): ptr cef_browser_view_delegate {.cef_callback.}

    # Called after |popup_browser_view| is created. This function will be called
    # after cef_life_span_handler_t::on_after_created() and on_browser_created()
    # are called for the new popup browser. The popup originated from
    # |browser_view|. |is_devtools| will be true (1) if the popup is a DevTools
    # browser. Optionally add |popup_browser_view| to the views hierarchy
    # yourself and return true (1). Otherwise return false (0) and a default
    # cef_window_t will be created for the popup.
    on_popup_browser_view_created*: proc(self: ptr cef_browser_view_delegate,
      browser_view: ptr cef_browser_view,
      popup_browser_view: ptr cef_browser_view, is_devtools: cint): cint {.cef_callback.}

  # Implement this structure to handle Panel events. The functions of this
  # structure will be called on the browser process UI thread unless otherwise
  # indicated.
  cef_panel_delegate* = object of cef_view_delegate

  # Implement this structure to handle Button events. The functions of this
  # structure will be called on the browser process UI thread unless otherwise
  # indicated.
  cef_button_delegate* = object of cef_view_delegate
    # Called when |button| is pressed.
    on_button_pressed*: proc(self: ptr cef_button_delegate, button: ptr cef_button) {.cef_callback.}

  # Implement this structure to handle MenuButton events. The functions of this
  # structure will be called on the browser process UI thread unless otherwise
  # indicated.
  cef_menu_button_delegate* = object of cef_button_delegate
    # Called when |button| is pressed. Call cef_menu_button_t::show_menu() to
    # show the resulting menu at |screen_point|.
    on_menu_button_pressed*: proc(self: ptr cef_menu_button_delegate,
      menu_button: ptr cef_menu_button, screen_point: ptr cef_point) {.cef_callback.}

  # Implement this structure to handle Textfield events. The functions of this
  # structure will be called on the browser process UI thread unless otherwise
  # indicated.
  cef_textfield_delegate* = object of cef_view_delegate
    # Called when |textfield| recieves a keyboard event. |event| contains
    # information about the keyboard event. Return true (1) if the keyboard event
    # was handled or false (0) otherwise for default handling.
    on_key_event*: proc(self: ptr cef_textfield_delegate,
      textfield: ptr cef_textfield,
      event: ptr cef_key_event): cint {.cef_callback.}

    # Called after performing a user action that may change |textfield|.
    on_after_user_action*: proc(self: ptr cef_textfield_delegate,
      textfield: ptr cef_textfield) {.cef_callback.}

  # Implement this structure to handle window events. The functions of this
  # structure will be called on the browser process UI thread unless otherwise
  # indicated.
  cef_window_delegate* = object of cef_panel_delegate
    # Called when |window| is created.
    on_window_created*: proc(self: ptr cef_window_delegate,
      window: ptr cef_window) {.cef_callback.}

    # Called when |window| is destroyed. Release all references to |window| and
    # do not attempt to execute any functions on |window| after this callback
    # returns.
    on_window_destroyed*: proc(self: ptr cef_window_delegate,
      window: ptr cef_window) {.cef_callback.}

    # Return true (1) if |window| should be created without a frame or title bar.
    # The window will be resizable if can_resize() returns true (1). Use
    # cef_window_t::set_draggable_regions() to specify draggable regions.
    is_frameless*: proc(self: ptr cef_window_delegate,
      window: ptr cef_window): cint {.cef_callback.}

    # Return true (1) if |window| can be resized.
    can_resize*: proc(self: ptr cef_window_delegate,
      window: ptr cef_window): cint {.cef_callback.}

    # Return true (1) if |window| can be maximized.
    can_maximize*: proc(self: ptr cef_window_delegate,
      window: ptr cef_window): cint {.cef_callback.}

    # Return true (1) if |window| can be minimized.
    can_minimize*: proc(self: ptr cef_window_delegate,
      window: ptr cef_window): cint {.cef_callback.}

    # Return true (1) if |window| can be closed. This will be called for user-
    # initiated window close actions and when cef_window_t::close() is called.
    can_close*: proc(self: ptr cef_window_delegate,
      window: ptr cef_window): cint {.cef_callback.}

# Create a new BrowserView. The underlying cef_browser_t will not be created
# until this view is added to the views hierarchy.
proc cef_browser_view_create*(client: ptr cef_client, url: ptr cef_string,
  settings: ptr cef_browser_settings, request_context: ptr cef_request_context,
  delegate: ptr cef_browser_view_delegate): ptr cef_browser_view {.cef_import.}

# Returns the BrowserView associated with |browser|.
proc cef_browser_view_get_for_browser*(browser: ptr cef_browser): ptr cef_browser_view {.cef_import.}

# Create a new Panel.
proc cef_panel_create*(delegate: ptr cef_panel_delegate): ptr cef_panel {.cef_import.}

# Create a new Textfield.
proc cef_textfield_create*(delegate: ptr cef_textfield_delegate): ptr cef_textfield {.cef_import.}

# Create a new Window.
proc cef_window_create_top_level*(delegate: ptr cef_window_delegate): ptr cef_window {.cef_import.}

# Create a new LabelButton. A |delegate| must be provided to handle the button
# click. |text| will be shown on the LabelButton and used as the default
# accessible name. If |with_frame| is true (1) the button will have a visible
# frame at all times, center alignment, additional padding and a default
# minimum size of 70x33 DIP. If |with_frame| is false (0) the button will only
# have a visible frame on hover/press, left alignment, less padding and no
# default minimum size.
proc cef_label_button_create*(delegate: ptr cef_button_delegate,
  text: ptr cef_string, with_frame: cint): ptr cef_label_button {.cef_import.}

# Returns the primary Display.
proc cef_display_get_primary*(): ptr cef_display {.cef_import.}

# Returns the Display nearest |point|. Set |input_pixel_coords| to true (1) if
# |point| is in pixel coordinates instead of density independent pixels (DIP).
proc cef_display_get_nearest_point*(point: ptr cef_point, input_pixel_coords: cint): ptr cef_display {.cef_import.}

# Returns the Display that most closely intersects |bounds|.  Set
# |input_pixel_coords| to true (1) if |bounds| is in pixel coordinates instead
# of density independent pixels (DIP).
proc cef_display_get_matching_bounds*(bounds: ptr cef_rect, input_pixel_coords: cint): ptr cef_display {.cef_import.}

# Returns the total number of Displays. Mirrored displays are excluded; this
# function is intended to return the number of distinct, usable displays.
proc cef_display_get_count*(): csize_t {.cef_import.}

# Returns all Displays. Mirrored displays are excluded; this function is
# intended to return distinct, usable displays.
proc cef_display_get_alls*(displaysCount: var csize_t, displays: ptr ptr cef_display) {.cef_import.}

# Create a new MenuButton. A |delegate| must be provided to call show_menu()
# when the button is clicked. |text| will be shown on the MenuButton and used
# as the default accessible name. If |with_frame| is true (1) the button will
# have a visible frame at all times, center alignment, additional padding and a
# default minimum size of 70x33 DIP. If |with_frame| is false (0) the button
# will only have a visible frame on hover/press, left alignment, less padding
# and no default minimum size. If |with_menu_marker| is true (1) a menu marker
# will be added to the button.
proc cef_menu_button_create*(delegate: ptr cef_menu_button_delegate, text: ptr cef_string,
  with_frame: cint, with_menu_marker: cint): ptr cef_menu_button {.cef_import.}