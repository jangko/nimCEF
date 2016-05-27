


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

###Translation status(CEF3 ver 2623):

| No | Items                 | Win32    | Linux32 | Win64    | Linux64 | Mac64    | Nim Ver |
|----|-----------------------|----------|---------|----------|---------|----------|---------|
| 1  | CEF3 C API            | complete | 98%     | complete | 98%     | 90%      | 0.13.0  |
| 2  | CEF3 C API example    | yes      | no      | yes      | no      | no       | 0.13.0  |
| 3  | Simple Client Example | yes      | no      | yes      | no      | no       | 0.13.0  |
| 4  | CefClient Example     | 20%      | no      | no       | no      | no       | 0.13.0  |
| 5  | Convenience Layer     | complete | 75%     | complete | 75%     | 60%      | 0.13.0  |


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
* Next step use **callbackImpl**, with three parameters,
	* first param is any valid identifier you want
	* second param is the typeDesc we already defined or the NCxxx type
	* the third param is a list of your procs. The 'self' must have the same type with the second param
  * the third param is optional, and default implementation will be used if no procs are defined
  
```nimrod
callbackImpl(abc, myHandler):
  proc OnBeforeContextMenu(self: myHandler, browser: NCBrowser,
    frame: NCFrame, params: NCContextMenuParams, model: NCMenuModel) =
    discard
   
  proc OnContextMenuCommand(self: myHandler, browser: NCBrowser,
    frame: NCFrame, params: NCContextMenuParams, command_id: cef_menu_id,
    event_flags: cef_event_flags): int =
    discard
```

* if you want to create an instance of your handler, just call NCCreate with single param from callbackImpl first param
```nimrod
var cmhandler_inst = abc.NCCreate()


### HOW TO CREATE USER DEFINED MENU ID
If you use NCContextMenuModel and NCContextMenuHandler to create user defined menu entry, you also need
to provide user defined menu id. You can simply use USER_MENU_ID with single integer parameter

```nimrod
const
  MY_MENU_ID = USER_MENU_ID(1)
  MY_QUIT_ID = USER_MENU_ID(2)
  MY_PLUGIN_ID = USER_MENU_ID(3)
```