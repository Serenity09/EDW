library All requires Deferred
	globals
		private integer array CountFinished
		private integer array CountWaiting
	endglobals
	
	private function onPromiseResolve takes integer result, Deferred all returns integer
		set CountFinished[all] = CountFinished[all] + 1
					
		if CountFinished[all] == CountWaiting[all] then
			call all.Resolve(result)
		else
			call all.Progress(result)
		endif
		
		return 0
	endfunction
	private function onPromiseProgress takes integer result, Deferred all returns integer
		call all.Progress(result)
		
		return 0
	endfunction
	
	function All takes SimpleList_List allPromises returns Deferred
		local Deferred new = Deferred.create()
		local SimpleList_ListNode curPromiseNode = allPromises.first
		
		set CountFinished[new] = 0
		set CountWaiting[new] = allPromises.count
		
		loop
		exitwhen curPromiseNode == 0
			call Deferred(curPromiseNode.value).Then(onPromiseResolve, onPromiseProgress, new)
		set curPromiseNode = curPromiseNode.next
		endloop
		
		return new
	endfunction
endlibrary