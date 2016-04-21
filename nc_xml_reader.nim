import nc_util, cef/cef_xml_reader_api, cef/cef_types, cef/cef_stream_api
import nc_stream, cef/cef_base_api

type
  # Structure that supports the reading of XML data via the libxml streaming API.
  # The functions of this structure should only be called on the thread that
  # creates the object.
  NCXmlReader* = ptr cef_xml_reader

# Moves the cursor to the next node in the document. This function must be
# called at least once to set the current cursor position. Returns true (1)
# if the cursor position was set successfully.
proc MoveToNextNode*(self: NCXmlReader): bool =
  result = self.move_to_next_node(self) == 1.cint

# Close the document. This should be called directly to ensure that cleanup
# occurs on the correct thread.
proc Close*(self: NCXmlReader): int =
  result = self.close(self).int

# Returns true (1) if an error has been reported by the XML parser.
proc HasError*(self: NCXmlReader): bool =
  result = self.has_error(self) == 1.cint

# Returns the error string.
# The resulting string must be freed by calling string_free().
proc GetError*(self: NCXmlReader): string =
  result = to_nim_string(self.get_error(self))

# The below functions retrieve data for the node at the current cursor
# position.

# Returns the node type.
proc GetType*(self: NCXmlReader): cef_xml_node_type =
  result = self.get_type(self)

# Returns the node depth. Depth starts at 0 for the root node.
proc GetDepth*(self: NCXmlReader): int =
  result = self.get_depth(self).int

# Returns the local name. See http:#www.w3.org/TR/REC-xml-names/#NT-
# LocalPart for additional details.
# The resulting string must be freed by calling string_free().
proc GetLocalName*(self: NCXmlReader): string =
  result = to_nim_string(self.get_local_name(self))

# Returns the namespace prefix. See http:#www.w3.org/TR/REC-xml-names/ for
# additional details.
# The resulting string must be freed by calling string_free().
proc GetPrefix*(self: NCXmlReader): string =
  result = to_nim_string(self.get_prefix(self))

# Returns the qualified name, equal to (Prefix:)LocalName. See
# http:#www.w3.org/TR/REC-xml-names/#ns-qualnames for additional details.
# The resulting string must be freed by calling string_free().
proc GetQualifiedName*(self: NCXmlReader): string =
  result = to_nim_string(self.get_qualified_name(self))

# Returns the URI defining the namespace associated with the node. See
# http:#www.w3.org/TR/REC-xml-names/ for additional details.
# The resulting string must be freed by calling string_free().
proc GetNamespaceUri*(self: NCXmlReader): string =
  result = to_nim_string(self.get_namespace_uri(self))

# Returns the base URI of the node. See http:#www.w3.org/TR/xmlbase/ for
# additional details.
# The resulting string must be freed by calling string_free().
proc GetBaseUri*(self: NCXmlReader): string =
  result = to_nim_string(self.get_base_uri(self))

# Returns the xml:lang scope within which the node resides. See
# http:#www.w3.org/TR/REC-xml/#sec-lang-tag for additional details.
# The resulting string must be freed by calling string_free().
proc GetXmlLang*(self: NCXmlReader): string =
  result = to_nim_string(self.get_xml_lang(self))

# Returns true (1) if the node represents an NULL element. <a/> is considered
# NULL but <a></a> is not.
proc IsEmptyElement*(self: NCXmlReader): bool =
  result = self.is_empty_element(self) == 1.cint

# Returns true (1) if the node has a text value.
proc HasValue*(self: NCXmlReader): bool =
  result = self.has_value(self) == 1.cint

# Returns the text value.
# The resulting string must be freed by calling string_free().
proc GetValue*(self: NCXmlReader): string =
  result = to_nim_string(self.get_value(self))

# Returns true (1) if the node has attributes.
proc HasAttributes*(self: NCXmlReader): bool =
  result = self.has_attributes(self) == 1.cint

# Returns the number of attributes.
proc GetAttributeCount*(self: NCXmlReader): int =
  result = self.get_attribute_count(self).int

# Returns the value of the attribute at the specified 0-based index.
# The resulting string must be freed by calling string_free().
proc GetAttributeByIndex*(self: NCXmlReader, index: int): string =
  result = to_nim_string(self.get_attribute_byindex(self, index.cint))

# Returns the value of the attribute with the specified qualified name.
# The resulting string must be freed by calling string_free().
proc GetAttributeByQname*(self: NCXmlReader, qualifiedName: string): string =
  let qname = to_cef_string(qualifiedName)
  result = to_nim_string(self.get_attribute_byqname(self, qname))
  cef_string_userfree_free(qname)

# Returns the value of the attribute with the specified local name and
# namespace URI.
# The resulting string must be freed by calling string_free().
proc GetAttributeByLname*(self: NCXmlReader, localName, namespaceURI: string): string =
  let clname = to_cef_string(localName)
  let cnsuri = to_cef_string(namespaceURI)
  result = to_nim_string(self.get_attribute_bylname(self, clname, cnsuri))
  cef_string_userfree_free(clname)
  cef_string_userfree_free(cnsuri)

# Returns an XML representation of the current node's children.
# The resulting string must be freed by calling string_free().
proc GetInnerXml*(self: NCXmlReader): string =
  result = to_nim_string(self.get_inner_xml(self))

# Returns an XML representation of the current node including its children.
# The resulting string must be freed by calling string_free().
proc GetOuterXml*(self: NCXmlReader): string =
  result = to_nim_string(self.get_outer_xml(self))

# Returns the line number for the current node.
proc GetLineNumber*(self: NCXmlReader): int =
  result = self.get_line_number(self).int

# Attribute nodes are not traversed by default. The below functions can be
# used to move the cursor to an attribute node. move_to_carrying_element()
# can be called afterwards to return the cursor to the carrying element. The
# depth of an attribute node will be 1 + the depth of the carrying element.
# Moves the cursor to the attribute at the specified 0-based index. Returns
# true (1) if the cursor position was set successfully.
proc MoveToAttributeByIndex*(self: NCXmlReader, index: int): bool =
  result = self.move_to_attribute_byindex(self, index.cint) == 1.cint

# Moves the cursor to the attribute with the specified qualified name.
# Returns true (1) if the cursor position was set successfully.
proc MoveToAttributeByQname*(self: NCXmlReader, qualifiedName: string): bool =
  let qname = to_cef_string(qualifiedName)
  result = self.move_to_attribute_byqname(self, qname) == 1.cint
  cef_string_userfree_free(qname)

# Moves the cursor to the attribute with the specified local name and
# namespace URI. Returns true (1) if the cursor position was set
# successfully.
proc MoveToAttributeByLname*(self: NCXmlReader, localName, namespaceURI: string): bool =
  let clname = to_cef_string(localName)
  let cnsuri = to_cef_string(namespaceURI)
  result = self.move_to_attribute_bylname(self, clname, cnsuri) == 1.cint
  cef_string_userfree_free(clname)
  cef_string_userfree_free(cnsuri)

# Moves the cursor to the first attribute in the current element. Returns
# true (1) if the cursor position was set successfully.
proc MoveToFirstAttribute*(self: NCXmlReader): bool =
  result = self.move_to_first_attribute(self) == 1.cint

# Moves the cursor to the next attribute in the current element. Returns true
# (1) if the cursor position was set successfully.
proc MoveToNextAttribute*(self: NCXmlReader): bool =
  result = self.move_to_next_attribute(self) == 1.cint

# Moves the cursor back to the carrying element. Returns true (1) if the
# cursor position was set successfully.
proc MoveToCarryingElement*(self: NCXmlReader): bool =
  result = self.move_to_carrying_element(self) == 1.cint

# Create a new cef_xml_reader_t object. The returned object's functions can
# only be called from the thread that created the object.
proc NCXmlReaderCreate*(stream: NCStreamReader, encodingType: cef_xml_encoding_type, URI: string): NCXmlReader =
  let curi = to_cef_string(URI)
  add_ref(stream)
  result = cef_xml_reader_create(stream, encodingType, curi)
  cef_string_userfree_free(curi)

iterator attrs*(self: NCXmlReader): string =
  let count = self.GetAttributeCount()
  for i in 0.. <count:
    yield self.GetAttributeByIndex(i)
