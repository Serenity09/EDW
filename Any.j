library Any
	struct Any	
		public delegate Deferred Promise
				
		private static method onPromiseResolve takes integer result, Any any returns integer
			call any.Promise.Resolve(result)
			
			return 0
		endmethod
		private static method onPromiseProgress takes integer result, Any any returns integer
			call any.Promise.Progress(result)
			
			return 0
		endmethod
		
		public static method create takes SimpleList_List allPromises returns thistype
			local SimpleList_ListNode curPromiseNode = allPromises.first
			local thistype new = Deferred.create()
			set new.Promise = new
			
			loop
			exitwhen curPromiseNode == 0
				call Deferred(curPromiseNode.value).Then(thistype.onPromiseResolve, thistype.onPromiseProgress, new)
			set curPromiseNode = curPromiseNode.next
			endloop
			
			return new
		endmethod
		public method destroy takes nothing returns nothing
			call this.Promise.destroy()
		endmethod
	endstruct
endlibrary