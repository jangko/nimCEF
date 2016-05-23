import cef/cef_base_api, strtabs, cef/cef_string_map_api
import cef/cef_string_api, cef/cef_string_list_api, tables
import cef/cef_string_multimap_api, macros, strutils
include cef/cef_import

export strtabs, cef_string_api, cef_string_list_api, cef_string_map_api, tables
export cef_string_multimap_api

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

template nc_free*(cmap: cef_string_multimap) =
  cef_string_multimap_free(cmap)

template add_ref*(elem: expr) =
  if elem != nil: elem.base.add_ref(cast[ptr cef_base](elem))

template release*(elem: expr) =
  if elem != nil: discard elem.base.release(cast[ptr cef_base](elem))

template has_one_ref*(elem: expr): expr =
  elem.base.has_one_ref(cast[ptr cef_base](elem))

var
  wrapDebugMode    {.compileTime.} = false
  wrapCallStat     {.compileTime.} = 0
  wrapProcStat     {.compileTime.} = 0
  wrapMethodStat   {.compileTime.} = 0
  wrapAPIStat      {.compileTime.} = 0
  wrapCallbackStat {.compileTime.} = 0

macro printWrapStat*(): stmt =
  echo "wrapCall    : ", wrapCallStat
  echo "wrapProc    : ", wrapProcStat
  echo "wrapMethod  : ", wrapMethodStat
  echo "wrapAPI     : ", wrapAPIStat
  echo "wrapCallback: ", wrapCallbackStat

macro wrapAPI*(x, base: untyped, importUtil: bool = true): typed =
  inc(wrapAPIStat)
  
  if importUtil.boolVal():
    var exim = "import impl/nc_util_impl, cef/" & $base & "_api\n"
    exim.add "export " & $base & "_api\n"
    result = parseStmt exim
  else:
    result = newNimNode(nnkStmtList)

  var res = newIdentNode("result")

  result.add quote do:
    type
      `x`* = ref object of RootObj
        handler*: ptr `base`

    proc GetHandler*(self: `x`): ptr `base` {.inline.} =
      `res` = if self == nil: nil else: self.handler

    proc nc_finalizer(self: `x`) =
      release(self.handler)

    proc nc_wrap*(handler: ptr `base`): `x` =
      if handler == nil: return nil
      new(`res`, nc_finalizer)
      `res`.handler = handler
      add_ref(handler)

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
  result = not err

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
  let nType = getType(n)
  if nType.typeKind != ntyRef: return false
  let objSym = nType[1]
  let objType = getType(objSym)
  let handler = objType[1][0]
  if $handler != "handler": return false
  let handlee = getType(handler)[1]
  if objSym.typeKind != ntyObject: err = true
  if not (handler.typeKind == ntyPtr and $handler == "handler"): err = true
  if handler.typeKind == ntyPtr and substr($handlee, 0, 3) != "cef_": err = true
  result = not err

proc checkMultiMap(n: NimNode): bool =
  let objSym = getType(n)[1] #table
  if objSym.kind != nnkSym: return false
  if $objSym != "Table": return false
  let data = getType(objSym)[1][0]
  let A = getType(data)[1][2]
  if $A != "string": return false
  let B = getType(data)[1][3]
  if B.typeKind != ntySequence: return false
  if $getType(B)[1] != "string": return false
  result = true

proc checkStringMap(n: NimNode): bool =
  let objSym = getType(n)[1]
  if $objSym != "StringTableObj": return false
  result = true

proc checkString(n: NimNode): bool =
  if n.kind != nnkSym: return false
  if $n != "string": return false
  result = true

proc getHandler(n: NimNode): NimNode =
  let nType = getType(n[1])
  let hType = getType(nType[1][0])
  result = hType[1]

proc getArgName(n: NimNode): string =
  if n.kind == nnkHiddenDeref: return $n[0]
  result = $n

proc getBaseType(n: NimNode): string =
  if n.typeKind in {ntyVar, ntyPtr}: return $n[1]
  if n.typeKind == ntyRef:
    let t = $n[1]
    return t.substr(0, t.find(':')-1)
  result = $n

macro wrapCall*(self: typed, routine: untyped, args: varargs[typed]): stmt =
  inc(wrapCallStat)
  
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
    params = "self.handler"
    calee = "self.handler." & $routine
    body = ""

  if hasResult and args.len > 1:
    params.add ", "

  if not hasResult and args.len > 0:
    if args[0].kind == nnkSym and $args[0] == "result":
      startIndex = 1
      if args.len > 1: params.add ", "
    else: params.add ", "

  if hasResult and args.len > 0:
    if args[0].kind == nnkSym and $args[0] == "result": startIndex = 1
    else: error(lineinfo(self) & " expected \"result\" param")

  if hasResult and args.len == 0:
    error(lineinfo(self) & " expected \"result\" param")

  for i in startIndex..argSize:
    let argi = $(i - startIndex)
    let arg  = args[i]
    let argv = getArgName(arg)
    case arg.typeKind
    of ntyString:
      proloque.add "let arg$1 = to_cef($2)\n" % [argi, argv]
      params.add "arg$1" % [argi]
      epiloque.add "nc_free(arg$1)\n" % [argi]
    of ntyBool, ntyInt, ntyFloat:
      let argType = getType(rout)[i - startIndex + 3].getBaseType()
      if arg.kind == nnkHiddenDeref:
        proloque.add "var arg$1 = $2.$3\n" % [argi, argv, argType]
        params.add "arg" & argi
        if arg.typeKind == ntyBool:
          epiloque.add "$1 = arg$2 == 1.$3\n" % [argv, argi, argType]
        else:
          epiloque.add "$1 = arg$2\n" % [argv, argi]
      else:
        params.add "$1.$2" % [argv, argType]
    of ntyPointer, ntyEnum, ntyInt64:
      let argT = getType(rout)[i - startIndex + 3]
      if arg.typeKind == ntyEnum and argT.typeKind != ntyEnum:
        let argType = argT.getBaseType()
        params.add "$1.$2" % [argv, argType]
      else:
        params.add argv
    of ntyRef:
      if arg.kind == nnkHiddenDeref:
        proloque.add "var arg$1 = $2.GetHandler()\n" % [argi, argv]
        epiloque.add "$1 = nc_wrap(arg$2)\n" % [argv, argi]
        params.add "arg" & argi
      elif checkWrapped(arg):
        let argType = getType(rout)[i - startIndex + 3]
        proloque.add "add_ref($1.GetHandler())\n" % [argv]
        if argType.typeKind == ntyDistinct:
          params.add "cast[$1]($2.GetHandler())" % [$argType, argv]
        else:
          params.add "$1.GetHandler()" % [argv]
      elif checkMultiMap(arg):
        proloque.add "let arg$1 = to_cef($2)\n" % [argi, argv]
        params.add "arg$1" % [argi]
        epiloque.add "nc_free(arg$1)\n" % [argi]
      else: error(lineinfo(arg) & " unsupported ref type: " & argv)
    of ntySequence:
      let T = getType(arg)[1]
      if checkWrapped(T):
        let handler = $getHandler(T)
        let argType = getType(rout)[i - startIndex + 3].getBaseType()
        proloque.add "var arg$1 = newSeq[ptr $2]($3.len)\n" % [argi, handler, argv]
        proloque.add "for i in 0.. <$1.len:\n" % [argv]
        proloque.add "  arg$1[i] = $2[i].GetHandler()\n" % [argi, argv]
        proloque.add "  add_ref(arg$1[i])\n" % [argi]
        params.add "$1.len.$2, cast[ptr ptr $3](arg$4[0].addr)" % [argv, argType, handler, argi]
      elif checkString(T):
        proloque.add "var arg$1 = to_cef($2)\n" % [argi, argv]
        params.add "arg$1" % [argi]
        epiloque.add "nc_free(arg$1)\n" % [argi]
      elif T.typeKind == ntyObject:
        let argLen  = getType(rout)[i - startIndex + 3].getBaseType()
        let argBase = getType(rout)[i - startIndex + 4].getBaseType()
        proloque.add "var arg$1 = newSeq[$2]($3.len)\n" % [argi, argBase, argv]
        proloque.add "for i in 0.. <$1.len:\n" % [argv]
        proloque.add "  arg$1[i] = $2[i].to_cef()\n" % [argi, argv]
        params.add "$1.len.$2, cast[ptr $3](arg$4[0].addr)" % [argv, argLen, argBase, argi]
      else:
        error(lineinfo(arg) & " unsupported param: " & getType(arg).treeRepr)
    of ntyObject:
      proloque.add "var arg$1 = to_cef($2)\n" % [argi, argv]
      params.add "arg$1.addr" % [argi]
      epiloque.add "nc_free(arg$1)\n" % [argi]
    of ntyPtr:
      let cType = getType(rout)[i - startIndex + 3]
      let nType = getType(arg)
      if sameType(cType, nType):
        params.add argv
    else:
      error(lineinfo(arg) & " unsupported param type: " & $arg.typeKind)

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
      body = "result = $1($2).int\n" % [calee, params]
    of ntyInt32:
      body = "result = $1($2).int32\n" % [calee, params]
    of ntyUInt32:
      body = "result = $1($2).uint32\n" % [calee, params]
    of ntyRef:
      if checkWrapped(res): body = "result = nc_wrap($1($2))\n" % [calee, params]
      elif checkMultiMap(res):
        proloque.add "var map = cef_string_multimap_alloc()\n"
        params.add ", map"
        body = "$1($2)\n" % [calee, params]
        epiloque.add "result = to_nim(map)\n"
      elif checkStringMap(res):
        proloque.add "var map = cef_string_map_alloc()\n"
        params.add ", map"
        body = "$1($2)\n" % [calee, params]
        epiloque.add "result = to_nim(map)\n"
      else: error(lineinfo(res) & " unsupported ref type of \"result\"")
    of ntyFloat:
      body = "result = $1($2).float64\n" % [calee, params]
    of ntySequence:
      let T = getType(res)[1]
      if checkString(T):
        proloque.add "var res = cef_string_list_alloc()\n"
        params.add ", res"
        if hasResult:
          body.add "if $1($2) == 1.cint:\n" % [calee, params]
          body.add "  result = to_nim(res)\n"
          body.add "else:\n"
          body.add "  nc_free(res)\n"
          body.add "  result = @[]\n"
        else:
          body.add "$1($2)\n" % [calee, params]
          body.add "result = to_nim(res)\n"
      elif checkWrapped(T):
        let handler = $getHandler(T)
        let size = $args[args.len-1]
        let destType = T.getBaseType()
        let argi = $argSize
        proloque.add "result = newSeq[$1]($2)\n" % [destType, size]
        proloque.add "var res$1 = newSeq[ptr $2]($3)\n" % [argi, handler, size]
        proloque.add "var buf$1 = cast[ptr ptr $2](res$1[0].addr)\n" % [argi, handler]
        params.add ", buf" & argi
        body = "$1($2)\n" % [calee, params]
        epiloque.add "for i in 0.. <$1:\n" % [size]
        epiloque.add "  result[i] = nc_wrap(res$1[i])\n" % [argi]
      elif T.typeKind == ntyInt64:
        let size = $args[args.len-1]
        proloque.add "result = newSeq[int64]($1.int)\n" % [size]
        params.add ", result[0].addr"
        body = "$1($2)\n" % [calee, params]
      elif T.typeKind == ntyObject:
        let size = $args[args.len-1]
        let srcType = getType(rout).last().getBaseType()
        let destType = T.getBaseType()
        let argi = $argSize
        proloque.add "result = newSeq[$1]($2)\n" % [destType, size]
        proloque.add "var res$1 = newSeq[$2]($3)\n" % [argi, srcType, size]
        proloque.add "var buf$1 = cast[ptr $2](res$1[0].addr)\n" % [argi, srcType]
        params.add ", buf" & argi
        body = "$1($2)\n" % [calee, params]
        epiloque.add "for i in 0.. <$1:\n" % [size]
        epiloque.add "  result[i] = to_nim(res$1[i])\n" % [argi]
      else:
        error(lineinfo(res) & " unsupported type of \"result\": seq " & getType(res).treeRepr)
    of ntyDistinct:
      let T = getType(res)[1]
      if T.typeKind == ntyPointer:
        body = "result = $1($2)\n" % [calee, params]
      else:
        error(lineinfo(res) & " unsupported return distinct: " & $T)
    of ntyPtr:
      let cType = getType(rout)[1]
      let nType = getType(res)
      if sameType(cType, nType):
        body = "result = $1($2)\n" % [calee, params]
    else:
      error(lineinfo(res) & " unsupported return type: " & $res.typeKind)
  else:
    body = "$1($2)\n" % [calee, params]

  if wrapDebugMode:
    echo proloque
    echo body
    echo epiloque

  result = parseStmt(proloque & body & epiloque)

macro wrapProc*(routine: typed, args: varargs[typed]): stmt =
  inc(wrapProcStat)
  
  let hasResult = routineHasResult(routine)
  let argSize = args.len-1

  var
    startIndex = 0
    proloque = ""
    epiloque = ""
    params = ""
    calee = $routine
    body = ""

  if not hasResult and args.len > 0:
    if args[0].kind == nnkSym and $args[0] == "result":
      startIndex = 1

  if hasResult and args.len > 0:
    if args[0].kind == nnkSym and $args[0] == "result": startIndex = 1
    else: error(lineinfo(routine) & " expected \"result\" param")

  if hasResult and args.len == 0:
    error(lineinfo(routine) & " expected \"result\" param")

  for i in startIndex..argSize:
    let argi = $(i - startIndex)
    let arg  = args[i]
    let argv = getArgName(arg)
    case arg.typeKind
    of ntyPtr:
      if checkBase(arg): proloque.add "add_ref($1)\n" % [argv]
      else: error(lineinfo(arg) & " unsupported ptr type")
      params.add argv
    of ntyEnum, ntyPointer, ntyInt64:
      if arg.kind == nnkHiddenDeref:
        #enumty should have typeName
        let argType = $getType(routine)[i - startIndex + 2][1][0][1]
        proloque.add "var arg$1 = $2\n" % [argi, argType]
        params.add "arg$1" % [argi]
        epiloque.add "$1 = arg$2\n" % [argv, argi]
      else:
        params.add argv
    of ntyString:
      if arg.kind == nnkHiddenDeref:
        proloque.add "var arg$1: cef_string\n" % [argi]
        params.add "arg$1.addr" % [argi]
        epiloque.add "$1 = $$arg$2.addr\n" % [argv, argi]
        epiloque.add "cef_string_clear(arg$1.addr)\n" % [argi]
      else:
        proloque.add "let arg$1 = to_cef($2)\n" % [argi, argv]
        params.add "arg$1" % [argi]
        epiloque.add "nc_free(arg$1)\n" % [argi]
    of ntyRef:
      if checkWrapped(arg): proloque.add "add_ref($1.GetHandler())\n" % [argv]
      else: error(lineinfo(arg) & " unsupported ref type: " & argv)
      params.add "$1.GetHandler()" % [argv]
    of ntyBool, ntyInt, ntyFloat, ntyInt32, ntyUint32:
      if arg.kind == nnkHiddenDeref:
        let argType = $getType(routine)[i - startIndex + 2][1]
        proloque.add "var arg$1: $2\n" % [argi, argType]
        params.add "arg$1" % [argi]
        epiloque.add "$1 = arg$2\n" % [argv, argi]
      else:
        let argType = $getType(routine)[i - startIndex + 2]
        params.add "$1.$2" % [argv, argType]
    of ntyObject:
      if arg.kind == nnkHiddenDeref:
        proloque.add "var arg$1 = to_cef($2)\n" % [argi, argv]
        params.add "arg$1.addr" % [argi]
        epiloque.add "$1 = to_nim(arg$2)\n" % [argv, argi]
      else:
        proloque.add "var arg$1 = to_cef($2)\n" % [argi, argv]
        params.add "arg$1.addr" % [argi]
        epiloque.add "nc_free(arg$1)\n" % [argi]
    of ntySet:
      params.add "to_cef($1)" % [argv]
    else:
      error(lineinfo(arg) & " unsupported param type: " & $arg.typeKind)

    if i < argSize: params.add ", "

  if startIndex > 0:
    let res = args[0]
    case res.typeKind
    of ntyRef:
      if checkWrapped(res):
        body = "result = nc_wrap($1($2))\n" % [calee, params]
      else:
        error(lineinfo(res) & " unsupported ref result")
    of ntyBool:
      body = "result = $1($2) == 1.cint\n" % [calee, params]
    of ntyInt64, ntyInt:
      body = "result = $1($2)\n" % [calee, params]
    of ntyString:
      body = "result = to_nim($1($2))\n" % [calee, params]
    of ntySequence:
      let T = getType(res)[1]
      if checkString(T):
        proloque.add "var res = cef_string_list_alloc()\n"
        params.add ", res"
        body.add "$1($2)\n" % [calee, params]
        epiloque.add "result = to_nim(res)\n"
      else:
        error(lineinfo(res) & " unsupported type of \"result\": seq " & getType(res).treeRepr)
    else:
      error(lineinfo(res) & " unsupported return type: " & $res.typeKind)
  else:
    body = "$1($2)\n" % [calee, params]

  if wrapDebugMode:
    echo proloque
    echo body
    echo epiloque

  result = parseStmt(proloque & body & epiloque)

proc make_nc_name(n: string): string =
  result = "nc_" & n.substr(n.find('_') + 1)

proc getValidProcName(n: NimNode): string =
  if n.kind != nnkPostfix:
    error("need export symbol for method name")
  result = $n[1]

type
  paramPair = object
    nName: NimNode
    nType: NimNode

proc extractParam(res: var seq[paramPair], n: NimNode) =
  let numParam = n.len - 2
  for i in 0.. <numParam:
    res.add paramPair(nName: n[i], nType: n[numParam])

proc collectParams(n: NimNode): seq[paramPair] =
  result = @[]
  # skip result and self
  for i in 2.. <n.len:
    extractParam(result, n[i])

proc checkCefPtr(n: NimNode): bool =
  if n.typeKind != ntyPtr: return false
  let objType = getType(n[0])
  if objType.typeKind != ntyObject: return false
  if $objType[1][0] != "base": return false
  result = true

proc procHasResult(n: NimNode): bool =
  if n[0].kind == nnkEmpty: return false
  if n[0].kind == nnkSym and $n[0] == "void": return false
  result = true

proc isNCSeq(n: NimNode): bool =
  if n.typeKind != ntySequence: return false
  if not checkWrapped(n[1]): return false
  result = true

var global_iidx {.compileTime.} = 0

proc glueSingleMethod(ns: string, nproc, cproc: NimNode, iidx: int): string =
  inc(wrapMethodStat)
  
  let nname = getValidProcName(nproc[0])
  let cname = getValidProcName(cproc[0])
  let nparams = nproc[1][0]
  let cparams = cproc[1][0]
  let nplist = collectParams(nparams)
  let cplist = collectParams(cparams)
  let nresult = procHasResult(nparams)
  let calee = "handler.impl." & nname
  var params = "handler.container"
  if nplist.len > 0: params.add ", "

  var body = ""
  var epiloque = ""
  var epiloque2 = ""
  var proloque = "proc $1_i$2$3 {.cef_callback.} =\n" % [cname, $iidx, cparams.toStrLit().strVal()]
  proloque.add "  var handler = toType($1, self)\n" % [ns]
  proloque.add "  if $1 != nil:\n" % [calee]

  let argSize = nplist.len
  var ci = 0
  for i in 0.. <argSize:
    let n = nplist[i]
    let c = cplist[ci]
    inc(ci)

    #special case for seq
    if isNCSeq(n.nType) and c.nType.typeKind == ntyInt:
      let cc = cplist[ci]
      proloque.add "    proc idxptr(a: ptr ptr $1, i: int): ptr $1 =\n" % [$cc.nType[0][0]]
      proloque.add "      cast[ptr ptr $1](cast[ByteAddress](a) + i * sizeof(pointer))[]\n" % [$cc.nType[0][0]]
      proloque.add "    var $1_p = newSeq[$2]($3.int)\n" % [$n.nName, $n.nType[1], $c.nName]
      proloque.add "    for i in 0.. <$1_p.len:\n" % [$n.nName]
      proloque.add "      $1_p[i] = nc_wrap(idxptr($2, i))\n" % [$n.nName, $cc.nName]
      epiloque.add "    for i in 0.. <$1_p.len:\n" % [$n.nName]
      epiloque.add "      var xx = idxptr($1, i)\n" % [$cc.nName]
      epiloque.add "      release(xx)\n" % [$n.nName]
      params.add "$1_p" % [$n.nName]
      inc(ci)
      if i < argSize-1: params.add ", "
      continue

    case c.nType.typeKind
    of ntyPtr:
      if c.nType.kind == nnkSym:
        if $c.nType == "cef_event_handle":
          params.add $c.nName
        else:
          error("unknow ptr type")
      elif checkCefPtr(c.nType):
        params.add "nc_wrap($1)" % [$c.nName]
        epiloque2.add "  release($1)\n" % [$c.nName]
      elif n.nType.typeKind == ntyString:
        params.add "$$($1)" % [$c.nName]
      elif n.nType.typeKind == ntyVar:
        if n.nType[0].typeKind == ntyString:
          proloque.add "    var $1_p = $$($1)\n" % [$c.nName]
          params.add "$1_p" % [$c.nName]
          epiloque.add "    cef_string_clear($1)\n" % [$c.nName]
          epiloque.add "    discard cef_string_from_utf8($1_p.cstring, $1_p.len.cint, $1)\n" % [$c.nName]
        else:
          error("unknown var ptr type: " & $n.nName)
      elif n.nType.typeKind == ntyObject:
        params.add "to_nim($1)" % [$c.nName]
      else:
        error("unknown ptr type: " & $n.nName)
    of ntyInt32:
      if n.nType.typeKind == ntyBool:
        params.add "$1 == 1.$2" % [$c.nName, $c.nType]
      else:
        params.add "$1.$2" % [$c.nName, $n.nType]
    of ntyPointer, ntyInt, ntyInt64, ntyCstring, ntyEnum:
      params.add $c.nName
    of ntyDistinct:
      if $c.nType == "ptr_cef_browser":
        params.add "nc_wrap($1)" % [$c.nName]
        epiloque2.add "  release($1)\n" % [$c.nName]
      elif $c.nType == "cef_string_list":
        params.add "$$($1)" % [$c.nName]
      else:
        error("unknown distinct param")
    of ntyVar:
      if n.nType[0].typeKind in {ntyInt, ntyInt64}:
        proloque.add "    var $1_p = $1.$2\n" % [$c.nName, $n.nType[0]]
        params.add "$1_p" % [$c.nName]
        epiloque.add "    $1 = $1_p.$2\n" % [$c.nName, $c.nType[0]]
      elif n.nType[0].typeKind == ntyPointer:
        proloque.add "    var $1_p = $1\n" % [$c.nName]
        params.add "$1_p" % [$c.nName]
        epiloque.add "    $1 = $1_p\n" % [$c.nName]      
      elif n.nType[0].typeKind == ntyBool:
        proloque.add "    var $1_p = $1 == 1.$2\n" % [$c.nName, $c.nType[0]]
        params.add "$1_p" % [$c.nName]
        epiloque.add "    $1 = $1_p.$2\n" % [$c.nName, $c.nType[0]]
      elif n.nType[0].typeKind == ntyEnum:
        proloque.add "    var $1_p = $1\n" % [$c.nName]
        params.add "$1_p" % [$c.nName]
        epiloque.add "    $1 = $1_p\n" % [$c.nName]
      elif n.nType[0].typeKind == ntyRef:
        proloque.add "    var $1_p: $2\n" % [$n.nName, $n.nType[0]]
        params.add "$1_p" % [$n.nName]
        epiloque.add "    $1 = cast[$2]($1_p.GetHandler())\n" % [$n.nName, c.nType[0].toStrLit().strVal()]
      else:
        error("unknown var param " & $n.nType[0].typeKind)
    of ntyFloat:
      params.add "$1.$2" % [$c.nName, $n.nType]
    else:
      error("unknown param kind " & $c.nType.typeKind)

    if i < argSize-1: params.add ", "

  if nresult:
    let cres = cparams[0]
    case cres.typeKind
    of ntyInt32:
      body = "    result = $1($2).$3\n" % [calee, params, $cres]
    of ntyInt, ntyInt64, ntyEnum:
      body = "    result = $1($2)\n" % [calee, params]
    of ntyPtr:
      if checkCefPtr(cres):
        body = "    result = $1($2).GetHandler()\n" % [calee, params]
      else:
        error("unknown ptr type")
    of ntyObject:
      body = "    result = to_cef($1($2))\n" % [calee, params]
    else:
      error("$1: unknown result kind $2" % [nname, $cres.typeKind])
  else:
    body = "    $1($2)\n" % [calee, params]

  result = proloque & body & epiloque & epiloque2

macro wrapMethods*(nc, n, c: typed): stmt =
  let nlist = getImpl(n.symbol)[2][2]
  let clist = getImpl(c.symbol)[2][2]
  let ni = $n
  let ns = ni.substr(0, ni.len-3)

  var glue = ""
  var constructor = "proc make$1*[T](impl: $2[T]): T =\n" % [$nc, ni]
  constructor.add "  nc_init($1, T, impl)\n" % [ns]

  for i in 0.. <nlist.len:
    let cproc = clist[i+1] # +1 skip base
    let cname = getValidProcName(cproc[0])
    glue.add glueSingleMethod(ns, nlist[i], cproc, global_iidx)
    constructor.add "  result.handler.$1 = $1_i$2\n" % [cname, $global_iidx]
    inc(global_iidx)

  if wrapDebugMode:
    echo glue
    echo constructor

  result = parseStmt(glue & constructor)

proc wrapCallbackImpl(nc: NimNode, cef: NimNode, methods: NimNode, wrapAPI: bool): string =
  inc(wrapCallbackStat)
  
  let nc_name = make_nc_name($cef)

  var glue = ""
  if wrapAPI: 
    glue.add "wrapAPI($1, $2, false)\n" % [$nc, $cef]
  glue.add "type\n"
  glue.add "  $1_i*[T] = object\n" % [nc_name]

  for m in methods:
    let procName = m[0].toStrLit().strVal()
    let params = m[3].toStrLit().strVal()
    glue.add "    $1: proc$2\n" % [procName, params]

  glue.add "  $1 = object of nc_base[$2, $3]\n" % [nc_name, $cef, $nc]
  glue.add "    impl: $1_i[$2]\n" % [nc_name, $nc]
  glue.add "wrapMethods($1, $2_i, $3)\n" % [$nc, nc_name, $cef]

  if wrapDebugMode:
    echo glue
    
  result = glue
  
macro wrapCallback*(nc: untyped, cef: typed, methods: untyped): stmt =
  let glue = wrapCallbackImpl(nc, cef, methods, true)
  result = parseStmt(glue)
  
macro wrapHandler*(nc: untyped, cef: typed, methods: untyped): stmt =
  let glue = wrapCallbackImpl(nc, cef, methods, false)
  result = parseStmt(glue)