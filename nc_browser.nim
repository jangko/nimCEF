import nc_types, cef/cef_browser_api, nc_util, nc_process_message, nc_client
import nc_request_context, nc_settings, nc_navigation_entry

type
  # Callback structure for cef_browser_host_t::RunFileDialog. The functions of
  # this structure will be called on the browser process UI thread.
  NCRunFileDialogCallback* = ref object of RootObj
    handler: cef_run_file_dialog_callback

  # Callback structure for cef_browser_host_t::GetNavigationEntries. The
  # functions of this structure will be called on the browser process UI thread.
  NCNavigationEntryVisitor* = ref object of RootObj
    handler: cef_navigation_entry_visitor
    
  # Callback structure for cef_browser_host_t::PrintToPDF. The functions of this
  # structure will be called on the browser process UI thread.
  NCPdfPrintCallback* = ref object of RootObj
    handler: cef_pdf_print_callback
      
      
# Called asynchronously after the file dialog is dismissed.
# |selected_accept_filter| is the 0-based index of the value selected from
# the accept filters array passed to cef_browser_host_t::RunFileDialog.
# |file_paths| will be a single value or a list of values depending on the
# dialog mode. If the selection was cancelled |file_paths| will be NULL.
method OnFileDialogDismissed*(self: NCRunFileDialogCallback,
  selected_accept_filter: int, file_paths: seq[string]) {.base.} =
  discard
    
# Method that will be executed. Do not keep a reference to |entry| outside of
# this callback. Return true (1) to continue visiting entries or false (0) to
# stop. |current| is true (1) if this entry is the currently loaded
# navigation entry. |index| is the 0-based index of this entry and |total| is
# the total number of entries.
method NavigationVisit*(self: NCNavigationEntryVisitor, entry: NCNavigationEntry, 
  current, index, total: int): bool =
  result = false

# Method that will be executed when the PDF printing has completed. |path| is
# the output path. |ok| will be true (1) if the printing completed
# successfully or false (0) otherwise.
method OnPdfPrintFinished*(self: NCPdfPrintCallback, path: string, ok: bool): bool =
  result = false

# Returns the browser host object. This function can only be called in the
# browser process.
proc GetHost*(self: NCBrowser): NCBrowserHost =
  result = self.get_host(self)

# Returns true (1) if the browser can navigate backwards.
proc CanGoBack*(self: NCBrowser): bool =
  result = self.can_go_back(self) == 1.cint

# Navigate backwards.
proc GoBack*(self: NCBrowser) =
  self.go_back(self)

# Returns true (1) if the browser can navigate forwards.
proc CanGoForward*(self: NCBrowser): bool =
  self.can_go_forward(self) == 1.cint

# Navigate forwards.
proc GoGorward*(self: NCBrowser) =
  self.go_forward(self)

# Returns true (1) if the browser is currently loading.
proc IsLoading*(self: NCBrowser): bool =
  result = self.is_loading(self) == 1.cint

# Reload the current page.
proc Reload*(self: NCBrowser) =
  self.reload(self)

# Reload the current page ignoring any cached data.
proc ReloadIgnoreCache*(self: NCBrowser) =
  self.reload_ignore_cache(self)

# Stop loading the page.
proc StopLoad*(self: NCBrowser) =
  self.stop_load(self)

# Returns the globally unique identifier for this browser.
proc GetIdentifier*(self: NCBrowser): int =
  result = self.get_identifier(self).int

# Returns true (1) if this object is pointing to the same handle as |that|
# object.
proc IsSame*(self, that: NCBrowser): bool =
  add_ref(that)
  result = self.is_same(self, that) == 1.cint

# Returns true (1) if the window is a popup window.
proc IsPopup*(self: NCBrowser): bool =
  result = self.is_popup(self) == 1.cint

# Returns true (1) if a document has been loaded in the browser.
proc HasDocument*(self: NCBrowser): bool =
  result = self.has_document(self) == 1.cint

# Returns the main (top-level) frame for the browser window.
proc GetMainFrame*(self: NCBrowser): NCFrame =
  result = self.get_main_frame(self)

# Returns the focused frame for the browser window.
proc GetFocusedFrame*(self: NCBrowser): NCFrame =
  result = self.get_focused_frame(self)

# Returns the frame with the specified identifier, or NULL if not found.
proc GetFrameByident*(self: NCBrowser, identifier: int64): NCFrame =
  result = self.get_frame_byident(self, identifier)

# Returns the frame with the specified name, or NULL if not found.
proc GetFrame*(self: NCBrowser, name: string): NCFrame =
  var cname = to_cef(name)
  result = self.get_frame(self, cname)
  nc_free(cname)

# Returns the number of frames that currently exist.
proc GetFrameCount*(self: NCBrowser): int =
  result = self.get_frame_count(self).int

# Returns the identifiers of all existing frames.
proc GetFrameIdentifiers*(self: NCBrowser): seq[int64] =
  var count = self.get_frame_count(self)
  result = newSeq[int64](count.int)
  self.get_frame_identifiers(self, count, result[0].addr)

# Returns the names of all existing frames.
proc GetFrameNames*(self: NCBrowser): seq[string] =
  var names = cef_string_list_alloc()
  self.get_frame_names(self, names)
  result = to_nim(names)

# Send a message to the specified |target_process|. Returns true (1) if the
# message was sent successfully.
proc SendProcessMessage*(self: NCBrowser, target_process: cef_process_id, message: NCProcessMessage): bool =
  add_ref(message)
  result = self.send_process_message(self, target_process, message) == 1.cint

# Returns the hosted browser object.
proc GetBrowser*(self: NCBrowserHost): NCBrowser =
  result = self.get_browser(self)

# Request that the browser close. The JavaScript 'onbeforeunload' event will
# be fired. If |force_close| is false (0) the event handler, if any, will be
# allowed to prompt the user and the user can optionally cancel the close. If
# |force_close| is true (1) the prompt will not be displayed and the close
# will proceed. Results in a call to cef_life_span_handler_t::do_close() if
# the event handler allows the close or if |force_close| is true (1). See
# cef_life_span_handler_t::do_close() documentation for additional usage
# information.
proc CloseBrowser*(self: NCBrowserHost, force_close: bool) =
  self.close_browser(self, force_close.cint)

# Set whether the browser is focused.
proc SetFocus*(self: NCBrowserHost, focus: bool) =
  self.set_focus(self, focus.cint)

# Set whether the window containing the browser is visible
# (minimized/unminimized, app hidden/unhidden, etc). Only used on Mac OS X.
proc SetWindowVisibility*(self: NCBrowserHost, visible: int) =
  self.set_window_visibility(self, visible.cint)

# Retrieve the window handle for this browser.
proc GetWindowGandle*(self: NCBrowserHost): cef_window_handle =
  result = self.get_window_handle(self)

# Retrieve the window handle of the browser that opened this browser. Will
# return NULL for non-popup windows. This function can be used in combination
# with custom handling of modal windows.
proc GetOpenerWindowGandle*(self: NCBrowserHost): cef_window_handle =
  result = self.get_opener_window_handle(self)

# Returns the client for this browser.
proc GetClient*(self: NCBrowserHost): NCClient =
  result = client_to_client(self.get_client(self))

# Returns the request context for this browser.
proc GetRequestContext*(self: NCBrowserHost): NCRequestContext =
  result = nc_wrap(self.get_request_context(self))

# Get the current zoom level. The default zoom level is 0.0. This function
# can only be called on the UI thread.
proc GetZoomLevel*(self: NCBrowserHost): float64 =
  result = self.get_zoom_level(self).float64

# Change the zoom level to the specified value. Specify 0.0 to reset the zoom
# level. If called on the UI thread the change will be applied immediately.
# Otherwise, the change will be applied asynchronously on the UI thread.
proc SetZoomLevel*(self: NCBrowserHost, zoomLevel: float64) =
  self.set_zoom_level(self, zoomLevel.cdouble)

# Call to run a file chooser dialog. Only a single file chooser dialog may be
# pending at any given time. |mode| represents the type of dialog to display.
# |title| to the title to be used for the dialog and may be NULL to show the
# default title ("Open" or "Save" depending on the mode). |default_file_path|
# is the path with optional directory and/or file name component that will be
# initially selected in the dialog. |accept_filters| are used to restrict the
# selectable file types and may any combination of (a) valid lower-cased MIME
# types (e.g. "text/*" or "image/*"), (b) individual file extensions (e.g.
# ".txt" or ".png"), or (c) combined description and file extension delimited
# using "|" and "=" (e.g. "Image Types|.png=.gif=.jpg").
# |selected_accept_filter| is the 0-based index of the filter that will be
# selected by default. |callback| will be executed after the dialog is
# dismissed or immediately if another dialog is already pending. The dialog
# will be initiated asynchronously on the UI thread.
proc RunFileDialog*(self: NCBrowserHost,
  mode: cef_file_dialog_mode, title, default_file_path: string,
  accept_filters: seq[string], selected_accept_filter: int,
  callback: ptr cef_run_file_dialog_callback) =

  let ctitle = to_cef(title)
  let cpath = to_cef(default_file_path)
  let clist = to_cef(accept_filters)
  self.run_file_dialog(self, mode, ctitle, cpath, clist, selected_accept_filter.cint, callback)
  nc_free(clist)
  nc_free(ctitle)
  nc_free(cpath)

# Download the file at |url| using cef_download_handler_t.
proc StartDownload*(self: NCBrowserHost, url: string) =
  let curl = to_cef(url)
  self.start_download(self, curl)
  nc_free(curl)

# Print the current browser contents.
proc Print*(self: NCBrowserHost) =
  self.print(self)

# Print the current browser contents to the PDF file specified by |path| and
# execute |callback| on completion. The caller is responsible for deleting
# |path| when done. For PDF printing to work on Linux you must implement the
# cef_print_handler_t::GetPdfPaperSize function.
proc PrintToPdf*(self: NCBrowserHost, path: string, settings: NCPdfPrintSettings, callback: ptr cef_pdf_print_callback) =
  let cpath = to_cef(path)
  var csettings: cef_pdf_print_settings
  self.print_to_pdf(self, cpath, csettings.addr, callback)
  nc_free(cpath)
  csettings.clear()

# Search for |searchText|. |identifier| can be used to have multiple searches
# running simultaniously. |forward| indicates whether to search forward or
# backward within the page. |matchCase| indicates whether the search should
# be case-sensitive. |findNext| indicates whether this is the first request
# or a follow-up. The cef_find_handler_t instance, if any, returned via
# cef_client_t::GetFindHandler will be called to report find results.
proc Find*(self: NCBrowserHost, identifier: int, searchText: string, forward, matchCase, findNext: bool) =
  let ctext = to_cef(searchText)
  self.find(self, identifier.cint, ctext, forward.cint, matchCase.cint, findNext.cint)
  nc_free(ctext)

# Cancel all searches that are currently going on.
proc StopFinding*(self: NCBrowserHost, clearSelection: bool) =
  self.stop_finding(self, clearSelection.cint)

# Open developer tools in its own window. If |inspect_element_at| is non-
# NULL the element at the specified (x,y) location will be inspected.
proc ShowDevTools*(self: NCBrowserHost, windowInfo: ptr cef_window_info, client: NCClient,
  setting: NCBrowserSettings, inspect_element_at: ptr cef_point) =
  var csettings: cef_browser_settings
  to_cef(setting, csettings)
  self.show_dev_tools(self, windowInfo, to_cclient(client), csettings.addr, inspect_element_at)
  csettings.clear()

# Explicitly close the developer tools window if one exists for this browser
# instance.
proc CloseDevTools*(self: NCBrowserHost) =
  self.close_dev_tools(self)

# Retrieve a snapshot of current navigation entries as values sent to the
# specified visitor. If |current_only| is true (1) only the current
# navigation entry will be sent, otherwise all navigation entries will be
# sent.
proc GetNavigationEntries*(self: NCBrowserHost,
  visitor: ptr cef_navigation_entry_visitor, current_only: bool) =
  self.get_navigation_entries(self, visitor, current_only.cint)

# Set whether mouse cursor change is disabled.
proc SetMouseCursorChangeDisabled*(self: NCBrowserHost, disabled: bool) =
  self.set_mouse_cursor_change_disabled(self, disabled.cint)

# Returns true (1) if mouse cursor change is disabled.
proc IsMouseCursorChangeDisabled*(self: NCBrowserHost): bool =
  self.is_mouse_cursor_change_disabled(self) == 1.cint

# If a misspelled word is currently selected in an editable node calling this
# function will replace it with the specified |word|.
proc ReplaceMisspelling*(self: NCBrowserHost, word: string) =
  let cword = to_cef(word)
  self.replace_misspelling(self, cword)
  nc_free(cword)

# Add the specified |word| to the spelling dictionary.
proc AddWordToDictionary*(self: NCBrowserHost, word: string) =
  let cword = to_cef(word)
  self.add_word_to_dictionary(self, cword)
  nc_free(cword)

# Returns true (1) if window rendering is disabled.
proc IsWindowRenderingDisabled*(self: NCBrowserHost): bool =
  self.is_window_rendering_disabled(self) == 1.cint

# Notify the browser that the widget has been resized. The browser will first
# call cef_render_handler_t::GetViewRect to get the new size and then call
# cef_render_handler_t::OnPaint asynchronously with the updated regions. This
# function is only used when window rendering is disabled.
proc WasResized*(self: NCBrowserHost) =
  self.was_resized(self)

# Notify the browser that it has been hidden or shown. Layouting and
# cef_render_handler_t::OnPaint notification will stop when the browser is
# hidden. This function is only used when window rendering is disabled.
proc WasHidden*(self: NCBrowserHost, hidden: bool) =
  self.was_hidden(self, hidden.cint)

# Send a notification to the browser that the screen info has changed. The
# browser will then call cef_render_handler_t::GetScreenInfo to update the
# screen information with the new values. This simulates moving the webview
# window from one display to another, or changing the properties of the
# current display. This function is only used when window rendering is
# disabled.
proc NotifyScreenInfoChanged*(self: NCBrowserHost) =
  self.notify_screen_info_changed(self)

# Invalidate the view. The browser will call cef_render_handler_t::OnPaint
# asynchronously. This function is only used when window rendering is
# disabled.
proc Invalidate*(self: NCBrowserHost, ptype: cef_paint_element_type) =
  self.invalidate(self, ptype)

# Send a key event to the browser.
proc SendKeyEvent*(self: NCBrowserHost, event: ptr cef_key_event) =
  self.send_key_event(self, event)

# Send a mouse click event to the browser. The |x| and |y| coordinates are
# relative to the upper-left corner of the view.
proc SendMouseClickEvent*(self: NCBrowserHost, event: ptr cef_mouse_event,
  ptype: cef_mouse_button_type, mouseUp: bool, clickCount: int) =
  self.send_mouse_click_event(self, event, ptype, mouseUp.cint, clickCount.cint)

# Send a mouse move event to the browser. The |x| and |y| coordinates are
# relative to the upper-left corner of the view.
proc SendMouseMoveEvent*(self: NCBrowserHost,
  event: ptr cef_mouse_event, mouseLeave: bool) =
  self.send_mouse_move_event(self, event, mouseLeave.cint)

# Send a mouse wheel event to the browser. The |x| and |y| coordinates are
# relative to the upper-left corner of the view. The |deltaX| and |deltaY|
# values represent the movement delta in the X and Y directions respectively.
# In order to scroll inside select popups with window rendering disabled
# cef_render_handler_t::GetScreenPoint should be implemented properly.
proc SendMouseWheelEvent*(self: NCBrowserHost,
   event: ptr cef_mouse_event, deltaX, deltaY: int) =
   self.send_mouse_wheel_event(self, event, deltaX.cint, deltaY.cint)

# Send a focus event to the browser.
proc SendFocusEvent*(self: NCBrowserHost, setFocus: bool) =
  self.send_focus_event(self, setFocus.cint)

# Send a capture lost event to the browser.
proc SendCaptureLostEvent*(self: NCBrowserHost) =
  self.send_capture_lost_event(self)

# Notify the browser that the window hosting it is about to be moved or
# resized. This function is only used on Windows and Linux.
proc NotifyMoveOrResizeStarted*(self: NCBrowserHost) =
  self.notify_move_or_resize_started(self)

# Returns the maximum rate in frames per second (fps) that
# cef_render_handler_t:: OnPaint will be called for a windowless browser. The
# actual fps may be lower if the browser cannot generate frames at the
# requested rate. The minimum value is 1 and the maximum value is 60 (default
# 30). This function can only be called on the UI thread.
proc GetWindowlessFrameRate*(self: NCBrowserHost): int =
  self.get_windowless_frame_rate(self).int

# Set the maximum rate in frames per second (fps) that cef_render_handler_t::
# OnPaint will be called for a windowless browser. The actual fps may be
# lower if the browser cannot generate frames at the requested rate. The
# minimum value is 1 and the maximum value is 60 (default 30). Can also be
# set at browser creation via cef_browser_tSettings.windowless_frame_rate.
proc SetWindowlessFrameRate*(self: NCBrowserHost, frame_rate: int) =
  self.set_windowless_frame_rate(self, frame_rate.cint)

# Get the NSTextInputContext implementation for enabling IME on Mac when
# window rendering is disabled.
proc GetNstextInputContext*(self: NCBrowserHost): cef_text_input_context =
  self.get_nstext_input_context(self)

# Handles a keyDown event prior to passing it through the NSTextInputClient
# machinery.
proc HandleKeyEventBeforeTextInputClient*(self: NCBrowserHost, keyEvent: cef_event_handle) =
  self.handle_key_event_before_text_input_client(self, keyEvent)

# Performs any additional actions after NSTextInputClient handles the event.
proc HandleKeyEventAfterTextInputClient*(self: NCBrowserHost, keyEvent: cef_event_handle) =
  self.handle_key_event_after_text_input_client(self, keyEvent)

# Call this function when the user drags the mouse into the web view (before
# calling DragTargetDragOver/DragTargetLeave/DragTargetDrop). |drag_data|
# should not contain file contents as this type of data is not allowed to be
# dragged into the web view. File contents can be removed using
# cef_drag_data_t::ResetFileContents (for example, if |drag_data| comes from
# cef_render_handler_t::StartDragging). This function is only used when
# window rendering is disabled.
proc DragTargetDragEnter*(self: NCBrowserHost, drag_data: ptr cef_drag_data,
  event: ptr cef_mouse_event, allowed_ops: cef_drag_operations_mask) =
  self.drag_target_drag_enter(self, drag_data, event, allowed_ops)

# Call this function each time the mouse is moved across the web view during
# a drag operation (after calling DragTargetDragEnter and before calling
# DragTargetDragLeave/DragTargetDrop). This function is only used when window
# rendering is disabled.
proc DragTargetDragOver*(self: NCBrowserHost, event: ptr cef_mouse_event,
  allowed_ops: cef_drag_operations_mask) =
  self.drag_target_drag_over(self, event, allowed_ops)

# Call this function when the user drags the mouse out of the web view (after
# calling DragTargetDragEnter). This function is only used when window
# rendering is disabled.
proc DragTargetDragLeave*(self: NCBrowserHost) =
  self.drag_target_drag_leave(self)

# Call this function when the user completes the drag operation by dropping
# the object onto the web view (after calling DragTargetDragEnter). The
# object being dropped is |drag_data|, given as an argument to the previous
# DragTargetDragEnter call. This function is only used when window rendering
# is disabled.
proc DragTargetDrop*(self: NCBrowserHost, event: ptr cef_mouse_event) =
  self.drag_target_drop(self, event)

# Call this function when the drag operation started by a
# cef_render_handler_t::StartDragging call has ended either in a drop or by
# being cancelled. |x| and |y| are mouse coordinates relative to the upper-
# left corner of the view. If the web view is both the drag source and the
# drag target then all DragTarget* functions should be called before
# DragSource* mthods. This function is only used when window rendering is
# disabled.
proc DragSourceEndedAt*(self: NCBrowserHost, x, y: int, op: cef_drag_operations_mask) =
  self.drag_source_ended_at(self, x.cint, y.cint, op)

# Call this function when the drag operation started by a
# cef_render_handler_t::StartDragging call has completed. This function may
# be called immediately without first calling DragSourceEndedAt to cancel a
# drag operation. If the web view is both the drag source and the drag target
# then all DragTarget* functions should be called before DragSource* mthods.
# This function is only used when window rendering is disabled.
proc DragSourceSystemDragEnded*(self: NCBrowserHost) =
  self.drag_source_system_drag_ended(self)


# Create a new browser window using the window parameters specified by
# |windowInfo|. All values will be copied internally and the actual window will
# be created on the UI thread. If |request_context| is NULL the global request
# context will be used. This function can be called on any browser process
# thread and will not block.
proc NCBrowserHostCreateBrowser*(windowInfo: ptr cef_window_info, client: NCClient,
  url: string, settings: NCBrowserSettings, request_context: NCRequestContext = nil): bool =
  let curl = to_cef(url)
  var csettings: cef_browser_settings
  to_cef(settings, csettings)
  result = cef_browser_host_create_browser(windowInfo, client.GetHandler(), curl, csettings.addr, 
    if request_context == nil: nil else: request_context.GetHandler()) == 1.cint
  nc_free(curl)
  csettings.clear()

# Create a new browser window using the window parameters specified by
# |windowInfo|. If |request_context| is NULL the global request context will be
# used. This function can only be called on the browser process UI thread.
proc NCBrowserHostCreateBrowserSync*(windowInfo: ptr cef_window_info, client: NCClient,
  url: string, settings: NCBrowserSettings, request_context: NCRequestContext = nil): NCBrowser =
  let curl = to_cef(url)
  var csettings: cef_browser_settings
  to_cef(settings, csettings)
  result = cef_browser_host_create_browser_sync(windowInfo, client.GetHandler(), curl, csettings.addr, 
    if request_context == nil: nil else: request_context.GetHandler())
  nc_free(curl)
  csettings.clear()