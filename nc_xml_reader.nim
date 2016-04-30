import nc_util, cef/cef_xml_reader_api, cef/cef_types, cef/cef_stream_api
import nc_stream, cef/cef_base_api

type
  # Structure that supports the reading of XML data via the libxml streaming API.
  # The functions of this structure should only be called on the thread that
  # creates the object.
  NCXmlReader* = ref object
    handler: ptr cef_xml_reader

import impl/nc_util_impl

proc GetHandler*(self: NCXmlReader): ptr cef_xml_reader {.inline.} =
  result = self.handler

proc nc_wrap*(handler: ptr cef_xml_reader): NCXmlReader =
  new(result, nc_finalizer[NCXmlReader])
  result.handler = handler
  add_ref(handler)

# Moves the cursor to the next node in the document. This function must be
# called at least once to set the current cursor position. Returns true (1)
# if the cursor position was set successfully.
proc MoveToNextNode*(self: NCXmlReader): bool =
  result = self.handler.move_to_next_node(self.handler) == 1.cint

# Close the document. This should be called directly to ensure that cleanup
# occurs on the correct thread.
proc Close*(self: NCXmlReader): int =
  result = self.handler.close(self.handler).int

# Returns true (1) if an error has been reported by the XML parser.
proc HasError*(self: NCXmlReader): bool =
  result = self.handler.has_error(self.handler) == 1.cint

# Returns the error string.
# The resulting string must be freed by calling string_free().
proc GetError*(self: NCXmlReader): string =
  result = to_nim(self.handler.get_error(self.handler))

# The below functions retrieve data for the node at the current cursor
# position.

# Returns the node type.
proc GetType*(self: NCXmlReader): cef_xml_node_type =
  result = self.handler.get_type(self.handler)

# Returns the node depth. Depth starts at 0 for the root node.
proc GetDepth*(self: NCXmlReader): int =
  result = self.handler.get_depth(self.handler).int

# Returns the local name. See http:#www.w3.org/TR/REC-xml-names/#NT-
# LocalPart for additional details.
# The resulting string must be freed by calling string_free().
proc GetLocalName*(self: NCXmlReader): string =
  result = to_nim(self.handler.get_local_name(self.handler))

# Returns the namespace prefix. See http:#www.w3.org/TR/REC-xml-names/ for
# additional details.
# The resulting string must be freed by calling string_free().
proc GetPrefix*(self: NCXmlReader): string =
  result = to_nim(self.handler.get_prefix(self.handler))

# Returns the qualified name, equal to (Prefix:)LocalName. See
# http:#www.w3.org/TR/REC-xml-names/#ns-qualnames for additional details.
# The resulting string must be freed by calling string_free().
proc GetQualifiedName*(self: NCXmlReader): string =
  result = to_nim(self.handler.get_qualified_name(self.handler))

# Returns the URI defining the namespace associated with the node. See
# http:#www.w3.org/TR/REC-xml-names/ for additional details.
# The resulting string must be freed by calling string_free().
proc GetNamespaceUri*(self: NCXmlReader): string =
  result = to_nim(self.handler.get_namespace_uri(self.handler))

# Returns the base URI of the node. See http:#www.w3.org/TR/xmlbase/ for
# additional details.
# The resulting string must be freed by calling string_free().
proc GetBaseUri*(self: NCXmlReader): string =
  result = to_nim(self.handler.get_base_uri(self.handler))

# Returns the xml:lang scope within which the node resides. See
# http:#www.w3.org/TR/REC-xml/#sec-lang-tag for additional details.
# The resulting string must be freed by calling string_free().
proc GetXmlLang*(self: NCXmlReader): string =
  result = to_nim(self.handler.get_xml_lang(self.handler))

# Returns true (1) if the node represents an NULL element. <a/> is considered
# NULL but <a></a> is not.
proc IsEmptyElement*(self: NCXmlReader): bool =
  result = self.handler.is_empty_element(self.handler) == 1.cint

# Returns true (1) if the node has a text value.
proc HasValue*(self: NCXmlReader): bool =
  result = self.handler.has_value(self.handler) == 1.cint

# Returns the text value.
# The resulting string must be freed by calling string_free().
proc GetValue*(self: NCXmlReader): string =
  result = to_nim(self.handler.get_value(self.handler))

# Returns true (1) if the node has attributes.
proc HasAttributes*(self: NCXmlReader): bool =
  result = self.handler.has_attributes(self.handler) == 1.cint

# Returns the number of attributes.
proc GetAttributeCount*(self: NCXmlReader): int =
  result = self.handler.get_attribute_count(self.handler).int

# Returns the value of the attribute at the specified 0-based index.
# The resulting string must be freed by calling string_free().
proc GetAttributeByIndex*(self: NCXmlReader, index: int): string =
  result = to_nim(self.handler.get_attribute_byindex(self.handler, index.cint))

# Returns the value of the attribute with the specified qualified name.
# The resulting string must be freed by calling string_free().
proc GetAttributeByQname*(self: NCXmlReader, qualifiedName: string): string =
  let qname = to_cef(qualifiedName)
  result = to_nim(self.handler.get_attribute_byqname(self.handler, qname))
  nc_free(qname)

# Returns the value of the attribute with the specified local name and
# namespace URI.
# The resulting string must be freed by calling string_free().
proc GetAttributeByLname*(self: NCXmlReader, localName, namespaceURI: string): string =
  let clname = to_cef(localName)
  let cnsuri = to_cef(namespaceURI)
  result = to_nim(self.handler.get_attribute_bylname(self.handler, clname, cnsuri))
  nc_free(clname)
  nc_free(cnsuri)

# Returns an XML representation of the current node's children.
# The resulting string must be freed by calling string_free().
proc GetInnerXml*(self: NCXmlReader): string =
  result = to_nim(self.handler.get_inner_xml(self.handler))

# Returns an XML representation of the current node including its children.
# The resulting string must be freed by calling string_free().
proc GetOuterXml*(self: NCXmlReader): string =
  result = to_nim(self.handler.get_outer_xml(self.handler))

# Returns the line number for the current node.
proc GetLineNumber*(self: NCXmlReader): int =
  result = self.handler.get_line_number(self.handler).int

# Attribute nodes are not traversed by default. The below functions can be
# used to move the cursor to an attribute node. move_to_carrying_element()
# can be called afterwards to return the cursor to the carrying element. The
# depth of an attribute node will be 1 + the depth of the carrying element.
# Moves the cursor to the attribute at the specified 0-based index. Returns
# true (1) if the cursor position was set successfully.
proc MoveToAttributeByIndex*(self: NCXmlReader, index: int): bool =
  result = self.handler.move_to_attribute_byindex(self.handler, index.cint) == 1.cint

# Moves the cursor to the attribute with the specified qualified name.
# Returns true (1) if the cursor position was set successfully.
proc MoveToAttributeByQname*(self: NCXmlReader, qualifiedName: string): bool =
  let qname = to_cef(qualifiedName)
  result = self.handler.move_to_attribute_byqname(self.handler, qname) == 1.cint
  nc_free(qname)

# Moves the cursor to the attribute with the specified local name and
# namespace URI. Returns true (1) if the cursor position was set
# successfully.
proc MoveToAttributeByLname*(self: NCXmlReader, localName, namespaceURI: string): bool =
  let clname = to_cef(localName)
  let cnsuri = to_cef(namespaceURI)
  result = self.handler.move_to_attribute_bylname(self.handler, clname, cnsuri) == 1.cint
  nc_free(clname)
  nc_free(cnsuri)

# Moves the cursor to the first attribute in the current element. Returns
# true (1) if the cursor position was set successfully.
proc MoveToFirstAttribute*(self: NCXmlReader): bool =
  result = self.handler.move_to_first_attribute(self.handler) == 1.cint

# Moves the cursor to the next attribute in the current element. Returns true
# (1) if the cursor position was set successfully.
proc MoveToNextAttribute*(self: NCXmlReader): bool =
  result = self.handler.move_to_next_attribute(self.handler) == 1.cint

# Moves the cursor back to the carrying element. Returns true (1) if the
# cursor position was set successfully.
proc MoveToCarryingElement*(self: NCXmlReader): bool =
  result = self.handler.move_to_carrying_element(self.handler) == 1.cint

# Create a new cef_xml_reader_t object. The returned object's functions can
# only be called from the thread that created the object.
proc NCXmlReaderCreate*(stream: NCStreamReader, encodingType: cef_xml_encoding_type, URI: string): NCXmlReader =
  let curi = to_cef(URI)
  add_ref(stream)
  result = nc_wrap(cef_xml_reader_create(stream, encodingType, curi))
  nc_free(curi)
