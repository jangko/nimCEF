import nc_xml_reader, strtabs, nc_stream, cef/cef_types, nc_util

type
  NCXmlObject* = ref object
    name: string
    parent: NCXmlObject
    value: string
    attributes: StringTableRef
    children: seq[NCXmlObject]
  
proc newNCXmlObject*(name: string): NCXmlObject =
  new(result)
  result.name = name
  result.children = @[]
  result.attributes = newStringTable(modeCaseSensitive)
  result.value = ""
  
proc SetParent*(self, parent: NCXmlObject) =
  if parent != nil:
    doAssert(self.parent == nil)
    self.parent = parent
  else:
    assert(self.parent != nil)
    self.parent = nil
  
proc ClearChildren*(self: NCXmlObject) =
  for it in self.children:
    it.SetParent(nil)
  self.children = @[]
  
proc ClearAttributes*(self: NCXmlObject) =
  self.attributes.clear(modeCaseSensitive)
  
# Clears this object's children and attributes. The name and parenting of
# this object are not changed. 
proc Clear*(self: NCXmlObject) =
  self.ClearChildren()
  self.ClearAttributes()
  
# Access the object's name. An object name must always be at least one
# character long. 
proc GetName*(self: NCXmlObject): string =
  result = self.name
  
proc SetName*(self: NCXmlObject, name: string): bool =
  if name.len == 0: return false
  self.name = name
  result = true
  
# Access the object's parent. The parent can be NULL if this object has not
# been added as the child on another object.
proc HasParent*(self: NCXmlObject): bool = 
  result = self.parent != nil

proc GetParent*(self: NCXmlObject): NCXmlObject =
  result = self.parent
  
# Access the object's value. An object cannot have a value if it also has
# children. Attempting to set the value while children exist will fail.
proc HasValue*(self: NCXmlObject): bool = 
  result = self.value.len != 0
  
proc GetValue*(self: NCXmlObject): string = 
  result = self.value
  
proc SetValue*(self: NCXmlObject, value: string): bool = 
  assert(self.children.len == 0)
  if not self.children.len == 0: return false
  self.value = value
  result = true

# Access the object's attributes. Attributes must have unique names.
proc HasAttributes*(self: NCXmlObject): bool =
  result = self.attributes.len != 0
  
proc GetAttributeCount*(self: NCXmlObject): int =
  result = self.attributes.len
  
proc HasAttribute*(self: NCXmlObject, name: string): bool =
  result = self.attributes.hasKey(name)
  
proc GetAttributeValue*(self: NCXmlObject, name: string): string =
  result = self.attributes[name]
  
proc SetAttributeValue*(self: NCXmlObject, name, value: string): bool =
  assert(name.len != 0)
  if name.len == 0: return false
  self.attributes[name] = value
  result = true

proc GetAttributes*(self: NCXmlObject): StringTableRef =
  result = self.attributes
  
# Access the object's children. Each object can only have one parent so
# attempting to add an object that already has a parent will fail. Removing a
# child will set the child's parent to NULL. Adding a child will set the
# child's parent to this object. This object's value, if any, will be cleared
# if a child is added.

proc HasChildren*(self: NCXmlObject): bool =
  result = self.children.len != 0
  
proc GetChildCount*(self: NCXmlObject): int =
  result = self.children.len

proc HasChild*(self, child: NCXmlObject): bool =
  for c in self.children:
    if c == child: return true
  result = false
  
proc AddChild*(self, child: NCXmlObject): bool =
  if child == nil: return false
  assert(child.parent == nil)
  if child.parent != nil: return false
  self.children.add(child)
  child.SetParent(self)
  result = true
  
proc RemoveChild*(self, child: NCXmlObject): bool =
  for i in 0.. <self.children.len:
    if self.children[i] == child:
      self.children.delete(i)
      child.SetParent(nil)
      return true
  result = false

proc GetChildren*(self: NCXmlObject): seq[NCXmlObject] =
  result = self.children
  
# Find the first child with the specified name.
proc FindChild*(self: NCXmlObject, name: string): NCXmlObject =
  assert(name.len != 0)
  if name.len == 0: return nil
  for n in self.children:
    if n.name == name: return n
  result = nil
  
# Find all children with the specified name.
proc FindChildren*(self: NCXmlObject, name: string): seq[NCXmlObject] =
  result = @[]
  assert(name.len != 0)
  if name.len != 0:
    for n in self.children:
      if n.name == name: result.add(n)
 
# Append a duplicate of the children and attributes of the specified object
# to this object. If |overwriteAttributes| is true then any attributes in
# this object that also exist in the specified object will be overwritten
# with the new values. The name of this object is not changed.
proc Append*(self, other: NCXmlObject, overwriteAttributes: bool)
 
# Set the name, children and attributes of this object to a duplicate of the
# specified object's contents. The existing children and attributes, if any,
# will first be cleared.
proc Set*(self, other: NCXmlObject) =
  assert(other != nil)
  self.Clear()
  self.name = other.name
  self.Append(other, true)

# Return a new object with the same name, children and attributes as this
# object. The parent of the new object will be NULL.
proc Duplicate(self: NCXmlObject): NCXmlObject =
  result = newNCXmlObject(self.name)
  result.Append(self, true)
    
proc Append(self, other: NCXmlObject, overwriteAttributes: bool) =
  assert(other != nil)

  if other.HasChildren():
    let children = other.GetChildren()
    for it in children:
      discard self.AddChild(it.Duplicate())

  if other.HasAttributes():
    let attributes = other.GetAttributes()
    for key, val in attributes:
      if overwriteAttributes or not self.HasAttribute(key):
        discard self.SetAttributeValue(key, val)
    
# Load the contents of the specified XML stream into this object.
proc LoadXml*(stream: NCStreamReader, encodingType: cef_xml_encoding_type,
  URI: string, loadError: var string): NCXmlObject =
  
  var reader = NCXmlReaderCreate(stream, encodingType, URI)
  if reader == nil: return nil
  var ret = reader.MoveToNextNode()
  if not ret:
    release(reader)
    return nil
  
  var
    cur_object = newNCXmlObject("document")
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
    cur_depth = reader.GetDepth()
    if value_depth >= 0 and (cur_depth > value_depth):
      # The current node has already been parsed as part of a value.
      discard reader.MoveToNextNode()
      continue

    cur_type = reader.GetType()
    if cur_type == XML_NODE_ELEMENT_START:
      if cur_depth == value_depth:
        # Add to the current value.
        cur_value.add reader.GetOuterXml()
        discard reader.MoveToNextNode()
        continue
      elif last_has_ns and reader.GetPrefix().len == 0:
        if not cur_object.HasChildren():
          # Start a new value because the last element has a namespace and
          # this element does not.
          value_depth = cur_depth
          cur_value.add reader.GetOuterXml()
        else:
          # Value following a child element is not allowed.
          loadError = "Value following child element, line " 
          loadError.add $reader.GetLineNumber()
          ret = false
          break
      else:
        # Start a new element.
        new_object = newNCXmlObject(reader.GetQualifiedName())
        discard cur_object.AddChild(new_object)
        last_has_ns = reader.GetPrefix().len != 0
        if not reader.IsEmptyElement():
          # The new element potentially has a value and/or children, so
          # set the current object and add the object to the queue.
          cur_object = new_object
          queue.add(cur_object)
        if reader.HasAttributes() and reader.MoveToFirstAttribute():
          # Read all object attributes.
          while true:
            discard new_object.SetAttributeValue(reader.GetQualifiedName(), reader.GetValue())
            if not reader.MoveToNextAttribute(): break
          discard reader.MoveToCarryingElement()
    elif cur_type == XML_NODE_ELEMENT_END:
      if cur_depth == value_depth:
        # Ending an element that is already in the value.
        discard reader.MoveToNextNode()
        continue
      elif cur_depth < value_depth:
        # Done with parsing the value portion of the current element.
        discard cur_object.SetValue(cur_value)
        cur_value = ""
        value_depth = -1
      
      # Pop the current element from the queue.
      discard queue.pop()

      if (queue.len == 0) or (cur_object.GetName() != reader.GetQualifiedName()):
        # Open tag without close tag or close tag without open tag should
        # never occur (the parser catches this error).
        # NOTREACHED()
        loadError = "Mismatched end tag for "
        loadError.add cur_object.GetName()
        loadError.add ", line "
        loadError.add $reader.GetLineNumber()
        ret = false
        break

      # Set the current object to the previous object in the queue.
      cur_object = queue[queue.len - 1]
    elif cur_type in {XML_NODE_TEXT, XML_NODE_CDATA, XML_NODE_ENTITY_REFERENCE}:
      if cur_depth == value_depth:
        # Add to the current value.
        cur_value.add reader.GetValue()
      elif not cur_object.HasChildren():
        # Start a new value.
        value_depth = cur_depth
        cur_value.add reader.GetValue()
      else:
        # Value following a child element is not allowed.
        loadError = "Value following child element, line "
        loadError.add $reader.GetLineNumber()
        ret = false
        break
        
    if not reader.MoveToNextNode(): break
    
  if reader.HasError():
    loadError = reader.GetError()
    release(reader)
    return nil

  if not ret:
    release(reader)
    return nil

  release(reader)