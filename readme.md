


# nimCEF

Chromium Embedded Framework(CEF3) wrapper.

---

nimCEF consist of two parts:

* First part: nimCEF is a thin wrapper for CEF3 written in Nim.
Basically, nimCEF is CEF3 C API translated to Nim, therefore
if you know how to use CEF3 C API, using **First part** is not much different.

* Second part: Convenience layer added on top of C style API to ease
the development in Nim style. Nim native datatypes will be used whenever possible.
And many of the ref-count related issues already handled for you.
The Convenience Layer heavily utilizing Nim macros to generate consistent and efficient wrapper.

---

### Translation status(CEF3 ver 2704):

| No | Items                 | Win32    | Linux32 | Win64    | Linux64 | Mac64    | Nim Ver  |
|----|-----------------------|----------|---------|----------|---------|----------|----------|
| 1  | CEF3 C API            | complete | 98%     | complete | 98%     | 90%      |  0.14.2  |
| 2  | CEF3 C API example    | yes      | no      | yes      | no      | no       |  0.14.2  |
| 3  | Simple Client Example | yes      | no      | yes      | no      | no       |  0.14.2  |
| 4  | CefClient Example     | 20%      | no      | no       | no      | no       |  0.14.2  |
| 5  | Convenience Layer     | complete | 75%     | complete | 75%     | 60%      |  0.14.2  |

### Latest Statistics

| Macro Name   | Call Count |
|--------------|------------|
| wrapCall     |    662     |
| wrapProc     |    80      |
| wrapMethod   |    151     |
| wrapAPI      |    109     |
| wrapCallback |    45      |

### HOW TO BUILD nimCEF EXAMPLES
From your console command prompt type:

To build all examples:

```sh
nim e build.nims
```

To build individual example:

```sh
nim c test_client
nim c test_api
nim c test_parser
etc
```

### HOW TO PREPARE RUNTIME LIBRARY
* make sure your cef library binary bitness is compatible with your executable
* download prebuilt binary from [here](http://www.magpcss.net/cef_downloads/), or built from the source yourself
* place your binaries according to this [layout](https://bitbucket.org/chromiumembedded/cef/wiki/GeneralUsage#markdown-header-application-layout)
* run your executable

### HOW TO CREATE HANDLER/CALLBACK DEFINITION AND INSTANCE

* First import your needed files, notably nc_util and nc_types

```nimrod
import nc_context_menu_handler, nc_browser, nc_types
import nc_util, nc_context_menu_params, nc_menu_model
```

* Then define your own handler type inherited from e.g. NCContextMenuHandler, but this is optional, you can use NCContextMenuHandler directly without inheriting it.

```nimrod
type
  myHandler = ref object of NCContextMenuHandler
```
* Next step use **handlerImpl**, with two parameters,
	* first param is the typeDesc we already defined or the NCxxx type
	* the second param is a list of your procs. The 'self' must have the same type with the first param
  * the second param is optional, and default implementation will be used if no procs are defined

```nimrod
handlerImpl(myHandler):
  proc OnBeforeContextMenu(self: myHandler, browser: NCBrowser,
    frame: NCFrame, params: NCContextMenuParams, model: NCMenuModel) =
    discard

  proc OnContextMenuCommand(self: myHandler, browser: NCBrowser,
    frame: NCFrame, params: NCContextMenuParams, command_id: cef_menu_id,
    event_flags: cef_event_flags): int =
    discard
```

* if you want to create an instance of your handler, just call NCCreate with single param from **handlerImpl** first param
```nimrod
var cmhandler_inst = myHandler.NCCreate()
```

### HOW TO CREATE USER DEFINED MENU ID
If you use NCContextMenuModel and NCContextMenuHandler to create user defined menu entry, you also need
to provide user defined menu id. You can simply use USER_MENU_ID with single integer parameter

```nimrod
const
  MY_MENU_ID = USER_MENU_ID(1)
  MY_QUIT_ID = USER_MENU_ID(2)
  MY_PLUGIN_ID = USER_MENU_ID(3)
```

or better yet, you can use MENU_ID macro to guarantee you always get unique id for each identifier

```nimrod
MENU_ID:
  MY_MENU_ID
  MY_QUIT_ID
  MY_PLUGIN_ID
```

### HOW TO POST TASK TO OTHER THREAD

* You can use handlerImpl to implement your own callback object derived from NCTask
* or you can use NCBindTask to help you do that in a much simpler way

```nimrod
proc ContinueOpenOnIOThread(fileId: int) =
  NC_REQUIRE_IO_THREAD()
  #do something in IO thread

proc OpenMyFile(fileId: int) =
  # first param is the task's name
  # second param is a proc that will be executed in target thread
  NCBindTask(continueOpenTask, ContinueOpenOnIOThread)
  discard NCPostTask(TID_IO, ContinueOpenFileTask(fileId))
```

How to resolve overloaded proc? You can give param to target proc to help compiler decide which one will be used
```nimrod
proc readFile(fileId: int) =
  NC_REQUIRE_IO_THREAD()
  #do something

proc readFile(fileId: int, mode: int) =
  NC_REQUIRE_IO_THREAD()
  #do something

proc readMyFile(fileId: int, mode: int) =
  # help the compiler to choose between overloaded procs
  NCBindTask(readMyFileTask, readFile(fileId, mode))
  discard NCPostTask(TID_IO, readMyFileTask(fileId, mode))
```

You must be very careful when you post object across threads boundary for the reason below.

### MULTITHREAD ISSUE
Nim memory model and C/C++ memory model is different. In C/C++, object can be freely posted to another thread via CefPostTask.
While in Nim, NCPostTask should be used carefully. Every Nim thread has their own heap and GC. if you must post object across
threads, you must create object in global heap, it means you must manually manage the object lifetime and you cannot use
string or seq as usual(they must be manually marked by GC_ref/GC_unref). If you don't post object across threads boundary,
you can call setupForeignThreadGC() before you create any object and use them as usual inside that thread only.