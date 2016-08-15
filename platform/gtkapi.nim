import posix, cef_app_api

const LIB_GTK* = "libgtk-3.so(|.0)"

{.pragma: libgtk, cdecl, dynlib: LIB_GTK.}

type
  Window* = culong

const NULL = 0

proc gtk_init*(argc: var cint; argv: var cstringArray) {.importc: "gtk_init", libgtk.}

proc app_terminate_signal(signal: cint) =
  cef_quit_message_loop()

proc initialize_gtk*() =
  #var argc: cint = 0
  #var argv: array[1, cstring]
  #gtk_init(argc, argv)
  #signal(SIGINT, app_terminate_signal)
  #signal(SIGTERM, app_terminate_signal)
  discard

#proc window_destroy_signal(GtkWidget* widget, gpointer data) =
  #cef_quit_message_loop()

proc set_title*(window: Window; title: cstring) {. importc: "gtk_window_set_title", libgtk.}
