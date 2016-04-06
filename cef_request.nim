import cef_base
include cef_import

type
  cef_request* = object
    base*: cef_base
  cef_resource_bundle_handler* = object 
    base*: cef_base
  cef_browser_process_handler* = object 
    base*: cef_base
  cef_navigation_entry* = object 
    base*: cef_base
  cef_dialog_handler* = object 
    base*: cef_base
  cef_display_handler* = object 
    base*: cef_base
  cef_download_handler* = object 
    base*: cef_base
  cef_load_handler* = object 
    base*: cef_base
  cef_render_handler* = object 
    base*: cef_base
  cef_response* = object
    base*: cef_base
  cef_response_filter* = object
    base*: cef_base