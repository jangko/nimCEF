import nc_parser

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