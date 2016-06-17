import cef_base_api, cef_frame_api, cef_menu_model_api
include cef_import

type
  # Callback structure used for continuation of custom context menu display.
  cef_run_context_menu_callback* = object of cef_base
    # Complete context menu display by selecting the specified |command_id| and
    # |event_flags|.
    cont*: proc(self: ptr cef_run_context_menu_callback,
      command_id: cint, event_flags: cef_event_flags) {.cef_callback.}

    # Cancel context menu display.
    cancel*: proc(self: ptr cef_run_context_menu_callback) {.cef_callback.}

  # Implement this structure to handle context menu events. The functions of this
  # structure will be called on the UI thread.
  cef_context_menu_handler* = object of cef_base
    # Called before a context menu is displayed. |params| provides information
    # about the context menu state. |model| initially contains the default
    # context menu. The |model| can be cleared to show no context menu or
    # modified to show a custom menu. Do not keep references to |params| or
    # |model| outside of this callback.

    on_before_context_menu*: proc(self: ptr cef_context_menu_handler,
        browser: ptr_cef_browser,
        frame: ptr cef_frame, params: ptr cef_context_menu_params,
        model: ptr cef_menu_model) {.cef_callback.}

    # Called to allow custom display of the context menu. |params| provides
    # information about the context menu state. |model| contains the context menu
    # model resulting from OnBeforeContextMenu. For custom display return true
    # (1) and execute |callback| either synchronously or asynchronously with the
    # selected command ID. For default display return false (0). Do not keep
    # references to |params| or |model| outside of this callback.
    run_context_menu*: proc(self: ptr cef_context_menu_handler,
        browser: ptr_cef_browser, frame: ptr cef_frame,
        params: ptr cef_context_menu_params,
        model: ptr cef_menu_model,
        callback: ptr cef_run_context_menu_callback): cint {.cef_callback.}

    # Called to execute a command selected from the context menu. Return true (1)
    # if the command was handled or false (0) for the default implementation. See
    # cef_menu_id_t for the command ids that have default implementations. All
    # user-defined command ids should be between MENU_ID_USER_FIRST and
    # MENU_ID_USER_LAST. |params| will have the same values as what was passed to
    # on_before_context_menu(). Do not keep a reference to |params| outside of
    # this callback.
    on_context_menu_command*: proc(self: ptr cef_context_menu_handler,
      browser: ptr_cef_browser, frame: ptr cef_frame, params: ptr cef_context_menu_params,
      command_id: cint, event_flags: cef_event_flags): cint {.cef_callback.}

    # Called when the context menu is dismissed irregardless of whether the menu
    # was NULL or a command was selected.
    on_context_menu_dismissed*: proc(self: ptr cef_context_menu_handler,
      browser: ptr_cef_browser, frame: ptr cef_frame) {.cef_callback.}

  # Provides information about the context menu state. The ethods of this
  # structure can only be accessed on browser process the UI thread.
  cef_context_menu_params* = object of cef_base
    # Returns the X coordinate of the mouse where the context menu was invoked.
    # Coords are relative to the associated RenderView's origin.
    get_xcoord*: proc(self: ptr cef_context_menu_params): cint {.cef_callback.}

    # Returns the Y coordinate of the mouse where the context menu was invoked.
    # Coords are relative to the associated RenderView's origin.
    get_ycoord*: proc(self: ptr cef_context_menu_params): cint {.cef_callback.}

    # Returns flags representing the type of node that the context menu was
    # invoked on.
    get_type_flags*: proc(self: ptr cef_context_menu_params): cef_context_menu_type_flags {.cef_callback.}

    # Returns the URL of the link, if any, that encloses the node that the
    # context menu was invoked on.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_link_url*: proc(self: ptr cef_context_menu_params): cef_string_userfree {.cef_callback.}

    # Returns the link URL, if any, to be used ONLY for "copy link address". We
    # don't validate this field in the frontend process.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_unfiltered_link_url*: proc(self: ptr cef_context_menu_params): cef_string_userfree {.cef_callback.}

    # Returns the source URL, if any, for the element that the context menu was
    # invoked on. Example of elements with source URLs are img, audio, and video.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_source_url*: proc(self: ptr cef_context_menu_params): cef_string_userfree {.cef_callback.}

    # Returns true (1) if the context menu was invoked on an image which has non-
    # NULL contents.
    has_image_contents*: proc(self: ptr cef_context_menu_params): cint {.cef_callback.}

    # Returns the URL of the top level page that the context menu was invoked on.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_page_url*: proc(self: ptr cef_context_menu_params): cef_string_userfree {.cef_callback.}

    # Returns the URL of the subframe that the context menu was invoked on.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_frame_url*: proc(self: ptr cef_context_menu_params): cef_string_userfree {.cef_callback.}

    # Returns the character encoding of the subframe that the context menu was
    # invoked on.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_frame_charset*: proc(self: ptr cef_context_menu_params): cef_string_userfree {.cef_callback.}

    # Returns the type of context node that the context menu was invoked on.
    get_media_type*: proc(self: ptr cef_context_menu_params): cef_context_menu_media_type {.cef_callback.}

    # Returns flags representing the actions supported by the media element, if
    # any, that the context menu was invoked on.
    get_media_state_flags*: proc(self: ptr cef_context_menu_params): cef_context_menu_media_state_flags {.cef_callback.}

    # Returns the text of the selection, if any, that the context menu was
    # invoked on.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_selection_text*: proc(self: ptr cef_context_menu_params): cef_string_userfree {.cef_callback.}

    # Returns the text of the misspelled word, if any, that the context menu was
    # invoked on.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_misspelled_word*: proc(self: ptr cef_context_menu_params): cef_string_userfree {.cef_callback.}

    # Returns true (1) if suggestions exist, false (0) otherwise. Fills in
    # |suggestions| from the spell check service for the misspelled word if there
    # is one.
    get_dictionary_suggestions*: proc(self: ptr cef_context_menu_params, suggestions: cef_string_list): cint {.cef_callback.}

    # Returns true (1) if the context menu was invoked on an editable node.
    is_editable*: proc(self: ptr cef_context_menu_params): cint {.cef_callback.}

    # Returns true (1) if the context menu was invoked on an editable node where
    # spell-check is enabled.
    is_spell_check_enabled*: proc(self: ptr cef_context_menu_params): cint {.cef_callback.}

    # Returns flags representing the actions supported by the editable node, if
    # any, that the context menu was invoked on.
    get_edit_state_flags*: proc(self: ptr cef_context_menu_params): cef_context_menu_edit_state_flags {.cef_callback.}

    # Returns true (1) if the context menu contains items specified by the
    # renderer process (for example, plugin placeholder or pepper plugin menu
    # items).
    is_custom_menu*: proc(self: ptr cef_context_menu_params): cint {.cef_callback.}

    # Returns true (1) if the context menu was invoked from a pepper plugin.
    is_pepper_menu*: proc(self: ptr cef_context_menu_params): cint {.cef_callback.}