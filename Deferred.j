library Deferred requires Alloc, SimpleList
	function interface DeferredCallback takes integer result, integer callbackData returns integer
	
	struct DeferredAwaiter extends array
		private Deferred Parent
		
		public DeferredCallback Success
		//JASS does not implement error handling, no good way to offer failure
		//public DeferredCallback Failure
		public DeferredCallback Progress
		
		public integer CallbackData
		
		public Deferred Promise
		
		implement Alloc
		
		public method Remove takes nothing returns nothing
			call this.Parent.Remove(this)
		endmethod
		
		public static method create takes Deferred parent, integer callbackData returns thistype
			local thistype new = thistype.allocate()
			
			set new.Parent = parent
			set new.CallbackData = callbackData
			
			set new.Promise = Deferred.create()
			
			return new
		endmethod
		public method destroy takes nothing returns nothing
			set this.Success = 0
			set this.Progress = 0
			
			//call this.Remove()
			call this.Promise.destroy()
			call this.deallocate()
			
			//call DisplayTextToPlayer(Player(0), 0, 0, "Deallocated deferred awaiter - " + I2S(this))
		endmethod
	endstruct
	
	struct Deferred extends array
		readonly boolean Resolved
		public SimpleList_List Waiting
		public integer Result
		
		implement Alloc
		
		public method Progress takes integer progress returns nothing
			local SimpleList_ListNode curAwaiter
			local integer awaiterResult
			
			if not this.Resolved then
				set curAwaiter = this.Waiting.first
				loop
				exitwhen curAwaiter == 0
					if DeferredAwaiter(curAwaiter.value).Progress != 0 then
						set awaiterResult = DeferredAwaiter(curAwaiter.value).Progress.evaluate(progress, DeferredAwaiter(curAwaiter.value).CallbackData)
						
						call DeferredAwaiter(curAwaiter.value).Promise.Progress(awaiterResult)
					endif
				set curAwaiter = curAwaiter.next
				endloop
			endif
		endmethod
		public method Resolve takes integer result returns nothing
			local SimpleList_ListNode curAwaiter = this.Waiting.first
			local integer awaiterResult
			
			if not this.Resolved then
				set this.Resolved = true
				set this.Result = result
				
				loop
				//leave JASS deferreds in waiting queue, to allow them to be properly recycled after use
				//set curAwaiter = this.Waiting.pop()
				exitwhen curAwaiter == 0
					if DeferredAwaiter(curAwaiter.value).Success != 0 then
						set awaiterResult = DeferredAwaiter(curAwaiter.value).Success.evaluate(result, DeferredAwaiter(curAwaiter.value).CallbackData)
						
						//TODO check if awaiterResult is a Deferred and chain it if it is
						
						call DeferredAwaiter(curAwaiter.value).Promise.Resolve(awaiterResult)
					endif
					
					// call DeferredAwaiter(curAwaiter.value).destroy()
					// call curAwaiter.deallocate()
				set curAwaiter = curAwaiter.next
				endloop
			endif
		endmethod
		
		public method Then takes DeferredCallback success /*, DeferredCallback failure */, DeferredCallback progress, integer callbackData returns DeferredAwaiter
			local DeferredAwaiter awaiter
			
			if this.Resolved then
				call success.evaluate(this.Result, callbackData)
				
				return 0
			else
				set awaiter = DeferredAwaiter.create(this, callbackData)
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
			
			set new.Resolved = false
			set new.Result = 0
			set new.Waiting = SimpleList_List.create()
			
			return new
		endmethod
		//Deferreds that can be destroyed and then later accessed as if they were not destroyed need code protecting them from that exact use case
		//Ex. Deferred "A" will resolve when async functionality "X" is finished. When this happens, neither the async function "X" nor the resolve call guarantees conditions required by listening Then calls
		//This is problematic when Deferred "A" will execute Then code that can crash if certain conditions aren't met
		//Solution. Confirm requirements before resolving deferred. In particular, confirm that the Deferred has not been destroyed / recreated
		public method destroy takes nothing returns nothing
			local SimpleList_ListNode curAwaiterNode
			
			//call DisplayTextToPlayer(Player(0), 0, 0, "Deferred destroying - " + I2S(this) + ", awaiter count - " + I2S(this.Waiting.count))
			
			loop
			set curAwaiterNode = this.Waiting.pop()
			exitwhen curAwaiterNode == 0
				call DeferredAwaiter(curAwaiterNode.value).destroy()
				call curAwaiterNode.deallocate()
			endloop
			
			call this.Waiting.destroy()
			call this.deallocate()
			
			//call DisplayTextToPlayer(Player(0), 0, 0, "Deallocated deferred - " + I2S(this))
		endmethod
	endstruct
endlibrary