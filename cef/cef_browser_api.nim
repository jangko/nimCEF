import cef_base_api, cef_request_api, cef_drag_data_api, cef_frame_api, cef_client_api
import cef_process_message_api, cef_request_context_api, cef_navigation_entry_api

export cef_frame_api, cef_drag_data_api, cef_request_context_api
include cef_import

# Structure used to represent a browser window. When used in the browser
# process the functions of this structure may be called on any thread unless
# otherwise indicated in the comments. When used in the render process the
# functions of this structure may only be called on the main thread.
type
  cef_browser* = object
    base*: cef_base
    
    # Returns the browser host object. This function can only be called in the
    # browser process.
    get_host*: proc(self: ptr cef_browser): ptr cef_browser_host {.cef_callback.}
    
    # Returns true (1) if the browser can navigate backwards.
    can_go_back*: proc(self: ptr cef_browser): cint {.cef_callback.}
    
    # Navigate backwards.
    go_back*: proc(self: ptr cef_browser) {.cef_callback.}
  
    # Returns true (1) if the browser can navigate forwards.
    can_go_forward*: proc(self: ptr cef_browser): cint {.cef_callback.}
    
    # Navigate forwards.
    go_forward*: proc(self: ptr cef_browser) {.cef_callback.}
    
    # Returns true (1) if the browser is currently loading.
    is_loading*: proc(self: ptr cef_browser): cint {.cef_callback.}
  
    # Reload the current page.
    reload*: proc(self: ptr cef_browser) {.cef_callback.}
  
    # Reload the current page ignoring any cached data.
    reload_ignore_cache*: proc(self: ptr cef_browser) {.cef_callback.}
  
    # Stop loading the page.
    stop_load*: proc(self: ptr cef_browser) {.cef_callback.}
    
    # Returns the globally unique identifier for this browser.
    get_identifier*: proc(self: ptr cef_browser): cint {.cef_callback.}
  
    # Returns true (1) if this object is pointing to the same handle as |that|
    # object.
    is_same*: proc(self: ptr cef_browser,
      that: ptr cef_browser): cint {.cef_callback.}
  
    # Returns true (1) if the window is a popup window.
    is_popup*: proc(self: ptr cef_browser): cint {.cef_callback.}
    
    # Returns true (1) if a document has been loaded in the browser.
    has_document*: proc(self: ptr cef_browser): cint {.cef_callback.}
    
    # Returns the main (top-level) frame for the browser window.
    get_main_frame*: proc(self: ptr cef_browser): ptr cef_frame {.cef_callback.}
  
    # Returns the focused frame for the browser window.
    get_focused_frame*: proc(self: ptr cef_browser): ptr cef_frame {.cef_callback.}
    
    # Returns the frame with the specified identifier, or NULL if not found.
    get_frame_byident*: proc(self: ptr cef_browser, identifier: int64): ptr cef_frame {.cef_callback.}
  
    # Returns the frame with the specified name, or NULL if not found.
    get_frame*: proc(self: ptr cef_browser,
      name: ptr cef_string): ptr cef_frame {.cef_callback.}
  
    # Returns the number of frames that currently exist.
    get_frame_count*: proc(self: ptr cef_browser): csize {.cef_callback.}
  
    # Returns the identifiers of all existing frames.
    get_frame_identifiers*: proc(self: ptr cef_browser,
      identifiersCount: var csize, identifiers: var int64) {.cef_callback.}
  
    # Returns the names of all existing frames.
    get_frame_names*: proc(self: ptr cef_browser,
      names: cef_string_list) {.cef_callback.}
    
    # Send a message to the specified |target_process|. Returns true (1) if the
    # message was sent successfully.
    send_process_message*: proc(self: ptr cef_browser,
      target_process: cef_process_id,
      message: ptr cef_process_message): cint {.cef_callback.}
   
  # Structure used to represent the browser process aspects of a browser window.
  # The functions of this structure can only be called in the browser process.
  # They may be called on any thread in that process unless otherwise indicated
  # in the comments.
  cef_browser_host* = object
    base*: cef_base
    # Returns the hosted browser object.
    get_browser*: proc(self: ptr cef_browser_host): ptr cef_browser {.cef_callback.}
  
    # Request that the browser close. The JavaScript 'onbeforeunload' event will
    # be fired. If |force_close| is false (0) the event handler, if any, will be
    # allowed to prompt the user and the user can optionally cancel the close. If
    # |force_close| is true (1) the prompt will not be displayed and the close
    # will proceed. Results in a call to cef_life_span_handler_t::do_close() if
    # the event handler allows the close or if |force_close| is true (1). See
    # cef_life_span_handler_t::do_close() documentation for additional usage
    # information.
    close_browser*: proc(self: ptr cef_browser_host, force_close: cint) {.cef_callback.}
  
    # Set whether the browser is focused.
    set_focus*: proc(self: ptr cef_browser_host, focus: cint) {.cef_callback.}
  
    # Set whether the window containing the browser is visible
    # (minimized/unminimized, app hidden/unhidden, etc). Only used on Mac OS X.
    set_window_visibility*: proc(self: ptr cef_browser_host, visible: cint) {.cef_callback.}

    # Retrieve the window handle for this browser.
    get_window_handle*: proc(self: ptr cef_browser_host): cef_window_handle {.cef_callback.}

    # Retrieve the window handle of the browser that opened this browser. Will
    # return NULL for non-popup windows. This function can be used in combination
    # with custom handling of modal windows.
    get_opener_window_handle*: proc(self: ptr cef_browser_host): cef_window_handle {.cef_callback.}
  
    # Returns the client for this browser.
    get_client*: proc(self: ptr cef_browser_host): ptr cef_client {.cef_callback.}

    # Returns the request context for this browser.
    get_request_context*: proc(self: ptr cef_browser_host): ptr cef_request_context {.cef_callback.}

    # Get the current zoom level. The default zoom level is 0.0. This function
    # can only be called on the UI thread.
    get_zoom_level*: proc(self: ptr cef_browser_host): cdouble {.cef_callback.}
  
    # Change the zoom level to the specified value. Specify 0.0 to reset the zoom
    # level. If called on the UI thread the change will be applied immediately.
    # Otherwise, the change will be applied asynchronously on the UI thread.
  
    set_zoom_level*: proc(self: ptr cef_browser_host, zoomLevel: cdouble) {.cef_callback.}

    # Call to run a file chooser dialog. Only a single file chooser dialog may be
    # pending at any given time. |mode| represents the type of dialog to display.
    # |title| to the title to be used for the dialog and may be NULL to show the
    # default title ("Open" or "Save" depending on the mode). |default_file_path|
    # is the path with optional directory and/or file name component that will be
    # initially selected in the dialog. |accept_filters| are used to restrict the
    # selectable file types and may any combination of (a) valid lower-cased MIME
    # types (e.g. "text/*" or "image/*"), (b) individual file extensions (e.g.
    # ".txt" or ".png"), or (c) combined description and file extension delimited
    # using "|" and "{.cef_callback.}" (e.g. "Image Types|.png{.cef_callback.}.gif{.cef_callback.}.jpg").
    # |selected_accept_filter| is the 0-based index of the filter that will be
    # selected by default. |callback| will be executed after the dialog is
    # dismissed or immediately if another dialog is already pending. The dialog
    # will be initiated asynchronously on the UI thread.
  
    run_file_dialog*: proc(self: ptr cef_browser_host,
      mode: cef_file_dialog_mode, title, default_file_path: ptr cef_string, 
      accept_filters: cef_string_list, selected_accept_filter: cint,
      callback: ptr cef_run_file_dialog_callback) {.cef_callback.}

    # Download the file at |url| using cef_download_handler_t.
    start_download*: proc(self: ptr cef_browser_host,
      url: ptr cef_string) {.cef_callback.}
  
    # Print the current browser contents.
    print*: proc(self: ptr cef_browser_host) {.cef_callback.}
    
    # Print the current browser contents to the PDF file specified by |path| and
    # execute |callback| on completion. The caller is responsible for deleting
    # |path| when done. For PDF printing to work on Linux you must implement the
    # cef_print_handler_t::GetPdfPaperSize function.
    print_to_pdf*: proc(self: ptr cef_browser_host,
      path: ptr cef_string, settings: ptr cef_pdf_print_settings,
      callback: ptr cef_pdf_print_callback) {.cef_callback.}
    
    # Search for |searchText|. |identifier| can be used to have multiple searches
    # running simultaniously. |forward| indicates whether to search forward or
    # backward within the page. |matchCase| indicates whether the search should
    # be case-sensitive. |findNext| indicates whether this is the first request
    # or a follow-up. The cef_find_handler_t instance, if any, returned via
    # cef_client_t::GetFindHandler will be called to report find results.    
    find*: proc(self: ptr cef_browser_host, identifier: cint,
      searchText: ptr cef_string, forward, matchCase: cint,
      findNext: cint) {.cef_callback.}
    
    # Cancel all searches that are currently going on.
    stop_finding*: proc(self: ptr cef_browser_host,
      clearSelection: cint) {.cef_callback.}
    
    # Open developer tools in its own window. If |inspect_element_at| is non-
    # NULL the element at the specified (x,y) location will be inspected.
    show_dev_tools*: proc(self: ptr cef_browser_host,
        windowInfo: ptr cef_window_info,
        client: ptr cef_client,
        setting: ptr cef_browser_settings,
        inspect_element_at: ptr cef_point) {.cef_callback.}
    
    # Explicitly close the developer tools window if one exists for this browser
    # instance.
    close_dev_tools*: proc(self: ptr cef_browser_host) {.cef_callback.}
    
    # Retrieve a snapshot of current navigation entries as values sent to the
    # specified visitor. If |current_only| is true (1) only the current
    # navigation entry will be sent, otherwise all navigation entries will be
    # sent.
    get_navigation_entries*: proc(self: ptr cef_browser_host,
        visitor: ptr cef_navigation_entry_visitor, current_only: cint) {.cef_callback.}
    
    # Set whether mouse cursor change is disabled.
    set_mouse_cursor_change_disabled*: proc(self: ptr cef_browser_host, disabled: cint) {.cef_callback.}
    
    # Returns true (1) if mouse cursor change is disabled.
    is_mouse_cursor_change_disabled*: proc(self: ptr cef_browser_host): cint {.cef_callback.}
    
    # If a misspelled word is currently selected in an editable node calling this
    # function will replace it with the specified |word|.
    replace_misspelling*: proc(self: ptr cef_browser_host,
      word: ptr cef_string) {.cef_callback.}
    
    # Add the specified |word| to the spelling dictionary.
    add_word_to_dictionary*: proc(self: ptr cef_browser_host,
      word: ptr cef_string) {.cef_callback.}
    
    # Returns true (1) if window rendering is disabled.
    is_window_rendering_disabled*: proc(self: ptr cef_browser_host): cint {.cef_callback.}
    
    # Notify the browser that the widget has been resized. The browser will first
    # call cef_render_handler_t::GetViewRect to get the new size and then call
    # cef_render_handler_t::OnPaint asynchronously with the updated regions. This
    # function is only used when window rendering is disabled.
    was_resized*: proc(self: ptr cef_browser_host) {.cef_callback.}
    
    # Notify the browser that it has been hidden or shown. Layouting and
    # cef_render_handler_t::OnPaint notification will stop when the browser is
    # hidden. This function is only used when window rendering is disabled.
    was_hidden*: proc(self: ptr cef_browser_host, hidden: cint) {.cef_callback.}
    
    # Send a notification to the browser that the screen info has changed. The
    # browser will then call cef_render_handler_t::GetScreenInfo to update the
    # screen information with the new values. This simulates moving the webview
    # window from one display to another, or changing the properties of the
    # current display. This function is only used when window rendering is
    # disabled.
    notify_screen_info_changed*: proc(self: ptr cef_browser_host) {.cef_callback.}
    
    # Invalidate the view. The browser will call cef_render_handler_t::OnPaint
    # asynchronously. This function is only used when window rendering is
    # disabled.
    invalidate*: proc(self: ptr cef_browser_host,
      ptype: cef_paint_element_type) {.cef_callback.}
    
    # Send a key event to the browser.
    send_key_event*: proc(self: ptr cef_browser_host,
      event: ptr cef_key_event) {.cef_callback.}
    
    # Send a mouse click event to the browser. The |x| and |y| coordinates are
    # relative to the upper-left corner of the view.
    send_mouse_click_event*: proc(self: ptr cef_browser_host,
      event: ptr cef_mouse_event, ptype: cef_mouse_button_type,
      mouseUp: cint, clickCount: cint) {.cef_callback.}
    
    # Send a mouse move event to the browser. The |x| and |y| coordinates are
    # relative to the upper-left corner of the view.
    send_mouse_move_event*: proc(self: ptr cef_browser_host,
      event: ptr cef_mouse_event, mouseLeave: cint) {.cef_callback.}
    
    # Send a mouse wheel event to the browser. The |x| and |y| coordinates are
    # relative to the upper-left corner of the view. The |deltaX| and |deltaY|
    # values represent the movement delta in the X and Y directions respectively.
    # In order to scroll inside select popups with window rendering disabled
    # cef_render_handler_t::GetScreenPoint should be implemented properly.
    send_mouse_wheel_event*: proc(self: ptr cef_browser_host,
       event: ptr cef_mouse_event, deltaX, deltaY: cint) {.cef_callback.}
    
    # Send a focus event to the browser.
    send_focus_event*: proc(self: ptr cef_browser_host,
      setFocus: cint) {.cef_callback.}
    
    # Send a capture lost event to the browser.
    send_capture_lost_event*: proc(self: ptr cef_browser_host) {.cef_callback.}
    
    # Notify the browser that the window hosting it is about to be moved or
    # resized. This function is only used on Windows and Linux.
    notify_move_or_resize_started*: proc(self: ptr cef_browser_host) {.cef_callback.}
    
    # Returns the maximum rate in frames per second (fps) that
    # cef_render_handler_t:: OnPaint will be called for a windowless browser. The
    # actual fps may be lower if the browser cannot generate frames at the
    # requested rate. The minimum value is 1 and the maximum value is 60 (default
    # 30). This function can only be called on the UI thread.
    get_windowless_frame_rate*: proc(self: ptr cef_browser_host): cint {.cef_callback.}
    
    # Set the maximum rate in frames per second (fps) that cef_render_handler_t::
    # OnPaint will be called for a windowless browser. The actual fps may be
    # lower if the browser cannot generate frames at the requested rate. The
    # minimum value is 1 and the maximum value is 60 (default 30). Can also be
    # set at browser creation via cef_browser_tSettings.windowless_frame_rate.
    set_windowless_frame_rate*: proc(self: ptr cef_browser_host, frame_rate: cint) {.cef_callback.}
    
    # Get the NSTextInputContext implementation for enabling IME on Mac when
    # window rendering is disabled.
    get_nstext_input_context*:proc(self: ptr cef_browser_host): cef_text_input_context {.cef_callback.}
    
    # Handles a keyDown event prior to passing it through the NSTextInputClient
    # machinery.
    handle_key_event_before_text_input_client*: proc(self: ptr cef_browser_host, 
      keyEvent: cef_event_handle) {.cef_callback.}
    
    # Performs any additional actions after NSTextInputClient handles the event.
    handle_key_event_after_text_input_client*: proc(self: ptr cef_browser_host, 
      keyEvent: cef_event_handle) {.cef_callback.}
    
    # Call this function when the user drags the mouse into the web view (before
    # calling DragTargetDragOver/DragTargetLeave/DragTargetDrop). |drag_data|
    # should not contain file contents as this type of data is not allowed to be
    # dragged into the web view. File contents can be removed using
    # cef_drag_data_t::ResetFileContents (for example, if |drag_data| comes from
    # cef_render_handler_t::StartDragging). This function is only used when
    # window rendering is disabled.
    drag_target_drag_enter*: proc(self: ptr cef_browser_host,
      drag_data: ptr cef_drag_data,
      event: ptr cef_mouse_event,
      allowed_ops: cef_drag_operations_mask) {.cef_callback.}
    
    # Call this function each time the mouse is moved across the web view during
    # a drag operation (after calling DragTargetDragEnter and before calling
    # DragTargetDragLeave/DragTargetDrop). This function is only used when window
    # rendering is disabled.
    drag_target_drag_over*: proc(self: ptr cef_browser_host,
      event: ptr cef_mouse_event,
      allowed_ops: cef_drag_operations_mask) {.cef_callback.}
    
    # Call this function when the user drags the mouse out of the web view (after
    # calling DragTargetDragEnter). This function is only used when window
    # rendering is disabled.
    drag_target_drag_leave*: proc(self: ptr cef_browser_host) {.cef_callback.}
    
    # Call this function when the user completes the drag operation by dropping
    # the object onto the web view (after calling DragTargetDragEnter). The
    # object being dropped is |drag_data|, given as an argument to the previous
    # DragTargetDragEnter call. This function is only used when window rendering
    # is disabled.
    drag_target_drop*: proc(self: ptr cef_browser_host,
      event: ptr cef_mouse_event) {.cef_callback.}
    
    # Call this function when the drag operation started by a
    # cef_render_handler_t::StartDragging call has ended either in a drop or by
    # being cancelled. |x| and |y| are mouse coordinates relative to the upper-
    # left corner of the view. If the web view is both the drag source and the
    # drag target then all DragTarget* functions should be called before
    # DragSource* mthods. This function is only used when window rendering is
    # disabled.
    drag_source_ended_at*: proc(self: ptr cef_browser_host,
      x, y: cint, op: cef_drag_operations_mask) {.cef_callback.}
    
    # Call this function when the drag operation started by a
    # cef_render_handler_t::StartDragging call has completed. This function may
    # be called immediately without first calling DragSourceEndedAt to cancel a
    # drag operation. If the web view is both the drag source and the drag target
    # then all DragTarget* functions should be called before DragSource* mthods.
    # This function is only used when window rendering is disabled.
    drag_source_system_drag_ended*: proc(self: ptr cef_browser_host) {.cef_callback.}
 
  # Callback structure for cef_browser_host_t::RunFileDialog. The functions of
  # this structure will be called on the browser process UI thread.
  cef_run_file_dialog_callback* = object
    # Called asynchronously after the file dialog is dismissed.
    # |selected_accept_filter| is the 0-based index of the value selected from
    # the accept filters array passed to cef_browser_host_t::RunFileDialog.
    # |file_paths| will be a single value or a list of values depending on the
    # dialog mode. If the selection was cancelled |file_paths| will be NULL.
    
    on_file_dialog_dismissed*: proc(self: ptr cef_run_file_dialog_callback, 
      selected_accept_filter: cint, file_paths: cef_string_list) {.cef_callback.}

  # Callback structure for cef_browser_host_t::GetNavigationEntries. The
  # functions of this structure will be called on the browser process UI thread.

  cef_navigation_entry_visitor* = object
    # Method that will be executed. Do not keep a reference to |entry| outside of
    # this callback. Return true (1) to continue visiting entries or false (0) to
    # stop. |current| is true (1) if this entry is the currently loaded
    # navigation entry. |index| is the 0-based index of this entry and |total| is
    # the total number of entries.
  
    visit*: proc(self: ptr cef_navigation_entry_visitor,
      entry: ptr cef_navigation_entry, current, index, total: cint): cint {.cef_callback.}

  # Callback structure for cef_browser_host_t::PrintToPDF. The functions of this
  # structure will be called on the browser process UI thread.

  cef_pdf_print_callback* = object  
    # Method that will be executed when the PDF printing has completed. |path| is
    # the output path. |ok| will be true (1) if the printing completed
    # successfully or false (0) otherwise.
  
    on_pdf_print_finished*: proc(self: ptr cef_pdf_print_callback, path: ptr cef_string,
      ok: cint): cint {.cef_callback.}

# Create a new browser window using the window parameters specified by
# |windowInfo|. All values will be copied internally and the actual window will
# be created on the UI thread. If |request_context| is NULL the global request
# context will be used. This function can be called on any browser process
# thread and will not block.
proc cef_browser_host_create_browser*(windowInfo: ptr cef_window_info, client: ptr cef_client,
  url: ptr cef_string, settings: ptr cef_browser_settings,
  request_context: ptr cef_request_context): cint {.cef_import.}

# Create a new browser window using the window parameters specified by
# |windowInfo|. If |request_context| is NULL the global request context will be
# used. This function can only be called on the browser process UI thread.
proc cef_browser_host_create_browser_sync*(windowInfo: ptr cef_window_info, client: ptr cef_client,
  url: ptr cef_string, settings: ptr cef_browser_settings,
  request_context: ptr cef_request_context): ptr cef_browser {.cef_import.}
    
