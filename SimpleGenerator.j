library SimpleGenerator requires TimerUtils, SimpleList, Recycle, GroupUtils, PatternSpawn

globals
    private constant real BUFFER = 64
    private constant real MOVEMENT_UPDATE_TIMESTEP = .035
    //private constant real DESPAWN_CHECK_TIMESTEP = .5
	
	private constant real MOVEMENT_ANIMATION_EXTRASLOW = 50. //helps animation match actual speed
    
    private constant player GENERATOR_PLAYER = Player(10)
	
	private constant boolean DEBUG_MOVE_LOOP = false
	private constant boolean DEBUG_SPAWN_LOOP = false
	private constant boolean DEBUG_START = false
endglobals

struct SimpleGenerator extends IStartable
    public LinePatternSpawn SpawnPattern
		
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
		local group spawnGroup = generator.SpawnPattern.Spawn(generator.ParentLevel)
		local group tempGroup
		local unit u
		
		static if DEBUG_SPAWN_LOOP then
			call DisplayTextToForce(bj_FORCE_PLAYER[0], "Spawning for generator " + I2S(generator))
		endif
				
		if generator.AnimateMovement then
			set tempGroup = NewGroup()
			
			loop
			set u = FirstOfGroup(spawnGroup)
			exitwhen u == null
				call SetUnitFacingTimed(u, generator.SpawnDirection, 0)
				
				call SetUnitAnimationByIndex(u, GetWalkAnimationIndex(GetUnitTypeId(u)))
				call SetUnitTimeScale(u, RAbsBJ(generator.MoveSpeed) / MOVEMENT_UPDATE_TIMESTEP / (GetDefaultMoveSpeed(GetUnitTypeId(u)) + MOVEMENT_ANIMATION_EXTRASLOW))
			call GroupAddUnit(tempGroup, u)
			call GroupRemoveUnit(spawnGroup, u)
			endloop
			
			call ReleaseGroup(spawnGroup)
			set spawnGroup = tempGroup
		endif
		
		static if DEBUG_SPAWN_LOOP then
			call DisplayTextToForce(bj_FORCE_PLAYER[0], "Spawning " + I2S(CountUnitsInGroup(spawnGroup)) + " new units")
		endif
		
		//! runtextmacro MergeGroups("generator.SpawnedUnits", "spawnGroup", "u", "tempGroup")
		
		call ReleaseGroup(spawnGroup)
		set spawnGroup = null
				
		static if DEBUG_SPAWN_LOOP then
			call DisplayTextToForce(bj_FORCE_PLAYER[0], "Finished spawning with " + I2S(CountUnitsInGroup(generator.SpawnedUnits)) + " total units")
		endif
    endmethod
    
	//TODO could support any angle by using sin/cos
    public static method PeriodicMove takes nothing returns nothing
        local SimpleList_ListNode curActiveWidgetNode = thistype.ActiveWidgets.first
        local group swapGroup
        local thistype curActiveWidget
        local unit curUnit
                
        local real destinationCoordinate
        
        loop
        exitwhen curActiveWidgetNode == 0
			set curActiveWidget = thistype(curActiveWidgetNode.value)
			
			static if DEBUG_MOVE_LOOP then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Started generator update for " + I2S(curActiveWidget))
			endif
                        
			set swapGroup = NewGroup()
            loop
            set curUnit = FirstOfGroup(curActiveWidget.SpawnedUnits)
			exitwhen curUnit == null
                //evaluate cos/sin functions for 90 degree angles
				//would otherwise be x = x + Cos(.SpawnDirection)*.MoveSpeed
				if curActiveWidget.SpawnDirection == 0 or curActiveWidget.SpawnDirection == 180 then
					set destinationCoordinate = GetUnitX(curUnit) + curActiveWidget.MoveSpeed
					
					//solve change vs destination for easy perpendiculars
					if (curActiveWidget.SpawnDirection == 0 and destinationCoordinate >= curActiveWidget.EndCoordinate) or (curActiveWidget.SpawnDirection == 180 and destinationCoordinate <= curActiveWidget.EndCoordinate) then
						call GroupRemoveUnit(curActiveWidget.SpawnedUnits, curUnit)
						call Recycle_ReleaseUnit(curUnit)
						
						static if DEBUG_MOVE_LOOP then
							call DisplayTextToForce(bj_FORCE_PLAYER[0], "Removed unit from movement")
						endif
					else
						call SetUnitX(curUnit, destinationCoordinate)
					
						call GroupRemoveUnit(curActiveWidget.SpawnedUnits, curUnit)
						call GroupAddUnit(swapGroup, curUnit)
					endif
				else//if curActiveWidget.SpawnDirection == 90 or curActiveWidget.SpawnDirection == 270 then
					set destinationCoordinate = GetUnitY(curUnit) + curActiveWidget.MoveSpeed
					
					//solve change vs destination for easy perpendiculars
					if (curActiveWidget.SpawnDirection == 90 and destinationCoordinate >= curActiveWidget.EndCoordinate) or (curActiveWidget.SpawnDirection == 270 and destinationCoordinate <= curActiveWidget.EndCoordinate) then
						call GroupRemoveUnit(curActiveWidget.SpawnedUnits, curUnit)
						call Recycle_ReleaseUnit(curUnit)
						
						static if DEBUG_MOVE_LOOP then
							call DisplayTextToForce(bj_FORCE_PLAYER[0], "Removed unit from movement")
						endif
					else
						call SetUnitY(curUnit, destinationCoordinate)
					
						call GroupRemoveUnit(curActiveWidget.SpawnedUnits, curUnit)
						call GroupAddUnit(swapGroup, curUnit)
					endif
				endif
            endloop
			
			static if DEBUG_MOVE_LOOP then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Finished generator update")
            endif
			
            call ReleaseGroup(curActiveWidget.SpawnedUnits)
            set curActiveWidget.SpawnedUnits = swapGroup
                        
        set curActiveWidgetNode = curActiveWidgetNode.next
        endloop
		
		static if DEBUG_MOVE_LOOP then
			call DisplayTextToForce(bj_FORCE_PLAYER[0], "Finished all generators")
		endif
    endmethod
	
	public method Start takes nothing returns nothing
        if thistype.ActiveWidgets.count == 0 then
            call TimerStart(thistype.MoveTimer, MOVEMENT_UPDATE_TIMESTEP, true, function thistype.PeriodicMove)
        endif
        
        call thistype.ActiveWidgets.addEnd(this)
        set this.SpawnTimer = NewTimerEx(this)
        set this.SpawnedUnits = NewGroup()
		
		static if DEBUG_START then
			call DisplayTextToForce(bj_FORCE_PLAYER[0], "Starting generator " + I2S(this) + " with group " + I2S(GetHandleId(this.SpawnedUnits)))
		endif
		
        call TimerStart(this.SpawnTimer, this.SpawnTimeStep, true, function thistype.PeriodicSpawn)
    endmethod
    
    public method Stop takes nothing returns nothing
        call thistype.ActiveWidgets.remove(this)
		
        call ReleaseTimer(this.SpawnTimer)
        set this.SpawnTimer = null
		
		call ReleaseGroup(this.SpawnedUnits)
		set this.SpawnedUnits = null
        
		if this.SpawnPattern != 0 then
			call this.SpawnPattern.Reset()
		endif
		
        if thistype.ActiveWidgets.count == 0 then
            call PauseTimer(thistype.MoveTimer)
        endif
    endmethod
	
	public method destroy takes nothing returns nothing
        if thistype.ActiveWidgets.contains(this) then
			call .Stop()
		endif
		
		if .SpawnPattern != 0 then
			//TODO
			//call .SpawnPattern.destroy()
		endif		
	endmethod
    public static method create takes LinePatternSpawn spawnPattern, real spawnTimestep, real spawnDirection, integer spawnLength, real movespeed returns thistype
        local thistype new = thistype.allocate()
        
        local real xOffset
        local real yOffset
		
		static if DEBUG_MODE then
			if spawnPattern == 0 then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Creating SimpleGenerator with null spawnPattern, spawnPattern is required!")
			endif
		endif
        
		set new.SpawnPattern = spawnPattern
		
        set new.SpawnTimeStep = spawnTimestep
        set new.SpawnDirection = spawnDirection
        set new.MoveSpeed = movespeed * MOVEMENT_UPDATE_TIMESTEP
		
        if spawnDirection == 0 then
            set xOffset = spawnLength * TERRAIN_TILE_SIZE
            
            set new.EndCoordinate = spawnPattern.SpawnOrigin.x + xOffset
        elseif spawnDirection == 180 then
            set xOffset = -spawnLength * TERRAIN_TILE_SIZE
            
            set new.EndCoordinate = spawnPattern.SpawnOrigin.x + xOffset
			set new.MoveSpeed = -new.MoveSpeed
        elseif spawnDirection == 90 then
            set yOffset = spawnLength * TERRAIN_TILE_SIZE
            
            set new.EndCoordinate = spawnPattern.SpawnOrigin.y + yOffset
        elseif spawnDirection == 270 then
            set yOffset = -spawnLength * TERRAIN_TILE_SIZE
            
            set new.EndCoordinate = spawnPattern.SpawnOrigin.y + yOffset
			set new.MoveSpeed = -new.MoveSpeed
        else
            //error
            debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Invalid spawn direction for mass create!! Must use either 0, 90, 180, or 270")
            return 0/0
        endif
		
		//defaults
		set new.AnimateMovement = false
        
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