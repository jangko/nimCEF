import nc_util

import cef_path_util_api, cef_string_visitor_api, cef_auth_callback_api
import cef_process_util_api, cef_callback_api, cef_geolocation_api, cef_find_handler_api
import cef_process_message_api, cef_drag_handler_api, cef_focus_handler_api
import cef_keyboard_handler_api, cef_resource_handler_api, cef_print_handler_api
import cef_download_item_api, cef_jsdialog_handler_api, cef_task_api
import cef_render_process_handler_api, cef_web_plugin_info_api, cef_parser_api
import cef_render_handler_api, cef_sslinfo_api, cef_urlrequest_api
import cef_xml_reader_api, cef_cookie_manager_api, cef_domdocument_api
import cef_context_menu_handler_api, cef_request_handler_api, cef_request_context_api
import cef_v8context_api, cef_browser_process_handler_api, cef_dialog_handler_api
import cef_display_handler_api, cef_download_handler_api, cef_load_handler_api
import cef_navigation_entry_api, cef_origin_whitelist_api, cef_request_context_handler_api
import cef_resource_bundle_api, cef_resource_bundle_handler_api, cef_response_filter_api
import cef_trace_api, cef_zip_reader_api, cef_response_api, cef_view_api


import nc_app, nc_client, nc_frame
import nc_menu_model, nc_process_message, nc_command_line
import nc_browser, nc_zip_reader, nc_xml_reader, nc_value, nc_dom, nc_types
import nc_drag_data, nc_v8, nc_navigation_entry, nc_response, nc_parser
import nc_process_util, nc_path_util, nc_origin_whitelist
import nc_print_settings, nc_ssl_info, nc_web_plugin, nc_trace
import nc_auth_callback, nc_cookie_manager, nc_response_filter
import nc_request_context, nc_pack_strings, nc_pack_resources
import nc_sandbox_info, nc_version, nc_urlrequest, nc_request_context_handler
import nc_geolocation, nc_print_handler, nc_xml_object
import nc_context_menu_handler, nc_dialog_handler, nc_display_handler
import nc_download_handler, nc_drag_handler, nc_find_handler
import nc_focus_handler, nc_geolocation_handler, nc_jsdialog_handler
import nc_keyboard_handler, nc_life_span_handler, nc_load_handler
import nc_render_handler, nc_request_handler
import nc_render_process_handler, nc_resource_bundle_handler
import nc_browser_process_handler, nc_view

#this module purpose is to test the wrapper macro
#and then print to console the statistics for each macro
#that has been called during compile
printWrapStat()