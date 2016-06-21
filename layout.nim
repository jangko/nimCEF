import nc_util, nc_types, nc_view, nc_settings

type
  MyWindowDelegate* = ref object of NCWindowDelegate
    buttonDelegate: MyButtonDelegate
    client: NCClient
    url: string
    addressBar: NCTextField
    
  MyButtonDelegate = ref object of NCButtonDelegate
  MyPanelDelegate = ref object of NCPanelDelegate    
  MyTextFieldDelegate = ref object of NCTextFieldDelegate
  MyBrowserViewDelegate = ref object of NCBrowserViewDelegate
    
handlerImpl(MyButtonDelegate):
  proc getPreferredSize*(self: MyButtonDelegate, view: NCView): NCSize =
    result = NCSize(width: 80, height: 10)

  proc getMinimumSize*(self: MyButtonDelegate, view: NCView): NCSize =
    result = NCSize(width:50, height:10)

  proc getMaximumSize*(self: MyButtonDelegate, view: NCView): NCSize =
    result = NCSize(width:300, height:100)
    
  proc onButtonPressed*(self: MyButtonDelegate, button: NCButton) =
    discard

handlerImpl(MyPanelDelegate):
  proc getPreferredSize*(self: MyPanelDelegate, view: NCView): NCSize =
    let parent = view.getParentView()
    if parent != nil:
      let size = parent.getSize()
      result = NCSize(width: size.width, height: 30)
    else:
      result = NCSize(width: 600, height: 30)
    
  proc getMinimumSize*(self: MyPanelDelegate, view: NCView): NCSize =
    result = NCSize(width: 50, height: 10)

  proc getMaximumSize*(self: MyPanelDelegate, view: NCView): NCSize =
    result = NCSize(width: 300, height: 100)

handlerImpl(MyTextFieldDelegate):
  proc getPreferredSize*(self: MyTextFieldDelegate, view: NCView): NCSize =
    let parent = view.getParentView()
    if parent != nil:
      let size = parent.getSize()
      let pos  = view.getPosition()
      result = NCSize(width: size.width - pos.x - 5, height: 30)
    else:
      result = NCSize(width: 1200, height: 30)
    
  proc getMinimumSize*(self: MyTextFieldDelegate, view: NCView): NCSize =
    result = NCSize(width: 50, height: 10)

  proc getMaximumSize*(self: MyTextFieldDelegate, view: NCView): NCSize =
    result = NCSize(width: 1500, height: 100)

handlerImpl(MyBrowserViewDelegate):
  proc getPreferredSize*(self: MyBrowserViewDelegate, view: NCView): NCSize =
    let parent = view.getParentView()
    if parent != nil:
      let size = parent.getSize()
      result = NCSize(width: 300, height: size.height - 30)
    else:
      result = NCSize(width: 300, height: 270)
    
  proc getMinimumSize*(self: MyBrowserViewDelegate, view: NCView): NCSize =
    result = NCSize(width: 50, height: 10)

  proc getMaximumSize*(self: MyBrowserViewDelegate, view: NCView): NCSize =
    result = NCSize(width: 300, height: 1000)
    
handlerImpl(MyWindowDelegate):
  proc onWindowCreated*(self: MyWindowDelegate, window: NCWindow) =
    #window.setSize(NCSize(width:600, height:300))
    window.maximize()
    window.setVisible(true)
    self.buttonDelegate = MyButtonDelegate.ncCreate()
    
    var panel = ncPanelCreate(MyPanelDelegate.ncCreate())
    
    var button = ncLabelButtonCreate(self.buttonDelegate, "Back", true)
    panel.addChildView(button)
    button.setVisible(true)
    
    var button2 = ncLabelButtonCreate(self.buttonDelegate, "Forward", true)
    panel.addChildView(button2)
    button2.setVisible(true)

    var button3 = ncLabelButtonCreate(self.buttonDelegate, "Reload", true)
    panel.addChildView(button3)
    button3.setVisible(true)

    var button4 = ncLabelButtonCreate(self.buttonDelegate, "Stop", true)
    panel.addChildView(button4)
    button4.setVisible(true)
    
    var text1 = ncTextFieldCreate(MyTextFieldDelegate.ncCreate())
    panel.addChildView(text1)
    text1.setVisible(true)
    
    self.addressBar = text1
    
    var s : NCBoxLayoutSettings
    s.horizontal = true

    # Adds additional horizontal space between the child view area and the host
    # view border.
    #s.inside_border_horizontal_spacing = 5

    # Adds additional vertical space between the child view area and the host
    # view border.
    s.inside_border_vertical_spacing = 5

    # Adds additional space around the child view area.
    #inside_border_insets*: NCInsets

    # Adds additional space between child views.
    #between_child_spacing*: int

    # Specifies where along the main axis the child views should be laid out.
    #main_axis_alignment*: cef_main_axis_alignment

    # Specifies where along the cross axis the child views should be laid out.
    #cross_axis_alignment*: cef_cross_axis_alignment

    # Minimum cross axis size.
    #minimum_cross_axis_size*: int

    # Default flex for views when none is specified via CefBoxLayout methods.
    # Using the preferred size as the basis, free space along the main axis is
    # distributed to views in the ratio of their flex weights. Similarly, if the
    # views will overflow the parent, space is subtracted in these ratios. A flex
    # of 0 means this view is not resized. Flex values must not be negative.
    #default_flex*: int
    
    var layout = panel.setToBoxLayout(s)
    panel.layout()
    
    var browserSettings: NCBrowserSettings
    var browserView = ncBrowserViewCreate(self.client, self.url,
      browserSettings, nil, MyBrowserViewDelegate.ncCreate())
  
    s.horizontal = false
    s.inside_border_vertical_spacing = 0
    discard window.setToBoxLayout(s)
    #discard window.setToFillLayout()
    window.addChildView(panel)
    window.addChildView(browserView)
    window.layout()

  proc onWindowDestroyed*(self: MyWindowDelegate, window: NCWindow) =
    discard

  proc isFrameless*(self: MyWindowDelegate, window: NCWindow): bool =
    result = false

  proc canResize*(self: MyWindowDelegate, window: NCWindow): bool =
    result = true

  proc canMaximize*(self: MyWindowDelegate, window: NCWindow): bool =
    result = true
  
  proc canMinimize*(self: MyWindowDelegate,  window: NCWindow): bool =
    result = true

  proc canClose*(self: MyWindowDelegate, window: NCWindow): bool =
    result = true
    
proc setupLayout*(client: NCClient, url: string): MyWindowDelegate =
  var delegate = MyWindowDelegate.ncCreate()
  delegate.client = client
  delegate.url = url
  discard ncWindowCreateTopLevel(delegate)
  result = delegate
  
proc setAddress*(self: MyWindowDelegate, url: string) =
  self.addressBar.setText(url)