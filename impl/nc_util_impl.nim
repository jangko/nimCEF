import cef\cef_base_api, nc_util
include cef\cef_import

type
  nc_base*[T, C] = object of RootObj
    handler: T
    refCount: int
    container*: C
    
proc generic_add_ref[T](self: ptr cef_base) {.cef_callback.} =
  var handler = cast[T](self)
  atomicInc(handler.refCount)

proc generic_release[T](self: ptr cef_base): cint {.cef_callback.} =
  var handler = cast[T](self)
  if atomicDec(handler.refCount) == 0:
    freeShared(self)

proc generic_has_one_ref[T](self: ptr cef_base): cint {.cef_callback.} =
  var handler = cast[T](self)
  result = (handler.refCount == 1).cint

proc nc_initialize_base[T](base: ptr cef_base) =
  let size = base.size
  if size <= 0:
    echo "FATAL: initialize_cef_base failed, size member not set"
    quit(1)

  base.add_ref = generic_add_ref[T]
  base.release = generic_release[T]
  base.has_one_ref = generic_has_one_ref[T]

proc nc_init_base[A](elem: A) =
  elem.handler.base.size = sizeof(A)
  nc_initialize_base[A](cast[ptr cef_base](elem.handler.addr))

proc nc_finalizer*[T](self: T) =
  release(self.handler)

template nc_init*(T, X: typedesc, impl: expr) =
  var handler = createShared(T)
  nc_init_base(handler)
  new(result, nc_finalizer[X])
  result.handler = handler.handler.addr
  add_ref(handler.handler.addr)
  handler.container = result
  handler.impl = impl
  
  