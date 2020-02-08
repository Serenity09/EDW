library LavaDamage requires TimerUtils, GroupUtils, SimpleList, SpecialEffect
	globals	
		private real TIMESTEP = .5
		private constant real LAVARATE = 350 * TIMESTEP //~1.8 seconds till death
		
		private constant string DEATH_FX = "Abilities\\Spells\\Human\\MarkOfChaos\\MarkOfChaosTarget.mdl"
		private constant string LAVA_MOVEMENT_FX = "Abilities\\Spells\\Orc\\LiquidFire\\Liquidfire.mdl"
		
		private constant boolean DEBUG_DELTA = false
	endglobals

	struct LavaDamage extends array
		private static SimpleList_List players
		private static real array pctTimeApplied
		private static timer t = null		
		
		//this doesn't work when run on timer start
		//for some reason timers start with a different elapsed / remaining time than they tick with
		//OR i could pass Elapsed time in as a parameter, hard coding it to the ideal value for its start state
		public static method ApplyDamage takes integer pID, real pctTimeElapsed returns nothing
			//delta remaining from previous call * % of timestep represented during call
			local real pctTimeDamaged = pctTimeElapsed - thistype.pctTimeApplied[pID]
			local real damagedHP = RMaxBJ(0., (GetUnitState(MazersArray[pID], UNIT_STATE_LIFE) - LAVARATE * pctTimeDamaged))
			
			static if DEBUG_DELTA then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Applied Delta: " + R2S(pctTimeDamaged) + ", damage: " + R2S(LAVARATE * pctTimeDamaged))
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Timer elapsed time: " + R2S(TimerGetElapsed(.t)) + ", parameter pctTimeElapsed: " + R2S(pctTimeElapsed) + ", property already applied time (%): " + R2S(thistype.pctTimeApplied[pID]))
			endif
			
			if pctTimeElapsed >= 1. then
				//reset deltas
				set pctTimeApplied[pID] = 0.
			else
				//equivalent to thistype.pctTimeApplied[pID] + pctTimeDamaged
				set pctTimeApplied[pID] = pctTimeElapsed 
			endif
						
			static if DEBUG_DELTA then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "New Delta: " + R2S(thistype.pctTimeApplied[pID]))
			endif
			
			//update mazer life
			call SetUnitState(MazersArray[pID], UNIT_STATE_LIFE, damagedHP)
			
			//TODO better for HD only (add for HD only)
			call BlzSetSpecialEffectScale(CreateTimedSpecialEffect(LAVA_MOVEMENT_FX, GetUnitX(MazersArray[pID]), GetUnitY(MazersArray[pID]), Player(pID), TIMESTEP * GetRandomReal(1.5, 2.)), GetRandomReal(.6, .8))
			
			if damagedHP == 0 then
				call CreateInstantSpecialEffect(DEATH_FX, GetUnitX(MazersArray[pID]), GetUnitY(MazersArray[pID]), Player(pID))
			endif
		endmethod		
		private static method ApplyDamageLoop takes nothing returns nothing
			local SimpleList_ListNode curPlayerNode = thistype.players.first
			local real pctTimeElapsed = TimerGetElapsed(thistype.t) / TIMESTEP
			
			loop
			exitwhen curPlayerNode == 0
				call thistype.ApplyDamage(curPlayerNode.value, pctTimeElapsed)
			set curPlayerNode = curPlayerNode.next
			endloop
		endmethod

		public static method Add takes integer pID returns nothing
			set thistype.pctTimeApplied[pID] = 0.
			
			if thistype.players.count == 0 then
				set .t = NewTimer()
				call TimerStart(.t, TIMESTEP, true, function thistype.ApplyDamageLoop)
				
				//immediately apply full portion of damage
				call thistype.ApplyDamage(pID, 1.)
			else
				//immediately apply the portion of damage that the timer has currently elapsed for, it will then apply the remaining damage at the next natural tick
				call thistype.ApplyDamage(pID, TimerGetElapsed(thistype.t) / TIMESTEP)
			endif
			
			call thistype.players.add(pID)
			
			//TODO better for SD only (add for SD only)
			// call User(pID).SetActiveEffect(LAVA_MOVEMENT_FX, "origin")
		endmethod
		
		public static method Remove takes integer pID returns nothing
			call thistype.players.remove(pID)
			
			//TODO better for SD only (add for SD only)
			// call User(pID).ClearActiveEffect()
			
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