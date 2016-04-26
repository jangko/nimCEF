import cef/cef_dom_api, nc_util, nc_types, cef/cef_types
include cef/cef_import

type
  # Structure to implement for visiting the DOM. The functions of this structure
  # will be called on the render process main thread.
  NCDomVisitor* = ref object of RootObj
    handler*: cef_domvisitor

  # Structure used to represent a DOM document. The functions of this structure
  # should only be called on the render process main thread thread.
  NCDomDocument* = ptr cef_domdocument

  # Structure used to represent a DOM node. The functions of this structure
  # should only be called on the render process main thread.
  NCDomNode* = ptr cef_domnode


# Method executed for visiting the DOM. The document object passed to this
# function represents a snapshot of the DOM at the time this function is
# executed. DOM objects are only valid for the scope of this function. Do not
# keep references to or attempt to access any DOM objects outside the scope
# of this function.
method DomVisit*(self: NCDomVisitor, document: NCDomDocument) {.base.} =
  discard

proc GetHandler*(self: NCDomVisitor): ptr cef_dom_visitor {.inline.} =
  result = self.handler.addr
  
proc visit_document(self: ptr cef_domvisitor, document: ptr cef_domdocument) {.cef_callback.} =
  var handler = type_to_type(NCDomVisitor, self)
  handler.DomVisit(document)
  release(document)
        
proc init_dom_visitor(handler: ptr cef_dom_visitor) =
  init_base(handler)
  handler.visit = visit_document
  
proc makeNCDomVisitor*(T: typedesc): auto =
  result = new(T)
  init_dom_visitor(result.GetHandler())

# Returns the document type.
proc GetType*(self: NCDomDocument): cef_dom_document_type =
  result = self.get_type(self)

# Returns the root document node.
proc GetDocument*(self: NCDomDocument): NCDomNode =
  result = self.get_document(self)

# Returns the BODY node of an HTML document.
proc GetBody*(self: NCDomDocument): NCDomNode =
  result = self.get_body(self)

# Returns the HEAD node of an HTML document.
proc GetHead*(self: NCDomDocument): NCDomNode =
  result = self.get_head(self)

# Returns the title of an HTML document.
# The resulting string must be freed by calling string_free().
proc GetTitle*(self: NCDomDocument): string =
  result = to_nim(self.get_title(self))

# Returns the document element with the specified ID value.
proc GetElementById*(self: NCDomDocument, id: string): NCDomNode =
  let cid = to_cef(id)
  result = self.get_element_by_id(self, cid)
  nc_free(cid)

# Returns the node that currently has keyboard focus.
proc GetFocusedNode*(self: NCDomDocument): NCDomNode =
  result = self.get_focused_node(self)

# Returns true (1) if a portion of the document is selected.
proc HasSelection*(self: NCDomDocument): bool =
  result = self.has_selection(self) == 1.cint

# Returns the selection offset within the start node.
proc GetSelectionStartOffset*(self: NCDomDocument): int =
  result = self.get_selection_start_offset(self).int

# Returns the selection offset within the end node.
proc GetSelectionEndOffset*(self: NCDomDocument): int =
  result = self.get_selection_end_offset(self).int

# Returns the contents of this selection as markup.
# The resulting string must be freed by calling string_free().
proc GetSelectionAsMarkup*(self: NCDomDocument): string =
  result = to_nim(self.get_selection_as_markup(self))

# Returns the contents of this selection as text.
# The resulting string must be freed by calling string_free().
proc GetSelectionAsText*(self: NCDomDocument): string =
  result = to_nim(self.get_selection_as_text(self))

# Returns the base URL for the document.
# The resulting string must be freed by calling string_free().
proc GetBaseUrl*(self: NCDomDocument): string =
  result = to_nim(self.get_base_url(self))

# Returns a complete URL based on the document base URL and the specified
# partial URL.
# The resulting string must be freed by calling string_free().
proc GetCompleteUrl*(self: NCDomDocument, partialURL: string): string =
  let curl = to_cef(partialURL)
  result = to_nim(self.get_complete_url(self, curl))
  nc_free(curl)

# Returns the type for this node.
proc GetType*(self: NCDomNode): cef_dom_node_type =
  result = self.get_type(self)

# Returns true (1) if this is a text node.
proc IsText*(self: NCDomNode): bool =
  result = self.is_text(self) == 1.cint

# Returns true (1) if this is an element node.
proc IsElement*(self: NCDomNode): bool =
  result = self.is_element(self) == 1.cint

# Returns true (1) if this is an editable node.
proc IsEditable*(self: NCDomNode): bool =
  result = self.is_editable(self) == 1.cint

# Returns true (1) if this is a form control element node.
proc IsFormControlElement*(self: NCDomNode): bool =
  result = self.is_form_control_element(self) == 1.cint

# Returns the type of this form control element node.
# The resulting string must be freed by calling string_free().
proc GetFormControlElementType*(self: NCDomNode): string =
  result = to_nim(self.get_form_control_element_type(self))

# Returns true (1) if this object is pointing to the same handle as |that|
# object.
proc IsSame*(self, that: NCDomNode): bool =
  result = self.is_same(self, that) == 1.cint

# Returns the name of this node.
# The resulting string must be freed by calling string_free().
proc GetName*(self: NCDomNode): string =
  result = to_nim(self.get_name(self))

# Returns the value of this node.
# The resulting string must be freed by calling string_free().
proc GetValue*(self: NCDomNode): string =
  result = to_nim(self.get_value(self))

# Set the value of this node. Returns true (1) on success.
proc SetValue*(self: NCDomNode, value: string): bool =
  let cval = to_cef(value)
  result = self.set_value(self, cval) == 1.cint
  nc_free(cval)

# Returns the contents of this node as markup.
# The resulting string must be freed by calling string_free().
proc GetAsMarkup*(self: NCDomNode): string =
  result = to_nim(self.get_as_markup(self))

# Returns the document associated with this node.
proc GetDocument*(self: NCDomNode): NCDomDocument =
  result = self.get_document(self)

# Returns the parent node.
proc GetParent*(self: NCDomNode): NCDomNode =
  result = self.get_parent(self)

# Returns the previous sibling node.
proc GetPreviousSibling*(self: NCDomNode): NCDomNode =
  result = self.get_previous_sibling(self)

# Returns the next sibling node.
proc GetNextSibling*(self: NCDomNode): NCDomNode =
  result = self.get_next_sibling(self)

# Returns true (1) if this node has child nodes.
proc HasChildren*(self: NCDomNode): bool =
  result = self.has_children(self) == 1.cint

# Return the first child node.
proc GetFirstChild*(self: NCDomNode): NCDomNode =
  result = self.get_first_child(self)

# Returns the last child node.
proc GetLastChild*(self: NCDomNode): NCDomNode =
  result = self.get_last_child(self)

# The following functions are valid only for element nodes.
# Returns the tag name of this element.
# The resulting string must be freed by calling string_free().
proc GetElementTagName*(self: NCDomNode): string =
  result = to_nim(self.get_element_tag_name(self))

# Returns true (1) if this element has attributes.
proc HasElementAttributes*(self: NCDomNode): bool =
  result = self.has_element_attributes(self) == 1.cint

# Returns true (1) if this element has an attribute named |attrName|.
proc HasElementAttribute*(self: NCDomNode, attrName: string): bool =
  let cname = to_cef(attrName)
  result = self.has_element_attribute(self, cname) == 1.cint
  nc_free(cname)

# Returns the element attribute named |attrName|.
# The resulting string must be freed by calling string_free().
proc GetElementAttribute*(self: NCDomNode, attrName: string): string =
  let cname = to_cef(attrName)
  result = to_nim(self.get_element_attribute(self, cname))
  nc_free(cname)

# Returns a map of all element attributes.
proc GetElementAttributes*(self: NCDomNode): StringTableRef =
  var cmap = cef_string_map_alloc()
  self.get_element_attributes(self, cmap)
  result = to_nim(cmap)

# Set the value for the element attribute named |attrName|. Returns true (1)
# on success.
proc SetElementAttribute*(self: NCDomNode, attrName, value: string): bool =
  let cname = to_cef(attrName)
  let cvalue = to_cef(value)
  result = self.set_element_attribute(self, cname, cvalue) == 1.cint
  nc_free(cname)
  nc_free(cvalue)

# Returns the inner text of the element.
# The resulting string must be freed by calling string_free().
proc GetElementInnerText*(self: NCDomNode): string =
  result = to_nim(self.get_element_inner_text(self))