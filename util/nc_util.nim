import cef_base_api, strtabs, cef_string_map_api
import cef_string_api, cef_string_list_api, tables
import cef_string_multimap_api, macros, strutils
include cef_import

export strtabs, cef_string_api, cef_string_list_api, cef_string_map_api, tables
export cef_string_multimap_api

type
  NCStringMultiMap* = TableRef[string, seq[string]]

proc newNCStringMultiMap*(): NCStringMultiMap =
  result = newTable[string, seq[string]]()

#don't forget to call cef_string_userfree_free after you finished using
#cef_string from this proc
proc toCef*(str: string): ptr cef_string =
  if str.len == 0: return nil
  result = cef_string_userfree_alloc()
  discard cef_string_from_utf8(str.cstring, str.len.csize_t, result)

proc toNim*(str: cef_string_userfree, dofree = true): string =
  if str == nil: return ""
  var res: cef_string_utf8
  if cef_string_to_utf8(str.str, str.length.csize_t, res.addr) == 1:
    result = newString(res.length)
    copyMem(result.cstring, res.str, res.length)
    cef_string_utf8_clear(res.addr)
  else:
    result = ""
  if dofree: cef_string_userfree_free(str)

proc `$`*(str: ptr cef_string): string = toNim(str, false)

proc `<=`*(cstr: var cef_string, str: string) =
  if str.len != 0:
    discard cef_string_from_utf8(str.cstring, str.len.csize_t, cstr.addr)

template ncFree*(str: ptr cef_string) =
  if str != nil: cef_string_userfree_free(str)

proc toNim*(strlist: cef_string_list, dofree = true): seq[string] =
  var len = cef_string_list_size(strlist).int
  result = newSeq[string](len)
  var res: cef_string
  for i in 0..<len:
    if cef_string_list_value(strlist, i.cint, res.addr) == 1.cint:
      result[i] = $(res.addr)
      cef_string_clear(res.addr)
    else:
      result[i] = ""
  if dofree: cef_string_list_free(strlist)

proc `$`*(list: cef_string_list): seq[string] = toNim(list, false)

#don't forget to call cef_string_list_free
proc toCef*(input: seq[string]): cef_string_list =
  var list = cef_string_list_alloc()
  var res: cef_string
  for x in input:
    if cef_string_from_utf8(x.cstring, x.len.csize_t, res.addr) == 1.cint:
      cef_string_list_append(list, res.addr)
      cef_string_clear(res.addr)
  result = list

template ncFree*(list: cef_string_list) =
  cef_string_list_free(list)

proc toNim*(map: cef_string_map, doFree = true): StringTableRef =
  let count = cef_string_map_size(map)
  result = newStringTable(modeCaseSensitive)
  var key, value: cef_string
  for i in 0..<count:
    discard cef_string_map_key(map, i.cint, key.addr)
    discard cef_string_map_value(map, i.cint, value.addr)
    result[$(key.addr)] = $(value.addr)
    cef_string_clear(key.addr)
    cef_string_clear(value.addr)
  if doFree: cef_string_map_free(map)

proc toNim*(map: cef_string_multimap, doFree = true): NCStringMultiMap =
  result = newTable[string, seq[string]]()
  let len = cef_string_multimap_size(map)
  var key, val: cef_string
  for i in 0..<len:
    if cef_string_multimap_key(map, i.cint, key.addr) == 1.cint:
      let count = cef_string_multimap_find_count(map, key.addr)
      var elem = newSeq[string](count)
      for j in 0..<count:
        discard cef_string_multimap_enumerate(map, key.addr, j.cint, val.addr)
        elem[j] = $(val.addr)
        cef_string_clear(val.addr)
      result[$(key.addr)] = elem
      cef_string_clear(key.addr)
  if doFree: cef_string_multimap_free(map)

#don't forget to call cef_string_multi_map_free
proc toCef*(map: NCStringMultiMap): cef_string_multimap =
  let cmap = cef_string_multimap_alloc()
  for key, elem in map:
    let ckey = toCef(key)
    for val in elem:
      let cval = toCef(val)
      discard cef_string_multimap_append(cmap, ckey, cval)
      cef_string_userfree_free(cval)
    cef_string_userfree_free(ckey)
  result = cmap

template ncFree*(cmap: cef_string_multimap) =
  cef_string_multimap_free(cmap)

var
  wrapDebugMode    {.compileTime.} = false
  wrapCallStat     {.compileTime.} = 0
  wrapProcStat     {.compileTime.} = 0
  wrapMethodStat   {.compileTime.} = 0
  wrapAPIStat      {.compileTime.} = 0
  wrapCallbackStat {.compileTime.} = 0

macro printWrapStat*(): untyped =
  echo "wrapCall    : ", wrapCallStat
  echo "wrapProc    : ", wrapProcStat
  echo "wrapMethod  : ", wrapMethodStat
  echo "wrapAPI     : ", wrapAPIStat
  echo "wrapCallback: ", wrapCallbackStat

proc ncAddRef*[T](elem: T) =
  if elem != nil: elem.add_ref(cast[ptr cef_base](elem))

proc ncRelease*[T](elem: T) =
  if elem != nil: discard elem.release(cast[ptr cef_base](elem))

type
  APIPair = object
    nApi : NimNode
    nBase: NimNode

var apiList {.compileTime.} : seq[APIPair] = @[]

macro registerAPI*(api, base: typed): untyped =
  apiList.add APIPair(nApi: api, nBase: base)
  result = newEmptyNode()

macro wrapAPI*(api, base: untyped, importUtil: bool = true, parent: typed = RootObj): untyped =
  inc(wrapAPIStat)

  let baseName = $base
  let parentName = $parent
  let apiName = $api
  let isRoot = parentName == "RootObj"
  var glue = ""

  if importUtil.boolVal():
    glue.add "import nc_util_impl, $1_api\n" % [baseName]
    glue.add "export $1_api\n" % [baseName]

  glue.add "type\n"
  glue.add "  $1* = ref object of $2\n" % [apiName, parentName]

  if isRoot:
    glue.add "    handler*: ptr $1\n" % [baseName]

  glue.add "proc getHandler*(self: $1): ptr $2 {.inline.} =\n" % [apiName, baseName]

  if isRoot:
    glue.add "  result = if self == nil: nil else: self.handler\n"
  else:
    glue.add "  result = if self == nil: nil else: cast[ptr $1](self.handler)\n" % [baseName]

  glue.add "template ncCastHandler*(self: $1): untyped =\n" % [apiName]
  if isRoot:
    glue.add "  self.handler\n"
  else:
    glue.add "  cast[ptr $1](self.handler)\n" % [baseName]

  glue.add "proc ncFinalizer(self: $1) =\n" % [apiName]
  glue.add "  ncRelease(self.handler)\n"

  glue.add "proc ncWrap*(handler: ptr $1): $2 =\n" % [baseName, apiName]
  glue.add "  if handler == nil: return nil\n"
  glue.add "  new(result, ncFinalizer)\n"
  glue.add "  result.handler = handler\n"
  glue.add "  ncAddRef(handler)\n"
  glue.add "registerAPI($1, $2)\n" % [apiName, baseName]

  if wrapDebugMode:
    echo glue

  result = parseStmt(glue)

macro debugModeOn*(): untyped =
  wrapDebugMode = true
  result = newEmptyNode()

macro debugModeOff*(): untyped =
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

proc getRecList(n: NimNode): NimNode =
  for c in n:
    if c.kind == nnkRecList:
      return c
  result = newEmptyNode()

proc findRoot(n: NimNode): NimNode =
  var parent = n
  while true:
    if parent[1].kind == nnkEmpty: break
    if parent[1].kind == nnkSym:
      if $parent[1] == "RootObj": break
    parent = getType(parent[1])
  result = parent

proc checkSymHandler(nc: NimNode): NimNode =
  var ncstr = $nc
  let pos = ncstr.find(':')
  if pos != -1:
    ncstr = ncstr.substr(0, pos-1)
  for n in apiList:
    if $n.nAPI == ncstr: return getType(n.nBase)
  error(lineinfo(nc) & " unregistered nc type")

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
  let nType = getType(n)
  if nType.typeKind != ntyRef: return false
  let parent = getTypeImpl(nType[1])
  let root = findRoot(parent)
  if root[2].len == 0: return false
  let handler = root[2][0]
  if not (handler.typeKind == ntyPtr and $handler == "handler"): return false
  let handlee = getType(handler)[1]
  if handlee.typeKind != ntyObject: return false
  if handler.typeKind == ntyPtr and substr($handlee, 0, 3) != "cef_": return false
  result = true

proc checkMultiMap(n: NimNode): bool =
  let mapType = getTypeImpl(n)
  if mapType.kind != nnkRefTy: return false
  let bracket = mapType[0]
  if bracket.kind != nnkBracketExpr: return false
  if bracket.len < 3: return false
  if bracket[0].kind != nnkSym and $bracket[0] != "Table": return false
  if bracket[1].kind != nnkSym and $bracket[1] != "string": return false
  if bracket[2].kind != nnkBracketExpr: return false
  let seqType = bracket[2]
  if seqType.len < 2: return false
  if seqType[0].kind != nnkSym and $seqType[0] != "seq": return false
  if seqType[1].kind != nnkSym and $seqType[1] != "string": return false
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
  let hType = getType(getRecList(nType)[0])
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

macro wrapCall*(self: typed, routine: untyped, args: varargs[typed]): untyped =
  inc(wrapCallStat)

  # Sanitary Check
  let
    selfType   = checkSelf(self)         # BracketExpr: sym ref, sym NCXXX:ObjectType
    symHandler = checkSymHandler(selfType[1]) # BracketExpr: sym ptr, sym cef_xxx
    symCef     = getType(symHandler[1])  # ObjectTy: Empty, Reclist: 1..n
    routineList= getRecList(symCef)
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
    params = "ncCastHandler(self)"
    calee = "ncCastHandler(self)." & $routine
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
      proloque.add "let arg$1 = toCef($2)\n" % [argi, argv]
      params.add "arg$1" % [argi]
      epiloque.add "ncFree(arg$1)\n" % [argi]
    of ntyBool, ntyInt, ntyUInt, ntyFloat, ntyFloat32:
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
    of ntyPointer, ntyEnum, ntyInt64, ntyCString, ntyUInt32:
      let argT = getType(rout)[i - startIndex + 3]
      if arg.typeKind == ntyEnum and argT.typeKind != ntyEnum:
        let argType = argT.getBaseType()
        params.add "$1.$2" % [argv, argType]
      else:
        params.add argv
    of ntyRef:
      if arg.kind == nnkHiddenDeref:
        proloque.add "var arg$1 = $2.getHandler()\n" % [argi, argv]
        epiloque.add "$1 = ncWrap(arg$2)\n" % [argv, argi]
        params.add "arg" & argi
      elif checkWrapped(arg):
        let argType = getType(rout)[i - startIndex + 3]
        proloque.add "ncAddRef($1.getHandler())\n" % [argv]
        if argType.typeKind == ntyDistinct:
          params.add "cast[$1]($2.getHandler())" % [$argType, argv]
        else:
          params.add "$1.getHandler()" % [argv]
      elif checkMultiMap(arg):
        proloque.add "let arg$1 = toCef($2)\n" % [argi, argv]
        params.add "arg$1" % [argi]
        epiloque.add "ncFree(arg$1)\n" % [argi]
      else: error(lineinfo(arg) & " unsupported ref type: " & argv)
    of ntySequence:
      let T = getType(arg)[1]
      if checkWrapped(T):
        let handler = $getHandler(T)
        let argType = getType(rout)[i - startIndex + 3].getBaseType()
        proloque.add "var arg$1 = newSeq[ptr $2]($3.len)\n" % [argi, handler, argv]
        proloque.add "for i in 0..<$1.len:\n" % [argv]
        proloque.add "  arg$1[i] = $2[i].getHandler()\n" % [argi, argv]
        proloque.add "  ncAddRef(arg$1[i])\n" % [argi]
        params.add "$1.len.$2, cast[ptr ptr $3](arg$4[0].addr)" % [argv, argType, handler, argi]
      elif checkString(T):
        proloque.add "var arg$1 = toCef($2)\n" % [argi, argv]
        params.add "arg$1" % [argi]
        epiloque.add "ncFree(arg$1)\n" % [argi]
      elif T.typeKind == ntyObject:
        let argLen  = getType(rout)[i - startIndex + 3].getBaseType()
        let argBase = getType(rout)[i - startIndex + 4].getBaseType()
        proloque.add "var arg$1 = newSeq[$2]($3.len)\n" % [argi, argBase, argv]
        proloque.add "for i in 0..<$1.len:\n" % [argv]
        proloque.add "  arg$1[i] = $2[i].toCef()\n" % [argi, argv]
        params.add "$1.len.$2, cast[ptr $3](arg$4[0].addr)" % [argv, argLen, argBase, argi]
      else:
        error(lineinfo(arg) & " unsupported param: " & getType(arg).treeRepr)
    of ntyObject:
      proloque.add "var arg$1 = toCef($2)\n" % [argi, argv]
      params.add "arg$1.addr" % [argi]
      epiloque.add "ncFree(arg$1)\n" % [argi]
    of ntyPtr:
      let cType = getType(rout)[i - startIndex + 3]
      let nType = getType(arg)
      if sameType(cType, nType):
        params.add argv
    of ntyDistinct:
      let T = getType(arg)[1]
      if T.typeKind == ntyPointer:
        params.add argv
      else:
        error(lineinfo(arg) & " unsupported distinct param type: " & $T)
    else:
      error(lineinfo(arg) & " unsupported param type: " & $arg.typeKind)

    if i < argSize: params.add ", "

  if startIndex > 0:
    let res = args[0]
    case res.typeKind
    of ntyBool:
      body = "result = $1($2) == 1.cint\n" % [calee, params]
    of ntyString, ntyObject:
      body = "result = toNim($1($2))\n" % [calee, params]
    of ntyInt64, ntyEnum:
      body = "result = $1($2)\n" % [calee, params]
    of ntyInt:
      body = "result = $1($2).int\n" % [calee, params]
    of ntyInt32:
      body = "result = $1($2).int32\n" % [calee, params]
    of ntyUInt32:
      body = "result = $1($2).uint32\n" % [calee, params]
    of ntyUInt:
      body = "result = $1($2).uint\n" % [calee, params]
    of ntyRef:
      if checkWrapped(res): body = "result = ncWrap($1($2))\n" % [calee, params]
      elif checkMultiMap(res):
        proloque.add "var map = cef_string_multimap_alloc()\n"
        params.add ", map"
        body = "$1($2)\n" % [calee, params]
        epiloque.add "result = toNim(map)\n"
      elif checkStringMap(res):
        proloque.add "var map = cef_string_map_alloc()\n"
        params.add ", map"
        body = "$1($2)\n" % [calee, params]
        epiloque.add "result = toNim(map)\n"
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
          body.add "  result = toNim(res)\n"
          body.add "else:\n"
          body.add "  ncFree(res)\n"
          body.add "  result = @[]\n"
        else:
          body.add "$1($2)\n" % [calee, params]
          body.add "result = toNim(res)\n"
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
        epiloque.add "for i in 0..<$1:\n" % [size]
        epiloque.add "  result[i] = ncWrap(res$1[i])\n" % [argi]
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
        epiloque.add "for i in 0..<$1:\n" % [size]
        epiloque.add "  result[i] = toNim(res$1[i])\n" % [argi]
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

macro wrapProc*(routine: typed, args: varargs[typed]): untyped =
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
      if checkBase(arg): proloque.add "ncAddRef($1)\n" % [argv]
      else: error(lineinfo(arg) & " unsupported ptr type")
      params.add argv
    of ntyEnum, ntyPointer, ntyInt64:
      if arg.kind == nnkHiddenDeref:
        #enumty should have typeName
        let argVal = $getTypeImpl(routine)[0][i - startIndex + 1][0]
        proloque.add "var arg$1 = $2\n" % [argi, argVal]
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
        proloque.add "let arg$1 = toCef($2)\n" % [argi, argv]
        params.add "arg$1" % [argi]
        epiloque.add "ncFree(arg$1)\n" % [argi]
    of ntyRef:
      if checkWrapped(arg): proloque.add "ncAddRef($1.getHandler())\n" % [argv]
      else: error(lineinfo(arg) & " unsupported ref type: " & argv)
      params.add "$1.getHandler()" % [argv]
    of ntyBool, ntyInt, ntyUInt, ntyFloat, ntyInt32, ntyUint32:
      let argType = getType(routine)[i - startIndex + 2].getBaseType()
      if arg.kind == nnkHiddenDeref:
        proloque.add "var arg$1: $2\n" % [argi, argType]
        params.add "arg$1" % [argi]
        epiloque.add "$1 = arg$2\n" % [argv, argi]
      else:
        params.add "$1.$2" % [argv, argType]
    of ntyObject:
      if arg.kind == nnkHiddenDeref:
        proloque.add "var arg$1 = toCef($2)\n" % [argi, argv]
        params.add "arg$1.addr" % [argi]
        epiloque.add "$1 = toNim(arg$2)\n" % [argv, argi]
      else:
        proloque.add "var arg$1 = toCef($2)\n" % [argi, argv]
        params.add "arg$1.addr" % [argi]
        epiloque.add "ncFree(arg$1)\n" % [argi]
    of ntySet:
      params.add "toCef($1)" % [argv]
    else:
      error(lineinfo(arg) & " unsupported param type: " & $arg.typeKind)

    if i < argSize: params.add ", "

  if startIndex > 0:
    let res = args[0]
    case res.typeKind
    of ntyRef:
      if checkWrapped(res):
        body = "result = ncWrap($1($2))\n" % [calee, params]
      else:
        error(lineinfo(res) & " unsupported ref result")
    of ntyBool:
      body = "result = $1($2) == 1.cint\n" % [calee, params]
    of ntyInt64, ntyInt, ntyUint:
      body = "result = $1($2)\n" % [calee, params]
    of ntyString:
      body = "result = toNim($1($2))\n" % [calee, params]
    of ntySequence:
      let T = getType(res)[1]
      if checkString(T):
        proloque.add "var res = cef_string_list_alloc()\n"
        if argSize > 0: params.add ", "
        params.add "res"
        body.add "$1($2)\n" % [calee, params]
        epiloque.add "result = toNim(res)\n"
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
        epiloque.add "for i in 0..<$1:\n" % [size]
        epiloque.add "  result[i] = ncWrap(res$1[i])\n" % [argi]
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
  result = "Tnc_" & n.substr(n.find('_') + 1)

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
  for i in 0..<numParam:
    res.add paramPair(nName: n[i], nType: n[numParam])

proc collectParams(n: NimNode, start = 2): seq[paramPair] =
  result = @[]
  # skip result and self
  for i in start..<n.len:
    extractParam(result, n[i])

proc checkCefPtr(n: NimNode): bool =
  var node = n
  while true:
    let objType = getImpl(node[0])
    if objType.len < 3: return false
    if objType[2].typeKind != ntyObject: return false
    if objType[2].len < 2: return false
    let ofInherit = objType[2][1]
    if ofInherit.kind != nnkEmpty:
      node = ofInherit
      continue
    else:
      if $node[0] == "cef_base": return true
      else: return false
  result = false

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
  for i in 0..<argSize:
    let n = nplist[i]
    let c = cplist[ci]
    inc(ci)

    #special case for seq
    if isNCSeq(n.nType) and c.nType.typeKind == ntyUInt:
      let cc = cplist[ci]
      proloque.add "    proc idxptr(a: ptr ptr $1, i: int): ptr $1 =\n" % [$cc.nType[0][0]]
      proloque.add "      cast[ptr ptr $1](cast[ByteAddress](a) + i * sizeof(pointer))[]\n" % [$cc.nType[0][0]]
      proloque.add "    var $1_p = newSeq[$2]($3.int)\n" % [$n.nName, $n.nType[1], $c.nName]
      proloque.add "    for i in 0..<$1_p.len:\n" % [$n.nName]
      proloque.add "      $1_p[i] = ncWrap(idxptr($2, i))\n" % [$n.nName, $cc.nName]
      epiloque.add "    for i in 0..<$1_p.len:\n" % [$n.nName]
      epiloque.add "      var xx = idxptr($1, i)\n" % [$cc.nName]
      epiloque.add "      ncRelease(xx)\n" % [$n.nName]
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
        params.add "ncWrap($1)" % [$c.nName]
        epiloque2.add "  ncRelease($1)\n" % [$c.nName]
      elif n.nType.typeKind == ntyString:
        params.add "$$($1)" % [$c.nName]
      elif n.nType.typeKind == ntyVar:
        if n.nType[0].typeKind == ntyString:
          proloque.add "    var $1_p = $$($1)\n" % [$c.nName]
          params.add "$1_p" % [$c.nName]
          epiloque.add "    cef_string_clear($1)\n" % [$c.nName]
          epiloque.add "    discard cef_string_from_utf8($1_p.cstring, $1_p.len.csize_t, $1)\n" % [$c.nName]
        else:
          error("unknown var ptr type: " & $n.nName)
      elif n.nType.typeKind == ntyObject:
        params.add "toNim($1)" % [$c.nName]
      else:
        error("unknown ptr type: " & $n.nName)
    of ntyInt32:
      if n.nType.typeKind == ntyBool:
        params.add "$1 == 1.$2" % [$c.nName, $c.nType]
      else:
        params.add "$1.$2" % [$c.nName, $n.nType]
    of ntyPointer, ntyInt, ntyInt64, ntyCstring, ntyEnum, ntyUint:
      params.add $c.nName
    of ntyDistinct:
      if $c.nType == "ptr_cef_browser":
        params.add "ncWrap($1)" % [$c.nName]
        epiloque2.add "  ncRelease($1)\n" % [$c.nName]
      elif $c.nType == "cef_string_list":
        params.add "$$($1)" % [$c.nName]
      elif $c.nType == "cef_event_handle":
        params.add $c.nName
      else:
        error("unknown distinct param: " & $c.nType)
    of ntyVar:
      if n.nType[0].typeKind in {ntyInt, ntyUInt, ntyInt64}:
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
        epiloque.add "    $1 = cast[$2]($1_p.getHandler())\n" % [$n.nName, c.nType[0].toStrLit().strVal()]
      else:
        error("unknown var param " & $n.nType[0].typeKind)
    of ntyFloat:
      params.add "$1.$2" % [$c.nName, $n.nType]
    else:
      error("unknown param kind " & $c.nType.typeKind & ", of " & $c.nName)

    if i < argSize-1: params.add ", "

  if nresult:
    let cres = cparams[0]
    case cres.typeKind
    of ntyInt32:
      body = "    result = $1($2).$3\n" % [calee, params, $cres]
    of ntyInt, ntyInt64, ntyUint, ntyEnum:
      body = "    result = $1($2)\n" % [calee, params]
    of ntyPtr:
      if checkCefPtr(cres):
        body = "    result = $1($2).getHandler()\n" % [calee, params]
        body.add "    ncAddRef(result)\n"
      else:
        error("unknown ptr type")
    of ntyObject:
      body = "    result = toCef($1($2))\n" % [calee, params]
    else:
      error("$1: unknown result kind $2" % [nname, $cres.typeKind])
  else:
    body = "    $1($2)\n" % [calee, params]

  result = proloque & body & epiloque & epiloque2

proc collectMethods(ce: NimNode): NimNode =
  result = newStmtList()
  var temp = newStmtList()
  var parent = ce
  while true:
    let impl = getImpl(parent)
    let recList = impl[2][2]
    temp.add recList
    parent = impl[2][1]
    if parent.kind == nnkEmpty: break
    parent = parent[0]
    if $parent == "cef_base": break

  #parent first then child, that's why the operation must be reversed
  for x in countdown(temp.len-1, 0):
    let recList = temp[x]
    for n in recList:
      result.add n

macro wrapMethods*(nc, n, c: typed): untyped =
  let nlist = getImpl(n)[2][2]
  let clist = collectMethods(c)
  let ni = $n
  let ns = ni.substr(0, ni.len-3)

  var glue = ""
  var constructor = "proc make$1*[T](impl: $2[T]): T =\n" % [$nc, ni]
  constructor.add "  ncInit($1, T, impl)\n" % [ns]
  constructor.add "  var handler = cast[ptr $1](result.handler)\n" % [$c]

  for i in 0..<nlist.len:
    let cproc = clist[i]
    let cname = getValidProcName(cproc[0])
    glue.add glueSingleMethod(ns, nlist[i], cproc, global_iidx)
    constructor.add "  handler.$1 = $1_i$2\n" % [cname, $global_iidx]
    inc(global_iidx)

  if wrapDebugMode:
    echo glue
    echo constructor

  result = parseStmt(glue & constructor)

proc getParentMethods(nc: NimNode): seq[string] =
  result = @[]
  if $nc == "RootObj": return result
  let impl = getImpl(nc)
  let recList = impl[2][2]
  for n in recList:
    result.add n.toStrLit().strVal()

var handlerList {.compileTime.} : seq[APIPair] = @[]

macro registerHandler*(api, base: typed): untyped =
  handlerList.add APIPair(nApi: api, nBase: base)
  result = newEmptyNode()

proc wrapCallbackImpl(nc, cef, parent, methods: NimNode, wrapAPI: bool): string =
  inc(wrapCallbackStat)

  let nc_name = make_nc_name($cef)

  var glue = ""
  if wrapAPI:
    glue.add "wrapAPI($1, $2, false)\n" % [$nc, $cef]
  glue.add "type\n"
  glue.add "  $1_i*[T] = object\n" % [nc_name]

  let parentMethods = getParentMethods(parent)
  for m in parentMethods:
    glue.add "    $1\n" % [m]

  for m in methods:
    let procName = m[0].toStrLit().strVal()
    let params = m[3].toStrLit().strVal()
    glue.add "    $1: proc$2\n" % [procName, params]

  glue.add "  $1* = object of NCBase[$2, $3]\n" % [nc_name, $cef, $nc]
  glue.add "    impl: $1_i[$2]\n" % [nc_name, $nc]
  glue.add "wrapMethods($1, $2_i, $3)\n" % [$nc, nc_name, $cef]
  glue.add "registerHandler($1, $2)\n" % [$nc, nc_name]

  if wrapDebugMode:
    echo glue

  result = glue

macro wrapCallback*(nc: untyped, cef: typed, methods: untyped): untyped =
  let glue = wrapCallbackImpl(nc, cef, bindSym"RootObj", methods, true)
  result = parseStmt(glue)

macro wrapHandler*(nc: untyped, cef: typed, parent: typed, methods: untyped): untyped =
  let glue = wrapCallbackImpl(nc, cef, parent, methods, false)
  result = parseStmt(glue)

macro wrapHandlerNoMethods*(nc: untyped, cef: typed, parent: typed): untyped =
  let glue = wrapCallbackImpl(nc, cef, parent, newStmtList(), false)
  result = parseStmt(glue)

proc isRefInherit(nc: NimNode): NimNode =
  if nc.kind != nnkSym: return newEmptyNode()
  let impl = getImpl(nc)
  if impl.kind != nnkTypeDef: return newEmptyNode()
  if impl[2].typeKind != ntyRef: return newEmptyNode()
  if impl[2][0].typeKind != ntyObject: return newEmptyNode()
  let obj = impl[2][0]
  if obj[1].kind != nnkOfInherit: return newEmptyNode()
  return obj[1][0]

proc isNCObject(nc: NimNode): bool =
  let base = isRefInherit(nc)
  if base.kind == nnkEmpty: return false
  if $base != "RootObj": return false
  if not checkWrapped(getType(nc)[1]): return false
  result = true

proc getHandlerName(base: string): string {.compileTime.} =
  for n in handlerList:
    if $n.nAPI == base: return $n.nBase
  error("unknown type, possibly not a nc object")

proc genField(nc: NimNode): string =
  if nc.kind != nnkProcDef:
    error("must be a proc def")
  let name = $nc[0]
  result = "  $1:$1" % [name]

proc getBaseName(nc: NimNode): string =
  if isNCObject(nc): return $nc
  let base = isRefInherit(nc)
  result = $base

proc handlerImplImpl(nc: NimNode, methods: NimNode, constructorVisible: bool): string =
  let baseName = getBaseName(nc)
  let hName = getHandlerName(baseName)

  let typeID = $global_iidx
  let implID = $(global_iidx + 1)
  inc(global_iidx, 2)

  var glue = "type\n"
  glue.add "  NCType$1 = $2_i[$3]\n" % [typeID, hName, $nc]
  glue.add "var NCImpl$1 = NCType$2" % [implID, typeID]


  if methods.len == 0:
    glue.add "()\n"
  else:
    glue.add "(\n"

  if methods.len > 0:
    if methods[0].kind == nnkProcDef:
      glue.add genField(methods[0])
    else:
      let len = methods[0].len
      for i in 0..<len:
        let n = methods[0][i]
        glue.add genField(n)
        if i < len-1: glue.add ",\n"

  if methods.len != 0:
    glue.add ")\n"

  let star = if constructorVisible: "*" else: ""
  glue.add "proc make$1NCImplNC$2(): $1 = \n" % [$nc, star]
  glue.add "  result = make$1(NCImpl$2)\n" % [baseName, implID]

  if wrapDebugMode:
    echo glue

  result = glue

macro handlerImpl*(nc: typed, methods: varargs[typed]): untyped =
  let glue = handlerImplImpl(nc, methods, true)
  result = methods[0]
  result.add parseStmt(glue)

macro closureHandlerImpl*(nc: typed, methods: varargs[typed]): untyped =
  let glue = handlerImplImpl(nc, methods, false)
  result = methods[0]
  result = parseStmt(glue)

template ncCreate*(n: typed): untyped =
  `make n NCImplNC`()

var
  vm_menu_id {.compileTime.} = 1

macro MENU_ID*(n: untyped): untyped =
  if n.kind != nnkStmtList:
    error(n.lineinfo() & " expected stmtlist")

  var glue = "const\n"
  for c in n:
    if c.kind != nnkIdent:
      error(c.lineinfo() & " expected identifer")
    glue.add "  $1 = USER_MENU_ID($2)\n" % [$c, $vm_menu_id]
    inc vm_menu_id

  result = parseStmt(glue)

macro ncBindTask*(ident: untyped, routine: typed): untyped =
  var procName: string
  var rout: NimNode
  if routine.kind == nnkCall:
    procName = $routine[0]
    rout = getImpl(routine[0])
  else:
    procName = $routine
    rout = getImpl(routine)

  let params = params(rout)
  let paramList = collectParams(params, 1)
  let typeID = $global_iidx
  inc(global_iidx)

  var args = ""
  var ex_args = ""
  var call_args = ""
  for i in 0..<paramList.len:
    let arg = paramList[i]
    args.add "arg$1: $2" % [$i, arg.nType.toStrlit().strVal]
    ex_args.add "self.nc_arg$1" % [$i]
    call_args.add "arg$1" % [$i]
    if i < paramList.len - 1:
      args.add ", "
      ex_args.add ", "
      call_args.add ", "

  var glue = "proc $1($2): NCTask =\n" % [$ident, args]
  glue.add "  type\n"
  glue.add "    NCType$1 = ref object of NCTask\n" % [typeID]

  for i in 0..<paramList.len:
    let arg = paramList[i]
    glue.add "      nc_arg$1: $2\n" % [$i, arg.nType.toStrlit().strVal]

  glue.add "  closureHandlerImpl(NCType$1):\n" % [typeID]
  glue.add "    proc Execute(self: NCType$1) =\n" % [typeID]
  glue.add "      $1($2)\n" % [procName, ex_args]

  glue.add "  proc newNCType$1($2): NCType$1 =\n" % [typeID, args]
  glue.add "    result = NCType$1.ncCreate()\n" % [typeID]

  for i in 0..<paramList.len:
    glue.add "    result.nc_arg$1 = arg$1\n" % [$i]

  glue.add "  result = newNCType$1($2)\n" % [typeID, call_args]

  if wrapDebugMode:
    echo glue

  result = parseStmt(glue)
