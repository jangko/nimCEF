mode = ScriptMode.Verbose

import strutils

var switches = ""

proc addSwitch(sw: string) =
  switches.add " --"
  switches.add sw

addSwitch("path:platform")
addSwitch("path:cef")
addSwitch("path:nimcef")
addSwitch("path:util")
addSwitch("path:wrapper")
addSwitch("threads:on")
addSwitch("tlsEmulation:off")
addSwitch("define:winUnicode")

when defined(release):
  addSwitch("define:release")

when not defined(cpu64):
  addSwitch("cpu:i386")
  
when defined(windows):
  exec "nim c $1 test_client" % [switches]
  exec "nim c $1 test_api" % [switches]
  exec "nim c $1 test_nim_api" % [switches]
  exec "nim c $1 test_parser" % [switches]
  exec "nim c $1 test_simple_client" % [switches]
else:
  exec "nim c $1 simple" % [switches]
