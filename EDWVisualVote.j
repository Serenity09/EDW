library EDWVisualVote requires VisualVote, ContinueGlobals, Teams, PlayerUtils, MazerGlobals
    globals
        //public VisualVote_voteMenu MyMenu
        
        private constant real VOTE_TIME_ROUND_ONE = 10
		private constant real VOTE_TIME_ROUND_TWO = 10
		private constant boolean FORCE_MENU = false
    endglobals
    
    public function GetFirstLevel takes nothing returns Levels_Level
        if DEBUG_MODE or CONFIGURATION_PROFILE != RELEASE then
            //3 == first ice level
            //24/31 == last ice levels
            //9 == first platforming level
            
            //66 == debug platform testing
            return Levels_Level(23)
            //return Levels_Levels[23]
        else
            return Levels_Level(1)
        endif
    endfunction
        
    public function GameModeSolo takes nothing returns nothing
        //call DisplayTextToPlayer(Player(0), 0, 0, "solo")
                
        set GameMode = 0
    endfunction
    
    public function GameModeRandom takes nothing returns nothing
        //call DisplayTextToPlayer(Player(0), 0, 0, "random")
        
        set GameMode = 2
    endfunction
    
    public function GameModeAllIsOne takes nothing returns nothing        
        //call DisplayTextToPlayer(Player(0), 0, 0, "all is one")
        
        set GameMode = 1
    endfunction
    
    public function RewardStandard takes nothing returns nothing
        //call DisplayTextToPlayer(Player(0), 0, 0, "standard")
        
        set RewardMode = 0
    endfunction
    
    public function RewardChallenge takes nothing returns nothing
        //call DisplayTextToPlayer(Player(0), 0, 0, "challenge")
        
        set RewardMode = 1
    endfunction
    
    public function Reward99AndNone takes nothing returns nothing
        //call DisplayTextToPlayer(Player(0), 0, 0, "99 and none")
        
        set RewardMode = 2
    endfunction
    
    public function MinigamesOn takes nothing returns nothing
        //call DisplayTextToPlayer(Player(0), 0, 0, "minigames on (actually off)")
        
        //no minigames yet!
        set MinigamesMode = false
        //set MinigamesMode = true
    endfunction
    public function MinigamesOff takes nothing returns nothing
        //call DisplayTextToPlayer(Player(0), 0, 0, "minigames off")
        
        set MinigamesMode = false
    endfunction
    
    public function InstantRespawnOn takes nothing returns nothing
        //call DisplayTextToPlayer(Player(0), 0, 0, "respawn ASAP on")
        
        set RespawnASAPMode = true
    endfunction
    public function InstantRespawnOff takes nothing returns nothing
        //call DisplayTextToPlayer(Player(0), 0, 0, "respawn ASAP off")
        
        set RespawnASAPMode = false
    endfunction
	
	private function FadeCBTwo takes nothing returns nothing
		local timer t = GetExpiredTimer()
		local SimpleList_ListNode fp = PlayerUtils_FirstPlayer
		
		call DisplayCineFilter(false)
		call EnableUserUI(true)
		
		loop
		exitwhen fp == 0
			call PauseUnit(MazersArray[fp.value], false)
			//call mt.ChangePlayerVision(Levels_Levels[0].Vision)
		set fp = fp.next
		endloop
		
		call DestroyTimer(t)
		set t = null
	endfunction
	private function FadeCBOne takes nothing returns nothing
		local timer t = GetExpiredTimer()
		
		
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
		
		call TimerStart(t, 3, false, function FadeCBTwo)
		set t = null
	endfunction
    
	public function InitializeGameForGlobals takes nothing returns nothing
		local SimpleList_ListNode fp = PlayerUtils_FirstPlayer
        
        local integer count = GetHumanPlayersCount()
        local Teams_MazingTeam array team
        local integer i = 0
        local integer teamCount = 1
        local integer array teamSize
        local integer array teamSlotsRemaining
        
        local integer rand
        local boolean flag
        local Levels_Level firstLevel
		
		local Cinematic welcomeCine
        local CinemaMessage cineMsg
        
        //call DisplayTextToPlayer(Player(0), 0, 0, "Initializing Game For Globals")
        //call DisplayTextToPlayer(Player(0), 0, 0, "Human count: " + I2S(count))
        
        if GameMode == 0 then
            //create a team for each player
            set i = 0
            loop
            exitwhen fp == 0
                set team[i] = Teams_MazingTeam.create(fp.value)
                call team[i].AddPlayer(fp.value)
                //call PauseUnit(MazersArray[fp.value], false)
                //call mt.ChangePlayerVision(Levels_Levels[0].Vision)
                set team[i].Weight = 1
            set fp = fp.next
            set i = i + 1
            endloop
            
            set teamCount = i
        elseif GameMode == 1 then
            //one team for all players
            set team[0] = Teams_MazingTeam.create(0)
            loop
            exitwhen fp == 0
                call team[0].AddPlayer(fp.value)
                //call PauseUnit(MazersArray[fp.value], false)
                //call mt.ChangePlayerVision(Levels_Levels[0].Vision)
            set fp = fp.next
            endloop
            
            set team[0].Weight = 1
        elseif GameMode == 2 then
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
            //call DisplayTextToForce(bj_FORCE_PLAYER[0], "Team Count: " + I2S(teamCount))
            //create teams
            set i = 0
            loop
                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Team Size: " + I2S(teamSize[i]))
                set team[i] = Teams_MazingTeam.create(i)
                set teamSlotsRemaining[i] = teamSize[i]
                
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
                        //call DisplayTextToForce(bj_FORCE_PLAYER[0], "Added player: " + I2S(fp.value) + " to team: " + I2S(i))
                        
                        set count = count - 1
                        set teamSlotsRemaining[i] = teamSlotsRemaining[i] - 1
                        
                        set flag = true //this loop ends after a player is added to a random group
                    else
                        set rand = rand - teamSlotsRemaining[i]
                        //call DisplayTextToForce(bj_FORCE_PLAYER[0], "No room in team: " + I2S(i))
                    endif
                    
                    set i = i + 1
                exitwhen flag or i >= teamCount
                endloop
            set fp = fp.next
            endloop            
        else
            call DisplayTextToForce(bj_FORCE_PLAYER[0], "Invalid Gamemode!")
            return
        endif
        
        //determine starting continues
        call Teams_MazingTeam.ComputeTeamWeights()
                
        //get first level -- mostly for debugging, should always be 0 in release
        set firstLevel = GetFirstLevel()
        call firstLevel.Start()
        
        //debug call DisplayTextToPlayer(Player(0), 0, 0, "Team count " + I2S(teamCount))
        
		set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage(FINAL_BOSS_PRE_REVEAL, "Welcome", DEFAULT_TEXT_COLOR), DEFAULT_TINY_TEXT_SPEED)
        set welcomeCine = Cinematic.create(null, false, false, cineMsg)
        call welcomeCine.AddMessage(null, GetEDWSpeakerMessage(FINAL_BOSS_PRE_REVEAL, "To", DEFAULT_TEXT_COLOR), DEFAULT_TINY_TEXT_SPEED)
        call welcomeCine.AddMessage(null, GetEDWSpeakerMessage(FINAL_BOSS_PRE_REVEAL, "Dream World", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
		
        set i = 0
        loop
            set team[i].OnLevel = firstLevel
            set team[i].ContinueCount = team[i].GetInitialContinues()
            
            //call team[i].MoveRevive(firstLevel.CPCenters[0])
            //set team[i].DefaultGameMode = firstLevel.CPDefaultGameModes[0]
            //call team[i].SwitchTeamGameMode(team[i].DefaultGameMode, GetRandomReal(GetRectMinX(team[i].Revive), GetRectMaxX(team[i].Revive)), GetRandomReal(GetRectMinY(team[i].Revive), GetRectMaxY(team[i].Revive)))
            
            call team[i].ApplyTeamDefaultCameras()
            call team[i].AddTeamVision(firstLevel.Vision)
			
			static if not DEBUG_MODE then
				call team[i].AddTeamCinema(welcomeCine, team[i].FirstUser.value)
			endif
			
            call firstLevel.ActiveTeams.add(team[i])
			
			call firstLevel.SetCheckpointForTeam(team[i], 0)
			
            debug call DisplayTextToPlayer(Player(0), 0, 0, "Team " + I2S(team[i]) + " on level: " + I2S(team[i].OnLevel))
        set i = i + 1
        exitwhen i >= teamCount
        endloop
		
		static if not DEBUG_MODE then
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
			
			call TimerStart(CreateTimer(), 3, false, function FadeCBOne)
		else
			set fp = PlayerUtils_FirstPlayer
			loop
			exitwhen fp == 0
				call PauseUnit(MazersArray[fp.value], false)
				//call mt.ChangePlayerVision(Levels_Levels[0].Vision)
			set fp = fp.next
			endloop
		endif
		
        //apply the player's (custom) Default camerasetup and pan to their default mazer
        //call SelectAndPanAllDefaultUnits()
        
        call Teams_MazingTeam.MultiboardSetupInit()
        
        //call DisplayTextToForce(bj_FORCE_PLAYER[0], "Finished Initializing Game For Globals!")
	endfunction
    
	public function OnRoundOneFinishCB takes nothing returns nothing
		local VisualVote_voteMenu MyMenu
		local VisualVote_voteColumn col
        local VisualVote_voteContainer con
        local VisualVote_voteOption opt   
		
		if GameMode != 0 then
			//start round 2 of voting!
			set MyMenu = VisualVote_voteMenu.create(3060, 5800, VOTE_TIME_ROUND_TWO, "EDWVisualVote_InitializeGameForGlobals")
			call MyMenu.addAllPlayersToMenu()
			
			set col = MyMenu.addColumn(512)
            
            set con = col.addContainer("Respawn Wait Style")
            set con.required = true
            
            call con.addOption("Leeeeeroy Jenkinsss", "EDWVisualVote_InstantRespawnOn")
            set opt = con.addOption("We Band of Brothers", "EDWVisualVote_InstantRespawnOff")
            set con.defaultOption = opt
			
			call MyMenu.render()
            call MyMenu.enforceVoteMode()
		else
			set RespawnASAPMode = true
			set MinigamesMode = false
			
			call InitializeGameForGlobals()
		endif
	endfunction
    
    //TODO add 2 stage menu, first choose team or solo -- then specify for final options
    public function CreateMenu takes nothing returns nothing
		local VisualVote_voteMenu MyMenu
		local VisualVote_voteColumn col
        local VisualVote_voteContainer con
        local VisualVote_voteOption opt        

		if not FORCE_MENU and DEBUG_MODE then
        //static if DEBUG_MODE and false then
            call CreateFogModifierRectBJ(true, Player(0), FOG_OF_WAR_VISIBLE, GetPlayableMapRect())
			
			set GameMode = GameModesGlobals_TEAMALL
            //99 and none
            set RewardMode = 2
            //respawn as soon as you die
            set RespawnASAPMode = false
            //currently unimplemented
            set MinigamesMode = false
            
            call InitializeGameForGlobals()
		elseif GetHumanPlayersCount() == 1 then
			set GameMode = GameModesGlobals_SOLO
			set RespawnASAPMode = true
			set MinigamesMode = false
			
			set MyMenu = VisualVote_voteMenu.create(3060, 5800, VOTE_TIME_ROUND_ONE, null)
            set MyMenu.onDestroyFinish = "EDWVisualVote_InitializeGameForGlobals"
            call MyMenu.addAllPlayersToMenu()
			
			set col = MyMenu.addColumn(512)
			
			set con = col.addContainer("Difficulty")
            set con.required = true
			call con.addOption("Vanilla", "EDWVisualVote_RewardStandard")
            call con.addOption("Chocolate", "EDWVisualVote_RewardChallenge")
            set opt = con.addOption("99 and None", "EDWVisualVote_Reward99AndNone")
            set con.defaultOption = opt
			
			call MyMenu.render()
            call MyMenu.enforceVoteMode()
        else
            set MyMenu = VisualVote_voteMenu.create(3060, 5800, VOTE_TIME_ROUND_ONE, null)
            set MyMenu.onDestroyFinish = "EDWVisualVote_OnRoundOneFinishCB"
            call MyMenu.addAllPlayersToMenu()
            //set MyMenu = VisualVote_voteMenu.create(-1600, 7556)
            
            set col = MyMenu.addColumn(512)
            //
            set con = col.addContainer("Teams")
            set con.required = true
            
            call con.addOption("Solo", "EDWVisualVote_GameModeSolo")
            set opt = con.addOption("Teams - Mixer", "EDWVisualVote_GameModeRandom")
            set con.defaultOption = opt
            set opt = con.addOption("Teams - One for All", "EDWVisualVote_GameModeAllIsOne")
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Default: " + con.defaultOption.text)
            
			set con = col.addContainer("Difficulty")
            set con.required = true
            
            call con.addOption("Vanilla", "EDWVisualVote_RewardStandard")
            call con.addOption("Chocolate", "EDWVisualVote_RewardChallenge")
            set opt = con.addOption("99 and None", "EDWVisualVote_Reward99AndNone")
            set con.defaultOption = opt
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Default: " + con.defaultOption.text)
            
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Default: " + con.defaultOption.text)
			set col = MyMenu.addColumn(512)
			
            set con = col.addContainer("Contests")
            set con.required = false
            set con.enabled = false
            set opt = con.addOption("yea", "EDWVisualVote_MinigamesOn")
            set opt = con.addOption("nei", "EDWVisualVote_MinigamesOn")
            call opt.setDefault()

            set con = col.addContainer("RPG Mode")
            set con.required = false
            set con.enabled = false
            set opt = con.addOption("yea", "EDWVisualVote_MinigamesOn")
            set opt = con.addOption("nei", "EDWVisualVote_MinigamesOn")
            call opt.setDefault()
            
            call MyMenu.render()
            
            call MyMenu.enforceVoteMode()
        endif
    endfunction
endlibrary