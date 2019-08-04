library All requires Deferred
	//All/Any objects need to be cleaned up IN ADDITION TO / separately from the deferreds that they wrap around (just need to call destroy)
	struct All extends array
		public integer CountFinished
		public integer CountWaiting
		
		public delegate Deferred Promise
				
		private static method onPromiseResolve takes integer result, All all returns integer
			set all.CountFinished = all.CountFinished + 1
						
			if all.CountFinished == all.CountWaiting then
				call all.Promise.Resolve(result)
			else
				call all.Promise.Progress(result)
			endif
			
			return 0
		endmethod
		private static method onPromiseProgress takes integer result, All all returns integer
			call all.Promise.Progress(result)
			
			return 0
		endmethod
		
		public static method create takes SimpleList_List allPromises returns thistype
			local thistype new = Deferred.create()
			local SimpleList_ListNode curPromiseNode = allPromises.first
			set new.Promise = new
			set new.CountFinished = 0
			set new.CountWaiting = allPromises.count
			
			loop
			exitwhen curPromiseNode == 0
				call Deferred(curPromiseNode.value).Then(thistype.onPromiseResolve, thistype.onPromiseProgress, new)
			set curPromiseNode = curPromiseNode.next
			endloop
			
			return new
		endmethod
		public method destroy takes nothing returns nothing
			//call DisplayTextToPlayer(Player(0), 0, 0, "All destroying - " + I2S(this))
			call this.Promise.destroy()
		endmethod
	endstruct
endlibrary