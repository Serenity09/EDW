library SyncRequest requires Deferred
	globals
		private constant boolean PRIVATE_EVENT = true //loosely recommended to leave true, but doing so adds a fair bit of bloat to an unoptimized string. you just probably shouldn't chain the same sync prefix even if false
		private constant string EVENT_PREFIX = "E" //can be anything if PRIVATE_EVENT == true, but should be a unique prefix if false
		private constant string DATA_DELIMITER = "," //should be any single character
	endglobals
	
	struct SyncRequest extends array
		//will contain the synchronized result of the request, but only after it resolves
		readonly string RequestData
		
		//convenience methods for sweeter sugar and clearer type casting
		public method operator Promise takes nothing returns Deferred
			return this
		endmethod
		public method operator Data takes nothing returns string
			return this.RequestData
		endmethod
		
		//fires after all players have already finished syncing the native BlzSendSyncData event
		//the (now synchronized) data from the original sync event is stored within the corresponding SyncRequest instance
		private static method OnSync takes nothing returns boolean
			//Idea: encode a "sync data request" ID at the start of every request's result
			//then decode the ID portion of the result and use ID to retrieve the original Deferred (returned at the start of the request) and resolve it
			//resolve with the same ID/object, which can then be used to retrieve the data via API (which resolves via a dictionary or some shit)
			local string rawData = BlzGetTriggerSyncData()
			local integer curDataPosition = 0
			local thistype request = 0
			
			loop
			exitwhen curDataPosition + 1 >= StringLength(rawData) or request != 0
				if SubString(rawData, curDataPosition, curDataPosition + 1) == DATA_DELIMITER then
					set request = S2I(SubString(rawData, 0, curDataPosition))
				endif
			set curDataPosition = curDataPosition + 1
			endloop
			
			//check if syncing an already resolved promise, which can only happen if Sync has been called multiple times for the same request
			static if LIBRARY_ErrorMessage then
				call ThrowError(Deferred(request).Resolved, "SyncRequest", "OnSync", null, 0, "Sync request " + I2S(request) + " has already been resolved! SyncRequest.Sync should only be called once per request")
			endif
			
			set request.RequestData = SubString(rawData, curDataPosition, StringLength(rawData))
			
			call Deferred(request).Resolve(request)
			
			return false
		endmethod
		
		//sync some string data
		//should only be called once, but is async/local-player safe
		public method Sync takes string data returns nothing
			static if PRIVATE_EVENT then
				call BlzSendSyncData(SCOPE_PRIVATE + EVENT_PREFIX, I2S(this) + DATA_DELIMITER + data)
			else
				call BlzSendSyncData(EVENT_PREFIX, I2S(this) + DATA_DELIMITER + data)
			endif
		endmethod
		
		//create a new Promise representing a request to synchronize a data string. THIS MUST BE CREATED SYNCHRONOUSLY
		//sync is not called immediately during create, because the whole point is to call that asynchronously, while depending on its success synchronously
		//the success callback is declared during creation because if youre creating a sync request and you don't need to deal with its success, then what are you using this for?
		//any additional Then logic should always run properly whenever/wherever its added (so long as the promise hasn't been destroyed). It should still fire even when the request syncs immediately in single player
		//syncCallbackData should be a value that's already synchronized between players (everything in create must already be synchronized)
		public static method create takes DeferredCallback success, integer syncCallbackData returns thistype
			local Deferred new = Deferred.create()
			call new.Then(success, 0, syncCallbackData)
			
			return new
		endmethod
		//sync requests will never automatically be destroyed, it's up to the calling code to clean them up. this is usually easy to do from within the sync callback
		public method destroy takes nothing returns nothing
			set this.RequestData = null
			call Deferred(this).destroy()
		endmethod
		
		private static method onInit takes nothing returns nothing
			local integer playerIndex = 0
			local trigger syncTrigger = CreateTrigger()
			
			call TriggerAddCondition(syncTrigger, Condition(function thistype.OnSync))
			
			//listen for sync calls from all players, ye symbols all equals before o holy compiler
			loop
				static if PRIVATE_EVENT then
					call BlzTriggerRegisterPlayerSyncEvent(syncTrigger, Player(playerIndex), SCOPE_PRIVATE + EVENT_PREFIX, false)
				else
					call BlzTriggerRegisterPlayerSyncEvent(syncTrigger, Player(playerIndex), EVENT_PREFIX, false)
				endif
			set playerIndex = playerIndex + 1
			exitwhen playerIndex == bj_MAX_PLAYER_SLOTS
			endloop
			
			//assert configuration is compatible with implementation
			static if LIBRARY_ErrorMessage then
				call ThrowError(StringLength(EVENT_PREFIX) < 1, "SyncRequest", "onInit", null, 0, "Event prefix is an invalid length")
				call ThrowError(StringLength(DATA_DELIMITER) != 1, "SyncRequest", "onInit", null, 0, "Delimiter is an invalid length")
			endif
		endmethod
	endstruct	
endlibrary