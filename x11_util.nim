import gtkapi, nc_types, nc_browser

when defined(macosx):
  const libX11* = "libX11.dylib"
else:
  const libX11* = "libX11.so.6"

{.pragma: libx11, cdecl, dynlib: libX11, importc.}
{.pragma: libx11c, cdecl, dynlib: libX11.}

type
  PPChar* = ptr cstring
  PAtom* = ptr TAtom
  TAtom* = culong
  TBool* = cint
  TStatus* = cint
  TWindow* = culong
  Pcuchar* = cstring
  TXID* = culong
  PXErrorEvent* = ptr TXErrorEvent
  TXErrorEvent*{.final.} = object
    theType*: cint
    display*: XDisplay
    resourceid*: TXID
    serial*: culong
    error_code*: cuchar
    request_code*: cuchar
    minor_code*: cuchar
    
  TXErrorHandler* = proc(para1: XDisplay, para2: PXErrorEvent): cint {.cdecl.}
  TXIOErrorHandler* = proc(para1: XDisplay): cint {.cdecl.}
  
const
  PropModeReplace* = 0

proc XInternAtoms*(para1: XDisplay, para2: PPchar, para3: cint, para4: TBool, para5: PAtom): TStatus {.libx11.}

proc XChangeProperty*(para1: XDisplay, para2: TWindow, para3: TAtom,
                      para4: TAtom, para5: cint, para6: cint, para7: Pcuchar,
                      para8: cint): cint {.libx11.}

proc XStoreName*(para1: XDisplay, para2: TWindow, para3: cstring): cint {.libx11.}
proc XSetErrorHandler*(para1: TXErrorHandler): TXErrorHandler {.libx11.}
proc XSetIOErrorHandler*(para1: TXIOErrorHandler): TXIOErrorHandler {.libx11.}

let
  atom1 = "_NET_WM_NAME"
  atom2 = "UTF8_STRING"

var kAtoms = [atom1.cstring, atom2.cstring]

proc PlatformTitleChange*(browser: NCBrowser, title: string) =
  # Retrieve the X11 display shared with Chromium.
  var display = cef_get_xdisplay()
  doAssert(display.pointer != nil)

  # Retrieve the X11 window handle for the browser.
  var window = browser.getHost().getWindowHandle()
  doAssert(window != kNullWindowHandle.culong)

  # Retrieve the atoms required by the below XChangeProperty call.
  var atoms: array[2, TAtom]
  var result = XInternAtoms(display, kAtoms[0].addr, 2, 0.cint, atoms[0].addr)
  if result == 0: return

  # Set the window title.
  discard XChangeProperty(display,
                  window,
                  atoms[0],
                  atoms[1],
                  8.cint,
                  PropModeReplace.cint,
                  title,
                  title.len.cint)

  # TODO(erg): This is technically wrong. So XStoreName and friends expect
  # this in Host Portable Character Encoding instead of UTF-8, which I believe
  # is Compound Text. This shouldn't matter 90% of the time since this is the
  # fallback to the UTF8 property above.
  discard XStoreName(display, window, title)
