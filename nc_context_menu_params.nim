import cef/cef_base_api, cef/cef_context_menu_handler_api, nc_util

type
# Provides information about the context menu state. The methods of this
# structure can only be accessed on browser process the UI thread.
  NCContextMenuParams* = ptr cef_context_menu_params

# Returns the X coordinate of the mouse where the context menu was invoked.
# Coords are relative to the associated RenderView's origin.
proc GetXCoord*(self: NCContextMenuParams): int =
  result = self.get_xcoord(self).int

# Returns the Y coordinate of the mouse where the context menu was invoked.
# Coords are relative to the associated RenderView's origin.
proc GetYCoord*(self: NCContextMenuParams): int =
  result = self.get_ycoord(self).int

# Returns flags representing the type of node that the context menu was
# invoked on.
proc GetTypeFlags*(self: NCContextMenuParams): cef_context_menu_type_flags =
  result = self.get_type_flags(self)

# Returns the URL of the link, if any, that encloses the node that the
# context menu was invoked on.
# The resulting string must be freed by calling cef_string_userfree_free().
proc GetLinkUrl*(self: NCContextMenuParams): string =
  result = to_nim_string(self.get_link_url(self))

# Returns the link URL, if any, to be used ONLY for "copy link address". We
# don't validate this field in the frontend process.
# The resulting string must be freed by calling cef_string_userfree_free().
proc GetUnfilteredLinkUrl*(self: NCContextMenuParams): string =
  result = to_nim_string(self.get_unfiltered_link_url(self))

# Returns the source URL, if any, for the element that the context menu was
# invoked on. Example of elements with source URLs are img, audio, and video.
# The resulting string must be freed by calling cef_string_userfree_free().
proc GetSourceUrl*(self: NCContextMenuParams): string =
  result = to_nim_string(self.get_source_url(self))

# Returns true (1) if the context menu was invoked on an image which has non-
# NULL contents.
proc HasImageContents*(self: NCContextMenuParams): bool =
  result = self.has_image_contents(self) == 1.cint

# Returns the URL of the top level page that the context menu was invoked on.
# The resulting string must be freed by calling cef_string_userfree_free().
proc GetPageUrl*(self: NCContextMenuParams): string =
  result = to_nim_string(self.get_page_url(self))

# Returns the URL of the subframe that the context menu was invoked on.
# The resulting string must be freed by calling cef_string_userfree_free().
proc GetFrameUrl*(self: NCContextMenuParams): string =
  result = to_nim_string(self.get_frame_url(self))

# Returns the character encoding of the subframe that the context menu was
# invoked on.
# The resulting string must be freed by calling cef_string_userfree_free().
proc GetFrameCharset*(self: NCContextMenuParams): string =
  result = to_nim_string(self.get_frame_charset(self))

# Returns the type of context node that the context menu was invoked on.
proc GetMediaType*(self: NCContextMenuParams): cef_context_menu_media_type =
  result = self.get_media_type(self)

# Returns flags representing the actions supported by the media element, if
# any, that the context menu was invoked on.
proc GetMediaStateFlags*(self: NCContextMenuParams): cef_context_menu_media_state_flags =
  result = self.get_media_state_flags(self)

# Returns the text of the selection, if any, that the context menu was
# invoked on.
# The resulting string must be freed by calling cef_string_userfree_free().
proc GetSelectionText*(self: NCContextMenuParams): string =
  result = to_nim_string(self.get_selection_text(self))

# Returns the text of the misspelled word, if any, that the context menu was
# invoked on.
# The resulting string must be freed by calling cef_string_userfree_free().
proc GetMisspelledWord*(self: NCContextMenuParams): string =
  result = to_nim_string(self.get_misspelled_word(self))

# Returns true (1) if suggestions exist, false (0) otherwise. Fills in
# |suggestions| from the spell check service for the misspelled word if there
# is one.
proc GetDictionarySuggestions*(self: NCContextMenuParams): seq[string] =
  var suggestions = cef_string_list_alloc()
  if self.get_dictionary_suggestions(self, suggestions) == 1.cint:
    result = to_nim_and_free(suggestions)
  else:
    cef_string_list_free(suggestions)
    result = nil

# Returns true (1) if the context menu was invoked on an editable node.
proc IsEditable*(self: NCContextMenuParams): bool =
  result = self.is_editable(self) == 1.cint

# Returns true (1) if the context menu was invoked on an editable node where
# spell-check is enabled.
proc IsSpellCheckEnabled*(self: NCContextMenuParams): bool =
  result = self.is_spell_check_enabled(self) == 1.cint

# Returns flags representing the actions supported by the editable node, if
# any, that the context menu was invoked on.
proc GetEditStateFlags*(self: NCContextMenuParams): cef_context_menu_edit_state_flags =
  result = self.get_edit_state_flags(self)

# Returns true (1) if the context menu contains items specified by the
# renderer process (for example, plugin placeholder or pepper plugin menu
# items).
proc IsCustomMenu*(self: NCContextMenuParams): bool =
  result = self.is_custom_menu(self) == 1.cint

# Returns true (1) if the context menu was invoked from a pepper plugin.
proc IsPepperMenu*(self: NCContextMenuParams): bool =
  result = self.is_pepper_menu(self) == 1.cint