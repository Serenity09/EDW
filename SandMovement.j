library SandMovement requires MazerGlobals, SkatingGlobals

globals
    private constant real TIMESTEP = .035
    private constant real ACCELERATION = 5.75*TIMESTEP
	private constant real FALLOFF = 1.05
	
	public constant real MOVESPEED = 200
endglobals

function SandMove takes nothing returns nothing
    local unit u = GetEnumUnit()
    local real x = GetUnitX(u)
    local real y = GetUnitY(u)
    local integer i = GetPlayerId(GetOwningPlayer(u))
    
    //local real x0 = OrderDestin
    
    local real facingRad = (GetUnitFacing(u)/180)*bj_PI
    
    if isMoving[i] then
        set VelocityX[i] = VelocityX[i] + Cos(facingRad) * ACCELERATION
        set VelocityY[i] = VelocityY[i] + Sin(facingRad) * ACCELERATION
    else
        set VelocityX[i] = VelocityX[i] / FALLOFF
        set VelocityY[i] = VelocityY[i] / FALLOFF
    endif
    
    call SetUnitX(u, x + VelocityX[i])
    call SetUnitY(u, y + VelocityY[i])
    
    set u = null
endfunction

function SandMoveInit takes nothing returns nothing
    call ForGroup(OnSandGroup, function SandMove)
endfunction

//===========================================================================
function InitTrig_Sand_Movement takes nothing returns nothing
    set gg_trg_Sand_Movement = CreateTrigger(  )
    call TriggerRegisterTimerEvent( gg_trg_Sand_Movement, 0.035, true )
    call TriggerAddAction( gg_trg_Sand_Movement, function SandMoveInit )
endfunction

endlibrary