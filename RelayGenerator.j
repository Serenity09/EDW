library RelayGenerator requires GameGlobalConstants, SimpleList, Table, Vector2, TimerUtils, Recycle, locust, Alloc, Draw, IStartable
    globals
        private constant real RELAY_TURN_CHECK_TIMESTEP = .1
        
        private constant integer RELAY_PLAYER = 10
        
        //these have to be opposite for functionality to work, and it'll be faster if they're set this way to make computations off of (always interested in inverse)
        private constant integer LEFT = 1
        private constant integer RIGHT = -1
        private constant integer DOWN = 1
        private constant integer UP = -1
        
        //all of these can be made instance variables for more flexibility
        private constant real UNIT_DESTINATION_BUFFER = TERRAIN_QUADRANT_SIZE / 4.
        private constant integer UNIT_SIDE_BUFFER = 0
        
        //has to be around 64 or the bot left corner of rect won't register units
        private constant real TURN_RECT_BUFFER = TERRAIN_TILE_SIZE
    endglobals
    
    struct RelayUnit extends array
        //public unit Unit
        //public RelayGenerator Parent
        public integer LaneNumber
        public SimpleList_ListNode CurrentTurn
        
        implement Alloc
        
        public static method create takes integer lane, SimpleList_ListNode firstTurn returns thistype
            local thistype new = thistype.allocate()
            
            set new.LaneNumber = lane
            set new.CurrentTurn = firstTurn
            
            return new
        endmethod
    endstruct
    
    struct RelayTurn extends array
        //public vector2 FirstLaneRelative
        public vector2 FirstLane
        public integer FirstLaneX
        public integer FirstLaneY
        public integer Direction
        public real Distance
        
        public vector2 Center
        public rect Area
        
        implement Alloc
        
        public method DrawCorner takes nothing returns nothing
            
        endmethod
        
        public static method create takes rect area, vector2 center, RelayGenerator generator, integer direction, real distance, integer firstX, integer firstY returns thistype
            local thistype new = thistype.allocate()
            local vector2 firstLane
            
            set new.Direction = direction
            set new.Distance = distance
            set new.Area = area
            set new.Center = center
            
            set new.FirstLaneX = firstX
            set new.FirstLaneY = firstY
            
            //set new.FirstLaneRelative = vector2.create(firstX, firstY)
            set firstLane = vector2.create(center.x, center.y)
            if firstX == LEFT then
				if ModuloInteger(generator.Diameter, 2) == 0 then
					set firstLane.x = firstLane.x - generator.GetRadius()*TERRAIN_TILE_SIZE + TERRAIN_QUADRANT_SIZE + UNIT_SIDE_BUFFER*generator.UnitLaneSize
				else
					set firstLane.x = firstLane.x - generator.GetRadius()*TERRAIN_TILE_SIZE + UNIT_SIDE_BUFFER*generator.UnitLaneSize
				endif
            else
				if ModuloInteger(generator.Diameter, 2) == 0 then
					set firstLane.x = firstLane.x + generator.GetRadius()*TERRAIN_TILE_SIZE - TERRAIN_QUADRANT_SIZE - UNIT_SIDE_BUFFER*generator.UnitLaneSize
				else
					set firstLane.x = firstLane.x + generator.GetRadius()*TERRAIN_TILE_SIZE - UNIT_SIDE_BUFFER*generator.UnitLaneSize
				endif
                
            endif
            
            if firstY == DOWN then
                if ModuloInteger(generator.Diameter, 2) == 0 then
					set firstLane.y = firstLane.y - generator.GetRadius()*TERRAIN_TILE_SIZE + TERRAIN_QUADRANT_SIZE + UNIT_SIDE_BUFFER*generator.UnitLaneSize
				else
					set firstLane.y = firstLane.y - generator.GetRadius()*TERRAIN_TILE_SIZE + UNIT_SIDE_BUFFER*generator.UnitLaneSize
				endif
            else
                if ModuloInteger(generator.Diameter, 2) == 0 then
					set firstLane.y = firstLane.y + generator.GetRadius()*TERRAIN_TILE_SIZE - TERRAIN_QUADRANT_SIZE - UNIT_SIDE_BUFFER*generator.UnitLaneSize
				else
					set firstLane.y = firstLane.y + generator.GetRadius()*TERRAIN_TILE_SIZE - UNIT_SIDE_BUFFER*generator.UnitLaneSize
				endif
            endif
            set new.FirstLane = firstLane
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "First lane: " + new.FirstLane.toString())
            
            //debug call Draw_DrawRegion(area, 0)
            //debug call CreateUnit(Player(RELAY_PLAYER), DEBUG_UNIT, new.Center.x, new.Center.y, 0)
            //debug call CreateUnit(Player(0), DEBUG_UNIT, new.FirstLane.x, new.FirstLane.y, 0)
            
            return new
        endmethod
    endstruct
    
    struct RelayGenerator extends IStartable
        public RelayPatternSpawn SpawnPattern
		public vector2 SpawnCenter
		public integer Diameter
        //public real Radius //in whole tile units
        
        public real UnitLaneSize
        public static integer array UnitIDToRelayUnitID //links unit ID to RelayUnit struct ID (UnitIDToRelayUnitID[UnitID] = RelayUnit struct ID)
        private real UnitTimeout
        private timer UnitTimer
		
		private group Units
        
        public SimpleList_List Turns
        
        public static SimpleList_List ActiveRelays
        
        private static timer TurnTimer
        
        //implement Alloc
        
        static if DEBUG_MODE then
            public method DrawTurns takes nothing returns nothing
                local SimpleList_ListNode turnNode = this.Turns.first
                local RelayTurn turn
                
                loop
                exitwhen turnNode == 0
                    set turn = turnNode.value
                    
                    debug call Draw_DrawRegion(turn.Area, 0)
                    debug call CreateUnit(Player(RELAY_PLAYER), DEBUG_UNIT, turn.Center.x, turn.Center.y, 0)
                    debug call CreateUnit(Player(0), DEBUG_UNIT, turn.FirstLane.x, turn.FirstLane.y, 0)
                set turnNode = turnNode.next
                endloop
            endmethod            
        endif
        
        public method ToString takes nothing returns string
            return "Unit Lane Size: " + R2S(.UnitLaneSize) + ", radius: " + R2S(.GetRadius()) + ", number lanes: " + I2S(.GetNumberLanes())
        endmethod
        
		public method GetNumberLanes takes nothing returns integer
            //number lanes in a single tile = tile-size / lane-offset
            //number lanes total = lanes-single * spawn-diameter
            return R2I(this.Diameter*TERRAIN_TILE_SIZE/.UnitLaneSize) - UNIT_SIDE_BUFFER*2
        endmethod
		public method GetRadius takes nothing returns integer
			return R2I(this.Diameter / 2.)
		endmethod
		
        //register the rect that matches the final turn's destination under a remove unit timer event
        public method EndTurns takes integer endDirection returns nothing
            call this.AddTurnSimple(endDirection, 0)
        endmethod
        
        //rect area needs to be in a legal position relative to the last turn's center, and combination of newDirection and newDistance needs to get a unit from their last rect to this one
        public method AddTurn takes rect area, vector2 center, integer newDirection, real newDistance returns nothing
            //nextTurn.flipped = 
            local RelayTurn turn
            local RelayTurn lastTurn = RelayTurn(Turns.last.value)
            
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Last turn ID " + I2S(Turns.last.value))
                        
            //check if turning 90 degrees
            if ((lastTurn.Direction == 0 or lastTurn.Direction == 180) and (newDirection == 90 or newDirection == 270)) or ((lastTurn.Direction == 90 or lastTurn.Direction == 270) and (newDirection == 0 or newDirection == 180)) then
                if newDirection == 90 then
                    if lastTurn.Direction == 0 then
                        //right -> up
                        if lastTurn.FirstLaneY == UP then
                            set turn = RelayTurn.create(area, center, this, newDirection, newDistance, LEFT, UP)
                        else //lastTurn.FirstLaneY == BOTTOM
                            set turn = RelayTurn.create(area, center, this, newDirection, newDistance, RIGHT, DOWN)
                        endif
                    else //lastTurn.Direction == 180
                        //left -> up
                        if lastTurn.FirstLaneY == UP then
                            set turn = RelayTurn.create(area, center, this, newDirection, newDistance, RIGHT, UP)
                        else //lastTurn.FirstLaneY == BOTTOM
                            set turn = RelayTurn.create(area, center, this, newDirection, newDistance, LEFT, DOWN)
                        endif
                    endif
                elseif newDirection == 270 then
                    if lastTurn.Direction == 0 then
                        //right -> down
                        if lastTurn.FirstLaneY == UP then
                            set turn = RelayTurn.create(area, center, this, newDirection, newDistance, RIGHT, UP)
                        else //lastTurn.FirstLaneY == BOTTOM
                            set turn = RelayTurn.create(area, center, this, newDirection, newDistance, LEFT, DOWN)
                        endif
                    else //lastTurn.Direction == 180
                        //left -> down
                        if lastTurn.FirstLaneY == UP then
                            set turn = RelayTurn.create(area, center, this, newDirection, newDistance, LEFT, UP)
                        else //lastTurn.FirstLaneY == BOTTOM
                            set turn = RelayTurn.create(area, center, this, newDirection, newDistance, RIGHT, DOWN)
                        endif
                    endif
                elseif newDirection == 0 then
                    if lastTurn.Direction == 90 then
                        //up -> right
                        if lastTurn.FirstLaneX == LEFT then
                            set turn = RelayTurn.create(area, center, this, newDirection, newDistance, LEFT, UP)
                        else //lastTurn.FirstLaneX == RIGHT
                            set turn = RelayTurn.create(area, center, this, newDirection, newDistance, RIGHT, DOWN)
                        endif
                    else //lastTurn.Direction == 270
                        //down -> right
                        if lastTurn.FirstLaneX == LEFT then
                            set turn = RelayTurn.create(area, center, this, newDirection, newDistance, LEFT, DOWN)
                        else //lastTurn.FirstLaneX == RIGHT
                            set turn = RelayTurn.create(area, center, this, newDirection, newDistance, RIGHT, UP)
                        endif
                    endif
                else //newDirection == 180
                    if lastTurn.Direction == 90 then
                        //up -> left
                        if lastTurn.FirstLaneX == LEFT then
                            set turn = RelayTurn.create(area, center, this, newDirection, newDistance, LEFT, DOWN)
                        else //lastTurn.FirstLaneX == RIGHT
                            set turn = RelayTurn.create(area, center, this, newDirection, newDistance, RIGHT, UP)
                        endif
                    else //lastTurn.Direction == 270
                        //down -> left
                        if lastTurn.FirstLaneX == LEFT then
                            set turn = RelayTurn.create(area, center, this, newDirection, newDistance, LEFT, UP)
                        else //lastTurn.FirstLaneX == RIGHT
                            set turn = RelayTurn.create(area, center, this, newDirection, newDistance, RIGHT, DOWN)
                        endif
                    endif
                endif
                
            else
                //either continuing straight or doubling back -- either way, persist the unchanged part of the first lane position
                if newDirection == 0 then
                    set turn = RelayTurn.create(area, center, this, newDirection, newDistance, RIGHT, lastTurn.FirstLaneY)
                elseif newDirection == 180 then
                    set turn = RelayTurn.create(area, center, this, newDirection, newDistance, LEFT, lastTurn.FirstLaneY)
                elseif newDirection == 90 then
                    set turn = RelayTurn.create(area, center, this, newDirection, newDistance, lastTurn.FirstLaneX, UP)
                else
                    set turn = RelayTurn.create(area, center, this, newDirection, newDistance, lastTurn.FirstLaneX, DOWN)
                endif
            endif
            
            if turn != 0 then
                call this.Turns.addEnd(turn)
                
                //debug call this.Turns.print(0)
            endif
        endmethod
        
        //uses easier to provide parameters to create a guaranteed legal destination rect
        public method AddTurnSimple takes integer newDirection, integer tilesToTravel returns nothing
            local RelayTurn lastTurn = RelayTurn(Turns.last.value)
            
            //relay diameter = (LaneCount + 2) / 2
            local real radius = this.GetRadius()*TERRAIN_TILE_SIZE
            local real totalDistance = this.Diameter*TERRAIN_TILE_SIZE + tilesToTravel*TERRAIN_TILE_SIZE
            
            local real turnCenterX
            local real turnCenterY
            
            if lastTurn.Direction == 0 then
                set turnCenterX = lastTurn.Center.x + lastTurn.Distance
                set turnCenterY = lastTurn.Center.y
            elseif lastTurn.Direction == 180 then
                set turnCenterX = lastTurn.Center.x - lastTurn.Distance
                set turnCenterY = lastTurn.Center.y
            elseif lastTurn.Direction == 90 then
                set turnCenterX = lastTurn.Center.x
                set turnCenterY = lastTurn.Center.y + lastTurn.Distance
            else //lastTurn.Direction == 270
                set turnCenterX = lastTurn.Center.x
                set turnCenterY = lastTurn.Center.y - lastTurn.Distance
            endif
            
            if ((lastTurn.Direction == 0 or lastTurn.Direction == 180) and (newDirection == 90 or newDirection == 270)) or ((lastTurn.Direction == 90 or lastTurn.Direction == 270) and (newDirection == 0 or newDirection == 180)) then
                call this.AddTurn(Rect(turnCenterX - radius - TURN_RECT_BUFFER, turnCenterY - radius - TURN_RECT_BUFFER, turnCenterX + radius + TURN_RECT_BUFFER, turnCenterY + radius + TURN_RECT_BUFFER), vector2.create(turnCenterX, turnCenterY), newDirection, totalDistance)
            else
                //get 1 cell wide rect on far side of square
                if newDirection == 0 then
                    call this.AddTurn(Rect(turnCenterX + radius - TERRAIN_TILE_SIZE - TURN_RECT_BUFFER, turnCenterY - radius - TURN_RECT_BUFFER, turnCenterX + radius + TURN_RECT_BUFFER, turnCenterY + radius + TURN_RECT_BUFFER), vector2.create(turnCenterX, turnCenterY), newDirection, totalDistance)
                elseif newDirection == 180 then
                    call this.AddTurn(Rect(turnCenterX - radius - TURN_RECT_BUFFER, turnCenterY - radius - TURN_RECT_BUFFER, turnCenterX - radius + TERRAIN_TILE_SIZE + TURN_RECT_BUFFER, turnCenterY + radius + TURN_RECT_BUFFER), vector2.create(turnCenterX, turnCenterY), newDirection, totalDistance)
                elseif newDirection == 90 then
                    call this.AddTurn(Rect(turnCenterX - radius - TURN_RECT_BUFFER, turnCenterY + radius - TERRAIN_TILE_SIZE - TURN_RECT_BUFFER, turnCenterX + radius + TURN_RECT_BUFFER, turnCenterY + radius + TURN_RECT_BUFFER), vector2.create(turnCenterX, turnCenterY), newDirection, totalDistance)
                else
                    call this.AddTurn(Rect(turnCenterX - radius - TURN_RECT_BUFFER, turnCenterY - radius - TURN_RECT_BUFFER, turnCenterX + radius + TURN_RECT_BUFFER, turnCenterY - radius + TERRAIN_TILE_SIZE + TURN_RECT_BUFFER), vector2.create(turnCenterX, turnCenterY), newDirection, totalDistance)
                endif
            endif
        endmethod
        
        public method IsUnitAtNextDestination takes unit u, RelayUnit turnUnit returns boolean
            local real x = GetUnitX(u)
            local real y = GetUnitY(u)
            local boolean atDestination
            
            local vector2 destination = this.GetTurnDestination(turnUnit.CurrentTurn.prev, turnUnit.LaneNumber)
            
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Cur x, y " + R2S(x) + ", " + R2S(y) + " destination " + destination.toString())
            
            //check if unit within box formed around destination using UNIT_DESTINATION_BUFFER as radius
            set atDestination = (x >= destination.x - UNIT_DESTINATION_BUFFER and x <= destination.x + UNIT_DESTINATION_BUFFER) and (y >= destination.y - UNIT_DESTINATION_BUFFER and y <= destination.y + UNIT_DESTINATION_BUFFER)
            
            call destination.deallocate()
            return atDestination
        endmethod
        
        public method GetTurnDestination takes SimpleList_ListNode currentTurn, integer lane returns vector2
            local RelayTurn nextTurn = RelayTurn(currentTurn.next.value)
            
            //get the location of the first lane
            //check if corner
            if ((RelayTurn(currentTurn.value).Direction == 0 or RelayTurn(currentTurn.value).Direction == 180) and (nextTurn.Direction == 90 or nextTurn.Direction == 270)) or ((RelayTurn(currentTurn.value).Direction == 90 or RelayTurn(currentTurn.value).Direction == 270) and (nextTurn.Direction == 0 or nextTurn.Direction == 180)) then
                //get this units lane using firstLane
                return vector2.create(nextTurn.FirstLane.x + nextTurn.FirstLaneX*.UnitLaneSize*lane, nextTurn.FirstLane.y + nextTurn.FirstLaneY*.UnitLaneSize*lane)
            else //straight of some sorts
                if nextTurn.Direction == 90 or nextTurn.Direction == 270 then
                    return vector2.create(nextTurn.FirstLane.x + nextTurn.FirstLaneX*.UnitLaneSize*lane, nextTurn.FirstLane.y)
                else //LEFT or RIGHT
                    return vector2.create(nextTurn.FirstLane.x, nextTurn.FirstLane.y + nextTurn.FirstLaneY*.UnitLaneSize*lane)
                endif
            endif
        endmethod
        
        public method GetNextTurnDestination takes RelayUnit turnUnit returns vector2
            /*
			local vector2 destination = GetTurnDestination(turnUnit.CurrentTurn, turnUnit.LaneNumber)
			local RelayTurn turn = turnUnit.CurrentTurn.value
			
			//call DisplayTextToForce(bj_FORCE_PLAYER[0], "Cur destination " + destination.toString())
			if turn.Direction == 0 then 
				set destination.x = destination.x + UNIT_DESTINATION_BUFFER
			elseif turn.Direction == 90 then
				set destination.y = destination.y + UNIT_DESTINATION_BUFFER
			elseif turn.Direction == 180 then
				set destination.x = destination.x - UNIT_DESTINATION_BUFFER
			elseif turn.Direction == 270 then
				set destination.y = destination.y - UNIT_DESTINATION_BUFFER
			endif
			//call DisplayTextToForce(bj_FORCE_PLAYER[0], "Buffered destination " + destination.toString())
			
			return destination
			*/
			
			return GetTurnDestination(turnUnit.CurrentTurn, turnUnit.LaneNumber)
        endmethod
        		
        private static method CreateUnitCB takes nothing returns nothing
            local RelayGenerator generator = GetTimerData(GetExpiredTimer())
			local RelayTurn spawnTurn = generator.Turns.first.value
			
			local group g
            local unit u
			local integer lane
            local vector2 destination
            
            set g = generator.SpawnPattern.Spawn(generator.ParentLevel)
			loop
			set u = FirstOfGroup(g)
			exitwhen u == null
				if spawnTurn.Direction == 90 or spawnTurn.Direction == 270 then
					//GetUnitX(u) = spawnTurn.FirstLane.x + spawnTurn.FirstLaneX*lane*generator.UnitLaneSize
					//GetUnitX(u) - spawnTurn.FirstLane.x = spawnTurn.FirstLaneX*lane*generator.UnitLaneSize
					//(GetUnitX(u) - spawnTurn.FirstLane.x) / (spawnTurn.FirstLaneX * generator.UnitLaneSize) = lane
					set lane = R2I((GetUnitX(u) - spawnTurn.FirstLane.x) / (spawnTurn.FirstLaneX * generator.UnitLaneSize))
				else
					set lane = R2I((GetUnitY(u) - spawnTurn.FirstLane.y) / (spawnTurn.FirstLaneY * generator.UnitLaneSize))
				endif
				
				//debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Creating unit in lane " + I2S(lane))
				
				call IndexedUnit.create(u)
				call GroupAddUnit(generator.Units, u)
				set UnitIDToRelayUnitID[GetUnitUserData(u)] = RelayUnit.create(lane, generator.Turns.first)
				
				//send unit to first destination
				set destination = generator.GetNextTurnDestination(UnitIDToRelayUnitID[GetUnitUserData(u)])
				call IssuePointOrder(u, "move", destination.x, destination.y)
				
				set RelayUnit(UnitIDToRelayUnitID[GetUnitUserData(u)]).CurrentTurn = generator.Turns.first.next
				
				call destination.deallocate()
			call GroupRemoveUnit(g, u)
			endloop
            
			call ReleaseGroup(g)
			set g = null
        endmethod
		
		private method ReleaseUnit takes unit u returns nothing
			call RelayUnit(UnitIDToRelayUnitID[GetUnitUserData(u)]).deallocate()
			call GroupRemoveUnit(.Units, u)
			
			call IndexedUnit(GetUnitUserData(u)).destroy()
			call Recycle_ReleaseUnit(u)
		endmethod
        
        private method CheckRelay takes nothing returns nothing
            //local SimpleList_ListNode turn = this.Turns.first
            local unit turnUnit
			local group tempGroup = NewGroup()
            local RelayUnit turnUnitInfo
            
            local vector2 destination
            
			//first of group loop, with group swap at the end to restore original state
			loop
			set turnUnit = FirstOfGroup(.Units)
			exitwhen turnUnit == null
				//see if unit is being watched, returns 0 if unwatched / not part of a relay
				set turnUnitInfo = UnitIDToRelayUnitID[GetUnitUserData(turnUnit)]
				
				//check if unit is part of this relay, and on the turn we're enumerating the rect for, and if they've made it past where they need to go (for their lane) --- turns can only belong to 1 relay, so if the turn matches then so does the relay
				if IsUnitAtNextDestination(turnUnit, turnUnitInfo) then
					if turnUnitInfo.CurrentTurn.next != 0 then
						//send unit a bit past their next destination
						set destination = GetNextTurnDestination(turnUnitInfo)
						call IssuePointOrder(turnUnit, "move", destination.x, destination.y)
						call destination.deallocate()
						
						set turnUnitInfo.CurrentTurn = turnUnitInfo.CurrentTurn.next
						
						call GroupAddUnit(tempGroup, turnUnit)
						call GroupRemoveUnit(.Units, turnUnit)
					else //finished all turns
						call .ReleaseUnit(turnUnit)
					endif
				else
					call GroupAddUnit(tempGroup, turnUnit)
					call GroupRemoveUnit(.Units, turnUnit)
				endif
			endloop
			
			call ReleaseGroup(.Units)
			set .Units = tempGroup
        endmethod
        
        private static method CheckRelayInit takes nothing returns nothing
            local SimpleList_ListNode activeRelay = ActiveRelays.first
            //local integer stopwatch = StopWatchCreate()
			
            loop
            exitwhen activeRelay == 0
                //call DisplayTextToForce(bj_FORCE_PLAYER[0], "Checking turns for generator " + I2S(activeRelay.value))
                call RelayGenerator(activeRelay.value).CheckRelay()
            set activeRelay = activeRelay.next
            endloop
			
			//call DisplayTextToForce(bj_FORCE_PLAYER[0], "Stop watch ticks: " + I2S(StopWatchMark(stopwatch)))
        endmethod
        
        public method Start takes nothing returns nothing
            if not ActiveRelays.contains(this) then
                call ActiveRelays.add(this)
                
				set this.Units = NewGroup()
				
                set this.UnitTimer = NewTimerEx(this)
                call TimerStart(this.UnitTimer, this.UnitTimeout, true, function RelayGenerator.CreateUnitCB)
                
                //call DisplayTextToForce(bj_FORCE_PLAYER[0], "Count relays on " + I2S(ActiveRelays.count))
                
                if ActiveRelays.count == 1 then
                    call TimerStart(TurnTimer, RELAY_TURN_CHECK_TIMESTEP, true, function RelayGenerator.CheckRelayInit)
                    //call DisplayTextToForce(bj_FORCE_PLAYER[0], "Started turn check timer")
                endif
            endif
        endmethod
        
        public method Stop takes nothing returns nothing
            local unit u
			
			if ActiveRelays.contains(this) then
                call ActiveRelays.remove(this)
                
				//recycle all units in a way that's proper for this struct
				loop
				set u = FirstOfGroup(.Units)
				exitwhen u == null
					call .ReleaseUnit(u)
					//call GroupRemoveUnit(.Units, u)
				endloop
				
				call ReleaseGroup(.Units)
				
                //pauses and recycles timer while relay is off
                call ReleaseTimer(this.UnitTimer)
                
                if ActiveRelays.count == 0 then
                    call PauseTimer(TurnTimer)
                endif
            endif
        endmethod
                        
        //takes:
        //real centerX -- center coord for relay generator's first turn (and spawn)
        //real centerY
        //integer spawnDiameter -- # of full tiles this spawn is in both length and width directions. all spawns are squares
        //integer laneCount -- # of lanes in relay
        public static method create takes real centerX, real centerY, integer spawnDiameter, integer laneCount, integer direction, integer tilesToTravel, real unitSpawnTimeout, IPatternSpawn spawnCB, integer cycleCount returns thistype
            local thistype new
            local real spawnRadius = spawnDiameter / 2. * TERRAIN_TILE_SIZE
			local vector2 testCenter
            local vector2 spawnCenter
            
            //local real travelDistance = spawnRadius*2 + tilesToTravel*TERRAIN_TILE_SIZE
            
            if ModuloInteger(direction, 90) == 0 then
                set new = thistype.allocate()
                
                set new.UnitTimeout = unitSpawnTimeout
                
				if ModuloInteger(spawnDiameter, 2) == 0 then
					set spawnCenter = vector2.allocate()
					
					//get point halfway between two tiles on vertical
					set testCenter = GetTerrainCenterpoint(centerX, centerY - TERRAIN_QUADRANT_SIZE)
					set spawnCenter.y = testCenter.y
					call testCenter.deallocate()
					
					set testCenter = GetTerrainCenterpoint(centerX, centerY + TERRAIN_QUADRANT_SIZE)
					set spawnCenter.y = (spawnCenter.y + testCenter.y) / 2
					call testCenter.deallocate()

					//get point halfway between two tiles on horizontal
					set testCenter = GetTerrainCenterpoint(centerX - TERRAIN_QUADRANT_SIZE, centerY)
					set spawnCenter.x = testCenter.x
					call testCenter.deallocate()
					
					set testCenter = GetTerrainCenterpoint(centerX + TERRAIN_QUADRANT_SIZE, centerY)
					set spawnCenter.x = (spawnCenter.x + testCenter.x) / 2
					call testCenter.deallocate()
				else
					set spawnCenter = GetTerrainCenterpoint(centerX, centerY)
				endif
				
				set new.Diameter = spawnDiameter
                // set new.Radius = R2I(spawnDiameter / 2. - .5000)
                set new.UnitLaneSize = spawnDiameter * TERRAIN_TILE_SIZE / (1.*laneCount)
                
                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Spawn radius: " + R2S(spawnRadius) + ", Lane count: " + R2S(new.LaneCount))
                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Spawn initial total distance: " + R2S(spawnDiameter*TERRAIN_TILE_SIZE + tilesToTravel*TERRAIN_TILE_SIZE))
                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], new.SpawnCenter.toString())
                
                set new.Turns = SimpleList_List.create()
				
                if direction == 0 then
                    //sending right
                    call new.Turns.add(RelayTurn.create(Rect(spawnCenter.x - spawnRadius - new.UnitLaneSize, spawnCenter.y - spawnRadius - new.UnitLaneSize, spawnCenter.x - spawnRadius + TERRAIN_TILE_SIZE + new.UnitLaneSize, spawnCenter.y + spawnRadius + new.UnitLaneSize), spawnCenter, new, direction, spawnDiameter*TERRAIN_TILE_SIZE + tilesToTravel*TERRAIN_TILE_SIZE, LEFT, DOWN))
                elseif direction == 180 then
                    //sending left
                    call new.Turns.add(RelayTurn.create(Rect(spawnCenter.x + spawnRadius - TERRAIN_TILE_SIZE - new.UnitLaneSize, spawnCenter.y - spawnRadius - new.UnitLaneSize, spawnCenter.x + spawnRadius + new.UnitLaneSize, spawnCenter.y + spawnRadius + new.UnitLaneSize), spawnCenter, new, direction, spawnDiameter*TERRAIN_TILE_SIZE + tilesToTravel*TERRAIN_TILE_SIZE, RIGHT, DOWN))
                elseif direction == 90 then
                    //sending up
                    call new.Turns.add(RelayTurn.create(Rect(spawnCenter.x - spawnRadius - new.UnitLaneSize, spawnCenter.y - spawnRadius - new.UnitLaneSize, spawnCenter.x + spawnRadius + new.UnitLaneSize, spawnCenter.y - spawnRadius + TERRAIN_TILE_SIZE + new.UnitLaneSize), spawnCenter, new, direction, spawnDiameter*TERRAIN_TILE_SIZE + tilesToTravel*TERRAIN_TILE_SIZE, LEFT, DOWN))
                else //direction == 270
                    //sending down
                    call new.Turns.add(RelayTurn.create(Rect(spawnCenter.x - spawnRadius - new.UnitLaneSize, spawnCenter.y + spawnRadius - TERRAIN_TILE_SIZE - new.UnitLaneSize, spawnCenter.x + spawnRadius + new.UnitLaneSize, spawnCenter.y + spawnRadius + new.UnitLaneSize), spawnCenter, new, direction, spawnDiameter*TERRAIN_TILE_SIZE + tilesToTravel*TERRAIN_TILE_SIZE, LEFT, UP))
                endif
				
				set new.SpawnPattern = RelayPatternSpawn.create(spawnCB, cycleCount, new)
                
                //don't deallocate spawn center, it's re-used by the generator
                
                debug if spawnDiameter <= 1 then
                    debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Trying to create relay with 0 lanes!")
                debug endif
            else
                debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Trying to create relay with illegal starting direction!")
            endif
            
            return new
        endmethod
		public static method createFromPoint takes rect centerPoint, integer spawnDiameter, integer laneCount, integer direction, integer tilesToTravel, real unitSpawnTimeout, IPatternSpawn spawnCB, integer cycleCount returns thistype
			return thistype.create(GetRectCenterX(centerPoint), GetRectCenterY(centerPoint), spawnDiameter, laneCount, direction, tilesToTravel, unitSpawnTimeout, spawnCB, cycleCount)
		endmethod
        
        public static method onInit takes nothing returns nothing
            set ActiveRelays = SimpleList_List.create()
            set TurnTimer = CreateTimer()
            set UnitIDToRelayUnitID[0] = 0
            //set UnitTable = Table.create()
        endmethod
    endstruct
endlibrary