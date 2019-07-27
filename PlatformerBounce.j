library PlatformerBounce requires SimpleList, Vector2, TerrainGlobals

globals
    private constant real TIMESTEP = .1500
	
	public constant string TERRAIN_SUPERBOUNCE_FX = "Abilities\\Spells\\Undead\\AnimateDead\\AnimateDeadTarget.mdl"
endglobals

struct PlatformerBounce extends array
	private static timer BounceTimer = CreateTimer()
	
	private static SimpleList_List ActivePlatformers
	
	private static method Bounce takes Platformer plat returns nothing	
		// local vector2 terrainCenter = GetTerrainCenterpoint(plat.XPosition, plat.YPosition)
			
		// //this is too inconsistent inside this loop, will need to move it out to its own timer after all...
		// if .GravitationalAccel > 0 then
			// set .YVelocity = -BOOST_SPEED
		// elseif .GravitationalAccel < 0 then
			// set .YVelocity = BOOST_SPEED
		// endif
		
		if GetTerrainType(plat.XPosition, plat.YPosition) == BOOST then
			call DestroyEffect(AddSpecialEffect(TERRAIN_SUPERBOUNCE_FX, plat.XPosition, plat.YPosition))
		endif
	endmethod
	private static method BounceCallback takes nothing returns nothing
		local SimpleList_ListNode curPlatformerNode = ActivePlatformers.first
		
		loop
		exitwhen curPlatformerNode == 0
			call Bounce(curPlatformerNode.value)
		set curPlatformerNode = curPlatformerNode.next
		endloop
	endmethod

	public static method Add takes Platformer plat returns nothing
		//register self
		if ActivePlatformers.count == 0 then
			call TimerStart(BounceTimer, TIMESTEP, true, function thistype.BounceCallback)
		endif
		
		call ActivePlatformers.addEnd(plat)
		
		//immediately bounce that shit
		call Bounce(plat)
	endmethod
	
	public static method Remove takes Platformer plat returns nothing		
		//deregister self
		call ActivePlatformers.remove(plat)
		
		if ActivePlatformers.count == 0 then
			call PauseTimer(BounceTimer)
		endif
	endmethod
	
	private static method onInit takes nothing returns nothing
		set ActivePlatformers = SimpleList_List.create()
	endmethod
endstruct

endlibrary