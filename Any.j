library Any requires Deferred
	private function onPromiseResolve takes integer result, Deferred any returns integer
		call any.Resolve(result)
		
		return 0
	endfunction
	private function onPromiseProgress takes integer result, Deferred any returns integer
		call any.Progress(result)
		
		return 0
	endfunction
	
	function Any takes SimpleList_List allPromises returns Deferred
		local Deferred new = Deferred.create()
		local SimpleList_ListNode curPromiseNode = allPromises.first
			
		loop
		exitwhen curPromiseNode == 0
			call Deferred(curPromiseNode.value).Then(onPromiseResolve, onPromiseProgress, new)
		set curPromiseNode = curPromiseNode.next
		endloop
		
		return new
	endfunction
endlibrary