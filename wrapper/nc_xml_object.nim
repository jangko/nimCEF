import nc_xml_reader, strtabs, nc_stream, cef_types, nc_util

type
  NCXmlObject* = ref object
    name: string
    parent: NCXmlObject
    value: string
    attributes: StringTableRef
    children: seq[NCXmlObject]

proc makeNCXmlObject*(name: string): NCXmlObject =
  new(result)
  result.name = name
  result.children = @[]
  result.attributes = newStringTable(modeCaseSensitive)
  result.value = ""

proc setParent*(self, parent: NCXmlObject) =
  if parent != nil:
    doAssert(self.parent == nil)
    self.parent = parent
  else:
    assert(self.parent != nil)
    self.parent = nil

proc clearChildren*(self: NCXmlObject) =
  for it in self.children:
    it.setParent(nil)
  self.children = @[]

proc clearAttributes*(self: NCXmlObject) =
  self.attributes.clear(modeCaseSensitive)

# Clears this object's children and attributes. The name and parenting of
# this object are not changed.
proc clear*(self: NCXmlObject) =
  self.clearChildren()
  self.clearAttributes()

# Access the object's name. An object name must always be at least one
# character long.
proc getName*(self: NCXmlObject): string =
  result = self.name

proc setName*(self: NCXmlObject, name: string): bool =
  if name.len == 0: return false
  self.name = name
  result = true

# Access the object's parent. The parent can be NULL if this object has not
# been added as the child on another object.
proc hasParent*(self: NCXmlObject): bool =
  result = self.parent != nil

proc getParent*(self: NCXmlObject): NCXmlObject =
  result = self.parent

# Access the object's value. An object cannot have a value if it also has
# children. Attempting to set the value while children exist will fail.
proc hasValue*(self: NCXmlObject): bool =
  result = self.value.len != 0

proc getValue*(self: NCXmlObject): string =
  result = self.value

proc setValue*(self: NCXmlObject, value: string): bool =
  assert(self.children.len == 0)
  if self.children.len != 0: return false
  self.value = value
  result = true

# Access the object's attributes. Attributes must have unique names.
proc hasAttributes*(self: NCXmlObject): bool =
  result = self.attributes.len != 0

proc getAttributeCount*(self: NCXmlObject): int =
  result = self.attributes.len

proc hasAttribute*(self: NCXmlObject, name: string): bool =
  result = self.attributes.hasKey(name)

proc getAttributeValue*(self: NCXmlObject, name: string): string =
  result = self.attributes[name]

proc setAttributeValue*(self: NCXmlObject, name, value: string): bool =
  assert(name.len != 0)
  if name.len == 0: return false
  self.attributes[name] = value
  result = true

proc getAttributes*(self: NCXmlObject): StringTableRef =
  result = self.attributes

# Access the object's children. Each object can only have one parent so
# attempting to add an object that already has a parent will fail. Removing a
# child will set the child's parent to NULL. Adding a child will set the
# child's parent to this object. This object's value, if any, will be cleared
# if a child is added.

proc hasChildren*(self: NCXmlObject): bool =
  result = self.children.len != 0

proc getChildCount*(self: NCXmlObject): int =
  result = self.children.len

proc hasChild*(self, child: NCXmlObject): bool =
  for c in self.children:
    if c == child: return true
  result = false

proc addChild*(self, child: NCXmlObject): bool =
  if child == nil: return false
  assert(child.parent == nil)
  if child.parent != nil: return false
  self.children.add(child)
  child.setParent(self)
  result = true

proc removeChild*(self, child: NCXmlObject): bool =
  for i in 0..<self.children.len:
    if self.children[i] == child:
      self.children.delete(i)
      child.setParent(nil)
      return true
  result = false

proc getChildren*(self: NCXmlObject): seq[NCXmlObject] =
  result = self.children

# Find the first child with the specified name.
proc findChild*(self: NCXmlObject, name: string): NCXmlObject =
  assert(name.len != 0)
  if name.len == 0: return nil
  for n in self.children:
    if n.name == name: return n
  result = nil

# Find all children with the specified name.
proc findChildren*(self: NCXmlObject, name: string): seq[NCXmlObject] =
  result = @[]
  assert(name.len != 0)
  if name.len != 0:
    for n in self.children:
      if n.name == name: result.add(n)

# Append a duplicate of the children and attributes of the specified object
# to this object. If |overwriteAttributes| is true then any attributes in
# this object that also exist in the specified object will be overwritten
# with the new values. The name of this object is not changed.
proc append*(self, other: NCXmlObject, overwriteAttributes: bool)

# Set the name, children and attributes of this object to a duplicate of the
# specified object's contents. The existing children and attributes, if any,
# will first be cleared.
proc set*(self, other: NCXmlObject) =
  assert(other != nil)
  self.clear()
  self.name = other.name
  self.append(other, true)

# Return a new object with the same name, children and attributes as this
# object. The parent of the new object will be NULL.
proc duplicate(self: NCXmlObject): NCXmlObject =
  result = makeNCXmlObject(self.name)
  result.append(self, true)

proc append(self, other: NCXmlObject, overwriteAttributes: bool) =
  assert(other != nil)

  if other.hasChildren():
    let children = other.getChildren()
    for it in children:
      discard self.addChild(it.duplicate())

  if other.hasAttributes():
    let attributes = other.getAttributes()
    for key, val in attributes:
      if overwriteAttributes or not self.hasAttribute(key):
        discard self.setAttributeValue(key, val)

# Load the contents of the specified XML stream into this object.
proc loadXml*(stream: NCStreamReader, encodingType: cef_xml_encoding_type,
  URI: string, loadError: var string): NCXmlObject =

  var reader = ncXmlReaderCreate(stream, encodingType, URI)
  if reader == nil: return nil
  var ret = reader.moveToNextNode()
  if not ret: return nil

  var
    cur_object = makeNCXmlObject("document")
    new_object: NCXmlObject
    queue: seq[NCXmlObject] = @[]
    cur_depth = 0
    value_depth = -1
    cur_type: cef_xml_node_type
    cur_value = ""
    last_has_ns = false

  result = cur_object
  queue.add(cur_object)

  while true:
    cur_depth = reader.getDepth()
    if value_depth >= 0 and (cur_depth > value_depth):
      # The current node has already been parsed as part of a value.
      if not reader.moveToNextNode(): break
      continue

    cur_type = reader.getType()
    if cur_type == XML_NODE_ELEMENT_START:
      if cur_depth == value_depth:
        # Add to the current value.
        cur_value.add reader.getOuterXml()
        if not reader.moveToNextNode(): break
        continue
      elif last_has_ns and reader.getPrefix().len == 0:
        if not cur_object.hasChildren():
          # Start a new value because the last element has a namespace and
          # this element does not.
          value_depth = cur_depth
          cur_value.add reader.getOuterXml()
        else:
          # Value following a child element is not allowed.
          loadError = "Value following child element, line "
          loadError.add $reader.getLineNumber()
          ret = false
          break
      else:
        # Start a new element.
        new_object = makeNCXmlObject(reader.getQualifiedName())
        discard cur_object.addChild(new_object)
        last_has_ns = reader.getPrefix().len != 0
        if not reader.isEmptyElement():
          # The new element potentially has a value and/or children, so
          # set the current object and add the object to the queue.
          cur_object = new_object
          queue.add(cur_object)
        if reader.hasAttributes() and reader.moveToFirstAttribute():
          # Read all object attributes.
          while true:
            discard new_object.setAttributeValue(reader.getQualifiedName(), reader.getValue())
            if not reader.moveToNextAttribute(): break
          discard reader.moveToCarryingElement()
    elif cur_type == XML_NODE_ELEMENT_END:
      if cur_depth == value_depth:
        # Ending an element that is already in the value.
        if not reader.moveToNextNode(): break
        continue
      elif cur_depth < value_depth:
        # Done with parsing the value portion of the current element.
        discard cur_object.setValue(cur_value)
        cur_value = ""
        value_depth = -1

      # Pop the current element from the queue.
      discard queue.pop()

      if (queue.len == 0) or (cur_object.getName() != reader.getQualifiedName()):
        # Open tag without close tag or close tag without open tag should
        # never occur (the parser catches this error).
        # NOTREACHED()
        loadError = "Mismatched end tag for "
        loadError.add cur_object.getName()
        loadError.add ", line "
        loadError.add $reader.getLineNumber()
        ret = false
        break

      # Set the current object to the previous object in the queue.
      cur_object = queue[queue.len - 1]
    elif cur_type in {XML_NODE_TEXT, XML_NODE_CDATA, XML_NODE_ENTITY_REFERENCE}:
      if cur_depth == value_depth:
        # Add to the current value.
        cur_value.add reader.getValue()
      elif not cur_object.hasChildren():
        # Start a new value.
        value_depth = cur_depth
        cur_value.add reader.getValue()
      else:
        # Value following a child element is not allowed.
        loadError = "Value following child element, line "
        loadError.add $reader.getLineNumber()
        ret = false
        break

    if not reader.moveToNextNode(): break

  if reader.hasError():
    loadError = reader.getError()
    return nil

  if not ret: return nil