library EDWVisualVoteCallback requires GameModesGlobals, ConfigurationMode, TimerUtils, Teams, SimpleList, Levels, Cinema, EDWLevelContent, EDWCinematicContent
    globals
        constant boolean DEBUG_MODE_INITIALIZATION = false
        private constant boolean DEBUG_GAME_INITIALIZATION = false
    endglobals

    
    function GameModeSolo takes nothing returns nothing
        static if DEBUG_MODE_INITIALIZATION then
            call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "solo")
        endif
                
        set GameMode = GameModesGlobals_SOLO
    endfunction
    
    function GameModeRandom takes nothing returns nothing
        static if DEBUG_MODE_INITIALIZATION then
            call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "random")
        endif
        
        set GameMode = GameModesGlobals_TEAMRANDOM
    endfunction
    
    function GameModeAllIsOne takes nothing returns nothing        
        static if DEBUG_MODE_INITIALIZATION then
            call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "all is one")
        endif
        
        set GameMode = GameModesGlobals_TEAMALL
    endfunction
    
    function RewardStandard takes nothing returns nothing
        static if DEBUG_MODE_INITIALIZATION then
            call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "standard")
        endif
        
        set RewardMode = GameModesGlobals_EASY
    endfunction
    
    function RewardChallenge takes nothing returns nothing
        static if DEBUG_MODE_INITIALIZATION then
            call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "challenge")
        endif
        
        set RewardMode = GameModesGlobals_HARD
    endfunction
    
    function Reward99AndNone takes nothing returns nothing
        static if DEBUG_MODE_INITIALIZATION then
            call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "99 and none")
        endif
        
        set RewardMode = GameModesGlobals_CHEAT
    endfunction
    
    function MinigamesOn takes nothing returns nothing
        static if DEBUG_MODE_INITIALIZATION then
            call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "minigames on (actually off)")
        endif
        
        //no minigames yet!
        set MinigamesMode = false
        //set MinigamesMode = true
    endfunction
    function MinigamesOff takes nothing returns nothing
        static if DEBUG_MODE_INITIALIZATION then
            call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "minigames off")
        endif
        
        set MinigamesMode = false
    endfunction
    
    function InstantRespawnOn takes nothing returns nothing
        static if DEBUG_MODE_INITIALIZATION then
            call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "respawn ASAP on")
        endif
        
        set RespawnASAPMode = true
		set RespawnPauseTime = 2.5
    endfunction
    function InstantRespawnOff takes nothing returns nothing
        static if DEBUG_MODE_INITIALIZATION then
            call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "respawn ASAP off")
        endif
        
        set RespawnASAPMode = false
		set RespawnPauseTime = 1.5
    endfunction


    private function FadeCBTwo takes nothing returns nothing
		call DisplayCineFilter(false)
		call EnableUserUI(true)
						
		call ReleaseTimer(GetExpiredTimer())
	endfunction
	private function FadeCBOne takes nothing returns nothing
		call DisplayCineFilter(false)
		
		call SetCineFilterTexture("ReplaceableTextures\\CameraMasks\\Black_mask.blp")
		call SetCineFilterBlendMode(BLEND_MODE_BLEND)
		call SetCineFilterTexMapFlags(TEXMAP_FLAG_NONE)
		call SetCineFilterStartUV(0, 0, 1, 1)
		call SetCineFilterEndUV(0, 0, 1, 1)
		call SetCineFilterStartColor(PercentTo255(100), PercentTo255(100), PercentTo255(100), PercentTo255(100))
		call SetCineFilterEndColor(PercentTo255(100), PercentTo255(100), PercentTo255(100), PercentTo255(0))
		call SetCineFilterDuration(3)
		call DisplayCineFilter(true)
		
		//call EnableUserUI(true)
		
		call TimerStart(GetExpiredTimer(), 3, false, function FadeCBTwo)
	endfunction
	private function MultiboardMinimizeCB takes nothing returns nothing
		// call MultiboardMinimize(Teams_MazingTeam.PlayerStats, true)
		call Teams_MazingTeam.MinimizeMultiboardAll(true)
		
		call ReleaseTimer(GetExpiredTimer())
	endfunction
    
    
	function InitializeGameForGlobals takes nothing returns nothing
		local SimpleList_ListNode fp = PlayerUtils_FirstPlayer
        
        local integer count = GetHumanPlayersCount()
        local Teams_MazingTeam array team
        local integer i = 0
        local integer teamCount = 1
        local integer array teamSize
        local integer array teamSlotsRemaining
        
        local integer rand
        local boolean flag
		
		//get first level -- mostly for debugging, should always be 0 in release
        local Levels_Level firstLevel = Levels_Level(GetFirstLevelID())
		
		local real welcomeCineTime = 0
		local Cinematic welcomeCine
        local CinemaMessage cineMsg
        
        static if DEBUG_GAME_INITIALIZATION then
            call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Initializing Game For Globals")
            call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Human count: " + I2S(count))
        endif
        
		//initialize victory time before content and cinematics, so they can depend on its value
		if RewardMode == GameModesGlobals_HARD then
			set VictoryTime = 30 * 60
		endif

		//now that difficulty is set, we can initialize all startable content
		call EDWLevelContent_Initialize()

        static if DEBUG_GAME_INITIALIZATION then
            call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Finished Level Content Init")
        endif

        //call cinematic initalizer after levels are ready
		call EDWCinematicContent_Initialize()

        static if DEBUG_GAME_INITIALIZATION then
            call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Finished Cinematic Content Init")
        endif
		
        //hard mode victory score is equal to the raw score total of all vanilla levels
		//initialize after level content, in case that content ever modifies its level's score
        if RewardMode == GameModesGlobals_HARD then
            set VictoryScore = Levels_Level.GetTotalRawScore()
        endif

        if GameMode == GameModesGlobals_SOLO then
            //create a team for each player
            set i = 0
            loop
            exitwhen fp == 0
                set team[i] = Teams_MazingTeam.create()
                call team[i].AddPlayer(fp.value)
                set team[i].Weight = 1
            set fp = fp.next
            set i = i + 1
            endloop
            
            set teamCount = i
        elseif GameMode == GameModesGlobals_TEAMALL then
            //one team for all players
            set team[0] = Teams_MazingTeam.create()
            loop
            exitwhen fp == 0
                call team[0].AddPlayer(fp.value)
            set fp = fp.next
            endloop
            
            set team[0].Weight = 1
        else //if GameMode == GameModesGlobals_TEAMRANDOM then
            //define team sizes
            if count == 1 or count == 2 or count == 3 then
                if GetRandomInt(0, 1) == 0 then
					//1v1 or 1v1v1
					set teamCount = count
					
					//set all teams to have size = 1
					set i = 0
					loop
						set teamSize[i] = 1
						
					set i = i + 1
					exitwhen i >= count
					endloop
				else
					//all on same team
					set teamCount = 1
					set teamSize[0] = count
				endif
            elseif count == 4 or count == 6 or count == 8 then
                if count == 4 then
                    set teamCount = 2
                elseif count == 6 then
                    if GetRandomInt(0, 1) == 0 then
                        //3v3
                        set teamCount = 2
                    else
                        //2v2v2
                        set teamCount = 3
                    endif
                elseif count == 8 then
                    if GetRandomInt(0, 1) == 0 then
                        //4v4
                        set teamCount = 2
                    else
                        //2v2v2v2
                        set teamCount = 4
                    endif
                endif
                
                set i = 0
                loop
                    set teamSize[i] = count / teamCount
                    
                    set i = i + 1
                exitwhen i >= count
                endloop
                
            elseif count == 5 then
                set teamCount = 2
                set teamSize[0] = 3
                set teamSize[1] = 2
            else //count == 7
                if (GetRandomInt(0, 1) == 0) then
                    //4v3
                    set teamCount = 2
                    set teamSize[0] = 4
                    set teamSize[1] = 3
                else
                    //3v2v2
                    set teamCount = 3
                    set teamSize[0] = 3
                    set teamSize[1] = 2
                    set teamSize[2] = 2
                endif
            endif

            static if DEBUG_GAME_INITIALIZATION then
                call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Team Count: " + I2S(teamCount))
            endif

            //create teams
            set i = 0
            loop
                set team[i] = Teams_MazingTeam.create()
                set teamSlotsRemaining[i] = teamSize[i]

                static if DEBUG_GAME_INITIALIZATION then
                    call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Created Team: " + I2S(team[i]) + ", Team Size: " + I2S(teamSize[i]))
                endif
                
                set i = i + 1
            exitwhen i >= teamCount
            endloop
            
            //randomly place players in teams        
            loop
            exitwhen fp == 0
                //roll a random number that corresponds to player i's assigned team
                set rand = GetRandomInt(0, count) //count is both a measure of number players left teamless and number slots remaining
                //call DisplayTextToForce(bj_FORCE_PLAYER[0], "Rand: " + I2S(rand) + " remaining: " + I2S(count))
                //place player i into the 0 based slot # (rand) of the available remaining slots
                set i = 0
                set flag = false
                loop
                    if teamSlotsRemaining[i] != 0 and teamSlotsRemaining[i] >= rand then
                        call team[i].AddPlayer(fp.value)
                        //call PauseUnit(MazersArray[fp.value], false)
                        static if DEBUG_GAME_INITIALIZATION then
                            call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Added player: " + I2S(fp.value) + " to team: " + I2S(team[i]))
                        endif
                        
                        set count = count - 1
                        set teamSlotsRemaining[i] = teamSlotsRemaining[i] - 1
                        
                        set flag = true //this loop ends after a player is added to a random group
                    else
                        set rand = rand - teamSlotsRemaining[i]
                        
                        static if DEBUG_GAME_INITIALIZATION then
                            call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "No room in team: " + I2S(i))
                        endif
                    endif
                    
                    set i = i + 1
                exitwhen flag or i >= teamCount
                endloop
            set fp = fp.next
            endloop            
        endif
        
        //determine starting continues
        call Teams_MazingTeam.ComputeTeamWeights()
		
		//initialize multiboard
		call Teams_MazingTeam.MultiboardSetupInit()

        static if DEBUG_GAME_INITIALIZATION then
            call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Finished Multiboard Init")
        endif
				
		if GameMode == GameModesGlobals_SOLO then
			set cineMsg = CinemaMessage.createEx(null, null, 'CiTS', DEFAULT_MEDIUM_TEXT_SPEED)
			set welcomeCineTime = welcomeCineTime + DEFAULT_MEDIUM_TEXT_SPEED
		elseif GameMode == GameModesGlobals_TEAMALL then
			set cineMsg = CinemaMessage.createEx(null, null, 'CiTO', DEFAULT_MEDIUM_TEXT_SPEED)
			set welcomeCineTime = welcomeCineTime + DEFAULT_MEDIUM_TEXT_SPEED
		else //TEAMRANDOM
			set cineMsg = CinemaMessage.createEx(null, null, 'CiTR', DEFAULT_MEDIUM_TEXT_SPEED)
			set welcomeCineTime = welcomeCineTime + DEFAULT_MEDIUM_TEXT_SPEED
		endif
		
		set welcomeCine = Cinematic.create(null, true, true, cineMsg)
		
		if RewardMode == GameModesGlobals_EASY then
			call welcomeCine.AddMessage(CinemaMessage.createEx(null, null, 'CiDE', DEFAULT_MEDIUM_TEXT_SPEED))
			set welcomeCineTime = welcomeCineTime + DEFAULT_MEDIUM_TEXT_SPEED
		elseif RewardMode == GameModesGlobals_HARD then
			call welcomeCine.AddMessage(CinemaMessage.createEx(null, null, 'CiDH', DEFAULT_SHORT_TEXT_SPEED))
			set welcomeCineTime = welcomeCineTime + DEFAULT_SHORT_TEXT_SPEED
		else //CHEAT
			call welcomeCine.AddMessage(CinemaMessage.createEx(null, null, 'CiDC', DEFAULT_LONG_TEXT_SPEED))
			set welcomeCineTime = welcomeCineTime + DEFAULT_LONG_TEXT_SPEED
		endif
		
		call TimerStart(NewTimer(), welcomeCineTime + .5, false, function MultiboardMinimizeCB)
		
		call welcomeCine.SetLastMessageBuffer(1)
		set welcomeCineTime = welcomeCineTime + 1

		call welcomeCine.AddMessage(CinemaMessage.createEx(null, FINAL_BOSS_PRE_REVEAL, 'CiW1', DEFAULT_TINY_TEXT_SPEED))
        call welcomeCine.AddMessage(CinemaMessage.createEx(null, FINAL_BOSS_PRE_REVEAL, 'CiW2', DEFAULT_TINY_TEXT_SPEED))
        call welcomeCine.AddMessage(CinemaMessage.createEx(null, FINAL_BOSS_PRE_REVEAL, 'CiW3', DEFAULT_SHORT_TEXT_SPEED))
		
		set welcomeCineTime = welcomeCineTime + 2 * DEFAULT_TINY_TEXT_SPEED //don't include last message, more dramatic that way
		
        set i = 0
        loop            
            call team[i].ApplyTeamDefaultCameras()

			if ShouldShowSettingVoteMenu() or FORCE_INTRO_REVEAL then
            // if false and ShouldShowSettingVoteMenu() or FORCE_INTRO_REVEAL then
				call team[i].AddTeamCinema(welcomeCine, team[i].FirstUser.value)
			endif
						
		    call firstLevel.StartLevelForTeam(team[i])
			
			if ShouldShowSettingVoteMenu() or FORCE_INTRO_REVEAL then
			 	call team[i].CancelAutoUnpauseForTeam()
			endif
						
            //debug call DisplayTextToPlayer(Player(0), 0, 0, "Team " + I2S(team[i]) + " on level: " + I2S(team[i].OnLevel))
        set i = i + 1
        exitwhen i >= teamCount
        endloop
				
		if ShouldShowSettingVoteMenu() or FORCE_INTRO_REVEAL then
			call EnableUserUI(false)
			call SetCineFilterTexture("ReplaceableTextures\\CameraMasks\\Black_mask.blp")
			call SetCineFilterBlendMode(BLEND_MODE_BLEND)
			call SetCineFilterTexMapFlags(TEXMAP_FLAG_NONE)
			call SetCineFilterStartUV(0, 0, 1, 1)
			call SetCineFilterEndUV(0, 0, 1, 1)
			call SetCineFilterStartColor(PercentTo255(100), PercentTo255(100), PercentTo255(100), PercentTo255(100))
			call SetCineFilterEndColor(PercentTo255(100), PercentTo255(100), PercentTo255(100), PercentTo255(100))
			call SetCineFilterDuration(0)
			call DisplayCineFilter(true)
			
			call TimerStart(NewTimer(), welcomeCineTime, false, function FadeCBOne)
		else
			set fp = PlayerUtils_FirstPlayer
			loop
			exitwhen fp == 0
				call PauseUnit(MazersArray[fp.value], false)
			set fp = fp.next
			endloop
		endif
		
        //apply the player's (custom) Default camerasetup and pan to their default mazer
        //call SelectAndPanAllDefaultUnits()
        
		if CONFIGURATION_PROFILE == DEV or RewardMode == GameModesGlobals_CHEAT then
			set i = 0
			loop
				call team[i].SetContinueCount(99)
			set i = i + 1
			exitwhen i >= teamCount
			endloop
		endif
		
        static if DEBUG_MODE_INITIALIZATION then
            call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Finished Initializing Game For Globals!")
        endif
	endfunction
endlibrary


library EDWVisualVote requires ConfigurationMode, VisualVote, Teams, PlayerUtils
    globals
        //public VisualVote_voteMenu MyMenu
        
        private constant real VOTE_TIME_ROUND_ONE = 10
		private constant real VOTE_TIME_ROUND_TWO = 10

        private constant integer DIFFICULTY_CONTAINER_CONTENT_ID = 'VVDT'
        private constant integer DIFFICULTY_EASY_CONTENT_ID = 'VVDE'
        private constant integer DIFFICULTY_HARD_CONTENT_ID = 'VVDC'
        private constant integer DIFFICULTY_99_CONTENT_ID = 'VVD9'

        private constant integer TEAM_CONTAINER_CONTENT_ID = 'VVTT'
        private constant integer TEAM_SOLO_CONTENT_ID = 'VVTS'
        private constant integer TEAM_RANDOM_CONTENT_ID = 'VVTR'
        private constant integer TEAM_ALL_CONTENT_ID = 'VVTO'
    endglobals

    private function InitializeGlobalsForVote takes nothing returns nothing
        local VisualVote_voteMenu menu = VisualVote_LastFinishedMenu
        
        local integer iVC = 0
        local VisualVote_voteColumn vc
        local integer iVCont
        local VisualVote_voteContainer vCont

        local VisualVote_voteOption majorityOption

        static if DEBUG_MODE_INITIALIZATION then
            call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Initializing Globals For Vote")
            call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Vote Menu: " + I2S(menu))
        endif

        //execute majority option for each container, regardless of if everyones voted or not
        set iVC = 0
        loop
        exitwhen iVC >= menu.voteColumnCount
            set vc = menu.voteColumns[iVC]
            set iVCont = 0
            
            set majorityOption = 0
            loop
            exitwhen iVCont > vc.voteContainerCount
                set vCont = vc.voteContainers[iVCont]
                set majorityOption = vCont.getMajorityOption()

                if majorityOption.contentID == DIFFICULTY_EASY_CONTENT_ID then
                    call RewardStandard()
                elseif majorityOption.contentID == DIFFICULTY_HARD_CONTENT_ID then
                    call RewardChallenge()
                elseif majorityOption.contentID == DIFFICULTY_99_CONTENT_ID then
                    call Reward99AndNone()
                elseif majorityOption.contentID == TEAM_SOLO_CONTENT_ID then
                    call GameModeSolo()
                elseif majorityOption.contentID == TEAM_RANDOM_CONTENT_ID then
                    call GameModeRandom()
                elseif majorityOption.contentID == TEAM_ALL_CONTENT_ID then
                    call GameModeAllIsOne()
                endif
            set iVCont = iVCont + 1
            endloop
        set iVC = iVC + 1
        endloop
    endfunction
    public function OnVoteFinish takes nothing returns nothing
        if ShouldShowSettingVoteMenu() then
            call InitializeGlobalsForVote()
        endif

        call InitializeGameForGlobals()
    endfunction

	// public function OnRoundOneFinishCB takes nothing returns nothing
	// 	local VisualVote_voteMenu MyMenu
	// 	local VisualVote_voteColumn col
    //     local VisualVote_voteContainer con
    //     local VisualVote_voteOption opt   
		
	// 	if GameMode != 0 then
	// 		/*
	// 		//start round 2 of voting!
	// 		set MyMenu = VisualVote_voteMenu.create(3060, 5800, VOTE_TIME_ROUND_TWO, "EDWVisualVote_InitializeGameForGlobals")
	// 		call MyMenu.addAllPlayersToMenu()
			
	// 		set col = MyMenu.addColumn(512)
            
    //         set con = col.addContainer("Respawn Wait Style")
    //         set con.required = true
            
    //         call con.addOption("Leeeeeroy Jenkinsss", "EDWVisualVote_InstantRespawnOn")
    //         set opt = con.addOption("We Band of Brothers", "EDWVisualVote_InstantRespawnOff")
    //         set con.defaultOption = opt
			
	// 		call MyMenu.render()
    //         call MyMenu.enforceVoteMode()
	// 		*/
			
	// 		//I think I actually like just always setting game to We Band of Brothers
	// 		set RespawnASAPMode = false
	// 		set MinigamesMode = false
			
	// 		call InitializeGameForGlobals()
	// 	else
	// 		set RespawnASAPMode = true
	// 		set MinigamesMode = false
			
	// 		call InitializeGameForGlobals()
	// 	endif
	// endfunction
    
	public function CreateMenu takes nothing returns nothing
		local VisualVote_voteMenu MyMenu
		local VisualVote_voteColumn col
        local VisualVote_voteContainer con
        local VisualVote_voteOption opt        
		
        //defaults
        set GameMode = DEBUG_TEAM_MODE
        set RewardMode = DEBUG_DIFFICULTY_MODE
        //respawn as soon as you die
        call InstantRespawnOff()
        //set RespawnASAPMode = false
        //currently unimplemented
        call MinigamesOff()
        //set MinigamesMode = false

		if not ShouldShowSettingVoteMenu() then
			//TODO replace with awaiting an .All promise for User async property init
			if DEBUG_USE_FULL_VISIBILITY then
				call CreateFogModifierRectBJ(true, Player(0), FOG_OF_WAR_VISIBLE, GetPlayableMapRect())
			endif
				
			// set GameMode = DEBUG_TEAM_MODE
			// set RewardMode = DEBUG_DIFFICULTY_MODE
			// //respawn as soon as you die
			// call InstantRespawnOff()
			// //set RespawnASAPMode = false
			// //currently unimplemented
			// call MinigamesOff()
			// //set MinigamesMode = false
			
			call InitializeGameForGlobals()
			
			call Teams_MazingTeam.MinimizeMultiboardAll(true)
			// call MultiboardMinimize(Teams_MazingTeam.PlayerStats, true)
			
			if GetFirstLevelID() != INTRO_LEVEL_ID then
				call TrackGameTime()
			endif
			
			call DestroyTimer(GetExpiredTimer())
		elseif GetHumanPlayersCount() == 1 then
			call GameModeSolo()
			call InstantRespawnOn()
			call MinigamesOff()
			
			set MyMenu = VisualVote_voteMenu.create(3060, 5800, VOTE_TIME_ROUND_ONE, "EDWVisualVote_OnVoteFinish")
            call MyMenu.addAllPlayersToMenu()
			
			set col = MyMenu.addColumn(512)
			
			//difficulty
			set con = col.addContainer(DIFFICULTY_CONTAINER_CONTENT_ID)
            set con.required = true
			
			set opt = con.addOption(DIFFICULTY_EASY_CONTENT_ID)
            call con.addOption(DIFFICULTY_HARD_CONTENT_ID)
            call con.addOption(DIFFICULTY_99_CONTENT_ID)
			
            set con.defaultOption = opt
			
			call MyMenu.render()
            call MyMenu.enforceVoteMode()
        else
            set MyMenu = VisualVote_voteMenu.create(3060, 5800, VOTE_TIME_ROUND_ONE, "EDWVisualVote_OnVoteFinish")
            call MyMenu.addAllPlayersToMenu()
            //set MyMenu = VisualVote_voteMenu.create(-1600, 7556)
            
            set col = MyMenu.addColumn(512)
			//teams
            set con = col.addContainer(TEAM_CONTAINER_CONTENT_ID)
            set con.required = true
			
            call con.addOption(TEAM_SOLO_CONTENT_ID)
			if User.ActivePlayers > 3 then
				call con.addOption(TEAM_RANDOM_CONTENT_ID)
			endif
            set opt = con.addOption(TEAM_ALL_CONTENT_ID)
            set con.defaultOption = opt
			//debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Default: " + con.defaultOption.text)
            
			//difficulty
			set con = col.addContainer(DIFFICULTY_CONTAINER_CONTENT_ID)
            set con.required = true
			
			set opt = con.addOption(DIFFICULTY_EASY_CONTENT_ID)
            call con.addOption(DIFFICULTY_HARD_CONTENT_ID)
            // call con.addOption('VVD9', "EDWVisualVote_Reward99AndNone")
			
            set con.defaultOption = opt
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Default: " + con.defaultOption.text)
            
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Default: " + con.defaultOption.text)
			// if CONFIGURATION_PROFILE != RELEASE then
				// set col = MyMenu.addColumn(512)
				
				// set con = col.addContainer("Contests")
				// set con.required = false
				// set con.enabled = false
				// set opt = con.addOption("yea", "EDWVisualVote_MinigamesOn")
				// set opt = con.addOption("nei", "EDWVisualVote_MinigamesOn")
				// call opt.setDefault()

				// set con = col.addContainer("RPG Mode")
				// set con.required = false
				// set con.enabled = false
				// set opt = con.addOption("yea", "EDWVisualVote_MinigamesOn")
				// set opt = con.addOption("nei", "EDWVisualVote_MinigamesOn")
				// call opt.setDefault()
            // endif
			
            call MyMenu.render()
            
            call MyMenu.enforceVoteMode()
        endif
	endfunction
	
    //2 stage menu, first choose difficulty and team breakdown -- then specify for final options
    // public function CreateMenu takes nothing returns nothing
		// call TimerStart(CreateTimer(), .25, false, function CreateMenuCB)
    // endfunction
endlibrary