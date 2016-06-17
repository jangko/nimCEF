import nc_util, nc_types, cef_types
include cef_import

# Structure used to represent a DOM document. The functions of this structure
# should only be called on the render process main thread thread.
wrapAPI(NCDomDocument, cef_domdocument)

# Structure used to represent a DOM node. The functions of this structure
# should only be called on the render process main thread.
wrapAPI(NCDomNode, cef_domnode, false)

# Structure to implement for visiting the DOM. The functions of this structure
# will be called on the render process main thread.
wrapCallback(NCDomVisitor, cef_domvisitor):
  # Method executed for visiting the DOM. The document object passed to this
  # function represents a snapshot of the DOM at the time this function is
  # executed. DOM objects are only valid for the scope of this function. Do not
  # keep references to or attempt to access any DOM objects outside the scope
  # of this function.
  proc Visit*(self: T, document: NCDomDocument)

# Returns the document type.
proc getType*(self: NCDomDocument): cef_dom_document_type =
  self.wrapCall(get_type, result)

# Returns the root document node.
proc getDocument*(self: NCDomDocument): NCDomNode =
  self.wrapCall(get_document, result)

# Returns the BODY node of an HTML document.
proc getBody*(self: NCDomDocument): NCDomNode =
  self.wrapCall(get_body, result)

# Returns the HEAD node of an HTML document.
proc getHead*(self: NCDomDocument): NCDomNode =
  self.wrapCall(get_head, result)

# Returns the title of an HTML document.
proc getTitle*(self: NCDomDocument): string =
  self.wrapCall(get_title, result)

# Returns the document element with the specified ID value.
proc getElementById*(self: NCDomDocument, id: string): NCDomNode =
  self.wrapCall(get_element_by_id, result, id)

# Returns the node that currently has keyboard focus.
proc getFocusedNode*(self: NCDomDocument): NCDomNode =
  self.wrapCall(get_focused_node, result)

# Returns true (1) if a portion of the document is selected.
proc hasSelection*(self: NCDomDocument): bool =
  self.wrapCall(has_selection, result)

# Returns the selection offset within the start node.
proc getSelectionStartOffset*(self: NCDomDocument): int =
  self.wrapCall(get_selection_start_offset, result)

# Returns the selection offset within the end node.
proc getSelectionEndOffset*(self: NCDomDocument): int =
  self.wrapCall(get_selection_end_offset, result)

# Returns the contents of this selection as markup.
proc getSelectionAsMarkup*(self: NCDomDocument): string =
  self.wrapCall(get_selection_as_markup, result)

# Returns the contents of this selection as text.
proc getSelectionAsText*(self: NCDomDocument): string =
  self.wrapCall(get_selection_as_text, result)

# Returns the base URL for the document.
proc getBaseUrl*(self: NCDomDocument): string =
  self.wrapCall(get_base_url, result)

# Returns a complete URL based on the document base URL and the specified
# partial URL.
proc getCompleteUrl*(self: NCDomDocument, partialURL: string): string =
  self.wrapCall(get_complete_url, result, partialURL)

# Returns the type for this node.
proc getType*(self: NCDomNode): cef_dom_node_type =
  self.wrapCall(get_type, result)

# Returns true (1) if this is a text node.
proc isText*(self: NCDomNode): bool =
  self.wrapCall(is_text, result)

# Returns true (1) if this is an element node.
proc isElement*(self: NCDomNode): bool =
  self.wrapCall(is_element, result)

# Returns true (1) if this is an editable node.
proc isEditable*(self: NCDomNode): bool =
  self.wrapCall(is_editable, result)

# Returns true (1) if this is a form control element node.
proc isFormControlElement*(self: NCDomNode): bool =
  self.wrapCall(is_form_control_element, result)

# Returns the type of this form control element node.
proc getFormControlElementType*(self: NCDomNode): string =
  self.wrapCall(get_form_control_element_type, result)

# Returns true (1) if this object is pointing to the same handle as |that|
# object.
proc isSame*(self, that: NCDomNode): bool =
  self.wrapCall(is_same, result, that)

# Returns the name of this node.
proc getName*(self: NCDomNode): string =
  self.wrapCall(get_name, result)

# Returns the value of this node.
proc getValue*(self: NCDomNode): string =
  self.wrapCall(get_value, result)

# Set the value of this node. Returns true (1) on success.
proc setValue*(self: NCDomNode, value: string): bool =
  self.wrapCall(set_value, result, value)

# Returns the contents of this node as markup.
proc getAsMarkup*(self: NCDomNode): string =
  self.wrapCall(get_as_markup, result)

# Returns the document associated with this node.
proc getDocument*(self: NCDomNode): NCDomDocument =
  self.wrapCall(get_document, result)

# Returns the parent node.
proc getParent*(self: NCDomNode): NCDomNode =
  self.wrapCall(get_parent, result)

# Returns the previous sibling node.
proc getPreviousSibling*(self: NCDomNode): NCDomNode =
  self.wrapCall(get_previous_sibling, result)

# Returns the next sibling node.
proc getNextSibling*(self: NCDomNode): NCDomNode =
  self.wrapCall(get_next_sibling, result)

# Returns true (1) if this node has child nodes.
proc hasChildren*(self: NCDomNode): bool =
  self.wrapCall(has_children, result)

# Return the first child node.
proc getFirstChild*(self: NCDomNode): NCDomNode =
  self.wrapCall(get_first_child, result)

# Returns the last child node.
proc getLastChild*(self: NCDomNode): NCDomNode =
  self.wrapCall(get_last_child, result)

# The following functions are valid only for element nodes.
# Returns the tag name of this element.
proc getElementTagName*(self: NCDomNode): string =
  self.wrapCall(get_element_tag_name, result)

# Returns true (1) if this element has attributes.
proc hasElementAttributes*(self: NCDomNode): bool =
  self.wrapCall(has_element_attributes, result)

# Returns true (1) if this element has an attribute named |attrName|.
proc hasElementAttribute*(self: NCDomNode, attrName: string): bool =
  self.wrapCall(has_element_attribute, result, attrName)

# Returns the element attribute named |attrName|.
proc getElementAttribute*(self: NCDomNode, attrName: string): string =
  self.wrapCall(get_element_attribute, result, attrName)

# Returns a map of all element attributes.
proc getElementAttributes*(self: NCDomNode): StringTableRef =
  self.wrapCall(get_element_attributes, result)

# Set the value for the element attribute named |attrName|. Returns true (1)
# on success.
proc setElementAttribute*(self: NCDomNode, attrName, value: string): bool =
  self.wrapCall(set_element_attribute, result, attrName, value)

# Returns the inner text of the element.
proc getElementInnerText*(self: NCDomNode): string =
  self.wrapCall(get_element_inner_text, result)