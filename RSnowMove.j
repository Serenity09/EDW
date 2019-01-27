library RSnowMovement requires TimerUtils, GroupUtils
globals	
	real array RSFacing[NumberPlayers]
	//constant real MAXRSVELOCITY = 10
	
	private real TIMESTEP = .035
	private real ACCELERATION = 8.5 * TIMESTEP
endglobals

struct RSnowMovement extends array
	private static group g = null
	private static timer t = null
	
	private static method RSnowMove takes nothing returns nothing
		local group swap = NewGroup()
		local unit u
		//local real dist
		
		local integer i
		
		loop
		set u = FirstOfGroup(g)
		exitwhen u == null
			set i = GetPlayerId(GetOwningPlayer(u))
						
			set VelocityX[i] = VelocityX[i] + Cos(RSFacing[i]) * ACCELERATION
			set VelocityY[i] = VelocityY[i] + Sin(RSFacing[i]) * ACCELERATION
			
			//set dist = SquareRoot(VelocityX[i]*VelocityX[i] + VelocityY[i]*VelocityY[i])
			
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
			
			call TimerStart(t, TIMESTEP, true, function thistype.RSnowMove)
		endif
		
		set RSFacing[GetPlayerId(GetOwningPlayer(u))] = GetUnitFacing(u) * bj_DEGTORAD
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

