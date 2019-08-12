library User requires UnitDefaultRadius, MazerGlobals, Platformer, TerrainHelpers, Cinema

globals
	User TriggerUser //used with events
	
	private constant boolean DEBUG_AFK = false
	private constant real CAMERA_TARGET_POSITION_FLEX = 50.
	
	private constant real CAMERA_TARGET_POSITION_PAUSE_X_FLEX = 8.5 * TERRAIN_TILE_SIZE
	private constant real CAMERA_TARGET_POSITION_PAUSE_Y_FLEX = 5.5 * TERRAIN_TILE_SIZE
	private constant real CAMERA_TARGET_POSITION_PAUSE_Y_TOP_FLEX = CAMERA_TARGET_POSITION_PAUSE_Y_FLEX + 1.
	private constant real CAMERA_TARGET_POSITION_PAUSE_Y_BOTTOM_FLEX = CAMERA_TARGET_POSITION_PAUSE_Y_FLEX - 1.
	
	private constant real AFK_CAMERA_CHECK_TIMEOUT = 1.
	private constant real AFK_CAMERA_DEBUG_TIMEOUT = 5.
	private constant real AFK_CAMERA_MAX_TIMEOUT = 120.
	private constant real AFK_CAMERA_MIN_TIMEOUT = 15.
	private constant real AFK_CAMERA_DELTA_TIMEOUT = .75
	
	private constant real AFK_PAN_CAMERA_DURATION = 2.
	private constant real AFK_UNPAUSE_BUFFER = 3.
	
	private constant real AFK_MANUAL_CHECK_FACTOR = .75
	private constant string AFK_SYNC_EVENT_PREFIX = "AFK"
	
	private constant real AFK_PLATFORMER_CLOCK = .5
	private constant real AFK_PLATFORMER_DEATH_CLOCK_START = 5.
	
	private constant real SMALL_FONT_SIZE = 0.024
	
	public constant string LOCAL_CAMERA_IDLE_TIME_EVENT_PREFIX = "CAM"
	
	private constant boolean DEBUG_GAMEMODE_CHANGE = false
	private constant boolean DEBUG_ACTIVE_EFFECT_CHANGE = false
	private constant boolean DEBUG_CAMERA = false
endglobals

struct User extends array
    public boolean IsPlaying
    public boolean IsAlive
	readonly boolean IsAFK
    public integer Deaths
    public unit ActiveUnit
	public real ActiveUnitRadius
    public Platformer Platformer
    public integer GameMode //0: regular DH mazing, 1: wisp platforming, 9: mini-games?
    public integer PreviousGameMode //only standard or platforming
    public Teams_MazingTeam Team
    public CinemaCallbackModel CinematicPlaying
    public SimpleList_List CinematicQueue //FiFo
	public effect ActiveEffect
	private timer UnpauseTimer
	   
	// public real CameraIdleTime //only as accurate as the last sync
	readonly real AFKPlatformerDeathClock
	
    public static integer ActivePlayers
	
	// private static trigger AFKLocalCameraTimeSyncEvent
	// private static SimpleList_List AFKSyncLocalCameraTimePromises
	
	private static trigger AFKSyncEvent
	readonly static vector2 LocalCameraTargetPosition
	private static real LocalCameraIdleTime
	private static real LocalAFKThreshold
	private boolean PlatformerStartStable
	// public static trigger AFKMouseEvent
	// public static vector2 LocalUserMousePosition
	
	private static Cinematic ToggleCameraTrackingTutorial
		    
    //MOST IMPORTANT that "this" returns the exact player ID without having to remember to add / subtract 1
    //also no need to recycle users, let's just keep a basic count
    private static integer count = -1
    
	public method SetActiveEffect takes string strEffect, string attachPoint returns nothing
		if .ActiveEffect != null then
			static if DEBUG_ACTIVE_EFFECT_CHANGE then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Destroying active effect: " + I2S(GetHandleId(.ActiveEffect)))
			endif
			
			call DestroyEffect(.ActiveEffect)
			set .ActiveEffect = null
		endif
		
		if strEffect != null then
			set .ActiveEffect = AddSpecialEffectTarget(strEffect, .ActiveUnit, attachPoint)
			
			static if DEBUG_ACTIVE_EFFECT_CHANGE then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Set active effect: " + I2S(GetHandleId(.ActiveEffect)))
			endif
		endif
	endmethod
	public method SetActiveEffectEx takes effect fx returns nothing
		if .ActiveEffect != null then
			static if DEBUG_ACTIVE_EFFECT_CHANGE then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Destroying active effect: " + I2S(GetHandleId(.ActiveEffect)))
			endif
			
			call DestroyEffect(.ActiveEffect)
		endif
		
		set .ActiveEffect = fx
		
		static if DEBUG_ACTIVE_EFFECT_CHANGE then
			if fx != null then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Set active effect: " + I2S(GetHandleId(.ActiveEffect)))
			else
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Set active null: " + I2S(GetHandleId(.ActiveEffect)))
			endif
		endif
	endmethod
	public method ClearActiveEffect takes nothing returns nothing
		call .SetActiveEffect(null, null)
	endmethod
	
	public method CreateUserTimedEffect takes string fxFileLocation, string attachPointName, real duration returns nothing
		call UserActiveTimedEffect.create(fxFileLocation, attachPointName, this, duration)
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
        set EventUser.CinematicPlaying = 0
        call EventUser.CheckCinematicQueue()
		
        return false
    endmethod
	public method ShortcutCinematicQueue takes Cinematic cine returns nothing
		call .CinematicQueue.add(cine)
		
		//remove currently playing cinematic
		if .CinematicPlaying != 0 then
			call .CinematicPlaying.EndCallbackStack()
		else
			call .CheckCinematicQueue()
		endif
	endmethod
    public method AddCinematicToQueue takes Cinematic cine returns nothing
        local integer priorityIndex = 0
		local SimpleList_ListNode curCinematicNode = .CinematicQueue.first
		
		if .CinematicPlaying == 0 then
			call .CinematicQueue.add(cine)
			call .CheckCinematicQueue()
		else
			// call DisplayTextToPlayer(Player(0), 0, 0, "Cinematic priority difference: " + I2S(cine.Priority - .CinematicPlaying.Cinematic.Priority))
			
			if cine.Priority - .CinematicPlaying.Cinematic.Priority >= 2 then
				call ShortcutCinematicQueue(cine)
			else
				//iterate list until we find the position in user's queue to place the cinema (comparing priorities)
				loop
				exitwhen curCinematicNode == 0 or Cinematic(curCinematicNode.value).Priority < cine.Priority
				
				set curCinematicNode = curCinematicNode.next
				set priorityIndex = priorityIndex + 1
				endloop
				
				//add the new cinema at the priority sorted index. no need to check queue as already established its non null
				call .CinematicQueue.insert(cine, priorityIndex)
			endif
		endif        
    endmethod
    public method CheckCinematicQueue takes nothing returns nothing
        //call DisplayTextToForce(bj_FORCE_PLAYER[0], "Checking cinema queue for user:" + I2S(this))
        //debug call .CinematicQueue.print(this)
        
        if .CinematicPlaying == 0 and .CinematicQueue.count > 0 then
            //call DisplayTextToForce(bj_FORCE_PLAYER[0], "popping next cinematic for user: " + I2S(this))
            
            set .CinematicPlaying = Cinematic(.CinematicQueue.pop().value).Activate(this)
            // call .CinematicPlaying.Activate(this)
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
		
		call .SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)

        //TODO cleanup any structs
        
        //call thistype.DisplayMessageAll(GetPlayerName(Player(this)) + " has left the game!")
        call thistype.DisplayMessageAll(this.GetStylizedPlayerName() + " has left the game!")
        
        set .ActiveUnit = null
        
        set User.ActivePlayers = User.ActivePlayers - 1
    endmethod
    
    
    public method ReviveActiveHero takes real x, real y returns nothing
        if .GameMode == Teams_GAMEMODE_STANDARD then
            call ReviveHero(MazersArray[this], x, y, true)
            call PauseUnit(MazersArray[this], true)
			call PauseUnit(MazersArray[this], false)
            call SetUnitX(MazersArray[this], x)
            call SetUnitY(MazersArray[this], y)
        elseif .GameMode == Teams_GAMEMODE_PLATFORMING then
            call Platformer.StartPlatforming(x, y)
        endif
    endmethod
    
	public method ToggleDefaultTracking takes nothing returns nothing
        set DefaultCameraTracking[this] = not DefaultCameraTracking[this]
		
		if .GameMode == Teams_GAMEMODE_STANDARD or .GameMode == Teams_GAMEMODE_STANDARD_PAUSED then
			if GetLocalPlayer() == Player(this) then
				if DefaultCameraTracking[this] then
					//enable
					call SetCameraTargetController(MazersArray[this], 0, 0, false)
					
					// if .CinematicPlaying.Cinematic != thistype.ToggleCameraTrackingTutorial or thistype.ToggleCameraTrackingTutorial == 0 then
						// call .DisplayMessage("Camera tracking: " + ColorMessage("ON", TOGGLE_ON_COLOR), 1.)
					// endif
					call .DisplayMessage("Camera tracking: " + ColorMessage("ON", TOGGLE_ON_COLOR), 1.)
				else
					//disable
					call ResetToGameCamera(0)
					call CameraSetupApply(DefaultCamera[this], false, false)
					
					// if .CinematicPlaying.Cinematic != thistype.ToggleCameraTrackingTutorial or thistype.ToggleCameraTrackingTutorial == 0 then
						// call .DisplayMessage("Camera tracking: " + ColorMessage("OFF", TOGGLE_OFF_COLOR), 1.)
					// endif
					call .DisplayMessage("Camera tracking: " + ColorMessage("OFF", TOGGLE_OFF_COLOR), 1.)
				endif
			endif
			
			if thistype.ToggleCameraTrackingTutorial != 0 then
				if DefaultCameraTracking[this] and not thistype.ToggleCameraTrackingTutorial.HasUserViewed(this) then
					call this.ShortcutCinematicQueue(thistype.ToggleCameraTrackingTutorial)
				endif
			endif
		endif
    endmethod
    public method ApplyDefaultCameras takes real time returns nothing
        static if DEBUG_CAMERA then
			if GetLocalPlayer() == Player(0) then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Before apply, camera destination x: " + R2S(GetCameraTargetPositionX()) + ", y: " + R2S(GetCameraTargetPositionY()))
			endif
		endif
		
		if .GameMode == Teams_GAMEMODE_PLATFORMING or .GameMode == Teams_GAMEMODE_PLATFORMING_PAUSED then
            call .Platformer.ApplyCamera()
        elseif .GameMode == Teams_GAMEMODE_STANDARD or .GameMode == Teams_GAMEMODE_STANDARD_PAUSED then
            if GetLocalPlayer() == Player(this) then
                call CameraSetupApply(DefaultCamera[this], false, false)
                if .IsAFK then
					call SetCameraPosition(GetUnitX(.ActiveUnit), GetUnitY(.ActiveUnit))
					
					//these don't return the updated value until a timeout of 0 for some reason
					// set thistype.LocalCameraTargetPosition.x = GetCameraTargetPositionX()
					// set thistype.LocalCameraTargetPosition.y = GetCameraTargetPositionY()
					set thistype.LocalCameraTargetPosition.x = GetUnitX(.ActiveUnit)
					set thistype.LocalCameraTargetPosition.y = GetUnitY(.ActiveUnit)
				else
					call PanCameraToTimed(GetUnitX(.ActiveUnit), GetUnitY(.ActiveUnit), time)
				endif
				
                if DefaultCameraTracking[this] then
                    call SetCameraTargetController(.ActiveUnit, 0, 0, false)
                endif				
            endif
        endif
		
		static if DEBUG_CAMERA then
			if GetLocalPlayer() == Player(0) then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "After apply, camera destination x: " + R2S(GetCameraTargetPositionX()) + ", y: " + R2S(GetCameraTargetPositionY()))
			endif
		endif
    endmethod
	public method ResetDefaultCamera takes real duration returns nothing
        static if DEBUG_CAMERA then
			if GetLocalPlayer() == Player(0) then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Before reset, camera destination x: " + R2S(GetCameraTargetPositionX()) + ", y: " + R2S(GetCameraTargetPositionY()))
			endif
		endif
		
		if (GetLocalPlayer() == Player(this)) then
            call ResetToGameCamera(duration)
			if duration > 0 then
				call CameraSetupApply(DefaultCamera[this], false, false)
			else
				call CameraSetupApply(DefaultCamera[this], false, false)
			endif
        endif
		
		static if DEBUG_CAMERA then
			if GetLocalPlayer() == Player(0) then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "After reset, camera destination x: " + R2S(GetCameraTargetPositionX()) + ", y: " + R2S(GetCameraTargetPositionY()))
			endif
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
    
    public method Pause takes boolean flag returns nothing
        if .IsPlaying and .IsAlive then
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "unpausing " + I2S(u))
            //call PauseUnit(.ActiveUnit, flag)
            if flag then
                if .GameMode == Teams_GAMEMODE_STANDARD then
					call PauseUnit(MazersArray[this], true)
					call PauseUnit(MazersArray[this], false)
					call IssueImmediateOrder(.ActiveUnit, "stop")
					
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
    
	public method CancelAutoUnpause takes nothing returns nothing
		if this.UnpauseTimer != null then
			call ReleaseTimer(this.UnpauseTimer)
			set this.UnpauseTimer = null
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
		
		static if DEBUG_MODE then
			if t != u.UnpauseTimer then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Unpause User CB with unidentified timer")
			endif
		endif
        
        call ReleaseTimer(t)
        set t = null
		set u.UnpauseTimer = null
    endmethod
	public method RegisterAutoUnpause takes real timeout returns nothing
		call .CancelAutoUnpause()
		set .UnpauseTimer = NewTimerEx(this)
		call TimerStart(.UnpauseTimer, timeout, false, function thistype.UnpauseUserCB)
	endmethod
	public method GetAutoUnpauseRemainingTime takes nothing returns real
		if .UnpauseTimer != null then
			return TimerGetRemaining(.UnpauseTimer)
		else
			return -1.
		endif
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
                    exitwhen (ttype != ABYSS and ttype != LAVA)
                elseif .Team.DefaultGameMode == Teams_GAMEMODE_PLATFORMING then
                    exitwhen (ttype != LAVA and ttype != LRGBRICKS and TerrainGlobals_IsTerrainPathable(ttype))
                endif				
            endloop
			
			//call DisplayTextToForce(bj_FORCE_PLAYER[0], "reviving at x: " + R2S(x) + ", y: " + R2S(y))
			// if this == 1 then
				// call DisplayTextToForce(bj_FORCE_PLAYER[0], "reviving at x: " + R2S(x) + ", y: " + R2S(y))
			// endif
			
            if .Team.DefaultGameMode == Teams_GAMEMODE_STANDARD or .Team.DefaultGameMode == Teams_GAMEMODE_STANDARD_PAUSED then			
				call this.SwitchGameModes(Teams_GAMEMODE_STANDARD_PAUSED, x, y)
                
				call .RegisterAutoUnpause(RespawnPauseTime)
			elseif .Team.DefaultGameMode == Teams_GAMEMODE_PLATFORMING_PAUSED then
				call this.SwitchGameModes(Teams_GAMEMODE_PLATFORMING_PAUSED, x, y)
				
				call .RegisterAutoUnpause(RespawnPauseTime)
            /*
            elseif .Team.DefaultGameMode == Teams_GAMEMODE_PLATFORMING then
				call this.SwitchGameModes(Teams_GAMEMODE_PLATFORMING_PAUSED, x, y)
                
                call .RegisterAutoUnpause(RespawnPauseTime)
            */
            else
                call this.SwitchGameModes(.Team.DefaultGameMode, x, y)
            endif            
        endif
        
		//it's least jarring to call apply default cameras only when it's extremely important
        call this.ApplyDefaultCameras(0.0)
		
		//call DisplayTextToForce(bj_FORCE_PLAYER[0], "respawn end for player " + I2S(this))
		// if this == 1 then
			// //call DisplayTextToForce(bj_FORCE_PLAYER[0], "Active Unit name after " + GetUnitName(.ActiveUnit))
			// call DisplayTextToForce(bj_FORCE_PLAYER[0], "Respawn check active x: " + R2S(GetUnitX(.ActiveUnit)) + ", y: " + R2S(GetUnitY(.ActiveUnit)))
			// call DisplayTextToForce(bj_FORCE_PLAYER[0], "respawn end for player " + I2S(this))
		// endif
		
        //set .LastTransferTime = GameElapsedTime()
    endmethod
	
	public method SetKeyColor takes integer keyColor returns nothing
		if MazerColor[this] != keyColor then
			set MazerColor[this] = keyColor
			
			if keyColor == KEY_RED then
				call SetUnitVertexColor(MazersArray[this], 255, 0, 0, 255)
			elseif keyColor == KEY_BLUE then
				call SetUnitVertexColor(MazersArray[this], 0, 0, 255, 255)
			elseif keyColor == KEY_GREEN then
				call SetUnitVertexColor(MazersArray[this], 0, 255, 0, 255)
			endif
		endif
	endmethod
	
	public method GetPlayerColorHex takes nothing returns string
		local string hex
        
        if this == 0 then
            set hex = "FF0303"
        elseif this == 1 then
            set hex = "0042ff"
        elseif this == 2 then
            set hex = "1ce6b9"
        elseif this == 3 then
            set hex = "540081"
        elseif this == 4 then
            set hex = "fffc01"
        elseif this == 5 then
            set hex = "feba0e"
        elseif this == 6 then
            set hex = "20c000"
        elseif this == 7 then
            set hex = "e55bb0"
        else
            set hex = ""
        endif
		
		return hex
	endmethod
	public method GetStylizedPlayerName takes nothing returns string
        local string hex = .GetPlayerColorHex()
        
        if GetPlayerSlotState(Player(this)) == PLAYER_SLOT_STATE_PLAYING then
			if .IsAFK then
				return ColorMessage("(AFK) ", DISABLED_COLOR) + ColorMessage(GetPlayerName(Player(this)), hex)
			else
				return ColorMessage(GetPlayerName(Player(this)), hex)
			endif
        else
			return ColorMessage("(Left) " + GetPlayerName(Player(this)), hex)
        endif
    endmethod
    
    public method PartialUpdateMultiboard takes nothing returns nothing
        if GetPlayerSlotState(Player(this)) == PLAYER_SLOT_STATE_PLAYING then                
            call MultiboardSetItemValue(MultiboardGetItem(.Team.PlayerStats, this + 1, 0), .Team.GetStylizedPlayerName(this))
			call MultiboardSetItemValue(MultiboardGetItem(.Team.PlayerStats, this + 1, 2), I2S(.Team.GetScore()))
            call MultiboardSetItemValue(MultiboardGetItem(.Team.PlayerStats, this + 1, 3), I2S(.Team.GetContinueCount()))
            
            call MultiboardReleaseItem(MultiboardGetItem(.Team.PlayerStats, this + 1, 0))
			call MultiboardReleaseItem(MultiboardGetItem(.Team.PlayerStats, this + 1, 2))
            call MultiboardReleaseItem(MultiboardGetItem(.Team.PlayerStats, this + 1, 3))
            
			if RewardMode == GameModesGlobals_HARD then
				call MultiboardSetItemValue(MultiboardGetItem(.Team.PlayerStats, this + 1, 4), I2S(.Deaths))
				call MultiboardReleaseItem(MultiboardGetItem(.Team.PlayerStats, this + 1, 4))
            endif
        elseif GetPlayerSlotState(Player(this)) == PLAYER_SLOT_STATE_LEFT then
            call MultiboardSetItemValue(MultiboardGetItem(.Team.PlayerStats, this + 1, 0), "Left the game")
            call MultiboardSetItemValue(MultiboardGetItem(.Team.PlayerStats, this + 1, 1), "Gone")
            call MultiboardSetItemValue(MultiboardGetItem(.Team.PlayerStats, this + 1, 2), "Negative")
            call MultiboardSetItemValue(MultiboardGetItem(.Team.PlayerStats, this + 1, 3), "Zilch")
            
            call MultiboardReleaseItem(MultiboardGetItem(.Team.PlayerStats, this + 1, 0))
            call MultiboardReleaseItem(MultiboardGetItem(.Team.PlayerStats, this + 1, 1))
            call MultiboardReleaseItem(MultiboardGetItem(.Team.PlayerStats, this + 1, 2))
            call MultiboardReleaseItem(MultiboardGetItem(.Team.PlayerStats, this + 1, 3))
            
			if RewardMode == GameModesGlobals_HARD then
				call MultiboardSetItemValue(MultiboardGetItem(.Team.PlayerStats, this + 1, 4), "Too many")
				call MultiboardReleaseItem(MultiboardGetItem(.Team.PlayerStats, this + 1, 4))
			endif
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
                    exitwhen (ttype != ABYSS and ttype != LAVA and ttype != LRGBRICKS)
                elseif newGameMode == Teams_GAMEMODE_PLATFORMING or newGameMode == Teams_GAMEMODE_PLATFORMING_PAUSED then
                    exitwhen (ttype != LAVA and ttype != LRGBRICKS and TerrainGlobals_IsTerrainPathable(ttype))
                else
                    debug call DisplayTextToPlayer(Player(0), 0, 0, "Switching from dead gamemode to invalid new gamemode: " + I2S(newGameMode))
                endif
            endloop
        elseif .ActiveUnit != null then
            set x = GetUnitX(.ActiveUnit)
            set y = GetUnitY(.ActiveUnit)
		else 
			set x = 0
			set y = 0
        endif
        
        call .SwitchGameModes(newGameMode, x, y)
    endmethod
    
    private method ApplyDeathMode takes real x, real y, real facing, integer oldGameMode returns nothing
        local vector2 respawnPoint
                
        //disable camera tracking if that player has it enabled
        call ResetDefaultCamera(1.)
        
        //check if respawn circles should be used
        if not RespawnASAPMode and .IsPlaying then
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
            static if DEBUG_GAMEMODE_CHANGE then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Current gamemode: " + I2S(curGameMode) + ", New gamemode: " + I2S(newGameMode))
			endif
			
			//if the new gamemode is death then we might need to keep a few things in memory
            if newGameMode == Teams_GAMEMODE_DEAD then
                if not RespawnASAPMode then
                    set facing = GetUnitFacing(.ActiveUnit)
                endif
			elseif newGameMode == Teams_GAMEMODE_HIDDEN then
				call .ResetDefaultCamera(0.)
            endif
			
			// if this == 1 then
				// call DisplayTextToForce(bj_FORCE_PLAYER[0], "Changing gamemode from: " + I2S(curGameMode) + ", to: " + R2S(newGameMode))
			// endif
            
            //remove the old game mode
            if curGameMode == Teams_GAMEMODE_STANDARD then
                call ShowUnit(MazersArray[this], false)
				
				//remove the current terrain effect
                if PreviousTerrainTypedx[this] != NOEFFECT then
					call GameLoopRemoveTerrainAction(MazersArray[this], this, PreviousTerrainTypedx[this], NOEFFECT)
					set PreviousTerrainTypedx[this] = NOEFFECT
				endif
								
				//moves the mazing unit
                call SetUnitPosition(MazersArray[this], MazerGlobals_SAFE_X, MazerGlobals_SAFE_Y)
                //removes the reg unit from the reg game loop. thereby enabling regular terrain effects
				call StandardMazingUsers.remove(this)
                
                //updates the number of units platforming/regular mazing
                set NumberMazing = NumberMazing - 1
            elseif curGameMode == Teams_GAMEMODE_PLATFORMING then
                call .Platformer.StopPlatforming()
            elseif curGameMode == Teams_GAMEMODE_STANDARD_PAUSED then
                // //restore default movespeed regardless
                //call SetUnitMoveSpeed(MazersArray[this], DefaultMoveSpeed)
                
                //remove entangling roots on the paused mazer
				call .ClearActiveEffect()
				
                //call UnitRemoveBuffs(.ActiveUnit, true, true)
                call DummyCaster['A004'].castTarget(Player(10), 1, OrderId("dispel"), .ActiveUnit)
				call SetUnitPropWindow(.ActiveUnit, GetUnitDefaultPropWindow(.ActiveUnit) * bj_DEGTORAD)
                
                //if the new gamemode isnt to unpause the unit then we need to undo the pause effect
                if newGameMode != Teams_GAMEMODE_STANDARD then					
					call ShowUnit(MazersArray[this], false)
					call SetUnitPosition(MazersArray[this], MazerGlobals_SAFE_X, MazerGlobals_SAFE_Y)
                endif
            elseif curGameMode == Teams_GAMEMODE_PLATFORMING_PAUSED then
                //if the new gamemode isnt to unpause the unit then we need to undo the pause effect
                if newGameMode != Teams_GAMEMODE_PLATFORMING then
                    call ShowUnit(.Platformer.Unit, false)
					call SetUnitPosition(.Platformer.Unit, PlatformerGlobals_SAFE_X, PlatformerGlobals_SAFE_Y)
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
                //moves the mazing unit
				call SetUnitPosition(MazersArray[this], x, y)
				//adds the reg unit from the reg game loop. thereby enabling regular terrain effects
				call StandardMazingUsers.addEnd(this)
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
                call .Platformer.StartPlatforming(x, y)
				
				// if GetLocalPlayer() == Player(this) then
					// set .PlatformerStartStable = false
				// endif
				set .PlatformerStartStable = false
				
				if .IsAFK then
					call .ApplyAFKPlatformer()
				endif
            elseif newGameMode == Teams_GAMEMODE_STANDARD_PAUSED then
                call SetUnitPosition(MazersArray[this], x, y)
                //set movespeed 0 instead of pausing unit so player can pivot to face a better direction
                //call SetUnitMoveSpeed(MazersArray[this], 0)
                call ShowUnit(MazersArray[this], true)
				
                //apply entangling roots to the paused mazer
				//using the actual spell on a flying unit is very inconsistent so just script its effect
                //call DummyCaster['A003'].castTarget(Player(10), 1, OrderId("entanglingroots"), .ActiveUnit)			
				//call DummyCaster['A007'].castTarget(Player(10), 1, OrderId("slow"), .ActiveUnit)
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
                call .Platformer.StopPlatforming()
                call .Platformer.StartPlatforming(x, y)
            endif
        endif
		
		// if this == 1 then
			// call DisplayTextToForce(bj_FORCE_PLAYER[0], "Moved to x: " + R2S(x) + ", y: " + R2S(y))
			// call DisplayTextToForce(bj_FORCE_PLAYER[0], "Check active x: " + R2S(GetUnitX(.ActiveUnit)) + ", y: " + R2S(GetUnitY(.ActiveUnit)))
		// endif
    endmethod
    
    private method SetCurrentGameMode takes integer newGameMode returns nothing
        if newGameMode != .GameMode then
            if .GameMode >= 0 then
                set .PreviousGameMode = .GameMode
            endif
            
            set .GameMode = newGameMode
            
			if newGameMode != Teams_GAMEMODE_DEAD and newGameMode != Teams_GAMEMODE_DYING then
				set .IsAlive = true
			endif
			
            if newGameMode == Teams_GAMEMODE_STANDARD or newGameMode == Teams_GAMEMODE_STANDARD_PAUSED or newGameMode == Teams_GAMEMODE_DYING then
                set .ActiveUnit = MazersArray[this]
				set .ActiveUnitRadius = GetUnitDefaultRadius(GetUnitTypeId(.ActiveUnit))
            elseif newGameMode == Teams_GAMEMODE_PLATFORMING or newGameMode == Teams_GAMEMODE_PLATFORMING_PAUSED then
                set .ActiveUnit = .Platformer.Unit
				set .ActiveUnitRadius = GetUnitDefaultRadius(GetUnitTypeId(.ActiveUnit))
            elseif newGameMode == Teams_GAMEMODE_DEAD then
                //this may be problematic
                if RespawnASAPMode then
                    set .ActiveUnit = null
					set .ActiveUnitRadius = 0.
                else
                    set .ActiveUnit = PlayerReviveCircles[this]
					set .ActiveUnitRadius = GetUnitDefaultRadius(GetUnitTypeId(.ActiveUnit))
                endif
			elseif newGameMode == Teams_GAMEMODE_HIDDEN then
				set .ActiveUnit = null
            endif
        endif
    endmethod
    
    public method IsActiveUnitInRect takes rect r returns boolean
        return GetUnitX(.ActiveUnit) >= GetRectMinX(r) and GetUnitX(.ActiveUnit) <= GetRectMaxX(r) and GetUnitY(.ActiveUnit) >= GetRectMinY(r) and GetUnitY(.ActiveUnit) <= GetRectMaxY(r)
    endmethod
    public method IsActiveUnitInArea takes vector2 topLeft, vector2 botRight returns boolean
        return GetUnitX(.ActiveUnit) >= topLeft.x and GetUnitX(.ActiveUnit) <= botRight.x and GetUnitY(.ActiveUnit) >= botRight.y and GetUnitY(.ActiveUnit) <= topLeft.y
    endmethod
	
	private static method UnpauseAFKCB takes nothing returns nothing
		local timer t = GetExpiredTimer()
		local User u = GetTimerData(t)
		local texttag text
		
		if u.AFKPlatformerDeathClock == AFK_UNPAUSE_BUFFER then
			set text = CreateTextTag()
			call SetTextTagText(text, ColorMessage("Unpausing", u.GetPlayerColorHex()) + " in ", SMALL_FONT_SIZE)
			call SetTextTagPos(text, GetUnitX(u.ActiveUnit) - 13 * 5.5, GetUnitY(u.ActiveUnit), 16.0)
			call SetTextTagVisibility(text, true)
			call SetTextTagFadepoint(text, AFK_UNPAUSE_BUFFER)
			call SetTextTagLifespan(text, AFK_UNPAUSE_BUFFER + 1.)
			call SetTextTagPermanent(text, false)
			set text = null
		endif
		
		if u.AFKPlatformerDeathClock > 0 then
			if u.AFKPlatformerDeathClock - R2I(u.AFKPlatformerDeathClock) == 0. then
				set text = CreateTextTag()
				call SetTextTagText(text, I2S(R2I(u.AFKPlatformerDeathClock)), SMALL_FONT_SIZE)
				
				//more funk
				call SetTextTagPos(text, GetUnitX(u.ActiveUnit) + 22 * 5.5 + 4 * 5.5, GetUnitY(u.ActiveUnit) - 16 * 2.5, 16.0)
				call SetTextTagVelocity(text, 0.0, 0.04)
				// //less funk
				// call SetTextTagPos(text, u.Platformer.XPosition + 16 * 5.5 + 4 * 5.5, u.Platformer.YPosition, 16.0)
				// call SetTextTagVelocity(text, 0.0, 0.02)
				
				call SetTextTagVisibility(text, true)
				call SetTextTagFadepoint(text, .75)
				call SetTextTagLifespan(text, 1.)
				call SetTextTagPermanent(text, false)
				
				if u.AFKPlatformerDeathClock == 1. then
					call SetTextTagColor(text, 255, 0, 0, 255)
				endif
				
				set text = null
			endif
			
			set u.AFKPlatformerDeathClock = u.AFKPlatformerDeathClock - 1.
		else
			call u.Pause(false)
			
			call ReleaseTimer(t)
		endif
		
		set t = null
	endmethod
	private static method PanAFKCameraCB takes nothing returns nothing
		call TimerStart(GetExpiredTimer(), 1., true, function thistype.UnpauseAFKCB)
	endmethod
	
	private static method ApplyAFKPlatformerCB takes nothing returns nothing
		local timer t = GetExpiredTimer()
		local User u = GetTimerData(t)
		local texttag text
		
		if u.IsAFK then
			if u.PlatformerStartStable then
				if u.AFKPlatformerDeathClock == AFK_PLATFORMER_DEATH_CLOCK_START then
					set text = CreateTextTag()
					call SetTextTagText(text, ColorMessage("Dead", u.GetPlayerColorHex()) + " in ", SMALL_FONT_SIZE)
					call SetTextTagPos(text, u.Platformer.XPosition - 8 * 5.5, u.Platformer.YPosition, 16.0)
					call SetTextTagVisibility(text, true)
					call SetTextTagFadepoint(text, AFK_PLATFORMER_DEATH_CLOCK_START)
					call SetTextTagLifespan(text, AFK_PLATFORMER_DEATH_CLOCK_START + 1.)
					call SetTextTagPermanent(text, false)
					set text = null
				endif
				
				if u.AFKPlatformerDeathClock > 0 then
					if u.AFKPlatformerDeathClock - R2I(u.AFKPlatformerDeathClock) == 0. then
						set text = CreateTextTag()
						call SetTextTagText(text, I2S(R2I(u.AFKPlatformerDeathClock)), SMALL_FONT_SIZE)
						
						//more funk
						call SetTextTagPos(text, u.Platformer.XPosition + 16 * 5.5 + 4 * 5.5, u.Platformer.YPosition - 16 * 2.5, 16.0)
						call SetTextTagVelocity(text, 0.0, 0.04)
						// //less funk
						// call SetTextTagPos(text, u.Platformer.XPosition + 16 * 5.5 + 4 * 5.5, u.Platformer.YPosition, 16.0)
						// call SetTextTagVelocity(text, 0.0, 0.02)
						
						call SetTextTagVisibility(text, true)
						call SetTextTagFadepoint(text, .75)
						call SetTextTagLifespan(text, 1.)
						call SetTextTagPermanent(text, false)
						
						if u.AFKPlatformerDeathClock <= 3 then
							call SetTextTagColor(text, 255, 0, 0, 255)
						endif
						
						set text = null
					endif
					
					set u.AFKPlatformerDeathClock = u.AFKPlatformerDeathClock - AFK_PLATFORMER_CLOCK
				else
					call u.SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
					
					call ReleaseTimer(t)
				endif
			endif
		else
			//no longer AFK, immediately desist
			call ReleaseTimer(t)
		endif
		
		set t = null
	endmethod
	public method ApplyAFKPlatformer takes nothing returns nothing	
		//no way to support sharing control via keyboard actions
		//show texttag countdown before killing
		set .AFKPlatformerDeathClock = AFK_PLATFORMER_DEATH_CLOCK_START
		call TimerStart(NewTimerEx(this), AFK_PLATFORMER_CLOCK, true, function thistype.ApplyAFKPlatformerCB)
	endmethod
	
	private static method OnUnapplyAFKStandard takes SyncRequest request, User user returns integer
		// local boolean needsPause = S2B(request.RequestData)
		
		if S2B(request.RequestData) then
			set user.AFKPlatformerDeathClock = AFK_UNPAUSE_BUFFER
			call user.Pause(true)
			call user.ApplyDefaultCameras(AFK_PAN_CAMERA_DURATION)
			call user.ApplyDefaultSelections()
			
			call TimerStart(NewTimerEx(user), AFK_PAN_CAMERA_DURATION, false, function thistype.PanAFKCameraCB)
		endif
		
		call request.destroy()
		
		return 0
	endmethod
	
	//User AFK synced event callback and async logic for checking/tracking idle state
	public method ToggleAFK takes nothing returns nothing
		local SyncRequest request
		
		//this hurts, but its advantageous to have GetStylizedPlayerName include the AFK prefix in every other situation but this
		if not .IsAFK then
			if DEBUG_AFK or .Team.Users.count > 1 then
				call .Team.PrintMessage(.GetStylizedPlayerName() + " is now AFK!")
			endif
		endif
		
		set .IsAFK = not .IsAFK
		
		if .IsAFK then
			if DEBUG_AFK or .Team.Users.count > 1 then
				// call .Team.PrintMessage(.GetStylizedPlayerName() + " is now AFK!")
				
				if .GameMode == Teams_GAMEMODE_STANDARD or .GameMode == Teams_GAMEMODE_STANDARD_PAUSED then
					call .Team.SetSharedControlForTeam(this, true)
				elseif .GameMode == Teams_GAMEMODE_PLATFORMING or .GameMode == Teams_GAMEMODE_PLATFORMING_PAUSED then
					call .ApplyAFKPlatformer()
				endif
				
				//disable default camera tracking so as to not interact with shared control
				if DefaultCameraTracking[this] then
					call .ToggleDefaultTracking()
				endif
				
				if GetLocalPlayer() == Player(this) and AFK_CAMERA_DELTA_TIMEOUT * thistype.LocalAFKThreshold >= AFK_CAMERA_MIN_TIMEOUT then
					set thistype.LocalAFKThreshold = AFK_CAMERA_DELTA_TIMEOUT * thistype.LocalAFKThreshold
					
					//TODO sync callback for user's threshold
					//if first threshold then warn player about exiling
					//if second threshold then inform team about exiling
				endif
			endif
		else
			if DEBUG_AFK or .Team.Users.count > 1 then
				call .Team.PrintMessage(.GetStylizedPlayerName() + " is no longer AFK")
				call .Team.SetSharedControlForTeam(this, false)
				
				if .GameMode == Teams_GAMEMODE_STANDARD then
					//check that unit is not near owner's camera bounds as well
					set request = SyncRequest.create(OnUnapplyAFKStandard, this)
					// set request = SyncRequest.create()
					// call request.Then(OnUnapplyAFKStandard, 0, this)
					
					if GetLocalPlayer() == Player(this) then
						call request.Sync(B2S(RAbsBJ(GetCameraTargetPositionX() - GetUnitX(.ActiveUnit)) >= CAMERA_TARGET_POSITION_PAUSE_X_FLEX or (GetCameraTargetPositionY() >= GetUnitY(.ActiveUnit) and GetCameraTargetPositionY() - GetUnitY(.ActiveUnit) >= CAMERA_TARGET_POSITION_PAUSE_Y_BOTTOM_FLEX) or (GetCameraTargetPositionY() < GetUnitY(.ActiveUnit) and GetUnitY(.ActiveUnit) - GetCameraTargetPositionY()  >= CAMERA_TARGET_POSITION_PAUSE_Y_TOP_FLEX)))
						
						// call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Unpause AFK, pt 1: " + B2S(RAbsBJ(GetCameraTargetPositionX() - GetUnitX(.ActiveUnit)) >= CAMERA_TARGET_POSITION_PAUSE_X_FLEX) + ", pt 2: " + B2S(GetCameraTargetPositionY() >= GetUnitY(.ActiveUnit) and GetCameraTargetPositionY() - GetUnitY(.ActiveUnit) >= CAMERA_TARGET_POSITION_PAUSE_Y_BOTTOM_FLEX) + ", pt 3: " + B2S(GetCameraTargetPositionY() < GetUnitY(.ActiveUnit) and GetUnitY(.ActiveUnit) - GetCameraTargetPositionY()  >= CAMERA_TARGET_POSITION_PAUSE_Y_TOP_FLEX))
					endif
				endif
				
				
			endif
		endif
		
		//either prepend or reset player's name in multiboard
		call .PartialUpdateMultiboard()
	endmethod
	private static method ToggleAFKCallback takes nothing returns boolean
		call User(S2I(BlzGetTriggerSyncData())).ToggleAFK()
		
		return false
	endmethod
		
	private method CheckAFKPlayer takes real timeElapsed returns nothing
		//call sync AFK checks, sync wrappers around async data
		if this.GameMode == Teams_GAMEMODE_PLATFORMING and not this.PlatformerStartStable and ((this.Platformer.PushedAgainstVector != 0 and this.Platformer.YVelocity == 0.) or this.Platformer.HorizontalAxisState != 0) then
			set this.PlatformerStartStable = true
			
			if GetLocalPlayer() == Player(this) and this.Platformer.HorizontalAxisState == 0 then
				set thistype.LocalCameraTargetPosition.x = GetCameraTargetPositionX()
				set thistype.LocalCameraTargetPosition.y = GetCameraTargetPositionY()
			endif
		endif
		
		//call async AFK checks
		if GetLocalPlayer() == Player(this) then
			if this.GameMode == Teams_GAMEMODE_PLATFORMING or this.GameMode == Teams_GAMEMODE_PLATFORMING_PAUSED then				
				if this.Platformer.HorizontalAxisState != 0 or (this.PlatformerStartStable and (GetCameraTargetPositionX() != LocalCameraTargetPosition.x or GetCameraTargetPositionY() != LocalCameraTargetPosition.y)) then
					set thistype.LocalCameraIdleTime = 0
					
					set thistype.LocalCameraTargetPosition.x = GetCameraTargetPositionX()
					set thistype.LocalCameraTargetPosition.y = GetCameraTargetPositionY()
				else
					set thistype.LocalCameraIdleTime = thistype.LocalCameraIdleTime + timeElapsed
				endif
			else
				if RAbsBJ(GetCameraTargetPositionX() - LocalCameraTargetPosition.x) > CAMERA_TARGET_POSITION_FLEX or RAbsBJ(GetCameraTargetPositionY() - LocalCameraTargetPosition.y) > CAMERA_TARGET_POSITION_FLEX then
					// call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Difference for camera destination x: " + R2S(RAbsBJ(GetCameraTargetPositionX() - LocalCameraTargetPosition.x)) + ", y: " + R2S(RAbsBJ(GetCameraTargetPositionY() - LocalCameraTargetPosition.y)))
					
					set thistype.LocalCameraIdleTime = 0
					
					set thistype.LocalCameraTargetPosition.x = GetCameraTargetPositionX()
					set thistype.LocalCameraTargetPosition.y = GetCameraTargetPositionY()
				else
					// if .IsAFK then
						// call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "(No) Difference for camera destination x: " + R2S(RAbsBJ(GetCameraTargetPositionX() - LocalCameraTargetPosition.x)) + ", y: " + R2S(RAbsBJ(GetCameraTargetPositionY() - LocalCameraTargetPosition.y)))
						// call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Full boolean: " + B2S(RAbsBJ(GetCameraTargetPositionX() - LocalCameraTargetPosition.x) > CAMERA_TARGET_POSITION_FLEX or RAbsBJ(GetCameraTargetPositionY() - LocalCameraTargetPosition.y) > CAMERA_TARGET_POSITION_FLEX) + ", pt 1: " + B2S(RAbsBJ(GetCameraTargetPositionX() - LocalCameraTargetPosition.x) > CAMERA_TARGET_POSITION_FLEX) + ", pt 2: " + B2S(RAbsBJ(GetCameraTargetPositionY() - LocalCameraTargetPosition.y) > CAMERA_TARGET_POSITION_FLEX))
					// endif

					set thistype.LocalCameraIdleTime = thistype.LocalCameraIdleTime + timeElapsed
				endif
			endif
			
			//if (this.IsAFK and thistype.LocalCameraIdleTime < AFK_CAMERA_MAX_TIMEOUT) or /*
			//	*/(not this.IsAFK and /*
			//	*/((thistype.LocalCameraIdleTime >= AFK_CAMERA_MAX_TIMEOUT) or /*
			//	*/(thistype.LocalCameraIdleTime >= AFK_MANUAL_CHECK_FACTOR * AFK_CAMERA_MAX_TIMEOUT)) then
			//
			if (this.IsAFK and thistype.LocalCameraIdleTime < thistype.LocalAFKThreshold) or (not this.IsAFK and thistype.LocalCameraIdleTime >= thistype.LocalAFKThreshold) then
				// call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "On sync event, idle time: " + R2S(thistype.LocalCameraIdleTime))
				call BlzSendSyncData(AFK_SYNC_EVENT_PREFIX, I2S(this))
			endif
		endif
	endmethod
	private static method CheckAFKPlayers takes nothing returns nothing
		local SimpleList_ListNode curUserNode = PlayerUtils_FirstPlayer
		local real timeElapsed = TimerGetElapsed(GetExpiredTimer())
		
		loop
		exitwhen curUserNode == 0
			call User(curUserNode.value).CheckAFKPlayer(timeElapsed)
		set curUserNode = curUserNode.next
		endloop
	endmethod
	
	// private static method ClearSyncLocalCameraPromises takes nothing returns nothing
		// local SimpleList_ListNode curCameraPromiseNode
		
		// loop
		// set curCameraPromiseNode = AFKSyncLocalCameraTimePromises.pop()
		// exitwhen curCameraPromiseNode == 0
			// call Deferred(curCameraPromiseNode.value).destroy()
			
			// call curCameraPromiseNode.deallocate()
		// endloop
	// endmethod
	// private static method OnSyncAll takes integer result, All allCameraTimeSynced returns integer
		// local SimpleList_ListNode curUserNode = PlayerUtils_FirstPlayer
		
		// call DisplayTextToPlayer(Player(0), 0, 0, "All camera idle times synced (all: " + I2S(allCameraTimeSynced) + ")")
		
		// loop
		// exitwhen curUserNode == 0
			// call DisplayTextToPlayer(Player(0), 0, 0, "Idle time: " + R2S(User(curUserNode.value).CameraIdleTime))
		// set curUserNode = curUserNode.next
		// endloop
		
		// // call allCameraTimeSynced.destroy()
		
		// return 0
	// endmethod
	// private static method OnSyncLocal takes nothing returns boolean
		// local string data = BlzGetTriggerSyncData()
		// local integer uIndex = S2I(SubString(data, 0, 1))
		// local User u = PlayerUtils_PlayerList.get(uIndex).value
		// // local real time = S2R(SubString(data, 1, StringLength(data)))
		
		// // // call DisplayTextToPlayer(Player(0), 0, 0, "user index: " + I2S(uIndex) + ", user: " + I2S(u) + ", time: " + R2S(time))
		
		// // set u.CameraIdleTime = time
		
		// // call DisplayTextToPlayer(Player(0), 0, 0, "user index: " + I2S(uIndex) + ", user: " + I2S(u) + ", time: " + R2S(S2R(SubString(data, 1, StringLength(data)))))
		
		// set u.CameraIdleTime = S2R(SubString(data, 1, StringLength(data)))
		// call Deferred(thistype.AFKSyncLocalCameraTimePromises.get(uIndex).value).Resolve(u)
		
		// return false
	// endmethod
	
	// public method IsAFKSync takes nothing returns boolean
		// // call DisplayTextToPlayer(Player(0), 0, 0, "User: " + I2S(this) + ", idle time: " + R2S(.CameraIdleTime) + ", threshold: " + R2S(AFK_MANUAL_CHECK_FACTOR * AFK_CAMERA_MAX_TIMEOUT))
		
		// return .CameraIdleTime >=  AFK_MANUAL_CHECK_FACTOR * AFK_CAMERA_MAX_TIMEOUT
	// endmethod
	// public static method SyncLocalCameraIdleTime takes nothing returns Deferred
		// local SimpleList_ListNode curUserNode = PlayerUtils_FirstPlayer
		// local integer i = 0
		// // local Deferred allCameraTimeSynced
		
		// call ClearSyncLocalCameraPromises()
		
		// loop
		// exitwhen curUserNode == 0
			// call AFKSyncLocalCameraTimePromises.addEnd(Deferred.create())
			
			// if GetLocalPlayer() == Player(curUserNode.value) then
				// //TODO encode to base-whatever to support max possible players
				// call BlzSendSyncData(LOCAL_CAMERA_IDLE_TIME_EVENT_PREFIX, I2S(i) + R2S(thistype.LocalCameraIdleTime))
			// endif
		// set curUserNode = curUserNode.next
		// set i = i + 1
		// endloop
		
		// // set allCameraTimeSynced = All(AFKSyncLocalCameraTimePromises)
		// // //TODO move this to the caller
		// // // call allCameraTimeSynced.Then(thistype.OnSyncAll, 0, allCameraTimeSynced)
		
		// // return allCameraTimeSynced
		
		// return All(AFKSyncLocalCameraTimePromises)
	// endmethod
	        
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
        set new.IsAlive = true
		
		set new.IsAFK = false
		call BlzTriggerRegisterPlayerSyncEvent(thistype.AFKSyncEvent, Player(new), AFK_SYNC_EVENT_PREFIX, false)
		
		// set new.CameraIdleTime = 0.
		// call BlzTriggerRegisterPlayerSyncEvent(thistype.AFKLocalCameraTimeSyncEvent, Player(new), LOCAL_CAMERA_IDLE_TIME_EVENT_PREFIX, false)
		// call TriggerRegisterPlayerStateEvent(thistype.AFKMouseEvent, Player(new), PLAYER_STATE_OBSERVER_ON_DEATH, GREATER_THAN_OR_EQUAL, 0)
        
        set new.CinematicPlaying = 0
        set new.CinematicQueue = SimpleList_List.create()
        
        set new.GameMode = Teams_GAMEMODE_STANDARD //regular mazing
        //FOR SOME REASON THIS IS RETURNING NULL, SO WE NEED TO SET ACTIVE UNIT AFTER MAP INIT
        //set new.ActiveUnit = MazersArray[new]
        
        //set new.Platformer = Platformer.AllPlatformers[new]
        set new.Platformer = Platformer.create(new)
		
        return new
    endmethod
	
	private static method ToggleCameraTrackingCinematicCleanup takes nothing returns boolean
		if EventCinematic == thistype.ToggleCameraTrackingTutorial then
			set thistype.ToggleCameraTrackingTutorial = 0
		endif
		
		return false
	endmethod
	//currently assumes that the human players are all the first n players
    private static method onInit takes nothing returns nothing
        local integer n = 0
        set User.ActivePlayers = 0
        
		static if DEBUG_AFK then
			set User.LocalAFKThreshold = AFK_CAMERA_DEBUG_TIMEOUT
		else
			set User.LocalAFKThreshold = AFK_CAMERA_MAX_TIMEOUT
		endif
		
		// set User.AFKLocalCameraTimeSyncEvent = CreateTrigger()
		// set User.AFKSyncLocalCameraTimePromises = SimpleList_List.create()
		// call TriggerAddCondition(User.AFKLocalCameraTimeSyncEvent, Condition(function thistype.OnSyncLocal))
		
		set User.AFKSyncEvent = CreateTrigger()
		call TriggerAddCondition(thistype.AFKSyncEvent, Condition(function thistype.ToggleAFKCallback))
		set User.LocalCameraIdleTime = 0.
		set User.LocalCameraTargetPosition = vector2.create(0., 0.)
		
		// set User.AFKMouseEvent = CreateTrigger()
		// call TriggerAddCondition(thistype.AFKMouseEvent, Condition(function thistype.CheckAFKMouseEventCallback))
		// set User.LocalUserMousePosition = vector2.create(0., 0.)
		
		call TimerStart(CreateTimer(), AFK_CAMERA_CHECK_TIMEOUT, true, function thistype.CheckAFKPlayers)
		
        loop
        exitwhen n>=NumberPlayers
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
		
		//register camera tracking cinematic
		set ToggleCameraTrackingTutorial = Cinematic.create(null, false, false, CinemaMessage.create(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Nice, you've enabled camera tracking!", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED))
		call ToggleCameraTrackingTutorial.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Turn tracking on and off by pressing the escape key", DEFAULT_TEXT_COLOR), DEFAULT_LONG_TEXT_SPEED)
		call ToggleCameraTrackingTutorial.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Each mode has different advantages and disadvantages", DEFAULT_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
		call ToggleCameraTrackingTutorial.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Try getting good at both!", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
		
		call Cinematic.OnCinemaEnd.register(Condition(function thistype.ToggleCameraTrackingCinematicCleanup))
    endmethod
endstruct

endlibrary