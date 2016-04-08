import cef/cef_base_api

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