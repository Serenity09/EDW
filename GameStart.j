library EDWGameStart initializer Init requires TimerUtils, Levels, EDWVisualVote, UnitGlobals, MazerGlobals, GameMessage, EDWLevelContent, EDWCinematicContent, Recycle, AsyncInit
    globals
        constant real GAME_INIT_TIME_INITIAL = 0.01 //how long into the game before we start
        //constant real GAME_INIT_TIME_STEP = .5
		
		private boolean FinishedPreLoad = false
		private boolean FinishedPostLoad = false
		
		private constant boolean DEBUG_PRELOAD = false
		private constant boolean DEBUG_PRELOAD_FULL = false
		private constant boolean DEBUG_POSTLOAD = false
    endglobals
                       
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
                //call AddUnitLocust(CreateUnit(Player(11), UBOUNCE, GetUnitX(u), GetUnitY(u), 90))
				call Recycle_MakeUnit(UBOUNCE, GetUnitX(u), GetUnitY(u))
                call RemoveUnit(u)
            elseif uID == LBOUNCE then
                //call AddUnitLocust(CreateUnit(Player(11), LBOUNCE, GetUnitX(u), GetUnitY(u), 180))
				call Recycle_MakeUnit(LBOUNCE, GetUnitX(u), GetUnitY(u))
                call RemoveUnit(u)
            elseif uID == DBOUNCE then
                // call AddUnitLocust(CreateUnit(Player(11), DBOUNCE, GetUnitX(u), GetUnitY(u), 270))
				call Recycle_MakeUnit(DBOUNCE, GetUnitX(u), GetUnitY(u))
                call RemoveUnit(u)
            elseif uID == RBOUNCE then
                // call AddUnitLocust(CreateUnit(Player(11), RBOUNCE, GetUnitX(u), GetUnitY(u), 0))
				call Recycle_MakeUnit(RBOUNCE, GetUnitX(u), GetUnitY(u))
                call RemoveUnit(u)
			//elseif GetPlayerId(GetOwningPlayer(u)) == 11 and (uID == BFIRE or uID == BKEY or uID == RFIRE or uID == RKEY or uID == GFIRE or uID == GKEY or uID == KEYR or uID == REGRET or uID == LMEMORY or uID == GUILT or uID == GRAVITY or uID == BOUNCER or uID == SUPERSPEED) then
			else
				call IndexedUnit.create(u)
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
	
	private function OnAsyncInit takes Deferred lastAsyncInit, Deferred allAsyncInit returns integer
		// call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "All async init finished")
		call EDWVisualVote_CreateMenu()
				
		return 0
	endfunction
            
    private function First takes nothing returns nothing
        //INITIALIZE MAP SETTINGS
        //time should be fixed at noon
        call SetFloatGameState(GAME_STATE_TIME_OF_DAY, 12.00001)
        call SetTimeOfDayScale(0)
        
        //ADD LOCUST TO ALL OF BROWNS UNITS
        call AddLocustAll()
		call EnablePreSelect(true, false)
        
        //CALL OTHER INITS
        call EDWPlayerSlotsInit()
        
        //GAME MODE INIT
        //Menu should happen after level creation so that it doesn't mess with the number of players on the intro world
        //use single players when in debug mode, now that menu is functional
        // call EDWVisualVote_CreateMenu()
		// call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "GameStart registering async callback for: " + I2S(OnAsyncInit))
		call RegisterAsyncCallback(OnAsyncInit)
        
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
		static if DEBUG_POSTLOAD then
			call DisplayTextToForce(bj_FORCE_PLAYER[0], "Finished Game Start postload callback")
		endif
		
		call ReleaseTimer(GetExpiredTimer())
    endfunction	
            
    private function Init takes nothing returns nothing
        call TimerStart(NewTimer(), GAME_INIT_TIME_INITIAL, false, function First)
        
		static if DEBUG_MODE then
			call TimerStart(CreateTimer(), 1.0, false, function CheckInitFinished)
		endif
		
		//connect editor placed units with their needed logic
        call PreplacedUnitInit()
		
		static if DEBUG_PRELOAD_FULL then
			call DisplayTextToForce(bj_FORCE_PLAYER[0], "Preload 1")
		endif
		
        //call level initalizer
		call EDWLevels_Initialize()
		
		static if DEBUG_PRELOAD_FULL then
			call DisplayTextToForce(bj_FORCE_PLAYER[0], "Preload 2")
		endif
		
		// call EDWLevelContent_Initialize()
		
		static if DEBUG_PRELOAD_FULL then
			call DisplayTextToForce(bj_FORCE_PLAYER[0], "Preload 3")
		endif
		
		//call cinematic initalizer after levels are ready
		call EDWCinematicContent_Initialize()
		
		static if DEBUG_PRELOAD_FULL then
			call DisplayTextToForce(bj_FORCE_PLAYER[0], "Preload 4")
		endif
		
		static if DEBUG_MODE then
			set FinishedPreLoad = true
		endif
		static if DEBUG_PRELOAD then
			call DisplayTextToForce(bj_FORCE_PLAYER[0], "Finished Game Start preload callback")
		endif
    endfunction
endlibrary