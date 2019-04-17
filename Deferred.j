library Deferred requires Alloc, SimpleList
	function interface DeferredCallback takes integer result returns integer
	
	struct DeferredAwaiter extends array
		public DeferredCallback Success
		//JASS does not implement error handling, no good way to offer failure
		//public DeferredCallback Failure
		public DeferredCallback Progress
		
		private Deferred Parent
		public Deferred Promise
		
		implement Alloc
		
		public method Remove takes nothing returns nothing
			call this.Parent.Remove(this)
		endmethod
		
		public static method create takes Deferred parent returns thistype
			local thistype new = thistype.allocate()
			
			set new.Parent = parent
			set new.Promise = Deferred.create()
						
			return new
		endmethod
		public method destroy takes nothing returns nothing
			call this.Remove()
			
			call this.Promise.destroy()
			call this.deallocate()
		endmethod
	endstruct
	
	struct Deferred extends array
		readonly boolean Resolved
		public SimpleList_List Waiting
		public integer Result
		//public Deferred ResultPromise
		
		implement Alloc
		
		public method Progress takes integer progress returns nothing
			local SimpleList_ListNode curAwaiter
			
			if not this.Resolved then
				set curAwaiter = this.Waiting.first
				loop
				exitwhen curAwaiter == 0
					if DeferredAwaiter(curAwaiter.value).Progress != 0 then
						call DeferredAwaiter(curAwaiter.value).Progress.evaluate(progress)
					endif
				set curAwaiter = curAwaiter.next
				endloop
			endif
		endmethod
		public method Resolve takes integer result returns nothing
			local SimpleList_ListNode curAwaiter
			local integer awaiterResult
			
			if not this.Resolved then
				set this.Resolved = true
				set this.Result = result
				
				loop
				set curAwaiter = this.Waiting.pop()
				exitwhen curAwaiter == 0
					if DeferredAwaiter(curAwaiter.value).Success != 0 then
						set awaiterResult = DeferredAwaiter(curAwaiter.value).Success.evaluate(result)
						
						//check if awaiterResult is a Deferred and chain it if it is
					endif
					
					call DeferredAwaiter(curAwaiter.value).destroy()
					call curAwaiter.deallocate()
				endloop
			endif
		endmethod
		
		public method Then takes DeferredCallback success /*, DeferredCallback failure */, DeferredCallback progress returns DeferredAwaiter
			local DeferredAwaiter awaiter
			
			if this.Resolved then
				call success.evaluate(this.Result)
				
				return 0
			else
				set awaiter = DeferredAwaiter.create(this)
				set awaiter.Success = success
				//set awaiter.Failure = failure
				set awaiter.Progress = progress
				
				call this.Waiting.addEnd(awaiter)
				
				return awaiter
			endif
		endmethod
		public method Remove takes DeferredAwaiter awaiter returns nothing
			call this.Waiting.remove(awaiter)
		endmethod
		
		public static method create takes nothing returns thistype
			local thistype new = thistype.allocate()
			
			set new.Waiting = SimpleList_List.create()
			
			return new
		endmethod
		public method destroy takes nothing returns nothing
			local SimpleList_ListNode curAwaiter
			
			loop
			set curAwaiter = this.Waiting.pop()
			exitwhen curAwaiter == 0
				call DeferredAwaiter(curAwaiter.value).destroy()
				call curAwaiter.deallocate()
			endloop
			
			call this.Waiting.destroy()
		endmethod
	endstruct
endlibrary