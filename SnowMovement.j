library SnowMovement requires MazerGlobals, SkatingGlobals, GroupUtils

globals
    private constant real TIMESTEP = 0.035
    
    private constant real OPPOSITION_BONUS = 1.5
    private constant real ACCELERATION = 5.0000*TIMESTEP
endglobals

struct SnowMovement extends array
	private static group g = null
	private static timer t = null
	
	private static method SnowMove takes nothing returns nothing
		local group swap = NewGroup()
		local unit u = GetEnumUnit()
		
		local integer i
		local real facingRad
		local real x
		local real y
		
		loop
		set u = FirstOfGroup(g)
		exitwhen u == null
			set i = GetPlayerId(GetOwningPlayer(u))
			set facingRad = (GetUnitFacing(u)/180)*bj_PI
			set x = Cos(facingRad)
			set y = Sin(facingRad)
			
			if (x > 0 and VelocityX[i] < 0) or (x < 0 and VelocityX[i] > 0) then
				set x = x * OPPOSITION_BONUS * ACCELERATION
			else
				set x = x * ACCELERATION
			endif
			
			if (y > 0 and VelocityY[i] < 0) or (y < 0 and VelocityY[i] > 0) then
				set y = y * OPPOSITION_BONUS * ACCELERATION
			else
				set y = y * ACCELERATION
			endif
			
			set VelocityX[i] = VelocityX[i] + x /*((MAXVELOCITY - RAbsBJ(VelocityX[i])) / MAXVELOCITY)*/
			set VelocityY[i] = VelocityY[i] + y /*((MAXVELOCITY - RAbsBJ(VelocityY[i])) / MAXVELOCITY)*/
			
			call SetUnitX(u, GetUnitX(u) + VelocityX[i])
			call SetUnitY(u, GetUnitY(u) + VelocityY[i])
			call IssueImmediateOrder(u, "stop")
			
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
			
			call TimerStart(t, TIMESTEP, true, function thistype.SnowMove)
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