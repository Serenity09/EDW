library SandMovement requires MazerGlobals, SkatingGlobals, GroupUtils

globals
    private constant real TIMESTEP = .035
    private constant real ACCELERATION = 5.75*TIMESTEP
	private constant real FALLOFF = 1.05
	
	public constant real MOVESPEED = 200
endglobals

struct SandMovement extends array
	private static group g = null
	private static timer t = null
	
	private static method SandMove takes nothing returns nothing
		local group swap = NewGroup()
		local unit u = GetEnumUnit()
		
		local integer i
		local real facingRad
		
		loop
		set u = FirstOfGroup(g)
		exitwhen u == null
			set i = GetPlayerId(GetOwningPlayer(u))
			set facingRad = (GetUnitFacing(u)/180)*bj_PI
			
			if isMoving[i] then
				set VelocityX[i] = VelocityX[i] + Cos(facingRad) * ACCELERATION
				set VelocityY[i] = VelocityY[i] + Sin(facingRad) * ACCELERATION
			else
				set VelocityX[i] = VelocityX[i] / FALLOFF
				set VelocityY[i] = VelocityY[i] / FALLOFF
			endif
			
			call SetUnitX(u, GetUnitX(u) + VelocityX[i])
			call SetUnitY(u, GetUnitY(u) + VelocityY[i])
			
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
			
			call TimerStart(t, TIMESTEP, true, function thistype.SandMove)
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