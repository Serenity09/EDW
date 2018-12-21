library User requires MazerGlobals, Platformer, TerrainHelpers, Cinema

globals
	User TriggerUser //used with events
endglobals

struct User extends array
    //public integer PlayerID
    public boolean IsPlaying
    public boolean IsAlive
    public integer Deaths
    public fogmodifier Vision
    public unit ActiveUnit
    public Platformer Platformer
    public integer GameMode //0: regular DH mazing, 1: wisp platforming, 9: mini-games?
    public integer PreviousGameMode //only standard or platforming
    public Teams_MazingTeam Team
    public Cinematic CinematicPlaying
    public SimpleList_List CinematicQueue //FiFo
	public effect ActiveEffect
    
    public static integer ActivePlayers
	
    //TODO
    //public integer TotalScore
    //public integer ResourceCount
    
    //MOST IMPORTANT that "this" returns the exact player ID without having to remember to add / subtract 1
    //also no need to recycle users, let's just keep a basic count
    private static integer count = -1
    
	public method SetActiveEffect takes string strEffect, string attachPoint returns nothing
		if .ActiveEffect != null then
			call DestroyEffect(.ActiveEffect)
			set .ActiveEffect = null
		endif
		
		if strEffect != null then
			set .ActiveEffect = AddSpecialEffectTarget(strEffect, .ActiveUnit, attachPoint)
		endif
	endmethod
	public method ClearActiveEffect takes nothing returns nothing
		call .SetActiveEffect(null, null)
	endmethod
	
    public static method DisplayMessageAll takes string message returns nothing
        local integer i = 0
        
        loop
        exitwhen i > count
            call User(i).DisplayMessage(message, 0)
        set i = i + 1
        endloop
    endmethod
    
    public static method OnCinemaEndCB takes nothing returns boolean
        local User user = EventUser
        
        //call DisplayTextToForce(bj_FORCE_PLAYER[0], "Inside On Cinema End CB for user " + I2S(user))
        set user.CinematicPlaying = 0
        call user.CheckCinematicQueue()
        
        return false
    endmethod
    public method AddCinematicToQueue takes Cinematic cine returns nothing
        //call DisplayTextToForce(bj_FORCE_PLAYER[0], "Adding cinematic for user: " + I2S(this))
        
        //call cine.PreviousViewers.add(this)
        //call cine.OnCinemaEndCBs.add(thistype.OnCinemaEndCB)
        
        call .CinematicQueue.addEnd(cine)
        
        call .CheckCinematicQueue()
    endmethod
    public method CheckCinematicQueue takes nothing returns nothing
        //call DisplayTextToForce(bj_FORCE_PLAYER[0], "Checking cinema queue for user:" + I2S(this))
        //debug call .CinematicQueue.print(this)
        
        if .CinematicPlaying == 0 and .CinematicQueue.count > 0 then
            //call DisplayTextToForce(bj_FORCE_PLAYER[0], "popping next cinematic for user: " + I2S(this))
            
            set .CinematicPlaying = .CinematicQueue.pop().value
            call .CinematicPlaying.Activate(this)
        endif
    endmethod
    
    public method DisplayMessage takes string message, real duration returns nothing
        if .IsPlaying then
            if duration == 0 then
                call DisplayTextToPlayer(Player(this), 0, 0, message)
            else
                call DisplayTimedTextToPlayer(Player(this), 0, 0, duration, message)
            endif
        endif
    endmethod
    
    public method OnLeave takes nothing returns nothing
        call SwitchGameModesDefaultLocation(Teams_GAMEMODE_STANDARD)
        
        set .IsPlaying = false
        set .IsAlive = false
        
        //moves the mazing unit
        call SetUnitPosition(MazersArray[this], MazerGlobals_SAFE_X, MazerGlobals_SAFE_Y)
        //removes the reg unit from the reg game loop. thereby enabling regular terrain effects
        call GroupRemoveUnit(MazersGroup, MazersArray[this])
        //updates the number of units platforming/regular mazing
        set NumberMazing = NumberMazing - 1
        //hides the DH
        call ShowUnit(MazersArray[this], false)
        
        //update multiboard
        call .Team.UpdateMultiboard()
        
        //TODO cleanup any structs
        call DestroyFogModifier(.Vision)
        
        //call thistype.DisplayMessageAll(GetPlayerName(Player(this)) + " has left the game!")
        call thistype.DisplayMessageAll(this.GetStylizedPlayerName() + " has left the game!")
        
        set .Vision = null
        set .ActiveUnit = null
        
        set User.ActivePlayers = User.ActivePlayers - 1
    endmethod
    
    
    public method ReviveActiveHero takes real x, real y returns nothing
        if .GameMode == Teams_GAMEMODE_STANDARD then
            call ReviveHero(MazersArray[this], x, y, true)
            call PauseUnit(MazersArray[this], true)
            call SetUnitX(MazersArray[this], x)
            call SetUnitY(MazersArray[this], y)
        elseif .GameMode == Teams_GAMEMODE_PLATFORMING then
            call Platformer.StartPlatforming(x, y)
        endif
    endmethod
    
    public method ApplyDefaultCameras takes nothing returns nothing
        if .GameMode != Teams_GAMEMODE_PLATFORMING and .GameMode != Teams_GAMEMODE_PLATFORMING_PAUSED then
            if (GetLocalPlayer() == Player(this)) then
                call CameraSetupApply(DefaultCamera[this], false, false)
                call PanCameraToTimed(GetUnitX(.ActiveUnit), GetUnitY(.ActiveUnit), 0.0)
                if DefaultCameraTracking[this] then
                    call SetCameraTargetController(.ActiveUnit, 0, 0, false)
                endif
            endif
        else
            call .Platformer.ApplyCamera()
        endif
    endmethod
	public method ApplyDefaultSelections takes nothing returns nothing
		if .GameMode != Teams_GAMEMODE_PLATFORMING and .GameMode != Teams_GAMEMODE_PLATFORMING_PAUSED then
            if GetLocalPlayer() == Player(this) then
                call ClearSelection()
                if .ActiveUnit != null then
                    call SelectUnit(.ActiveUnit, true)
                endif
            endif
        endif
	endmethod
    
    public method ResetDefaultCamera takes nothing returns nothing
        if (GetLocalPlayer() == Player(this)) then
            call ResetToGameCamera(0)
            call CameraSetupApply(DefaultCamera[this], false, false)
        endif
    endmethod
    
    public method Pause takes boolean flag returns nothing
        if .IsPlaying and .IsAlive then
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "unpausing " + I2S(u))
            call PauseUnit(.ActiveUnit, flag)
            call IssueImmediateOrder(.ActiveUnit, "stop")
            
            if flag then
                if .GameMode == Teams_GAMEMODE_STANDARD then
                    call this.SwitchGameModesDefaultLocation(Teams_GAMEMODE_STANDARD_PAUSED)
                elseif .GameMode == Teams_GAMEMODE_PLATFORMING then
                    call this.SwitchGameModesDefaultLocation(Teams_GAMEMODE_PLATFORMING_PAUSED)
                endif
            else
                if .GameMode == Teams_GAMEMODE_STANDARD_PAUSED then
                    call this.SwitchGameModesDefaultLocation(Teams_GAMEMODE_STANDARD)
                elseif .GameMode == Teams_GAMEMODE_PLATFORMING_PAUSED then
                    call this.SwitchGameModesDefaultLocation(Teams_GAMEMODE_PLATFORMING)
                endif
            endif
        endif
    endmethod
    
    private static method UnpauseUserCB takes nothing returns nothing
        local timer t = GetExpiredTimer()
        local thistype u = thistype(GetTimerData(t))
        
        if u.IsPlaying then
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "unpausing " + I2S(u))
            //call PauseUnit(u.ActiveUnit, false)
            //call IssueImmediateOrder(u.ActiveUnit, "stop")
            
            call u.Pause(false)
        endif
                
        call ReleaseTimer(t)
        set t = null
    endmethod
    
    public method RespawnAtRect takes rect r, boolean moveliving returns nothing
        local real x = GetRectMinX(r)
        local real y = GetRectMinY(r)
        local integer ttype
		
		//call DisplayTextToForce(bj_FORCE_PLAYER[0], "respawn start for player " + I2S(this))
		// if this == 1 then
			// call DisplayTextToForce(bj_FORCE_PLAYER[0], "respawn start for player " + I2S(this))
			// //call DisplayTextToForce(bj_FORCE_PLAYER[0], "Active Unit name before " + GetUnitName(.ActiveUnit))
		// endif
		
        if .IsPlaying and (moveliving or not .IsAlive) then
            loop
                set x = GetRandomReal(GetRectMinX(r), GetRectMaxX(r))
                set y = GetRandomReal(GetRectMinY(r), GetRectMaxY(r))
                //check these values to see if they're on abyss, redo if so
                set ttype = GetTerrainType(x, y)
                if .Team.DefaultGameMode == Teams_GAMEMODE_STANDARD then
                    exitwhen (ttype != ABYSS and ttype != LAVA and ttype != RUNEBRICKS)
                elseif .Team.DefaultGameMode == Teams_GAMEMODE_PLATFORMING then
                    exitwhen (ttype != LAVA and ttype != LRGBRICKS and ttype != RUNEBRICKS and TerrainGlobals_IsTerrainPathable(ttype))
                endif				
            endloop
			
			//call DisplayTextToForce(bj_FORCE_PLAYER[0], "reviving at x: " + R2S(x) + ", y: " + R2S(y))
			// if this == 1 then
				// call DisplayTextToForce(bj_FORCE_PLAYER[0], "reviving at x: " + R2S(x) + ", y: " + R2S(y))
			// endif
			
            if .Team.DefaultGameMode == Teams_GAMEMODE_STANDARD or .Team.DefaultGameMode == Teams_GAMEMODE_STANDARD_PAUSED then
                call this.SwitchGameModes(Teams_GAMEMODE_STANDARD_PAUSED, x, y)
                
                if RespawnASAPMode then
                    call TimerStart(NewTimerEx(this), REVIVE_PAUSE_TIME_ASAP, false, function User.UnpauseUserCB)
                else
                    call TimerStart(NewTimerEx(this), REVIVE_PAUSE_TIME_NONASAP, false, function User.UnpauseUserCB)
                endif
            /*
            elseif .Team.DefaultGameMode == Teams_GAMEMODE_PLATFORMING then
                call this.SwitchGameModes(Teams_GAMEMODE_PLATFORMING_PAUSED, x, y)
                
                call TimerStart(NewTimerEx(this), REVIVE_PAUSE_TIME_PLATFORMING, false, function User.UnpauseUserCB)
            */
            else
                call this.SwitchGameModes(.Team.DefaultGameMode, x, y)
            endif
            
			/*
            if .Team.DefaultGameMode != Teams_GAMEMODE_DEAD and .Team.DefaultGameMode != Teams_GAMEMODE_DYING then
                set .IsAlive = true
            endif
			*/
        endif
        
		//it's least jarring to call apply default cameras only when it's extremely important
        call this.ApplyDefaultCameras()
		
		//call DisplayTextToForce(bj_FORCE_PLAYER[0], "respawn end for player " + I2S(this))
		// if this == 1 then
			// //call DisplayTextToForce(bj_FORCE_PLAYER[0], "Active Unit name after " + GetUnitName(.ActiveUnit))
			// call DisplayTextToForce(bj_FORCE_PLAYER[0], "Respawn check active x: " + R2S(GetUnitX(.ActiveUnit)) + ", y: " + R2S(GetUnitY(.ActiveUnit)))
			// call DisplayTextToForce(bj_FORCE_PLAYER[0], "respawn end for player " + I2S(this))
		// endif
		
        //set .LastTransferTime = GameElapsedTime()
    endmethod
    
    public method GetStylizedPlayerName takes nothing returns string
        local string hex
        
        if this.Team.TeamID == 0 then
            set hex = "|cFF00CC00"
        elseif this.Team.TeamID == 1 then
            set hex = "|cFF0000FF"
        elseif this.Team.TeamID == 2 then
            set hex = "|cFF00FFCC"
        elseif this.Team.TeamID == 3 then
            set hex = "|cFFFF66CC"
        elseif this.Team.TeamID == 4 then
            set hex = "|cFFFFFF66"
        elseif this.Team.TeamID == 5 then
            set hex = "|cFFFF9933"
        elseif this.Team.TeamID == 6 then
            set hex = "|cFFFF0000"
        elseif this.Team.TeamID == 7 then
            set hex = "|cFFFF66CC"
        else
            set hex = ""
        endif
        
        if GetPlayerSlotState(Player(this)) == PLAYER_SLOT_STATE_PLAYING then
            return hex + GetPlayerName(Player(this)) + "|r"
        else
            return hex + "Gone" + "|r"
        endif
    endmethod
    
    public method PartialUpdateMultiboard takes nothing returns nothing
        if GetPlayerSlotState(Player(this)) == PLAYER_SLOT_STATE_PLAYING then                
            call MultiboardSetItemValue(MultiboardGetItem(.Team.PlayerStats, this + 1, 2), I2S(.Team.Score))
            call MultiboardSetItemValue(MultiboardGetItem(.Team.PlayerStats, this + 1, 3), I2S(.Team.ContinueCount))
            call MultiboardSetItemValue(MultiboardGetItem(.Team.PlayerStats, this + 1, 4), I2S(.Deaths))
            
            call MultiboardReleaseItem(MultiboardGetItem(.Team.PlayerStats, this + 1, 2))
            call MultiboardReleaseItem(MultiboardGetItem(.Team.PlayerStats, this + 1, 3))
            call MultiboardReleaseItem(MultiboardGetItem(.Team.PlayerStats, this + 1, 4))
        elseif GetPlayerSlotState(Player(this)) == PLAYER_SLOT_STATE_LEFT then
            call MultiboardSetItemValue(MultiboardGetItem(.Team.PlayerStats, this + 1, 0), "Left the game")
            call MultiboardSetItemValue(MultiboardGetItem(.Team.PlayerStats, this + 1, 1), "Gone")
            call MultiboardSetItemValue(MultiboardGetItem(.Team.PlayerStats, this + 1, 2), "Negative")
            call MultiboardSetItemValue(MultiboardGetItem(.Team.PlayerStats, this + 1, 3), "Zilch")
            call MultiboardSetItemValue(MultiboardGetItem(.Team.PlayerStats, this + 1, 4), "Too many")
            
            call MultiboardReleaseItem(MultiboardGetItem(.Team.PlayerStats, this + 1, 0))
            call MultiboardReleaseItem(MultiboardGetItem(.Team.PlayerStats, this + 1, 1))
            call MultiboardReleaseItem(MultiboardGetItem(.Team.PlayerStats, this + 1, 2))
            call MultiboardReleaseItem(MultiboardGetItem(.Team.PlayerStats, this + 1, 3))
            call MultiboardReleaseItem(MultiboardGetItem(.Team.PlayerStats, this + 1, 4))
        else
            call MultiboardSetItemValue(MultiboardGetItem(.Team.PlayerStats, this + 1, 0), "Not playing")
            call MultiboardReleaseItem(MultiboardGetItem(.Team.PlayerStats, this + 1, 0))
        endif
    endmethod
    
    //set game mode should take all players, dead or alive, and make it so the next time they are respawned (naturally or forced) it will be as the correct unit type with all the correct mechanisms enabled
    
    //initial x, y coordinate will either resume from previous location in last gamemode or from revive
    public method SwitchGameModesDefaultLocation takes integer newGameMode returns nothing
        local real x
        local real y
        
        local integer ttype
        
        if .GameMode == Teams_GAMEMODE_DEAD then
            loop
                set x = GetRandomReal(GetRectMinX(.Team.Revive), GetRectMaxX(.Team.Revive))
                set y = GetRandomReal(GetRectMinY(.Team.Revive), GetRectMaxY(.Team.Revive))
                //check these values to see if they're on abyss, redo if so
                set ttype = GetTerrainType(x, y)
                
                if newGameMode == Teams_GAMEMODE_STANDARD or newGameMode == Teams_GAMEMODE_STANDARD_PAUSED then
                    exitwhen (ttype != ABYSS and ttype != LAVA and ttype != LRGBRICKS and ttype != RUNEBRICKS)
                elseif newGameMode == Teams_GAMEMODE_PLATFORMING or newGameMode == Teams_GAMEMODE_PLATFORMING_PAUSED then
                    exitwhen (ttype != LAVA and ttype != LRGBRICKS and TerrainGlobals_IsTerrainPathable(ttype))
                else
                    debug call DisplayTextToPlayer(Player(0), 0, 0, "Switching from dead gamemode to invalid new gamemode: " + I2S(newGameMode))
                endif
            endloop
        else
            set x = GetUnitX(.ActiveUnit)
            set y = GetUnitY(.ActiveUnit)
        endif
        
        call SwitchGameModes(newGameMode, x, y)
    endmethod
    
    private method ApplyDeathMode takes real x, real y, real facing, integer oldGameMode returns nothing
        local vector2 respawnPoint
                
        //disable camera tracking if that player has it enabled
        call ResetDefaultCamera()
        
        //check if respawn circles should be used
        if not RespawnASAPMode then
            //figure out the coordinates for respawn point given the previous game mode and other info
            set respawnPoint = TerrainHelpers_TryGetLastValidLocation(x, y, facing, oldGameMode)
            
            //move respawn circle to point
            call SetUnitPosition(PlayerReviveCircles[this], respawnPoint.x, respawnPoint.y)
            call ShowUnit(PlayerReviveCircles[this], true)
            
            call respawnPoint.destroy()
        endif
    endmethod
    
    private static method ApplyRootsCB takes nothing returns nothing
        local timer t = GetExpiredTimer()
        local thistype user = GetTimerData(t)
        
        //call DummyCaster['A003'].castTarget(Player(10), 1, OrderId("entanglingroots"), user.ActiveUnit)
        call DummyCaster['A003'].castTarget(Player(user), 1, OrderId("entanglingroots"), user.ActiveUnit)
        
        call ReleaseTimer(t)
        set t = null
    endmethod
    
    public method SwitchGameModes takes integer newGameMode, real x, real y returns nothing
        local integer curGameMode = .GameMode
        local real facing
        
        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Removing " + I2S(oldGameMode) + ", Adding " + I2S(newGameMode))
        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Adding " + I2S(newGameMode))
        
        if newGameMode != curGameMode then
            //if the new gamemode is death then we might need to keep a few things in memory
            if newGameMode == Teams_GAMEMODE_DEAD then
                if not RespawnASAPMode then
                    set facing = GetUnitFacing(.ActiveUnit)
                endif
            endif
			
			// if this == 1 then
				// call DisplayTextToForce(bj_FORCE_PLAYER[0], "Changing gamemode from: " + I2S(curGameMode) + ", to: " + R2S(newGameMode))
			// endif
            
            //remove the old game mode
            if curGameMode == Teams_GAMEMODE_STANDARD then
                //moves the mazing unit
                call SetUnitPosition(MazersArray[this], MazerGlobals_SAFE_X, MazerGlobals_SAFE_Y)
                //removes the reg unit from the reg game loop. thereby enabling regular terrain effects
                call GroupRemoveUnit(MazersGroup, MazersArray[this])
                //remove the current terrain effect
                call GameLoopRemoveTerrainAction(MazersArray[this], this, PreviousTerrainTypedx[this], NOEFFECT)
                set PreviousTerrainTypedx[this] = NOEFFECT
                //updates the number of units platforming/regular mazing
                set NumberMazing = NumberMazing - 1
                
                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Number mazing removing standard: " + I2S(NumberMazing))
                //hides the DH
                call ShowUnit(MazersArray[this], false)
            elseif curGameMode == Teams_GAMEMODE_PLATFORMING then
                call .Platformer.StopPlatforming()
            elseif curGameMode == Teams_GAMEMODE_STANDARD_PAUSED then
                //restore default movespeed regardless
                call SetUnitMoveSpeed(MazersArray[this], DefaultMoveSpeed)
                
                //remove entangling roots on the paused mazer
				/*
				if .ActiveEffect != null then
					call DestroyEffect(.ActiveEffect)
					set .ActiveEffect = null
				endif
				*/
				call .ClearActiveEffect()
				
                //call UnitRemoveBuffs(.ActiveUnit, true, true)
                call DummyCaster['A004'].castTarget(Player(10), 1, OrderId("dispel"), .ActiveUnit)
				call SetUnitPropWindow(.ActiveUnit, GetUnitDefaultPropWindow(.ActiveUnit))
                
                //if the new gamemode isnt to unpause the unit then we need to undo the pause effect
                if newGameMode != Teams_GAMEMODE_STANDARD then
                    call SetUnitPosition(MazersArray[this], MazerGlobals_SAFE_X, MazerGlobals_SAFE_Y)
                    call ShowUnit(MazersArray[this], false)
                endif
            elseif curGameMode == Teams_GAMEMODE_PLATFORMING_PAUSED then
                //if the new gamemode isnt to unpause the unit then we need to undo the pause effect
                if newGameMode != Teams_GAMEMODE_PLATFORMING then
                    call SetUnitPosition(.Platformer.Unit, PlatformerGlobals_SAFE_X, PlatformerGlobals_SAFE_Y)
                    call ShowUnit(.Platformer.Unit, false)
                endif
            elseif curGameMode == Teams_GAMEMODE_DYING then
				//no actions removing dying gamemode
            elseif curGameMode == Teams_GAMEMODE_DEAD then
                //revive the mazing unit
                call ReviveHero(MazersArray[this], MazerGlobals_SAFE_X, MazerGlobals_SAFE_Y, false)
                call ShowUnit(MazersArray[this], false)
                call IssueImmediateOrder(MazersArray[this], "stop")
                //call PauseUnit(MazersArray[this], true)
                //call PauseUnit(MazersArray[this], false)
                
                //move the respawn circle
                call SetUnitPosition(PlayerReviveCircles[this], MazerGlobals_REVIVE_CIRCLE_SAFE_X, MazerGlobals_REVIVE_CIRCLE_SAFE_Y)
                call ShowUnit(PlayerReviveCircles[this], false)
            endif
            
            //set the new game mode
            //note this does not do anything (include store the gamemode) if new game mode is same as old
            call this.SetCurrentGameMode(newGameMode)
            
            //apply the new game mode
            if newGameMode == Teams_GAMEMODE_STANDARD then
                set PreviousTerrainTypedx[this] = PLATFORMING
                //moves the mazing unit
				call SetUnitPosition(MazersArray[this], x, y)
                //adds the reg unit from the reg game loop. thereby enabling regular terrain effects
                call GroupAddUnit(MazersGroup, MazersArray[this])
                //updates the number of units platforming/regular mazing
                set NumberMazing = NumberMazing + 1
                
                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Number mazing applying standard: " + I2S(NumberMazing))
                
                //unhides the wisp and hides the DH
                call ShowUnit(MazersArray[this], true)
                //pause/unpause the unit to clear order stack
                call PauseUnit(MazersArray[this], true)
                call PauseUnit(MazersArray[this], false)
				
				//always select the mazing unit when switching to STANDARD mode
				call .ApplyDefaultSelections()
            elseif newGameMode == Teams_GAMEMODE_PLATFORMING then
                call Platformer.StartPlatforming(x, y)
            elseif newGameMode == Teams_GAMEMODE_STANDARD_PAUSED then
                call SetUnitPosition(MazersArray[this], x, y)
                //set movespeed 0 instead of pausing unit so player can pivot to face a better direction
                //call SetUnitMoveSpeed(MazersArray[this], 0)
                call ShowUnit(MazersArray[this], true)
				
                //cast entangling roots on the paused mazer
                //call DummyCaster['A003'].castTarget(Player(10), 1, 'AEer', .ActiveUnit)
                //call DummyCaster['A003'].castTarget(Player(10), 1, OrderId("entanglingroots"), .ActiveUnit)
                //call DummyCaster['A003'].castTarget(Player(this), 1, OrderId("entanglingroots"), .ActiveUnit)
                //call DummyCaster['A005'].castTarget(Player(this), 1, OrderId("web"), .ActiveUnit)
                //call TimerStart(NewTimerEx(this), 0.00001, false, function thistype.ApplyRootsCB)
				//call DummyCaster['A007'].castTarget(Player(this), 1, OrderId("slow"), .ActiveUnit)
				
				//TODO this is very inconsistent with whether or not it shows at all (though at least it does show...) ...maybe just manually create and destroy a special effect
				//call DummyCaster['A007'].castTarget(Player(10), 1, OrderId("slow"), .ActiveUnit)
				/*
				if .ActiveEffect != null then
					call DestroyEffect(.ActiveEffect)
					set .ActiveEffect = null
				endif
				set .ActiveEffect = AddSpecialEffectTarget("Abilities\\Spells\\NightElf\\EntanglingRoots\\EntanglingRootsTarget.mdl", .ActiveUnit, "origin")
				*/
				call .SetActiveEffect("Abilities\\Spells\\NightElf\\EntanglingRoots\\EntanglingRootsTarget.mdl", "origin")
				
				call SetUnitPropWindow(.ActiveUnit, 0)
				
				//always select the mazing unit when switching to STANDARD_PAUSED mode
				call .ApplyDefaultSelections()
                //call UnitApplyTimedLife(.ActiveUnit, 'BEer', 10.)
				
                //resets the game camera and selects the mazing unit
                //call SetDefaultCameraForPlayer(this, .5)
            elseif newGameMode == Teams_GAMEMODE_PLATFORMING_PAUSED then
                set .Platformer.XPosition = x
                set .Platformer.YPosition = y
                call SetUnitPosition(.Platformer.Unit, x, y)
                call ShowUnit(.Platformer.Unit, true)
                
                call .Platformer.ApplyCamera()
            elseif newGameMode == Teams_GAMEMODE_DYING then
                //kill their standard mazer in front of their eyes
                //DO THIS LAST SO IT HURTS MORE. jk, its BC IT IMMEDIATELY SETS OFF ON DEATH EVENT AND PRE-EMPTS THE REST OF THIS FUNC
				call SetUnitPosition(MazersArray[this], x, y)
                call ShowUnit(MazersArray[this], true)
                call KillUnit(MazersArray[this])
            elseif newGameMode == Teams_GAMEMODE_DEAD then
                call ApplyDeathMode(x, y, facing, .PreviousGameMode)
            endif
        else
            //same gamemode, but may still need to move unit
            if newGameMode == Teams_GAMEMODE_STANDARD or newGameMode == Teams_GAMEMODE_STANDARD_PAUSED then
                //moves the mazing unit
                call SetUnitPosition(MazersArray[this], x, y)
            elseif newGameMode == Teams_GAMEMODE_PLATFORMING or newGameMode == Teams_GAMEMODE_PLATFORMING_PAUSED then
                //call .Platformer.StartPlatforming(x, y)
                call .Platformer.StopPlatforming()
                call .Platformer.StartPlatforming(x, y)
                
                /*
                set .Platformer.XPosition = x
                set .Platformer.YPosition = y
                set .Platformer.XVelocity = 0
                set .Platformer.YVelocity = 0
                call SetUnitPosition(.Platformer.Unit, x, y)
                */
            endif
        endif
		
		// if this == 1 then
			// call DisplayTextToForce(bj_FORCE_PLAYER[0], "Moved to x: " + R2S(x) + ", y: " + R2S(y))
			// call DisplayTextToForce(bj_FORCE_PLAYER[0], "Check active x: " + R2S(GetUnitX(.ActiveUnit)) + ", y: " + R2S(GetUnitY(.ActiveUnit)))
		// endif
    endmethod
    
    private method SetCurrentGameMode takes integer newGameMode returns nothing
        if newGameMode != .GameMode then
            if .GameMode != Teams_GAMEMODE_DYING then
                set .PreviousGameMode = .GameMode
            endif
            
            set .GameMode = newGameMode
            
			if newGameMode != Teams_GAMEMODE_DEAD and newGameMode != Teams_GAMEMODE_DYING then
				set .IsAlive = true
			endif
			
            if newGameMode == Teams_GAMEMODE_STANDARD or newGameMode == Teams_GAMEMODE_STANDARD_PAUSED then
                set .ActiveUnit = MazersArray[this]
            elseif newGameMode == Teams_GAMEMODE_PLATFORMING or newGameMode == Teams_GAMEMODE_PLATFORMING_PAUSED then
                set .ActiveUnit = .Platformer.Unit
            elseif newGameMode == Teams_GAMEMODE_DEAD then
                //this may be problematic
                if RespawnASAPMode then
                    set .ActiveUnit = null
                else
                    set .ActiveUnit = PlayerReviveCircles[this]
                endif
            endif
        endif
    endmethod
    
    public method IsActiveUnitInRect takes rect r returns boolean
        return GetUnitX(.ActiveUnit) >= GetRectMinX(r) and GetUnitX(.ActiveUnit) <= GetRectMaxX(r) and GetUnitY(.ActiveUnit) >= GetRectMinY(r) and GetUnitY(.ActiveUnit) <= GetRectMaxY(r)
    endmethod
    public method IsActiveUnitInArea takes vector2 topLeft, vector2 botRight returns boolean
        return GetUnitX(.ActiveUnit) >= topLeft.x and GetUnitX(.ActiveUnit) <= botRight.x and GetUnitY(.ActiveUnit) >= botRight.y and GetUnitY(.ActiveUnit) <= topLeft.y
    endmethod
    
    //TODO get rid of PlayerID field entirely
    public static method GetUserFromPlayerID takes integer playerID returns User
        return User(playerID)
    endmethod
    
    static method allocate takes nothing returns thistype
        set .count = .count + 1
        return .count
    endmethod
        
    public static method create takes nothing returns thistype
        local thistype new 
        
        set new = thistype.allocate()
        
        //debug call DisplayTextToPlayer(Player(0), 0, 0, "Creating User: " + I2S(new))
        
        //set new.PlayerID = new
        set new.Team = 0
        set new.Deaths = 0
        set new.IsPlaying = GetPlayerSlotState(Player(new))==PLAYER_SLOT_STATE_PLAYING
        set new.IsAlive = true
        
        set new.CinematicPlaying = 0
        set new.CinematicQueue = SimpleList_List.create()
        
        set new.GameMode = Teams_GAMEMODE_STANDARD //regular mazing
        //FOR SOME REASON THIS IS RETURNING NULL, SO WE NEED TO SET ACTIVE UNIT AFTER MAP INIT
        //set new.ActiveUnit = MazersArray[new]
                    
        //set new.Platformer = Platformer.AllPlatformers[new]
        set new.Platformer = Platformer.create(new)
		
        if new.IsPlaying then
            set User.ActivePlayers = User.ActivePlayers + 1
        endif
        
        return new
    endmethod

    public static method onInit takes nothing returns nothing
        local integer n = 0
        set User.ActivePlayers = 0
        
        loop
        exitwhen n>=8
            //debug call DisplayTextToPlayer(Player(0), 0, 0, "Creating User: " + I2S(n))
            
            //if GetPlayerSlotState(Player(n))==PLAYER_SLOT_STATE_PLAYING then
                if GetPlayerController(Player(n))==MAP_CONTROL_USER then
                    call User.create()
                endif
            //endif
        set n=n+1
        endloop       
        
        //register user cinematic CB
        //call DisplayTextToPlayer(Player(0), 0, 0, "Trying to register user cinematic CB")
        //call Cinematic.OnCinemaEnd.register(Condition(function thistype.OnCinemaEndCB))
        //call DisplayTextToPlayer(Player(0), 0, 0, "Registered user cinematic CB")
    endmethod
endstruct

endlibrary