import cef_base_api, nc_util
include cef_import

type
  NCBase*[T, C] = object of RootObj
    handler*: T
    refCount*: int
    container*: C

template toType*(T: typedesc, obj: typed): untyped =
  cast[ptr T](cast[ByteAddress](obj) - sizeof(pointer))

proc genericAddRef[T](self: ptr cef_base) {.cef_callback.} =
  var handler = cast[ptr T](cast[ByteAddress](self) - sizeof(pointer))
  atomicInc(handler.refCount)

proc genericRelease[T](self: ptr cef_base): cint {.cef_callback.} =
  var handler = cast[ptr T](cast[ByteAddress](self) - sizeof(pointer))
  atomicDec(handler.refCount)
  result = (handler.refCount == 0).cint
  if handler.refCount == 0:
    if handler.container != nil:
      handler.container.handler = nil
    freeShared(handler)

proc genericHasOneRef[T](self: ptr cef_base): cint {.cef_callback.} =
  var handler = cast[ptr T](cast[ByteAddress](self) - sizeof(pointer))
  result = (handler.refCount == 1).cint

proc ncInitializeBase[T](base: ptr cef_base) =
  let size = base.size
  if size <= 0:
    echo "FATAL: initialize_cef_base failed, size member not set"
    quit(1)

  base.add_ref = genericAddRef[T]
  base.release = genericRelease[T]
  base.has_one_ref = genericHasOneRef[T]

proc ncInitBase*[A](elem: ptr A) =
  elem.handler.size = sizeof(A)
  ncInitializeBase[A](cast[ptr cef_base](elem.handler.addr))

proc ncFinalizer*[T, C](self: C) =
  if self.handler != nil:
    var handler = toType(T, self.handler)
    handler.container = nil
  ncRelease(self.handler)

#T is nc_xxx from wrapCallback
#C is NCxxx or it's descendant
template ncInit*(T, C: typedesc, impl: typed) =
  var handler = createShared(T)
  ncInitBase[T](handler)
  new(result, ncFinalizer[T, C])
  result.handler = handler.handler.addr
  ncAddRef(handler.handler.addr)
  handler.container = result
  copyMem(handler.impl.addr, impl.unsafeAddr, sizeof(impl))

