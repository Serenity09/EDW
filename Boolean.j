library Boolean
	function S2B takes string s returns boolean
		return s == "1" or s == "true"
	endfunction
	function B2S takes boolean b returns string
		if b then
			return "true"
		else
			return "false"
		endif
	endfunction
	
	function I2B takes integer i returns boolean
		return i != 0
	endfunction
	function B2I takes boolean b returns integer
		if b then
			return 1
		else
			return 0
		endif
	endfunction
endlibrary