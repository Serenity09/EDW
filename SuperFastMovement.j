library SuperFastMovement requires SandMovement, isMoving, TimerUtils, GroupUtils
globals
    constant real SuperFastSpeed = 10
	private real TIMESTEP = .035
endglobals

struct SuperFastMovement extends array
	private static SimpleList_List SuperFastUsers
	private static timer t = CreateTimer()
	
	private static method FastMove takes nothing returns nothing
		local SimpleList_ListNode curUserNode = SuperFastUsers.first
		local unit u
		local real facingRad
		
		loop
		exitwhen curUserNode == 0
			if isMoving[curUserNode.value] then
				set u = User(curUserNode.value).ActiveUnit
				set facingRad = GetUnitFacing(u) * bj_DEGTORAD
				
				call SetUnitX(u, GetUnitX(u) + Cos(facingRad) * SuperFastSpeed)
				call SetUnitY(u, GetUnitY(u) + Sin(facingRad) * SuperFastSpeed)
			endif
		set curUserNode = curUserNode.next
		endloop		
	endmethod

	public static method Add takes User user returns nothing
		if SuperFastUsers.count == 0 then
			call TimerStart(thistype.t, TIMESTEP, true, function thistype.FastMove)
		endif
		
		call SuperFastUsers.addEnd(user)
		call IsMoving.Add(user)
	endmethod
	
	public static method Remove takes User user returns nothing
		call SuperFastUsers.remove(user)
		call IsMoving.Remove(user)
		
		if SuperFastUsers.count == 0 then
			call PauseTimer(thistype.t)
		endif
	endmethod
	
	private static method onInit takes nothing returns nothing
		set SuperFastUsers = SimpleList_List.create()
	endmethod
endstruct

endlibrary