import cef_base
include cef_import

type
  # Supports creation and modification of menus. See cef_menu_id_t for the
  # command ids that have default implementations. All user-defined command ids
  # should be between MENU_ID_USER_FIRST and MENU_ID_USER_LAST. The functions of
  # this structure can only be accessed on the browser process the UI thread.
  cef_menu_model* = object
    # Base structure.
    base*: cef_base

    # Clears the menu. Returns true (1) on success.
    clear*: proc(self: ptr cef_menu_model): int {.cef_callback.}

    # Returns the number of items in this menu.
    get_count*: proc(self: ptr cef_menu_model): int {.cef_callback.}

    # Add a separator to the menu. Returns true (1) on success.
    add_separator*: proc(self: ptr cef_menu_model): int {.cef_callback.}

    # Add an item to the menu. Returns true (1) on success.
    add_item*: proc(self: ptr cef_menu_model, command_id: int,
      label: ptr cef_string): int {.cef_callback.}

    # Add a check item to the menu. Returns true (1) on success.
    add_check_item*: proc(self: ptr cef_menu_model,
      command_id: int, label: ptr cef_string): int {.cef_callback.}

    # Add a radio item to the menu. Only a single item with the specified
    # |group_id| can be checked at a time. Returns true (1) on success.
    add_radio_item*: proc(self: ptr cef_menu_model,
      command_id: int, label: ptr cef_string, group_id: int): int {.cef_callback.}
  
    # Add a sub-menu to the menu. The new sub-menu is returned.
    add_sub_menu*: proc(self: ptr cef_menu_model, command_id: int,
      label: ptr cef_string): ptr cef_menu_model {.cef_callback.}

    # Insert a separator in the menu at the specified |index|. Returns true (1)
    # on success.  
    insert_separator_at*: proc(self: ptr cef_menu_model,
      index: int): int {.cef_callback.}

    # Insert an item in the menu at the specified |index|. Returns true (1) on
    # success.
    insert_item_at*: proc(self: ptr cef_menu_model, index: int,
      command_id: int, label: ptr cef_string): int {.cef_callback.}

    # Insert a check item in the menu at the specified |index|. Returns true (1)
    # on success.
    insert_check_item_at*: proc(self: ptr cef_menu_model,
      index: int, command_id: int, label: ptr cef_string): int {.cef_callback.}

    # Insert a radio item in the menu at the specified |index|. Only a single
    # item with the specified |group_id| can be checked at a time. Returns true
    # (1) on success.
    insert_radio_item_at*: proc(self: ptr cef_menu_model,
      index: int, command_id: int, label: ptr cef_string, group_id: int): int {.cef_callback.}

    # Insert a sub-menu in the menu at the specified |index|. The new sub-menu is
    # returned.
    insert_sub_menu_at*: proc(self: ptr cef_menu_model, index: int, command_id: int,
      label: ptr cef_string): ptr cef_menu_model {.cef_callback.}

    # Removes the item with the specified |command_id|. Returns true (1) on
    # success.
    remove*: proc(self: ptr cef_menu_model, command_id: int): int {.cef_callback.}

    # Removes the item at the specified |index|. Returns true (1) on success.
    remove_at*: proc(self: ptr cef_menu_model, index: int): int {.cef_callback.}

    # Returns the index associated with the specified |command_id| or -1 if not
    # found due to the command id not existing in the menu.
    get_index_of*: proc(self: ptr cef_menu_model,
      command_id: int): int {.cef_callback.}

    # Returns the command id at the specified |index| or -1 if not found due to
    # invalid range or the index being a separator.
    get_command_id_at*: proc(self: ptr cef_menu_model,
      index: int): int {.cef_callback.}

    # Sets the command id at the specified |index|. Returns true (1) on success.
    set_command_id_at*: proc(self: ptr cef_menu_model,
      index: int, command_id: int): int {.cef_callback.}

    # Returns the label for the specified |command_id| or NULL if not found.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_label*: proc(self: ptr cef_menu_model, command_id: int): cef_string_userfree {.cef_callback.}

    # Returns the label at the specified |index| or NULL if not found due to
    # invalid range or the index being a separator.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_label_at*: proc(self: ptr cef_menu_model, index: int): cef_string_userfree {.cef_callback.}

    # Sets the label for the specified |command_id|. Returns true (1) on success.
    set_label*: proc(self: ptr cef_menu_model, command_id: int,
      label: ptr cef_string): int {.cef_callback.}

    # Set the label at the specified |index|. Returns true (1) on success.
    set_label_at*: proc(self: ptr cef_menu_model, index: int,
      label: ptr cef_string): int {.cef_callback.}

    # Returns the item type for the specified |command_id|.
    get_type*: proc(self: ptr cef_menu_model, command_id: int): cef_menu_item_type {.cef_callback.}

    # Returns the item type at the specified |index|.
    get_type_at*: proc(self: ptr cef_menu_model, index: int): cef_menu_item_type {.cef_callback.}

    # Returns the group id for the specified |command_id| or -1 if invalid.
    get_group_id*: proc(self: ptr cef_menu_model,
      command_id: int): int {.cef_callback.}

    # Returns the group id at the specified |index| or -1 if invalid.
    get_group_id_at*: proc(self: ptr cef_menu_model,
      index: int): int {.cef_callback.}

    # Sets the group id for the specified |command_id|. Returns true (1) on
    # success.
    set_group_id*: proc(self: ptr cef_menu_model,
      command_id: int, group_id: int): int {.cef_callback.}

    # Sets the group id at the specified |index|. Returns true (1) on success.
    set_group_id_at*: proc(self: ptr cef_menu_model, index: int,
      group_id: int): int {.cef_callback.}

    # Returns the submenu for the specified |command_id| or NULL if invalid.
    get_sub_menu*: proc(self: ptr cef_menu_model, command_id: int): ptr cef_menu_model {.cef_callback.}

    # Returns the submenu at the specified |index| or NULL if invalid.
    get_sub_menu_at*: proc(self: ptr cef_menu_model, index: int): ptr cef_menu_model {.cef_callback.}

    # Returns true (1) if the specified |command_id| is visible.
    is_visible*: proc(self: ptr cef_menu_model,
      command_id: int): int {.cef_callback.}

    # Returns true (1) if the specified |index| is visible.
    is_visible_at*: proc(self: ptr cef_menu_model, index: int): int {.cef_callback.}

    # Change the visibility of the specified |command_id|. Returns true (1) on
    # success.
    set_visible*: proc(self: ptr cef_menu_model,
      command_id: int, visible: int): int {.cef_callback.}

    # Change the visibility at the specified |index|. Returns true (1) on
    # success.
    set_visible_at*: proc(self: ptr cef_menu_model, index: int,
      visible: int): int {.cef_callback.}

    # Returns true (1) if the specified |command_id| is enabled.
    is_enabled*: proc(self: ptr cef_menu_model,
      command_id: int): int {.cef_callback.}

    # Returns true (1) if the specified |index| is enabled.
    is_enabled_at*: proc(self: ptr cef_menu_model, index: int): int {.cef_callback.}
  
    # Change the enabled status of the specified |command_id|. Returns true (1)
    # on success.
    set_enabled*: proc(self: ptr cef_menu_model,
      command_id: int, enabled: int): int {.cef_callback.}

    # Change the enabled status at the specified |index|. Returns true (1) on
    # success.
    set_enabled_at*: proc(self: ptr cef_menu_model, index: int,
      enabled: int): int {.cef_callback.}

    # Returns true (1) if the specified |command_id| is checked. Only applies to
    # check and radio items.
    is_checked*: proc(self: ptr cef_menu_model,
      command_id: int): int {.cef_callback.}

    # Returns true (1) if the specified |index| is checked. Only applies to check
    # and radio items.
    is_checked_at*: proc(self: ptr cef_menu_model, index: int): int {.cef_callback.}

    # Check the specified |command_id|. Only applies to check and radio items.
    # Returns true (1) on success.
    set_checked*: proc(self: ptr cef_menu_model,
      command_id: int, checked: int): int {.cef_callback.}
  
    # Check the specified |index|. Only applies to check and radio items. Returns
    # true (1) on success.
    set_checked_at*: proc(self: ptr cef_menu_model, index: int,
      checked: int): int {.cef_callback.}

    # Returns true (1) if the specified |command_id| has a keyboard accelerator
    # assigned.
    has_accelerator*: proc(self: ptr cef_menu_model,
      command_id: int): int {.cef_callback.}

    # Returns true (1) if the specified |index| has a keyboard accelerator
    # assigned.
    has_accelerator_at*: proc(self: ptr cef_menu_model,
      index: int): int {.cef_callback.}
  
    # Set the keyboard accelerator for the specified |command_id|. |key_code| can
    # be any virtual key or character value. Returns true (1) on success.
    set_accelerator*: proc(self: ptr cef_menu_model,
      command_id: int, key_code: int, shift_pressed: int, ctrl_pressed: int,
      alt_pressed: int): int {.cef_callback.}

    # Set the keyboard accelerator at the specified |index|. |key_code| can be
    # any virtual key or character value. Returns true (1) on success.
    set_accelerator_at*: proc(self: ptr cef_menu_model,
      index: int, key_code: int, shift_pressed: int, ctrl_pressed: int,
      alt_pressed: int): int {.cef_callback.}

    # Remove the keyboard accelerator for the specified |command_id|. Returns
    # true (1) on success.
    remove_accelerator*: proc(self: ptr cef_menu_model,
      command_id: int): int {.cef_callback.}

    # Remove the keyboard accelerator at the specified |index|. Returns true (1)
    # on success.
    remove_accelerator_at*: proc(self: ptr cef_menu_model,
      index: int): int {.cef_callback.}

    # Retrieves the keyboard accelerator for the specified |command_id|. Returns
    # true (1) on success.
    get_accelerator*: proc(self: ptr cef_menu_model,
      command_id: int, key_code: var int, shift_pressed: var int, ctrl_pressed: var int,
      alt_pressed: var int): int {.cef_callback.}

    # Retrieves the keyboard accelerator for the specified |index|. Returns true
    # (1) on success.
    get_accelerator_at*: proc(self: ptr cef_menu_model,
      index: int, key_code: var int, shift_pressed: var int, ctrl_pressed: var int,
      alt_pressed: var int): int {.cef_callback.}