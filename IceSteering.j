library IceSteering
globals
	private trigger t = CreateTrigger()
endglobals

function ControlledSteering takes nothing returns boolean
    local integer i = GetPlayerId(GetTriggerPlayer())
        
    if CanSteer[i] then        
        call SetUnitFacingTimed(MazersArray[i], (bj_RADTODEG * Atan2(GetOrderPointY() - GetUnitY(MazersArray[i]), GetOrderPointX() - GetUnitX(MazersArray[i]))), 0)
    endif
	
	return false
endfunction

//===========================================================================
function InitTrig_Steering takes nothing returns nothing
    local integer i = 0
    //set gg_trg_Steering = CreateTrigger()
    loop
    exitwhen i >= NumberPlayers
        call TriggerRegisterPlayerUnitEvent(t, Player(i), EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, Filter(function ControlledSteering))
        set i = i + 1
    endloop
    //call TriggerAddCondition(t, function ControlledSteering)
endfunction

endlibrary