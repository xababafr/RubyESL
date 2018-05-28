#.......................................................
# Do not move this 'evaluate'  function inside a module
# Otherwise, the eval_uated class will be prefixed
# with the module itself
# ......................................................
def evaluate simfile
  rcode=IO.read(simfile)
  eval(rcode)
end
