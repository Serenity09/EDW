library LavaDamage requires TimerUtils, GroupUtils
	globals	
		private real TIMESTEP = .5
		constant real LAVARATE = 350 * TIMESTEP //2 seconds till death	
	endglobals

	struct LavaDamage extends array
		private static group g = null
		private static timer t = null
		
		private static method LavaDamage takes nothing returns nothing
			local group swap = NewGroup()
			local unit u
						
			loop
			set u = FirstOfGroup(g)
			exitwhen u == null
				call SetUnitState(u, UNIT_STATE_LIFE, RMaxBJ(0, (GetUnitState(u, UNIT_STATE_LIFE) - LAVARATE)))
				
			call GroupAddUnit(swap, u)
			call GroupRemoveUnit(g, u)
			endloop
			
			call ReleaseGroup(g)
			set g = swap
			
			set u = null
			set swap = null
		endmethod

		public static method Add takes unit u returns nothing
			if g == null then
				set g = NewGroup()
				set t = NewTimer()
				
				call TimerStart(t, TIMESTEP, true, function thistype.LavaDamage)
			endif
			
			call GroupAddUnit(g, u)
		endmethod
		
		public static method Remove takes unit u returns nothing
			call GroupRemoveUnit(g, u)
			
			if IsGroupEmpty(g) then
				call ReleaseTimer(t)
				call ReleaseGroup(g)
				
				set g = null
				set t = null
			endif
		endmethod
	endstruct
endlibrary