library Snow requires MazerGlobals, SkatingGlobals

globals
    private constant real TIMESTEP = 0.035
    
    private constant real OPPOSITION_BONUS = 1.5
    private constant real ACCELERATION = 5.0000*TIMESTEP
	
	//private constant real MAXVELOCITY = 32 * TIMESTEP
endglobals

function SnowMove takes nothing returns nothing
    local unit u = GetEnumUnit()
    local real facingRad = GetUnitFacing(u)/180*bj_PI
	local real x = Cos(facingRad)
    local real y = Sin(facingRad)
    local integer i = GetPlayerId(GetOwningPlayer(u))
    
    
    /*
    if VelocityX[i] > MAXVELOCITY then
        set VelocityX[i] = MAXVELOCITY
    elseif VelocityX[i] < -MAXVELOCITY then
        set VelocityX[i] = -MAXVELOCITY
    endif
    if VelocityY[i] > MAXVELOCITY then
        set VelocityY[i] = MAXVELOCITY
    elseif VelocityY[i] < -MAXVELOCITY then
        set VelocityY[i] = -MAXVELOCITY
    endif
    */
	
	
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
    
    set u = null
endfunction

function SnowMoveInit takes nothing returns nothing
    call ForGroup(OnSnowGroup, function SnowMove)
endfunction

//===========================================================================
function InitTrig_Snow_Movement takes nothing returns nothing
    set gg_trg_Snow_Movement = CreateTrigger(  )
    call TriggerRegisterTimerEvent( gg_trg_Snow_Movement, TIMESTEP, true)
    call TriggerAddAction( gg_trg_Snow_Movement, function SnowMoveInit)
endfunction

endlibrary