library isMoving requires TerrainGlobals, ORDER, SimpleList
	globals
		constant real TOLERANCE = 25
		
		//1.5 tiles
		constant real TELEPORT_MAXDISTANCE = 20
		constant real TELEPORT_EXACTDISTANCE = TERRAIN_TILE_SIZE * 3
		
		private constant string TELEPORT_MOVEMENT_FROM_FX = "Abilities\\Spells\\NightElf\\Blink\\BlinkCaster.mdl"
		private constant string TELEPORT_MOVEMENT_TO_FX = "Abilities\\Spells\\NightElf\\Blink\\BlinkTarget.mdl"
		// private constant string TELEPORT_MOVEMENT_FX = "Abilities\\Spells\\NightElf\\Blink\\BlinkTarget.mdl"
		// private constant string TELEPORT_MOVEMENT_FX = "Abilities\\Spells\\NightElf\\Blink\\BlinkCaster.mdl"
		// private constant string TELEPORT_MOVEMENT_FROM_FX = "Abilities\\Spells\\Undead\\VampiricAura\\VampiricAuraTarget.mdl"
		// private constant string TELEPORT_MOVEMENT_TO_FX = "Abilities\\Spells\\NightElf\\Starfall\\StarfallTarget.mdl"
		// private constant string TELEPORT_MOVEMENT_TO_FX = "Abilities\\Spells\\Undead\\VampiricAura\\VampiricAuraTarget.mdl"
		
		private constant boolean DEBUG_STOP_MOVEMENT = false
	endglobals
	
	struct IsMoving extends array
		private static trigger Click = CreateTrigger()
		private static trigger StopEvent = CreateTrigger()
		
		private static SimpleList_List DestinationUsers
		private static timer DestinationTimer = CreateTimer()
		
		private static method stopCallback takes nothing returns nothing
			local timer t = GetExpiredTimer()
			local integer pID = GetTimerData(t)
			
			set isMoving[pID] = false
			call IssueImmediateOrder(MazersArray[pID], "stop")
			
			call ReleaseTimer(t)
			set t = null
		endmethod

		private static method applyTeleportMovement takes User pID returns nothing
			local real curX = GetUnitX(pID.ActiveUnit)
			local real curY = GetUnitY(pID.ActiveUnit)
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
			
			call DestroyEffect(AddSpecialEffect(TELEPORT_MOVEMENT_FROM_FX, GetUnitX(pID.ActiveUnit), GetUnitY(pID.ActiveUnit)))
			// call CreateInstantSpecialEffect(TELEPORT_MOVEMENT_FX, GetUnitX(pID.ActiveUnit), GetUnitY(pID.ActiveUnit), Player(pID))
			call SetUnitPosition(pID.ActiveUnit, curX + deltaX, curY + deltaY)
			call DestroyEffect(AddSpecialEffect(TELEPORT_MOVEMENT_TO_FX, GetUnitX(pID.ActiveUnit), GetUnitY(pID.ActiveUnit)))
			//call SetUnitX(u, OrderDestinationX[i] - x)
			//call SetUnitY(u, OrderDestinationY[i] - y)
			
			call TimerStart(NewTimerEx(pID), 0.0, false, function thistype.stopCallback)
		endmethod
		
		private static method moves takes nothing returns nothing
			local integer i = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
			
			set isMoving[i] = true
			set OrderDestinationX[i] = GetOrderPointX()
			set OrderDestinationY[i] = GetOrderPointY()
			
			if UseTeleportMovement[i] then        
				call thistype.applyTeleportMovement(i)
			endif
			
			//call DisplayTextToForce(bj_FORCE_PLAYER[0], "MOVING")
		endmethod

		private static method stops takes nothing returns nothing
			if GetIssuedOrderId() == ORDER_stop then
				set isMoving[GetPlayerId(GetOwningPlayer(GetOrderedUnit()))] = false
				
				static if DEBUG_STOP_MOVEMENT then
					call DisplayTextToForce(bj_FORCE_PLAYER[0], "Unit stopped via order")
				endif
			endif
		endmethod

		private static method checkDestination takes nothing returns nothing
			local group tempGroup = NewGroup()
			local SimpleList_ListNode curUserNode = DestinationUsers.first
			local User user
			loop
			exitwhen curUserNode == 0
				set user = User(curUserNode.value)
				if isMoving[user] and ((RAbsBJ(OrderDestinationX[user] - GetUnitX(user.ActiveUnit)) < TOLERANCE) and (RAbsBJ(OrderDestinationY[user] - GetUnitY(user.ActiveUnit)) < TOLERANCE)) then
					set isMoving[user] = false
					call IssueImmediateOrder(user.ActiveUnit, "stop")
					//call DisplayTextToForce(bj_FORCE_PLAYER[0], "NOT MOVING")
					
					static if DEBUG_STOP_MOVEMENT then
						call DisplayTextToForce(bj_FORCE_PLAYER[0], "Unit stopped via destination arrival")
					endif
				endif
			
			set curUserNode = curUserNode.next
			endloop
		endmethod

		public static method Add takes User user returns nothing
			if DestinationUsers.count == 0 then
				call TimerStart(DestinationTimer, .1, true, function thistype.checkDestination)
			endif
			
			call DestinationUsers.addEnd(user)
			
			//check if unit is moving currently, set initial value for isMoving appropriately
			if GetUnitCurrentOrder(user.ActiveUnit) == OrderId("none") or GetUnitCurrentOrder(user.ActiveUnit) == OrderId("stop") then
				set isMoving[user] = false
			else
				set isMoving[user] = true
			endif
		endmethod
		public static method Remove takes User user returns nothing
			call DestinationUsers.remove(user)
			
			if DestinationUsers.count == 0 then
				call PauseTimer(DestinationTimer)
			endif
		endmethod
		
		private static method onInit takes nothing returns nothing
			set thistype.DestinationUsers = SimpleList_List.create()
		
			call TriggerAddAction(thistype.Click, function thistype.moves)
			call TriggerAddAction(thistype.StopEvent, function thistype.stops)
		endmethod
		
		public static method RegisterMazingClickEvents takes integer pID returns nothing
			//click event
			call TriggerRegisterUnitEvent(thistype.Click, MazersArray[pID], EVENT_UNIT_ISSUED_TARGET_ORDER)
			call TriggerRegisterUnitEvent(thistype.Click, MazersArray[pID], EVENT_UNIT_ISSUED_POINT_ORDER)
			
			//stop event
			call TriggerRegisterUnitEvent(thistype.StopEvent, MazersArray[pID], EVENT_UNIT_ISSUED_ORDER)
		endmethod
	endstruct
endlibrary