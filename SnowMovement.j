library SnowMovement requires MazerGlobals, SkatingGlobals, TimerUtils, SimpleList

globals
    private constant real TIMESTEP = 0.035
    
    private constant real OPPOSITION_BONUS = 1.5
    private constant real ACCELERATION = 5.0000*TIMESTEP
	
	private constant real FALLOFF_LOWER = 0.275
	private constant real FALLOFF_UPPER = 0.8
	
	private constant boolean DEBUG_VELOCITY = false
	private constant boolean DEBUG_V2 = false
endglobals

struct SnowMovement extends array
	private static SimpleList_List active
	private static timer t = null
	
	private static method SnowMove takes nothing returns nothing
		local SimpleList_ListNode curUser = thistype.active.first
		local unit u
		local integer i

		local real facing
		local real x
		local real y
		
		local real angleUV
		local real falloffFactor
		
		loop
		exitwhen curUser == 0
			set i = curUser.value
			set u = User(curUser.value).ActiveUnit
			
			set facing = GetUnitFacing(u) * bj_DEGTORAD
			set x = Cos(facing)
			set y = Sin(facing)
			
			set angleUV = Atan2(VelocityX[i]*y - VelocityY[i]*x, VelocityX[i]*x + VelocityY[i]*y)
			set falloffFactor = RAbsBJ(Sin(angleUV))*(FALLOFF_UPPER - FALLOFF_LOWER) + FALLOFF_LOWER
			
			set VelocityX[i] = VelocityX[i] - TIMESTEP * falloffFactor * VelocityX[i] + x * ACCELERATION
			set VelocityY[i] = VelocityY[i] - TIMESTEP * falloffFactor * VelocityY[i] + y * ACCELERATION
			
			static if DEBUG_VELOCITY then
				call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Velocity X: " + R2S(VelocityX[i]))
				call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Velocity Y: " + R2S(VelocityY[i]))
			endif
			static if DEBUG_V2 then
				call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Angle between U and V: " + R2S(angleUV))
				call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Falloff factor: " + R2S(falloffFactor))
				call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Velocity falloff X: " + R2S(TIMESTEP * falloffFactor * VelocityX[i]))
				call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Velocity falloff Y: " + R2S(TIMESTEP * falloffFactor * VelocityY[i]))
			endif
			
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