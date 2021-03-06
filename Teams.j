library Teams requires MazerGlobals, MultiboardGlobals, User, UnitLocalVisibility, LevelPath
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
	
	// private constant real PATH_UPDATE_TIMEOUT = .5
	private constant real PATH_UPDATE_TIMEOUT = .035
	private constant real OFFPATH_UPDATE_TIMEOUT = 2.
	
	Teams_MazingTeam TriggerTeam //used with events
	
	private constant boolean DEBUG_FORCE_TEAM_VS_TEAM = false
endglobals

function interface LocalizeContentFunc takes integer origin, User localizer returns string

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
	public integer OnCheckpoint //Used purely in conjunction with levels struct. ==0 refers to the initial CP for a level
    public string TeamName // TODO allow custom player defined team names
	readonly LevelPath Path
    private integer Score
    public real Weight
    public integer DefaultGameMode
    
	public SimpleList_List AllWorldProgress
    //public integer DefaultGameMode
    
    // public static multiboard PlayerStats    
    readonly static integer NumberTeams = 0
	readonly static SimpleList_List AllTeams
	    
	implement Alloc
		
	method operator < takes thistype other returns boolean
		return R2I(I2R(this)) < R2I(I2R(other))
	endmethod
	
    public method MoveRevive takes rect newlocation returns nothing
        call MoveRectTo(.Revive, GetRectCenterX(newlocation), GetRectCenterY(newlocation))
    endmethod
    
    public method MoveReviveToDoors takes nothing returns nothing
        call MoveRectTo(.Revive, GetRectCenterX(gg_rct_HubWorld_R), GetRectCenterY(gg_rct_HubWorld_R))
    endmethod
	
    public method ClearVoteMenu takes nothing returns nothing
		local SimpleList_ListNode curUserNode = .FirstUser
        
        loop
        exitwhen curUserNode == 0
            call User(curUserNode.value).ClearVoteMenu()
        set curUserNode = curUserNode.next
        endloop
	endmethod
	public method SetVoteMenu takes VisualVote_voteMenu menu returns nothing
		local SimpleList_ListNode curUserNode = .FirstUser
        
        loop
        exitwhen curUserNode == 0
            call User(curUserNode.value).SetVoteMenu(menu)
        set curUserNode = curUserNode.next
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
				
				call u.SetConnection(this.OnLevel.GetCheckpoint(this.OnCheckpoint).DefaultConnection)
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
			if User(u.value).IsPlaying then
            	call User(u.value).AddCinematicToQueue(cinema)
			endif
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
	
	public method DisplayDynamicContent takes LocalizeContentFunc localizeFunc, integer origin returns nothing
		local SimpleList_ListNode curUserNode = this.Users.first
		local string localizedContent
		
		// call DisplayTextToPlayer(Player(0), 0, 0, "Displaying localized content: " + I2S(localizeFunc) + ", origin: " + I2S(origin))
		
		loop
		exitwhen curUserNode == 0
			//this approach prevents any desyncing over the string cache
			set localizedContent = localizeFunc.evaluate(origin, curUserNode.value)
			// call DisplayTextToPlayer(Player(0), 0, 0, "Displaying local content for: " + I2S(curUserNode.value))
			if GetLocalPlayer() == Player(curUserNode.value) then
				// call User(curUserNode.value).DisplayMessage(localizeFunc.evaluate(origin, curUserNode.value), 0)
				call User(curUserNode.value).DisplayMessage(localizedContent, 0)
			endif
		set curUserNode = curUserNode.next
		endloop
	endmethod
	public static method DisplayDynamicContentAll takes LocalizeContentFunc localizeFunc, integer origin, Teams_MazingTeam filter returns nothing
		local SimpleList_ListNode curTeamNode = thistype.AllTeams.first
		
		loop
		exitwhen curTeamNode == 0
			if curTeamNode.value != filter  then
				call Teams_MazingTeam(curTeamNode.value).DisplayDynamicContent(localizeFunc, origin)
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
    
	private static method PlayerLeavesCB takes nothing returns nothing
		local timer t = GetExpiredTimer()
		local User u = GetTimerData(t)
		local thistype mt = u.Team
		
		local SimpleList_ListNode curUserNode = mt.Users.first
		local boolean anyActive = false
		
		local integer originalSortIndex = u.StatisticsSortIndex
		
		loop
        exitwhen curUserNode == 0 or anyActive
			if User(curUserNode.value).IsPlaying then
				set anyActive = User(curUserNode.value).IsPlaying
			endif
		set curUserNode = curUserNode.next
		endloop
		
		if not anyActive then
			set mt.IsTeamPlaying = false
			
			//zero out score
			call mt.ChangeScore(-mt.Score)
		else
			//update team comparison weights and give the team that just lost a player ~1 more continue
			call mt.ComputeTeamWeights()
			set mt.ContinueCount = mt.ContinueCount + R2I(1 * mt.Weight + .5)
			
			call Teams_MazingTeam.MultiboardUpdateSort()
		endif
		
		if u.StatisticsSortIndex == originalSortIndex then
			call u.UpdateMultiboard()
		endif
		
		call ReleaseTimer(t)
		set t = null
	endmethod
    public static method PlayerLeaves takes nothing returns nothing
        local integer pID = GetPlayerId(GetTriggerPlayer())
        local User u = User(pID)
				
        call u.OnLeave()
        
		call TimerStart(NewTimerEx(u), 0.01, false, function thistype.PlayerLeavesCB)		
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
    
	public method GetTeamColor takes nothing returns string
		local string hex
        
		if GameMode == GameModesGlobals_SOLO then
			set hex = User(.FirstUser.value).GetPlayerColorHex()
		else
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
		endif
		
		return hex
	endmethod
	public method GetLocalizedTeamName takes User forUser returns string
		local string name = ""
		local integer id
		
		if GameMode == GameModesGlobals_SOLO then
			set id = .FirstUser.value + 1
		else
			set id = this
		endif
		
		if id == 1 then
			set name = LocalizeContent('TGRE', forUser.LanguageCode)
		elseif id == 2 then
			set name = LocalizeContent('TGBL', forUser.LanguageCode)
		elseif id == 3 then
			set name = LocalizeContent('TGTE', forUser.LanguageCode)
		elseif id == 4 then
			set name = LocalizeContent('TGPU', forUser.LanguageCode)
		elseif id == 5 then
			set name = LocalizeContent('TGYE', forUser.LanguageCode)
		elseif id == 6 then
			set name = LocalizeContent('TGOR', forUser.LanguageCode)
		elseif id == 7 then
			set name = LocalizeContent('TGRE', forUser.LanguageCode)
		elseif id == 8 then
			set name = LocalizeContent('TGPI', forUser.LanguageCode)
		endif
	
		set name = ColorMessage(name, .GetTeamColor())
		
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
	public method GetTeamColorIconPath takes nothing returns string
		if this == 1 then
			return "war3mapImported\\PC_Red.tga"
		elseif this == 2 then
			return "war3mapImported\\PC_Blue.tga"
		elseif this == 3 then
			return "war3mapImported\\PC_Teal.tga"
		elseif this == 4 then
			return "war3mapImported\\PC_Purple.tga"
		elseif this == 5 then
			return "war3mapImported\\PC_Yellow.tga"
		elseif this == 6 then
			return "war3mapImported\\PC_Orange.tga"
		elseif this == 7 then
			return "war3mapImported\\PC_Green.tga"
		elseif this == 8 then
			return "war3mapImported\\PC_Pink.tga"
		else
			return null
		endif
	endmethod

	public method GetLocalizedPlayerName takes User target, User localizer returns string
        local string hex = this.GetTeamColor()
        
        if GetPlayerSlotState(Player(target)) == PLAYER_SLOT_STATE_PLAYING then
			if target.IsAFK then
				return ColorMessage("(" + StringCase(LocalizeContent('CAFK', localizer.LanguageCode), true) + ") ", DISABLED_COLOR) + ColorMessage(GetPlayerName(Player(target)), hex)
			else
				return ColorMessage(GetPlayerName(Player(target)), hex)
			endif
        else
			return ColorMessage(LocalizeContent('USLE', localizer.LanguageCode) + " " + GetPlayerName(Player(target)), hex)
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
		local integer rand
		
		if NumberTeams != 1 or filter == 0 then
			loop
			set rand = GetRandomInt(0, NumberTeams - 1)
			exitwhen rand + 1 != filter
			endloop
			
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
		
		call .PartialUpdateMultiboard(MULTIBOARD_CONTINUES)
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
			
			call .PartialUpdateMultiboard(MULTIBOARD_CONTINUES)
		endif
	endmethod
		
	private static method LocalizeNeedsScore takes MazingTeam team, User localizer returns string
		return StringFormat2(LocalizeContent('TCTE', localizer.LanguageCode), team.GetLocalizedTeamName(localizer), ColorValue(I2S(VictoryScore - team.Score)))
		// return LocalizeContent('TCTE', localizer.LanguageCode) + " " /*
			// */ + origin.Team.GetLocalizedTeamName(localizer) + " " /*
			// */ + LocalizeContent('TCNE', localizer.LanguageCode) + " " /*
			// */ + ColorValue(I2S(VictoryScore - origin.Team.Score)) + " " /*
			// */ + LocalizeContent('TCMO', localizer.LanguageCode)
	endmethod
	private static method LocalizeOnlyNeedsScore takes MazingTeam team, User localizer returns string	
		return StringFormat2(LocalizeContent('TCNE', localizer.LanguageCode), team.GetLocalizedTeamName(localizer), ColorValue(I2S(VictoryScore - team.Score)))
		// return LocalizeContent('TCTE', localizer.LanguageCode) + " " /*
			// */ + origin.Team.GetLocalizedTeamName(localizer) + " " /*
			// */ + LocalizeContent('TCON', localizer.LanguageCode) + " " /*
			// */ + ColorValue(I2S(VictoryScore - origin.Team.Score)) + " " /*
			// */ + LocalizeContent('TCMO', localizer.LanguageCode)
	endmethod
	public method GetScore takes nothing returns integer
		return .Score
	endmethod
	public method ChangeScore takes integer scoreOffset returns nothing
		local integer ogScore = VictoryScore - .Score
		local integer teamNameContentID = this.GetTeamNameContentID()
		local string teamColor = this.GetTeamColor()
		
		if scoreOffset != 0 then
			set .Score = .Score + scoreOffset
			
			//check for victory conditions if VictoryScore is configured to be non-zero
			if VictoryScore != 0 then
				if VictoryScore - .Score <= 0 then
					call MazingTeam.ApplyEndGameAll(this)
				else
					if (VictoryScore - .Score <= 10 and ogScore > 10) or (VictoryScore - .Score <= 5 and ogScore > 5) then
						call thistype.DisplayDynamicContentAll(LocalizeNeedsScore, this, 0)
					elseif VictoryScore - .Score <= 3 and ogScore > 3 then
						call thistype.DisplayDynamicContentAll(LocalizeOnlyNeedsScore, this,  0)
					endif
				endif
			endif
			
			call MultiboardUpdateSort()
			call .PartialUpdateMultiboard(MULTIBOARD_SCORE)
		endif
	endmethod
	
	public static method IsTeamVersusTeam takes nothing returns boolean
		static if DEBUG_FORCE_TEAM_VS_TEAM then
			return true
		else
			return thistype.AllTeams.count > 1 and GameMode != GameModesGlobals_SOLO
		endif
	endmethod
	public static method GetPlayerNameColumn takes nothing returns integer
		if thistype.IsTeamVersusTeam() then
			return 1
		else
			return 0
		endif
	endmethod
	
	public method UpdateMultiboardLevelIcon takes nothing returns nothing
		local SimpleList_ListNode curUserNode = .FirstUser
        
        loop
        exitwhen curUserNode == 0
            call User(curUserNode.value).UpdateMultiboardLevelIcon()
        set curUserNode = curUserNode.next
        endloop
	endmethod
	
	public method UpdateMultiboard takes nothing returns nothing
        local SimpleList_ListNode curUserNode = .FirstUser
        
        loop
        exitwhen curUserNode == 0
            call User(curUserNode.value).UpdateMultiboard()
        set curUserNode = curUserNode.next
        endloop
    endmethod
	public method PartialUpdateMultiboard takes integer columnID returns nothing
		local SimpleList_ListNode curUserNode = .FirstUser
        
        loop
        exitwhen curUserNode == 0
            call User(curUserNode.value).PartialUpdateMultiboard(columnID)
        set curUserNode = curUserNode.next
        endloop
	endmethod
	
	public method MinimizeMultiboard takes boolean flag returns nothing
		local SimpleList_ListNode curUserNode = .FirstUser
        
        loop
        exitwhen curUserNode == 0
            call User(curUserNode.value).MinimizeMultiboard(flag)
        set curUserNode = curUserNode.next
        endloop
	endmethod
	public static method MinimizeMultiboardAll takes boolean flag returns nothing
		local SimpleList_ListNode curTeamNode = thistype.AllTeams.first
		
		loop
		exitwhen curTeamNode == 0
			call Teams_MazingTeam(curTeamNode.value).MinimizeMultiboard(flag)
		set curTeamNode = curTeamNode.next
		endloop
	endmethod
	
	public method DisplayMultiboard takes boolean flag returns nothing
		local SimpleList_ListNode curUserNode = .FirstUser
        
        loop
        exitwhen curUserNode == 0
            call User(curUserNode.value).DisplayMultiboard(flag)
        set curUserNode = curUserNode.next
        endloop
	endmethod
	public static method DisplayMultiboardAll takes boolean flag returns nothing
		local SimpleList_ListNode curTeamNode = thistype.AllTeams.first
		
		loop
		exitwhen curTeamNode == 0
			call Teams_MazingTeam(curTeamNode.value).DisplayMultiboard(flag)
		set curTeamNode = curTeamNode.next
		endloop
	endmethod
	
	//basic bubble sort based on score < team < user
	private static method MultiboardSortUser takes SimpleList_List sortOrder, User u returns nothing
		local SimpleList_ListNode curSortOrderNode = sortOrder.first
		local integer sortIndex = 0
		local boolean foundSortIndex = false
		
		loop
		exitwhen curSortOrderNode == 0
			if User(curSortOrderNode.value).Team.Score < u.Team.Score then
				set foundSortIndex = true
			elseif User(curSortOrderNode.value).Team.Score == u.Team.Score then
				if User(curSortOrderNode.value).Team > u.Team then
					set foundSortIndex = true
				elseif User(curSortOrderNode.value).Team == u.Team then
					if (u.IsPlaying and User(curSortOrderNode.value).IsPlaying) or (not u.IsPlaying and not User(curSortOrderNode.value).IsPlaying) then
						if User(curSortOrderNode.value) > u then
							set foundSortIndex = true
						endif
					elseif u.IsPlaying then
						set foundSortIndex = true
					// elseif User(curSortOrderNode.value).IsPlaying then
						
					endif
					
					// if User(curSortOrderNode.value) > u then
						// set foundSortIndex = true
					// endif
				endif
			endif
		
			exitwhen foundSortIndex
		
		set curSortOrderNode = curSortOrderNode.next
		set sortIndex = sortIndex + 1
		endloop
		
		call sortOrder.insert(u, sortIndex)
	endmethod
	public static method MultiboardUpdateSort takes nothing returns nothing
		local SimpleList_List sortOrder = SimpleList_List.create()
		
		local SimpleList_ListNode curTeamNode = thistype.AllTeams.first
		local SimpleList_ListNode curUserNode
		
		local integer sortIndex = 1
		
		loop
		exitwhen curTeamNode == 0
			set curUserNode = Teams_MazingTeam(curTeamNode.value).Users.first
			
			loop
			exitwhen curUserNode == 0
				call MultiboardSortUser(sortOrder, curUserNode.value)
			set curUserNode = curUserNode.next
			endloop
		set curTeamNode = curTeamNode.next
		endloop
		
		// call sortOrder.print(0)
		
		set curUserNode = sortOrder.first
		loop
		exitwhen curUserNode == 0
			if User(curUserNode.value).StatisticsSortIndex != sortIndex then
				set User(curUserNode.value).StatisticsSortIndex = sortIndex
				call User(curUserNode.value).UpdateMultiboard()
			endif
		set sortIndex = sortIndex + 1
		set curUserNode = curUserNode.next
		endloop
				
		call sortOrder.destroy()
	endmethod
	
    public static method MultiboardSetupInit takes nothing returns nothing
		local SimpleList_ListNode curTeamNode = thistype.AllTeams.first
		local SimpleList_ListNode curUserNode
		
		local integer sortIndex = 1
		
		//init localized column text for multiboard
		loop
		exitwhen curTeamNode == 0
			set curUserNode = Teams_MazingTeam(curTeamNode.value).Users.first
			
			loop
			exitwhen curUserNode == 0
				// //TODO assumes player order matches team assignment, which it won't for random teams mode
				// set User(curUserNode.value).StatisticsSortIndex = sortIndex
				// set sortIndex = sortIndex + 1
				
				call User(curUserNode.value).InitializeMultiboard()
			set curUserNode = curUserNode.next
			endloop
		set curTeamNode = curTeamNode.next
		endloop
		
		//init multiboard sort order
		call MultiboardUpdateSort()
		
		//update all multiboards
		set curTeamNode = thistype.AllTeams.first
		loop
		exitwhen curTeamNode == 0
			set curUserNode = Teams_MazingTeam(curTeamNode.value).Users.first
			
			loop
			exitwhen curUserNode == 0
				call User(curUserNode.value).InitializeMultiboardIcons()
				call User(curUserNode.value).UpdateMultiboard()
				
				call User(curUserNode.value).InitializeMultiboardDisplay()
			set curUserNode = curUserNode.next
			endloop
		set curTeamNode = curTeamNode.next
		endloop
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

	public static method GetMajorityLanguage takes nothing returns string
		local SimpleList_List languageUserCounts = SimpleList_List.create()
		local SimpleList_ListNode languageUserCountNode
		local integer iLanguageCode = 1

		local SimpleList_ListNode curTeamNode = thistype.AllTeams.first
		local SimpleList_ListNode curUserNode
		
		local string leadLanguageCode = GetLanguageCodeFromID(LocalizationData_ENGLISH_ID)
		local integer leadLanguageCount = 0
		
		//initialize languageUserCounts as all 0's
		loop
		exitwhen iLanguageCode > LocalizationData_LANGUAGE_COUNT
			call languageUserCounts.addEnd(0)
		set iLanguageCode = iLanguageCode + 1
		endloop

		//accumulate all user's language into languageUserCounts using language ID as index
		loop
		exitwhen curTeamNode == 0
			set curUserNode = thistype(curTeamNode.value).Users.first

			loop
			exitwhen curUserNode == 0
				if User(curUserNode.value).IsPlaying then
					set languageUserCountNode = languageUserCounts.get(GetIDForLanguageCode(User(curUserNode.value).LanguageCode) - 1)

					set languageUserCountNode.value = languageUserCountNode.value + 1
				endif
			set curUserNode = curUserNode.next
			endloop
		set curTeamNode = curTeamNode.next
		endloop

		//determine the language with the most user's
		set languageUserCountNode = languageUserCounts.first
		set iLanguageCode = 1
		loop
		exitwhen languageUserCountNode == 0
			if languageUserCountNode.value > leadLanguageCount then
				set leadLanguageCode = GetLanguageCodeFromID(iLanguageCode)
				set leadLanguageCount = languageUserCountNode.value
			endif
		set languageUserCountNode = languageUserCountNode.next
		set iLanguageCode = iLanguageCode + 1
		endloop

		call languageUserCounts.destroy()
		return leadLanguageCode
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
	
	public method IsTeamAwaitingAFK takes nothing returns boolean
		local SimpleList_ListNode curUserNode = .FirstUser
		
		local integer aliveAndActive = 0
		local integer deadAndActive = 0
		
		loop
		exitwhen curUserNode == 0
			if not User(curUserNode.value).IsAFK and User(curUserNode.value).IsPlaying then
				if User(curUserNode.value).IsAlive and User(curUserNode.value).GameMode != GAMEMODE_DYING then
					set aliveAndActive = aliveAndActive + 1
				else
					set deadAndActive = deadAndActive + 1
				endif
			endif
		set curUserNode = curUserNode.next
		endloop
		
		// call DisplayTextToPlayer(Player(.Users.last.value), 0, 0, "A&A: " + I2S(aliveAndActive) + ", D&A: " + I2S(deadAndActive))
		
		return aliveAndActive == 0 and deadAndActive > 0
	endmethod
	public method ApplyAwaitingAFKState takes nothing returns nothing
		local SimpleList_ListNode curUserNode = .FirstUser
		
		loop
		exitwhen curUserNode == 0
			call User(curUserNode.value).ApplyAwaitingAFKState()
		set curUserNode = curUserNode.next
		endloop
	endmethod
	
	public method UpdateAwaitingAFKState takes nothing returns nothing
		if .IsTeamAwaitingAFK() then
			// call DisplayTextToPlayer(Player(.Users.last.value), 0, 0, "applying afk platformer")
			call .ApplyAwaitingAFKState()
		endif
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
			call User(curPlayerNode.value).PanCamera(x, y, duration)
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
	
	//sets all members of a team to a certain alliance setting towards the target player
	public method SetTeamAlliance takes player target, alliancetype field, boolean flag returns nothing
		local SimpleList_ListNode curPlayerNode = .FirstUser
		
		loop
		exitwhen curPlayerNode == 0
			if curPlayerNode.value != GetPlayerId(target) then
				call SetPlayerAlliance(Player(curPlayerNode.value), target, field, flag)
			endif
		set curPlayerNode = curPlayerNode.next
		endloop
	endmethod
	//sets all members of a user's team to share control (status = flag) of that user's active unit
	public method SetSharedControlForTeam takes User user, boolean flag returns nothing
		local SimpleList_ListNode curPlayerNode = .FirstUser
		
		//TODO API should prevent this, either refactor this method to be static and use user.Team or refactor this method to the User implementation
		if CONFIGURATION_PROFILE != RELEASE then
			if user.Team != this then
				call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Setting shared control for user not via the wrong team!")
			endif
		endif
		
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
	
	public method SetPathForTeam takes Checkpoint checkpoint returns nothing
		local SimpleList_ListNode curUserNode = this.FirstUser
		
		static if LevelPath_DEBUG_FINALIZE then
			if checkpoint.Path != 0 and not checkpoint.Path.Finalized then
				call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Warning! Setting Team's path to a non-finalized Path! Expect lots of vector2 leaks")
				call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Path ID: " + I2S(checkpoint.Path) + ", set for team: " + I2S(this))
			endif
		endif
		
		if this.Path != checkpoint.Path then
			set this.Path = checkpoint.Path			
			
			loop
			exitwhen curUserNode == 0
				call User(curUserNode.value).SetPath(checkpoint.Path, checkpoint.DefaultConnection)
				
			set curUserNode = curUserNode.next
			endloop
		endif
	endmethod
	
	public method CheckPathForTeam takes nothing returns nothing		
		local SimpleList_ListNode curUserNode = this.FirstUser
		
		if this.Path != 0 then			
			loop
			exitwhen curUserNode == 0
				// call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Checking path: " + I2S(this.Path) + ", for user: " + I2S(curUserNode.value))
				
				call User(curUserNode.value).CheckPath(this.Path)
				
			set curUserNode = curUserNode.next
			endloop
		endif
	endmethod
	private static method AutoCheckPath takes nothing returns nothing
		local SimpleList_ListNode curTeamNode = thistype.AllTeams.first
        
        loop
        exitwhen curTeamNode == 0
			// call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Auto checking team: " + I2S(curTeamNode.value))
			
			call MazingTeam(curTeamNode.value).CheckPathForTeam()
			
		set curTeamNode = curTeamNode.next
        endloop
	endmethod

	private method CheckOffPathForTeam takes nothing returns nothing
		local SimpleList_ListNode curUserNode = this.FirstUser
		
		if this.Path != 0 then			
			loop
			exitwhen curUserNode == 0
				// call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Checking off path: " + I2S(this.Path) + ", for user: " + I2S(curUserNode.value))
				
				call User(curUserNode.value).CheckOffPath(this.Path)
			set curUserNode = curUserNode.next
			endloop
		endif
	endmethod
	private static method AutoCheckOffPath takes nothing returns nothing
		local SimpleList_ListNode curTeamNode = thistype.AllTeams.first
        
        loop
        exitwhen curTeamNode == 0
			// call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Auto checking off path for team: " + I2S(curTeamNode.value))
			
			call MazingTeam(curTeamNode.value).CheckOffPathForTeam()
			
		set curTeamNode = curTeamNode.next
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
		
		call TimerStart(CreateTimer(), PATH_UPDATE_TIMEOUT, true, function thistype.AutoCheckPath)
		call TimerStart(CreateTimer(), OFFPATH_UPDATE_TIMEOUT, true, function thistype.AutoCheckOffPath)
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