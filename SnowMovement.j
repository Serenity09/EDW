library SnowMovement requires MazerGlobals, SkatingGlobals, TimerUtils, SimpleList

globals
    private constant real TIMESTEP = 0.035
    
    private constant real OPPOSITION_BONUS = 1.5
    private constant real ACCELERATION = 5.0000*TIMESTEP
endglobals

struct SnowMovement extends array
	private static SimpleList_List active
	private static timer t = null
	
	private static method SnowMove takes nothing returns nothing
		local SimpleList_ListNode curUser = thistype.active.first
		local unit u
		local integer i

		local real x
		local real y
		
		loop
		exitwhen curUser == 0
			set i = curUser.value
			set u = User(curUser.value).ActiveUnit
			
			set x = Cos(GetUnitFacing(u)*bj_DEGTORAD)
			set y = Sin(GetUnitFacing(u)*bj_DEGTORAD)
			
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
		
		set curUser = curUser.next
		endloop
		
		set u = null
	endmethod

	public static method Add takes User user returns nothing
		if thistype.active.count == 0 then
			call TimerStart(thistype.t, TIMESTEP, true, function thistype.SnowMove)
		endif
		
		call thistype.active.addEnd(user)
		
		set CanSteer[user] = true
	endmethod
	
	public static method Remove takes User user returns nothing
		call thistype.active.remove(user)
		
		if thistype.active.count == 0 then
			call PauseTimer(thistype.t)
		endif
		
		set CanSteer[user] = false
	endmethod
	
	private static method onInit takes nothing returns nothing
		set thistype.active = SimpleList_List.create()
		set thistype.t = CreateTimer()
	endmethod
endstruct

endlibrary