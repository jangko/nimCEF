import cef/cef_base_api, cef/cef_browser_api
import nc_client

proc get_client*(browser: ptr_cef_browser): NCClient =
  var brow = cast[ptr cef_browser](browser)
  var host = brow.get_host(brow)
  var client = host.get_client(host)
  result = cast[NCClient](cast[ByteAddress](client) - sizeof(pointer))

template app_to_app*(app: expr): expr =
  cast[NCApp](cast[ByteAddress](app) - sizeof(pointer))
  
