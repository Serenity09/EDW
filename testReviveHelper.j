library testReviveHelper initializer init requires TerrainHelpers, Alloc, Vector2
globals
	private unit TestUnit
endglobals

private struct unitWrapper extends array
    implement Alloc
    
    unit u
endstruct

private function testReviveCleanup takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local unitWrapper wrapped = unitWrapper(GetTimerData(t))
    local unit u = wrapped.u

    call RemoveUnit(u)

    call ReleaseTimer(t)
    call wrapped.deallocate()
    
    set t = null
    set u = null
endfunction

private function testRevive takes nothing returns nothing
    local real x
    local real y
    local real facing
    local integer testGameMode
    
    local vector2 safeLocation
    local unit reviveUnit
    local unitWrapper wrappedUnit
    
    local timer t
    
    set x = GetUnitX(TestUnit)
    set y = GetUnitY(TestUnit)
    set facing = GetUnitFacing(TestUnit)
    set testGameMode = Teams_GAMEMODE_STANDARD
    
    set safeLocation = TerrainHelpers_TryGetLastValidLocation(x, y, facing, testGameMode)
    set reviveUnit = CreateUnit(Player(10), TEAM_REVIVE_UNIT_ID, safeLocation.x, safeLocation.y, 0)
    set wrappedUnit = unitWrapper.allocate()
    set wrappedUnit.u = reviveUnit
    
    set t = NewTimerEx(wrappedUnit)
    call TimerStart(t, 2, false, function testReviveCleanup)
endfunction

//===========================================================================
private function init takes nothing returns nothing
    local trigger t
	
	if CONFIGURATION_PROFILE != RELEASE then
		set TestUnit = CreateUnit(Player(0), 'Edem', -12545, 13064, 0)
		
		set t = CreateTrigger()
		call TriggerRegisterPlayerChatEvent(t, Player(0), "-revivecircle", true)
		call TriggerRegisterPlayerChatEvent(t, Player(0), "-rc", true)
		call TriggerAddAction(t, function testRevive)
		
		set t = null
	endif
endfunction

endlibrary