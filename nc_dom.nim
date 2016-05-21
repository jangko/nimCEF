import nc_util, nc_types, cef/cef_types
include cef/cef_import

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
proc GetType*(self: NCDomDocument): cef_dom_document_type =
  self.wrapCall(get_type, result)

# Returns the root document node.
proc GetDocument*(self: NCDomDocument): NCDomNode =
  self.wrapCall(get_document, result)

# Returns the BODY node of an HTML document.
proc GetBody*(self: NCDomDocument): NCDomNode =
  self.wrapCall(get_body, result)

# Returns the HEAD node of an HTML document.
proc GetHead*(self: NCDomDocument): NCDomNode =
  self.wrapCall(get_head, result)

# Returns the title of an HTML document.
# The resulting string must be freed by calling string_free().
proc GetTitle*(self: NCDomDocument): string =
  self.wrapCall(get_title, result)

# Returns the document element with the specified ID value.
proc GetElementById*(self: NCDomDocument, id: string): NCDomNode =
  self.wrapCall(get_element_by_id, result, id)

# Returns the node that currently has keyboard focus.
proc GetFocusedNode*(self: NCDomDocument): NCDomNode =
  self.wrapCall(get_focused_node, result)

# Returns true (1) if a portion of the document is selected.
proc HasSelection*(self: NCDomDocument): bool =
  self.wrapCall(has_selection, result)

# Returns the selection offset within the start node.
proc GetSelectionStartOffset*(self: NCDomDocument): int =
  self.wrapCall(get_selection_start_offset, result)

# Returns the selection offset within the end node.
proc GetSelectionEndOffset*(self: NCDomDocument): int =
  self.wrapCall(get_selection_end_offset, result)

# Returns the contents of this selection as markup.
# The resulting string must be freed by calling string_free().
proc GetSelectionAsMarkup*(self: NCDomDocument): string =
  self.wrapCall(get_selection_as_markup, result)

# Returns the contents of this selection as text.
# The resulting string must be freed by calling string_free().
proc GetSelectionAsText*(self: NCDomDocument): string =
  self.wrapCall(get_selection_as_text, result)

# Returns the base URL for the document.
# The resulting string must be freed by calling string_free().
proc GetBaseUrl*(self: NCDomDocument): string =
  self.wrapCall(get_base_url, result)

# Returns a complete URL based on the document base URL and the specified
# partial URL.
# The resulting string must be freed by calling string_free().
proc GetCompleteUrl*(self: NCDomDocument, partialURL: string): string =
  self.wrapCall(get_complete_url, result, partialURL)

# Returns the type for this node.
proc GetType*(self: NCDomNode): cef_dom_node_type =
  self.wrapCall(get_type, result)

# Returns true (1) if this is a text node.
proc IsText*(self: NCDomNode): bool =
  self.wrapCall(is_text, result)

# Returns true (1) if this is an element node.
proc IsElement*(self: NCDomNode): bool =
  self.wrapCall(is_element, result)

# Returns true (1) if this is an editable node.
proc IsEditable*(self: NCDomNode): bool =
  self.wrapCall(is_editable, result)

# Returns true (1) if this is a form control element node.
proc IsFormControlElement*(self: NCDomNode): bool =
  self.wrapCall(is_form_control_element, result)

# Returns the type of this form control element node.
# The resulting string must be freed by calling string_free().
proc GetFormControlElementType*(self: NCDomNode): string =
  self.wrapCall(get_form_control_element_type, result)

# Returns true (1) if this object is pointing to the same handle as |that|
# object.
proc IsSame*(self, that: NCDomNode): bool =
  self.wrapCall(is_same, result, that)

# Returns the name of this node.
# The resulting string must be freed by calling string_free().
proc GetName*(self: NCDomNode): string =
  self.wrapCall(get_name, result)

# Returns the value of this node.
# The resulting string must be freed by calling string_free().
proc GetValue*(self: NCDomNode): string =
  self.wrapCall(get_value, result)

# Set the value of this node. Returns true (1) on success.
proc SetValue*(self: NCDomNode, value: string): bool =
  self.wrapCall(set_value, result, value)

# Returns the contents of this node as markup.
# The resulting string must be freed by calling string_free().
proc GetAsMarkup*(self: NCDomNode): string =
  self.wrapCall(get_as_markup, result)

# Returns the document associated with this node.
proc GetDocument*(self: NCDomNode): NCDomDocument =
  self.wrapCall(get_document, result)

# Returns the parent node.
proc GetParent*(self: NCDomNode): NCDomNode =
  self.wrapCall(get_parent, result)

# Returns the previous sibling node.
proc GetPreviousSibling*(self: NCDomNode): NCDomNode =
  self.wrapCall(get_previous_sibling, result)

# Returns the next sibling node.
proc GetNextSibling*(self: NCDomNode): NCDomNode =
  self.wrapCall(get_next_sibling, result)

# Returns true (1) if this node has child nodes.
proc HasChildren*(self: NCDomNode): bool =
  self.wrapCall(has_children, result)

# Return the first child node.
proc GetFirstChild*(self: NCDomNode): NCDomNode =
  self.wrapCall(get_first_child, result)

# Returns the last child node.
proc GetLastChild*(self: NCDomNode): NCDomNode =
  self.wrapCall(get_last_child, result)

# The following functions are valid only for element nodes.
# Returns the tag name of this element.
# The resulting string must be freed by calling string_free().
proc GetElementTagName*(self: NCDomNode): string =
  self.wrapCall(get_element_tag_name, result)

# Returns true (1) if this element has attributes.
proc HasElementAttributes*(self: NCDomNode): bool =
  self.wrapCall(has_element_attributes, result)

# Returns true (1) if this element has an attribute named |attrName|.
proc HasElementAttribute*(self: NCDomNode, attrName: string): bool =
  self.wrapCall(has_element_attribute, result, attrName)

# Returns the element attribute named |attrName|.
# The resulting string must be freed by calling string_free().
proc GetElementAttribute*(self: NCDomNode, attrName: string): string =
  self.wrapCall(get_element_attribute, result, attrName)

# Returns a map of all element attributes.
proc GetElementAttributes*(self: NCDomNode): StringTableRef =
  self.wrapCall(get_element_attributes, result)

# Set the value for the element attribute named |attrName|. Returns true (1)
# on success.
proc SetElementAttribute*(self: NCDomNode, attrName, value: string): bool =
  self.wrapCall(set_element_attribute, result, attrName, value)

# Returns the inner text of the element.
# The resulting string must be freed by calling string_free().
proc GetElementInnerText*(self: NCDomNode): string =
  self.wrapCall(get_element_inner_text, result)