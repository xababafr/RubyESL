#sys=System.new("test1"){
  e1=Emitter.new("e1")
  e2=Emitter.new("e2")
  comp=Computation.new("comp")
  recv=Receiver.new("recv")

  connect e1,:f,comp,:a,:fifo10
  connect e2,:f,comp,:b,:fifo10
  connect comp,:f,recv,:i1,:fifo7
#}
