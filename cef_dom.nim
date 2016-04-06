import cef_base
include cef_import

type
  # Structure to implement for visiting the DOM. The functions of this structure
  # will be called on the render process main thread.
  cef_domvisitor* = object
    # Base structure.
    base*: cef_base

    # Method executed for visiting the DOM. The document object passed to this
    # function represents a snapshot of the DOM at the time this function is
    # executed. DOM objects are only valid for the scope of this function. Do not
    # keep references to or attempt to access any DOM objects outside the scope
    # of this function.
    
    visit*: proc(self: ptr cef_domvisitor,
      document: ptr cef_domdocument) {.cef_callback.}

  # Structure used to represent a DOM document. The functions of this structure
  # should only be called on the render process main thread thread.
  cef_domdocument* = object
    # Base structure.
    base*: cef_base

    # Returns the document type.
    get_type*: proc(self: ptr cef_domdocument): cef_dom_document_type {.cef_callback.}

    # Returns the root document node.
    get_document*: proc(self: ptr cef_domdocument): ptr cef_domnode {.cef_callback.}

    # Returns the BODY node of an HTML document.
    get_body*: proc(self: ptr cef_domdocument): ptr cef_domnode {.cef_callback.}

    # Returns the HEAD node of an HTML document.
    get_head*: proc(self: ptr cef_domdocument): ptr cef_domnode {.cef_callback.}
  
    # Returns the title of an HTML document.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_title*: proc(self: ptr cef_domdocument): cef_string_userfree {.cef_callback.}

    # Returns the document element with the specified ID value.
    get_element_by_id*: proc(self: ptr cef_domdocument, id: ptr cef_string): ptr cef_domnode {.cef_callback.}

    # Returns the node that currently has keyboard focus.
    get_focused_node*: proc(self: ptr cef_domdocument): ptr cef_domnode {.cef_callback.}

    # Returns true (1) if a portion of the document is selected.
    has_selection*: proc(self: ptr cef_domdocument): int {.cef_callback.}

    # Returns the selection offset within the start node.
    get_selection_start_offset*: proc(self: ptr cef_domdocument): int {.cef_callback.}
  
    # Returns the selection offset within the end node.
    get_selection_end_offset*: proc(self: ptr cef_domdocument): int {.cef_callback.}

    # Returns the contents of this selection as markup.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_selection_as_markup*: proc(self: ptr cef_domdocument): cef_string_userfree {.cef_callback.}
  
    # Returns the contents of this selection as text.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_selection_as_text*: proc(self: ptr cef_domdocument): cef_string_userfree {.cef_callback.}

    # Returns the base URL for the document.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_base_url*: proc(self: ptr cef_domdocument): cef_string_userfree {.cef_callback.}

    # Returns a complete URL based on the document base URL and the specified
    # partial URL.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_complete_url*: proc(self: ptr cef_domdocument, partialURL: ptr cef_string): cef_string_userfree {.cef_callback.}

  # Structure used to represent a DOM node. The functions of this structure
  # should only be called on the render process main thread.
  cef_domnode* = object
    # Base structure.
    base*: cef_base
  
    # Returns the type for this node.
    get_type*: proc(self: ptr cef_domnode): cef_dom_node_type {.cef_callback.}

    # Returns true (1) if this is a text node.
    is_text*: proc(self: ptr cef_domnode): int {.cef_callback.}

    # Returns true (1) if this is an element node.
    is_element*: proc(self: ptr cef_domnode): int {.cef_callback.}
  
    # Returns true (1) if this is an editable node.
    is_editable*: proc(self: ptr cef_domnode): int {.cef_callback.}

    # Returns true (1) if this is a form control element node.
    is_form_control_element*: proc(self: ptr cef_domnode): int {.cef_callback.}

    # Returns the type of this form control element node.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_form_control_element_type*: proc(self: ptr cef_domnode): cef_string_userfree {.cef_callback.}

    # Returns true (1) if this object is pointing to the same handle as |that|
    # object.
    is_same*: proc(self, that: ptr cef_domnode): int {.cef_callback.}

    # Returns the name of this node.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_name*: proc(self: ptr cef_domnode): cef_string_userfree {.cef_callback.}

    # Returns the value of this node.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_value*: proc(self: ptr cef_domnode): cef_string_userfree {.cef_callback.}

    # Set the value of this node. Returns true (1) on success.
    set_value*: proc(self: ptr cef_domnode, value: ptr cef_string): int {.cef_callback.}

    # Returns the contents of this node as markup.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_as_markup*: proc(self: ptr cef_domnode): cef_string_userfree {.cef_callback.}

    # Returns the document associated with this node.
    get_document*: proc(self: ptr cef_domnode): ptr cef_domdocument {.cef_callback.}

    # Returns the parent node.
    get_parent*: proc(self: ptr cef_domnode): ptr cef_domnode {.cef_callback.}

    # Returns the previous sibling node.
    get_previous_sibling*: proc(self: ptr cef_domnode): ptr cef_domnode {.cef_callback.}

    # Returns the next sibling node.
    get_next_sibling*: proc(self: ptr cef_domnode): ptr cef_domnode {.cef_callback.}

    # Returns true (1) if this node has child nodes.
    has_children*: proc(self: ptr cef_domnode): int {.cef_callback.}
  
    # Return the first child node.
    get_first_child*: proc(self: ptr cef_domnode): ptr cef_domnode {.cef_callback.}

    # Returns the last child node.
    get_last_child*: proc(self: ptr cef_domnode): ptr cef_domnode {.cef_callback.}

    # The following functions are valid only for element nodes.
    # Returns the tag name of this element.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_element_tag_name*: proc(self: ptr cef_domnode): cef_string_userfree {.cef_callback.}

    # Returns true (1) if this element has attributes.
    has_element_attributes*: proc(self: ptr cef_domnode): int {.cef_callback.}

    # Returns true (1) if this element has an attribute named |attrName|.
    has_element_attribute*: proc(self: ptr cef_domnode, attrName: ptr cef_string): int {.cef_callback.}
  
    # Returns the element attribute named |attrName|.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_element_attribute*: proc(self: ptr cef_domnode, attrName: ptr cef_string): cef_string_userfree {.cef_callback.}

    # Returns a map of all element attributes.
    get_element_attributes*: proc(self: ptr cef_domnode, attrMap: cef_string_map) {.cef_callback.}

    # Set the value for the element attribute named |attrName|. Returns true (1)
    # on success.
    set_element_attribute*: proc(self: ptr cef_domnode, attrName, value: ptr cef_string): int {.cef_callback.}

    # Returns the inner text of the element.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_element_inner_text*: proc(self: ptr cef_domnode): cef_string_userfree {.cef_callback.}