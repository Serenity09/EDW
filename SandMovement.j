library SandMovement requires MazerGlobals, SkatingGlobals, GroupUtils

globals
    private constant real TIMESTEP = .035
    private constant real ACCELERATION = 5.75*TIMESTEP
	private constant real FALLOFF = 1.05
	
	private constant real FX_TIMESTEP = .75
	
	public constant real MOVESPEED = 200
	
	constant string SAND_MOVEMENT_FX = "war3mapImported\\SlidingDust.mdx"
	constant real SAND_FX_THRESHOLD_START = 7.
	constant real SAND_FX_THRESHOLD_STOP = 1.5
endglobals

struct SandMovement extends array
	private static timer MovementTimer = CreateTimer()
	private static timer FXTimer = CreateTimer()
	
	private static SimpleList_List SandUsers
	
	private static method SandFX takes nothing returns nothing
		local SimpleList_ListNode curUserNode = SandUsers.first
		local real speed
		
		loop
		exitwhen curUserNode == 0
			set speed = SquareRoot(VelocityX[User(curUserNode.value)]*VelocityX[User(curUserNode.value)] + VelocityY[User(curUserNode.value)]*VelocityY[User(curUserNode.value)])
			if User(curUserNode.value).ActiveEffect == null and speed >= SAND_FX_THRESHOLD_START then
				call User(curUserNode.value).SetActiveEffect(SAND_MOVEMENT_FX, "origin")
			elseif User(curUserNode.value).ActiveEffect != null and speed <= SAND_FX_THRESHOLD_STOP then
				call User(curUserNode.value).ClearActiveEffect()
			endif
		set curUserNode = curUserNode.next
		endloop	
	endmethod
	private static method SandMove takes nothing returns nothing	
		local SimpleList_ListNode curUserNode = SandUsers.first
		local User user
		local real facingRad
		
		loop
		exitwhen curUserNode == 0
			set user = curUserNode.value
			
			if isMoving[user] then
				set facingRad = GetUnitFacing(user.ActiveUnit) * bj_DEGTORAD
				
				set VelocityX[user] = VelocityX[user] + Cos(facingRad) * ACCELERATION
				set VelocityY[user] = VelocityY[user] + Sin(facingRad) * ACCELERATION
			else
				set VelocityX[user] = VelocityX[user] / FALLOFF
				set VelocityY[user] = VelocityY[user] / FALLOFF
			endif
			
			call SetUnitX(user.ActiveUnit, GetUnitX(user.ActiveUnit) + VelocityX[user])
			call SetUnitY(user.ActiveUnit, GetUnitY(user.ActiveUnit) + VelocityY[user])
			
			// //reuse facingRad
			// set facingRad = SquareRoot(VelocityX[user]*VelocityX[user] + VelocityY[user]*VelocityY[user])
			// if user.ActiveEffect == null and facingRad >= SAND_FX_THRESHOLD_START then
				// call user.SetActiveEffect(SAND_MOVEMENT_FX, "origin")
			// elseif user.ActiveEffect != null and facingRad <= SAND_FX_THRESHOLD_STOP then
				// call user.ClearActiveEffect()
			// endif
		set curUserNode = curUserNode.next
		endloop		
	endmethod

	public static method Add takes User user returns nothing
		//register dependencies
		call IsMoving.Add(user)
		
		//register self
		if SandUsers.count == 0 then
			call TimerStart(MovementTimer, TIMESTEP, true, function thistype.SandMove)
			call TimerStart(FXTimer, FX_TIMESTEP, true, function thistype.SandFX)
		endif
		
		call SandUsers.addEnd(user)
	endmethod
	
	public static method Remove takes User user returns nothing
		//deregister dependencies
		call IsMoving.Remove(user)
		
		//deregister self
		call SandUsers.remove(user)
		
		if SandUsers.count == 0 then
			call PauseTimer(MovementTimer)
			call PauseTimer(FXTimer)
		endif
	endmethod
	
	private static method onInit takes nothing returns nothing
		set SandUsers = SimpleList_List.create()
	endmethod
endstruct

endlibrary