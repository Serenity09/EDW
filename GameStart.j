library GameStart initializer Init requires Levels, EDWVisualVote, UnitGlobals, MazerGlobals, GameMessage, EDWCinematics
    globals
        constant real GAME_INIT_TIME_INITIAL = 0.01 //how long into the game before we start
        //constant real GAME_INIT_TIME_STEP = .5
        public timer GameInitTimer        
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
            
            if uID == POWERUP_MARKER then
                call InWorldPowerup.CreateRandom(GetUnitX(u), GetUnitY(u))
                call RemoveUnit(u)
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
            
    public function First takes nothing returns nothing
        //INITIALIZE MAP SETTINGS
        //time should be fixed at noon
        call SetFloatGameState(GAME_STATE_TIME_OF_DAY, 12.00001)
        call SetTimeOfDayScale(0)
        
        //ADD LOCUST TO ALL OF BROWNS UNITS
        call AddLocustAll()
        
        //CALL OTHER INITS
        call PlayerInit()
        call PreplacedUnitInit()
        
        //GAME MODE INIT
        //Menu should happen after level creation so that it doesn't mess with the number of players on the intro world
        //use single players when in debug mode, now that menu is functional
        call EDWVisualVote_CreateMenu()
        
        debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Finished GameStart")
    endfunction
            
    public function Init takes nothing returns nothing
        set GameInitTimer = CreateTimer()
        call TimerStart(GameInitTimer, GAME_INIT_TIME_INITIAL, false, function GameStart_First)
        
        //call level initalizer, in EDWInitializedContent -- library EDWLevels
		call EDWLevels_Initialize()
		
		//call cinematic initalizer after levels are ready, in EDWInitializedContent -- library EDWCinematics
		call EDWCinematics_Initialize()
    endfunction
endlibrary