import cef/cef_menu_model_api, cef/cef_base_api

type
  # Supports creation and modification of menus. See cef_menu_id_t for the
  # command ids that have default implementations. All user-defined command ids
  # should be between MENU_ID_USER_FIRST and MENU_ID_USER_LAST. The functions of
  # this structure can only be accessed on the browser process the UI thread.  
  NCMenuModel* = ptr cef_menu_model

proc to_cef_string(str: string): ptr cef_string =
  result = cef_string_userfree_alloc()
  discard cef_string_from_utf8(str.cstring, str.len.csize, result)

# Clears the menu. Returns true *(1) on success.
proc Clear*(self: NCMenuModel): bool =
  result = self.clear(self) == 1.cint

# Returns the number of items in this menu.
proc GetCount*(self: NCMenuModel): int =
  result = self.get_count(self).int

# Add a separator to the menu. Returns true *(1) on success.
proc AddSeparator*(self: NCMenuModel): bool =
  result = self.add_separator(self) == 1.cint

# Add an item to the menu. Returns true *(1) on success.
proc AddItem*(self: NCMenuModel, command_id: int, label: string): bool =
  var clabel = to_cef_string(label)
  result = self.add_item(self, command_id.cint, clabel) == 1.cint
  cef_string_userfree_free(clabel)

# Add a check item to the menu. Returns true *(1) on success.
proc AddCheckItem*(self: NCMenuModel, command_id: int, label: string): bool =
  var clabel = to_cef_string(label)
  result = self.add_check_item(self, command_id.cint, clabel) == 1.cint
  cef_string_userfree_free(clabel)
  
# Add a radio item to the menu. Only a single item with the specified
# |group_id| can be checked at a time. Returns true *(1) on success.
proc AddRadioItem*(self: NCMenuModel, command_id: int, label: string, group_id: int): bool =
  var clabel = to_cef_string(label)
  result = self.add_radio_item(self, command_id.cint, clabel, group_id.cint) == 1.cint
  cef_string_userfree_free(clabel)
  
# Add a sub-menu to the menu. The new sub-menu is returned.
proc AddSubMenu*(self: NCMenuModel, command_id: int, label: string): NCMenuModel =
  var clabel = to_cef_string(label)
  result = self.add_sub_menu(self, command_id.cint, clabel)
  cef_string_userfree_free(clabel)
  
# Insert a separator in the menu at the specified |index|. Returns true *(1)
# on success.  
proc InsertSeparatorAt*(self: NCMenuModel, index: int): bool =
  result = self.insert_separator_at(self, index.cint) == 1.cint
  
# Insert an item in the menu at the specified |index|. Returns true *(1) on
# success.
proc InsertItemAt*(self: NCMenuModel, index: int, command_id: int, label: string): bool =
  var clabel = to_cef_string(label)
  result = self.insert_item_at(self, index.cint, command_id.cint, clabel) == 1.cint
  cef_string_userfree_free(clabel)  
  
# Insert a check item in the menu at the specified |index|. Returns true *(1)
# on success.
proc InsertCheckItemAt*(self: NCMenuModel, index: int, command_id: int, label: string): bool =
  var clabel = to_cef_string(label)
  result = self.insert_check_item_at(self, index.cint, command_id.cint, clabel) == 1.cint
  cef_string_userfree_free(clabel)  
  
# Insert a radio item in the menu at the specified |index|. Only a single
# item with the specified |group_id| can be checked at a time. Returns true
# *(1) on success.
proc InsertRadioItemAt*(self: NCMenuModel, index: int, command_id: int, label: string, group_id: int): bool =
  var clabel = to_cef_string(label)
  result = self.insert_radio_item_at(self, index.cint, command_id.cint, clabel, group_id.cint) == 1.cint
  cef_string_userfree_free(clabel)  
  
# Insert a sub-menu in the menu at the specified |index|. The new sub-menu is
# returned.
proc InsertSubMenuAt*(self: NCMenuModel, index: int, command_id: int, label: string): NCMenuModel =
  var clabel = to_cef_string(label)
  result = self.insert_sub_menu_at(self, index.cint, command_id.cint, clabel)
  cef_string_userfree_free(clabel)  
  
# Removes the item with the specified |command_id|. Returns true *(1) on
# success.
proc Remove*(self: NCMenuModel, command_id: int): bool =
  result = self.remove(self, command_id.cint) == 1.cint
  
# Removes the item at the specified |index|. Returns true *(1) on success.
proc RemoveAt*(self: NCMenuModel, index: cint): bool =
  result = self.remove_at(self, index.cint) == 1.cint

# Returns the index associated with the specified |command_id| or -1 if not
# found due to the command id not existing in the menu.
proc GetIndexOf*(self: NCMenuModel, command_id: int): int =
  result = self.get_index_of(self, command_id.cint).int

# Returns the command id at the specified |index| or -1 if not found due to
# invalid range or the index being a separator.
proc GetCommandIdAt*(self: NCMenuModel, index: cint): cint 

# Sets the command id at the specified |index|. Returns true *(1) on success.
proc SetCommandIdAt*(self: NCMenuModel, index: cint, command_id: cint): cint 

# Returns the label for the specified |command_id| or NULL if not found.
# The resulting string must be freed by calling cef_string_userfree_free*().
proc GetLabel*(self: NCMenuModel, command_id: cint): cef_string_userfree 

# Returns the label at the specified |index| or NULL if not found due to
# invalid range or the index being a separator.
# The resulting string must be freed by calling cef_string_userfree_free*().
proc GetLabelAt*(self: NCMenuModel, index: cint): cef_string_userfree 

# Sets the label for the specified |command_id|. Returns true *(1) on success.
proc SetLabel*(self: NCMenuModel, command_id: cint, label: string): cint 

# Set the label at the specified |index|. Returns true *(1) on success.
proc SetLabelAt*(self: NCMenuModel, index: cint, label: string): cint 

# Returns the item type for the specified |command_id|.
proc GetType*(self: NCMenuModel, command_id: cint): cef_menu_item_type 

# Returns the item type at the specified |index|.
proc GetTypeAt*(self: NCMenuModel, index: cint): cef_menu_item_type 

# Returns the group id for the specified |command_id| or -1 if invalid.
proc GetGroupId*(self: NCMenuModel, command_id: cint): cint 

# Returns the group id at the specified |index| or -1 if invalid.
proc GetGroupIdAt*(self: NCMenuModel, index: cint): cint 

# Sets the group id for the specified |command_id|. Returns true *(1) on
# success.
proc SetGroupId*(self: NCMenuModel, command_id: cint, group_id: cint): cint 

# Sets the group id at the specified |index|. Returns true *(1) on success.
proc SetGroupIdAt*(self: NCMenuModel, index: cint, group_id: cint): cint 

# Returns the submenu for the specified |command_id| or NULL if invalid.
proc GetSubMenu*(self: NCMenuModel, command_id: cint): NCMenuModel 

# Returns the submenu at the specified |index| or NULL if invalid.
proc GetSubMenuAt*(self: NCMenuModel, index: cint): NCMenuModel

# Returns true *(1) if the specified |command_id| is visible.
proc IsVisible*(self: NCMenuModel, command_id: cint): cint 

# Returns true *(1) if the specified |index| is visible.
proc IsVisibleAt*(self: NCMenuModel, index: cint): cint 

# Change the visibility of the specified |command_id|. Returns true *(1) on
# success.
proc SetVisible*(self: NCMenuModel, command_id: cint, visible: cint): cint 

# Change the visibility at the specified |index|. Returns true *(1) on
# success.
proc SetVisibleAt*(self: NCMenuModel, index: cint, visible: cint): cint 

# Returns true *(1) if the specified |command_id| is enabled.
proc IsEnabled*(self: NCMenuModel, command_id: cint): cint 

# Returns true *(1) if the specified |index| is enabled.
proc IsEnabledAt*(self: NCMenuModel, index: cint): cint 

# Change the enabled status of the specified |command_id|. Returns true *(1)
# on success.
proc SetEnabled*(self: NCMenuModel, command_id: cint, enabled: cint): cint 

# Change the enabled status at the specified |index|. Returns true *(1) on
# success.
proc SetEnabledAt*(self: NCMenuModel, index: cint, enabled: cint): cint 

# Returns true *(1) if the specified |command_id| is checked. Only applies to
# check and radio items.
proc IsChecked*(self: NCMenuModel, command_id: cint): cint 

# Returns true *(1) if the specified |index| is checked. Only applies to check
# and radio items.
proc IsCheckedAt*(self: NCMenuModel, index: cint): cint 

# Check the specified |command_id|. Only applies to check and radio items.
# Returns true *(1) on success.
proc SetChecked*(self: NCMenuModel, command_id: cint, checked: cint): cint 

# Check the specified |index|. Only applies to check and radio items. Returns
# true *(1) on success.
proc SetChecked_at*(self: NCMenuModel, index: cint, checked: cint): cint 

# Returns true *(1) if the specified |command_id| has a keyboard accelerator
# assigned.
proc HasAccelerator*(self: NCMenuModel, command_id: cint): cint 

# Returns true *(1) if the specified |index| has a keyboard accelerator
# assigned.
proc HasAcceleratorAt*(self: NCMenuModel, index: cint): cint 

# Set the keyboard accelerator for the specified |command_id|. |key_code| can
# be any virtual key or character value. Returns true *(1) on success.
proc SetAccelerator*(self: NCMenuModel, command_id: cint, key_code: cint, 
  shift_pressed: cint, ctrl_pressed: cint, alt_pressed: cint): cint 

# Set the keyboard accelerator at the specified |index|. |key_code| can be
# any virtual key or character value. Returns true *(1) on success.
proc SetAcceleratorAt*(self: NCMenuModel, index: cint, key_code: cint, 
  shift_pressed: cint, ctrl_pressed: cint, alt_pressed: cint): cint 

# Remove the keyboard accelerator for the specified |command_id|. Returns
# true *(1) on success.
proc RemoveAccelerator*(self: NCMenuModel, command_id: cint): cint 

# Remove the keyboard accelerator at the specified |index|. Returns true *(1)
# on success.
proc RemoveAcceleratorAt*(self: NCMenuModel, index: cint): cint 

# Retrieves the keyboard accelerator for the specified |command_id|. Returns
# true *(1) on success.
proc GetAccelerator*(self: NCMenuModel, command_id: cint, key_code: var cint, 
  shift_pressed: var cint, ctrl_pressed: var cint, alt_pressed: var cint): cint 

# Retrieves the keyboard accelerator for the specified |index|. Returns true
# *(1) on success.
proc GetAcceleratorAt*(self: NCMenuModel, index: cint, key_code: var cint, 
  shift_pressed: var cint, ctrl_pressed: var cint, alt_pressed: var cint): cint 