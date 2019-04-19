library Any
	struct Any	
		public delegate Deferred Promise
				
		private static method onPromiseResolve takes integer result, Any any returns integer
			call any.Promise.Resolve(result)
			
			return 0
		endmethod
		
		public static method create takes SimpleList_List allPromises returns thistype
			local SimpleList_ListNode curPromiseNode = allPromises.first
			local thistype new = Deferred.create()
			set new.Promise = new
			
			loop
			exitwhen curPromiseNode == 0
				call Deferred(curPromiseNode.value).Then(thistype.onPromiseResolve, 0, new)
			set curPromiseNode = curPromiseNode.next
			endloop
			
			return new
		endmethod
	endstruct
endlibrary