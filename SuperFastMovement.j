library SuperFastMovement requires SandMovement, isMoving, TimerUtils, GroupUtils
globals
    constant real SuperFastSpeed = 10
	private real TIMESTEP = .035
endglobals

struct SuperFastMovement extends array
	private static group g = null
	private static timer t = null
	
	private static method FastMove takes nothing returns nothing
		local group swap = NewGroup()
		local unit u
		local real facingRad
		
		loop
		set u = FirstOfGroup(g)
		exitwhen u == null
			if isMoving[GetPlayerId(GetOwningPlayer(u))] then
				set facingRad = GetUnitFacing(u) * bj_DEGTORAD
				call SetUnitX(u, GetUnitX(u) + Cos(facingRad) * SuperFastSpeed)
				call SetUnitY(u, GetUnitY(u) + Sin(facingRad) * SuperFastSpeed)
			endif
		call GroupAddUnit(swap, u)
		call GroupRemoveUnit(g, u)
		endloop
		
		call ReleaseGroup(g)
		set g = swap
		set swap = null
		
		set u = null
	endmethod

	public static method Add takes unit u returns nothing
		if g == null then
			set g = NewGroup()
			set t = NewTimer()
			
			call TimerStart(t, TIMESTEP, true, function thistype.FastMove)
		endif
		
		call GroupAddUnit(g, u)
		
		//check if unit is moving currently, otherwise set isMoving appropriately
		call GroupAddUnit(DestinationGroup, u)
		
		if GetUnitCurrentOrder(u) == OrderId("none") or GetUnitCurrentOrder(u) == OrderId("stop") then
            set isMoving[GetPlayerId(GetOwningPlayer(u))] = false
        else
            set isMoving[GetPlayerId(GetOwningPlayer(u))] = true
        endif
	endmethod
	
	public static method Remove takes unit u returns nothing
		call GroupRemoveUnit(g, u)
		call GroupRemoveUnit(DestinationGroup, u)
		
		if IsGroupEmpty(g) then
			call ReleaseTimer(t)
			call ReleaseGroup(g)
			
			set g = null
			set t = null
		endif
	endmethod
endstruct

endlibrary