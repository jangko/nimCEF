import cef\cef_base_api, nc_util
include cef\cef_import

type
  nc_base*[T, C] = object of RootObj
    handler*: T
    refCount*: int
    container*: C

template toType*(T: typedesc, obj: expr): expr =
  cast[ptr T](cast[ByteAddress](obj) - sizeof(pointer))

proc generic_add_ref[T](self: ptr cef_base) {.cef_callback.} =
  var handler = cast[ptr T](cast[ByteAddress](self) - sizeof(pointer))
  atomicInc(handler.refCount)

proc generic_release[T](self: ptr cef_base): cint {.cef_callback.} =
  var handler = cast[ptr T](cast[ByteAddress](self) - sizeof(pointer))
  atomicDec(handler.refCount)
  result = (handler.refCount == 0).cint
  if handler.refCount == 0:
    handler.container.handler = nil
    freeShared(handler)

proc generic_has_one_ref[T](self: ptr cef_base): cint {.cef_callback.} =
  var handler = cast[ptr T](cast[ByteAddress](self) - sizeof(pointer))
  result = (handler.refCount == 1).cint

proc nc_initialize_base[T](base: ptr cef_base) =
  let size = base.size
  if size <= 0:
    echo "FATAL: initialize_cef_base failed, size member not set"
    quit(1)

  base.add_ref = generic_add_ref[T]
  base.release = generic_release[T]
  base.has_one_ref = generic_has_one_ref[T]

proc nc_init_base*[A](elem: ptr A) =
  elem.handler.base.size = sizeof(A)
  nc_initialize_base[A](cast[ptr cef_base](elem.handler.addr))

proc nc_finalizer*[T](self: T) =
  release(self.handler)

template nc_init*(T, X: typedesc, impl: expr) =
  var handler = createShared(T)
  nc_init_base[T](handler)
  new(result, nc_finalizer[X])
  result.handler = handler.handler.addr
  add_ref(handler.handler.addr)
  handler.container = result
  copyMem(handler.impl.addr, impl.unsafeAddr, sizeof(impl))

