import nc_parser, nc_xml_reader, nc_stream, nc_util, cef/cef_types, nc_xml_object

var parts: NCUrlParts
if NCParseUrl("http://admin:pass@www.myhost.net:8080/mypath/index.php?title=main_page", parts):
  for key, val in fieldPairs(parts):
    echo key, " : ", val
else:
  echo "NCParseUrl failed"
  
var url: string
if NCCreateUrl(parts, url):
  echo url
else:
  echo "NCCreateUrl failed"
  
echo NCFormatUrlForSecurityDisplay(url, "EN")
let mime = NCGetMimeType("jpg")
echo mime

let exts = NCGetExtensionsForMimeType("text/html")
for x in exts:
  echo x
  
let base64 = NCBase64Encode(url.cstring, url.len)
echo base64

echo NCBase64Decode(base64)

let encuri = NCUriEncode(url, true)
echo encuri

echo NCUriDecode(encuri, false, NC_UU_ALL)

var stream = NCStreamReaderCreateForFile("resources\\spruce.xml")
assert(stream != nil)

var loadError: string
var xml = LoadXml(stream, XML_ENCODING_UTF8, "", loadError)
if xml == nil:
  echo loadError
  quit(1)
  
var child = xml.FindChild("spruce").FindChild("description")
if child != nil:
  echo child.GetAttributes()

#var xml = NCXmlReaderCreate(stream, XML_ENCODING_UTF8, "")
#assert(xml != nil)
#
#discard xml.MoveToNextNode() #move to first node
#discard xml.MoveToNextNode()
#echo xml.GetQualifiedName()
#if xml.HasAttributes() and xml.MoveToFirstAttribute():
#  while true:
#    echo xml.GetQualifiedName(), " = ", xml.GetValue()
#    if not xml.MoveToNextAttribute(): break
#    
#release(xml)
release(stream)

var xx: int = 0
atomicInc(xx)
echo "xx: ", xx