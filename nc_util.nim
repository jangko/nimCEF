import cef/cef_base_api
include cef/cef_import

proc to_cef_string*(str: string): ptr cef_string =
  result = cef_string_userfree_alloc()
  discard cef_string_from_utf8(str.cstring, str.len.csize, result)

proc to_nim_string*(str: cef_string_userfree, dofree = true): string =
  if str == nil: return ""
  var res: cef_string_utf8
  if cef_string_to_utf8(str.str, str.length, res.addr) == 1:
    result = newString(res.length)    
    copyMem(result.cstring, res.str, res.length)
    cef_string_utf8_clear(res.addr)
  else:
    result = ""
  if dofree: cef_string_userfree_free(str)
  
proc `$`*(str: ptr cef_string): string = to_nim_string(str, false)

template add_ref*(elem: expr) =
  discard elem.base.add_ref(cast[ptr cef_base](elem))

template release*(elem: expr) =
  if elem != nil: discard elem.base.release(cast[ptr cef_base](elem))
  
template has_one_ref*(elem: expr): expr =
  elem.base.has_one_ref(cast[ptr cef_base](elem))
  
proc nc_add_ref*(self: ptr cef_base) {.cef_callback.} = discard
proc nc_release*(self: ptr cef_base): cint {.cef_callback.} = 1
proc nc_has_one_ref*(self: ptr cef_base): cint {.cef_callback.} = 1

proc initialize_cef_base*(base: ptr cef_base) =
  let size = base.size
  if size <= 0:
    echo "FATAL: initialize_cef_base failed, size member not set"
    quit(1)
    
  base.add_ref = nc_add_ref
  base.release = nc_release
  base.has_one_ref = nc_has_one_ref

proc init_base*[T](elem: T) =
  elem.base.size = sizeof(elem[])
  initialize_cef_base(cast[ptr cef_base](elem))
  
template b_to_b*(brow: expr): expr = cast[ptr cef_browser](brow)