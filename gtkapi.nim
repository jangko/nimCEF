import posix

const LIB_GTK* = "libgtk-3.so(|.0)"

{.pragma: libgtk, cdecl, dynlib: LIB_GTK.}

proc gtk_init*(argc: var cint; argv: var cstringArray) {.importc: "gtk_init", libgtk.}

proc app_terminate_signal(signal: cint) {.cdecl.} =
  cef_quit_message_loop()

proc initialize_gtk*() =
  gtk_init(0, NULL)
  signal(SIGINT, app_terminate_signal)
  signal(SIGTERM, app_terminate_signal)

proc window_destroy_signal(GtkWidget* widget, gpointer data) {.cdecl.} =
  cef_quit_message_loop()

