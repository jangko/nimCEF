import nc_util, cef_types
include cef_import

# Supports creation and modification of menus. See cef_menu_id_t for the
# command ids that have default implementations. All user-defined command ids
# should be between MENU_ID_USER_FIRST and MENU_ID_USER_LAST. The functions of
# this structure can only be accessed on the browser process the UI thread.
wrapAPI(NCMenuModel, cef_menu_model)

# Clears the menu. Returns true *(1) on success.
proc clear*(self: NCMenuModel): bool =
  self.wrapCall(clear, result)

# Returns the number of items in this menu.
proc getCount*(self: NCMenuModel): int =
  self.wrapCall(get_count, result)

# Add a separator to the menu. Returns true *(1) on success.
proc addSeparator*(self: NCMenuModel): bool =
  self.wrapCall(add_separator, result)

# Add an item to the menu. Returns true *(1) on success.
proc addItem*(self: NCMenuModel, command_id: cef_menu_id, label: string): bool =
  self.wrapCall(add_item, result, command_id, label)

# Add a check item to the menu. Returns true *(1) on success.
proc addCheckItem*(self: NCMenuModel, command_id: cef_menu_id, label: string): bool =
  self.wrapCall(add_check_item, result, command_id, label)

# Add a radio item to the menu. Only a single item with the specified
# |group_id| can be checked at a time. Returns true *(1) on success.
proc addRadioItem*(self: NCMenuModel, command_id: cef_menu_id, label: string, group_id: int): bool =
  self.wrapCall(add_radio_item, result, command_id, label, group_id)

# Add a sub-menu to the menu. The new sub-menu is returned.
proc addSubMenu*(self: NCMenuModel, command_id: cef_menu_id, label: string): NCMenuModel =
  self.wrapCall(add_sub_menu, result, command_id, label)

# Insert a separator in the menu at the specified |index|. Returns true *(1)
# on success.
proc InsertSeparatorAt*(self: NCMenuModel, index: int): bool =
  self.wrapCall(insert_separator_at, result, index)

# Insert an item in the menu at the specified |index|. Returns true *(1) on
# success.
proc InsertItemAt*(self: NCMenuModel, index: int, command_id: cef_menu_id, label: string): bool =
  self.wrapCall(insert_item_at, result, index, command_id, label)

# Insert a check item in the menu at the specified |index|. Returns true *(1)
# on success.
proc InsertCheckItemAt*(self: NCMenuModel, index: int, command_id: cef_menu_id, label: string): bool =
  self.wrapCall(insert_check_item_at, result, index, command_id, label)

# Insert a radio item in the menu at the specified |index|. Only a single
# item with the specified |group_id| can be checked at a time. Returns true
# *(1) on success.
proc InsertRadioItemAt*(self: NCMenuModel, index: int, command_id: cef_menu_id, label: string, group_id: int): bool =
  self.wrapCall(insert_radio_item_at, result, index, command_id, label, group_id)

# Insert a sub-menu in the menu at the specified |index|. The new sub-menu is
# returned.
proc InsertSubMenuAt*(self: NCMenuModel, index: int, command_id: cef_menu_id, label: string): NCMenuModel =
  self.wrapCall(insert_sub_menu_at, result, index, command_id, label)

# Removes the item with the specified |command_id|. Returns true *(1) on
# success.
proc remove*(self: NCMenuModel, command_id: cef_menu_id): bool =
  self.wrapCall(remove, result, command_id)

# Removes the item at the specified |index|. Returns true *(1) on success.
proc removeAt*(self: NCMenuModel, index: int): bool =
  self.wrapCall(remove_at, result, index)

# Returns the index associated with the specified |command_id| or -1 if not
# found due to the command id not existing in the menu.
proc getIndexOf*(self: NCMenuModel, command_id: cef_menu_id): int =
  self.wrapCall(get_index_of, result, command_id)

# Returns the command id at the specified |index| or -1 if not found due to
# invalid range or the index being a separator.
proc getCommandIdAt*(self: NCMenuModel, index: int): int =
  self.wrapCall(get_command_id_at, result, index)

# Sets the command id at the specified |index|. Returns true *(1) on success.
proc setCommandIdAt*(self: NCMenuModel, index: int, command_id: cef_menu_id): bool =
  self.wrapCall(set_command_id_at, result, index, command_id)

# Returns the label for the specified |command_id| or NULL if not found.
proc getLabel*(self: NCMenuModel, command_id: cef_menu_id): string =
  self.wrapCall(get_label, result, command_id)

# Returns the label at the specified |index| or NULL if not found due to
# invalid range or the index being a separator.
proc getLabelAt*(self: NCMenuModel, index: int): string =
  self.wrapCall(get_label_at, result, index)

# Sets the label for the specified |command_id|. Returns true *(1) on success.
proc setLabel*(self: NCMenuModel, command_id: cef_menu_id, label: string): bool =
  self.wrapCall(set_label, result, command_id, label)

# Set the label at the specified |index|. Returns true *(1) on success.
proc setLabelAt*(self: NCMenuModel, index: int, label: string): bool =
  self.wrapCall(set_label_at, result, index, label)

# Returns the item type for the specified |command_id|.
proc getType*(self: NCMenuModel, command_id: cef_menu_id): cef_menu_item_type =
  self.wrapCall(get_type, result, command_id)

# Returns the item type at the specified |index|.
proc getTypeAt*(self: NCMenuModel, index: int): cef_menu_item_type =
  self.wrapCall(get_type_at, result, index)

# Returns the group id for the specified |command_id| or -1 if invalid.
proc getGroupId*(self: NCMenuModel, command_id: cef_menu_id): int =
  self.wrapCall(get_group_id, result, command_id)

# Returns the group id at the specified |index| or -1 if invalid.
proc getGroupIdAt*(self: NCMenuModel, index: int): int =
  self.wrapCall(get_group_id_at, result, index)

# Sets the group id for the specified |command_id|. Returns true *(1) on
# success.
proc setGroupId*(self: NCMenuModel, command_id: cef_menu_id, group_id: int): bool =
  self.wrapCall(set_group_id, result, command_id, group_id)

# Sets the group id at the specified |index|. Returns true *(1) on success.
proc setGroupIdAt*(self: NCMenuModel, index: int, group_id: int): bool =
  self.wrapCall(set_group_id_at, result, index, group_id)

# Returns the submenu for the specified |command_id| or NULL if invalid.
proc getSubMenu*(self: NCMenuModel, command_id: cef_menu_id): NCMenuModel =
  self.wrapCall(get_sub_menu, result, command_id)

# Returns the submenu at the specified |index| or NULL if invalid.
proc getSubMenuAt*(self: NCMenuModel, index: int): NCMenuModel =
  self.wrapCall(get_sub_menu_at, result, index)

# Returns true *(1) if the specified |command_id| is visible.
proc isVisible*(self: NCMenuModel, command_id: cef_menu_id): bool =
  self.wrapCall(is_visible, result, command_id)

# Returns true *(1) if the specified |index| is visible.
proc isVisibleAt*(self: NCMenuModel, index: int): bool =
  self.wrapCall(is_visible_at, result, index)

# Change the visibility of the specified |command_id|. Returns true *(1) on
# success.
proc setVisible*(self: NCMenuModel, command_id: cef_menu_id, visible: bool): bool =
  self.wrapCall(set_visible, result, command_id, visible)

# Change the visibility at the specified |index|. Returns true *(1) on
# success.
proc setVisibleAt*(self: NCMenuModel, index: int, visible: bool): bool =
  self.wrapCall(set_visible_at, result, index, visible)

# Returns true *(1) if the specified |command_id| is enabled.
proc isEnabled*(self: NCMenuModel, command_id: cef_menu_id): bool =
  self.wrapCall(is_enabled, result, command_id)

# Returns true *(1) if the specified |index| is enabled.
proc isEnabledAt*(self: NCMenuModel, index: int): bool =
  self.wrapCall(is_enabled_at, result, index)

# Change the enabled status of the specified |command_id|. Returns true *(1)
# on success.
proc setEnabled*(self: NCMenuModel, command_id: cef_menu_id, enabled: bool): bool =
  self.wrapCall(set_enabled, result, command_id, enabled)

# Change the enabled status at the specified |index|. Returns true *(1) on
# success.
proc setEnabledAt*(self: NCMenuModel, index: int, enabled: bool): bool =
  self.wrapCall(set_enabled_at, result, index, enabled)

# Returns true *(1) if the specified |command_id| is checked. Only applies to
# check and radio items.
proc isChecked*(self: NCMenuModel, command_id: cef_menu_id): bool =
  self.wrapCall(is_checked, result, command_id)

# Returns true *(1) if the specified |index| is checked. Only applies to check
# and radio items.
proc isCheckedAt*(self: NCMenuModel, index: int): bool =
  self.wrapCall(is_checked_at, result, index)

# Check the specified |command_id|. Only applies to check and radio items.
# Returns true *(1) on success.
proc setChecked*(self: NCMenuModel, command_id: cef_menu_id, checked: bool): bool =
  self.wrapCall(set_checked, result, command_id, checked)

# Check the specified |index|. Only applies to check and radio items. Returns
# true *(1) on success.
proc setChecked_at*(self: NCMenuModel, index: int, checked: bool): bool =
  self.wrapCall(set_checked_at, result, index, checked)

# Returns true *(1) if the specified |command_id| has a keyboard accelerator
# assigned.
proc hasAccelerator*(self: NCMenuModel, command_id: cef_menu_id): bool =
  self.wrapCall(has_accelerator, result, command_id)

# Returns true *(1) if the specified |index| has a keyboard accelerator
# assigned.
proc hasAcceleratorAt*(self: NCMenuModel, index: int): bool =
  self.wrapCall(has_accelerator_at, result, index)

# Set the keyboard accelerator for the specified |command_id|. |key_code| can
# be any virtual key or character value. Returns true *(1) on success.
proc setAccelerator*(self: NCMenuModel, command_id: cef_menu_id, key_code: int,
  shift_pressed, ctrl_pressed, alt_pressed: bool): bool =
  self.wrapCall(set_accelerator, result, command_id, key_code,
    shift_pressed, ctrl_pressed, alt_pressed)

# Set the keyboard accelerator at the specified |index|. |key_code| can be
# any virtual key or character value. Returns true *(1) on success.
proc setAcceleratorAt*(self: NCMenuModel, index: int, key_code: int,
  shift_pressed, ctrl_pressed, alt_pressed: bool): bool =
  self.wrapCall(set_accelerator_at, result, index, key_code,
    shift_pressed, ctrl_pressed, alt_pressed)

# Remove the keyboard accelerator for the specified |command_id|. Returns
# true *(1) on success.
proc removeAccelerator*(self: NCMenuModel, command_id: cef_menu_id): bool =
  self.wrapCall(remove_accelerator, result, command_id)

# Remove the keyboard accelerator at the specified |index|. Returns true *(1)
# on success.
proc removeAcceleratorAt*(self: NCMenuModel, index: int): bool =
  self.wrapCall(remove_accelerator_at, result, index)

# Retrieves the keyboard accelerator for the specified |command_id|. Returns
# true *(1) on success.
proc getAccelerator*(self: NCMenuModel, command_id: cef_menu_id, key_code: var int,
  shift_pressed, ctrl_pressed, alt_pressed: var bool): bool =
  self.wrapCall(get_accelerator, result, command_id, key_code, shift_pressed, ctrl_pressed, alt_pressed)

# Retrieves the keyboard accelerator for the specified |index|. Returns true
# *(1) on success.
proc getAcceleratorAt*(self: NCMenuModel, index: int, key_code: var int,
  shift_pressed, ctrl_pressed, alt_pressed: var bool): bool =
  self.wrapCall(get_accelerator_at, result, index, key_code, shift_pressed, ctrl_pressed, alt_pressed)
  
wrapCallback(NCMenuModelDelegate, cef_menu_model_delegate):
  #Perform the action associated with the specified |command_id| and optional
  #|event_flags|.
  proc ExecuteCommand*(self: NCMenuModelDelegate, menu_model: NCMenuModel, 
    command_id: cef_menu_id, event_flags: cef_event_flags)

    # The menu is about to show.
  proc MenuWillShow*(self: NCMenuModelDelegate, menu_model: NCMenuModel)

# Create a new MenuModel with the specified |delegate|.
proc ncMenuModelCreate*(delegate: NCMenuModelDelegate): NCMenuModel =
  wrapProc(cef_menu_model_create, result, delegate)
  
