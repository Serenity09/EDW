library SyncRequestAll requires Deferred, Table, PlayerUtils
	globals
		private constant string EVENT_PREFIX = "E"
	endglobals
	
	struct SyncRequestData extends array
		private static trigger Trigger
		private static Table ResponseResults
		
		implement Alloc
		
		private static method OnSyncRequest takes nothing returns boolean
			//no way to look up event handle in callback, no way to get back to original context, no way to resolve original deferred, gg
			//also current deferred API only supports ints, strings are a whole new ballgame
			
			return false
		endmethod
		
		public static method create takes string data returns thistype
			local thistype new = thistype.allocate()
			
			
			
			return new
		endmethod
		
		private static method onInit takes nothing returns nothing
			set thistype.Trigger = CreateTrigger()
			call BlzTriggerRegisterPlayerSyncEvent(thistype.Trigger, Player(0), SCOPE_PRIVATE + EVENT_PREFIX, false)
			call TriggerAddCondition(thistype.Trigger, Condition(function thistype.OnSyncRequest))
			
			set thistype.ResponseResults = Table.create()
		endmethod
	endstruct
	
	function SyncRequestAll takes string data returns Deferred
		
	endfunction
endlibrary