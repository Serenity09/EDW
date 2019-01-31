library EDWGameStart initializer Init requires Levels, EDWVisualVote, UnitGlobals, MazerGlobals, GameMessage, EDWLevelContent, EDWCinematicContent
    globals
        constant real GAME_INIT_TIME_INITIAL = 0.01 //how long into the game before we start
        //constant real GAME_INIT_TIME_STEP = .5
        public timer GameInitTimer     
		
		private boolean FinishedPreLoad = false
		private boolean FinishedPostLoad = false
    endglobals
    
    private function PlayerInit takes nothing returns nothing
        local SimpleList_ListNode fp = PlayerUtils_FirstPlayer
        local User u
        
        loop
        exitwhen fp == 0
            set u = fp.value
            
            if u.IsPlaying then
                set u.ActiveUnit = MazersArray[u]
            endif
        set fp = fp.next
        endloop
    endfunction
                    
    private function PreplacedUnitInit takes nothing returns nothing
        local unit u
        local integer uID
                
        call GroupEnumUnitsInRect(TempGroup, bj_mapInitialPlayableArea, null)
        
        loop
        set u = FirstOfGroup(TempGroup)
        exitwhen u == null
            set uID = GetUnitTypeId(u)
            
            if uID == POWERUP_MARKER or InWorldPowerup.IsPowerupUnit(uID) then
				call InWorldPowerup.CreateFromUnit(u)
            elseif uID == UBOUNCE then
                call AddUnitLocust(CreateUnit(Player(11), UBOUNCE, GetUnitX(u), GetUnitY(u), 90))
                call RemoveUnit(u)
            elseif uID == LBOUNCE then
                call AddUnitLocust(CreateUnit(Player(11), LBOUNCE, GetUnitX(u), GetUnitY(u), 180))
                call RemoveUnit(u)
            elseif uID == DBOUNCE then
                call AddUnitLocust(CreateUnit(Player(11), DBOUNCE, GetUnitX(u), GetUnitY(u), 270))
                call RemoveUnit(u)
            elseif uID == RBOUNCE then
                call AddUnitLocust(CreateUnit(Player(11), RBOUNCE, GetUnitX(u), GetUnitY(u), 0))
                call RemoveUnit(u)
            endif            
        call GroupRemoveUnit(TempGroup, u)
        endloop
        
        call GroupClear(TempGroup)
    endfunction

    
    private function LevelRewardsInit takes nothing returns nothing
        if RewardMode == 0 or RewardMode == 2 then
            
        elseif RewardMode == 1 then
            
        endif
    endfunction
	
	static if DEBUG_MODE then
		private function CheckInitFinished takes nothing returns nothing
			if not FinishedPreLoad then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Did not finish Game Pre Load")
			endif
			
			if not FinishedPostLoad then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Did not finish Game Post Load")
			endif
		endfunction
	endif
            
    private function First takes nothing returns nothing
        //INITIALIZE MAP SETTINGS
        //time should be fixed at noon
        call SetFloatGameState(GAME_STATE_TIME_OF_DAY, 12.00001)
        call SetTimeOfDayScale(0)
        
        //ADD LOCUST TO ALL OF BROWNS UNITS
        call AddLocustAll()
        
        //CALL OTHER INITS
        call EDWPlayerSlotsInit()
		
		//connect editor placed units with their needed logic
        call PreplacedUnitInit()
        
        //GAME MODE INIT
        //Menu should happen after level creation so that it doesn't mess with the number of players on the intro world
        //use single players when in debug mode, now that menu is functional
        call EDWVisualVote_CreateMenu()
        
		//theres no way to detect the game paused / resumed event, so all other events cannot be unhooked during that state
		//some of those events, such as platforming arrow keys, can be abused
		//waste all 3 pauses
		call PauseGame(true)
		call PauseGame(false)
		call PauseGame(true)
		call PauseGame(false)
		call PauseGame(true)
		call PauseGame(false)
		
		static if DEBUG_MODE then
			set FinishedPostLoad = true
		endif
        debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Finished Game Start 0 second callback")
    endfunction	
            
    private function Init takes nothing returns nothing
        set GameInitTimer = CreateTimer()
        call TimerStart(GameInitTimer, GAME_INIT_TIME_INITIAL, false, function First)
        
		static if DEBUG_MODE then
			call TimerStart(CreateTimer(), 1.0, false, function CheckInitFinished)
		endif
		
        //call level initalizer
		call EDWLevelContent_Initialize()
		
		//call cinematic initalizer after levels are ready
		call EDWCinematicContent_Initialize()
		
		static if DEBUG_MODE then
			set FinishedPreLoad = true
		endif
		debug 
    endfunction
endlibrary