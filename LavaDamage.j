library LavaDamage requires TimerUtils, GroupUtils, SimpleList
	globals	
		private real TIMESTEP = .5
		private constant real LAVARATE = 350 * TIMESTEP //~1.8 seconds till death
				
		private constant boolean DEBUG_DELTA = false
	endglobals

	struct LavaDamage extends array
		private static SimpleList_List players
		private static real array appliedTime
		private static timer t = null		
		
		//this doesn't work when run on timer start
		//for some reason timers start with a different elapsed / remaining time than they tick with
		public static method ApplyDamage takes integer pID returns nothing
			//delta remaining from previous call * % of timestep represented during call
			local real pctTimeElapsed = TimerGetElapsed(.t) / TIMESTEP
			local real pctTimeDamaged = pctTimeElapsed - thistype.appliedTime[pID]
			local real damagedHP = RMaxBJ(0., (GetUnitState(MazersArray[pID], UNIT_STATE_LIFE) - LAVARATE * pctTimeDamaged))
			
			static if DEBUG_DELTA then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Applied Delta: " + R2S(pctTimeDamaged) + ", damage: " + R2S(LAVARATE * pctTimeDamaged))
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Elapsed time: " + R2S(TimerGetElapsed(.t)) + ", pctTimeElapsed: " + R2S(pctTimeElapsed) + ", already applied time (%): " + R2S(thistype.appliedTime[pID]))
			endif
			
			if TimerGetElapsed(.t) == TIMESTEP then
				//reset deltas
				set appliedTime[pID] = 0.
			else
				//equivalent to thistype.appliedTime[pID] + pctTimeDamaged
				set appliedTime[pID] = pctTimeElapsed 
			endif
						
			static if DEBUG_DELTA then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "New Delta: " + R2S(thistype.appliedTime[pID]))
			endif
			
			//update mazer life
			call SetUnitState(MazersArray[pID], UNIT_STATE_LIFE, damagedHP)
		endmethod
		//hack workaround for timers starting with different properties than they tick with
		//all TimerGet___ calls are replaced with my preferred result on TimerStart
		private static method ApplyDamageTimerStart takes integer pID returns nothing
			//local real pctTimeElapsed = 1.
			//local real pctTimeDamaged = 1.
			local real damagedHP = RMaxBJ(0., (GetUnitState(MazersArray[pID], UNIT_STATE_LIFE) - LAVARATE))
			
			static if DEBUG_DELTA then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Applied Damage Start")
			endif
			
			set thistype.appliedTime[pID] = 0.
			
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
				set .t = NewTimer()
				call TimerStart(.t, TIMESTEP, true, function thistype.ApplyDamageLoop)
				
				set thistype.appliedTime[pID] = 0.
				
				//immediately apply full portion of damage
				call thistype.ApplyDamageTimerStart(pID)
			else
				//set initial delta to the % of time till next timer periodic and then immediately apply lava damage
				set thistype.appliedTime[pID] = (TIMESTEP - TimerGetElapsed(thistype.t)) / TIMESTEP
				
				//immediately apply the portion of damage that this player has been present for
				call thistype.ApplyDamage(pID)
			endif
			
			call thistype.players.add(pID)
		endmethod
		
		public static method Remove takes integer pID returns nothing
			call thistype.players.remove(pID)
			
			if thistype.players.count == 0 then
				call ReleaseTimer(.t)
				set .t = null
			endif
		endmethod
		
		private static method onInit takes nothing returns nothing
			set .players = SimpleList_List.create()
		endmethod
	endstruct
endlibrary