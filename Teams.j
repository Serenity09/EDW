library Teams requires MazerGlobals, User, UnitLocalVisibility
globals
    private constant real VOTE_TOP_LEFT_X = -15000
	private constant real VOTE_TOP_LEFT_Y = -4220
	
	//stable gamestates, a user in one of these gamestates will not transition to another one without a user or npc action
	//all these gamemodes should be >= 0
    public constant integer GAMEMODE_STANDARD = 0
    public constant integer GAMEMODE_PLATFORMING = 1
    public constant integer GAMEMODE_STANDARD_PAUSED = 10
    public constant integer GAMEMODE_PLATFORMING_PAUSED = 11
    public constant integer GAMEMODE_DEAD = 101
	
	//special gamestates that support unstable transitions. IE a user will never intentionally be left in one of these states indefinitely
	//all these gamemodes should be < 0
	public constant integer GAMEMODE_DYING = -1
	public constant integer GAMEMODE_HIDDEN = -2
	private constant integer GAMEMODE_INIT = -1032132
    
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

public struct MazingTeam extends array
    public SimpleList_List Users
    public SimpleList_ListNode FirstUser
    
	public User LastEventUser
    readonly boolean IsTeamPlaying
    readonly rect Revive
    readonly integer ContinueCount
    // public boolean RecentlyTransferred
    // public real LastTransferTime
	// public boolean IsRemainingTeamAFK
    public Levels_Level OnLevel
    public string TeamName // TODO allow custom player defined team names
    public integer OnCheckpoint //Used purely in conjunction with levels struct. ==0 refers to the initial CP for a level
    private integer Score
    public real Weight
    public integer DefaultGameMode
    public VisualVote_voteMenu VoteMenu
    
	public SimpleList_List AllWorldProgress
    //public integer DefaultGameMode
    
    public static multiboard PlayerStats
    
    readonly static integer NumberTeams = 0
	
	readonly static SimpleList_List AllTeams
    
	implement Alloc
	
    public method MoveRevive takes rect newlocation returns nothing
        call MoveRectTo(.Revive, GetRectCenterX(newlocation), GetRectCenterY(newlocation))
    endmethod
    
    public method MoveReviveToDoors takes nothing returns nothing
        call MoveRectTo(.Revive, GetRectCenterX(gg_rct_HubWorld_R), GetRectCenterY(gg_rct_HubWorld_R))
    endmethod
    
    public method CreateMenu takes real time, string optionCB returns nothing
        local real x = VOTE_TOP_LEFT_X + R2I((this + 1) / 4)
        local real y = VOTE_TOP_LEFT_Y + R2I((this + 1) / 2)
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
	public method ClearAllCinematicsForTeam takes nothing returns nothing
		local SimpleList_ListNode fp = .FirstUser
		
		loop
		exitwhen fp == 0
			call User(fp.value).CinematicQueue.clear()
			
			if User(fp.value).CinematicPlaying != 0 then
				call User(fp.value).CinematicPlaying.EndCallbackStack()
			endif
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
                    call FogModifierStart(CreateFogModifierRect(Player(u), FOG_OF_WAR_VISIBLE, newvision, false, true))
					
					//call DisplayTextToForce(bj_FORCE_PLAYER[0], "added vision for user " + I2S(u))
                endif
                
            set fp = fp.next
            endloop
        endif
    endmethod
    
    public method ApplyTeamDefaultCameras takes nothing returns nothing
        local SimpleList_ListNode fp = .FirstUser
        local User u
        
        if .IsTeamPlaying then
            loop
            exitwhen fp == 0
                set u = fp.value
                
                call User(fp.value).ApplyDefaultCameras(0.)
                
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
                    call u.SetKeyColor(keyID)
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
		local SimpleList_ListNode curTeamNode = thistype.AllTeams.first
        
        loop
        exitwhen curTeamNode == 0
            if filterTeam == 0 or curTeamNode.value != filterTeam then
				call MazingTeam(curTeamNode.value).PrintMessage(message)
			endif
			
            set curTeamNode = curTeamNode.next
        endloop
	endmethod
	
	public method LocalizeMessage takes integer contentID returns nothing
        local SimpleList_ListNode fp = .FirstUser
        
        loop
        exitwhen fp == 0
            call User(fp.value).DisplayLocalizedMessage(contentID, 0)
        set fp = fp.next
        endloop
    endmethod
	public static method LocalizeMessageAll takes integer contentID, MazingTeam filterTeam returns nothing
		local SimpleList_ListNode curTeamNode = thistype.AllTeams.first
        
        loop
        exitwhen curTeamNode == 0
            if filterTeam == 0 or curTeamNode.value != filterTeam then
				call MazingTeam(curTeamNode.value).LocalizeMessage(contentID)
			endif
			
            set curTeamNode = curTeamNode.next
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
        local SimpleList_ListNode curTeamNode = thistype.AllTeams.first
        local integer count = 0
        
        loop
        exitwhen curTeamNode == 0
            // call DisplayTextToForce(bj_FORCE_PLAYER[0], "Team " + I2S(MazingTeam(curTeamNode.value)) + " on level: " + I2S(MazingTeam(curTeamNode.value).OnLevel))
            // call DisplayTextToForce(bj_FORCE_PLAYER[0], "Checking " + I2S(levelID))
            if MazingTeam(curTeamNode.value).OnLevel == levelID then
                set count = count + MazingTeam(curTeamNode.value).Users.count
            endif
			
		set curTeamNode = curTeamNode.next
        endloop
        
        // call DisplayTextToForce(bj_FORCE_PLAYER[0], "Count on level " + I2S(count))
        
        return count
    endmethod
    
    public static method IsLevelEmpty takes integer levelID returns boolean
        local SimpleList_ListNode curTeamNode = thistype.AllTeams.first
        
        loop
        exitwhen curTeamNode == 0
            //call DisplayTextToForce(bj_FORCE_PLAYER[0], "Team " + I2S(AllTeams[i].TeamID) + " on level: " + I2S(.AllTeams[i].OnLevel))
            //call DisplayTextToForce(bj_FORCE_PLAYER[0], "Checking " + I2S(levelID))
            if MazingTeam(curTeamNode.value).OnLevel == levelID then
                return false
            endif
			
		set curTeamNode = curTeamNode.next
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
        local User u = User(pID)
        local thistype mt = u.Team
		
		local SimpleList_ListNode curUserNode = mt.Users.first
		local boolean anyActive = false
        
        //call mt.Users.remove(u)
        call u.OnLeave()
        
        //update team comparison weights and give the team that just lost a player ~1 more continue
        call mt.ComputeTeamWeights()
        set mt.ContinueCount = mt.ContinueCount + R2I(1 * mt.Weight + .5)
        
        call mt.UpdateMultiboard()
		
		loop
        exitwhen curUserNode == 0 or anyActive
			if User(curUserNode.value).IsPlaying then
				set anyActive = User(curUserNode.value).IsPlaying
			endif
		set curUserNode = curUserNode.next
		endloop
		
		if not anyActive then
			set mt.IsTeamPlaying = false
		endif
        //set MazersArray[pID] = null
    endmethod
    
    public method AddPlayer takes integer pID returns nothing
        static if (DEBUG_MODE) then
            local SimpleList_ListNode curTeamNode = thistype.AllTeams.first
            local SimpleList_ListNode user
            local MazingTeam mt
            
            loop
            exitwhen curTeamNode == 0
                set mt = curTeamNode.value
                set user = mt.FirstUser
                
                loop
                exitwhen user == 0
                    if User(user.value) == pID then
                        debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "WARNING: CURRENTLY ADDING PLAYER ID " + I2S(pID) + " TO TEAM " + I2S(this) + ", BUT THEY ARE ALREADY A MEMBER OF TEAM: " + I2S(mt))
                    endif
                    
                set user = user.next
                endloop
                
                set curTeamNode = curTeamNode.next
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
        
        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Player count of team " + I2S(this) + ", is now: " + I2S(.PlayerCount))
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
				call MultiboardSetItemValue(MultiboardGetItem(.PlayerStats, pID + 1, 0), u.GetStylizedPlayerName())
                call MultiboardSetItemValue(MultiboardGetItem(.PlayerStats, pID + 1, 1), .OnLevel.Name)
                call MultiboardSetItemValue(MultiboardGetItem(.PlayerStats, pID + 1, 2), I2S(.Score))
                call MultiboardSetItemValue(MultiboardGetItem(.PlayerStats, pID + 1, 3), I2S(.ContinueCount))
                
                
                call MultiboardReleaseItem(MultiboardGetItem(.PlayerStats, pID + 1, 0))
                call MultiboardReleaseItem(MultiboardGetItem(.PlayerStats, pID + 1, 1))
                call MultiboardReleaseItem(MultiboardGetItem(.PlayerStats, pID + 1, 2))
                call MultiboardReleaseItem(MultiboardGetItem(.PlayerStats, pID + 1, 3))
                
				
				if RewardMode == GameModesGlobals_HARD then
					call MultiboardSetItemValue(MultiboardGetItem(.PlayerStats, pID + 1, 4), I2S(u.Deaths))
					call MultiboardReleaseItem(MultiboardGetItem(.PlayerStats, pID + 1, 4))
				endif
			elseif GetPlayerSlotState(Player(pID)) == PLAYER_SLOT_STATE_LEFT then
                call MultiboardSetItemValue(MultiboardGetItem(.PlayerStats, pID + 1, 0), "Left the game")
                call MultiboardSetItemValue(MultiboardGetItem(.PlayerStats, pID + 1, 1), "Gone")
                call MultiboardSetItemValue(MultiboardGetItem(.PlayerStats, pID + 1, 2), "Negative")
                call MultiboardSetItemValue(MultiboardGetItem(.PlayerStats, pID + 1, 3), "Zilch")
                
                
                call MultiboardReleaseItem(MultiboardGetItem(.PlayerStats, pID + 1, 0))
                call MultiboardReleaseItem(MultiboardGetItem(.PlayerStats, pID + 1, 1))
                call MultiboardReleaseItem(MultiboardGetItem(.PlayerStats, pID + 1, 2))
                call MultiboardReleaseItem(MultiboardGetItem(.PlayerStats, pID + 1, 3))
                
				
				if RewardMode == GameModesGlobals_HARD then
					call MultiboardSetItemValue(MultiboardGetItem(.PlayerStats, pID + 1, 4), "Too many")
					call MultiboardReleaseItem(MultiboardGetItem(.PlayerStats, pID + 1, 4))
				endif
            else
                call MultiboardSetItemValue(MultiboardGetItem(.PlayerStats, pID + 1, 0), "Not playing")
                call MultiboardReleaseItem(MultiboardGetItem(.PlayerStats, pID + 1, 0))
            endif
            
        set fp = fp.next
        endloop
    endmethod
    
	public method GetTeamColor takes nothing returns string
		local string hex
        
        if this == 1 then
            set hex = "FF0000"
        elseif this == 2 then
            set hex = "0000FF"
        elseif this == 3 then
            set hex = "00FFCC"
        elseif this == 4 then
            set hex = "FF66CC"
        elseif this == 5 then
            set hex = "FFFF66"
        elseif this == 6 then
            set hex = "FF9933"
        elseif this == 7 then
            set hex = "00CC00"
        elseif this == 8 then
            set hex = "FF66CC"
        else
            set hex = ""
        endif
		
		return hex
	endmethod
	public method GetDefaultTeamName takes nothing returns string
		local string name
		
		if this == 1 then
			set name = "Red"
		elseif this == 2 then
			set name = "Blue"
		elseif this == 3 then
			set name = "Teal"
		elseif this == 4 then
			set name = "Purple"
		elseif this == 5 then
			set name = "Yellow"
		elseif this == 6 then
			set name = "Orange"
		elseif this == 7 then
			set name = "Green"
		elseif this == 8 then
			set name = "Pink"
		else
			set name = ""
		endif
		
		return ColorMessage(name, .GetTeamColor())
	endmethod
	public method GetLocalizedTeamName takes User forUser returns string
		local string name = ""
		
		if GetLocalPlayer() == Player(forUser) then
			if this == 1 then
				set name = LocalizeContent('TGRE', forUser.LanguageCode)
			elseif this == 2 then
				set name = LocalizeContent('TGBL', forUser.LanguageCode)
			elseif this == 3 then
				set name = LocalizeContent('TGTE', forUser.LanguageCode)
			elseif this == 4 then
				set name = LocalizeContent('TGPU', forUser.LanguageCode)
			elseif this == 5 then
				set name = LocalizeContent('TGYE', forUser.LanguageCode)
			elseif this == 6 then
				set name = LocalizeContent('TGOR', forUser.LanguageCode)
			elseif this == 7 then
				set name = LocalizeContent('TGRE', forUser.LanguageCode)
			elseif this == 8 then
				set name = LocalizeContent('TGPI', forUser.LanguageCode)
			endif
		
			set name = ColorMessage(name, .GetTeamColor())
		endif
		
		return name
	endmethod
	public method GetTeamNameContentID takes nothing returns integer
		if this == 1 then
				return 'TGRE'
			elseif this == 2 then
				return 'TGBL'
			elseif this == 3 then
				return 'TGTE'
			elseif this == 4 then
				return 'TGPU'
			elseif this == 5 then
				return 'TGYE'
			elseif this == 6 then
				return 'TGOR'
			elseif this == 7 then
				return 'TGRE'
			elseif this == 8 then
				return 'TGPI'
			else
				return 0
			endif
	endmethod
	   
    public static method ComputeTeamWeights takes nothing returns nothing
        local SimpleList_ListNode curTeamNode = thistype.AllTeams.first
        local real avgSize = 0
        
        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "computing team weights")
        
        //compute average team size
        loop
        exitwhen curTeamNode == 0
            set avgSize = avgSize + MazingTeam(curTeamNode.value).Users.count
            
		set curTeamNode = curTeamNode.next
        endloop
        set avgSize = avgSize / .NumberTeams
        
        //TODO also include individual player scores in weight
        
        set curTeamNode = thistype.AllTeams.first
        loop
        exitwhen curTeamNode == 0
            if MazingTeam(curTeamNode.value).Users.count > avgSize then
                set MazingTeam(curTeamNode.value).Weight = 1.0 / (MazingTeam(curTeamNode.value).Users.count - avgSize)
            elseif MazingTeam(curTeamNode.value).Users.count < avgSize then
                set MazingTeam(curTeamNode.value).Weight = 1.0 * (avgSize - MazingTeam(curTeamNode.value).Users.count)
            else // team size == avg size
                set MazingTeam(curTeamNode.value).Weight = 1.
            endif
            
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "team: " + I2S(i) + ", weight: " + R2S(.AllTeams[i].Weight))
            
		set curTeamNode = curTeamNode.next
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
			
			return AllTeams.get(rand).value
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
		
		local SimpleList_ListNode curTeamNode = thistype.AllTeams.first
		
		loop
        exitwhen curTeamNode == 0
            if MazingTeam(curTeamNode.value).Score > leadScore then
				set tie = false
				set leader = MazingTeam(curTeamNode.value)
				set leadScore = leader.Score
			elseif MazingTeam(curTeamNode.value).Score == leadScore then
				set tie = true
			endif
			
            set curTeamNode = curTeamNode.next
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
				call .LocalizeMessage('TGGG')
				// call .PrintMessage("Your team ran out of lives!")
				
				call .OnLevel.SwitchLevels(this, Levels_Level(DOORS_LEVEL_ID), 0, false)
				
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
	
	public method DisplayDynamicContent takes LocalizeContentFunc localizeFunc returns nothing
		local SimpleList_ListNode curUserNode = this.Users.first
		
		loop
		exitwhen curUserNode == 0
			if GetLocalPlayer() == Player(curUserNode.value) then
				call User(curUserNode.value).DisplayMessage(localizeFunc.evaluate(Player(curUserNode.value)), 0)
			endif
		set curUserNode = curUserNode.next
		endloop
	endmethod
	public static method DisplayDynamicContentAll takes LocalizeContentFunc localizeFunc returns nothing
		local SimpleList_ListNode curTeamNode = thistype.AllTeams.first
		
		loop
		exitwhen curTeamNode == 0
			call Teams_MazingTeam(curTeamNode.value).DisplayDynamicContent(localizeFunc)
		set curTeamNode = curTeamNode.next
		endloop
	endmethod
		
	private method LocalizeNeedsScore takes player p returns string
		local User u = User(GetPlayerId(p))
		
		return LocalizeContent('TCTE', u.LanguageCode) + " " /*
			*/ + ColorMessage(LocalizeContent(u.Team.GetTeamNameContentID(), u.LanguageCode), u.Team.GetTeamColor()) + " " /*
			*/ + LocalizeContent('TCNE', u.LanguageCode) + " " /*
			*/ + ColorValue(I2S(VictoryScore - u.Team.Score)) + " " /*
			*/ + LocalizeContent('TCMO', u.LanguageCode)
	endmethod
	private method LocalizeOnlyNeedsScore takes player p returns string
		local User u = User(GetPlayerId(p))
		
		return LocalizeContent('TCTE', u.LanguageCode) + " " /*
			*/ + ColorMessage(LocalizeContent(u.Team.GetTeamNameContentID(), u.LanguageCode), u.Team.GetTeamColor()) + " " /*
			*/ + LocalizeContent('TCON', u.LanguageCode) + " " /*
			*/ + ColorValue(I2S(VictoryScore - u.Team.Score)) + " " /*
			*/ + LocalizeContent('TCMO', u.LanguageCode)
	endmethod
	
	public method GetScore takes nothing returns integer
		return .Score
	endmethod
	public method ChangeScore takes integer scoreOffset returns nothing
		local integer ogScore = VictoryScore - .Score
		local integer teamNameContentID = this.GetTeamNameContentID()
		local string teamColor = this.GetTeamColor()
		
		local SimpleList_ListNode curTeamNode = thistype.AllTeams.first
		local SimpleList_ListNode curUserNode
		
		if scoreOffset != 0 then
			set .Score = .Score + scoreOffset			
			
			//check for victory conditions if VictoryScore is configured to be non-zero
			if VictoryScore != 0 then
				if VictoryScore - .Score <= 0 then
					call MazingTeam.ApplyEndGameAll(this)
				else
					if (VictoryScore - .Score <= 10 and ogScore > 10) or (VictoryScore - .Score <= 5 and ogScore > 5) then
						// call User(curUserNode.value).DisplayMessage(LocalizeContent('TCTE', User(curUserNode.value).LanguageCode) + " " /*
							// */ + ColorMessage(LocalizeContent(teamNameContentID, User(curUserNode.value).LanguageCode), teamColor) + " " /*
							// */ + LocalizeContent('TCNE', User(curUserNode.value).LanguageCode) + " " /*
							// */ + ColorValue(I2S(VictoryScore - .Score)) + " " /*
							// */ + LocalizeContent('TCMO', User(curUserNode.value).LanguageCode), 0)
						call thistype.DisplayDynamicContentAll(LocalizeNeedsScore)
					elseif VictoryScore - .Score <= 3 and ogScore > 3 then
						// call User(curUserNode.value).DisplayMessage(LocalizeContent('TCTE', User(curUserNode.value).LanguageCode) + " " /*
							// */ + ColorMessage(LocalizeContent(teamNameContentID, User(curUserNode.value).LanguageCode), teamColor) + " " /*
							// */ + LocalizeContent('TCON', User(curUserNode.value).LanguageCode) + " " /*
							// */ + ColorValue(I2S(VictoryScore - .Score)) + " " /*
							// */ + LocalizeContent('TCMO', User(curUserNode.value).LanguageCode), 0)
						call thistype.DisplayDynamicContentAll(LocalizeOnlyNeedsScore)
					endif
					
					// loop
					// exitwhen curTeamNode == 0
						// set curUserNode = Teams_MazingTeam(curTeamNode.value).Users.first
						
						// loop
						// exitwhen curUserNode == 0
							// if (VictoryScore - .Score <= 10 and ogScore > 10) or (VictoryScore - .Score <= 5 and ogScore > 5) then
								// // call User(curUserNode.value).DisplayMessage(LocalizeContent('TCTE', User(curUserNode.value).LanguageCode) + " " /*
									// // */ + ColorMessage(LocalizeContent(teamNameContentID, User(curUserNode.value).LanguageCode), teamColor) + " " /*
									// // */ + LocalizeContent('TCNE', User(curUserNode.value).LanguageCode) + " " /*
									// // */ + ColorValue(I2S(VictoryScore - .Score)) + " " /*
									// // */ + LocalizeContent('TCMO', User(curUserNode.value).LanguageCode), 0)
								// call thistype.DisplayDynamicContentAll(LocalizeNeedsScore)
							// elseif VictoryScore - .Score <= 3 and ogScore > 3 then
								// // call User(curUserNode.value).DisplayMessage(LocalizeContent('TCTE', User(curUserNode.value).LanguageCode) + " " /*
									// // */ + ColorMessage(LocalizeContent(teamNameContentID, User(curUserNode.value).LanguageCode), teamColor) + " " /*
									// // */ + LocalizeContent('TCON', User(curUserNode.value).LanguageCode) + " " /*
									// // */ + ColorValue(I2S(VictoryScore - .Score)) + " " /*
									// // */ + LocalizeContent('TCMO', User(curUserNode.value).LanguageCode), 0)
								// call thistype.DisplayDynamicContentAll(LocalizeOnlyNeedsScore)
							// endif
						// set curUserNode = curUserNode.next
						// endloop
					// set curTeamNode = curTeamNode.next
					// endloop
				endif
			endif
			
			//TODO order multiboard by score, user ID
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
	//TODO deprecate loop from implementing row logic to calling user's row logic
    public static method MultiboardSetupInit takes nothing returns nothing
        local integer i = 0
        local User u
        local thistype mt
        local timer t = NewTimer()
        
        set .PlayerStats = CreateMultiboard()
        set bj_lastCreatedMultiboard = .PlayerStats
        
        call MultiboardSetRowCount(.PlayerStats, NumberPlayers + 1)
        call MultiboardSetTitleText(.PlayerStats, "Player Stats")
        call MultiboardDisplay(.PlayerStats, true)
        call MultiboardSetItemsWidth(.PlayerStats, .1)
		
		if RewardMode == GameModesGlobals_HARD then
			call MultiboardSetColumnCount(.PlayerStats, 5)
		else
			call MultiboardSetColumnCount(.PlayerStats, 4)
        endif
        
        //multiboard column titles
        call MultiboardSetItemValue(MultiboardGetItem(.PlayerStats, 0, 0), "Player Name")
        call MultiboardSetItemValue(MultiboardGetItem(.PlayerStats, 0, 1), "On Level")
        call MultiboardSetItemValue(MultiboardGetItem(.PlayerStats, 0, 2), "Score")
        call MultiboardSetItemValue(MultiboardGetItem(.PlayerStats, 0, 3), "Continues")
        
        call MultiboardSetItemIcon(MultiboardGetItem(.PlayerStats, 0, 0), "ReplaceableTextures\\CommandButtons\\BTNPeasant.blp")
        call MultiboardSetItemIcon(MultiboardGetItem(.PlayerStats, 0, 1), "ReplaceableTextures\\CommandButtons\\BTNDemonGate.blp")
        call MultiboardSetItemIcon(MultiboardGetItem(.PlayerStats, 0, 2), "ReplaceableTextures\\CommandButtons\\BTNGlyph.blp")
        call MultiboardSetItemIcon(MultiboardGetItem(.PlayerStats, 0, 3), "ReplaceableTextures\\CommandButtons\\BTNSkillz.tga")
        
        call MultiboardReleaseItem(MultiboardGetItem(.PlayerStats, 0, 0))
        call MultiboardReleaseItem(MultiboardGetItem(.PlayerStats, 0, 1))
        call MultiboardReleaseItem(MultiboardGetItem(.PlayerStats, 0, 2))
        call MultiboardReleaseItem(MultiboardGetItem(.PlayerStats, 0, 3))
        
		if RewardMode == GameModesGlobals_HARD then
			call MultiboardSetItemValue(MultiboardGetItem(.PlayerStats, 0, 4), "Deaths")
			call MultiboardSetItemIcon(MultiboardGetItem(.PlayerStats, 0, 4), "ReplaceableTextures\\CommandButtons\\BTNAnkh.blp")
			call MultiboardReleaseItem(MultiboardGetItem(.PlayerStats, 0, 4))
		endif
		
        loop
        exitwhen i >= NumberPlayers
            call MultiboardSetItemIcon(MultiboardGetItem(.PlayerStats, i + 1, 0), "ReplaceableTextures\\CommandButtons\\BTNPeasant.blp")
            call MultiboardSetItemIcon(MultiboardGetItem(.PlayerStats, i + 1, 1), "ReplaceableTextures\\CommandButtons\\BTNDemonGate.blp")
            call MultiboardSetItemIcon(MultiboardGetItem(.PlayerStats, i + 1, 2), "ReplaceableTextures\\CommandButtons\\BTNGlyph.blp")
            call MultiboardSetItemIcon(MultiboardGetItem(.PlayerStats, i + 1, 3), "ReplaceableTextures\\CommandButtons\\BTNSkillz.tga")
            
			if RewardMode == GameModesGlobals_HARD then
				call MultiboardSetItemIcon(MultiboardGetItem(.PlayerStats, i + 1, 4), "ReplaceableTextures\\CommandButtons\\BTNAnkh.blp")
            endif
			
            if GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING then
                set u = User(i)
                set mt = u.Team
                
                call MultiboardSetItemValue(MultiboardGetItem(.PlayerStats, i + 1, 0), u.GetStylizedPlayerName())
                call MultiboardSetItemValue(MultiboardGetItem(.PlayerStats, i + 1, 1), mt.OnLevel.Name)
                call MultiboardSetItemValue(MultiboardGetItem(.PlayerStats, i + 1, 2), I2S(mt.Score))
                call MultiboardSetItemValue(MultiboardGetItem(.PlayerStats, i + 1, 3), I2S(mt.ContinueCount))
                
                
                call MultiboardReleaseItem(MultiboardGetItem(.PlayerStats, i + 1, 0))
                call MultiboardReleaseItem(MultiboardGetItem(.PlayerStats, i + 1, 1))
                call MultiboardReleaseItem(MultiboardGetItem(.PlayerStats, i + 1, 2))
                call MultiboardReleaseItem(MultiboardGetItem(.PlayerStats, i + 1, 3))
                
				
				if RewardMode == GameModesGlobals_HARD then
					call MultiboardSetItemValue(MultiboardGetItem(.PlayerStats, i + 1, 4), I2S(u.Deaths))
					call MultiboardReleaseItem(MultiboardGetItem(.PlayerStats, i + 1, 4))
				endif
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
        
        //call TimerStart(t, MULTIBOARD_HIDE_DELAY, false, function MazingTeam.MultiboardHideCallback)
        
        set t = null
    endmethod
	
	public method ApplyEndGame takes boolean victory returns nothing
		local SimpleList_ListNode curPlayer = .FirstUser
		
		loop
		exitwhen curPlayer == 0
			if victory then
				call CustomVictoryBJ(Player(curPlayer.value), true, false)
			else
				call CustomDefeatDialogBJ(Player(curPlayer.value), LocalizeContent('TCEG', User(curPlayer.value).LanguageCode))
			endif
		set curPlayer = curPlayer.next
		endloop
	endmethod
	public static method ApplyEndGameAll takes MazingTeam victor returns nothing
		local SimpleList_ListNode curTeamNode = thistype.AllTeams.first
		
		loop
        exitwhen curTeamNode == 0
            if MazingTeam(curTeamNode.value) == victor then
				call MazingTeam(curTeamNode.value).ApplyEndGame(true)
			else
				call MazingTeam(curTeamNode.value).ApplyEndGame(false)
			endif
			
            set curTeamNode = curTeamNode.next
        endloop
	endmethod
	
	public method PauseTeam takes boolean flag returns nothing
		local SimpleList_ListNode curPlayerNode = .FirstUser
		
		loop
		exitwhen curPlayerNode == 0
			call User(curPlayerNode.value).Pause(flag)
		set curPlayerNode = curPlayerNode.next
		endloop
	endmethod
	public method CancelAutoUnpauseForTeam takes nothing returns nothing
		local SimpleList_ListNode curPlayerNode = .FirstUser
		
		loop
		exitwhen curPlayerNode == 0
			call User(curPlayerNode.value).CancelAutoUnpause()
		set curPlayerNode = curPlayerNode.next
		endloop
	endmethod
	public method RegisterAutoUnpauseForTeam takes real timeout returns nothing
		local SimpleList_ListNode curPlayerNode = .FirstUser
		
		loop
		exitwhen curPlayerNode == 0
			call User(curPlayerNode.value).RegisterAutoUnpause(timeout)
		set curPlayerNode = curPlayerNode.next
		endloop
	endmethod
	public method GetAutoUnpauseLeastRemainingTime takes nothing returns real
		local SimpleList_ListNode curPlayerNode = .FirstUser
		local real leastTime = -1.
		local real curPlayerTime
		
		loop
		exitwhen curPlayerNode == 0
		set curPlayerTime = User(curPlayerNode.value).GetAutoUnpauseRemainingTime()
			if leastTime == -1. or (curPlayerTime != -1. and curPlayerTime < leastTime) then
				set leastTime = curPlayerTime
			endif
		set curPlayerNode = curPlayerNode.next
		endloop
				
		return leastTime
	endmethod
	
	public method DiscoverQuestForTeam takes quest q returns nothing
		local SimpleList_ListNode curPlayerNode = .FirstUser
		
		loop
		exitwhen curPlayerNode == 0
			call User(curPlayerNode.value).DiscoverQuest(q)
		set curPlayerNode = curPlayerNode.next
		endloop
	endmethod
	
	public method SetUnitLocalVisibilityForTeam takes unit u, boolean visible returns nothing
		local SimpleList_ListNode curPlayerNode = .FirstUser
		
		loop
		exitwhen curPlayerNode == 0
			call SetUnitLocalVisibility(u, curPlayerNode.value, visible)
		set curPlayerNode = curPlayerNode.next
		endloop
	endmethod
	public method SetUnitLocalOpacityForTeam takes unit u, integer opacity returns nothing
		local SimpleList_ListNode curPlayerNode = .FirstUser
		
		loop
		exitwhen curPlayerNode == 0
			call SetUnitLocalOpacity(u, curPlayerNode.value, opacity)
		set curPlayerNode = curPlayerNode.next
		endloop
	endmethod
		
	public method PlaySoundForTeam takes sound sfx returns nothing
		local SimpleList_ListNode curPlayerNode = .FirstUser
		
		loop
		exitwhen curPlayerNode == 0
			if GetLocalPlayer() == Player(curPlayerNode.value) then
				call StartSound(sfx)
			endif
		set curPlayerNode = curPlayerNode.next
		endloop
	endmethod
	
	public method PanCameraForTeam takes real x, real y, real duration returns nothing
		local SimpleList_ListNode curPlayerNode = .FirstUser
		
		loop
		exitwhen curPlayerNode == 0
			if GetLocalPlayer() == Player(curPlayerNode.value) then
				if User(curPlayerNode.value).IsAFK then
					call SetCameraPosition(x, y)
					
					//these don't return the updated value until a timeout of 0 for some reason
					// set User.LocalCameraTargetPosition.x = GetCameraTargetPositionX()
					// set User.LocalCameraTargetPosition.y = GetCameraTargetPositionY()
					set User.LocalCameraTargetPosition.x = x
					set User.LocalCameraTargetPosition.y = y
				else
					call PanCameraToTimed(x, y, duration)
				endif
			endif
		set curPlayerNode = curPlayerNode.next
		endloop
	endmethod
	
	private static method FadeInForTeamCB takes nothing returns nothing
		local timer t = GetExpiredTimer()
		local MazingTeam mt = GetTimerData(t)
		local SimpleList_ListNode curPlayerNode = mt.FirstUser
		
		loop
		exitwhen curPlayerNode == 0
			if GetLocalPlayer() == Player(curPlayerNode.value) then
				call DisplayCineFilter(false)
				call EnableUserUI(true)
			endif
		set curPlayerNode = curPlayerNode.next
		endloop
		
		call ReleaseTimer(t)
		set t = null
	endmethod
	public method FadeInForTeam takes real duration returns nothing
		local string filterTexture = "ReplaceableTextures\\CameraMasks\\Black_mask.blp"
		local SimpleList_ListNode curPlayerNode = .FirstUser
		
		loop
		exitwhen curPlayerNode == 0
			if GetLocalPlayer() == Player(curPlayerNode.value) then
				call EnableUserUI(false)
				
				call SetCineFilterTexture(filterTexture)
				call SetCineFilterBlendMode(BLEND_MODE_BLEND)
				call SetCineFilterTexMapFlags(TEXMAP_FLAG_NONE)
				call SetCineFilterStartUV(0, 0, 1, 1)
				call SetCineFilterEndUV(0, 0, 1, 1)
				call SetCineFilterStartColor(PercentTo255(100), PercentTo255(100), PercentTo255(100), PercentTo255(100))
				call SetCineFilterEndColor(PercentTo255(100), PercentTo255(100), PercentTo255(100), PercentTo255(0))
				call SetCineFilterDuration(duration)
				
				call DisplayCineFilter(true)
			endif
		set curPlayerNode = curPlayerNode.next
		endloop
		
		call TimerStart(NewTimerEx(this), duration, false, function thistype.FadeInForTeamCB)
	endmethod
	public method FadeOutForTeam takes real duration returns nothing
		local string filterTexture = "ReplaceableTextures\\CameraMasks\\Black_mask.blp"
		local SimpleList_ListNode curPlayerNode = .FirstUser
		
		loop
		exitwhen curPlayerNode == 0
			if GetLocalPlayer() == Player(curPlayerNode.value) then
				call EnableUserUI(false)
				
				call SetCineFilterTexture(filterTexture)
				call SetCineFilterBlendMode(BLEND_MODE_BLEND)
				call SetCineFilterTexMapFlags(TEXMAP_FLAG_NONE)
				call SetCineFilterStartUV(0, 0, 1, 1)
				call SetCineFilterEndUV(0, 0, 1, 1)
				call SetCineFilterStartColor(PercentTo255(100), PercentTo255(100), PercentTo255(100), PercentTo255(0))
				call SetCineFilterEndColor(PercentTo255(100), PercentTo255(100), PercentTo255(100), PercentTo255(100))
				call SetCineFilterDuration(duration)
				
				call DisplayCineFilter(true)
			endif
		set curPlayerNode = curPlayerNode.next
		endloop
	endmethod
	
	public method SetSharedControlForTeam takes User user, boolean flag returns nothing
		local SimpleList_ListNode curPlayerNode = .FirstUser
		
		loop
		exitwhen curPlayerNode == 0
			if curPlayerNode.value != user then
				call SetPlayerAlliance(Player(user), Player(curPlayerNode.value), ALLIANCE_SHARED_CONTROL, flag)
			endif
		set curPlayerNode = curPlayerNode.next
		endloop
	endmethod
	
	public method ResetHealthForTeam takes nothing returns nothing
		local SimpleList_ListNode curPlayerNode = .FirstUser
		
		loop
		exitwhen curPlayerNode == 0
			if User(curPlayerNode.value).IsAlive then
				call SetUnitState(MazersArray[curPlayerNode.value], UNIT_STATE_LIFE, GetUnitState(MazersArray[curPlayerNode.value], UNIT_STATE_MAX_LIFE))
			endif
		set curPlayerNode = curPlayerNode.next
		endloop
	endmethod
	
	public method CreateInstantEffectForTeam takes string fxFileLocation, User filter returns nothing
		local SimpleList_ListNode curPlayerNode = .FirstUser
		
		loop
		exitwhen curPlayerNode == 0
			if (filter == -1 or curPlayerNode.value != filter) and User(curPlayerNode.value).ActiveUnit != null then
				call CreateInstantSpecialEffect(fxFileLocation, GetUnitX(User(curPlayerNode.value).ActiveUnit), GetUnitY(User(curPlayerNode.value).ActiveUnit), Player(curPlayerNode.value))
			endif
		set curPlayerNode = curPlayerNode.next
		endloop
	endmethod
		
    public static method create takes nothing returns thistype
        local thistype mt = thistype.allocate()
		
        if not .AllTeams.contains(mt) then
			// set mt.RecentlyTransferred = false //used to make sure triggers aren't run multiple times / no interrupts
            // set mt.LastTransferTime = -50 //has never transferred
            set mt.OnLevel = TEMP_LEVEL_ID
            set mt.OnCheckpoint = -1
            set mt.Revive = Rect(0, 0, 200, 200)
            // call mt.MoveRevive(gg_rct_IntroWorld_R1)
            set mt.Score = 0
            set mt.DefaultGameMode = GAMEMODE_INIT
			set mt.LastEventUser = -1
            
			set mt.Users = SimpleList_List.create()
            set mt.AllWorldProgress = SimpleList_List.create()
			
            call thistype.AllTeams.addEnd(mt)
            //set .NumberTeams = .NumberTeams + 1
            set Teams_MazingTeam.NumberTeams = Teams_MazingTeam.NumberTeams + 1
        else
            call DisplayTextToForce(bj_FORCE_PLAYER[0], "Overlapping team ID: " + I2S(mt) + " -- invalid game state")
            return 0 //team already exists
        endif
        return mt
    endmethod
	
	private static method onInit takes nothing returns nothing
		set thistype.AllTeams = SimpleList_List.create()
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