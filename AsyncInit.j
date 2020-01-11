library AsyncInit requires SimpleList, Deferred, All optional ErrorMessage
	globals
		private SimpleList_List Awaiting
		private SimpleList_List ResolveCallbacks
		
		private Deferred AsyncInit
		
		private constant real INIT_TIME = .1
		private constant real ERROR_CHECK_TIME = 5.
	endglobals
	
	function RegisterAsyncCallback takes DeferredCallback callback returns nothing
		if AsyncInit == 0 then
			call ResolveCallbacks.addEnd(callback)
		else
			call AsyncInit.Then(callback, 0, AsyncInit)
		endif
	endfunction
	function RegisterAsyncInit takes Deferred asyncInit returns nothing
		// call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Registering async init deferred: " + I2S(asyncInit))
		if AsyncInit == 0 then
			call Awaiting.addEnd(asyncInit)
		static if LIBRARY_ErrorMessage then
		else
			call ThrowError(true, "AsyncInit", "RegisterAsyncInit", null, 0, "Registered async init deferred: " + I2S(asyncInit) + " too late")
		endif
		endif
	endfunction
	
	private function AsyncCleanup takes Deferred lastAsyncInit, Deferred allAsyncInit returns integer
		local SimpleList_ListNode curAwaitingNode
		
		loop
		set curAwaitingNode = Awaiting.pop()
		exitwhen curAwaitingNode == 0
			call Deferred(curAwaitingNode.value).destroy()
		endloop
		
		call Awaiting.destroy()
		set Awaiting = 0
		
		return 0
	endfunction
	
	private function InitErrorCheck takes nothing returns nothing
		if AsyncInit == 0 then
			call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "A critical error occured during initialization. Please email wcescapedreamworld@gmail.com for assistance")
		
			static if LIBRARY_ErrorMessage then
				call ThrowError(true, "AsyncInit", "InitErrorCheck", null, 0, "A critical error occured during initialization")
			endif
		else
			if not AsyncInit.Resolved then
				// static if LIBRARY_ErrorMessage then
					// call ThrowError(true, "AsyncInit", "InitErrorCheck", null, 0, "Failed to fully resolve!")
				// endif
				if CONFIGURATION_PROFILE != RELEASE then
					call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Async init failed to resolve on its own (likely due to a player disconnect during load). Attempting to resolve it manually")
				endif
				
				call AsyncInit.Resolve(0)
			endif
		endif
		
		call DestroyTimer(GetExpiredTimer())
	endfunction
	private function InitCB takes nothing returns nothing
		local SimpleList_ListNode curCallbackNode
		
		// call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Async deferreds")
		// call Awaiting.print(0)
		// call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Callbacks")
		// call ResolveCallbacks.print(0)
		
		set AsyncInit = All(Awaiting)
		call AsyncInit.Then(AsyncCleanup, 0, 0)
		
		loop
		set curCallbackNode = ResolveCallbacks.pop()
		exitwhen curCallbackNode == 0
			call AsyncInit.Then(DeferredCallback(curCallbackNode.value), 0, AsyncInit)
		endloop
		call ResolveCallbacks.destroy()
		set ResolveCallbacks = 0
		
		call DestroyTimer(GetExpiredTimer())
	endfunction
	private function Init takes nothing returns nothing
		set Awaiting = SimpleList_List.create()
		set ResolveCallbacks = SimpleList_List.create()
				
		set AsyncInit = 0
		call TimerStart(CreateTimer(), INIT_TIME, false, function InitCB)
		
		call TimerStart(CreateTimer(), ERROR_CHECK_TIME, false, function InitErrorCheck)
	endfunction
	
	private module m
		private static method onInit takes nothing returns nothing
			call Init()
		endmethod
	endmodule
	private struct s extends array
		implement m
	endstruct
endlibrary