import cef_types, cef_string_api, nc_util

type
  # Initialization settings. Specify NULL or 0 to get the recommended default
  # values. Many of these and other settings can also configured using command-
  # line switches.

  NCSettings* = object
    # Set to true (1) to use a single process for the browser and renderer. This
    # run mode is not officially supported by Chromium and is less stable than
    # the multi-process default. Also configurable using the "single-process"
    # command-line switch.
    single_process*: bool

    # Set to true (1) to disable the sandbox for sub-processes. See
    # cef_sandbox_win.h for requirements to enable the sandbox on Windows. Also
    # configurable using the "no-sandbox" command-line switch.
    no_sandbox*: bool

    # The path to a separate executable that will be launched for sub-processes.
    # By default the browser process executable is used. See the comments on
    # CefExecuteProcess() for details. Also configurable using the
    # "browser-subprocess-path" command-line switch.
    browser_subprocess_path*: string

    # Set to true (1) to have the browser process message loop run in a separate
    # thread. If false (0) than the CefDoMessageLoopWork() function must be
    # called from your application message loop. This option is only supported on
    # Windows.
    multi_threaded_message_loop*: bool

    # Set to true (1) to enable windowless (off-screen) rendering support. Do not
    # enable this value if the application does not use windowless rendering as
    # it may reduce rendering performance on some systems.
    windowless_rendering_enabled*: bool

    # Set to true (1) to disable configuration of browser process features using
    # standard CEF and Chromium command-line arguments. Configuration can still
    # be specified using CEF data structures or via the
    # CefApp::OnBeforeCommandLineProcessing() method.
    command_line_args_disabled*: bool

    # The location where cache data will be stored on disk. If empty then
    # browsers will be created in "incognito mode" where in-memory caches are
    # used for storage and no data is persisted to disk. HTML5 databases such as
    # localStorage will only persist across sessions if a cache path is
    # specified. Can be overridden for individual CefRequestContext instances via
    # the CefRequestContextSettings.cache_path value.
    cache_path*: string

    # The location where user data such as spell checking dictionary files will
    # be stored on disk. If empty then the default platform-specific user data
    # directory will be used ("~/.cef_user_data" directory on Linux,
    # "~/Library/Application Support/User Data" directory on Mac OS X,
    # "Local Settings\Application Data\User Data" directory under the user
    # profile directory on Windows).
    user_data_path*: string

    # To persist session cookies (cookies without an expiry date or validity
    # interval) by default when using the global cookie manager set this value to
    # true (1). Session cookies are generally intended to be transient and most
    # Web browsers do not persist them. A |cache_path| value must also be
    # specified to enable this feature. Also configurable using the
    # "persist-session-cookies" command-line switch. Can be overridden for
    # individual CefRequestContext instances via the
    # CefRequestContextSettings.persist_session_cookies value.
    persist_session_cookies*: bool

    # To persist user preferences as a JSON file in the cache path directory set
    # this value to true (1). A |cache_path| value must also be specified
    # to enable this feature. Also configurable using the
    # "persist-user-preferences" command-line switch. Can be overridden for
    # individual CefRequestContext instances via the
    # CefRequestContextSettings.persist_user_preferences value.
    persist_user_preferences*: bool

    # Value that will be returned as the User-Agent HTTP header. If empty the
    # default User-Agent string will be used. Also configurable using the
    # "user-agent" command-line switch.
    user_agent*: string

    # Value that will be inserted as the product portion of the default
    # User-Agent string. If empty the Chromium product version will be used. If
    # |userAgent| is specified this value will be ignored. Also configurable
    # using the "product-version" command-line switch.
    product_version*: string

    # The locale string that will be passed to WebKit. If empty the default
    # locale of "en-US" will be used. This value is ignored on Linux where locale
    # is determined using environment variable parsing with the precedence order:
    # LANGUAGE, LC_ALL, LC_MESSAGES and LANG. Also configurable using the "lang"
    # command-line switch.
    locale*: string

    # The directory and file name to use for the debug log. If empty a default
    # log file name and location will be used. On Windows and Linux a "debug.log"
    # file will be written in the main executable directory. On Mac OS X a
    # "~/Library/Logs/<app name>_debug.log" file will be written where <app name>
    # is the name of the main app executable. Also configurable using the
    # "log-file" command-line switch.
    log_file*: string

    # The log severity. Only messages of this severity level or higher will be
    # logged. Also configurable using the "log-severity" command-line switch with
    # a value of "verbose", "info", "warning", "error", "error-report" or
    # "disable".
    log_severity*: cef_log_severity

    # Custom flags that will be used when initializing the V8 JavaScript engine.
    # The consequences of using custom flags may not be well tested. Also
    # configurable using the "js-flags" command-line switch.
    javascript_flags*: string

    # The fully qualified path for the resources directory. If this value is
    # empty the cef.pak and/or devtools_resources.pak files must be located in
    # the module directory on Windows/Linux or the app bundle Resources directory
    # on Mac OS X. Also configurable using the "resources-dir-path" command-line
    # switch.
    resources_dir_path*: string

    # The fully qualified path for the locales directory. If this value is empty
    # the locales directory must be located in the module directory. This value
    # is ignored on Mac OS X where pack files are always loaded from the app
    # bundle Resources directory. Also configurable using the "locales-dir-path"
    # command-line switch.
    locales_dir_path*: string

    # Set to true (1) to disable loading of pack files for resources and locales.
    # A resource bundle handler must be provided for the browser and render
    # processes via CefApp::GetResourceBundleHandler() if loading of pack files
    # is disabled. Also configurable using the "disable-pack-loading" command-
    # line switch.
    pack_loading_disabled*: bool

    # Set to a value between 1024 and 65535 to enable remote debugging on the
    # specified port. For example, if 8080 is specified the remote debugging URL
    # will be http:#localhost:8080. CEF can be remotely debugged from any CEF or
    # Chrome browser window. Also configurable using the "remote-debugging-port"
    # command-line switch.
    remote_debugging_port*: int

    # The number of stack trace frames to capture for uncaught exceptions.
    # Specify a positive value to enable the CefRenderProcessHandler::
    # OnUncaughtException() callback. Specify 0 (default value) and
    # OnUncaughtException() will not be called. Also configurable using the
    # "uncaught-exception-stack-size" command-line switch.
    uncaught_exception_stack_size*: int

    # By default CEF V8 references will be invalidated (the IsValid() method will
    # return false) after the owning context has been released. This reduces the
    # need for external record keeping and avoids crashes due to the use of V8
    # references after the associated context has been released.
    #
    # CEF currently offers two context safety implementations with different
    # performance characteristics. The default implementation (value of 0) uses a
    # map of hash values and should provide better performance in situations with
    # a small number contexts. The alternate implementation (value of 1) uses a
    # hidden value attached to each context and should provide better performance
    # in situations with a large number of contexts.
    #
    # If you need better performance in the creation of V8 references and you
    # plan to manually track context lifespan you can disable context safety by
    # specifying a value of -1.
    #
    # Also configurable using the "context-safety-implementation" command-line
    # switch.
    context_safety_implementation*: int

    # Set to true (1) to ignore errors related to invalid SSL certificates.
    # Enabling this setting can lead to potential security vulnerabilities like
    # "man in the middle" attacks. Applications that load content from the
    # internet should not enable this setting. Also configurable using the
    # "ignore-certificate-errors" command-line switch. Can be overridden for
    # individual CefRequestContext instances via the
    # CefRequestContextSettings.ignore_certificate_errors value.
    ignore_certificate_errors*: bool

    # Opaque background color used for accelerated content. By default the
    # background color will be white. Only the RGB compontents of the specified
    # value will be used. The alpha component must greater than 0 to enable use
    # of the background color but will be otherwise ignored.
    background_color*: cef_color

    # Comma delimited ordered list of language codes without any whitespace that
    # will be used in the "Accept-Language" HTTP header. May be overridden on a
    # per-browser basis using the CefBrowserSettings.accept_language_list value.
    # If both values are empty then "en-US,en" will be used. Can be overridden
    # for individual CefRequestContext instances via the
    # CefRequestContextSettings.accept_language_list value.
    accept_language_list*: string

proc toCef*(ns: NCSettings): cef_settings =
  result.size = sizeof(cef_settings)
  result.single_process = ns.single_process.cint
  result.no_sandbox = ns.no_sandbox.cint
  result.browser_subprocess_path <= ns.browser_subprocess_path
  result.multi_threaded_message_loop  = ns.multi_threaded_message_loop.cint
  result.windowless_rendering_enabled = ns.windowless_rendering_enabled.cint
  result.command_line_args_disabled   = ns.command_line_args_disabled.cint
  result.cache_path <= ns.cache_path
  result.user_data_path <= ns.user_data_path
  result.persist_session_cookies  = ns.persist_session_cookies.cint
  result.persist_user_preferences = ns.persist_user_preferences.cint
  result.user_agent <= ns.user_agent
  result.product_version <= ns.product_version
  result.locale <= ns.locale
  result.log_file <= ns.log_file
  result.log_severity = ns.log_severity
  result.javascript_flags <= ns.javascript_flags
  result.resources_dir_path <= ns.resources_dir_path
  result.locales_dir_path <= ns.locales_dir_path
  result.pack_loading_disabled = ns.pack_loading_disabled.cint
  result.remote_debugging_port = ns.remote_debugging_port.cint
  result.uncaught_exception_stack_size = ns.uncaught_exception_stack_size.cint
  result.context_safety_implementation = ns.context_safety_implementation.cint
  result.ignore_certificate_errors = ns.ignore_certificate_errors.cint
  result.background_color = ns.background_color
  result.accept_language_list <= ns.accept_language_list

proc ncFree*(cs: var cef_settings) =
  cef_string_clear(cs.browser_subprocess_path.addr)
  cef_string_clear(cs.cache_path.addr)
  cef_string_clear(cs.user_data_path.addr)
  cef_string_clear(cs.user_agent.addr)
  cef_string_clear(cs.product_version.addr)
  cef_string_clear(cs.locale.addr)
  cef_string_clear(cs.log_file.addr)
  cef_string_clear(cs.javascript_flags.addr)
  cef_string_clear(cs.resources_dir_path.addr)
  cef_string_clear(cs.locales_dir_path.addr)
  cef_string_clear(cs.accept_language_list.addr)

type
  # Request context initialization settings. Specify NULL or 0 to get the
  # recommended default values.
  NCRequestContextSettings* = object
    # The location where cache data will be stored on disk. If empty then
    # browsers will be created in "incognito mode" where in-memory caches are
    # used for storage and no data is persisted to disk. HTML5 databases such as
    # localStorage will only persist across sessions if a cache path is
    # specified. To share the global browser cache and related configuration set
    # this value to match the CefSettings.cache_path value.
    cache_path*: string

    # To persist session cookies (cookies without an expiry date or validity
    # interval) by default when using the global cookie manager set this value to
    # true (1). Session cookies are generally intended to be transient and most
    # Web browsers do not persist them. Can be set globally using the
    # CefSettings.persist_session_cookies value. This value will be ignored if
    # |cache_path| is empty or if it matches the CefSettings.cache_path value.
    persist_session_cookies*: bool

    # To persist user preferences as a JSON file in the cache path directory set
    # this value to true (1). Can be set globally using the
    # CefSettings.persist_user_preferences value. This value will be ignored if
    # |cache_path| is empty or if it matches the CefSettings.cache_path value.
    persist_user_preferences*: bool

    # Set to true (1) to ignore errors related to invalid SSL certificates.
    # Enabling this setting can lead to potential security vulnerabilities like
    # "man in the middle" attacks. Applications that load content from the
    # internet should not enable this setting. Can be set globally using the
    # CefSettings.ignore_certificate_errors value. This value will be ignored if
    # |cache_path| matches the CefSettings.cache_path value.
    ignore_certificate_errors*: bool

    # Comma delimited ordered list of language codes without any whitespace that
    # will be used in the "Accept-Language" HTTP header. Can be set globally
    # using the CefSettings.accept_language_list value or overridden on a per-
    # browser basis using the CefBrowserSettings.accept_language_list value. If
    # all values are empty then "en-US,en" will be used. This value will be
    # ignored if |cache_path| matches the CefSettings.cache_path value.
    accept_language_list*: string

  # Browser initialization settings. Specify NULL or 0 to get the recommended
  # default values. The consequences of using custom values may not be well
  # tested. Many of these and other settings can also configured using command-
  # line switches.
  NCBrowserSettings* = object
    # The maximum rate in frames per second (fps) that CefRenderHandler::OnPaint
    # will be called for a windowless browser. The actual fps may be lower if
    # the browser cannot generate frames at the requested rate. The minimum
    # value is 1 and the maximum value is 60 (default 30). This value can also be
    # changed dynamically via CefBrowserHost::SetWindowlessFrameRate.
    windowless_frame_rate*: int

    # The below values map to WebPreferences settings.

    # Font settings.
    standard_font_family*: string
    fixed_font_family*: string
    serif_font_family*: string
    sans_serif_font_family*: string
    cursive_font_family*: string
    fantasy_font_family*: string
    default_font_size*: int
    default_fixed_font_size*: int
    minimum_font_size*: int
    minimum_logical_font_size*: int

    # Default encoding for Web content. If empty "ISO-8859-1" will be used. Also
    # configurable using the "default-encoding" command-line switch.
    default_encoding*: string

    # Controls the loading of fonts from remote sources. Also configurable using
    # the "disable-remote-fonts" command-line switch.
    remote_fonts*: cef_state

    # Controls whether JavaScript can be executed. Also configurable using the
    # "disable-javascript" command-line switch.
    javascript*: cef_state

    # Controls whether JavaScript can be used for opening windows. Also
    # configurable using the "disable-javascript-open-windows" command-line
    # switch.
    javascript_open_windows*: cef_state

    # Controls whether JavaScript can be used to close windows that were not
    # opened via JavaScript. JavaScript can still be used to close windows that
    # were opened via JavaScript or that have no back/forward history. Also
    # configurable using the "disable-javascript-close-windows" command-line
    # switch.
    javascript_close_windows*: cef_state

    # Controls whether JavaScript can access the clipboard. Also configurable
    # using the "disable-javascript-access-clipboard" command-line switch.
    javascript_access_clipboard*: cef_state

    # Controls whether DOM pasting is supported in the editor via
    # execCommand("paste"). The |javascript_access_clipboard| setting must also
    # be enabled. Also configurable using the "disable-javascript-dom-paste"
    # command-line switch.
    javascript_dom_paste*: cef_state

    # Controls whether the caret position will be drawn. Also configurable using
    # the "enable-caret-browsing" command-line switch.
    caret_browsing*: cef_state

    # Controls whether any plugins will be loaded. Also configurable using the
    # "disable-plugins" command-line switch.
    plugins*: cef_state

    # Controls whether file URLs will have access to all URLs. Also configurable
    # using the "allow-universal-access-from-files" command-line switch.
    universal_access_from_file_urls*: cef_state

    # Controls whether file URLs will have access to other file URLs. Also
    # configurable using the "allow-access-from-files" command-line switch.
    file_access_from_file_urls*: cef_state

    # Controls whether web security restrictions (same-origin policy) will be
    # enforced. Disabling this setting is not recommend as it will allow risky
    # security behavior such as cross-site scripting (XSS). Also configurable
    # using the "disable-web-security" command-line switch.
    web_security*: cef_state

    # Controls whether image URLs will be loaded from the network. A cached image
    # will still be rendered if requested. Also configurable using the
    # "disable-image-loading" command-line switch.
    image_loading*: cef_state

    # Controls whether standalone images will be shrunk to fit the page. Also
    # configurable using the "image-shrink-standalone-to-fit" command-line
    # switch.
    image_shrink_standalone_to_fit*: cef_state

    # Controls whether text areas can be resized. Also configurable using the
    # "disable-text-area-resize" command-line switch.
    text_area_resize*: cef_state

    # Controls whether the tab key can advance focus to links. Also configurable
    # using the "disable-tab-to-links" command-line switch.
    tab_to_links*: cef_state

    # Controls whether local storage can be used. Also configurable using the
    # "disable-local-storage" command-line switch.
    local_storage*: cef_state

    # Controls whether databases can be used. Also configurable using the
    # "disable-databases" command-line switch.
    databases*: cef_state

    # Controls whether the application cache can be used. Also configurable using
    # the "disable-application-cache" command-line switch.
    application_cache*: cef_state

    # Controls whether WebGL can be used. Note that WebGL requires hardware
    # support and may not work on all systems even when enabled. Also
    # configurable using the "disable-webgl" command-line switch.
    webgl*: cef_state

    # Opaque background color used for the browser before a document is loaded
    # and when no document color is specified. By default the background color
    # will be the same as CefSettings.background_color. Only the RGB compontents
    # of the specified value will be used. The alpha component must greater than
    # 0 to enable use of the background color but will be otherwise ignored.
    background_color*: cef_color

    # Comma delimited ordered list of language codes without any whitespace that
    # will be used in the "Accept-Language" HTTP header. May be set globally
    # using the CefBrowserSettings.accept_language_list value. If both values are
    # empty then "en-US,en" will be used.
    accept_language_list*: string

proc toCef*(ns: NCRequestContextSettings): cef_request_context_settings =
  result.cache_path <= ns.cache_path
  result.persist_session_cookies = ns.persist_session_cookies.cint
  result.persist_user_preferences = ns.persist_user_preferences.cint
  result.ignore_certificate_errors = ns.ignore_certificate_errors.cint
  result.accept_language_list <= ns.accept_language_list

proc ncFree*(cs: var cef_request_context_settings) =
  cef_string_clear(cs.cache_path.addr)
  cef_string_clear(cs.accept_language_list.addr)

proc toCef*(ns: NCBrowserSettings): cef_browser_settings =
  result.size = sizeof(cef_browser_settings)
  result.windowless_frame_rate = ns.windowless_frame_rate.cint
  result.standard_font_family <= ns.standard_font_family
  result.fixed_font_family <= ns.fixed_font_family
  result.serif_font_family <= ns.serif_font_family
  result.sans_serif_font_family <= ns.sans_serif_font_family
  result.cursive_font_family <= ns.cursive_font_family
  result.fantasy_font_family <= ns.fantasy_font_family
  result.default_font_size = ns.default_font_size.cint
  result.default_fixed_font_size = ns.default_fixed_font_size.cint
  result.minimum_font_size = ns.minimum_font_size.cint
  result.minimum_logical_font_size = ns.minimum_logical_font_size.cint
  result.default_encoding <= ns.default_encoding
  result.remote_fonts = ns.remote_fonts
  result.javascript = ns.javascript
  result.javascript_open_windows = ns.javascript_open_windows
  result.javascript_close_windows = ns.javascript_close_windows
  result.javascript_access_clipboard = ns.javascript_access_clipboard
  result.javascript_dom_paste = ns.javascript_dom_paste
  result.caret_browsing = ns.caret_browsing
  result.plugins = ns.plugins
  result.universal_access_from_file_urls = ns.universal_access_from_file_urls
  result.file_access_from_file_urls = ns.file_access_from_file_urls
  result.web_security = ns.web_security
  result.image_loading = ns.image_loading
  result.image_shrink_standalone_to_fit = ns.image_shrink_standalone_to_fit
  result.text_area_resize = ns.text_area_resize
  result.tab_to_links = ns.tab_to_links
  result.local_storage = ns.local_storage
  result.databases = ns.databases
  result.application_cache = ns.application_cache
  result.webgl = ns.webgl
  result.background_color = ns.background_color
  result.accept_language_list <= ns.accept_language_list

proc toNim*(ns: ptr cef_browser_settings): NCBrowserSettings =
  result.windowless_frame_rate = ns.windowless_frame_rate.cint
  result.standard_font_family = $(ns.standard_font_family.addr)
  result.fixed_font_family = $(ns.fixed_font_family.addr)
  result.serif_font_family = $(ns.serif_font_family.addr)
  result.sans_serif_font_family = $(ns.sans_serif_font_family.addr)
  result.cursive_font_family = $(ns.cursive_font_family.addr)
  result.fantasy_font_family = $(ns.fantasy_font_family.addr)
  result.default_font_size = ns.default_font_size.int
  result.default_fixed_font_size = ns.default_fixed_font_size.int
  result.minimum_font_size = ns.minimum_font_size.int
  result.minimum_logical_font_size = ns.minimum_logical_font_size.int
  result.default_encoding = $(ns.default_encoding.addr)
  result.remote_fonts = ns.remote_fonts
  result.javascript = ns.javascript
  result.javascript_open_windows = ns.javascript_open_windows
  result.javascript_close_windows = ns.javascript_close_windows
  result.javascript_access_clipboard = ns.javascript_access_clipboard
  result.javascript_dom_paste = ns.javascript_dom_paste
  result.caret_browsing = ns.caret_browsing
  result.plugins = ns.plugins
  result.universal_access_from_file_urls = ns.universal_access_from_file_urls
  result.file_access_from_file_urls = ns.file_access_from_file_urls
  result.web_security = ns.web_security
  result.image_loading = ns.image_loading
  result.image_shrink_standalone_to_fit = ns.image_shrink_standalone_to_fit
  result.text_area_resize = ns.text_area_resize
  result.tab_to_links = ns.tab_to_links
  result.local_storage = ns.local_storage
  result.databases = ns.databases
  result.application_cache = ns.application_cache
  result.webgl = ns.webgl
  result.background_color = ns.background_color
  result.accept_language_list = $(ns.accept_language_list.addr)

proc ncFree*(cs: var cef_browser_settings) =
  cef_string_clear(cs.standard_font_family.addr)
  cef_string_clear(cs.fixed_font_family.addr)
  cef_string_clear(cs.serif_font_family.addr)
  cef_string_clear(cs.sans_serif_font_family.addr)
  cef_string_clear(cs.cursive_font_family.addr)
  cef_string_clear(cs.fantasy_font_family.addr)
  cef_string_clear(cs.default_encoding.addr)
  cef_string_clear(cs.accept_language_list.addr)

type
  # Structure representing PDF print settings.
  NCPdfPrintSettings* = object
    # Page title to display in the header. Only used if |header_footer_enabled|
    # is set to true (1).
    header_footer_title: string

    # URL to display in the footer. Only used if |header_footer_enabled| is set
    # to true (1).
    header_footer_url: string

    # Output page size in microns. If either of these values is less than or
    # equal to zero then the default paper size (A4) will be used.
    page_width: int
    page_height: int

    # Margins in millimeters. Only used if |margin_type| is set to
    # PDF_PRINT_MARGIN_CUSTOM.
    margin_top: float64
    margin_right: float64
    margin_bottom: float64
    margin_left: float64

    # Margin type.
    margin_type: cef_pdf_print_margin_type

    # Set to true (1) to print headers and footers or false (0) to not print
    # headers and footers.
    header_footer_enabled: bool

    # Set to true (1) to print the selection only or false (0) to print all.
    selection_only: bool

    # Set to true (1) for landscape mode or false (0) for portrait mode.
    landscape: bool

    # Set to true (1) to print background graphics or false (0) to not print
    # background graphics.
    backgrounds_enabled: bool

proc toCef*(ns: NCPdfPrintSettings): cef_pdf_print_settings =
  result.header_footer_title <= ns.header_footer_title
  result.header_footer_url <= ns.header_footer_url
  result.page_width = ns.page_width.cint
  result.page_height = ns.page_height.cint
  result.margin_top = ns.margin_top
  result.margin_right = ns.margin_right
  result.margin_bottom = ns.margin_bottom
  result.margin_left = ns.margin_left
  result.margin_type = ns.margin_type
  result.header_footer_enabled = ns.header_footer_enabled.cint
  result.selection_only = ns.selection_only.cint
  result.landscape = ns.landscape.cint
  result.backgrounds_enabled = ns.backgrounds_enabled.cint

proc ncFree*(cs: var cef_pdf_print_settings) =
  cef_string_clear(cs.header_footer_title.addr)
  cef_string_clear(cs.header_footer_url.addr)