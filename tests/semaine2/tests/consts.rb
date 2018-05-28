# useless?
$entities = [
  { :ename => :e1, :cname => :Emitter },
  { :ename => :e2, :cname => :Emitter },
  { :ename => :comp, :cname => :Computation },
  { :ename => :recv, :cname => :Receiver },
]

$connexions = [
	[ {:ename=>:e1, :port=>:f}   , {:ename=>:comp, :port=>:a}  ],
	[ {:ename=>:e2, :port=>:f}   , {:ename=>:comp, :port=>:b}  ],
	[ {:ename=>:comp, :port=>:f} , {:ename=>:recv, :port=>:i1} ]
]

$inouts = {

	:e1 => [{
		:symbol => :f,
	    :type   => [],
		:value  => :nil
	}],

	:e2 => [{
		:symbol => :f,
	    :type   => [],
		:value  => :nil
	}],

	:comp => [{
		:symbol => :a,
		:type   => [],
		:value  => :nil
	}, {
		:symbol => :b,
		:type   => [],
		:value  => :nil
	}, {
		:symbol => :f,
		:type   => [],
		:value  => :nil
	}],

	:recv => [{
		:symbol => :i1,
	    :type   => [],
		:value  => :nil
	}]

}

$operations = {
    :* => [
        # int x int => int
        ["Integer", "Integer", "Integer"],
        ["Float", "Integer", "Float"],
        ["Integer", "Float", "Float"],
        ["Float", "Float", "Float"]
    ]
}
