library LavaDamage requires TimerUtils, GroupUtils, SimpleList
	globals	
		private real TIMESTEP = .5
		private constant real LAVARATE = 350 * TIMESTEP //2 seconds till death	
		private constant real DELTA_ROUND = 0.0 //round delta buffer remaining to 0 at this point
		
		private constant boolean DEBUG_DELTA = false
	endglobals

	struct LavaDamage extends array
		private static SimpleList_List players
		private static real array deltaRemaining
		private static timer t = null
		
		public static method ApplyDamage takes integer pID returns nothing
			//delta remaining from previous call * % of timestep represented during call
			local real pctTimeElapsed = TimerGetElapsed(thistype.t) / TIMESTEP
			local real damagedHP = RMaxBJ(0., (GetUnitState(MazersArray[pID], UNIT_STATE_LIFE) - LAVARATE * RMinBJ(thistype.deltaRemaining[pID], pctTimeElapsed)))
			
			static if DEBUG_DELTA then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Applied Delta: " + R2S(RMinBJ(thistype.deltaRemaining[pID], pctTimeElapsed)) + ", damage: " + R2S(LAVARATE * RMinBJ(thistype.deltaRemaining[pID], pctTimeElapsed)))
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Elapsed time: " + R2S(TimerGetElapsed(.t)) + ", pctTimeElapsed: " + R2S(pctTimeElapsed) + ", delta remaining: " + R2S(thistype.deltaRemaining[pID]))
			endif
			
			if TimerGetElapsed(.t) == TIMESTEP then
				set deltaRemaining[pID] = 1.
			else
				if deltaRemaining[pID] - pctTimeElapsed < DELTA_ROUND then
					set deltaRemaining[pID] = 0.
				else
					set deltaRemaining[pID] = deltaRemaining[pID] - pctTimeElapsed
				endif
			endif
						
			static if DEBUG_DELTA then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "New Delta: " + R2S(thistype.deltaRemaining[pID]))
			endif
			
			//update mazer life
			call SetUnitState(MazersArray[pID], UNIT_STATE_LIFE, damagedHP)			
		endmethod
		private static method ApplyDamageLoop takes nothing returns nothing
			local SimpleList_ListNode curPlayerNode = thistype.players.first
						
			loop
			exitwhen curPlayerNode == 0
				call thistype.ApplyDamage(curPlayerNode.value)
			set curPlayerNode = curPlayerNode.next
			endloop			
		endmethod

		public static method Add takes integer pID returns nothing
			if thistype.players.count == 0 then
				set t = NewTimer()
				
				call TimerStart(t, TIMESTEP, true, function thistype.ApplyDamageLoop)
			endif
			
			call thistype.players.add(pID)
			
			//set initial delta to the % of time till next timer periodic and then immediately apply lava damage
			set thistype.deltaRemaining[pID] = (TIMESTEP - TimerGetElapsed(thistype.t)) / TIMESTEP
			call ApplyDamage(pID)
		endmethod
		
		public static method Remove takes integer pID returns nothing
			call thistype.players.remove(pID)
			
			if thistype.players.count == 0 then
				call ReleaseTimer(t)
				
				set t = null
			endif
		endmethod
		
		private static method onInit takes nothing returns nothing
			set .players = SimpleList_List.create()
		endmethod
	endstruct
endlibrary