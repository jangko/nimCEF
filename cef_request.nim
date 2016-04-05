import cef_base
include cef_import

type
  cef_request* = object
    base*: cef_base
  cef_resource_handler* = object 
    base*: cef_base
  cef_resource_bundle_handler* = object 
    base*: cef_base
  cef_browser_process_handler* = object 
    base*: cef_base
  cef_render_process_handler* = object 
    base*: cef_base
  cef_navigation_entry* = object 
    base*: cef_base
  cef_request_context* = object 
    base*: cef_base
  cef_process_message* = object 
    base*: cef_base
  cef_context_menu_handler* = object 
    base*: cef_base
  cef_dialog_handler* = object 
    base*: cef_base
  cef_display_handler* = object 
    base*: cef_base
  cef_download_handler* = object 
    base*: cef_base
  cef_drag_handler* = object 
    base*: cef_base
  cef_find_handler* = object 
    base*: cef_base
  cef_focus_handler* = object 
    base*: cef_base
  cef_geolocation_handler* = object 
    base*: cef_base
  cef_jsdialog_handler* = object 
    base*: cef_base
  cef_keyboard_handler* = object 
    base*: cef_base
  cef_load_handler* = object 
    base*: cef_base
  cef_render_handler* = object 
    base*: cef_base
  cef_request_handler* = object 
    base*: cef_base
