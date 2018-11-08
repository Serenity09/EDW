library RelayGenerator requires GameGlobalConstants, SimpleList, Table, Vector2, TimerUtils, Recycle, locust, Alloc, Draw, IStartable
    globals
        private constant real RELAY_TURN_CHECK_TIMESTEP = .1
        
        private constant integer RELAY_PLAYER = 10
        
        //this have to be opposite for functionality to work, and it'll be faster if they're set this way to make computations off of (always interested in inverse)
        private constant integer LEFT = 1
        private constant integer RIGHT = -1
        private constant integer DOWN = 1
        private constant integer UP = -1
        
        //all of these can be made instance variables for more flexibility
        private constant real UNIT_LANE_OFFSET = TERRAIN_QUADRANT_SIZE
        private constant real UNIT_DESTINATION_BUFFER = UNIT_LANE_OFFSET / 4.
        private constant integer UNIT_SIDE_BUFFER = 0
        
        //has to be around 64 or the bot left corner of rect won't register units
        private constant real UNIT_RECT_BUFFER = TERRAIN_QUADRANT_SIZE
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
        
        public static method create takes rect area, vector2 center, real radius, integer direction, real distance, integer firstX, integer firstY returns thistype
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
                set firstLane.x = firstLane.x - radius*TERRAIN_TILE_SIZE + UNIT_SIDE_BUFFER*UNIT_LANE_OFFSET
            else
                set firstLane.x = firstLane.x + radius*TERRAIN_TILE_SIZE - UNIT_SIDE_BUFFER*UNIT_LANE_OFFSET
            endif
            
            if firstY == DOWN then
                set firstLane.y = firstLane.y - radius*TERRAIN_TILE_SIZE + UNIT_SIDE_BUFFER*UNIT_LANE_OFFSET
            else
                set firstLane.y = firstLane.y + radius*TERRAIN_TILE_SIZE - UNIT_SIDE_BUFFER*UNIT_LANE_OFFSET
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
        public vector2 SpawnCenter
        public real Radius //in whole tile units
        
        public integer UnitTypeID
        public static integer array UnitIDToRelayUnitID //links unit ID to RelayUnit struct ID (UnitIDToRelayUnitID[UnitID] = RelayUnit struct ID)
        private real UnitTimeout
        private timer UnitTimer
        
        public SimpleList_List Turns
        
        public static SimpleList_List ActiveRelays
        
        private static timer TurnTimer
        private static Table TurnTable
        
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
                            set turn = RelayTurn.create(area, center, this.Radius, newDirection, newDistance, LEFT, UP)
                        else //lastTurn.FirstLaneY == BOTTOM
                            set turn = RelayTurn.create(area, center, this.Radius, newDirection, newDistance, RIGHT, DOWN)
                        endif
                    else //lastTurn.Direction == 180
                        //left -> up
                        if lastTurn.FirstLaneY == UP then
                            set turn = RelayTurn.create(area, center, this.Radius, newDirection, newDistance, RIGHT, UP)
                        else //lastTurn.FirstLaneY == BOTTOM
                            set turn = RelayTurn.create(area, center, this.Radius, newDirection, newDistance, LEFT, DOWN)
                        endif
                    endif
                elseif newDirection == 270 then
                    if lastTurn.Direction == 0 then
                        //right -> down
                        if lastTurn.FirstLaneY == UP then
                            set turn = RelayTurn.create(area, center, this.Radius, newDirection, newDistance, RIGHT, UP)
                        else //lastTurn.FirstLaneY == BOTTOM
                            set turn = RelayTurn.create(area, center, this.Radius, newDirection, newDistance, LEFT, DOWN)
                        endif
                    else //lastTurn.Direction == 180
                        //left -> down
                        if lastTurn.FirstLaneY == UP then
                            set turn = RelayTurn.create(area, center, this.Radius, newDirection, newDistance, LEFT, UP)
                        else //lastTurn.FirstLaneY == BOTTOM
                            set turn = RelayTurn.create(area, center, this.Radius, newDirection, newDistance, RIGHT, DOWN)
                        endif
                    endif
                elseif newDirection == 0 then
                    if lastTurn.Direction == 90 then
                        //up -> right
                        if lastTurn.FirstLaneX == LEFT then
                            set turn = RelayTurn.create(area, center, this.Radius, newDirection, newDistance, LEFT, UP)
                        else //lastTurn.FirstLaneX == RIGHT
                            set turn = RelayTurn.create(area, center, this.Radius, newDirection, newDistance, RIGHT, DOWN)
                        endif
                    else //lastTurn.Direction == 270
                        //down -> right
                        if lastTurn.FirstLaneX == LEFT then
                            set turn = RelayTurn.create(area, center, this.Radius, newDirection, newDistance, LEFT, DOWN)
                        else //lastTurn.FirstLaneX == RIGHT
                            set turn = RelayTurn.create(area, center, this.Radius, newDirection, newDistance, RIGHT, UP)
                        endif
                    endif
                else //newDirection == 180
                    if lastTurn.Direction == 90 then
                        //up -> left
                        if lastTurn.FirstLaneX == LEFT then
                            set turn = RelayTurn.create(area, center, this.Radius, newDirection, newDistance, LEFT, DOWN)
                        else //lastTurn.FirstLaneX == RIGHT
                            set turn = RelayTurn.create(area, center, this.Radius, newDirection, newDistance, RIGHT, UP)
                        endif
                    else //lastTurn.Direction == 270
                        //down -> left
                        if lastTurn.FirstLaneX == LEFT then
                            set turn = RelayTurn.create(area, center, this.Radius, newDirection, newDistance, LEFT, UP)
                        else //lastTurn.FirstLaneX == RIGHT
                            set turn = RelayTurn.create(area, center, this.Radius, newDirection, newDistance, RIGHT, DOWN)
                        endif
                    endif
                endif
                
            else
                //either continuing straight or doubling back -- either way, persist the unchanged part of the first lane position
                if newDirection == 0 then
                    set turn = RelayTurn.create(area, center, this.Radius, newDirection, newDistance, RIGHT, lastTurn.FirstLaneY)
                elseif newDirection == 180 then
                    set turn = RelayTurn.create(area, center, this.Radius, newDirection, newDistance, LEFT, lastTurn.FirstLaneY)
                elseif newDirection == 90 then
                    set turn = RelayTurn.create(area, center, this.Radius, newDirection, newDistance, lastTurn.FirstLaneX, UP)
                else
                    set turn = RelayTurn.create(area, center, this.Radius, newDirection, newDistance, lastTurn.FirstLaneX, DOWN)
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
            local real radius = this.Radius * TERRAIN_TILE_SIZE
            local real totalDistance = radius*2 + tilesToTravel*TERRAIN_TILE_SIZE
            
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
                call this.AddTurn(Rect(turnCenterX - radius - UNIT_RECT_BUFFER, turnCenterY - radius - UNIT_RECT_BUFFER, turnCenterX + radius + UNIT_RECT_BUFFER, turnCenterY + radius + UNIT_RECT_BUFFER), vector2.create(turnCenterX, turnCenterY), newDirection, totalDistance)
            else
                //get 1 cell wide rect on far side of square
                if newDirection == 0 then
                    call this.AddTurn(Rect(turnCenterX + radius - TERRAIN_TILE_SIZE - UNIT_RECT_BUFFER, turnCenterY - radius - UNIT_RECT_BUFFER, turnCenterX + radius + UNIT_RECT_BUFFER, turnCenterY + radius + UNIT_RECT_BUFFER), vector2.create(turnCenterX, turnCenterY), newDirection, totalDistance)
                elseif newDirection == 180 then
                    call this.AddTurn(Rect(turnCenterX - radius - UNIT_RECT_BUFFER, turnCenterY - radius - UNIT_RECT_BUFFER, turnCenterX - radius + TERRAIN_TILE_SIZE + UNIT_RECT_BUFFER, turnCenterY + radius + UNIT_RECT_BUFFER), vector2.create(turnCenterX, turnCenterY), newDirection, totalDistance)
                elseif newDirection == 90 then
                    call this.AddTurn(Rect(turnCenterX - radius - UNIT_RECT_BUFFER, turnCenterY + radius - TERRAIN_TILE_SIZE - UNIT_RECT_BUFFER, turnCenterX + radius + UNIT_RECT_BUFFER, turnCenterY + radius + UNIT_RECT_BUFFER), vector2.create(turnCenterX, turnCenterY), newDirection, totalDistance)
                else
                    call this.AddTurn(Rect(turnCenterX - radius - UNIT_RECT_BUFFER, turnCenterY - radius - UNIT_RECT_BUFFER, turnCenterX + radius + UNIT_RECT_BUFFER, turnCenterY - radius + TERRAIN_TILE_SIZE + UNIT_RECT_BUFFER), vector2.create(turnCenterX, turnCenterY), newDirection, totalDistance)
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
                return vector2.create(nextTurn.FirstLane.x + nextTurn.FirstLaneX*UNIT_LANE_OFFSET*lane, nextTurn.FirstLane.y + nextTurn.FirstLaneY*UNIT_LANE_OFFSET*lane)
            else //straight of some sorts
                if nextTurn.Direction == 90 or nextTurn.Direction == 270 then
                    return vector2.create(nextTurn.FirstLane.x + nextTurn.FirstLaneX*UNIT_LANE_OFFSET*lane, nextTurn.FirstLane.y)
                else //LEFT or RIGHT
                    return vector2.create(nextTurn.FirstLane.x, nextTurn.FirstLane.y + nextTurn.FirstLaneY*UNIT_LANE_OFFSET*lane)
                endif
            endif
        endmethod
        
        public method GetNextTurnDestination takes RelayUnit turnUnit returns vector2
            return GetTurnDestination(turnUnit.CurrentTurn, turnUnit.LaneNumber)
        endmethod
        
        public method GetNumberLanes takes nothing returns integer
            //number lanes in a single tile = tile-size / lane-offset
            //number lanes total = lanes-single * spawn-diameter
            return R2I(this.Radius*2.*TERRAIN_TILE_SIZE/UNIT_LANE_OFFSET) - UNIT_SIDE_BUFFER*2
        endmethod
        
        private static method CreateUnitCB takes nothing returns nothing
            local RelayGenerator generator = GetTimerData(GetExpiredTimer())
            local RelayTurn firstTurn = RelayTurn(generator.Turns.first.value)
            
            local integer lane = GetRandomInt(0, generator.GetNumberLanes() - 1)
            local unit u 
            local vector2 destination
            
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Creating unit in lane " + I2S(lane))
            
            if firstTurn.Direction == 90 or firstTurn.Direction == 270 then
                //sending up/down
                set u = Recycle_MakeUnit(generator.UnitTypeID, firstTurn.FirstLane.x + firstTurn.FirstLaneX*lane*UNIT_LANE_OFFSET, firstTurn.FirstLane.y)
            else
                //sending left/right
                set u = Recycle_MakeUnit(generator.UnitTypeID, firstTurn.FirstLane.x, firstTurn.FirstLane.y + firstTurn.FirstLaneY*lane*UNIT_LANE_OFFSET)
            endif
            
            call IndexUnit(u)
            set UnitIDToRelayUnitID[GetUnitId(u)] = RelayUnit.create(lane, generator.Turns.first)
            
            //send unit to first destination
            set destination = generator.GetNextTurnDestination(UnitIDToRelayUnitID[GetUnitId(u)])
            call IssuePointOrder(u, "move", destination.x, destination.y)
            
            set RelayUnit(UnitIDToRelayUnitID[GetUnitId(u)]).CurrentTurn = generator.Turns.first.next
            
            call destination.deallocate()
        endmethod
        
        private method CheckRelay takes nothing returns nothing
            local SimpleList_ListNode turn = this.Turns.first
            local unit turnUnit
            local RelayUnit turnUnitInfo
            
            local vector2 destination
            
            loop
            exitwhen turn == 0
                //enum all units in turn region
                call GroupEnumUnitsInRect(TempGroup, RelayTurn(turn.value).Area, null)
                
                //first of group loop through units
                set turnUnit = FirstOfGroup(TempGroup)
                loop
                exitwhen turnUnit == null
                    //1st pass, check unit type id and player owner
                    if GetUnitTypeId(turnUnit) == this.UnitTypeID and GetPlayerId(GetOwningPlayer(turnUnit)) == RELAY_PLAYER then
                        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Unit passed 1st check")
                        //see if unit is being watched, returns 0 if unwatched / not part of a relay
                        set turnUnitInfo = UnitIDToRelayUnitID[GetUnitId(turnUnit)]
                        
                        static if DEBUG_MODE then
                            //call DisplayTextToForce(bj_FORCE_PLAYER[0], "Turn unit info " + I2S(turnUnitInfo))
                            //call DisplayTextToForce(bj_FORCE_PLAYER[0], "On turn " + I2S(turnUnitInfo.CurrentTurn) + " checking turn " + I2S(turn))
                            
                            /*
                            if IsUnitAtNextDestination(turnUnit, turnUnitInfo) then
                                call DisplayTextToForce(bj_FORCE_PLAYER[0], "At destination true")
                            else
                                call DisplayTextToForce(bj_FORCE_PLAYER[0], "At destination false")
                            endif
                            */
                            
                            //unit arrived to move target but is not at destination
                            if turnUnitInfo != 0 and turnUnitInfo.CurrentTurn == turn and (GetUnitCurrentOrder(turnUnit) == OrderId("none") or GetUnitCurrentOrder(turnUnit) == OrderId("stop")) and not IsUnitAtNextDestination(turnUnit, turnUnitInfo) then
                                call DisplayTextToForce(bj_FORCE_PLAYER[0], "Not moving but not at destination " + I2S(GetUnitId(turnUnit)))
                            endif
                        endif
                        
                        //check if unit is part of this relay, and on the turn we're enumerating the rect for, and if they've made it past where they need to go (for their lane) --- turns can only belong to 1 relay, so if the turn matches then so does the relay
                        if turnUnitInfo != 0 and turnUnitInfo.CurrentTurn == turn and IsUnitAtNextDestination(turnUnit, turnUnitInfo) then
                            //send unit a bit past their next destination
                            set destination = GetNextTurnDestination(turnUnitInfo)
                            call IssuePointOrder(turnUnit, "move", destination.x, destination.y)
                            call destination.deallocate()
                            
                            if turn.next != 0 then
                                set turnUnitInfo.CurrentTurn = turn.next
                            else //finished all turns
                                call turnUnitInfo.deallocate()
                                call DeindexUnit(turnUnit)
                                call Recycle_ReleaseUnit(turnUnit)
                                //call RemoveUnit(turnUnit)
                            endif
                        endif
                    endif
                call GroupRemoveUnit(TempGroup, turnUnit)
                set turnUnit = FirstOfGroup(TempGroup)
                endloop
                
                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "---")
                
                //always should clear TempGroup after using it
                call GroupClear(TempGroup)
            set turn = turn.next
            endloop
            
        endmethod
        
        private static method CheckRelayInit takes nothing returns nothing
            local SimpleList_ListNode activeRelay = ActiveRelays.first
            
            loop
            exitwhen activeRelay == 0
                //call DisplayTextToForce(bj_FORCE_PLAYER[0], "Checking turns for generator " + I2S(activeRelay.value))
                call RelayGenerator(activeRelay.value).CheckRelay()
            set activeRelay = activeRelay.next
            endloop
        endmethod
        
        public method Start takes nothing returns nothing
            if not ActiveRelays.contains(this) then
                call ActiveRelays.add(this)
                
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
            if ActiveRelays.contains(this) then
                call ActiveRelays.remove(this)
                
                //pauses and recycles timer while relay is off
                call ReleaseTimer(this.UnitTimer)
                
                if ActiveRelays.count == 0 then
                    call PauseTimer(TurnTimer)
                endif
            endif
        endmethod
                        
        public static method create takes real centerX, real centerY, integer tileDiameter, integer direction, integer tilesToTravel, integer unitTypeID, real unitSpawnTimeout returns thistype
            local thistype new
            local real spawnRadius = tileDiameter / 2. * TERRAIN_TILE_SIZE
            local vector2 spawnCenter
            
            //local real travelDistance = spawnRadius*2 + tilesToTravel*TERRAIN_TILE_SIZE
            
            if ModuloInteger(direction, 90) == 0 then
                set new = thistype.allocate()
                
                set new.UnitTypeID = unitTypeID
                set new.UnitTimeout = unitSpawnTimeout
                
                set spawnCenter = GetTerrainCenterpoint(centerX, centerY)
                set new.Radius = tileDiameter / 2.                
                
                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Spawn radius: " + R2S(spawnRadius) + ", Lane count: " + R2S(new.LaneCount))
                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Spawn initial total distance: " + R2S(tileDiameter*TERRAIN_TILE_SIZE + tilesToTravel*TERRAIN_TILE_SIZE))
                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], new.SpawnCenter.toString())
                
                set new.Turns = SimpleList_List.create()
                if direction == 0 then
                    //sending right
                    call new.Turns.add(RelayTurn.create(Rect(spawnCenter.x - spawnRadius - UNIT_RECT_BUFFER, spawnCenter.y - spawnRadius - UNIT_RECT_BUFFER, spawnCenter.x - spawnRadius + TERRAIN_TILE_SIZE + UNIT_RECT_BUFFER, spawnCenter.y + spawnRadius + UNIT_RECT_BUFFER), spawnCenter, new.Radius, direction, tileDiameter*TERRAIN_TILE_SIZE + tilesToTravel*TERRAIN_TILE_SIZE, LEFT, DOWN))
                elseif direction == 180 then
                    //sending left
                    call new.Turns.add(RelayTurn.create(Rect(spawnCenter.x + spawnRadius - TERRAIN_TILE_SIZE - UNIT_RECT_BUFFER, spawnCenter.y - spawnRadius - UNIT_RECT_BUFFER, spawnCenter.x + spawnRadius + UNIT_RECT_BUFFER, spawnCenter.y + spawnRadius + UNIT_RECT_BUFFER), spawnCenter, new.Radius, direction, tileDiameter*TERRAIN_TILE_SIZE + tilesToTravel*TERRAIN_TILE_SIZE, RIGHT, DOWN))
                elseif direction == 90 then
                    //sending up
                    call new.Turns.add(RelayTurn.create(Rect(spawnCenter.x - spawnRadius - UNIT_RECT_BUFFER, spawnCenter.y - spawnRadius - UNIT_RECT_BUFFER, spawnCenter.x + spawnRadius + UNIT_RECT_BUFFER, spawnCenter.y - spawnRadius + TERRAIN_TILE_SIZE + UNIT_RECT_BUFFER), spawnCenter, new.Radius, direction, tileDiameter*TERRAIN_TILE_SIZE + tilesToTravel*TERRAIN_TILE_SIZE, LEFT, DOWN))
                else //direction == 270
                    //sending down
                    call new.Turns.add(RelayTurn.create(Rect(spawnCenter.x - spawnRadius - UNIT_RECT_BUFFER, spawnCenter.y + spawnRadius - TERRAIN_TILE_SIZE - UNIT_RECT_BUFFER, spawnCenter.x + spawnRadius + UNIT_RECT_BUFFER, spawnCenter.y + spawnRadius + UNIT_RECT_BUFFER), spawnCenter, new.Radius, direction, tileDiameter*TERRAIN_TILE_SIZE + tilesToTravel*TERRAIN_TILE_SIZE, LEFT, UP))
                endif
                
                //debug call new.Turns.print(0)
                
                debug if tileDiameter <= 1 then
                    debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Trying to create relay with 0 lanes!")
                debug endif
            else
                debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Trying to create relay with illegal starting direction!")
            endif
            
            return new
        endmethod
        
        public static method onInit takes nothing returns nothing
            set ActiveRelays = SimpleList_List.create()
            set TurnTimer = CreateTimer()
            set TurnTable = Table.create()            
            set UnitIDToRelayUnitID[0] = 0
            //set UnitTable = Table.create()
        endmethod
    endstruct
endlibrary