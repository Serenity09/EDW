library isMoving requires MazerGlobals
globals
    group DestinationGroup = CreateGroup()
    constant real TOLERANCE = 25
    trigger Click = CreateTrigger()
    trigger CheckDest = CreateTrigger()
    
    //1.5 tiles
    constant real TELEPORT_MAXDISTANCE = 20
    constant real TELEPORT_EXACTDISTANCE = TERRAIN_TILE_SIZE * 3
endglobals

private function stopCallback takes nothing returns nothing
    local timer t = GetExpiredTimer()
    local integer pID = GetTimerData(t)
    
    set isMoving[pID] = false
    call IssueImmediateOrder(MazersArray[pID], "stop")
    
    call ReleaseTimer(t)
    set t = null
endfunction

function applyTeleportMovement takes integer pID returns nothing
    local real curX = GetUnitX(MazersArray[pID])
    local real curY = GetUnitY(MazersArray[pID])
    local real deltaX = OrderDestinationX[pID] - curX
    local real deltaY = OrderDestinationY[pID] - curY
    
    local real theta = Atan2(deltaY, deltaX)
    local integer i = 1
	
    //local real dist = SquareRoot(deltaX * deltaX + deltaY * deltaY)
    
    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Teleporting with angle: " + R2S(theta * 180 / bj_PI))
    
    if (theta < 0 and theta >= -bj_PI/4) or (theta >= 0 and theta < bj_PI/4) then
        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "East")
        set deltaY = 0
		
		loop
		exitwhen i == TELEPORT_MAXDISTANCE or GetTerrainType(curX + i*TERRAIN_TILE_SIZE, curY) != ABYSS
		set i = i + 1
		endloop
        set deltaX = i*TERRAIN_TILE_SIZE
    elseif theta >= bj_PI/4 and theta < bj_PI * 3/4 then
        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "North")
        loop
		exitwhen i == TELEPORT_MAXDISTANCE or GetTerrainType(curX, curY + i*TERRAIN_TILE_SIZE) != ABYSS
		set i = i + 1
		endloop
        set deltaY = i*TERRAIN_TILE_SIZE
		
		set deltaX = 0
    elseif (theta < 0 and theta < -bj_PI * 3/4) or (theta >= 0 and theta >= bj_PI * 3/4) then
        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "West")
        set deltaY = 0
        
		loop
		exitwhen i == TELEPORT_MAXDISTANCE or GetTerrainType(curX - i*TERRAIN_TILE_SIZE, curY) != ABYSS
		set i = i + 1
		endloop
        set deltaX = -i*TERRAIN_TILE_SIZE
    else//if theta >= -bj_PI * 3/4 and theta < -bj_PI/4 then
        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "South")
        loop
		exitwhen i == TELEPORT_MAXDISTANCE or GetTerrainType(curX, curY - i*TERRAIN_TILE_SIZE) != ABYSS
		set i = i + 1
		endloop
        set deltaY = -i*TERRAIN_TILE_SIZE
		
        set deltaX = 0
    endif
    
    call SetUnitPosition(MazersArray[pID], curX + deltaX, curY + deltaY)
    //call SetUnitX(u, OrderDestinationX[i] - x)
    //call SetUnitY(u, OrderDestinationY[i] - y)
    
    call TimerStart(NewTimerEx(pID), 0.0, false, function stopCallback)
endfunction

function moves takes nothing returns nothing
    local unit u = GetTriggerUnit()
    local integer i = GetPlayerId(GetOwningPlayer(u))
    
    
    set isMoving[i] = true
    set OrderDestinationX[i] = GetOrderPointX()
    set OrderDestinationY[i] = GetOrderPointY()
    
    if UseTeleportMovement[i] then        
        call applyTeleportMovement(i)
    endif
    
    set u = null
    //call DisplayTextToForce(bj_FORCE_PLAYER[0], "MOVING")
endfunction

function checkDest takes nothing returns nothing
    local unit u = GetEnumUnit()
    local integer i = GetPlayerId(GetOwningPlayer(u))
    local real x = GetUnitX(u)
    local real y = GetUnitY(u)
    if ((RAbsBJ(OrderDestinationX[i] - x) < TOLERANCE) and (RAbsBJ(OrderDestinationY[i] - y) < TOLERANCE)) then
        set isMoving[i] = false
        call IssueImmediateOrder(u, "stop")
        //call DisplayTextToForce(bj_FORCE_PLAYER[0], "NOT MOVING")
    endif
	
    set u = null
endfunction

function checkDestInit takes nothing returns nothing
    call ForGroup(DestinationGroup, function checkDest)
endfunction
/*
function registerUnits takes nothing returns nothing
    local integer i = 0
    //call DisplayTextToForce(bj_FORCE_PLAYER[0], "Registering")
    
    loop
    exitwhen i > NumberPlayers
        call TriggerRegisterUnitEvent(Click, MazersArray[i], EVENT_UNIT_ISSUED_TARGET_ORDER)
        call TriggerRegisterUnitEvent(Click, MazersArray[i], EVENT_UNIT_ISSUED_POINT_ORDER)
        //call DisplayTextToForce(bj_FORCE_PLAYER[0], I2S(i))
        set i = i + 1
    endloop
    
    call TriggerAddAction(Click, function moves)
    //call DisplayTextToForce(bj_FORCE_PLAYER[0], "Finished Registering")
endfunction
*/

//===========================================================================
function InitTrig_isMoving takes nothing returns nothing
    //local trigger move1 = CreateTrigger()
    
    //call TriggerRegisterUnitEvent( move1, gg_unit_Edem_0001, EVENT_UNIT_ISSUED_TARGET_ORDER )
    //call TriggerRegisterUnitEvent( move1, gg_unit_Edem_0001, EVENT_UNIT_ISSUED_POINT_ORDER )
    //call TriggerAddAction( move1, function moves )    
    
    call TriggerAddAction(CheckDest, function checkDestInit)
    call TriggerRegisterTimerEvent(CheckDest, .1, true)
    
    call TriggerAddAction(Click, function moves)
    
    //set move1 = null
    //set stop1 = null
endfunction
endlibrary