library IceMovement initializer Init requires MazerGlobals

globals
    constant real DEGREE_TO_RADIANS = 0.01745
    
    private SimpleList_List l
    private timer t
    private constant real TIMEOUT = .035
    
    private constant real VELOCITY_FALLOFF = 1
    private constant real VELOCITY_CUTOFF = VELOCITY_FALLOFF + .5
endglobals

function AdvancedIceMovement takes nothing returns nothing
//    local unit u = GetEnumUnit()
//    local real x = GetUnitX(u)
//    local real y = GetUnitY(u)
//    local integer i = GetPlayerId(GetOwningPlayer(u))
    local SimpleList_ListNode cur = l.first
    local unit u
    local integer i 
    
    loop
    exitwhen cur == 0
    set i = cur.value
    set u = MazersArray[i]
    
        //call DisplayTextToForce(bj_FORCE_PLAYER[i], "P" + I2S(i) + " Is On Ice")
        //call DisplayTextToForce(bj_FORCE_PLAYER[i], "With Speed: " + R2S(SkateSpeed[i]))
        
        
        //decrement remaining velocity, if any
        if VelocityX[i] != 0 then
            if VelocityX[i] > 0 then
                if VelocityX[i] < VELOCITY_CUTOFF then
                    set VelocityX[i] = 0
                else
                    set VelocityX[i] = VelocityX[i] - VELOCITY_FALLOFF
                endif
            else
                if VelocityX[i] > -VELOCITY_CUTOFF then
                    set VelocityX[i] = 0
                else
                    set VelocityX[i] = VelocityX[i] + VELOCITY_FALLOFF
                endif
            endif
        endif
        if VelocityY[i] != 0 then
            if VelocityY[i] > 0 then
                if VelocityY[i] < VELOCITY_CUTOFF then
                    set VelocityY[i] = 0
                else
                    set VelocityY[i] = VelocityY[i] - VELOCITY_FALLOFF
                endif
            else
                if VelocityY[i] > -VELOCITY_CUTOFF then
                    set VelocityY[i] = 0
                else
                    set VelocityY[i] = VelocityY[i] + VELOCITY_FALLOFF
                endif
            endif
        endif
        
//        if VelocityX[i] != 0 then
//            if (VelocityX[i] > 0 and VelocityX[i] < VELOCITY_CUTOFF) or (VelocityX[i] < 0 and VelocityX[i] > -VELOCITY_CUTOFF) then
//                set VelocityX[i] = 0
//            else
//                set VelocityX[i] = VelocityX[i] / VELOCITY_FALLOFF
//            endif
//        endif
//        if VelocityY[i] != 0 then
//            if (VelocityY[i] > 0 and VelocityY[i] < VELOCITY_CUTOFF) or (VelocityY[i] < 0 and VelocityY[i] > -VELOCITY_CUTOFF) then
//                set VelocityY[i] = 0
//            else
//                set VelocityY[i] = VelocityY[i] / VELOCITY_FALLOFF
//            endif
//        endif
//        
        //physically move the unit
        call SetUnitX(u, GetUnitX(u) + VelocityX[i] + SkateSpeed[i] * Cos(GetUnitFacing(u) * DEGREE_TO_RADIANS))
        call SetUnitY(u, GetUnitY(u) + VelocityY[i] + SkateSpeed[i] * Sin(GetUnitFacing(u) * DEGREE_TO_RADIANS))
        call IssueImmediateOrder(u, "stop")
    
    set cur = cur.next
    endloop
    
    set u = null
endfunction

//function AdvancedIceMovementInit takes nothing returns nothing
//    call ForGroup(OnIceGroup, function AdvancedIceMovement)
//endfunction
//
public function Remove takes integer pID returns nothing
    call l.remove(pID)
    
    if l.count == 0 then
        call PauseTimer(t)
    endif
endfunction

public function Add takes integer pID returns nothing
    call l.addEnd(pID)
    
    if l.count == 1 then
        call TimerStart(t, TIMEOUT, true, function AdvancedIceMovement)
    endif
endfunction

public function Init takes nothing returns nothing
    set l = SimpleList_List.create()
    set t = CreateTimer()
endfunction

//===========================================================================
//function InitTrig_Ice_Movement_Advanced takes nothing returns nothing
//    set gg_trg_Ice_Movement_Advanced = CreateTrigger(  )
//    call TriggerRegisterTimerEvent( gg_trg_Ice_Movement_Advanced, 0.035, true)
//    call TriggerAddAction( gg_trg_Ice_Movement_Advanced, function AdvancedIceMovementInit)
//endfunction
//
endlibrary