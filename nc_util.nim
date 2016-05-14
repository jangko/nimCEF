import cef/cef_base_api, strtabs, cef/cef_string_map_api
import cef/cef_string_api, cef/cef_string_list_api, tables
import cef/cef_string_multimap_api, macros, strutils
include cef/cef_import

export strtabs, cef_string_api, cef_string_list_api, cef_string_map_api, tables

type
  NCStringMultiMap* = TableRef[string, seq[string]]

#don't forget to call cef_string_userfree_free after you finished using
#cef_string from this proc
proc to_cef*(str: string): ptr cef_string =
  if str == nil: return nil
  result = cef_string_userfree_alloc()
  discard cef_string_from_utf8(str.cstring, str.len.csize, result)

proc to_nim*(str: cef_string_userfree, dofree = true): string =
  if str == nil: return nil
  var res: cef_string_utf8
  if cef_string_to_utf8(str.str, str.length, res.addr) == 1:
    result = newString(res.length)
    copyMem(result.cstring, res.str, res.length)
    cef_string_utf8_clear(res.addr)
  else:
    result = ""
  if dofree: cef_string_userfree_free(str)

proc `$`*(str: ptr cef_string): string = to_nim(str, false)

proc `<=`*(cstr: var cef_string, str: string) =
  if str != nil:
    discard cef_string_from_utf8(str.cstring, str.len.csize, cstr.addr)

template nc_free*(str: ptr cef_string) =
  if str != nil: cef_string_userfree_free(str)

proc to_nim*(strlist: cef_string_list, dofree = true): seq[string] =
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

proc `$`*(list: cef_string_list): seq[string] = to_nim(list, false)

#don't forget to call cef_string_list_free
proc to_cef*(input: seq[string]): cef_string_list =
  var list = cef_string_list_alloc()
  var res: cef_string
  for x in input:
    if cef_string_from_utf8(x.cstring, x.len.csize, res.addr) == 1.cint:
      cef_string_list_append(list, res.addr)
      cef_string_clear(res.addr)
  result = list

template nc_free*(list: cef_string_list) =
  cef_string_list_free(list)

proc to_nim*(map: cef_string_map, doFree = true): StringTableRef =
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

proc to_nim*(map: cef_string_multimap, doFree = true): NCStringMultiMap =
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

#don't forget to call cef_string_multi_map_free
proc to_cef*(map: NCStringMultiMap): cef_string_multimap =
  let cmap = cef_string_multimap_alloc()
  for key, elem in map:
    let ckey = to_cef(key)
    for val in elem:
      let cval = to_cef(val)
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

macro wrapAPI*(x, base: untyped, importUtil: bool = true): typed =
  if importUtil.boolVal():
    result = parseStmt "import impl/nc_util_impl, cef/" & $base & "_api"
  else:
    result = newNimNode(nnkStmtList)

  var res = newIdentNode("result")

  result.add quote do:
    type
      `x`* = ref object
        handler: ptr `base`

    proc GetHandler*(self: `x`): ptr `base` {.inline.} =
      `res` = self.handler

    proc nc_finalizer(self: `x`) =
      release(self.handler)

    proc nc_wrap*(handler: ptr `base`): `x` =
      new(`res`, nc_finalizer)
      `res`.handler = handler
      add_ref(handler)
      
var
  wrapDebugMode {.compileTime.} = false

macro debugModeOn*(): stmt =
  wrapDebugMode = true
  result = newEmptyNode()

macro debugModeOff*(): stmt =
  wrapDebugMode = false
  result = newEmptyNode()
  
proc isAvailable(list: NimNode, elem: string): bool =
  for c in list:
    if $c == elem: return true
  result = false

proc checkSelf(self: NimNode): NimNode =
  var err = false
  result = getType(self)
  if result.kind != nnkBracketExpr: err = true
  if result.len != 2: err = true
  if result[0].typeKind != ntyRef: err = true
  if not (result[1].kind == nnkSym and result[1].typeKind == ntyObject): err = true
  if err: error(lineinfo(self) & " self must be a ref object type")

proc checkSymNC(nc: NimNode): NimNode =
  var err = false
  result = getType(nc)
  if result.kind != nnkObjectTy: err = true
  if not (result[1][0].kind == nnkSym and $result[1][0] == "handler"): err = true
  if err: error(lineinfo(nc) & " self must be a ref object type with a handler")

proc checkSymHandler(nc: NimNode): NimNode =
  var err = false
  result = getType(nc)
  if result.kind != nnkBracketExpr: err = true
  if result[0].typeKind != ntyPtr: err = true
  if not (result[1].kind == nnkSym and substr($result[1], 0, 3) == "cef_"): err = true
  if err: error(lineinfo(nc) & " self.handler must be a ptr to cef_xxx")

proc getRoutine(list: NimNode, elem: string): NimNode =
  for c in list:
    if $c == elem: return c

proc routineHasResult(n: NimNode): bool =
  var err = false
  let procType = getType(n)
  if procType.kind != nnkBracketExpr: err = true
  if procType[0].typeKind != ntyProc: err = true
  if procType[1].kind == nnkEmpty: err = true
  if procType[1].kind == nnkSym and $procType[1] == "void": err = true
  #if err: error(lineinfo(n) & " expected routine \"" & $n & "\" has return type")
  result = not err

macro wrapCall*(self: typed, routine: untyped, args: varargs[typed]): stmt =
  # Sanitary Check
  let
    selfType   = checkSelf(self)         # BracketExpr: sym ref, sym NCXXX:ObjectType
    symNC      = checkSymNC(selfType[1]) # ObjectTy: Empty, Reclist: sym handler
    symHandler = checkSymHandler(symNC[1][0]) # BracketExpr: sym ptr, sym cef_xxx
    symCef     = getType(symHandler[1])  # ObjectTy: Empty, Reclist: 1..n
    routineList= symCef[1]
    argSize    = args.len-1
    rout       = getRoutine(routineList, $routine)
    hasResult  = routineHasResult(rout)

  # check if routine available
  if not isAvailable(routineList, $routine):
    error(lineinfo(routine) & " routine: \"" & $routine & "\" not available")

  var
    startIndex = 0
    proloque = ""
    epiloque = ""
    params = "self.handler, "
    calee = "self.handler." & $routine
    body = ""

  if hasResult and args.len > 0:
    if args[0].kind == nnkSym and $args[0] == "result": startIndex = 1
    else: error(lineinfo(self) & " expected \"result\" param")

  if hasResult and args.len == 0:
    error(lineinfo(self) & " expected \"result\" param")

  for i in startIndex..argSize:
    let argi = $(i - startIndex)
    let argv = $args[i]
    case args[i].typeKind
    of ntyString:
      proloque.add "let arg$1 = to_cef($2)\n" % [argi, argv]
      params.add "arg$1" % [argi]
      epiloque.add "nc_free(arg$1)\n" % [argi]
    of ntyBool, ntyInt:
      params.add "$1.cint" % [argv]
    of ntyPointer:
      params.add argv
    else:
      error(lineinfo(args[i]) & " unsupported param type: " & $args[i].typeKind)

    if i < argSize: params.add ", "

  if startIndex > 0:
    let res = args[0]
    case res.typeKind
    of ntyBool:
      body = "result = $1($2) == 1.cint\n" % [calee, params]
    of ntyString, ntyObject:
      body = "result = to_nim($1($2))\n" % [calee, params]
    of ntyInt64, ntyEnum:
      body = "result = $1($2)\n" % [calee, params]
    of ntyInt:
      body = "result = $1($2).cint\n" % [calee, params]
    else:
      error(lineinfo(res) & " unsupported return type: " & $res.typeKind)
  else:
    body = "$1($2)\n" % [calee, params]

  if wrapDebugMode:
    echo proloque
    echo body
    echo epiloque

  result = parseStmt(proloque & body & epiloque)

proc checkBase(n: NimNode): bool =
  var err = false
  let objSym = getType(n)[1]
  let objType = getType(objSym)
  let base = objType[1][0]
  if objSym.typeKind != ntyObject: err = true
  if not (base.typeKind == ntyObject and $base == "base"): err = true
  result = not err

proc checkWrapped(n: NimNode): bool =
  var err = false
  let objSym = getType(n)[1]
  let objType = getType(objSym)
  let handler = objType[1][0]
  let handlee = getType(handler)[1]
  if objSym.typeKind != ntyObject: err = true
  if not (handler.typeKind == ntyPtr and $handler == "handler"): err = true
  if handler.typeKind == ntyPtr and substr($handlee, 0, 3) != "cef_": err = true
  result = not err

macro wrapProc*(routine: typed, args: varargs[typed]): stmt =
  let hasResult = routineHasResult(routine)
  let argSize = args.len-1

  var
    startIndex = 0
    proloque = ""
    epiloque = ""
    params = ""
    calee = $routine
    body = ""

  if hasResult and args.len > 0:
    if args[0].kind == nnkSym and $args[0] == "result": startIndex = 1
    else: error(lineinfo(routine) & " expected \"result\" param")

  if hasResult and args.len == 0:
    error(lineinfo(routine) & " expected \"result\" param")

  for i in startIndex..argSize:
    let argi = $(i - startIndex)
    let argv = $args[i]
    case args[i].typeKind
    of ntyPtr:
      if checkBase(args[i]): proloque.add "add_ref($1)\n" % [argv]
      else: error(lineinfo(args[i]) & " unsupported ptr type")
      params.add argv
    of ntyEnum:
      params.add argv
    of ntyString:
      proloque.add "let arg$1 = to_cef($2)\n" % [argi, argv]
      params.add "arg$1" % [argi]
      epiloque.add "nc_free(arg$1)\n" % [argi]
    of ntyRef:
      if checkWrapped(args[i]): proloque.add "add_ref($1.GetHandler())\n" % [argv]
      else: error(lineinfo(args[i]) & " unsupported ref type")
      params.add "$1.GetHandler()" % [argv]
    else:
      error(lineinfo(args[i]) & " unsupported param type: " & $args[i].typeKind)

    if i < argSize: params.add ", "

  if startIndex > 0:
    let res = args[0]
    case res.typeKind
    of ntyRef:
      if checkWrapped(res):
        body = "result = nc_wrap($1($2))\n" % [calee, params]
      else:
        error(lineinfo(res) & " unsupported ref result")
    else:
      error(lineinfo(res) & " unsupported return type: " & $res.typeKind)
  else:
    body = "$1($2)\n" % [calee, params]

  if wrapDebugMode:
    echo proloque
    echo body
    echo epiloque

  result = parseStmt(proloque & body & epiloque)