library IceSteering initializer Init requires SkatingGlobals

private function ControlledSteering takes nothing returns boolean
    local integer i = GetPlayerId(GetTriggerPlayer())
    	
    if CanSteer[i] then        
        call SetUnitFacingTimed(MazersArray[i], (bj_RADTODEG * Atan2(GetOrderPointY() - GetUnitY(MazersArray[i]), GetOrderPointX() - GetUnitX(MazersArray[i]))), 0)
    endif
	
	return false
endfunction

//===========================================================================
private function Init takes nothing returns nothing
    local trigger t = CreateTrigger()
	local integer i = 0
	
    loop
    exitwhen i >= NumberPlayers
        call TriggerRegisterPlayerUnitEvent(t, Player(i), EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, null)
        set i = i + 1
    endloop
    call TriggerAddCondition(t, Condition(function ControlledSteering))
	
	set t = null
endfunction

endlibrary