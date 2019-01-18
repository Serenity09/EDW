library isMoving requires TerrainGlobals, ORDER
globals
    group DestinationGroup = CreateGroup()
    constant real TOLERANCE = 25
    trigger Click = CreateTrigger()
	trigger StopEvent = CreateTrigger()
	
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

function stops takes nothing returns nothing
	if GetIssuedOrderId() == ORDER_stop then
		set isMoving[GetPlayerId(GetOwningPlayer(GetOrderedUnit()))] = true
	endif
	
	//call DisplayTextToForce(bj_FORCE_PLAYER[0], "Order ID " + I2S(orderID) + " name " + OrderId2String(orderID))
endfunction

function checkDestination takes nothing returns nothing
	local group tempGroup = NewGroup()
	local unit u
	local integer i
	loop
	set u = FirstOfGroup(DestinationGroup)
	exitwhen u == null
		set i = GetPlayerId(GetOwningPlayer(u))
		if ((RAbsBJ(OrderDestinationX[i] - GetUnitX(u)) < TOLERANCE) and (RAbsBJ(OrderDestinationY[i] - GetUnitY(u)) < TOLERANCE)) then
			set isMoving[i] = false
			call IssueImmediateOrder(u, "stop")
			//call DisplayTextToForce(bj_FORCE_PLAYER[0], "NOT MOVING")
		endif
		
		call GroupAddUnit(tempGroup, u)
		call GroupRemoveUnit(DestinationGroup, u)
	endloop
	
	call ReleaseGroup(DestinationGroup)
	set DestinationGroup = tempGroup
endfunction

function RegisterMazingClickEvents takes integer pID returns nothing
	//click event
	call TriggerRegisterUnitEvent(Click, MazersArray[pID], EVENT_UNIT_ISSUED_TARGET_ORDER)
	call TriggerRegisterUnitEvent(Click, MazersArray[pID], EVENT_UNIT_ISSUED_POINT_ORDER)
	
	//stop event
	call TriggerRegisterUnitEvent(StopEvent, MazersArray[pID], EVENT_UNIT_ISSUED_ORDER)
endfunction

//===========================================================================
function InitTrig_isMoving takes nothing returns nothing
	call TriggerAddAction(Click, function moves)
	call TriggerAddAction(StopEvent, function stops)
    
	call TimerStart(CreateTimer(), .1, true, function checkDestination)
endfunction
endlibrary