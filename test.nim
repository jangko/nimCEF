type
  abc = ref object
    bnc: int
    

proc uvw(a: var abc) =
  a = abc(bnc:13)
  
var a: abc

a.uvw
echo a.bnc