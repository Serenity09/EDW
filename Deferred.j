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
		public integer Result
		public DeferredCallback Cancel
		
		public SimpleList_List Waiting
		
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
						
						//TODO check if awaiterResult is a Deferred and chain it if it is. this would need a way to inherently type an arbitrary int ref at runtime
						
						call DeferredAwaiter(curAwaiter.value).Promise.Resolve(awaiterResult)
					endif
					
					// call DeferredAwaiter(curAwaiter.value).destroy()
					// call curAwaiter.deallocate()
				set curAwaiter = curAwaiter.next
				endloop
			static if LIBRARY_ErrorMessage then
			else
				call ThrowError(false, "Deferred", "Resolve", null, 0, "Deferred " + I2S(this) + " has already been resolved!")
			endif
			endif
		endmethod
		
		public method Then takes DeferredCallback success /*, DeferredCallback failure */, DeferredCallback progress, integer callbackData returns DeferredAwaiter
			local DeferredAwaiter awaiter
			
			if this.Resolved then
				call success.evaluate(this.Result, callbackData)
				
				//this should still return an awaiter so that it can be depended on properly
				return DeferredAwaiter.create(this, callbackData)
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
			call awaiter.destroy()
		endmethod
		
		public static method create takes nothing returns thistype
			local thistype new = thistype.allocate()
			
			set new.Resolved = false
			set new.Cancel = 0
			set new.Result = 0
			set new.Waiting = SimpleList_List.create()
			
			return new
		endmethod
		
		//Calling destroy will recycle the entire tree of deferreds and their awaiters depending on this one. This often makes sense to do because if a Deferred parent is destroyed before resolving then it's children will also never resolve. But a deferred which has resolved may have children which have not; in thise case, killing off the parent may make sense, but its children should still have a chance at life
		//Still, recycling trees of deferreds will be annoying to do in chunks, and it should almost always be okay to keep a full tree of Deferreds in memory until ready to be recycled, and for use cases where it isn't, the tree can be broken up by defining multiple root deferreds and resolving/destroying them appropriately
		//SO the current intended use is to construct a deferred tree in whatever way makes sense, and then to keep it entirely around until no node in the tree needs it anymore
		//Otherwise, with no auto garbage collection, the implementing code will be responsible for recycling every parent deferred and its children awaiters (repeat recursively)
		//TODO a Canceled/Destroyed callback would be useful for handling this situation as a child of the deferred tree, otherwise all destroy logic for all child deferreds needs to be handled at the same level as the destroy call, which may not always make sense or be possible
		
		//Deferreds that can be destroyed and then later accessed as if they were not destroyed need code protecting them from that exact use case
		//Ex. Deferred "A" will resolve when async functionality "X" is finished. When this happens, neither the async function "X" nor the resolve call guarantees conditions required by listening Then calls
		//This is problematic when Deferred "A" will execute Then code that can crash if certain conditions aren't met
		//Solution to recycling Deferreds. Only destroy deferreds that are not depended on anymore. Coordinating logic flow for a set of deferred's can be achieved using the All/Any wrappers, or combinations thereof
		public method destroy takes nothing returns nothing
			local SimpleList_ListNode curAwaiterNode
			local integer awaiterResult
			
			//call DisplayTextToPlayer(Player(0), 0, 0, "Deferred destroying - " + I2S(this) + ", awaiter count - " + I2S(this.Waiting.count))
			
			loop
			set curAwaiterNode = this.Waiting.pop()
			exitwhen curAwaiterNode == 0
				if not this.Resolved and this.Cancel != 0 then
					call this.Cancel.evaluate(this.Result, DeferredAwaiter(curAwaiterNode.value).CallbackData)
				endif
				
				call DeferredAwaiter(curAwaiterNode.value).destroy()
				call curAwaiterNode.deallocate()
			endloop
			
			call this.Waiting.destroy()
			call this.deallocate()
			
			//call DisplayTextToPlayer(Player(0), 0, 0, "Deallocated deferred - " + I2S(this))
		endmethod
	endstruct
endlibrary