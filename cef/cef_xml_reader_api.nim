import cef_base_api, cef_stream_api
include cef_import


type
  # Structure that supports the reading of XML data via the libxml streaming API.
  # The functions of this structure should only be called on the thread that
  # creates the object.
  cef_xml_reader* = object
    base*: cef_base
  
    # Moves the cursor to the next node in the document. This function must be
    # called at least once to set the current cursor position. Returns true (1)
    # if the cursor position was set successfully.
    move_to_next_node*: proc(self: ptr cef_xml_reader): cint {.cef_callback.}
  
    # Close the document. This should be called directly to ensure that cleanup
    # occurs on the correct thread.
    close*: proc(self: ptr cef_xml_reader): cint {.cef_callback.}
  
    # Returns true (1) if an error has been reported by the XML parser.
    has_error*: proc(self: ptr cef_xml_reader): cint {.cef_callback.}
  
    # Returns the error string.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_error*: proc(self: ptr cef_xml_reader): cef_string_userfree {.cef_callback.}
  
    # The below functions retrieve data for the node at the current cursor
    # position.
  
    # Returns the node type.
    get_type*: proc(self: ptr cef_xml_reader): cef_xml_node_type {.cef_callback.}
  
    # Returns the node depth. Depth starts at 0 for the root node.
    get_depth*: proc(self: ptr cef_xml_reader): cint {.cef_callback.}
  
    # Returns the local name. See http:#www.w3.org/TR/REC-xml-names/#NT-
    # LocalPart for additional details.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_local_name*: proc(self: ptr cef_xml_reader): cef_string_userfree {.cef_callback.}
  
    # Returns the namespace prefix. See http:#www.w3.org/TR/REC-xml-names/ for
    # additional details.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_prefix*: proc(self: ptr cef_xml_reader): cef_string_userfree {.cef_callback.}
  
    # Returns the qualified name, equal to (Prefix:)LocalName. See
    # http:#www.w3.org/TR/REC-xml-names/#ns-qualnames for additional details.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_qualified_name*: proc(self: ptr cef_xml_reader): cef_string_userfree {.cef_callback.}
  
    # Returns the URI defining the namespace associated with the node. See
    # http:#www.w3.org/TR/REC-xml-names/ for additional details.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_namespace_uri*: proc(self: ptr cef_xml_reader): cef_string_userfree {.cef_callback.}
  
    # Returns the base URI of the node. See http:#www.w3.org/TR/xmlbase/ for
    # additional details.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_base_uri*: proc(self: ptr cef_xml_reader): cef_string_userfree {.cef_callback.}
  
    # Returns the xml:lang scope within which the node resides. See
    # http:#www.w3.org/TR/REC-xml/#sec-lang-tag for additional details.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_xml_lang*: proc(self: ptr cef_xml_reader): cef_string_userfree {.cef_callback.}
  
    # Returns true (1) if the node represents an NULL element. <a/> is considered
    # NULL but <a></a> is not.
    is_empty_element*: proc(self: ptr cef_xml_reader): cint {.cef_callback.}
  
    # Returns true (1) if the node has a text value.
    has_value*: proc(self: ptr cef_xml_reader): cint {.cef_callback.}
  
    # Returns the text value.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_value*: proc(self: ptr cef_xml_reader): cef_string_userfree {.cef_callback.}
  
    # Returns true (1) if the node has attributes.
    has_attributes*: proc(self: ptr cef_xml_reader): cint {.cef_callback.}
  
    # Returns the number of attributes.
    get_attribute_count*: proc(self: ptr cef_xml_reader): csize {.cef_callback.}
  
    # Returns the value of the attribute at the specified 0-based index.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_attribute_byindex*: proc(self: ptr cef_xml_reader, index: cint): cef_string_userfree {.cef_callback.}
  
    # Returns the value of the attribute with the specified qualified name.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_attribute_byqname*: proc(self: ptr cef_xml_reader, qualifiedName: ptr cef_string): cef_string_userfree {.cef_callback.}
  
    # Returns the value of the attribute with the specified local name and
    # namespace URI.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_attribute_bylname*: proc(self: ptr cef_xml_reader, 
      localName, namespaceURI: ptr cef_string): cef_string_userfree {.cef_callback.}
  
    # Returns an XML representation of the current node's children.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_inner_xml*: proc(self: ptr cef_xml_reader): cef_string_userfree {.cef_callback.}
  
    # Returns an XML representation of the current node including its children.
    # The resulting string must be freed by calling cef_string_userfree_free().
    get_outer_xml*: proc(self: ptr cef_xml_reader): cef_string_userfree {.cef_callback.}
  
    # Returns the line number for the current node.
    get_line_number*: proc(self: ptr cef_xml_reader): cint {.cef_callback.}
  
    # Attribute nodes are not traversed by default. The below functions can be
    # used to move the cursor to an attribute node. move_to_carrying_element()
    # can be called afterwards to return the cursor to the carrying element. The
    # depth of an attribute node will be 1 + the depth of the carrying element.
    # Moves the cursor to the attribute at the specified 0-based index. Returns
    # true (1) if the cursor position was set successfully.
    move_to_attribute_byindex*: proc(self: ptr cef_xml_reader,
      index: cint): cint {.cef_callback.}
  
    # Moves the cursor to the attribute with the specified qualified name.
    # Returns true (1) if the cursor position was set successfully.
    move_to_attribute_byqname*: proc(self: ptr cef_xml_reader,
      qualifiedName: ptr cef_string): cint {.cef_callback.}
  
    # Moves the cursor to the attribute with the specified local name and
    # namespace URI. Returns true (1) if the cursor position was set
    # successfully.
    move_to_attribute_bylname*: proc(self: ptr cef_xml_reader,
      localName, namespaceURI: ptr cef_string): cint {.cef_callback.}
  
    # Moves the cursor to the first attribute in the current element. Returns
    # true (1) if the cursor position was set successfully.
    move_to_first_attribute*: proc(self: ptr cef_xml_reader): cint {.cef_callback.}
  
    # Moves the cursor to the next attribute in the current element. Returns true
    # (1) if the cursor position was set successfully.
    move_to_next_attribute*: proc(self: ptr cef_xml_reader): cint {.cef_callback.}
  
    # Moves the cursor back to the carrying element. Returns true (1) if the
    # cursor position was set successfully.
    move_to_carrying_element*: proc(self: ptr cef_xml_reader): cint {.cef_callback.}

# Create a new cef_xml_reader_t object. The returned object's functions can
# only be called from the thread that created the object.
proc cef_xml_reader_create*(strem: ptr cef_stream_reader, encodingType: cef_xml_encoding_type,
  URI: ptr cef_string): ptr cef_xml_reader {.cef_import.}