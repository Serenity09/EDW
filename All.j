library All requires Deferred
	struct All
		public integer CountFinished
		public integer CountWaiting
		
		public delegate Deferred Promise
				
		private static method onPromiseResolve takes integer result, All all returns integer
			set all.CountFinished = all.CountFinished + 1
			
			if all.CountFinished == all.CountWaiting then
				call all.Promise.Resolve(result)
			endif
			
			return 0
		endmethod
		
		public static method create takes SimpleList_List allPromises returns thistype
			local SimpleList_ListNode curPromiseNode = allPromises.first
			local thistype new = Deferred.create()
			set new.Promise = new
			set new.CountFinished = 0
			set new.CountWaiting = allPromises.count
			
			loop
			exitwhen curPromiseNode == 0
				call Deferred(curPromiseNode.value).Then(thistype.onPromiseResolve, 0, new)
			set curPromiseNode = curPromiseNode.next
			endloop
			
			return new
		endmethod
	endstruct
endlibrary