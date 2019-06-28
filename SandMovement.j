library SandMovement requires MazerGlobals, SkatingGlobals, GroupUtils

globals
    private constant real TIMESTEP = .035
    private constant real ACCELERATION = 5.75*TIMESTEP
	private constant real FALLOFF = 1.05
	
	public constant real MOVESPEED = 200
endglobals

struct SandMovement extends array
	private static timer t = CreateTimer()
	
	private static SimpleList_List SandUsers
	
	private static method SandMove takes nothing returns nothing	
		local SimpleList_ListNode curUserNode = SandUsers.first
		local User user
		local real facingRad
		
		loop
		exitwhen curUserNode == 0
			set user = curUserNode.value
			set facingRad = GetUnitFacing(user.ActiveUnit) * bj_DEGTORAD
			
			if isMoving[user] then
				set VelocityX[user] = VelocityX[user] + Cos(facingRad) * ACCELERATION
				set VelocityY[user] = VelocityY[user] + Sin(facingRad) * ACCELERATION
			else
				set VelocityX[user] = VelocityX[user] / FALLOFF
				set VelocityY[user] = VelocityY[user] / FALLOFF
			endif
			
			call SetUnitX(user.ActiveUnit, GetUnitX(user.ActiveUnit) + VelocityX[user])
			call SetUnitY(user.ActiveUnit, GetUnitY(user.ActiveUnit) + VelocityY[user])
			
		set curUserNode = curUserNode.next
		endloop		
	endmethod

	public static method Add takes User user returns nothing
		//register dependencies
		call IsMoving.Add(user)
		
		//register self
		if SandUsers.count == 0 then
			call TimerStart(t, TIMESTEP, true, function thistype.SandMove)
		endif
		
		call SandUsers.addEnd(user)
	endmethod
	
	public static method Remove takes User user returns nothing
		//deregister dependencies
		call IsMoving.Remove(user)
		
		//deregister self
		call SandUsers.remove(user)
		
		if SandUsers.count == 0 then
			call PauseTimer(t)
		endif
	endmethod
	
	private static method onInit takes nothing returns nothing
		set SandUsers = SimpleList_List.create()
	endmethod
endstruct

endlibrary