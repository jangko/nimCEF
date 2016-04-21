import cef/cef_base_api, strtabs, cef/cef_string_map_api
import cef/cef_string_api, cef/cef_string_list_api, tables
import cef/cef_string_multimap_api, nc_task
include cef/cef_import

export strtabs, cef_string_api, cef_string_list_api, cef_string_map_api, tables

type
  NCStringMultiMap* = TableRef[string, seq[string]]
  
#don't forget to call cef_string_userfree_free after you finished using
#cef_string from this proc
proc to_cef_string*(str: string): ptr cef_string =
  result = cef_string_userfree_alloc()
  discard cef_string_from_utf8(str.cstring, str.len.csize, result)

proc to_nim_string*(str: cef_string_userfree, dofree = true): string =
  if str == nil: return nil
  var res: cef_string_utf8
  if cef_string_to_utf8(str.str, str.length, res.addr) == 1:
    result = newString(res.length)
    copyMem(result.cstring, res.str, res.length)
    cef_string_utf8_clear(res.addr)
  else:
    result = ""
  if dofree: cef_string_userfree_free(str)

proc `$`*(str: ptr cef_string): string = to_nim_string(str, false)

proc `<=`*(cstr: var cef_string, str: string) =
  if str != nil:
    discard cef_string_from_utf8(str.cstring, str.len.csize, cstr.addr)
  
proc to_nim_and_free*(strlist: cef_string_list, dofree = true): seq[string] =
  var len = cef_string_list_size(strlist).int
  result = newSeq[string](len)
  var res: cef_string
  for i in 0.. <len:
    if cef_string_list_value(strlist, i.cint, res.addr) == 1.cint:
      result[i] = $(res.addr)
      cef_string_clear(res.addr)
    else:
      result[i] = ""
  if dofree: cef_string_list_free(strlist)

proc `$`*(list: cef_string_list): seq[string] = to_nim_and_free(list, false)

proc nim_to_string_list*(input: seq[string]): cef_string_list =
  var list = cef_string_list_alloc()
  var res: cef_string
  for x in input:
    if cef_string_from_utf8(x.cstring, x.len.csize, res.addr) == 1.cint:
      cef_string_list_append(list, res.addr)
      cef_string_clear(res.addr)
  result = list

proc to_nim_and_free*(map: cef_string_map, doFree = true): StringTableRef =
  let count = cef_string_map_size(map)
  result = newStringTable(modeCaseSensitive)
  var key, value: cef_string
  for i in 0.. <count:
    discard cef_string_map_key(map, i.cint, key.addr)
    discard cef_string_map_value(map, i.cint, value.addr)
    result[$(key.addr)] = $(value.addr)
    cef_string_clear(key.addr)
    cef_string_clear(value.addr)
  if doFree: cef_string_map_free(map)
  
proc to_nim_and_free*(map: cef_string_multimap, doFree = true): NCStringMultiMap =
  result = newTable[string, seq[string]]()
  let len = cef_string_multimap_size(map)
  var key, val: cef_string
  for i in 0.. <len:
    if cef_string_multimap_key(map, i, key.addr) == 1.cint:
      let count = cef_string_multimap_find_count(map, key.addr)
      var elem = newSeq[string](count)
      for j in 0.. <count:
        discard cef_string_multimap_enumerate(map, key.addr, j, val.addr)
        elem[j] = $(val.addr)
        cef_string_clear(val.addr)
      result.add($(key.addr), elem)
      cef_string_clear(key.addr)
  if doFree: cef_string_multimap_free(map)

proc nim_to_string_multimap*(map: NCStringMultiMap): cef_string_multimap =
  let cmap = cef_string_multimap_alloc()
  for key, elem in map:
    let ckey = to_cef_string(key)
    for val in elem:
      let cval = to_cef_string(val)
      discard cef_string_multimap_append(cmap, ckey, cval)
      cef_string_userfree_free(cval)
    cef_string_userfree_free(ckey)
  result = cmap
  
template add_ref*(elem: expr) =
  if elem != nil: elem.base.add_ref(cast[ptr cef_base](elem))

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


template NC_REQUIRE_UI_THREAD*(): expr =
  doAssert(NCCurrentlyOn(TID_UI))
  
template NC_REQUIRE_IO_THREAD*(): expr =
  doAssert(NCCurrentlyOn(TID_IO))
  
template NC_REQUIRE_FILE_THREAD*(): expr =
  doAssert(NCCurrentlyOn(TID_FILE))
  
template NC_REQUIRE_RENDERER_THREAD*(): expr =
  doAssert(NCCurrentlyOn(TID_RENDERER))