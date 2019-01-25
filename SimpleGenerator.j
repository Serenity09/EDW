library SimpleGenerator requires TimerUtils, SimpleList, Recycle, GroupUtils, PatternSpawn

globals
    private constant real BUFFER = 64
    private constant real MOVEMENT_UPDATE_TIMESTEP = .035
    //private constant real DESPAWN_CHECK_TIMESTEP = .5
    
    private constant player GENERATOR_PLAYER = Player(10)
endglobals

struct SimpleGenerator extends IStartable
    public LinePatternSpawn SpawnPattern
	
	public rect SpawnArea
    public integer SpawnUnit
	
    public real SpawnDirection
    public real EndCoordinate
    
    private timer SpawnTimer
    private real SpawnTimeStep
	
    private group SpawnedUnits
    private real MoveSpeed
	
	public boolean AnimateMovement
    
    private static timer MoveTimer
    private static SimpleList_List ActiveWidgets
    
    public static method PeriodicSpawn takes nothing returns nothing
        local thistype generator = GetTimerData(GetExpiredTimer())
		local group g
		
		local group tempGroup
		local unit u
		
		//might as well keep this optimization/default implementation, since it's already built
		if generator.SpawnPattern == 0 then					
			set g = NewGroup()
			call GroupAddUnit(g, Recycle_MakeUnit(generator.SpawnUnit, GetRandomReal(GetRectMinX(generator.SpawnArea), GetRectMaxX(generator.SpawnArea)), GetRandomReal(GetRectMinY(generator.SpawnArea), GetRectMaxY(generator.SpawnArea))))
		else
			set g = generator.SpawnPattern.Spawn()
		endif
		
		if generator.AnimateMovement then
			set tempGroup = NewGroup()
			
			loop
			set u = FirstOfGroup(g)
			exitwhen u == null
				call SetUnitFacingTimed(u, generator.SpawnDirection, 0)
				// call SetUnitAnimation(u, "walk")
				
				//TODO replace walk animation hard code and move speed hard code with lookups for all EDW units
				call SetUnitAnimationByIndex(u, GetWalkAnimationIndex(GetUnitTypeId(u)))
				call SetUnitTimeScale(u, generator.MoveSpeed / MOVEMENT_UPDATE_TIMESTEP / GetDefaultMoveSpeed(GetUnitTypeId(u)))
			call GroupAddUnit(tempGroup, u)
			call GroupRemoveUnit(g, u)
			endloop
			
			call ReleaseGroup(g)
			set g = tempGroup
		endif
		
		
        call MergeGroups(generator.SpawnedUnits, g)
		
		call ReleaseGroup(g)
		set g = null
    endmethod
    
	//TODO could support any angle by using sin/cos
    public static method PeriodicMove takes nothing returns nothing
        local SimpleList_ListNode curActiveWidgetNode = thistype.ActiveWidgets.first
        local group swapGroup = NewGroup()
        local thistype curActiveWidget
        local unit curUnit
        
        local integer xDirection
        local integer yDirection
        
        local real destinationCoordinate
        
        loop
        exitwhen curActiveWidgetNode == 0
            set curActiveWidget = thistype(curActiveWidgetNode.value)
            
            if curActiveWidget.SpawnDirection == 0 then
                set xDirection = 1
                set yDirection = 0
            elseif curActiveWidget.SpawnDirection == 180 then
                set xDirection = -1
                set yDirection = 0
            elseif curActiveWidget.SpawnDirection == 90 then
                set xDirection = 0
                set yDirection = 1
            elseif curActiveWidget.SpawnDirection == 270 then
                set xDirection = 0
                set yDirection = -1
            endif
            
            set curUnit = FirstOfGroup(curActiveWidget.SpawnedUnits)
            loop
            exitwhen curUnit == null
                if xDirection != 0 then
                    set destinationCoordinate = GetUnitX(curUnit) + xDirection * curActiveWidget.MoveSpeed
                    
                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "end: " + R2S(curActiveWidget.EndCoordinate) + ", cur: " + R2S(destinationCoordinate))
                    if (curActiveWidget.EndCoordinate >= 0 and destinationCoordinate >= curActiveWidget.EndCoordinate) or (curActiveWidget.EndCoordinate < 0 and destinationCoordinate <= curActiveWidget.EndCoordinate) then
                        //unit has gone past end
                        call Recycle_ReleaseUnit(curUnit)
                    else
                        call SetUnitX(curUnit, destinationCoordinate)
                        call GroupAddUnit(swapGroup, curUnit)
                    endif
                else //yDirection != 0
                    set destinationCoordinate = GetUnitY(curUnit) + yDirection * curActiveWidget.MoveSpeed
                    
                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "end: " + R2S(curActiveWidget.EndCoordinate) + ", cur: " + R2S(destinationCoordinate))
                    if (curActiveWidget.EndCoordinate >= 0 and destinationCoordinate >= curActiveWidget.EndCoordinate) or (curActiveWidget.EndCoordinate < 0 and destinationCoordinate <= curActiveWidget.EndCoordinate) then
                        //unit has gone past end
                        call Recycle_ReleaseUnit(curUnit)
                    else
                        call SetUnitY(curUnit, destinationCoordinate)
                        call GroupAddUnit(swapGroup, curUnit)
                    endif
                endif
            
            call GroupRemoveUnit(curActiveWidget.SpawnedUnits, curUnit)
            set curUnit = FirstOfGroup(curActiveWidget.SpawnedUnits)
            endloop
            
            call ReleaseGroup(curActiveWidget.SpawnedUnits)
            set curActiveWidget.SpawnedUnits = swapGroup
                        
        set curActiveWidgetNode = curActiveWidgetNode.next
        endloop
    endmethod
	
	public method Start takes nothing returns nothing
        if thistype.ActiveWidgets.count == 0 then
            call TimerStart(thistype.MoveTimer, MOVEMENT_UPDATE_TIMESTEP, true, function thistype.PeriodicMove)
        endif
        
        call thistype.ActiveWidgets.addEnd(this)
        set this.SpawnTimer = NewTimerEx(this)
        set this.SpawnedUnits = NewGroup()
        call TimerStart(this.SpawnTimer, this.SpawnTimeStep, true, function thistype.PeriodicSpawn)
    endmethod
    
    public method Stop takes nothing returns nothing
        call thistype.ActiveWidgets.remove(this)
        //call PauseTimer(this.SpawnTimer)
        call ReleaseTimer(this.SpawnTimer)
        call ReleaseGroup(this.SpawnedUnits)
        set this.SpawnTimer = null
        
		if this.SpawnPattern != 0 then
			call this.SpawnPattern.Reset()
		endif
		
        if thistype.ActiveWidgets.count == 0 then
            call PauseTimer(thistype.MoveTimer)
        endif
    endmethod
        
    public static method create takes rect spawn, integer spawnUnitID, real spawnTimestep, real spawnDirection, integer spawnLength, real movespeed returns thistype
        local thistype new = thistype.allocate()
        
        local real xOffset
        local real yOffset
        
        if spawnDirection == 0 then
            set xOffset = spawnLength * TERRAIN_TILE_SIZE
            set yOffset = 0
            
            set new.EndCoordinate = GetRectMaxX(spawn) + xOffset
        elseif spawnDirection == 180 then
            set xOffset = -spawnLength * TERRAIN_TILE_SIZE
            set yOffset = 0
            
            set new.EndCoordinate = GetRectMinX(spawn) + xOffset
        elseif spawnDirection == 90 then
            set xOffset = 0
            set yOffset = spawnLength * TERRAIN_TILE_SIZE
            
            set new.EndCoordinate = GetRectMaxY(spawn) + yOffset
        elseif spawnDirection == 270 then
            set xOffset = 0
            set yOffset = -spawnLength * TERRAIN_TILE_SIZE
            
            set new.EndCoordinate = GetRectMinY(spawn) + yOffset
        else
            //error
            debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Invalid spawn direction for mass create!! Must use either 0, 90, 180, or 270")
            return 0/0
        endif
        
        set new.SpawnArea = spawn
        set new.SpawnUnit = spawnUnitID
        set new.SpawnTimeStep = spawnTimestep
        set new.SpawnDirection = spawnDirection
        set new.MoveSpeed = movespeed * MOVEMENT_UPDATE_TIMESTEP
		
		//defaults
		set new.AnimateMovement = false
		set new.SpawnPattern = 0
        
        //set new.EndArea = Rect(GetRectMinX(spawn) - BUFFER + xOffset, GetRectMinY(spawn) - BUFFER + yOffset, GetRectMaxX(spawn) + BUFFER + xOffset, GetRectMaxY(spawn) + BUFFER + yOffset)
        
        return new
    endmethod
    
    private static method onInit takes nothing returns nothing
        //set thistype.DespawnTimer = CreateTimer()
        set thistype.MoveTimer = CreateTimer()
        set thistype.ActiveWidgets = SimpleList_List.create()
    endmethod
endstruct
endlibrary