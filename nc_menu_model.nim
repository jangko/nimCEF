import cef/cef_menu_model_api, cef/cef_base_api, nc_util

type
  # Supports creation and modification of menus. See cef_menu_id_t for the
  # command ids that have default implementations. All user-defined command ids
  # should be between MENU_ID_USER_FIRST and MENU_ID_USER_LAST. The functions of
  # this structure can only be accessed on the browser process the UI thread.
  NCMenuModel* = ptr cef_menu_model

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
proc AddItem*(self: NCMenuModel, command_id: cef_menu_id, label: string): bool =
  var clabel = to_cef(label)
  result = self.add_item(self, command_id.cint, clabel) == 1.cint
  nc_free(clabel)

# Add a check item to the menu. Returns true *(1) on success.
proc AddCheckItem*(self: NCMenuModel, command_id: cef_menu_id, label: string): bool =
  var clabel = to_cef(label)
  result = self.add_check_item(self, command_id.cint, clabel) == 1.cint
  nc_free(clabel)

# Add a radio item to the menu. Only a single item with the specified
# |group_id| can be checked at a time. Returns true *(1) on success.
proc AddRadioItem*(self: NCMenuModel, command_id: cef_menu_id, label: string, group_id: int): bool =
  var clabel = to_cef(label)
  result = self.add_radio_item(self, command_id.cint, clabel, group_id.cint) == 1.cint
  nc_free(clabel)

# Add a sub-menu to the menu. The new sub-menu is returned.
proc AddSubMenu*(self: NCMenuModel, command_id: cef_menu_id, label: string): NCMenuModel =
  var clabel = to_cef(label)
  result = self.add_sub_menu(self, command_id.cint, clabel)
  nc_free(clabel)

# Insert a separator in the menu at the specified |index|. Returns true *(1)
# on success.
proc InsertSeparatorAt*(self: NCMenuModel, index: int): bool =
  result = self.insert_separator_at(self, index.cint) == 1.cint

# Insert an item in the menu at the specified |index|. Returns true *(1) on
# success.
proc InsertItemAt*(self: NCMenuModel, index: int, command_id: cef_menu_id, label: string): bool =
  var clabel = to_cef(label)
  result = self.insert_item_at(self, index.cint, command_id.cint, clabel) == 1.cint
  nc_free(clabel)

# Insert a check item in the menu at the specified |index|. Returns true *(1)
# on success.
proc InsertCheckItemAt*(self: NCMenuModel, index: int, command_id: cef_menu_id, label: string): bool =
  var clabel = to_cef(label)
  result = self.insert_check_item_at(self, index.cint, command_id.cint, clabel) == 1.cint
  nc_free(clabel)

# Insert a radio item in the menu at the specified |index|. Only a single
# item with the specified |group_id| can be checked at a time. Returns true
# *(1) on success.
proc InsertRadioItemAt*(self: NCMenuModel, index: int, command_id: cef_menu_id, label: string, group_id: int): bool =
  var clabel = to_cef(label)
  result = self.insert_radio_item_at(self, index.cint, command_id.cint, clabel, group_id.cint) == 1.cint
  nc_free(clabel)

# Insert a sub-menu in the menu at the specified |index|. The new sub-menu is
# returned.
proc InsertSubMenuAt*(self: NCMenuModel, index: int, command_id: cef_menu_id, label: string): NCMenuModel =
  var clabel = to_cef(label)
  result = self.insert_sub_menu_at(self, index.cint, command_id.cint, clabel)
  nc_free(clabel)

# Removes the item with the specified |command_id|. Returns true *(1) on
# success.
proc Remove*(self: NCMenuModel, command_id: cef_menu_id): bool =
  result = self.remove(self, command_id.cint) == 1.cint

# Removes the item at the specified |index|. Returns true *(1) on success.
proc RemoveAt*(self: NCMenuModel, index: int): bool =
  result = self.remove_at(self, index.cint) == 1.cint

# Returns the index associated with the specified |command_id| or -1 if not
# found due to the command id not existing in the menu.
proc GetIndexOf*(self: NCMenuModel, command_id: cef_menu_id): int =
  result = self.get_index_of(self, command_id.cint).int

# Returns the command id at the specified |index| or -1 if not found due to
# invalid range or the index being a separator.
proc GetCommandIdAt*(self: NCMenuModel, index: int): int =
  result = self.get_command_id_at(self, index.cint).int

# Sets the command id at the specified |index|. Returns true *(1) on success.
proc SetCommandIdAt*(self: NCMenuModel, index: int, command_id: cef_menu_id): bool =
  result = self.set_command_id_at(self, index.cint, command_id.cint) == 1.cint

# Returns the label for the specified |command_id| or NULL if not found.
# The resulting string must be freed by calling nc_free*().
proc GetLabel*(self: NCMenuModel, command_id: cef_menu_id): string =
  var clabel = self.get_label(self, command_id.cint)
  result = to_nim(clabel)

# Returns the label at the specified |index| or NULL if not found due to
# invalid range or the index being a separator.
# The resulting string must be freed by calling nc_free*().
proc GetLabelAt*(self: NCMenuModel, index: int): string =
  var clabel = self.get_label_at(self, index.cint)
  result = to_nim(clabel)

# Sets the label for the specified |command_id|. Returns true *(1) on success.
proc SetLabel*(self: NCMenuModel, command_id: cef_menu_id, label: string): bool =
  var clabel = to_cef(label)
  result = self.set_label(self, command_id.cint, clabel) == 1.cint

# Set the label at the specified |index|. Returns true *(1) on success.
proc SetLabelAt*(self: NCMenuModel, index: int, label: string): bool =
  var clabel = to_cef(label)
  result = self.set_label_at(self, index.cint, clabel) == 1.cint

# Returns the item type for the specified |command_id|.
proc GetType*(self: NCMenuModel, command_id: cef_menu_id): cef_menu_item_type =
  result = self.get_type(self, command_id.cint)

# Returns the item type at the specified |index|.
proc GetTypeAt*(self: NCMenuModel, index: int): cef_menu_item_type =
  result = self.get_type_at(self, index.cint)

# Returns the group id for the specified |command_id| or -1 if invalid.
proc GetGroupId*(self: NCMenuModel, command_id: cef_menu_id): int =
  result = self.get_group_id(self, command_id.cint).int

# Returns the group id at the specified |index| or -1 if invalid.
proc GetGroupIdAt*(self: NCMenuModel, index: int): int =
  result = self.get_group_id_at(self, index.cint).int

# Sets the group id for the specified |command_id|. Returns true *(1) on
# success.
proc SetGroupId*(self: NCMenuModel, command_id: cef_menu_id, group_id: int): bool =
  result = self.set_group_id(self, command_id.cint, group_id.cint) == 1.cint

# Sets the group id at the specified |index|. Returns true *(1) on success.
proc SetGroupIdAt*(self: NCMenuModel, index: int, group_id: int): bool =
  result = self.set_group_id_at(self, index.cint, group_id.cint) == 1.cint

# Returns the submenu for the specified |command_id| or NULL if invalid.
proc GetSubMenu*(self: NCMenuModel, command_id: cef_menu_id): NCMenuModel =
  result = self.get_sub_menu(self, command_id.cint)

# Returns the submenu at the specified |index| or NULL if invalid.
proc GetSubMenuAt*(self: NCMenuModel, index: int): NCMenuModel =
  result = self.get_sub_menu_at(self, index.cint)

# Returns true *(1) if the specified |command_id| is visible.
proc IsVisible*(self: NCMenuModel, command_id: cef_menu_id): bool =
  result = self.is_visible(self, command_id.cint) == 1.cint

# Returns true *(1) if the specified |index| is visible.
proc IsVisibleAt*(self: NCMenuModel, index: int): bool =
  result = self.is_visible_at(self, index.cint) == 1.cint

# Change the visibility of the specified |command_id|. Returns true *(1) on
# success.
proc SetVisible*(self: NCMenuModel, command_id: cef_menu_id, visible: bool): bool =
  result = self.set_visible(self, command_id.cint, visible.cint) == 1.cint

# Change the visibility at the specified |index|. Returns true *(1) on
# success.
proc SetVisibleAt*(self: NCMenuModel, index: int, visible: bool): bool =
  result = self.set_visible_at(self, index.cint, visible.cint) == 1.cint

# Returns true *(1) if the specified |command_id| is enabled.
proc IsEnabled*(self: NCMenuModel, command_id: cef_menu_id): bool =
  result = self.is_enabled(self, command_id.cint) == 1.cint

# Returns true *(1) if the specified |index| is enabled.
proc IsEnabledAt*(self: NCMenuModel, index: int): bool =
  result = self.is_enabled_at(self, index.cint) == 1.cint

# Change the enabled status of the specified |command_id|. Returns true *(1)
# on success.
proc SetEnabled*(self: NCMenuModel, command_id: cef_menu_id, enabled: bool): bool =
  result = self.set_enabled(self, command_id.cint, enabled.cint) == 1.cint

# Change the enabled status at the specified |index|. Returns true *(1) on
# success.
proc SetEnabledAt*(self: NCMenuModel, index: int, enabled: bool): bool =
  result = self.set_enabled_at(self, index.cint, enabled.cint) == 1.cint

# Returns true *(1) if the specified |command_id| is checked. Only applies to
# check and radio items.
proc IsChecked*(self: NCMenuModel, command_id: cef_menu_id): bool =
  result = self.is_checked(self, command_id.cint) == 1.cint

# Returns true *(1) if the specified |index| is checked. Only applies to check
# and radio items.
proc IsCheckedAt*(self: NCMenuModel, index: int): bool =
  result = self.is_checked_at(self, index.cint) == 1.cint

# Check the specified |command_id|. Only applies to check and radio items.
# Returns true *(1) on success.
proc SetChecked*(self: NCMenuModel, command_id: cef_menu_id, checked: bool): bool =
  result = self.set_checked(self, command_id.cint, checked.cint) == 1.cint

# Check the specified |index|. Only applies to check and radio items. Returns
# true *(1) on success.
proc SetChecked_at*(self: NCMenuModel, index: int, checked: bool): bool =
  result = self.set_checked_at(self, index.cint, checked.cint) == 1.cint

# Returns true *(1) if the specified |command_id| has a keyboard accelerator
# assigned.
proc HasAccelerator*(self: NCMenuModel, command_id: cef_menu_id): bool =
  result = self.has_accelerator(self, command_id.cint) == 1.cint

# Returns true *(1) if the specified |index| has a keyboard accelerator
# assigned.
proc HasAcceleratorAt*(self: NCMenuModel, index: int): bool =
  result = self.has_accelerator_at(self, index.cint) == 1.cint

# Set the keyboard accelerator for the specified |command_id|. |key_code| can
# be any virtual key or character value. Returns true *(1) on success.
proc SetAccelerator*(self: NCMenuModel, command_id: cef_menu_id, key_code: int,
  shift_pressed, ctrl_pressed, alt_pressed: bool): bool =
  result = self.set_accelerator(self, command_id.cint, key_code.cint,
    shift_pressed.cint, ctrl_pressed.cint, alt_pressed.cint) == 1.cint

# Set the keyboard accelerator at the specified |index|. |key_code| can be
# any virtual key or character value. Returns true *(1) on success.
proc SetAcceleratorAt*(self: NCMenuModel, index: int, key_code: int,
  shift_pressed, ctrl_pressed, alt_pressed: bool): bool =
  result = self.set_accelerator_at(self, index.cint, key_code.cint,
    shift_pressed.cint, ctrl_pressed.cint, alt_pressed.cint) == 1.cint

# Remove the keyboard accelerator for the specified |command_id|. Returns
# true *(1) on success.
proc RemoveAccelerator*(self: NCMenuModel, command_id: cef_menu_id): bool =
  result = self.remove_accelerator(self, command_id.cint) == 1.cint

# Remove the keyboard accelerator at the specified |index|. Returns true *(1)
# on success.
proc RemoveAcceleratorAt*(self: NCMenuModel, index: int): bool =
  result = self.remove_accelerator_at(self, index.cint) == 1.cint

# Retrieves the keyboard accelerator for the specified |command_id|. Returns
# true *(1) on success.
proc GetAccelerator*(self: NCMenuModel, command_id: cef_menu_id, key_code: var int,
  shift_pressed, ctrl_pressed, alt_pressed: var bool): bool =
  var kc, sp, cp, ap: cint
  result = self.get_accelerator(self, command_id.cint, kc, sp, cp, ap) == 1.cint
  shift_pressed = sp == 1.cint
  ctrl_pressed = cp == 1.cint
  alt_pressed = ap == 1.cint
  key_code = kc.int

# Retrieves the keyboard accelerator for the specified |index|. Returns true
# *(1) on success.
proc GetAcceleratorAt*(self: NCMenuModel, index: int, key_code: var int,
  shift_pressed, ctrl_pressed, alt_pressed: var bool): bool =
  var kc, sp, cp, ap: cint
  result = self.get_accelerator_at(self, index.cint, kc, sp, cp, ap) == 1.cint
  shift_pressed = sp == 1.cint
  ctrl_pressed = cp == 1.cint
  alt_pressed = ap == 1.cint
  key_code = kc.int
