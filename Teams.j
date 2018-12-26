library Teams initializer Init requires MazerGlobals, User
globals
    private constant real VOTE_TOP_LEFT_X = -15000
	private constant real VOTE_TOP_LEFT_Y = -4220
	
    public constant integer GAMEMODE_STANDARD = 0
    public constant integer GAMEMODE_PLATFORMING = 1
    public constant integer GAMEMODE_MINIGAMES = 5
    public constant integer GAMEMODE_STANDARD_PAUSED = 10
    public constant integer GAMEMODE_PLATFORMING_PAUSED = 11
    public constant integer GAMEMODE_REVIVED_BY_TEAM = 90
    public constant integer GAMEMODE_DYING = 100
    public constant integer GAMEMODE_DEAD = 101
    
    public constant real MULTIBOARD_HIDE_DELAY = 2.
	
	Teams_MazingTeam TriggerTeam //used with events
endglobals

//ASSUMPTIONS: !!IMPORTANT!!
//when creating a new MazingTeam, the game assumes that MazersArray[PlayerId(i)] = that player's starting demonhunter
//it also assumes that the platforming unit is fit to match (mistakes were made) and that all the relevant gameloops are ready to go / have been recycled properly
//this should only be relevant when first starting the game (for which it's hardcoded in already...) or if attempting to implement -restart lol

struct WorldProgress extends array
	public integer WorldID
	public Levels_Level FurthestLevel
	
	private static integer c = 1
	
	public static method create takes Levels_Level furthestLevel returns thistype
		local thistype new = c
		set c = c + 1
		
		set new.WorldID = furthestLevel.GetWorldID()
		set new.FurthestLevel = furthestLevel
		
		return new
	endmethod
endstruct

public struct MazingTeam
    readonly integer TeamID
    public SimpleList_List Users
    public SimpleList_ListNode FirstUser
    
    readonly boolean IsTeamPlaying
    readonly rect Revive
    private integer ContinueCount
    public boolean RecentlyTransferred
    public real LastTransferTime
    public Levels_Level OnLevel
    public string TeamName
    public integer OnCheckpoint //Used purely in conjunction with levels struct. ==0 refers to the initial CP for a level
    private integer Score
    public real Weight
    public integer DefaultGameMode
    public VisualVote_voteMenu VoteMenu
    
	public SimpleList_List AllWorldProgress
    //public integer DefaultGameMode
    
    public static multiboard PlayerStats
    
    readonly static MazingTeam array AllTeams[NumberPlayers]
    readonly static integer NumberTeams = 0
        
    public method MoveRevive takes rect newlocation returns nothing
        call MoveRectTo(.Revive, GetRectCenterX(newlocation), GetRectCenterY(newlocation))
    endmethod
    
    public method MoveReviveToDoors takes nothing returns nothing
        call MoveRectTo(.Revive, GetRectCenterX(gg_rct_HubWorld_R), GetRectCenterY(gg_rct_HubWorld_R))
    endmethod
    
    public method CreateMenu takes real time, string optionCB returns nothing
        local real x = VOTE_TOP_LEFT_X + R2I((TeamID + 1) / 4)
        local real y = VOTE_TOP_LEFT_Y + R2I((TeamID + 1) / 2)
        local SimpleList_ListNode cur = .FirstUser
                
        set .VoteMenu = VisualVote_voteMenu.create(x, y, time, optionCB)
        
        //register team to menu
        loop
        exitwhen cur == 0
            //pause their active unit
            if User(cur.value).GameMode == GAMEMODE_STANDARD then
                call User(cur.value).SwitchGameModesDefaultLocation(GAMEMODE_STANDARD_PAUSED)
            elseif User(cur.value).GameMode == GAMEMODE_PLATFORMING then
                call User(cur.value).SwitchGameModesDefaultLocation(GAMEMODE_PLATFORMING_PAUSED)
            endif
            
            call .VoteMenu.forPlayers.addEnd(cur.value)
        set cur = cur.next
        endloop
    endmethod
    
    public method IsTeamDead takes nothing returns boolean
        local SimpleList_ListNode fp = .FirstUser
        local integer count = 0
        
        if .IsTeamPlaying then
            loop
            exitwhen  fp == 0
                if not User(fp.value).IsPlaying or User(fp.value).GameMode == GAMEMODE_DEAD then
                    set count = count + 1
                endif
                
            set fp = fp.next
            endloop
            //call DisplayTextToForce(bj_FORCE_PLAYER[0], "count " + I2S(count) + " of " + I2S(.Users.count))
            return count == .Users.count
        else
            //call DisplayTextToForce(bj_FORCE_PLAYER[0], "team is dead, returning true")
            return true
        endif
    endmethod
	
	public method ClearCinematicQueue takes nothing returns nothing
		local SimpleList_ListNode fp = .FirstUser
		
		loop
		exitwhen fp == 0
			call User(fp.value).CinematicQueue.clear()
		set fp = fp.next
		endloop
	endmethod
    
//    public method SetDefaultTeamGameMode takes integer gameMode returns nothing
//        local SimpleList_ListNode u = .FirstUser
//        
//        set .DefaultGameMode = gameMode
//        
//        loop
//        exitwhen u == 0
//            call User(u.value).SetCurrentGameMode(gameMode)
//        set u = u.next
//        endloop
//    endmethod
    
    public method SwitchGameModeContinuous takes integer newGameMode returns nothing
        local SimpleList_ListNode u = .FirstUser
                
        loop
        exitwhen u == 0
            call User(u.value).SwitchGameModesDefaultLocation(newGameMode)
        set u = u.next
        endloop
    endmethod
    
    public method SwitchTeamGameMode takes integer newGameMode, real x, real y returns nothing
        local SimpleList_ListNode u = .FirstUser
                
        loop
        exitwhen u == 0
            call User(u.value).SwitchGameModes(newGameMode, x, y)
        set u = u.next
        endloop
    endmethod
    
    public method AddTeamVision takes rect newvision returns nothing
        local SimpleList_ListNode fp = .FirstUser
        local User u
        
        if .IsTeamPlaying then
            loop
            exitwhen fp == 0
                set u = fp.value
                if u.IsPlaying then
                    /*
					if (u.Vision != null) then
                        call FogModifierStop(u.Vision)
                    endif
					*/
                    call FogModifierStart(CreateFogModifierRect(Player(u), FOG_OF_WAR_VISIBLE, newvision, false, true))
					
					//call DisplayTextToForce(bj_FORCE_PLAYER[0], "added vision for user " + I2S(u))
                endif
                
            set fp = fp.next
            endloop
        endif
    endmethod
    
    private static method UnpauseTeam takes nothing returns nothing
        local timer t = GetExpiredTimer()
        local thistype mt = thistype(GetTimerData(t))
        local SimpleList_ListNode fp = mt.FirstUser
        local User u
        
        if mt.IsTeamPlaying then
            loop
            exitwhen fp == 0
                set u = fp.value
                if u.IsPlaying then
                    call DisplayTextToForce(bj_FORCE_PLAYER[0], "unpausing " + I2S(u))
                    call PauseUnit(u.ActiveUnit, false)
                    call IssueImmediateOrder(u.ActiveUnit, "stop")
                endif
                
            set fp = fp.next
            endloop
        endif
        
        call ReleaseTimer(t)
        set t = null
    endmethod
    
    public method ApplyTeamDefaultCameras takes nothing returns nothing
        local SimpleList_ListNode fp = .FirstUser
        local User u
        
        if .IsTeamPlaying then
            loop
            exitwhen fp == 0
                set u = fp.value
                
                if u.GameMode == GAMEMODE_STANDARD or u.GameMode == GAMEMODE_STANDARD_PAUSED then
                    if (GetLocalPlayer() == Player(u)) then
                        call CameraSetupApply(DefaultCamera[u], false, false)
                        call PanCameraToTimed(GetUnitX(u.ActiveUnit), GetUnitY(u.ActiveUnit), 0.0)
                        if DefaultCameraTracking[u] then
                            call SetCameraTargetController(u.ActiveUnit, 0, 0, false)
                        endif
                        
                        call ClearSelection()
                        call SelectUnit(u.ActiveUnit, true)
                    endif
                elseif u.GameMode == GAMEMODE_PLATFORMING or u.GameMode == GAMEMODE_PLATFORMING_PAUSED then
                    call u.Platformer.ApplyCamera()
                endif
                
            set fp = fp.next
            endloop
        endif
    endmethod
    
	public method ReviveTeam takes nothing returns nothing
		call .RespawnTeamAtRect(.Revive, true)
	endmethod
    public method RespawnTeamAtRect takes rect newlocation, boolean moveliving returns nothing
        local real x
        local real y
        local integer ttype
        local SimpleList_ListNode fp = .FirstUser
        local User u
        local timer t
        
        //call DisplayTextToForce(bj_FORCE_PLAYER[0], "Respawn start for team " + I2S(this))
        
        if .IsTeamPlaying then
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Team respawn")
            
            loop
            exitwhen fp == 0
                set u = fp.value
                
                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "respawning " + I2S(u))
                //call DisplayTextToForce(bj_FORCE_PLAYER[0], "cur " + I2S(fp) + ", next " + I2S(fp.next))
                
                call u.RespawnAtRect(newlocation, moveliving)
            set fp = fp.next
            endloop
            
			//call DisplayTextToForce(bj_FORCE_PLAYER[0], "Respawn end for team " + I2S(this))
            set t = null
        endif
    endmethod
    
    public method SetPlatformerProfile takes PlatformerProfile profile returns nothing
        local SimpleList_ListNode fp = .FirstUser
        local User u
        
        if .IsTeamPlaying then
            loop
            exitwhen fp == 0
                set u = fp.value
                if u.IsPlaying then
                    set u.Platformer.BaseProfile = profile
                endif
                
            set fp = fp.next
            endloop
        endif
    endmethod
    
    public method ApplyKeyToTeam takes integer keyID returns nothing
        local SimpleList_ListNode fp = .FirstUser
        local User u
        
        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "applying key " + I2S(keyID))
        if .IsTeamPlaying then
            loop
            exitwhen fp == 0
                set u = fp.value
                if u.IsPlaying then
                    set MazerColor[u] = keyID
                    
                    if keyID == 0 then
                        //call DisplayTextToForce(bj_FORCE_PLAYER[0], "setting 0 for pID " + I2S(PlayerIDs[i]))
                        call SetUnitVertexColor(MazersArray[u], 255, 255, 255, 255)
                    elseif keyID == 1 then
                        call SetUnitVertexColor(MazersArray[u], 255, 0, 0, 255)
                    elseif keyID == 2 then
                        call SetUnitVertexColor(MazersArray[u], 0, 0, 255, 255)
                    elseif keyID == 3 then
                        call SetUnitVertexColor(MazersArray[u], 0, 255, 0, 255)
                    endif
                endif
                
            set fp = fp.next
            endloop
        endif
    endmethod
    
    public method AddTeamCinema takes Cinematic cinema, User activatingUser returns nothing
        local SimpleList_ListNode u = .FirstUser
                
        loop
        exitwhen u == 0
            call User(u.value).AddCinematicToQueue(cinema)
        set u = u.next
        endloop
    endmethod
    
    public method PrintMessage takes string message returns nothing
        local SimpleList_ListNode fp = .FirstUser
        
        loop
        exitwhen fp == 0
            if GetLocalPlayer() == Player(fp.value) then
                call DisplayTextToPlayer(Player(fp.value), 0, 0, message)
            endif
        set fp = fp.next
        endloop
    endmethod
	public static method PrintMessageAll takes string message, MazingTeam filterTeam returns nothing
		local integer i = 0
        
        loop
        exitwhen i >= .NumberTeams
            if filterTeam == 0 or .AllTeams[i] != filterTeam then
				call .AllTeams[i].PrintMessage(message)
			endif
			
            set i = i + 1
        endloop
	endmethod
    
    //returns -1 if could not find that player in this.plist
    public method ConvertPlayerID takes integer pID returns User
        local SimpleList_ListNode fp = .FirstUser
        
        if .IsTeamPlaying then
            loop
            exitwhen fp == 0
                if User(fp.value) == pID then
                    return fp.value
                endif
                
            set fp = fp.next
            endloop
        endif
        
        return 0
    endmethod
        
    public method GetInitialContinues takes nothing returns integer
        local real weighted = STARTING_CONTINUES
        
        if RewardMode == 0 then
            set weighted = weighted * 2 * .Weight
        elseif RewardMode == 1 then
            set weighted = weighted * .Weight
        elseif RewardMode == 2 then
            set weighted = 0
        endif
        
        if this != 0 and RespawnASAPMode then
            set weighted = weighted * Users.count
        //else weighted = weighted, no point
        endif
        
        //TODO: Uneven teams handicap bonus
        
        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "initial continues: " + R2S(weighted))
        
        return R2I(weighted)
    endmethod
        
    public method GetWeightedReward takes integer unweighted returns integer
        local real weighted = unweighted
        
        if RewardMode == 0 then
            set weighted = weighted * 2 * .Weight
        elseif RewardMode == 1 then
            set weighted = weighted * .Weight
        elseif RewardMode == 2 then
            set weighted = 0
        endif
        
        if this != 0 and RespawnASAPMode then
            set weighted = weighted * Users.count
        //else weighted = weighted, no point
        endif
        
        //TODO: Uneven teams handicap bonus
        
        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "level reward continues: " + R2S(weighted))
        
        return R2I(weighted)
    endmethod
        
    public static method GetCountOnLevel takes integer levelID returns integer
        local integer i = 0
        local integer count = 0
        
        loop
        exitwhen i >= .NumberTeams
            //call DisplayTextToForce(bj_FORCE_PLAYER[0], "Team " + I2S(AllTeams[i].TeamID) + " on level: " + I2S(.AllTeams[i].OnLevel))
            //call DisplayTextToForce(bj_FORCE_PLAYER[0], "Checking " + I2S(levelID))
            if .AllTeams[i].OnLevel == levelID then
                set count = count + .AllTeams[i].Users.count
            endif
            set i = i + 1
        endloop
        
        //call DisplayTextToForce(bj_FORCE_PLAYER[0], "Count on level " + I2S(count))
        
        return count
    endmethod
    
    public static method IsLevelEmpty takes integer levelID returns boolean
        local integer i = 0
        
        loop
        exitwhen i >= .NumberTeams
            //call DisplayTextToForce(bj_FORCE_PLAYER[0], "Team " + I2S(AllTeams[i].TeamID) + " on level: " + I2S(.AllTeams[i].OnLevel))
            //call DisplayTextToForce(bj_FORCE_PLAYER[0], "Checking " + I2S(levelID))
            if .AllTeams[i].OnLevel == levelID then
                return false
            endif
            set i = i + 1
        endloop
        
        //call DisplayTextToForce(bj_FORCE_PLAYER[0], "Count on level " + I2S(count))
        
        return true
    endmethod
	
	public method GetWorldProgress takes integer worldID returns WorldProgress
		local SimpleList_ListNode curWorld = .AllWorldProgress.first
				
		loop
		exitwhen curWorld == 0
			if WorldProgress(curWorld.value).WorldID == worldID then
				return WorldProgress(curWorld.value)
			endif
		set curWorld = curWorld.next
		endloop
		
		return 0
	endmethod
	public method UpdateWorldProgress takes Levels_Level level returns nothing
		local integer worldID = level.GetWorldID()
		local WorldProgress currentProgress
				
		if worldID != 0 then
			set currentProgress = .GetWorldProgress(worldID)
						
			if currentProgress == 0 then
				set currentProgress = WorldProgress.create(level)
				call .AllWorldProgress.add(currentProgress)
			elseif currentProgress.FurthestLevel + 0 < level + 0 then
				set currentProgress.FurthestLevel = level
			endif
		endif
	endmethod
    
    public static method PlayerLeaves takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer pID = GetPlayerId(p)
        local User u = User.GetUserFromPlayerID(pID)
        local thistype mt = u.Team
        
        //call mt.Users.remove(u)
        call u.OnLeave()
        
        //update team comparison weights and give the team that just lost a player ~1 more continue
        call mt.ComputeTeamWeights()
        set mt.ContinueCount = mt.ContinueCount + R2I(1 * mt.Weight + .5)
        
        call mt.UpdateMultiboard()
        
        //set MazersArray[pID] = null
    endmethod
    
    public method AddPlayer takes integer pID returns nothing
        static if (DEBUG_MODE) then
            local integer i = 0
            local SimpleList_ListNode user
            local MazingTeam mt
            
            loop
            exitwhen i >= .NumberTeams
                set mt = .AllTeams[i]
                set user = mt.FirstUser
                
                loop
                exitwhen user == 0
                    if User(user.value) == pID then
                        debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "WARNING: CURRENTLY ADDING PLAYER ID " + I2S(pID) + " TO TEAM " + I2S(.TeamID) + ", BUT THEY ARE ALREADY A MEMBER OF TEAM: " + I2S(mt.TeamID))
                    endif
                    
                set user = user.next
                endloop
                
                set i = i + 1
            endloop
        endif
                
        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Adding user: " + I2S(User(pID)) + " to team: " + I2S(this))
        
        call Users.addEnd(User(pID))
        set User(pID).Team = this
        set User(pID).IsPlaying = true
        
        //check if this was the first player added to the team
        if Users.count == 1 then
            set .FirstUser = Users.first
            
            set .IsTeamPlaying = true
        endif
        
        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Player count of team " + I2S(.TeamID) + ", is now: " + I2S(.PlayerCount))
    endmethod
    
    public method UpdateMultiboard takes nothing returns nothing
        local integer pID
        
        local SimpleList_ListNode fp = .FirstUser
        local User u
        
        //PLAYER_SLOT_STATE_LEFT
        
        loop
        exitwhen fp == 0
            set u = User(fp.value)
            set pID = u
            
            if GetPlayerSlotState(Player(pID)) == PLAYER_SLOT_STATE_PLAYING then          
				call MultiboardSetItemValue(MultiboardGetItem(.PlayerStats, pID + 1, 0), .GetStylizedPlayerName(pID))
                call MultiboardSetItemValue(MultiboardGetItem(.PlayerStats, pID + 1, 1), .OnLevel.Name)
                call MultiboardSetItemValue(MultiboardGetItem(.PlayerStats, pID + 1, 2), I2S(.Score))
                call MultiboardSetItemValue(MultiboardGetItem(.PlayerStats, pID + 1, 3), I2S(.ContinueCount))
                call MultiboardSetItemValue(MultiboardGetItem(.PlayerStats, pID + 1, 4), I2S(u.Deaths))
                
                call MultiboardReleaseItem(MultiboardGetItem(.PlayerStats, pID + 1, 0))
                call MultiboardReleaseItem(MultiboardGetItem(.PlayerStats, pID + 1, 1))
                call MultiboardReleaseItem(MultiboardGetItem(.PlayerStats, pID + 1, 2))
                call MultiboardReleaseItem(MultiboardGetItem(.PlayerStats, pID + 1, 3))
                call MultiboardReleaseItem(MultiboardGetItem(.PlayerStats, pID + 1, 4))
			elseif GetPlayerSlotState(Player(pID)) == PLAYER_SLOT_STATE_LEFT then
                call MultiboardSetItemValue(MultiboardGetItem(.PlayerStats, pID + 1, 0), "Left the game")
                call MultiboardSetItemValue(MultiboardGetItem(.PlayerStats, pID + 1, 1), "Gone")
                call MultiboardSetItemValue(MultiboardGetItem(.PlayerStats, pID + 1, 2), "Negative")
                call MultiboardSetItemValue(MultiboardGetItem(.PlayerStats, pID + 1, 3), "Zilch")
                call MultiboardSetItemValue(MultiboardGetItem(.PlayerStats, pID + 1, 4), "Too many")
                
                call MultiboardReleaseItem(MultiboardGetItem(.PlayerStats, pID + 1, 0))
                call MultiboardReleaseItem(MultiboardGetItem(.PlayerStats, pID + 1, 1))
                call MultiboardReleaseItem(MultiboardGetItem(.PlayerStats, pID + 1, 2))
                call MultiboardReleaseItem(MultiboardGetItem(.PlayerStats, pID + 1, 3))
                call MultiboardReleaseItem(MultiboardGetItem(.PlayerStats, pID + 1, 4))
            else
                call MultiboardSetItemValue(MultiboardGetItem(.PlayerStats, pID + 1, 0), "Not playing")
                call MultiboardReleaseItem(MultiboardGetItem(.PlayerStats, pID + 1, 0))
            endif
            
        set fp = fp.next
        endloop
    endmethod
    
	public method GetTeamColor takes nothing returns string
		local string hex
        
        if .TeamID == 0 then
            set hex = "00CC00"
        elseif .TeamID == 1 then
            set hex = "0000FF"
        elseif .TeamID == 2 then
            set hex = "00FFCC"
        elseif .TeamID == 3 then
            set hex = "FF66CC"
        elseif .TeamID == 4 then
            set hex = "FFFF66"
        elseif .TeamID == 5 then
            set hex = "FF9933"
        elseif .TeamID == 6 then
            set hex = "FF0000"
        elseif .TeamID == 7 then
            set hex = "FF66CC"
        else
            set hex = ""
        endif
		
		return hex
	endmethod
    public method GetStylizedPlayerName takes integer pID returns string
        local string hex = .GetTeamColor()
        
        if GetPlayerSlotState(Player(pID)) == PLAYER_SLOT_STATE_PLAYING then
			return ColorMessage(GetPlayerName(Player(pID)), hex)
        else
			return ColorMessage("Gone", hex)
        endif
    endmethod
    
    public static method ComputeTeamWeights takes nothing returns nothing
        local integer i = 0
        local real avgSize = 0
        
        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "computing team weights")
        
        //compute average team size
        loop
        exitwhen i >= .NumberTeams
            set avgSize = avgSize + .AllTeams[i].Users.count
            set i = i + 1
        endloop
        set avgSize = avgSize / .NumberTeams
        
        //TODO also include individual player scores in weight
        
        set i = 0
        loop
        exitwhen i >= .NumberTeams
            if .AllTeams[i].Users.count > avgSize then
                set .AllTeams[i].Weight = 1.0 / (.AllTeams[i].Users.count - avgSize)
            elseif .AllTeams[i].Users.count < avgSize then
                set .AllTeams[i].Weight = 1.0 * (avgSize - .AllTeams[i].Users.count)
            else // team size == avg size
                set .AllTeams[i].Weight = 1.
            endif
            
            debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "team: " + I2S(i) + ", weight: " + R2S(.AllTeams[i].Weight))
            
            set i = i + 1
        endloop
    endmethod
	
	public static method GetRandomTeam takes MazingTeam filter returns MazingTeam
		local integer rand = GetRandomInt(0, NumberTeams - 1)
		
		if NumberTeams != 1 or filter == 0 then
			if filter != 0 then
				loop
				exitwhen rand != filter
				set rand = GetRandomInt(0, NumberTeams - 1)
				endloop
			endif
			
			return AllTeams[rand]
		else
			return 0
		endif
	endmethod
    	
	//returning the 1st place winner is fine for now, but eventually i'll want to run through all team ranks
	//TODO replace with a sort by score function that returns a simple list
	public static method GetLeadingScore takes nothing returns MazingTeam
		local MazingTeam leader = 0
		local integer leadScore = -1
		local boolean tie = false
		
		local integer i = 0
		
		loop
        exitwhen i >= .NumberTeams
            if .AllTeams[i].Score > leadScore then
				set tie = false
				set leader = .AllTeams[i]
				set leadScore = leader.Score
			elseif .AllTeams[i].Score == leadScore then
				set tie = true
			endif
			
            set i = i + 1
        endloop
		
		return leader
	endmethod
	
	public method GetContinueCount takes nothing returns integer
		return .ContinueCount
	endmethod
	public method SetContinueCount takes integer continueCount returns nothing
		static if DEBUG_MODE then
			if continueCount <= 0 then
				call .PrintMessage("Setting continues negative!")
			endif
		endif
		
		set .ContinueCount = continueCount
		
		call .UpdateMultiboard()
	endmethod
	public method ChangeContinueCount takes integer continueOffset returns nothing
		if continueOffset != 0 then
			if .ContinueCount + continueOffset < 0 then
				call .PrintMessage("Your team ran out of lives!")
				call .OnLevel.SwitchLevels(this, Levels_Level(Levels_DOORS_LEVEL_ID))
				
				//if not in 99 and none mode, reset continues
				if RewardMode == 0 or RewardMode == 1 then //standard mode or challenge mode
					set .ContinueCount = 0
					//call mt.RespawnTeamAtRect(mt.Revive, true)
				elseif RewardMode == 2 then
					//call RemoveUnit()
					//**************************************
					//no more continues in 99 and none mode -- team has lost!
					//**************************************
				endif
			else
				set .ContinueCount = .ContinueCount + continueOffset
			endif
			
			call .UpdateMultiboard()
		endif
	endmethod
	
	public method GetScore takes nothing returns integer
		return .Score
	endmethod
	public method ChangeScore takes integer scoreOffset returns nothing
		local integer ogScore = VictoryScore - .Score
		
		if scoreOffset != 0 then
			set .Score = .Score + scoreOffset
			
			//TODO update multiboard leader positions
			
			//check for victory conditions
			if VictoryScore != 0 then
				if VictoryScore - .Score <= 0 then
					call MazingTeam.ApplyEndGameAll(this)
				elseif (VictoryScore - .Score <= 10 and ogScore > 10) or (VictoryScore - .Score <= 5 and ogScore > 5) then
					call MazingTeam.PrintMessageAll("Team " + ColorValue(I2S(this)) + " needs " + ColorValue(I2S(VictoryScore - .Score)) + " more points to win", 0)
				elseif VictoryScore - .Score <= 3 and ogScore > 3 then
					if VictoryScore - .Score == 1 then
						call MazingTeam.PrintMessageAll("Team " + ColorValue(I2S(this)) + " only needs " + ColorValue(I2S(VictoryScore - .Score)) + " more point to win!", 0)
					else
						call MazingTeam.PrintMessageAll("Team " + ColorValue(I2S(this)) + " only needs " + ColorValue(I2S(VictoryScore - .Score)) + " more points to win!", 0)
					endif
				endif
			endif
			
			call .UpdateMultiboard()
		endif
	endmethod
    
	private static method MultiboardHideCallback takes nothing returns nothing
        local timer t = GetExpiredTimer()
        
        call MultiboardMinimize(.PlayerStats, true)
        
        call ReleaseTimer(t)
        set t = null
    endmethod

    //intended to be run after initial team setup
    public static method MultiboardSetupInit takes nothing returns nothing
        local integer i = 0
        local User u
        local thistype mt
        local timer t = NewTimer()
        
        set .PlayerStats = CreateMultiboard()
        set bj_lastCreatedMultiboard = .PlayerStats
        
        call MultiboardSetRowCount(.PlayerStats, NumberPlayers + 1)
        call MultiboardSetColumnCount(.PlayerStats, 5)
        call MultiboardSetTitleText(.PlayerStats, "Player Stats")
        call MultiboardDisplay(.PlayerStats, true)
        call MultiboardSetItemsWidth(.PlayerStats, .1)
        
        
        //multiboard column titles
        call MultiboardSetItemValue(MultiboardGetItem(.PlayerStats, 0, 0), "Player Name")
        call MultiboardSetItemValue(MultiboardGetItem(.PlayerStats, 0, 1), "On Level")
        call MultiboardSetItemValue(MultiboardGetItem(.PlayerStats, 0, 2), "Score")
        call MultiboardSetItemValue(MultiboardGetItem(.PlayerStats, 0, 3), "Continues")
        call MultiboardSetItemValue(MultiboardGetItem(.PlayerStats, 0, 4), "Deaths")
        
        call MultiboardSetItemIcon(MultiboardGetItem(.PlayerStats, 0, 0), "ReplaceableTextures\\CommandButtons\\BTNPeasant.blp")
        call MultiboardSetItemIcon(MultiboardGetItem(.PlayerStats, 0, 1), "ReplaceableTextures\\CommandButtons\\BTNDemonGate.blp")
        call MultiboardSetItemIcon(MultiboardGetItem(.PlayerStats, 0, 2), "ReplaceableTextures\\CommandButtons\\BTNGlyph.blp")
        call MultiboardSetItemIcon(MultiboardGetItem(.PlayerStats, 0, 3), "ReplaceableTextures\\CommandButtons\\BTNSkillz.tga")
        call MultiboardSetItemIcon(MultiboardGetItem(.PlayerStats, 0, 4), "ReplaceableTextures\\CommandButtons\\BTNAnkh.blp")
        
        call MultiboardReleaseItem(MultiboardGetItem(.PlayerStats, 0, 0))
        call MultiboardReleaseItem(MultiboardGetItem(.PlayerStats, 0, 1))
        call MultiboardReleaseItem(MultiboardGetItem(.PlayerStats, 0, 2))
        call MultiboardReleaseItem(MultiboardGetItem(.PlayerStats, 0, 3))
        call MultiboardReleaseItem(MultiboardGetItem(.PlayerStats, 0, 4))
        
        loop
        exitwhen i >= NumberPlayers
            call MultiboardSetItemIcon(MultiboardGetItem(.PlayerStats, i + 1, 0), "ReplaceableTextures\\CommandButtons\\BTNPeasant.blp")
            call MultiboardSetItemIcon(MultiboardGetItem(.PlayerStats, i + 1, 1), "ReplaceableTextures\\CommandButtons\\BTNDemonGate.blp")
            call MultiboardSetItemIcon(MultiboardGetItem(.PlayerStats, i + 1, 2), "ReplaceableTextures\\CommandButtons\\BTNGlyph.blp")
            call MultiboardSetItemIcon(MultiboardGetItem(.PlayerStats, i + 1, 3), "ReplaceableTextures\\CommandButtons\\BTNSkillz.tga")
            call MultiboardSetItemIcon(MultiboardGetItem(.PlayerStats, i + 1, 4), "ReplaceableTextures\\CommandButtons\\BTNAnkh.blp")
            
            if GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING then
                set u = User.GetUserFromPlayerID(i)
                set mt = u.Team
                
                call MultiboardSetItemValue(MultiboardGetItem(.PlayerStats, i + 1, 0), mt.GetStylizedPlayerName(i))
                call MultiboardSetItemValue(MultiboardGetItem(.PlayerStats, i + 1, 1), mt.OnLevel.Name)
                call MultiboardSetItemValue(MultiboardGetItem(.PlayerStats, i + 1, 2), I2S(mt.Score))
                call MultiboardSetItemValue(MultiboardGetItem(.PlayerStats, i + 1, 3), I2S(mt.ContinueCount))
                call MultiboardSetItemValue(MultiboardGetItem(.PlayerStats, i + 1, 4), I2S(u.Deaths))
                
                call MultiboardReleaseItem(MultiboardGetItem(.PlayerStats, i + 1, 0))
                call MultiboardReleaseItem(MultiboardGetItem(.PlayerStats, i + 1, 1))
                call MultiboardReleaseItem(MultiboardGetItem(.PlayerStats, i + 1, 2))
                call MultiboardReleaseItem(MultiboardGetItem(.PlayerStats, i + 1, 3))
                call MultiboardReleaseItem(MultiboardGetItem(.PlayerStats, i + 1, 4))
            else
                call MultiboardSetItemValue(MultiboardGetItem(.PlayerStats, i + 1, 0), "Not Playing")
                call MultiboardReleaseItem(MultiboardGetItem(.PlayerStats, i + 1, 0))
            endif
            
            set i = i + 1
        endloop
        call MultiboardDisplay(.PlayerStats, false)
        call MultiboardDisplay(.PlayerStats, true)
        call MultiboardMinimize(.PlayerStats, true)
        call MultiboardMinimize(.PlayerStats, false)
        
        call TimerStart(t, MULTIBOARD_HIDE_DELAY, false, function MazingTeam.MultiboardHideCallback)
        
        set t = null
    endmethod
	
	public method ApplyEndGame takes boolean victory returns nothing
		local SimpleList_ListNode curPlayer = .FirstUser
		
		loop
		exitwhen curPlayer == 0
			if victory then
				call CustomVictoryBJ(Player(curPlayer.value), true, false)
			else
				call CustomDefeatDialogBJ(Player(curPlayer.value), "Here to play. Forever stay.")
			endif
		set curPlayer = curPlayer.next
		endloop
	endmethod
	public static method ApplyEndGameAll takes MazingTeam victor returns nothing
		local integer i = 0
		
		loop
        exitwhen i >= .NumberTeams
            if .AllTeams[i] == victor then
				call .AllTeams[i].ApplyEndGame(true)
			else
				call .AllTeams[i].ApplyEndGame(false)
			endif
			
            set i = i + 1
        endloop
	endmethod
    
    public static method create takes integer teamID returns thistype
        local thistype mt = thistype.allocate()
        
        if .AllTeams[teamID] == 0 then
            set mt.TeamID = teamID
            set mt.TeamName = "TBD" //set later
            set mt.RecentlyTransferred = false //used to make sure triggers aren't run multiple times / no interrupts
            set mt.LastTransferTime = -50 //has never transferred
            //set mt.DefaultGameMode = GAMEMODE_STANDARD
            set mt.OnLevel = Levels_TEMP_LEVEL_ID
            set mt.OnCheckpoint = -1
            set mt.Revive = Rect(0, 0, 200, 200)
            call mt.MoveRevive(gg_rct_IntroWorld_R1)
            set mt.Score = 0
            set mt.DefaultGameMode = GAMEMODE_STANDARD
            
			set mt.Users = SimpleList_List.create()
            set mt.AllWorldProgress = SimpleList_List.create()
			
            set .AllTeams[teamID] = mt
            //set .NumberTeams = .NumberTeams + 1
            set Teams_MazingTeam.NumberTeams = Teams_MazingTeam.NumberTeams + 1
            //call DisplayTextToForce(bj_FORCE_PLAYER[0], "3")
        else
            call DisplayTextToForce(bj_FORCE_PLAYER[0], "Overlapping team ID -- invalid game state")
            return 0 //team already exists
        endif
        return mt
    endmethod
endstruct

public function Init takes nothing returns nothing
    local trigger t = CreateTrigger()
    local integer i = 0
    
    loop
        if GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING then
            call TriggerRegisterPlayerEvent(t, Player(i), EVENT_PLAYER_DEFEAT)
            call TriggerRegisterPlayerEvent(t, Player(i), EVENT_PLAYER_LEAVE)
        endif
        set i = i + 1
        exitwhen i >= NumberPlayers
    endloop
    
    call TriggerAddAction(t, function MazingTeam.PlayerLeaves)
endfunction

endlibrary
