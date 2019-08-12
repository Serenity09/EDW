library SyncRequest requires Deferred
	globals
		private constant boolean PRIVATE_EVENT = true //loosely recommended to leave true, but doing so adds a fair bit of bloat to an unoptimized string. you just probably shouldn't chain the same sync prefix even if false
		private constant string EVENT_PREFIX = "E" //can be anything if PRIVATE_EVENT == true, but should be a unique prefix if false
		private constant string DATA_DELIMITER = "," //should be any single character
	endglobals
	
	struct SyncRequest extends array
		// private static trigger SyncTrigger
		
		readonly string RequestData
		
		public method operator Promise takes nothing returns Deferred
			return this
		endmethod
		public method operator Data takes nothing returns string
			return this.RequestData
		endmethod
		
		private static method OnSync takes nothing returns boolean
			//Idea: encode a "sync data request" ID at the start of every request's result
			//then decode the ID portion of the result and use ID to retrieve the original Deferred (returned at the start of the request) and resolve it
			//resolve with the same ID/object, which can then be used to retrieve the data via API (which resolves via a dictionary or some shit)
			local string rawData = BlzGetTriggerSyncData()
			local integer curDataPosition = 0
			local thistype request = 0
			
			// call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "raw data: " + rawData)
			loop
			exitwhen curDataPosition + 1 >= StringLength(rawData) or request != 0
				if SubString(rawData, curDataPosition, curDataPosition + 1) == DATA_DELIMITER then
					set request = S2I(SubString(rawData, 0, curDataPosition))
				endif
			set curDataPosition = curDataPosition + 1
			endloop
			
			set request.RequestData = SubString(rawData, curDataPosition, StringLength(rawData))
			// call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "sync request: " + I2S(request) + ", data: " + request.RequestData)
			
			call Deferred(request).Resolve(request)
			
			return false
		endmethod
		public method Sync takes string data returns nothing
			static if PRIVATE_EVENT then
				call BlzSendSyncData(SCOPE_PRIVATE + EVENT_PREFIX, I2S(this) + DATA_DELIMITER + data)
			else
				call BlzSendSyncData(EVENT_PREFIX, I2S(this) + DATA_DELIMITER + data)
			endif
		endmethod
		
		public static method create takes DeferredCallback success, integer callbackData returns thistype
			local Deferred new = Deferred.create()
			call new.Then(success, 0, callbackData)
			
			return new
		endmethod
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
			
			//assert configuration in anyway possible
			static if DEBUG_MODE then
				call ThrowError(StringLength(DATA_DELIMITER) > 1, "SyncRequest", "onInit", null, 0, "Delimiter is an invalid length")
				
			endif
		endmethod
	endstruct	
endlibrary