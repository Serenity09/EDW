library User requires UnitDefaultRadius, MazerGlobals, Platformer, TerrainHelpers, Cinema, LocalizationData, MultiboardGlobals, StringFormat, AsyncInit

globals
	User TriggerUser //used with events
	
	private constant real CAMERA_SETTINGS_AUTO_CHECK_TIMEOUT = .5
	private constant real CAMERA_SETTINGS_AUTO_CHECK_BUFFER = 10.
	private constant real CAMERA_SETTINGS_AUTO_FIX_DURATION = .75
	
	private constant real CAMERA_TARGET_POSITION_FLEX = 50.
	private constant real AUTO_TRANSITION_BUFFER = .1
	
	private constant real CAMERA_TARGET_POSITION_UNPAUSE_TRANSITION_THRESHOLD = 7. * TERRAIN_TILE_SIZE
	private constant real AFK_TIMER_UNPAUSE_TRANSITION_THRESHOLD = 10.
	
	private constant real AFK_CAMERA_CHECK_TIMEOUT = 1.
	
	private constant real AFK_CAMERA_MAX_TIMEOUT = 120.
	private constant real AFK_CAMERA_MIN_TIMEOUT = 30.
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

	private constant boolean DEBUG_AUTO_LEAVE = false
	
	private constant boolean DEBUG_AFK = false
	private constant real AFK_CAMERA_DEBUG_TIMEOUT = AFK_CAMERA_MIN_TIMEOUT
endglobals

struct User extends array
    public boolean IsPlaying
    public boolean IsAlive
	private boolean IsTransitioning //not 100% reliable for some reason, but it doesn't need to be for its current needs. should fix before depending on for other functionality
	readonly timer TransitioningTimer
	readonly boolean IsAFK
    readonly integer Deaths
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
		
	readonly unit LastCollidedUnit
	readonly timer LastCollidedUnitTimer
	
	private multiboard Statistics
	public integer StatisticsSortIndex
	
	// public real CameraIdleTime //only as accurate as the last sync
	readonly timer AFKPlatformerDeathTimer
	readonly real AFKPlatformerDeathClock
	
	//synced at game start so that it can be used outside of local player blocks
	readonly string LanguageCode
	
	readonly VisualVote_voteMenu VoteMenu
	
	public static integer OriginalPlayerCount
    public static integer ActivePlayers
	
	// private static trigger AFKLocalCameraTimeSyncEvent
	// private static SimpleList_List AFKSyncLocalCameraTimePromises
	
	private static real LocalCameraTargetDistance
	
	private static trigger AFKSyncEvent
	readonly static vector2 LocalUnitPosition
	readonly static vector2 LocalCameraTargetPosition
	private static real LocalCameraIdleTime
	private static real LocalAFKThreshold
	public boolean PlatformerStartStable
	// public static trigger AFKMouseEvent
	// public static vector2 LocalUserMousePosition
	
	readonly LevelPathNodeConnection CurrentPathConnection
	readonly real FurthestPathDistance
	readonly LevelPathNodeConnection FurthestPathConnection
	//TODO move to static if after level path framework 
	private boolean DebugCurrentConnection
	private lightning DebugCurrentConnectionLine
	private unit DebugCurrentConnectionProjection
	public boolean DebugCurrentDistance
	
	private static Cinematic ToggleCameraTrackingTutorial
    
	method operator < takes thistype other returns boolean
		return R2I(I2R(this)) < R2I(I2R(other))
	endmethod
	
	public method operator IsDead takes nothing returns boolean
		return .GameMode == Teams_GAMEMODE_DYING or .GameMode == Teams_GAMEMODE_DYING
	endmethod
	// public method IsAlive takes nothing returns boolean
		// return not .IsDead
	// endmethod
	
	public method operator IsStandard takes nothing returns boolean
		return .GameMode == Teams_GAMEMODE_STANDARD or .GameMode == Teams_GAMEMODE_STANDARD_PAUSED
	endmethod
	public method operator IsPlatforming takes nothing returns boolean
		return .GameMode == Teams_GAMEMODE_PLATFORMING or .GameMode == Teams_GAMEMODE_PLATFORMING_PAUSED
	endmethod
	public method operator IsUnpaused takes nothing returns boolean
		return .GameMode == Teams_GAMEMODE_STANDARD or .GameMode == Teams_GAMEMODE_PLATFORMING
	endmethod
	public method operator IsPaused takes nothing returns boolean
		return .GameMode == Teams_GAMEMODE_STANDARD_PAUSED or .GameMode == Teams_GAMEMODE_PLATFORMING_PAUSED
	endmethod
	
	public method operator IsInactive takes nothing returns boolean
		return .IsDead or .GameMode == Teams_GAMEMODE_HIDDEN or .IsAFK
	endmethod
	public method operator IsActive takes nothing returns boolean
		return not .IsInactive
	endmethod
	
	public method GetCurrentPosition takes nothing returns vector2
		if .ActiveUnit != null then
			return vector2.create(GetUnitX(.ActiveUnit), GetUnitY(.ActiveUnit))
		else
			return 0
		endif
	endmethod
	
	public method SetConnection takes LevelPathNodeConnection connection returns nothing
		set this.CurrentPathConnection = connection
		
		if this.DebugCurrentConnection then
			if this.DebugCurrentConnectionLine != null then
				call DestroyLightning(this.DebugCurrentConnectionLine)
				set this.DebugCurrentConnectionLine = null
			endif
			if this.CurrentPathConnection != 0 then
				set this.DebugCurrentConnectionLine = this.CurrentPathConnection.ConnectingLine.DrawEx(Draw_SPIRIT_LINK)
			endif
		endif
	endmethod	
	
	public method SetPath takes LevelPath path, LevelPathNodeConnection defaultConnection returns nothing
		set this.FurthestPathDistance = 0.
		set this.FurthestPathConnection = 0
		
		call this.SetConnection(defaultConnection)
	endmethod
	public method CheckPath takes LevelPath path returns nothing
		local vector2 curUserPosition
		
		local LevelPathNodeConnection closestConnection
		local real closestConnectionTotalDistance
		
		local vector2 curProjectedPosition
		
		//check that the user is reasonably within the current level's boundaries and try to get their closest connection if they are
		if this.IsUnpaused and this.CurrentPathConnection != 0 then			
			set curUserPosition = this.GetCurrentPosition()
			set closestConnection = this.CurrentPathConnection.GetClosestConnection(this.Team.Path, curUserPosition)
			
			if this.CurrentPathConnection != closestConnection then
				call this.SetConnection(closestConnection)
			endif

			if closestConnection != 0 then
				//reorient position using the connection's start point as its new origin
				set curUserPosition.x = curUserPosition.x - closestConnection.StartNode.Position.x
				set curUserPosition.y = curUserPosition.y - closestConnection.StartNode.Position.y
				
				set closestConnectionTotalDistance = closestConnection.GetTotalDistanceFromPoint(curUserPosition)
				if closestConnectionTotalDistance > this.FurthestPathDistance then
					if this.DebugCurrentDistance then
						call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Furthest distance reached: " + R2S(closestConnectionTotalDistance))
					endif
					
					set this.FurthestPathDistance = closestConnectionTotalDistance
					set this.FurthestPathConnection = closestConnection
				endif
				
				if this.DebugCurrentDistance then
					call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Current distance: " + R2S(closestConnectionTotalDistance))
				endif
				
				if this.DebugCurrentConnection then
					set curProjectedPosition = closestConnection.ConnectingLine.ProjectPoint(curUserPosition)
					call SetUnitX(this.DebugCurrentConnectionProjection, curProjectedPosition.x + closestConnection.StartNode.Position.x)
					call SetUnitY(this.DebugCurrentConnectionProjection, curProjectedPosition.y + closestConnection.StartNode.Position.y)
					call curProjectedPosition.deallocate()
				endif
			endif

			call curUserPosition.deallocate()
		endif
	endmethod
	public method CheckOffPath takes LevelPath path returns nothing
		local vector2 curUserPosition
		local LevelPathNodeConnection bestConnection
		
		if this.IsUnpaused and this.CurrentPathConnection == 0 then
			set curUserPosition = this.GetCurrentPosition()
			
			//check that the user is reasonably within the current level's boundaries and try to get their closest connection if they are
			if this.Team.OnLevel.IsPointInBoundary(curUserPosition.x, curUserPosition.y, TERRAIN_TILE_SIZE * 7.) then			
				set bestConnection = path.GetBestConnection(curUserPosition, path.Start, LevelPathNode_CLOSE_ENOUGH_SQUARED)
				
				if this.CurrentPathConnection != bestConnection then
					call this.SetConnection(bestConnection)
				endif
			endif

			call curUserPosition.deallocate()
		endif
	endmethod

	public method GetDebugPathConnection takes nothing returns boolean
		return this.DebugCurrentConnection
	endmethod
	public method SetDebugPathConnection takes boolean flag returns nothing
		if this.DebugCurrentConnection != flag then
			set this.DebugCurrentConnection = flag 

			if this.DebugCurrentConnectionLine != null then
				call DestroyLightning(this.DebugCurrentConnectionLine)
				set this.DebugCurrentConnectionLine = null
			endif

			if this.DebugCurrentConnection then
				set this.DebugCurrentConnectionProjection = Draw_DrawPoint(this, DEBUG_X, DEBUG_Y)
			else
				call RemoveUnit(this.DebugCurrentConnectionProjection)
			endif
		endif
	endmethod
	
	// public method CreateMenu takes real time, string optionCB returns nothing
        // local real x = VOTE_TOP_LEFT_X + R2I((this + 1) / 4)
        // local real y = VOTE_TOP_LEFT_Y + R2I((this + 1) / 2)
        // local SimpleList_ListNode cur = .FirstUser
                
        // set .VoteMenu = VisualVote_voteMenu.create(x, y, time, optionCB)
        
        // //register team to menu
        // loop
        // exitwhen cur == 0
            // //pause their active unit
            // if User(cur.value).GameMode == GAMEMODE_STANDARD then
                // call User(cur.value).SwitchGameModesDefaultLocation(GAMEMODE_STANDARD_PAUSED)
            // elseif User(cur.value).GameMode == GAMEMODE_PLATFORMING then
                // call User(cur.value).SwitchGameModesDefaultLocation(GAMEMODE_PLATFORMING_PAUSED)
            // endif
            
            // call .VoteMenu.forPlayers.addEnd(cur.value)
        // set cur = cur.next
        // endloop
    // endmethod
	public method ClearVoteMenu takes nothing returns nothing
		if .VoteMenu != 0 then
			call .VoteMenu.forPlayers.remove(this)
			set .VoteMenu = 0
		endif
	endmethod
	public method SetVoteMenu takes VisualVote_voteMenu menu returns nothing
		call .ClearVoteMenu()
		
		set .VoteMenu = menu
		call menu.forPlayers.addEnd(this)
		
		// current approach to this causes desync issues
		// if menu.rendered then
			// call menu.refresh(this)
		// endif
	endmethod
	public static method SetVoteMenuAll takes VisualVote_voteMenu menu returns nothing
		local SimpleList_ListNode curUserNode = PlayerUtils_FirstPlayer
		
		loop
		exitwhen curUserNode == 0
			call User(curUserNode.value).SetVoteMenu(menu)
		set curUserNode = curUserNode.next
		endloop
	endmethod
	
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
	
	public method CreateUserTimedEffect takes string fxFileLocation, string attachPointName, real duration, boolean localizeVFX returns nothing
		call UserActiveTimedEffect.create(fxFileLocation, attachPointName, this, duration, localizeVFX)
	endmethod
	
	public method CreateSpecialEffectOutsideRadius takes string fxFileLocation, real x, real y, real radius returns effect
		local string localFXFileLocation = fxFileLocation
		local SimpleList_ListNode curUserNode = PlayerUtils_FirstPlayer
		
		local real dx
		local real dy
		
		loop
		exitwhen curUserNode == 0
			if GetLocalPlayer() == Player(curUserNode.value) and curUserNode.value != this and User(curUserNode.value).ActiveUnit != null then
				set dx = x - GetUnitX(User(curUserNode.value).ActiveUnit)
				set dy = y - GetUnitY(User(curUserNode.value).ActiveUnit)
				
				if SquareRoot(dx*dx + dy*dy) <= radius then
					set localFXFileLocation = ""
				endif
			endif
		set curUserNode = curUserNode.next
		endloop
				
		return AddSpecialEffect(localFXFileLocation, x, y)
	endmethod
	public method CreateInstantSpecialEffectOutsideRadius takes string fxFileLocation, real x, real y, real radius returns nothing
		call DestroyEffect(this.CreateSpecialEffectOutsideRadius(fxFileLocation, x, y, radius))
	endmethod
	
	public method FlashQuestButton takes nothing returns nothing
		if GetLocalPlayer() == Player(this) then
			call FlashQuestDialogButton()
		endif
	endmethod
	public method DiscoverQuest takes quest q returns nothing
		if GetLocalPlayer() == Player(this) then
			call QuestSetDiscovered(q, true)
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
    public static method DisplayMessageAll takes string message returns nothing
        local SimpleList_ListNode curUserNode = PlayerUtils_FirstPlayer
        
        loop
        exitwhen curUserNode == 0
            call User(curUserNode.value).DisplayMessage(message, 0)
        set curUserNode = curUserNode.next
        endloop
    endmethod
	
	public method DisplayLocalizedMessage takes integer contentID, real duration returns nothing
		if .IsPlaying and GetLocalPlayer() == Player(this) then
            if duration == 0 then
                call DisplayTextToPlayer(Player(this), 0, 0, LocalizeContent(contentID, this.LanguageCode))
            else
                call DisplayTimedTextToPlayer(Player(this), 0, 0, duration, LocalizeContent(contentID, this.LanguageCode))
            endif
        endif
	endmethod
	public method DisplayLocalizedMessageAll takes integer contentID returns nothing
		local SimpleList_ListNode curUserNode = PlayerUtils_FirstPlayer
        
        loop
        exitwhen curUserNode == 0
            call User(curUserNode.value).DisplayLocalizedMessage(contentID, 0)
        set curUserNode = curUserNode.next
        endloop
	endmethod
	
    public static method OnCinemaEndCB takes nothing returns boolean       
        if EventUser.IsPlaying then
			set EventUser.CinematicPlaying = 0
			call EventUser.CheckCinematicQueue()
		endif
		
        return false
    endmethod
	public method ShortcutCinematicQueue takes Cinematic cine returns nothing
		call .CinematicQueue.clear()
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
		
		if cine == EDWCinematicContent_OBSTACLE then
			call this.DiscoverQuest(EDWQuests_OBSTACLE)
		elseif cine == EDWCinematicContent_FIRE then
			call this.DiscoverQuest(EDWQuests_FIRE)
		elseif cine == EDWCinematicContent_SKATING then
			call this.DiscoverQuest(EDWQuests_SKATING)
		elseif cine == EDWCinematicContent_PLATFORMING or cine == EDWCinematicContent_PLATFORMING_DEATH then
			call this.DiscoverQuest(EDWQuests_PLATFORMING)
			
			if cine == EDWCinematicContent_PLATFORMING_DEATH then
				call this.FlashQuestButton()
			endif
		endif
		
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
       
	// private static method OnLeaveCB takes nothing returns nothing
		// local timer t = GetExpiredTimer()
		// local User u = GetTimerData(t)
		
		// call u.UpdateMultiboard()
		
		// call ReleaseTimer(t)
		// set t = null
	// endmethod
	public method OnLeave takes nothing returns nothing
        local SimpleList_ListNode curUserNode = PlayerUtils_FirstPlayer
		local string message
				
		call SwitchGameModesDefaultLocation(Teams_GAMEMODE_STANDARD)
        
        set .IsPlaying = false
		// call DisplayTextToPlayer(Player(0), 0, 0, "Player: " + I2S(this) + " playing? " + B2S(.IsPlaying))
		
		call .SwitchGameModesDefaultLocation(Teams_GAMEMODE_DYING)
		
		call .Team.UpdateAwaitingAFKState()
		
        //TODO cleanup any structs
        
		set .ActiveUnit = null
        
        set User.ActivePlayers = User.ActivePlayers - 1

		// call this.UpdateMultiboard()
		// call TimerStart(NewTimerEx(this), 0.01, false, function thistype.OnLeaveCB)
		
		// call thistype.DisplayMessageAll(this.GetStylizedPlayerName() + " has left the game!")
        loop
        exitwhen curUserNode == 0
			if User(curUserNode.value).IsPlaying then
				set message = StringFormat1(LocalizeContent('UONL', User(curUserNode.value).LanguageCode), ColorMessage(GetPlayerName(Player(this)), this.GetPlayerColorHex()))
				
				if GetLocalPlayer() == Player(curUserNode.value) then
					call User(curUserNode.value).DisplayMessage(message, 0)
				endif
			endif
        set curUserNode = curUserNode.next
        endloop

		static if DEBUG_AUTO_LEAVE then
			if this == 0 then
				call .Team.ApplyEndGameAll(.Team)
			endif
		endif
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
	
	public method CancelSystemCameraTransition takes nothing returns nothing
		if .IsTransitioning then
			set .IsTransitioning = false
			call PauseTimer(.TransitioningTimer)
			// set .TransitioningTimer = null
		endif
	endmethod
	private static method SystemCameraTransitionCB takes nothing returns nothing
		local User u = User(GetTimerData(GetExpiredTimer()))
		
		call u.CancelSystemCameraTransition()
		
		if GetLocalPlayer() == Player(u) then
			set thistype.LocalCameraTargetPosition.x = GetCameraTargetPositionX()
			set thistype.LocalCameraTargetPosition.y = GetCameraTargetPositionY()
		endif
	endmethod
	public method RegisterSystemCameraTransition takes real duration returns nothing
		call .CancelSystemCameraTransition()
		
		set .IsTransitioning = true
		// set .TransitioningTimer = NewTimerEx(this)
		call TimerStart(.TransitioningTimer, duration + AUTO_TRANSITION_BUFFER, false, function thistype.SystemCameraTransitionCB)
	endmethod
	
	
	public method ToggleDefaultTracking takes nothing returns nothing
        local string message
		
		set DefaultCameraTracking[this] = not DefaultCameraTracking[this]
		
		if .GameMode == Teams_GAMEMODE_STANDARD or .GameMode == Teams_GAMEMODE_STANDARD_PAUSED then
			if DefaultCameraTracking[this] then
				set message = StringFormat1(LocalizeContent('UCTR', this.LanguageCode), ColorMessage(LocalizeContent('UCTT', this.LanguageCode), TOGGLE_ON_COLOR))
				
				if GetLocalPlayer() == Player(this) then
					//enable
					call SetCameraTargetController(MazersArray[this], 0, 0, false)
					
					call .DisplayMessage(message, 1.)
				endif
			else
				set message = StringFormat1(LocalizeContent('UCTR', this.LanguageCode), ColorMessage(LocalizeContent('UCTF', this.LanguageCode), TOGGLE_OFF_COLOR))
				
				if GetLocalPlayer() == Player(this) then
					//disable
					call ResetToGameCamera(0)
					call CameraSetupApply(DefaultCamera[this], false, false)
					
					call .DisplayMessage(message, 1.)
				endif
			endif
			
			if thistype.ToggleCameraTrackingTutorial != 0 then
				if DefaultCameraTracking[this] and not thistype.ToggleCameraTrackingTutorial.HasUserViewed(this) then
					call this.ShortcutCinematicQueue(thistype.ToggleCameraTrackingTutorial)
				endif
			endif
		endif
    endmethod
	
	public method PanCamera takes real x, real y, real duration returns nothing
		if .IsAFK then
			if GetLocalPlayer() == Player(this) then
				call SetCameraPosition(x, y)
			endif
			
			call .RegisterSystemCameraTransition(0.)
		else
			if GetLocalPlayer() == Player(this) then
				call PanCameraToTimed(x, y, duration)
			endif
			
			call .RegisterSystemCameraTransition(duration)
		endif
	endmethod
	public method ApplyCameraTracking takes nothing returns nothing
		if GetLocalPlayer() == Player(this) then
			if DefaultCameraTracking[this] then
				call SetCameraTargetController(.ActiveUnit, 0, 0, false)
			endif
		endif
	endmethod
    public method ApplyDefaultCameras takes real time returns nothing
        static if DEBUG_CAMERA then
			call DisplayTextToPlayer(Player(this), 0, 0, "Before apply, camera destination x: " + R2S(GetCameraTargetPositionX()) + ", y: " + R2S(GetCameraTargetPositionY()))
		endif
		
		if .GameMode == Teams_GAMEMODE_PLATFORMING or .GameMode == Teams_GAMEMODE_PLATFORMING_PAUSED then
            call .Platformer.ApplyCamera()
        elseif .GameMode == Teams_GAMEMODE_STANDARD or .GameMode == Teams_GAMEMODE_STANDARD_PAUSED then
            if GetLocalPlayer() == Player(this) then
				if time == 0 then
					call CameraSetupApply(DefaultCamera[this], false, false)
				else
					call CameraSetupApplyForceDuration(DefaultCamera[this], false, time)
				endif
            endif
				
			// if .IsAFK then
				// call SetCameraPosition(GetUnitX(.ActiveUnit), GetUnitY(.ActiveUnit))
			// else
				// call PanCameraToTimed(GetUnitX(.ActiveUnit), GetUnitY(.ActiveUnit), time)
			// endif
			call .PanCamera(GetUnitX(.ActiveUnit), GetUnitY(.ActiveUnit), time)
			
			call .ApplyCameraTracking()
        endif
		
		static if DEBUG_CAMERA then
			call DisplayTextToPlayer(Player(this), 0, 0, "After apply, camera destination x: " + R2S(GetCameraTargetPositionX()) + ", y: " + R2S(GetCameraTargetPositionY()))
		endif
    endmethod
	public method ResetDefaultCamera takes real duration returns nothing
        static if DEBUG_CAMERA then
			call DisplayTextToPlayer(Player(this), 0, 0, "Before reset, camera destination x: " + R2S(GetCameraTargetPositionX()) + ", y: " + R2S(GetCameraTargetPositionY()))
		endif
		
		if (GetLocalPlayer() == Player(this)) then
            call ResetToGameCamera(duration)
			
			if duration > 0 then
				// call CameraSetupApply(DefaultCamera[this], false, false)
				call CameraSetupApplyForceDuration(DefaultCamera[this], false, duration)
			else
				call CameraSetupApply(DefaultCamera[this], false, false)
			endif
        endif
		
		call .RegisterSystemCameraTransition(0.)
		
		static if DEBUG_CAMERA then
			call DisplayTextToPlayer(Player(this), 0, 0, "After reset, camera destination x: " + R2S(GetCameraTargetPositionX()) + ", y: " + R2S(GetCameraTargetPositionY()))
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
			elseif keyColor == KEY_NONE then
				call SetUnitVertexColor(MazersArray[this], 255, 255, 255, 255)
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
	
	public method ChangeDeathCount takes integer deaths returns nothing
		set .Deaths = .Deaths + deaths
		
		call .PartialUpdateMultiboard(MULTIBOARD_DEATHS)
	endmethod
	
	public method GetLocalizedPlayerName takes User localizer returns string
        local string hex = .GetPlayerColorHex()
        
        if GetPlayerSlotState(Player(this)) == PLAYER_SLOT_STATE_PLAYING then
			if .IsAFK then
				return ColorMessage("(" + StringCase(LocalizeContent('CAFK', localizer.LanguageCode), true) + ") ", DISABLED_COLOR) + ColorMessage(GetPlayerName(Player(this)), hex)
			else
				return ColorMessage(GetPlayerName(Player(this)), hex)
			endif
        else
			return ColorMessage(LocalizeContent('USLE', localizer.LanguageCode) + " " + GetPlayerName(Player(this)), hex)
        endif
    endmethod
	
	public method UpdateMultiboardTeamIcon takes nothing returns nothing
		local SimpleList_ListNode curTeamNode = Teams_MazingTeam.AllTeams.first
		local SimpleList_ListNode curUserNode
		
		local string iconPath
		
		// call DisplayTextToPlayer(Player(0), 0, 0, "Updating player icon for: " + I2S(this))
		
		if Teams_MazingTeam.IsTeamVersusTeam() then
			set iconPath = .Team.GetTeamColorIconPath()
			// call DisplayTextToPlayer(Player(0), 0, 0, "Team icon: " + iconPath)
			
			if iconPath != null then
				loop
				exitwhen curTeamNode == 0
					set curUserNode = Teams_MazingTeam(curTeamNode.value).Users.first
					
					loop
					exitwhen curUserNode == 0
						call MultiboardSetItemIcon(MultiboardGetItem(User(curUserNode.value).Statistics, this.StatisticsSortIndex, 0), iconPath)
						call MultiboardReleaseItem(MultiboardGetItem(User(curUserNode.value).Statistics, this.StatisticsSortIndex, 0))
					set curUserNode = curUserNode.next
					endloop
					
				set curTeamNode = curTeamNode.next
				endloop
			endif
		endif
	endmethod
	
	public method UpdateMultiboardPlayerName takes nothing returns nothing
		local SimpleList_ListNode curTeamNode = Teams_MazingTeam.AllTeams.first
		local SimpleList_ListNode curUserNode
		
		// call DisplayTextToPlayer(Player(0), 0, 0, "Updating player name for: " + I2S(this))
		
		loop
		exitwhen curTeamNode == 0
			set curUserNode = Teams_MazingTeam(curTeamNode.value).Users.first
			
			loop
			exitwhen curUserNode == 0
				if GetPlayerSlotState(Player(this)) == PLAYER_SLOT_STATE_PLAYING then
					// call DisplayTextToPlayer(Player(0), 0, 0, "Player slot marked playing")
					call MultiboardSetItemValue(MultiboardGetItem(User(curUserNode.value).Statistics, this.StatisticsSortIndex, 0 + Teams_MazingTeam.GetPlayerNameColumn()), this.GetLocalizedPlayerName(curUserNode.value))
				elseif GetPlayerSlotState(Player(this)) == PLAYER_SLOT_STATE_LEFT then
					// call DisplayTextToPlayer(Player(0), 0, 0, "Player slot marked left")
					call MultiboardSetItemValue(MultiboardGetItem(User(curUserNode.value).Statistics, this.StatisticsSortIndex, 0 + Teams_MazingTeam.GetPlayerNameColumn()), LocalizeContent('UMLG', User(curUserNode.value).LanguageCode))
				else
					// call DisplayTextToPlayer(Player(0), 0, 0, "Player slot marked not playing")
					call MultiboardSetItemValue(MultiboardGetItem(User(curUserNode.value).Statistics, this.StatisticsSortIndex, 0 + Teams_MazingTeam.GetPlayerNameColumn()), LocalizeContent('UMNP', User(curUserNode.value).LanguageCode))
				endif
				
				call MultiboardReleaseItem(MultiboardGetItem(User(curUserNode.value).Statistics, this.StatisticsSortIndex, 0 + Teams_MazingTeam.GetPlayerNameColumn()))
			set curUserNode = curUserNode.next
			endloop
			
		set curTeamNode = curTeamNode.next
		endloop
	endmethod
	public method UpdateMultiboardPlayerIcon takes nothing returns nothing
		local SimpleList_ListNode curTeamNode = Teams_MazingTeam.AllTeams.first
		local SimpleList_ListNode curUserNode
		
		local string iconPath = null
		
		if this.GameMode == Teams_GAMEMODE_STANDARD_PAUSED or this.GameMode == Teams_GAMEMODE_STANDARD then
			set iconPath = "ReplaceableTextures\\CommandButtons\\BTNHeroDemonHunter.tga"
		elseif this.GameMode == Teams_GAMEMODE_PLATFORMING_PAUSED or this.GameMode == Teams_GAMEMODE_PLATFORMING then
			set iconPath = "ReplaceableTextures\\CommandButtons\\BTNWisp.tga"
		elseif this.GameMode == Teams_GAMEMODE_DEAD then
			set iconPath = "ReplaceableTextures\\CommandButtons\\BTNAnimateDead.tga"
		endif
		
		// call DisplayTextToPlayer(Player(0), 0, 0, "Updating player icon for: " + I2S(this))
		
		if iconPath != null then
			loop
			exitwhen curTeamNode == 0
				set curUserNode = Teams_MazingTeam(curTeamNode.value).Users.first
				
				loop
				exitwhen curUserNode == 0
					call MultiboardSetItemIcon(MultiboardGetItem(User(curUserNode.value).Statistics, this.StatisticsSortIndex, 0 + Teams_MazingTeam.GetPlayerNameColumn()), iconPath)
					call MultiboardReleaseItem(MultiboardGetItem(User(curUserNode.value).Statistics, this.StatisticsSortIndex, 0 + Teams_MazingTeam.GetPlayerNameColumn()))
				set curUserNode = curUserNode.next
				endloop
				
			set curTeamNode = curTeamNode.next
			endloop
		endif
	endmethod
	
	public method UpdateMultiboardLevelName takes nothing returns nothing
		local SimpleList_ListNode curTeamNode = Teams_MazingTeam.AllTeams.first
		local SimpleList_ListNode curUserNode
		
		loop
		exitwhen curTeamNode == 0
			set curUserNode = Teams_MazingTeam(curTeamNode.value).Users.first
			
			loop
			exitwhen curUserNode == 0
				if GetPlayerSlotState(Player(this)) == PLAYER_SLOT_STATE_PLAYING then
					call MultiboardSetItemValue(MultiboardGetItem(User(curUserNode.value).Statistics, this.StatisticsSortIndex, 1 + Teams_MazingTeam.GetPlayerNameColumn()), this.Team.OnLevel.GetLocalizedLevelName(curUserNode.value))
					call MultiboardReleaseItem(MultiboardGetItem(User(curUserNode.value).Statistics, this.StatisticsSortIndex, 1 + Teams_MazingTeam.GetPlayerNameColumn()))
				elseif GetPlayerSlotState(Player(this)) == PLAYER_SLOT_STATE_LEFT then
					call MultiboardSetItemValue(MultiboardGetItem(User(curUserNode.value).Statistics, this.StatisticsSortIndex, 1 + Teams_MazingTeam.GetPlayerNameColumn()), LocalizeContent('UMGN', User(curUserNode.value).LanguageCode))
					call MultiboardReleaseItem(MultiboardGetItem(User(curUserNode.value).Statistics, this.StatisticsSortIndex, 1 + Teams_MazingTeam.GetPlayerNameColumn()))
				endif
			set curUserNode = curUserNode.next
			endloop
			
		set curTeamNode = curTeamNode.next
		endloop
	endmethod
	public method UpdateMultiboardLevelIcon takes nothing returns nothing
		local SimpleList_ListNode curTeamNode = Teams_MazingTeam.AllTeams.first
		local SimpleList_ListNode curUserNode
		
		local integer worldID
		local string iconPath = null
		
		if this.Team.OnLevel == INTRO_LEVEL_ID or this.Team.OnLevel == DOORS_LEVEL_ID then
			set iconPath = "ReplaceableTextures\\CommandButtons\\BTNDemonGate.blp"
		else
			set worldID = this.Team.OnLevel.GetWorldID()
			
			if worldID == 1 then
				//hard ice
				set iconPath = "ReplaceableTextures\\CommandButtons\\BTNGlacier.tga"
			elseif worldID == 2 then
				//easy ice
				set iconPath = "ReplaceableTextures\\CommandButtons\\BTNGlacier.tga"
			elseif worldID == 3 then
				//landlubber
				set iconPath = "ReplaceableTextures\\PassiveButtons\\PASBTNCommand.tga"
			elseif worldID == 6 then
				//four seasons
				set iconPath = "ReplaceableTextures\\CommandButtons\\BTNStormEarth&Fire.tga"
			elseif worldID == 7 then
				//platforming
				set iconPath = "ReplaceableTextures\\PassiveButtons\\PASBTNScatterRockets.tga"
			endif
		endif
		
		// call DisplayTextToPlayer(Player(0), 0, 0, "Updating player icon for: " + I2S(this))
		
		if iconPath != null then
			loop
			exitwhen curTeamNode == 0
				set curUserNode = Teams_MazingTeam(curTeamNode.value).Users.first
				
				loop
				exitwhen curUserNode == 0
					call MultiboardSetItemIcon(MultiboardGetItem(User(curUserNode.value).Statistics, this.StatisticsSortIndex, 1 + Teams_MazingTeam.GetPlayerNameColumn()), iconPath)
					call MultiboardReleaseItem(MultiboardGetItem(User(curUserNode.value).Statistics, this.StatisticsSortIndex, 1 + Teams_MazingTeam.GetPlayerNameColumn()))
				set curUserNode = curUserNode.next
				endloop
				
			set curTeamNode = curTeamNode.next
			endloop
		endif
	endmethod
	
	public method UpdateMultiboardScore takes nothing returns nothing
		local SimpleList_ListNode curTeamNode = Teams_MazingTeam.AllTeams.first
		local SimpleList_ListNode curUserNode
		
		loop
		exitwhen curTeamNode == 0
			set curUserNode = Teams_MazingTeam(curTeamNode.value).Users.first
			
			loop
			exitwhen curUserNode == 0
				if GetPlayerSlotState(Player(this)) == PLAYER_SLOT_STATE_PLAYING then
					call MultiboardSetItemValue(MultiboardGetItem(User(curUserNode.value).Statistics, this.StatisticsSortIndex, 2 + Teams_MazingTeam.GetPlayerNameColumn()), I2S(.Team.GetScore()))
					call MultiboardReleaseItem(MultiboardGetItem(User(curUserNode.value).Statistics, this.StatisticsSortIndex, 2 + Teams_MazingTeam.GetPlayerNameColumn()))
				elseif GetPlayerSlotState(Player(this)) == PLAYER_SLOT_STATE_LEFT then
					call MultiboardSetItemValue(MultiboardGetItem(User(curUserNode.value).Statistics, this.StatisticsSortIndex, 2 + Teams_MazingTeam.GetPlayerNameColumn()), LocalizeContent('UMNE', User(curUserNode.value).LanguageCode))
					call MultiboardReleaseItem(MultiboardGetItem(User(curUserNode.value).Statistics, this.StatisticsSortIndex, 2 + Teams_MazingTeam.GetPlayerNameColumn()))
				endif
			set curUserNode = curUserNode.next
			endloop
			
		set curTeamNode = curTeamNode.next
		endloop
	endmethod
	public method UpdateMultiboardContinues takes nothing returns nothing
		local SimpleList_ListNode curTeamNode = Teams_MazingTeam.AllTeams.first
		local SimpleList_ListNode curUserNode
		
		loop
		exitwhen curTeamNode == 0
			set curUserNode = Teams_MazingTeam(curTeamNode.value).Users.first
			
			loop
			exitwhen curUserNode == 0
				if GetPlayerSlotState(Player(this)) == PLAYER_SLOT_STATE_PLAYING then
					call MultiboardSetItemValue(MultiboardGetItem(User(curUserNode.value).Statistics, this.StatisticsSortIndex, 3 + Teams_MazingTeam.GetPlayerNameColumn()), I2S(.Team.GetContinueCount()))
					call MultiboardReleaseItem(MultiboardGetItem(User(curUserNode.value).Statistics, this.StatisticsSortIndex, 3 + Teams_MazingTeam.GetPlayerNameColumn()))
				elseif GetPlayerSlotState(Player(this)) == PLAYER_SLOT_STATE_LEFT then
					call MultiboardSetItemValue(MultiboardGetItem(User(curUserNode.value).Statistics, this.StatisticsSortIndex, 3 + Teams_MazingTeam.GetPlayerNameColumn()), LocalizeContent('UMZE', User(curUserNode.value).LanguageCode))
					call MultiboardReleaseItem(MultiboardGetItem(User(curUserNode.value).Statistics, this.StatisticsSortIndex, 3 + Teams_MazingTeam.GetPlayerNameColumn()))
				endif
			set curUserNode = curUserNode.next
			endloop
			
		set curTeamNode = curTeamNode.next
		endloop
	endmethod
	public method UpdateMultiboardDeaths takes nothing returns nothing
		local SimpleList_ListNode curTeamNode = Teams_MazingTeam.AllTeams.first
		local SimpleList_ListNode curUserNode
		
		loop
		exitwhen curTeamNode == 0
			set curUserNode = Teams_MazingTeam(curTeamNode.value).Users.first
			
			loop
			exitwhen curUserNode == 0
				if RewardMode == GameModesGlobals_HARD then
					if GetPlayerSlotState(Player(this)) == PLAYER_SLOT_STATE_PLAYING then
						call MultiboardSetItemValue(MultiboardGetItem(User(curUserNode.value).Statistics, this.StatisticsSortIndex, 4 + Teams_MazingTeam.GetPlayerNameColumn()), I2S(.Deaths))
						call MultiboardReleaseItem(MultiboardGetItem(User(curUserNode.value).Statistics, this.StatisticsSortIndex, 4 + Teams_MazingTeam.GetPlayerNameColumn()))
					elseif GetPlayerSlotState(Player(this)) == PLAYER_SLOT_STATE_LEFT then
						call MultiboardSetItemValue(MultiboardGetItem(User(curUserNode.value).Statistics, this.StatisticsSortIndex, 4 + Teams_MazingTeam.GetPlayerNameColumn()), LocalizeContent('UMTM', User(curUserNode.value).LanguageCode))
						call MultiboardReleaseItem(MultiboardGetItem(User(curUserNode.value).Statistics, this.StatisticsSortIndex, 4 + Teams_MazingTeam.GetPlayerNameColumn()))
					endif
				endif
			set curUserNode = curUserNode.next
			endloop
			
		set curTeamNode = curTeamNode.next
		endloop
	endmethod
	
    public method PartialUpdateMultiboard takes integer columnID returns nothing
		if columnID == MULTIBOARD_PLAYERNAME then
			call .UpdateMultiboardPlayerName()
		elseif columnID == MULTIBOARD_LEVELNAME then
			call .UpdateMultiboardLevelName()
		elseif columnID == MULTIBOARD_SCORE then
			call .UpdateMultiboardScore()
		elseif columnID == MULTIBOARD_CONTINUES then
			call .UpdateMultiboardContinues()
		elseif columnID == MULTIBOARD_DEATHS then
			call .UpdateMultiboardDeaths()
		endif
    endmethod
	//will desync if called by more than one localization in a single execution stack
	public method UpdateMultiboard takes nothing returns nothing
		call .UpdateMultiboardTeamIcon()
		// call DisplayTextToPlayer(Player(0), 0, 0, "Update MB for user: " + I2S(this))
		call .UpdateMultiboardPlayerName()
		call .UpdateMultiboardPlayerIcon()
		// call DisplayTextToPlayer(Player(0), 0, 0, "Update MB 1")
		call .UpdateMultiboardLevelName()
		call .UpdateMultiboardLevelIcon()
		// call DisplayTextToPlayer(Player(0), 0, 0, "Update MB 2")
		call .UpdateMultiboardScore()
		call .UpdateMultiboardContinues()
		call .UpdateMultiboardDeaths()
		// call DisplayTextToPlayer(Player(0), 0, 0, "Update MB 3")
	endmethod
	
	public method MinimizeMultiboard takes boolean flag returns nothing
		if GetLocalPlayer() == Player(this) then
			call MultiboardMinimize(.Statistics, flag)
		endif
	endmethod
	public method DisplayMultiboard takes boolean flag returns nothing
		if GetLocalPlayer() == Player(this) then
			call MultiboardDisplay(.Statistics, flag)
		endif
	endmethod
	
	public method InitializeMultiboardDisplay takes nothing returns nothing
		if GetLocalPlayer() == Player(this) then
			call MultiboardDisplay(.Statistics, false)
			call MultiboardDisplay(.Statistics, true)
			call MultiboardMinimize(.Statistics, true)
			call MultiboardMinimize(.Statistics, false)
		// else
			// call MultiboardDisplay(.Statistics, false)
		endif
	endmethod
	
	public method InitializeMultiboardIcons takes nothing returns nothing
		local SimpleList_ListNode curTeamNode = Teams_MazingTeam.AllTeams.first
		local SimpleList_ListNode curUserNode
		
		loop
		exitwhen curTeamNode == 0
			set curUserNode = Teams_MazingTeam(curTeamNode.value).Users.first
			
			loop
			exitwhen curUserNode == 0
				if Teams_MazingTeam.IsTeamVersusTeam() then
					call MultiboardSetItemWidth(MultiboardGetItem(User(curUserNode.value).Statistics, this.StatisticsSortIndex, 0), .015)
					call MultiboardReleaseItem(MultiboardGetItem(User(curUserNode.value).Statistics, this.StatisticsSortIndex, 0))
				endif
				
				call MultiboardSetItemIcon(MultiboardGetItem(User(curUserNode.value).Statistics, this.StatisticsSortIndex, 0 + Teams_MazingTeam.GetPlayerNameColumn()), "ReplaceableTextures\\CommandButtons\\BTNPeasant.blp")
				call MultiboardReleaseItem(MultiboardGetItem(User(curUserNode.value).Statistics, this.StatisticsSortIndex, 0 + Teams_MazingTeam.GetPlayerNameColumn()))
				
				call MultiboardSetItemIcon(MultiboardGetItem(User(curUserNode.value).Statistics, this.StatisticsSortIndex, 1 + Teams_MazingTeam.GetPlayerNameColumn()), "ReplaceableTextures\\CommandButtons\\BTNDemonGate.blp")
				call MultiboardReleaseItem(MultiboardGetItem(User(curUserNode.value).Statistics, this.StatisticsSortIndex, 1 + Teams_MazingTeam.GetPlayerNameColumn()))
				
				call MultiboardSetItemIcon(MultiboardGetItem(User(curUserNode.value).Statistics, this.StatisticsSortIndex, 2 + Teams_MazingTeam.GetPlayerNameColumn()), "ReplaceableTextures\\CommandButtons\\BTNGlyph.blp")
				call MultiboardReleaseItem(MultiboardGetItem(User(curUserNode.value).Statistics, this.StatisticsSortIndex, 2 + Teams_MazingTeam.GetPlayerNameColumn()))
				
				call MultiboardSetItemIcon(MultiboardGetItem(User(curUserNode.value).Statistics, this.StatisticsSortIndex, 3 + Teams_MazingTeam.GetPlayerNameColumn()), "ReplaceableTextures\\CommandButtons\\BTNSkillz.tga")
				call MultiboardReleaseItem(MultiboardGetItem(User(curUserNode.value).Statistics, this.StatisticsSortIndex, 3 + Teams_MazingTeam.GetPlayerNameColumn()))
				
				if RewardMode == GameModesGlobals_HARD then
					call MultiboardSetItemIcon(MultiboardGetItem(User(curUserNode.value).Statistics, this.StatisticsSortIndex, 4 + Teams_MazingTeam.GetPlayerNameColumn()), "ReplaceableTextures\\CommandButtons\\BTNAnkh.blp")
					call MultiboardReleaseItem(MultiboardGetItem(User(curUserNode.value).Statistics, this.StatisticsSortIndex, 4 + Teams_MazingTeam.GetPlayerNameColumn()))
				endif
			set curUserNode = curUserNode.next
			endloop
			
		set curTeamNode = curTeamNode.next
		endloop
	endmethod
	
	public method LocalizeMultiboard takes nothing returns nothing
		local SimpleList_ListNode curTeamNode = Teams_MazingTeam.AllTeams.first
		local SimpleList_ListNode curUserNode
		
		local integer playerNameColumn = Teams_MazingTeam.GetPlayerNameColumn()
		
		//init localized column text for multiboard
		call MultiboardSetTitleText(.Statistics, LocalizeContent('UMPS', .LanguageCode))
		
		call MultiboardSetItemValue(MultiboardGetItem(.Statistics, 0, 0 + playerNameColumn), LocalizeContent('UMPN', .LanguageCode))
		call MultiboardSetItemValue(MultiboardGetItem(.Statistics, 0, 1 + playerNameColumn), LocalizeContent('UMOL', .LanguageCode))
		call MultiboardSetItemValue(MultiboardGetItem(.Statistics, 0, 2 + playerNameColumn), LocalizeContent('UMSC', .LanguageCode))
		call MultiboardSetItemValue(MultiboardGetItem(.Statistics, 0, 3 + playerNameColumn), LocalizeContent('UMCC', .LanguageCode))
		if RewardMode == GameModesGlobals_HARD then
			call MultiboardSetItemValue(MultiboardGetItem(.Statistics, 0, 4 + playerNameColumn), LocalizeContent('UMDC', .LanguageCode))
		endif
		
		//release columns
		call MultiboardReleaseItem(MultiboardGetItem(.Statistics, 0, 0 + playerNameColumn))
        call MultiboardReleaseItem(MultiboardGetItem(.Statistics, 0, 1 + playerNameColumn))
        call MultiboardReleaseItem(MultiboardGetItem(.Statistics, 0, 2 + playerNameColumn))
        call MultiboardReleaseItem(MultiboardGetItem(.Statistics, 0, 3 + playerNameColumn))
		if RewardMode == GameModesGlobals_HARD then
			call MultiboardReleaseItem(MultiboardGetItem(.Statistics, 0, 4 + playerNameColumn))
		endif
		
		//iterate rows
		loop
		exitwhen curTeamNode == 0
			set curUserNode = Teams_MazingTeam(curTeamNode.value).Users.first
			
			loop
			exitwhen curUserNode == 0				
				if GetPlayerSlotState(Player(this)) == PLAYER_SLOT_STATE_PLAYING then
					call MultiboardSetItemValue(MultiboardGetItem(this.Statistics, User(curUserNode.value).StatisticsSortIndex, 0 + playerNameColumn), User(curUserNode.value).GetLocalizedPlayerName(this))
				elseif GetPlayerSlotState(Player(this)) == PLAYER_SLOT_STATE_LEFT then
					call MultiboardSetItemValue(MultiboardGetItem(this.Statistics, User(curUserNode.value).StatisticsSortIndex, 0 + playerNameColumn), LocalizeContent('UMLG', User(this).LanguageCode))
				else
					call MultiboardSetItemValue(MultiboardGetItem(this.Statistics, User(curUserNode.value).StatisticsSortIndex, 0 + playerNameColumn), LocalizeContent('UMNP', User(this).LanguageCode))
				endif
				call MultiboardReleaseItem(MultiboardGetItem(this.Statistics, User(curUserNode.value).StatisticsSortIndex, 0 + playerNameColumn))
				
				if GetPlayerSlotState(Player(this)) == PLAYER_SLOT_STATE_PLAYING then
					call MultiboardSetItemValue(MultiboardGetItem(this.Statistics, User(curUserNode.value).StatisticsSortIndex, 1 + playerNameColumn), User(curUserNode.value).Team.OnLevel.GetLocalizedLevelName(this))
					call MultiboardReleaseItem(MultiboardGetItem(this.Statistics, User(curUserNode.value).StatisticsSortIndex, 1 + playerNameColumn))
				elseif GetPlayerSlotState(Player(this)) == PLAYER_SLOT_STATE_LEFT then
					call MultiboardSetItemValue(MultiboardGetItem(this.Statistics, User(curUserNode.value).StatisticsSortIndex, 1 + playerNameColumn), LocalizeContent('UMGN', this.LanguageCode))
					call MultiboardReleaseItem(MultiboardGetItem(this.Statistics, User(curUserNode.value).StatisticsSortIndex, 1 + playerNameColumn))
				endif
			set curUserNode = curUserNode.next
			endloop
			
		set curTeamNode = curTeamNode.next
		endloop
	endmethod
	
	public method InitializeMultiboard takes nothing returns nothing
		local integer i = 0
		local integer columnCount = 4
		local integer playerNameColumn = Teams_MazingTeam.GetPlayerNameColumn()
        
        set .Statistics = CreateMultiboard()
        
        call MultiboardSetRowCount(.Statistics, thistype.OriginalPlayerCount + 1)
        // call MultiboardSetTitleText(.Statistics, "Player Stats")
        call MultiboardDisplay(.Statistics, true)
        call MultiboardSetItemsWidth(.Statistics, .1)
		
		if RewardMode == GameModesGlobals_HARD then
			set columnCount = columnCount + 1
        endif
		
		if Teams_MazingTeam.IsTeamVersusTeam() then
			set columnCount = columnCount + 1
		endif
		
		call MultiboardSetColumnCount(.Statistics, columnCount)
        
		if Teams_MazingTeam.IsTeamVersusTeam() then
			// call MultiboardSetItemIcon(MultiboardGetItem(.Statistics, 0, 0), "war3mapImported\\PC_Rainbow.tga")
			// call MultiboardSetItemValue(MultiboardGetItem(.Statistics, 0, 0), LocalizeContent('UMTN', .LanguageCode))
			// call MultiboardSetItemValue(MultiboardGetItem(.Statistics, 0, 0), "Team")
			call MultiboardSetItemStyle(MultiboardGetItem(.Statistics, 0, 0), false, false)
			call MultiboardSetItemWidth(MultiboardGetItem(.Statistics, 0, 0), .015)
			
			call MultiboardReleaseItem(MultiboardGetItem(.Statistics, 0, 0))
		endif
		
		//initialize multiboard column
        call MultiboardSetItemIcon(MultiboardGetItem(.Statistics, 0, 0 + playerNameColumn), "ReplaceableTextures\\CommandButtons\\BTNPeasant.blp")
        call MultiboardSetItemIcon(MultiboardGetItem(.Statistics, 0, 1 + playerNameColumn), "ReplaceableTextures\\CommandButtons\\BTNSpy.tga")
        call MultiboardSetItemIcon(MultiboardGetItem(.Statistics, 0, 2 + playerNameColumn), "ReplaceableTextures\\CommandButtons\\BTNGlyph.blp")
        call MultiboardSetItemIcon(MultiboardGetItem(.Statistics, 0, 3 + playerNameColumn), "ReplaceableTextures\\CommandButtons\\BTNSkillz.tga")
		if RewardMode == GameModesGlobals_HARD then
			call MultiboardSetItemIcon(MultiboardGetItem(.Statistics, 0, 4 + playerNameColumn), "ReplaceableTextures\\CommandButtons\\BTNAnkh.blp")
		endif
		
		//init localized column text for multiboard
		call MultiboardSetTitleText(.Statistics, LocalizeContent('UMPS', .LanguageCode))
		
		call MultiboardSetItemValue(MultiboardGetItem(.Statistics, 0, 0 + playerNameColumn), LocalizeContent('UMPN', .LanguageCode))
		call MultiboardSetItemValue(MultiboardGetItem(.Statistics, 0, 1 + playerNameColumn), LocalizeContent('UMOL', .LanguageCode))
		call MultiboardSetItemValue(MultiboardGetItem(.Statistics, 0, 2 + playerNameColumn), LocalizeContent('UMSC', .LanguageCode))
		call MultiboardSetItemValue(MultiboardGetItem(.Statistics, 0, 3 + playerNameColumn), LocalizeContent('UMCC', .LanguageCode))
		if RewardMode == GameModesGlobals_HARD then
			call MultiboardSetItemValue(MultiboardGetItem(.Statistics, 0, 4 + playerNameColumn), LocalizeContent('UMDC', .LanguageCode))
		endif
		
		//release columns
		call MultiboardReleaseItem(MultiboardGetItem(.Statistics, 0, 0 + playerNameColumn))
        call MultiboardReleaseItem(MultiboardGetItem(.Statistics, 0, 1 + playerNameColumn))
        call MultiboardReleaseItem(MultiboardGetItem(.Statistics, 0, 2 + playerNameColumn))
        call MultiboardReleaseItem(MultiboardGetItem(.Statistics, 0, 3 + playerNameColumn))
		if RewardMode == GameModesGlobals_HARD then
			call MultiboardReleaseItem(MultiboardGetItem(.Statistics, 0, 4 + playerNameColumn))
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
		call this.ResetDefaultCamera(1.)
        
        //check if respawn circles should be used
        if not RespawnASAPMode and .IsPlaying then
            //figure out the coordinates for respawn point given the previous game mode and other info
            set respawnPoint = TerrainHelpers_TryGetLastValidLocation(x, y, facing, oldGameMode)
            
            //move respawn circle to point
            call SetUnitPosition(PlayerReviveCircles[this], respawnPoint.x, respawnPoint.y)
            call ShowUnit(PlayerReviveCircles[this], true)
            
            call respawnPoint.destroy()
        endif
		
		// call DisplayTextToPlayer(Player(this), 0, 0, "Death mode updating AFK await state")
		call .Team.UpdateAwaitingAFKState()
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
                call SetUnitPosition(MazersArray[this], SAFE_X, SAFE_Y)
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
					call SetUnitPosition(MazersArray[this], SAFE_X, SAFE_Y)
                endif
            elseif curGameMode == Teams_GAMEMODE_PLATFORMING_PAUSED then
                //if the new gamemode isnt to unpause the unit then we need to undo the pause effect
                if newGameMode != Teams_GAMEMODE_PLATFORMING then
                    call ShowUnit(.Platformer.Unit, false)
					call SetUnitPosition(.Platformer.Unit, SAFE_X, SAFE_Y)
                endif
            elseif curGameMode == Teams_GAMEMODE_DYING then
				//no actions removing dying gamemode
            elseif curGameMode == Teams_GAMEMODE_DEAD then
                //revive the mazing unit
                call ReviveHero(MazersArray[this], x, y, false)
                call ShowUnit(MazersArray[this], false)
                call IssueImmediateOrder(MazersArray[this], "stop")
                //call PauseUnit(MazersArray[this], true)
                //call PauseUnit(MazersArray[this], false)
                
                //move the respawn circle
                call ShowUnit(PlayerReviveCircles[this], false)
				call SetUnitPosition(PlayerReviveCircles[this], REVIVE_CIRCLE_SAFE_X, REVIVE_CIRCLE_SAFE_Y)
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
						
			call .UpdateMultiboardPlayerIcon()
        endif
    endmethod
    
    public method IsActiveUnitInRect takes rect r returns boolean
        return GetUnitX(.ActiveUnit) >= GetRectMinX(r) and GetUnitX(.ActiveUnit) <= GetRectMaxX(r) and GetUnitY(.ActiveUnit) >= GetRectMinY(r) and GetUnitY(.ActiveUnit) <= GetRectMaxY(r)
    endmethod
    public method IsActiveUnitInArea takes vector2 topLeft, vector2 botRight returns boolean
        return GetUnitX(.ActiveUnit) >= topLeft.x and GetUnitX(.ActiveUnit) <= botRight.x and GetUnitY(.ActiveUnit) >= botRight.y and GetUnitY(.ActiveUnit) <= topLeft.y
    endmethod
	
	private static method AfterCollisionCB takes nothing returns nothing
		local User user = GetTimerData(GetExpiredTimer())
		
		set user.LastCollidedUnit = null
	endmethod
	public method InitializeAfterCollisionCB takes unit cu, real timeout returns nothing
		//cancel the last collision CB (checks if timer is actually active under the hood - or at least doesn't error)
		call PauseTimer(this.LastCollidedUnitTimer)
		
		//start a new collision CB
		set this.LastCollidedUnit = cu
		call TimerStart(this.LastCollidedUnitTimer, timeout, false, function thistype.AfterCollisionCB)
	endmethod
	
	private static method UnpauseAFKCB takes nothing returns nothing
		local timer t = GetExpiredTimer()
		local User u = GetTimerData(t)
		local texttag text
		local string message
		local SimpleList_ListNode curUserNode = PlayerUtils_FirstPlayer
		
		if u.AFKPlatformerDeathClock == AFK_UNPAUSE_BUFFER then
			set text = CreateTextTag()
			
			loop
			exitwhen curUserNode == 0
				set message = StringFormat1(LocalizeContent('UAIN', User(curUserNode.value).LanguageCode), ColorMessage(LocalizeContent('UAUN', User(curUserNode.value).LanguageCode), u.GetPlayerColorHex()))
				
				if GetLocalPlayer() == Player(curUserNode.value) then
					call SetTextTagText(text, message, SMALL_FONT_SIZE)
				endif
			set curUserNode = curUserNode.next
			endloop
			
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
	
	private static method OnUnapplyAFKStandard takes SyncRequest request, User user returns integer
		// local boolean needsPause = S2B(request.RequestData)
		local string message
		
		//only pause, pan camera, and set immunity if the User says they need it (via request.RequestData)
		if S2B(request.RequestData) then
			set user.AFKPlatformerDeathClock = AFK_UNPAUSE_BUFFER
			call user.Pause(true)
			call user.ApplyDefaultCameras(AFK_PAN_CAMERA_DURATION)
			call user.ApplyDefaultSelections()
			
			call TimerStart(NewTimerEx(user), AFK_PAN_CAMERA_DURATION, false, function thistype.PanAFKCameraCB)
			
			set message = StringFormat1(LocalizeContent('UAAF', user.LanguageCode), user.GetLocalizedPlayerName(user))
			
			if GetLocalPlayer() == Player(user) then
				call user.DisplayMessage(message, 0)
			endif
		endif
		
		call request.destroy()
		
		return 0
	endmethod
	
	private static method ApplyAFKPlatformerCB takes nothing returns nothing
		local User u = GetTimerData(GetExpiredTimer())
		local texttag text
		local string message
		local SimpleList_ListNode curUserNode = PlayerUtils_FirstPlayer
		
		// call DisplayTextToPlayer(Player(u), 0, 0, "applying afk platformer")
		
		if u.IsAFK and u.IsAlive then
			if u.PlatformerStartStable then
				if u.AFKPlatformerDeathClock == AFK_PLATFORMER_DEATH_CLOCK_START then
					set text = CreateTextTag()
					
					loop
					exitwhen curUserNode == 0
						set message = StringFormat1(LocalizeContent('UAIN', User(curUserNode.value).LanguageCode), ColorMessage(LocalizeContent('UADE', User(curUserNode.value).LanguageCode), u.GetPlayerColorHex()))
						
						if GetLocalPlayer() == Player(curUserNode.value) then
							call SetTextTagText(text, message, SMALL_FONT_SIZE)
						endif
					set curUserNode = curUserNode.next
					endloop
					
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
					
					// call ReleaseTimer(t)
					call PauseTimer(u.AFKPlatformerDeathTimer)
				endif
			endif
		else
			//no longer AFK, immediately desist
			// call ReleaseTimer(t)
			call PauseTimer(u.AFKPlatformerDeathTimer)
		endif		
	endmethod
	public method ApplyAFKPlatformer takes nothing returns nothing	
		//no way to support sharing control via keyboard actions
		//show texttag countdown before killing
		set .AFKPlatformerDeathClock = AFK_PLATFORMER_DEATH_CLOCK_START
		call TimerStart(.AFKPlatformerDeathTimer, AFK_PLATFORMER_CLOCK, true, function thistype.ApplyAFKPlatformerCB)
	endmethod
	
	public method ApplyAwaitingAFKState takes nothing returns nothing
		if .GameMode == Teams_GAMEMODE_STANDARD or .GameMode == Teams_GAMEMODE_STANDARD_PAUSED then
			call .Team.SetSharedControlForTeam(this, true)
			
			//disable default camera tracking so as to not interact with shared control
			if DefaultCameraTracking[this] then
				call .ToggleDefaultTracking()
			endif
		elseif .GameMode == Teams_GAMEMODE_PLATFORMING or .GameMode == Teams_GAMEMODE_PLATFORMING_PAUSED then
			call .ApplyAFKPlatformer()
		endif
		
		if GetLocalPlayer() == Player(this) and AFK_CAMERA_DELTA_TIMEOUT * thistype.LocalAFKThreshold >= AFK_CAMERA_MIN_TIMEOUT then
			set thistype.LocalAFKThreshold = AFK_CAMERA_DELTA_TIMEOUT * thistype.LocalAFKThreshold
			
			//TODO sync callback for user's threshold
			//if first threshold then warn player about exiling
			//if second threshold then inform team about exiling
		endif
	endmethod
	
	//User AFK synced event callback and async logic for checking/tracking idle state
	public method SetAFK takes boolean flag returns nothing
		local SimpleList_ListNode curUserNode
		local string message
		
		local SyncRequest request
		local real x
		local real y
		
		if .IsAFK != flag then
			set curUserNode = this.Team.FirstUser
			
			//this could be more elegant, but applying this logic first lets GetLocalizedPlayerName stay simplish by not including the localized "(AFK) " prefix in the player's name
			if flag then
				if DEBUG_AFK or .Team.Users.count > 1 then
					loop
					exitwhen curUserNode == 0
						// call .Team.PrintMessage(.GetStylizedPlayerName() + " " + "is now AFK!")
						set message = StringFormat1(LocalizeContent('UAAT', User(curUserNode.value).LanguageCode), .GetLocalizedPlayerName(curUserNode.value))
						
						if GetLocalPlayer() == Player(curUserNode.value) then
							call User(curUserNode.value).DisplayMessage(message, 0)
						endif
					set curUserNode = curUserNode.next
					endloop
				endif
			endif
			
			set .IsAFK = flag
			
			//any change in .IsAFK should trigger a check on overall team AFK state
			call .Team.UpdateAwaitingAFKState()
			
			if flag then
				if GetLocalPlayer() == Player(this) then 
					set thistype.LocalCameraIdleTime = thistype.LocalAFKThreshold
				endif
			else
				if DEBUG_AFK or .Team.Users.count > 1 then
					loop
					exitwhen curUserNode == 0
						if this != curUserNode.value then
							// call .Team.PrintMessage(.GetStylizedPlayerName() + " " + "is no longer AFK")
							set message = StringFormat1(LocalizeContent('UAAF', User(curUserNode.value).LanguageCode), .GetLocalizedPlayerName(curUserNode.value))
							
							if GetLocalPlayer() == Player(curUserNode.value) then
								call User(curUserNode.value).DisplayMessage(message, 0)
							endif
						endif
					set curUserNode = curUserNode.next
					endloop
					
					call .Team.SetSharedControlForTeam(this, false)
					
					if .GameMode == Teams_GAMEMODE_STANDARD then
						//when a standard mazer is unpaused it always causes a pause in flow while the unit is literally paused, the camera panned to it, and then the unpause countdown fully executed
						//it's better for gameplay if the unit is paused and then unpaused (with no camera pan or a much faster pan)
						//check that unit is not near owner's camera bounds as well
						
						//this is saying only go through with removing AFK status if the user's active unit is far from its original position
						//checking this here requires an additional sync, is there ANY reason not to just check this during the original toggle? yes, to set .IsAFK first, then decide to do something about it second
						
						set request = SyncRequest.create(OnUnapplyAFKStandard, this)
						
						if GetLocalPlayer() == Player(this) then
							set x = GetCameraTargetPositionX() - GetUnitX(.ActiveUnit)
							set x = x*x
							
							set y = GetCameraTargetPositionY() - GetUnitY(.ActiveUnit)
							set y = y*y
							
							//check that the user's camera is a specified distance away from their active unit, and that they've been AFK for at least a specified time
							call request.Sync(B2S((SquareRoot(x + y) >= CAMERA_TARGET_POSITION_UNPAUSE_TRANSITION_THRESHOLD) and (thistype.LocalCameraIdleTime - thistype.LocalAFKThreshold >= AFK_TIMER_UNPAUSE_TRANSITION_THRESHOLD)))
							
							// call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Unpause AFK, pt 1: " + B2S(RAbsBJ(GetCameraTargetPositionX() - GetUnitX(.ActiveUnit)) >= CAMERA_TARGET_POSITION_PAUSE_X_FLEX) + ", pt 2: " + B2S(GetCameraTargetPositionY() >= GetUnitY(.ActiveUnit) and GetCameraTargetPositionY() - GetUnitY(.ActiveUnit) >= CAMERA_TARGET_POSITION_PAUSE_Y_BOTTOM_FLEX) + ", pt 3: " + B2S(GetCameraTargetPositionY() < GetUnitY(.ActiveUnit) and GetUnitY(.ActiveUnit) - GetCameraTargetPositionY()  >= CAMERA_TARGET_POSITION_PAUSE_Y_TOP_FLEX))
						endif
						
						// set .AFKPlatformerDeathClock = AFK_UNPAUSE_BUFFER
						// call .Pause(true)
						// call .ApplyDefaultCameras(AFK_PAN_CAMERA_DURATION)
						// call .ApplyDefaultSelections()
						
						// call TimerStart(NewTimerEx(this), AFK_PAN_CAMERA_DURATION, false, function thistype.PanAFKCameraCB)
					endif
				endif
				
				//clear idle time and reset camera target position
				if GetLocalPlayer() == Player(this) then
					set thistype.LocalCameraIdleTime = 0
					
					set thistype.LocalCameraTargetPosition.x = GetCameraTargetPositionX()
					set thistype.LocalCameraTargetPosition.y = GetCameraTargetPositionY()
				endif
			endif
			
			//either prepend or reset player's name in multiboard
			call .UpdateMultiboardPlayerName()
		endif
	endmethod
	
	public method ToggleAFK takes nothing returns nothing
		call .SetAFK(not .IsAFK)
	endmethod
	private static method ToggleAFKCallback takes nothing returns boolean
		call User(S2I(BlzGetTriggerSyncData())).ToggleAFK()
		
		return false
	endmethod
		
	private method CheckAFKPlayer takes real timeElapsed returns nothing
		local real x
		local real y
		
		local real newTime
		
		//call sync AFK logic
		// if this.GameMode == Teams_GAMEMODE_PLATFORMING and not this.PlatformerStartStable and ((this.Platformer.PushedAgainstVector != 0 and RAbsBJ(this.Platformer.YVelocity) <= .5) or this.Platformer.HorizontalAxisState != 0) then
		// call DisplayTextToPlayer(Player(this), 0, 0, "Pushed against: " + I2S(this.Platformer.PushedAgainstVector) + ", y velocity: " + R2S(this.Platformer.YVelocity))
		if this.GameMode == Teams_GAMEMODE_PLATFORMING and not this.PlatformerStartStable and ((this.Platformer.PushedAgainstVector != 0 and this.Platformer.YVelocity == 0.) or this.Platformer.HorizontalAxisState != 0) then
			set this.PlatformerStartStable = true
			
			//special case where the local player's camera target should be reset on PlatformerStartStable -> true
			if GetLocalPlayer() == Player(this) and this.Platformer.HorizontalAxisState == 0 then
				set thistype.LocalCameraTargetPosition.x = GetCameraTargetPositionX()
				set thistype.LocalCameraTargetPosition.y = GetCameraTargetPositionY()
			endif
		endif
		
		//only check AFK state when a player is not transitioning
		if not this.IsTransitioning then
			//call async AFK logic
			if GetLocalPlayer() == Player(this) then
				if this.GameMode == Teams_GAMEMODE_STANDARD or this.GameMode == Teams_GAMEMODE_STANDARD_PAUSED or this.GameMode == Teams_GAMEMODE_PLATFORMING or this.GameMode == Teams_GAMEMODE_PLATFORMING_PAUSED then
					set newTime = thistype.LocalCameraIdleTime + timeElapsed
				endif

				if this.GameMode == Teams_GAMEMODE_PLATFORMING or this.GameMode == Teams_GAMEMODE_PLATFORMING_PAUSED then				
					if this.Platformer.HorizontalAxisState != 0 then
						set newTime = 0						
					endif
				else
					if this.GameMode == Teams_GAMEMODE_STANDARD or this.GameMode == Teams_GAMEMODE_STANDARD_PAUSED then
						if not this.IsAFK then
							if OrderId2String(GetUnitCurrentOrder(this.ActiveUnit)) != null and (GetUnitX(this.ActiveUnit) != thistype.LocalUnitPosition.x or GetUnitY(this.ActiveUnit) != thistype.LocalUnitPosition.y) then
								set newTime = 0
							endif
						endif
					endif
					
					//check if the user's camera has moved a specified distance away from its original position
					set x = GetCameraTargetPositionX() - LocalCameraTargetPosition.x
					set x = x*x
					
					set y = GetCameraTargetPositionY() - LocalCameraTargetPosition.y
					set y = y*y
										
					//TODO also check mouse position, if that ever gets an async API
					if SquareRoot(x + y) >= CAMERA_TARGET_POSITION_FLEX then
						set newTime = 0
					endif
				endif
								
				if this.Team.OnLevel != INTRO_LEVEL_ID and this.Team.OnLevel != DOORS_LEVEL_ID and (this.IsAFK and newTime < thistype.LocalAFKThreshold) or (not this.IsAFK and newTime >= thistype.LocalAFKThreshold) then
					// call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "On sync event, idle time: " + R2S(thistype.LocalCameraIdleTime))
					call BlzSendSyncData(AFK_SYNC_EVENT_PREFIX, I2S(this))
				//only update local values when not syncing a change in AFK state
				//leave updating LocalCameraIdleTime and TargetPosition to the sync event, so it can reference their current values
				else
					if newTime != 0 then
						set thistype.LocalCameraIdleTime = newTime
					else
						set thistype.LocalCameraIdleTime = 0
						
						set thistype.LocalCameraTargetPosition.x = GetCameraTargetPositionX()
						set thistype.LocalCameraTargetPosition.y = GetCameraTargetPositionY()
					
						set thistype.LocalUnitPosition.x = GetUnitX(this.ActiveUnit)
						set thistype.LocalUnitPosition.y = GetUnitY(this.ActiveUnit)
					endif
				endif
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
	
	public method CheckDefaultCameraZoom takes nothing returns nothing
		// call DisplayTextToPlayer(Player(this), 0, 0, "Current distance: " + R2S(GetCameraField(CAMERA_FIELD_TARGET_DISTANCE)) + ", AoA: " + R2S(GetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK)))
		// call DisplayTextToPlayer(Player(this), 0, 0, "Default distance: " + R2S(CameraSetupGetField(DefaultCamera[this], CAMERA_FIELD_TARGET_DISTANCE)) + ", AoA: " + R2S(CameraSetupGetField(DefaultCamera[this], CAMERA_FIELD_ANGLE_OF_ATTACK)))
		// call DisplayTextToPlayer(Player(this), 0, 0, "GameMode: " + I2S(.GameMode))
		
		if GetLocalPlayer() == Player(this) /*
		*/ and .IsAlive and (.GameMode == Teams_GAMEMODE_STANDARD or .GameMode == Teams_GAMEMODE_STANDARD_PAUSED) /*
		*/ and RAbsBJ(GetCameraField(CAMERA_FIELD_TARGET_DISTANCE) - CameraSetupGetField(DefaultCamera[this], CAMERA_FIELD_TARGET_DISTANCE)) >= CAMERA_SETTINGS_AUTO_CHECK_BUFFER then
		// */ and (GetCameraField(CAMERA_FIELD_TARGET_DISTANCE) != CameraSetupGetField(DefaultCamera[this], CAMERA_FIELD_TARGET_DISTANCE) or GetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK) != CameraSetupGetField(DefaultCamera[this], CAMERA_FIELD_ANGLE_OF_ATTACK)) then

			if thistype.LocalCameraTargetDistance == GetCameraField(CAMERA_FIELD_TARGET_DISTANCE) then
				// call DisplayTextToPlayer(Player(this), 0, 0, "Resetting camera to default!")
				// call SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, CameraSetupGetField(DefaultCamera[this], CAMERA_FIELD_TARGET_DISTANCE), CAMERA_SETTINGS_AUTO_FIX_DURATION)
				// call SetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK, CameraSetupGetField(DefaultCamera[this], CAMERA_FIELD_ANGLE_OF_ATTACK), CAMERA_SETTINGS_AUTO_FIX_DURATION)
			
				call CameraSetupApplyForceDuration(DefaultCamera[this], false, CAMERA_SETTINGS_AUTO_FIX_DURATION)
			else
				set thistype.LocalCameraTargetDistance = GetCameraField(CAMERA_FIELD_TARGET_DISTANCE)
			endif
		endif
	endmethod
	public static method CheckDefaultCameraZooms takes nothing returns nothing
		// local SimpleList_ListNode curUserNode = PlayerUtils_FirstPlayer
		
		// loop
		// exitwhen curUserNode == 0
			// call User(curUserNode.value).CheckDefaultCameraZoom()
		// set curUserNode = curUserNode.next
		// endloop
		
		//do i really want to regression test desync issues again? the check/reset is constant computation, and theres only 8 players max
		call User(GetPlayerId(GetLocalPlayer())).CheckDefaultCameraZoom()
	endmethod
	
	public method AppreciateTranslator takes nothing returns nothing	
		local string source = LocalizeContent('TRSO', this.LanguageCode)
		
		//check if language has custom translations in general
		if source != null and source != "" then
			//get the specific translator for the specific language			
			call DisplayTextToPlayer(Player(this), 0, 0, StringFormat2(LocalizeContent('TYTR', this.LanguageCode), ColorValue(source), LocalizeContent('LNAM', this.LanguageCode)))
		//check if the language is auto translated. no appreciation for original English
		elseif .LanguageCode != "en" then
			call DisplayTextToPlayer(Player(this), 0, 0, LocalizeContent('TYGO', this.LanguageCode))
		endif
	endmethod
	public method SetLanguageCode takes string languageCode returns nothing
		if .LanguageCode != languageCode and GetIDForLanguageCode(languageCode) != 0 then
			set .LanguageCode = languageCode
			
			//refresh multiboard (if its available)
			if .Statistics != null then
				call .LocalizeMultiboard()
			endif
			
			//refresh quests
			call LocalizeAllQuestsForPlayer(this)
			
			//current approach to this causes desync
			//refresh visual vote menu (if any active)
			// if .VoteMenu != 0 then
				// call .VoteMenu.refresh(this)
			// endif
			
			call .AppreciateTranslator()
		endif
	endmethod
	private static method SyncUserLanguageCode takes SyncRequest request, User user returns integer
		set user.LanguageCode = request.Data
		
		call user.AppreciateTranslator()
		// call DisplayTextToPlayer(Player(user), 0, 0, request.Data)
		
		// call request.destroy()
		
		return 0
	endmethod
	
    public static method create takes integer playerID returns thistype
        local thistype new = playerID
		local SyncRequest request
                
        //debug call DisplayTextToPlayer(Player(0), 0, 0, "Creating User: " + I2S(new))
        set new.Team = 0
        set new.Deaths = 0
        set new.IsAlive = true
		
		set new.IsTransitioning = true
		set new.TransitioningTimer = NewTimerEx(new)
		
		set new.IsAFK = false
		call BlzTriggerRegisterPlayerSyncEvent(thistype.AFKSyncEvent, Player(new), AFK_SYNC_EVENT_PREFIX, false)
		set new.AFKPlatformerDeathTimer = NewTimerEx(new)
		
		// set new.CameraIdleTime = 0.
		// call BlzTriggerRegisterPlayerSyncEvent(thistype.AFKLocalCameraTimeSyncEvent, Player(new), LOCAL_CAMERA_IDLE_TIME_EVENT_PREFIX, false)
		// call TriggerRegisterPlayerStateEvent(thistype.AFKMouseEvent, Player(new), PLAYER_STATE_OBSERVER_ON_DEATH, GREATER_THAN_OR_EQUAL, 0)
        
        set new.CinematicPlaying = 0
        set new.CinematicQueue = SimpleList_List.create()
		
		set new.Statistics = null
		set new.VoteMenu = 0
        
        // set new.GameMode = Teams_GAMEMODE_STANDARD //regular mazing
		set new.GameMode = Teams_GAMEMODE_HIDDEN
        //FOR SOME REASON THIS IS RETURNING NULL, SO WE NEED TO SET ACTIVE UNIT AFTER MAP INIT
        //set new.ActiveUnit = MazersArray[new]
        
        //set new.Platformer = Platformer.AllPlatformers[new]
		if GetPlayerSlotState(Player(new)) == PLAYER_SLOT_STATE_PLAYING then
			set new.Platformer = Platformer.create(new)
			
			set new.LastCollidedUnit = null
			set new.LastCollidedUnitTimer = NewTimerEx(new)
			
			set request = SyncRequest.create(thistype.SyncUserLanguageCode, new)
			call RegisterAsyncInit(Deferred(request))
			
			if GetLocalPlayer() == Player(new) then
				call request.Sync(SubString(BlzGetLocale(), 0, 2))
			endif
		endif
		
		set new.DebugCurrentConnection = false
		set new.DebugCurrentConnectionLine = null
		set new.DebugCurrentConnectionProjection = null
		set new.DebugCurrentDistance = false
		
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
        
		//auto check that player's camera doesn't get messed up
		call TimerStart(CreateTimer(), CAMERA_SETTINGS_AUTO_CHECK_TIMEOUT, true, function thistype.CheckDefaultCameraZooms)
		
		//AFK infrastructure
		static if DEBUG_AFK then
			set User.LocalAFKThreshold = AFK_CAMERA_DEBUG_TIMEOUT
		else
			set User.LocalAFKThreshold = AFK_CAMERA_MAX_TIMEOUT
		endif
		
		//initialize static properties
		set User.AFKSyncEvent = CreateTrigger()
		call TriggerAddCondition(thistype.AFKSyncEvent, Condition(function thistype.ToggleAFKCallback))
		set User.LocalCameraIdleTime = 0.
		set User.LocalCameraTargetPosition = vector2.create(0., 0.)
		set User.LocalUnitPosition = vector2.create(0., 0.)
		
		// set User.AFKMouseEvent = CreateTrigger()
		// call TriggerAddCondition(thistype.AFKMouseEvent, Condition(function thistype.CheckAFKMouseEventCallback))
		// set User.LocalUserMousePosition = vector2.create(0., 0.)
		
		set User.LocalCameraTargetDistance = 0.
		
		call TimerStart(CreateTimer(), AFK_CAMERA_CHECK_TIMEOUT, true, function thistype.CheckAFKPlayers)
				
        loop
        exitwhen n>=NumberPlayers
            //debug call DisplayTextToPlayer(Player(0), 0, 0, "Creating User: " + I2S(n))
            
            //if GetPlayerSlotState(Player(n))==PLAYER_SLOT_STATE_PLAYING then
                if GetPlayerController(Player(n))==MAP_CONTROL_USER then
                    call User.create(n)
                endif
            //endif
        set n=n+1
        endloop
        
        //register user cinematic CB
        //call DisplayTextToPlayer(Player(0), 0, 0, "Trying to register user cinematic CB")
        //call Cinematic.OnCinemaEnd.register(Condition(function thistype.OnCinemaEndCB))
        //call DisplayTextToPlayer(Player(0), 0, 0, "Registered user cinematic CB")
		
		//register camera tracking cinematic
		set ToggleCameraTrackingTutorial = Cinematic.create(null, false, false, CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'CCT1', DEFAULT_SHORT_TEXT_SPEED))
		call ToggleCameraTrackingTutorial.AddMessage(CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'CCT2', DEFAULT_LONG_TEXT_SPEED))
		call ToggleCameraTrackingTutorial.AddMessage(CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'CCT3', DEFAULT_MEDIUM_TEXT_SPEED))
		// call ToggleCameraTrackingTutorial.AddMessage(CinemaMessage.createEx(null, PRIMARY_SPEAKER_NAME, 'CCT4', DEFAULT_SHORT_TEXT_SPEED))
		
		call Cinematic.OnCinemaEnd.register(Condition(function thistype.ToggleCameraTrackingCinematicCleanup))
    endmethod
endstruct

endlibrary