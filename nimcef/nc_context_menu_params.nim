import cef_base_api, cef_context_menu_handler_api, nc_util

# Provides information about the context menu state. The methods of this
# structure can only be accessed on browser process the UI thread.
wrapAPI(NCContextMenuParams, cef_context_menu_params, false)

# Returns the X coordinate of the mouse where the context menu was invoked.
# Coords are relative to the associated RenderView's origin.
proc getXCoord*(self: NCContextMenuParams): int =
  self.wrapCall(get_xcoord, result)

# Returns the Y coordinate of the mouse where the context menu was invoked.
# Coords are relative to the associated RenderView's origin.
proc getYCoord*(self: NCContextMenuParams): int =
  self.wrapCall(get_ycoord, result)

# Returns flags representing the type of node that the context menu was
# invoked on.
proc getTypeFlags*(self: NCContextMenuParams): cef_context_menu_type_flags =
  self.wrapCall(get_type_flags, result)

# Returns the URL of the link, if any, that encloses the node that the
# context menu was invoked on.
proc getLinkUrl*(self: NCContextMenuParams): string =
  self.wrapCall(get_link_url, result)

# Returns the link URL, if any, to be used ONLY for "copy link address". We
# don't validate this field in the frontend process.
proc getUnfilteredLinkUrl*(self: NCContextMenuParams): string =
  self.wrapCall(get_unfiltered_link_url, result)

# Returns the source URL, if any, for the element that the context menu was
# invoked on. Example of elements with source URLs are img, audio, and video.
proc getSourceUrl*(self: NCContextMenuParams): string =
  self.wrapCall(get_source_url, result)

# Returns true (1) if the context menu was invoked on an image which has non-
# NULL contents.
proc hasImageContents*(self: NCContextMenuParams): bool =
  self.wrapCall(has_image_contents, result)

# Returns the URL of the top level page that the context menu was invoked on.
proc getPageUrl*(self: NCContextMenuParams): string =
  self.wrapCall(get_page_url, result)

# Returns the URL of the subframe that the context menu was invoked on.
proc getFrameUrl*(self: NCContextMenuParams): string =
  self.wrapCall(get_frame_url, result)

# Returns the character encoding of the subframe that the context menu was
# invoked on.
proc getFrameCharset*(self: NCContextMenuParams): string =
  self.wrapCall(get_frame_charset, result)

# Returns the type of context node that the context menu was invoked on.
proc getMediaType*(self: NCContextMenuParams): cef_context_menu_media_type =
  self.wrapCall(get_media_type, result)

# Returns flags representing the actions supported by the media element, if
# any, that the context menu was invoked on.
proc getMediaStateFlags*(self: NCContextMenuParams): cef_context_menu_media_state_flags =
  self.wrapCall(get_media_state_flags, result)

# Returns the text of the selection, if any, that the context menu was
# invoked on.
proc getSelectionText*(self: NCContextMenuParams): string =
  self.wrapCall(get_selection_text, result)

# Returns the text of the misspelled word, if any, that the context menu was
# invoked on.
proc getMisspelledWord*(self: NCContextMenuParams): string =
  self.wrapCall(get_misspelled_word, result)

# Returns true (1) if suggestions exist, false (0) otherwise. Fills in
# |suggestions| from the spell check service for the misspelled word if there
# is one.
proc getDictionarySuggestions*(self: NCContextMenuParams): seq[string] =
  self.wrapCall(get_dictionary_suggestions, result)

# Returns true (1) if the context menu was invoked on an editable node.
proc isEditable*(self: NCContextMenuParams): bool =
  self.wrapCall(is_editable, result)

# Returns true (1) if the context menu was invoked on an editable node where
# spell-check is enabled.
proc isSpellCheckEnabled*(self: NCContextMenuParams): bool =
  self.wrapCall(is_spell_check_enabled, result)

# Returns flags representing the actions supported by the editable node, if
# any, that the context menu was invoked on.
proc getEditStateFlags*(self: NCContextMenuParams): cef_context_menu_edit_state_flags =
  self.wrapCall(get_edit_state_flags, result)

# Returns true (1) if the context menu contains items specified by the
# renderer process (for example, plugin placeholder or pepper plugin menu
# items).
proc isCustomMenu*(self: NCContextMenuParams): bool =
  self.wrapCall(is_custom_menu, result)

# Returns true (1) if the context menu was invoked from a pepper plugin.
proc isPepperMenu*(self: NCContextMenuParams): bool =
  self.wrapCall(is_pepper_menu, result)