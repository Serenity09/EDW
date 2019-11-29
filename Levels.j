library Levels requires SimpleList, Teams, GameModesGlobals, LevelIDGlobals, Cinema, User, IStartable, HandleList
    globals
		
		constant integer WorldCount = 7
		private rect array DoorRects[WorldCount]
		
		public constant real TRANSFER_TIMER_TIMEOUT = .05
        public constant real CINEMATIC_TIMER_TIMEOUT = .5
        
        public constant real EASY_SCORE_MODIFIER = 1.
        public constant real HARD_SCORE_MODIFIER = 1.25
        public constant real EASY_CONTINUE_MODIFIER = 1.5
        public constant integer EASY_MAX_CONTINUE_ROLLOVER = 3
		public constant integer HARD_MAX_CONTINUE_ROLLOVER = 1
        public constant real HARD_CONTINUE_MODIFIER = .8
        
		private constant real LEVEL_TRANSFER_MESSAGE_DELAY = 2.5
		private constant real LEVEL_TRANSFER_FADE_DURATION = 1.5
		private constant real LEVEL_TRANSFER_UNPAUSE_DELAY = 1.
		
		private constant boolean DEBUG_START_STOP = false
		private constant boolean DEBUG_LEVEL_CHANGE = false
		private constant boolean DEBUG_CHECKPOINT_CHANGE = false
		
		//used with events
		Levels_Level EventCurrentLevel
		Levels_Level EventPreviousLevel
		
		Checkpoint EventCheckpoint
		
		private constant real DEFAULT_MAX_COLLISION_SIZE = 137.
    endglobals
    
    struct Checkpoint extends array
        //struct does not support recycling
		private static integer c = 0
		
		public rect Gate
		public rect ReviveCenter
        public integer DefaultColor
        public integer DefaultGameMode
		public boolean RequiresSameGameMode
        
		public static method create takes rect gate, rect center returns thistype
			local thistype new = c + 1
			set c = new
			
			set new.Gate = gate
			set new.ReviveCenter = center
			
			//defaults
			set new.DefaultColor = KEY_NONE
			set new.DefaultGameMode = Teams_GAMEMODE_STANDARD
			set new.RequiresSameGameMode = false
			
			return new
		endmethod
		
		public method InitGate takes real angle, real scale returns destructable
			return CreateDestructable('B006', GetRectCenterX(this.Gate), GetRectCenterY(this.Gate), angle, scale, 1)
		endmethod
    endstruct
	
	public keyword Level
	
	private struct AnimatedLevelTransferData extends array
		public Teams_MazingTeam Team
		public Level NextLevel
		public boolean UpdateProgress
		
		implement Alloc
	endstruct
    
	public struct Level extends array //extends IStartable
        public string      Name            //a levels name
        public integer     RawContinues      //refers to the difficulty of a level
        public integer     RawScore
        
		private string StartFunction
        private string StopFunction
                
        public SimpleList_List Startables
        
		public RectList		Boundaries			//boundaries placed on a player's vision and the level's contents
        public rect LevelEnd				//rect that marks the end of this level
		readonly SimpleList_List Checkpoints
		
        readonly static Teams_MazingTeam CBTeam
		
        public Level         NextLevel       //pointer to the next Level struct
        public Level         PrevLevel       //pointer to the prev Level struct
		
        public SimpleList_List Cinematics //any cinematics that might be on the level
        
        public SimpleList_List ActiveTeams
        public static SimpleList_List ActiveLevels
		
		private Event OnLevelStart
		private Event OnLevelStop
		private Event OnCheckpointChange
		
		public real MaxCollisionSize
		
		//private static Event OnLevelChange
		//private static Event OnCheckpointChange
        
        public method Start takes nothing returns nothing
            local SimpleList_ListNode startableNode
			
			static if DEBUG_START_STOP then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Trying to start level " + I2S(this) + ", count: " + I2S(Teams_MazingTeam.GetCountOnLevel(this)))
            endif
			
            if Teams_MazingTeam.GetCountOnLevel(this) == 0 then
                call .ActiveLevels.add(this)
                
                if .StartFunction != null then
					call ExecuteFunc(.StartFunction)
				endif
					
				if .Startables != 0 then
					//debug call .Startables.print(0)
					set startableNode = .Startables.first
					
					loop
					exitwhen startableNode == 0
						call IStartable(startableNode.value).Start()
					set startableNode = startableNode.next
					endloop
				endif
				
                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Started level " + I2S(this))
            endif
        endmethod
        //stops this level unless someone else is on it
        public method Stop takes nothing returns nothing
            local integer countprev = Teams_MazingTeam.GetCountOnLevel(this)
            local SimpleList_ListNode startableNode
			
			static if DEBUG_START_STOP then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Trying to stop level " + I2S(this) + ", count: " + I2S(countprev))
            endif
			
            if countprev == 0 then
                call .ActiveLevels.remove(this)
                
                if .StopFunction != null then
					call ExecuteFunc(.StopFunction)
				endif
				
				if .Startables != 0 then
					//debug call .Startables.print(0)
					set startableNode = .Startables.first
					
					loop
					exitwhen startableNode == 0
						call IStartable(startableNode.value).Stop()
					set startableNode = startableNode.next
					endloop
				endif
				
				//cleans up unregistered content
				//MUST fire after IStartable.Stop to make sure IStartables are cleaned up correctly
                call .RemoveGreenFromLevel()
                
                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Stopped level " + I2S(this))
            endif
        endmethod
		
		//placeholder, TODO implement based on random integers already gotten for the level *and* the level's intended difficulty
		public method GetWeightedRandomInt takes integer lowBound, integer highBound returns integer
			return GetRandomInt(lowBound, highBound)
		endmethod
		public method GetWeightedRandomReal takes real lowBound, real highBound returns real
			return GetRandomReal(lowBound, highBound)
		endmethod
        
        public method GetWorldID takes nothing returns integer
            //World levels follow this format
			if this >= 3 and this <= 50 then //last level ID
                return ModuloInteger(this - 3, 7) + 1
			else
				return -this
            endif
        endmethod
		public method IsWorldLevel takes nothing returns boolean
			return this > 0 and .GetWorldID() > 0
		endmethod
		public method GetWorldColor takes nothing returns string
			local integer onWorld = .GetWorldID()
            
            if onWorld == -1 then
                return INTRO_TEXT_COLOR
			elseif onWorld == -2 then
				return DOORS_TEXT_COLOR
            elseif onWorld == 1 then
                return HARD_ICE_WORLD_COLOR
            elseif onWorld == 2 then
                return EASY_ICE_WORLD_COLOR
            elseif onWorld == 3 then
                return LAND_WORLD_COLOR
            elseif onWorld == 4 then
                return ""
            elseif onWorld == 5 then
                return ""
            elseif onWorld == 6 then
                return FOUR_SEASONS_WORLD_COLOR
            elseif onWorld == 7 then
                return PLATFORMING_WORLD_COLOR
			else
				return ""
            endif
		endmethod
        public method GetWorldString takes nothing returns string
            local integer onWorld = .GetWorldID()
			local string worldName = ""
            
            if onWorld == -1 then
                set worldName = "???"
			elseif onWorld == -2 then
				set worldName = "Doors"
            elseif onWorld == 1 then
                set worldName = "Black Ice"
            elseif onWorld == 2 then
                set worldName = "Icetown"
            elseif onWorld == 3 then
                set worldName = "Landlubber"
            elseif onWorld == 4 then
                set worldName = "Greed"
            elseif onWorld == 5 then
                set worldName = "Sloth"
            elseif onWorld == 6 then
                set worldName = "Four Seasons"
            else//if onWorld == 7
                set worldName = "2.5 Dimensions"
            endif
			
			return ColorMessage(worldName, .GetWorldColor())
        endmethod
		
		//TODO consolidate to one method - use Get prefix, closer to a convention
		public method GetLocalizedWorldString takes User user returns string
			local integer onWorld = .GetWorldID()
			local string worldName = ""
            			
            if onWorld == -1 then
                set worldName = "???"
			elseif onWorld == -2 then
				set worldName = LocalizeContent('DOOR', user.LanguageCode)
            elseif onWorld == 1 then
                set worldName = LocalizeContent('LGI1', user.LanguageCode)
            elseif onWorld == 2 then
                set worldName = LocalizeContent('LGI2', user.LanguageCode)
            elseif onWorld == 3 then
                set worldName = LocalizeContent('LGL1', user.LanguageCode)
            elseif onWorld == 4 then
                set worldName = "Greed"
            elseif onWorld == 5 then
                set worldName = "Sloth"
            elseif onWorld == 6 then
                set worldName = LocalizeContent('LGFS', user.LanguageCode)
            else//if onWorld == 7
                set worldName = LocalizeContent('LG25', user.LanguageCode)
            endif
						
			return ColorMessage(worldName, .GetWorldColor())
		endmethod
		public method ToLocalizedWorldString takes User user returns string
			local string name
            
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Level ID: " + I2S(this))
            
            if this == INTRO_LEVEL_ID then
                return LocalizeContent('ENTR', user.LanguageCode)
            elseif this == DOORS_LEVEL_ID then
                return LocalizeContent('DOOR', user.LanguageCode)
            else
                set name = .GetLocalizedWorldString(user)

                return name + " " + I2S(R2I((this - 3) / 7) + 1)
            endif
		endmethod
		
		public method GetLocalizedLevelName takes User user returns string
			if this == INTRO_LEVEL_ID then
				return LocalizeContent('ENTR', user.LanguageCode)
			elseif this == DOORS_LEVEL_ID then
				return LocalizeContent('DOOR', user.LanguageCode)
				
			elseif this == IW1_LEVEL_ID then
				return LocalizeContent('LNI1', user.LanguageCode)
			elseif this == IW2_LEVEL_ID then
				return LocalizeContent('LNI2', user.LanguageCode)
			elseif this == IW3_LEVEL_ID then
				return LocalizeContent('LNI3', user.LanguageCode)
			elseif this == IW4_LEVEL_ID then
				return LocalizeContent('LNI4', user.LanguageCode)
			elseif this == IW5_LEVEL_ID then
				return LocalizeContent('LNI5', user.LanguageCode)
				
			elseif this == IWB1_LEVEL_ID then
				return LocalizeContent('LNE1', user.LanguageCode)
				
			elseif this == LW1_LEVEL_ID then
				return LocalizeContent('LNL1', user.LanguageCode)
			elseif this == LW2_LEVEL_ID then
				return LocalizeContent('LNL2', user.LanguageCode)
				
			elseif this == FS1_LEVEL_ID then
				return LocalizeContent('LNF1', user.LanguageCode)
				
			elseif this == PW1_LEVEL_ID then
				return LocalizeContent('LNP1', user.LanguageCode)
			elseif this == PW2_LEVEL_ID then
				return LocalizeContent('LNP2', user.LanguageCode)
			elseif this == PW3_LEVEL_ID then
				return LocalizeContent('LNP3', user.LanguageCode)
			elseif this == PW4_LEVEL_ID then
				return LocalizeContent('LNP4', user.LanguageCode)
				
			elseif this == BRICK_BREAK_LEVEL_ID then
				return LocalizeContent('LNM1', user.LanguageCode)
			
			else
				if CONFIGURATION_PROFILE != RELEASE then
					call BJDebugMsg("Localizing level name for unhandled level ID: " + I2S(this))
				endif
				
				return ""
			endif
		endmethod
        
        public method RemoveGreenFromLevel takes nothing returns nothing
            local unit u
			local integer i = 0
            local rect r
			
			loop
			exitwhen i >= .Boundaries.size
			set r = .Boundaries[i]
				//call BJDebugMsg("Removing green from boundary ID: " + I2S(i))
				
				call GroupEnumUnitsInRect(TempGroup, r, null)
				
				loop
				set u = FirstOfGroup(TempGroup)
				exitwhen u == null
					if GetPlayerId(GetOwningPlayer(u)) == 10 then					
						//reset unit to default stats based on what can currently change... at some point find a better way to unload modified units (and only them)
						call SetUnitVertexColor(u, 255, 255, 255, 255)
						call SetUnitMoveSpeed(u, GetUnitDefaultMoveSpeed(u))
						call Recycle_ReleaseUnit(u)
					endif
				call GroupRemoveUnit(TempGroup, u)
				endloop
			set i = i + 1
            endloop
			
			set r = null
        endmethod
		
        public method SetCheckpointForTeam takes Teams_MazingTeam mt, integer cpID returns nothing
            local Checkpoint cp = Checkpoint(.Checkpoints.get(cpID).value)
			
			//call DisplayTextToForce(bj_FORCE_PLAYER[0], "Started setting CP for team " + I2S(mt) + ", index " + I2S(cpID) + ", cp " + I2S(cp))
			
			if cp != 0 then
				set EventCheckpoint = cp
				set EventCurrentLevel = this
				set this.CBTeam = mt
				
				set mt.OnCheckpoint = cpID
                
                set mt.DefaultGameMode = cp.DefaultGameMode
                
                call mt.MoveRevive(cp.ReviveCenter)
                call mt.RespawnTeamAtRect(cp.ReviveCenter, true)
                call mt.ApplyKeyToTeam(cp.DefaultColor)
				call mt.ResetHealthForTeam()
                
                call mt.UpdateMultiboard()
				
				if this.OnCheckpointChange != 0 then
					//debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Firing checkpoint event for: " + I2S(this.OnCheckpointChange))
					call this.OnCheckpointChange.fire()
				endif
				//call DisplayTextToForce(bj_FORCE_PLAYER[0], "Finished setting CP for team " + I2S(mt))				
            endif
            
            //TODO add team wide CP effect instead of CP effect on first user in team
            //call CPEffect(mt.FirstUser.value)
        endmethod
		
		private static method OnCheckpointChangeFX_Respawn takes nothing returns nothing
			local timer t = GetExpiredTimer()
			local Teams_MazingTeam mt = GetTimerData(t)
			
			call mt.OnLevel.SetCheckpointForTeam(mt, mt.OnCheckpoint)
			
			call ReleaseTimer(t)
			set t = null
		endmethod
		private static method OnCheckpointChangeFX_Pan takes nothing returns nothing
			local timer t = GetExpiredTimer()
			local Teams_MazingTeam mt = GetTimerData(t)
			
			call mt.PanCameraForTeam(GetUnitX(mt.LastEventUser.ActiveUnit), GetUnitY(mt.LastEventUser.ActiveUnit), 1.0)
			
			call TimerStart(t, 1.0 + 0.5, false, function thistype.OnCheckpointChangeFX_Respawn)
		endmethod
		private static method OnCheckpointChangeFX_Hide takes nothing returns nothing
			local timer t = GetExpiredTimer()
			local Teams_MazingTeam mt = GetTimerData(t)
			local SimpleList_ListNode u = mt.FirstUser
			
			loop
			exitwhen u == 0
				if u.value != mt.LastEventUser then
					call User(u.value).SwitchGameModes(Teams_GAMEMODE_HIDDEN, GetUnitX(mt.LastEventUser.ActiveUnit), GetUnitY(mt.LastEventUser.ActiveUnit))
				endif
			set u = u.next
			endloop
			
			call TimerStart(t, .5, false, function thistype.OnCheckpointChangeFX_Pan)
		endmethod
		private static method OnCheckpointChangeFX_HideAndPan takes nothing returns nothing
			local timer t = GetExpiredTimer()
			local Teams_MazingTeam mt = GetTimerData(t)
			local SimpleList_ListNode u = mt.FirstUser
			
			loop
			exitwhen u == 0
				if u.value != mt.LastEventUser then
					call User(u.value).SwitchGameModes(Teams_GAMEMODE_HIDDEN, GetUnitX(mt.LastEventUser.ActiveUnit), GetUnitY(mt.LastEventUser.ActiveUnit))
				endif
			set u = u.next
			endloop
			
			call mt.PanCameraForTeam(GetUnitX(mt.LastEventUser.ActiveUnit), GetUnitY(mt.LastEventUser.ActiveUnit), 1.0)
			
			call TimerStart(t, 1.0 + 0.75, false, function thistype.OnCheckpointChangeFX_Respawn)
		endmethod
		private static method OnCheckpointChangeFX_DisappearingVFX takes nothing returns nothing
			local timer t = GetExpiredTimer()
			local Teams_MazingTeam mt = GetTimerData(t)
			local SimpleList_ListNode u = mt.FirstUser
			local effect fx
			
			// call mt.CreateInstantEffectForTeam("Abilities\\Spells\\Items\\AIso\\AIsoTarget.mdl", mt.LastEventUser)
			// call mt.CreateInstantEffectForTeam("Abilities\\Spells\\Items\\TomeOfRetraining\\TomeOfRetrainingCaster.mdl", mt.LastEventUser)
			
			loop
			exitwhen u == 0
				if u.value != mt.LastEventUser and User(u.value).ActiveUnit != null then
					set fx = CreateSpecialEffect("Abilities\\Spells\\Items\\AIso\\AIsoTarget.mdl", GetUnitX(User(u.value).ActiveUnit), GetUnitY(User(u.value).ActiveUnit), null)
					call BlzSetSpecialEffectScale(fx, 1.5)
					call BlzSetSpecialEffectTime(fx, 1.)
					call BlzSetSpecialEffectTimeScale(fx, 1.75)
					call DestroyEffect(fx)
					// call CreateInstantSpecialEffect("Abilities\\Spells\\Items\\AIso\\AIsoTarget.mdl", GetUnitX(User(u.value).ActiveUnit), GetUnitY(User(u.value).ActiveUnit), null)
				endif
			set u = u.next
			endloop
			
			call TimerStart(t, 1.15, false, function thistype.OnCheckpointChangeFX_HideAndPan)
		endmethod
		
		private static method LocalizeReachedCheckpoint takes User origin, User localizer returns string
			return origin.GetLocalizedPlayerName(localizer) + " " + LocalizeContent('LSCP', localizer.LanguageCode)
		endmethod
		public method AnimatedSetCheckpointForTeam takes Teams_MazingTeam mt, integer cpID returns nothing
			local Checkpoint cp = Checkpoint(.Checkpoints.get(cpID).value)
			
			// call DisplayTextToForce(bj_FORCE_PLAYER[0], "Started setting CP for team " + I2S(mt) + ", index " + I2S(cpID) + ", cp " + I2S(cp))
			if mt.Users.count > 1 then
				if cp != 0 then
					call mt.PauseTeam(true)
					
					// call DisplayTextToForce(bj_FORCE_PLAYER[0], "Last Event User: " + I2S(mt.LastEventUser))
					if mt.LastEventUser != -1 then
						call mt.DisplayDynamicContent(LocalizeReachedCheckpoint, mt.LastEventUser)
						//call mt.PrintMessage(mt.LastEventUser.GetStylizedPlayerName() + " " + "has reached a checkpoint!")
					endif
					
					//just for safety
					set mt.OnCheckpoint = cpID
					set mt.DefaultGameMode = cp.DefaultGameMode
					call mt.MoveRevive(cp.ReviveCenter)
									
					call TimerStart(NewTimerEx(mt), .25, false, function thistype.OnCheckpointChangeFX_DisappearingVFX)
				endif
			else
				call this.SetCheckpointForTeam(mt, cpID)
			endif
		endmethod
                        
        public method AddCheckpoint takes rect gate, rect center returns Checkpoint
            local Checkpoint cp = Checkpoint.create(gate, center)
			call .Checkpoints.addEnd(cp)
			
			return cp
        endmethod
		public method InsertCheckpoint takes rect gate, rect center, integer position returns Checkpoint
			local Checkpoint cp = Checkpoint.create(gate, center)
			
			if position < .Checkpoints.count then
				call .Checkpoints.insert(cp, position)
			else
				call .Checkpoints.addEnd(cp)
			endif
			
			return cp
		endmethod
        
		public method GetWeightedScore takes nothing returns integer
			local integer score
					
			if RewardMode == GameModesGlobals_EASY or RewardMode == GameModesGlobals_CHEAT then
				set score = R2I(.RawScore*EASY_SCORE_MODIFIER + .5)
			elseif RewardMode == GameModesGlobals_HARD then
				set score = R2I(.RawScore*HARD_SCORE_MODIFIER + .5)
			else
				set score = .RawScore
			endif
			
			return score
		endmethod
		public method ApplyLevelRewards takes User u, Teams_MazingTeam mt, Level nextLevel returns nothing			
			local integer score = .GetWeightedScore()
			local integer originalContinues = mt.GetContinueCount()
			local integer rolloverContinues = 0
			local integer nextLevelContinues = 0
			
			//update score
			call mt.ChangeScore(score)
			
			//update continues
			if ShouldShowSettingVoteMenu() and RewardMode != GameModesGlobals_CHEAT then				
				if RewardMode == GameModesGlobals_EASY then
					if mt.GetContinueCount() > EASY_MAX_CONTINUE_ROLLOVER then
						set rolloverContinues = EASY_MAX_CONTINUE_ROLLOVER
					else
						set rolloverContinues = mt.GetContinueCount()
					endif
					
					set nextLevelContinues = R2I(nextLevel.RawContinues*EASY_CONTINUE_MODIFIER + .5)
				elseif RewardMode == GameModesGlobals_HARD then
					if mt.GetContinueCount() > HARD_MAX_CONTINUE_ROLLOVER then
						set rolloverContinues = HARD_MAX_CONTINUE_ROLLOVER
					else
						set rolloverContinues = mt.GetContinueCount()
					endif
					
					set nextLevelContinues = R2I(nextLevel.RawContinues*HARD_CONTINUE_MODIFIER + .5)
				endif
				
				if this == DOORS_LEVEL_ID then
					set rolloverContinues = 0
				endif
				
				if originalContinues != rolloverContinues + nextLevelContinues then
					call mt.SetContinueCount(rolloverContinues + nextLevelContinues)
				endif
			endif
			
			// if this == DOORS_LEVEL_ID then
				// //call mt.PrintMessage("Starting level " + ColorMessage(nextLevel.Name, SPEAKER_COLOR) + "!")
				// // if not ShouldShowSettingVoteMenu() or RewardMode == GameModesGlobals_CHEAT then
					// // call mt.PrintMessage("Starting " + nextLevel.GetWorldString())
				// // else
					// // call mt.PrintMessage("Starting " + nextLevel.GetWorldString() + " with " + ColorMessage(I2S(mt.GetContinueCount()), SPEAKER_COLOR) + " continues")
				// // endif
			// else
				// if ShouldShowSettingVoteMenu() and RewardMode != GameModesGlobals_CHEAT then
					// if originalContinues == 1 and rolloverContinues == 1 then
						// call mt.PrintMessage("You kept your " + ColorMessage(I2S(1), SPEAKER_COLOR) + " continue, and gained " + ColorMessage(I2S(nextLevelContinues), SPEAKER_COLOR) + " extra continues to boot")
					// elseif originalContinues > 0 and originalContinues != rolloverContinues + nextLevelContinues then
						// call mt.PrintMessage("You kept " + ColorMessage(I2S(rolloverContinues), SPEAKER_COLOR) + " of your " + ColorMessage(I2S(originalContinues), SPEAKER_COLOR) + " continues, and gained " + ColorMessage(I2S(nextLevelContinues), SPEAKER_COLOR) + " extra continues to boot")
					// else
						// call mt.PrintMessage("You have " + ColorMessage(I2S(rolloverContinues + nextLevelContinues), SPEAKER_COLOR) + " continues")
					// endif
				// endif
			// endif
		endmethod
		
		public method StopLevelForTeam takes Teams_MazingTeam mt returns nothing
			set EventPreviousLevel = this
			set this.CBTeam = mt
			
			call mt.ClearAllCinematicsForTeam()
            call this.ActiveTeams.remove(mt)
			
			set mt.OnLevel = TEMP_LEVEL_ID
            call this.Stop() //only stops the level if no ones on it
			if this.OnLevelStop != 0 then
				call this.OnLevelStop.fire()
			endif
		endmethod
		public method StartLevelForTeam takes Teams_MazingTeam mt returns nothing
			local integer i = 0
            local rect r
			
			set EventCurrentLevel = this
            set this.CBTeam = mt
			
			call this.Start() //only starts the next level if there is one
			if this.OnLevelStart != 0 then
				call this.OnLevelStart.fire()
			endif
			
            set mt.OnLevel = this
            call this.ActiveTeams.add(mt)
            
			loop
			exitwhen i >= .Boundaries.size
			set r = .Boundaries[i]
				call mt.AddTeamVision(r)
			set i = i + 1
			endloop
			set r = null
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Started")
            //team tele, respawn update, vision, pause + unpause
            call this.SetCheckpointForTeam(mt, 0)
		endmethod
		
        //update level continuously or discontinuously from one to the next. IE lvl 1 -> 2 -> 3 -> 4 OR 1 -> 4 -> 2 etc
        public method SwitchLevels takes Teams_MazingTeam mt, Level nextLevel, User activatingUser, boolean updateProgress returns nothing			
			static if DEBUG_LEVEL_CHANGE then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "From " + I2S(this) + " To " + I2S(nextLevel))
            endif
			
			if updateProgress then
				static if DEBUG_LEVEL_CHANGE then
					call DisplayTextToForce(bj_FORCE_PLAYER[0], "Updating progress")
				endif
				
				//add continues and score
				call this.ApplyLevelRewards(activatingUser, mt, nextLevel)

				call mt.UpdateWorldProgress(this)
			endif
			
			//stop current level before starting next level. some of the current level may be able to immediately recycle, and itll be easier on the CPU
			call this.StopLevelForTeam(mt)
			
			call nextLevel.StartLevelForTeam(mt)
        endmethod
		
		// private static method SwitchLevels_FadeIn takes nothing returns nothing
			// local timer t = GetExpiredTimer()
			// local AnimatedLevelTransferData transferData = GetTimerData(t)
			
			// // call transferData.Team.PrintMessage(transferData.NextLevel.Name)
			// call transferData.Team.FadeInForTeam(LEVEL_TRANSFER_FADE_DURATION)
			
			// call transferData.deallocate()
			// call ReleaseTimer(t)
			// set t = null
		// endmethod
		private static method LocalizeSwitchLevelsNowStarting takes AnimatedLevelTransferData origin, User localizer returns string
			return LocalizeContent('LS3N', localizer.LanguageCode) + " " + origin.NextLevel.GetLocalizedLevelName(localizer)
		endmethod
		private static method SwitchLevels_Message3 takes nothing returns nothing
			local timer t = GetExpiredTimer()
			local AnimatedLevelTransferData transferData = GetTimerData(t)
			
			// call transferData.Team.PrintMessage("Now starting:" + " " + transferData.NextLevel.Name)
			call transferData.Team.DisplayDynamicContent(LocalizeSwitchLevelsNowStarting, transferData)
			call transferData.Team.FadeInForTeam(LEVEL_TRANSFER_FADE_DURATION)
			
			if transferData.Team.DefaultGameMode == Teams_GAMEMODE_PLATFORMING then
				call transferData.Team.PauseTeam(false)
			else
				call transferData.Team.RegisterAutoUnpauseForTeam(LEVEL_TRANSFER_FADE_DURATION + LEVEL_TRANSFER_UNPAUSE_DELAY)
			endif
			
			call transferData.deallocate()
			call ReleaseTimer(t)
			set t = null
			// call TimerStart(t, LEVEL_TRANSFER_MESSAGE_DELAY, false, function thistype.SwitchLevels_FadeIn)
		endmethod
		
		private static method LocalizeSwitchLevelsContinueCount takes Teams_MazingTeam origin, User localizer returns string
			return ColorValue(I2S(origin.GetContinueCount())) + " " + LocalizeContent('LS2C', localizer.LanguageCode)
		endmethod
		private static method SwitchLevels_Message2 takes nothing returns nothing
			local timer t = GetExpiredTimer()
			local AnimatedLevelTransferData transferData = GetTimerData(t)
			
			// call transferData.Team.PrintMessage(ColorValue(I2S(transferData.Team.GetContinueCount())) + " " + "continues left")
			call transferData.Team.DisplayDynamicContent(LocalizeSwitchLevelsContinueCount, transferData.Team)
			
			call TimerStart(t, LEVEL_TRANSFER_MESSAGE_DELAY, false, function thistype.SwitchLevels_Message3)
		endmethod
		
		private static method LocalizeSwitchLevelsScore takes Teams_MazingTeam origin, User localizer returns string
			return LocalizeContent('LS1A', localizer.LanguageCode) /*
			*/ + " " + ColorValue(I2S(origin.OnLevel.GetWeightedScore())) /*
			*/ + " " + LocalizeContent('LS1B', localizer.LanguageCode)
		endmethod
		private static method LocalizeSwitchLevelsScoreTotal takes Teams_MazingTeam origin, User localizer returns string
			return LocalizeContent('LS1A', localizer.LanguageCode) + " " /*
				*/ + ColorValue(I2S(origin.OnLevel.GetWeightedScore())) + " " /*
				*/ + LocalizeContent('LS1B', localizer.LanguageCode) + /*
				*/ " (" + ColorValue(I2S(origin.GetScore() + origin.OnLevel.GetWeightedScore())) /*
				*/ + " " + LocalizeContent('LS1C', localizer.LanguageCode) + ")"
		endmethod
		private static method SwitchLevels_Message1 takes nothing returns nothing
			local timer t = GetExpiredTimer()
			local AnimatedLevelTransferData transferData = GetTimerData(t)
			
			if transferData.Team.OnLevel.GetWeightedScore() > 0 then				
				if transferData.Team.GetScore() <= 0 then
					// call transferData.Team.PrintMessage("You gained" + " " + ColorValue(I2S(transferData.Team.OnLevel.GetWeightedScore())) + " " + "points")
					call transferData.Team.DisplayDynamicContent(LocalizeSwitchLevelsScore, transferData.Team)
				else
					// call transferData.Team.PrintMessage("You gained" + " " + ColorValue(I2S(transferData.Team.OnLevel.GetWeightedScore())) + " " + "points" + " (" + ColorValue(I2S(transferData.Team.GetScore() + transferData.Team.OnLevel.GetWeightedScore())) + " " + "total" + ")")
					call transferData.Team.DisplayDynamicContent(LocalizeSwitchLevelsScoreTotal, transferData.Team)
				endif
			endif
			
			call transferData.Team.OnLevel.SwitchLevels(transferData.Team, transferData.NextLevel, transferData.Team.LastEventUser, true)
			call transferData.Team.CancelAutoUnpauseForTeam()
			call transferData.Team.PauseTeam(true)
			
			if ShouldShowSettingVoteMenu() and RewardMode != GameModesGlobals_CHEAT and transferData.Team.OnLevel.IsWorldLevel() then
				call TimerStart(t, LEVEL_TRANSFER_MESSAGE_DELAY, false, function thistype.SwitchLevels_Message2)
			else
				call TimerStart(t, LEVEL_TRANSFER_MESSAGE_DELAY, false, function thistype.SwitchLevels_Message3)
			endif
		endmethod
		// private static method SwitchLevels_Message takes nothing returns nothing
			// local timer t = GetExpiredTimer()
			// local AnimatedLevelTransferData transferData = GetTimerData(t)
			
			// if transferData.Team.GetScore() > 0 then
				// call transferData.Team.PrintMessage("You gained " + ColorValue(I2S(transferData.Team.OnLevel.GetWeightedScore())) + " points (" + ColorValue(I2S(transferData.Team.GetScore() + transferData.Team.OnLevel.GetWeightedScore())) + " total)")
			// else
				// call transferData.Team.PrintMessage("You gained " + ColorValue(I2S(transferData.Team.OnLevel.GetWeightedScore())) + " points")
			// endif
			// call transferData.Team.OnLevel.SwitchLevels(transferData.Team, transferData.NextLevel, transferData.Team.LastEventUser, true)
			
			// if ShouldShowSettingVoteMenu() and RewardMode != GameModesGlobals_CHEAT then
				// call transferData.Team.PrintMessage("You have " + ColorValue(I2S(transferData.Team.GetContinueCount())) + " continues left")
			// endif
			// // call transferData.Team.PrintMessage("Now starting: " + transferData.NextLevel.Name)
			
			// call transferData.Team.PrintMessage("Now starting:")
			
			// call TimerStart(t, 1., false, function thistype.SwitchLevels_FadeIn)
		// endmethod
		private static method SwitchLevels_GameMode takes nothing returns nothing
			local timer t = GetExpiredTimer()
			local AnimatedLevelTransferData transferData = GetTimerData(t)
						
			call transferData.Team.SwitchTeamGameMode(Teams_GAMEMODE_HIDDEN, GetUnitX(transferData.Team.LastEventUser.ActiveUnit), GetUnitY(transferData.Team.LastEventUser.ActiveUnit))
			
			if transferData.Team.OnLevel != DOORS_LEVEL_ID then
				call TimerStart(t, LEVEL_TRANSFER_FADE_DURATION, false, function thistype.SwitchLevels_Message1)
			else
				// call TimerStart(t, 0., false, function thistype.SwitchLevels_Message1)
				call thistype.SwitchLevels_Message1()
			endif
		endmethod
		private static method SwitchLevels_FadeOut takes nothing returns nothing
			local timer t = GetExpiredTimer()
			local AnimatedLevelTransferData transferData = GetTimerData(t)
			
			call transferData.Team.ClearAllCinematicsForTeam()
			// call transferData.Team.SwitchTeamGameMode(Teams_GAMEMODE_HIDDEN, GetUnitX(transferData.Team.LastEventUser.ActiveUnit), GetUnitY(transferData.Team.LastEventUser.ActiveUnit))
			call transferData.Team.FadeOutForTeam(LEVEL_TRANSFER_FADE_DURATION)
			
			call TimerStart(t, LEVEL_TRANSFER_FADE_DURATION, false, function thistype.SwitchLevels_GameMode)
		endmethod
		// private static method SwitchLevels_FadeOut takes nothing returns nothing
			// local timer t = GetExpiredTimer()
			// local AnimatedLevelTransferData transferData = GetTimerData(t)
						
			// call transferData.Team.SwitchTeamGameMode(Teams_GAMEMODE_HIDDEN, GetUnitX(transferData.Team.LastEventUser.ActiveUnit), GetUnitY(transferData.Team.LastEventUser.ActiveUnit))
			// call transferData.Team.FadeOutForTeam(LEVEL_TRANSFER_FADE_DURATION)
			
			// if transferData.Team.OnLevel != DOORS_LEVEL_ID then
				// call TimerStart(t, 2. * LEVEL_TRANSFER_FADE_DURATION, false, function thistype.SwitchLevels_Message1)
			// else
				// call TimerStart(t, LEVEL_TRANSFER_FADE_DURATION, false, function thistype.SwitchLevels_Message1)
			// endif
		// endmethod
		private static method SwitchLevels_DisappearingVFX takes nothing returns nothing
			local timer t = GetExpiredTimer()
			local AnimatedLevelTransferData transferData = GetTimerData(t)
			local SimpleList_ListNode u = transferData.Team.FirstUser
			local effect fx
						
			loop
			exitwhen u == 0
				if User(u.value).ActiveUnit != null then
					// set fx = CreateSpecialEffect("Abilities\\Spells\\Items\\AIso\\AIsoTarget.mdl", GetUnitX(User(u.value).ActiveUnit), GetUnitY(User(u.value).ActiveUnit), null)
					// call BlzSetSpecialEffectScale(fx, 1.5)
					// call BlzSetSpecialEffectTime(fx, 1.)
					// call BlzSetSpecialEffectTimeScale(fx, 1.75)
					// call DestroyEffect(fx)
					call CreateInstantSpecialEffect("Abilities\\Spells\\Human\\Resurrect\\ResurrectCaster.mdl", GetUnitX(User(u.value).ActiveUnit), GetUnitY(User(u.value).ActiveUnit), null)
				endif
			set u = u.next
			endloop
			
			call TimerStart(t, 1.15, false, function thistype.SwitchLevels_FadeOut)
		endmethod
		
		private static method LocalizeLevelClear takes User origin, User localizer returns string
			return origin.GetLocalizedPlayerName(localizer) + " " + LocalizeContent('LSAH', localizer.LanguageCode)
		endmethod
		private static method LocalizeWorldStartAll takes AnimatedLevelTransferData origin, User localizer returns string
			return origin.Team.GetLocalizedTeamName(localizer) + " " /*
				*/ + LocalizeContent('LSAT', localizer.LanguageCode) + " " /*
				*/ + origin.NextLevel.GetLocalizedWorldString(localizer)
		endmethod
		private static method LocalizeWorldStartTeam takes AnimatedLevelTransferData origin, User localizer returns string
			return LocalizeContent('LSAE', localizer.LanguageCode) + " " + origin.NextLevel.GetLocalizedWorldString(localizer)
		endmethod
		public method SwitchLevelsAnimated takes Teams_MazingTeam mt, Level nextLevel, boolean updateProgress returns nothing
			local AnimatedLevelTransferData transferData = AnimatedLevelTransferData.allocate()
			set transferData.Team = mt
			set transferData.NextLevel = nextLevel
			set transferData.UpdateProgress = updateProgress
			
			call mt.PauseTeam(true)
			if this != DOORS_LEVEL_ID then
				if mt.LastEventUser != -1 then
					// call mt.PrintMessage(mt.LastEventUser.GetStylizedPlayerName() + " " + "has cleared the level!")
					call mt.DisplayDynamicContent(LocalizeLevelClear, mt.LastEventUser)
				endif
			else
				//TODO remove when there's a less intrusive and more relevant way to convey what team is where via the Doors level
				// call Teams_MazingTeam.PrintMessageAll(mt.TeamName + " " + "team has just started" + " " + nextLevel.GetWorldString(), mt)
				call Teams_MazingTeam.DisplayDynamicContentAll(LocalizeWorldStartAll, transferData, mt)
				
				// call mt.PrintMessage("Entering new world:" + " " + nextLevel.GetWorldString())
				call mt.DisplayDynamicContent(LocalizeWorldStartTeam, transferData)
			endif
			
			call TimerStart(NewTimerEx(transferData), .5, false, function thistype.SwitchLevels_DisappearingVFX)
		endmethod
        
		private static method CheckTransfers takes nothing returns nothing
            local SimpleList_ListNode curLevel = thistype.ActiveLevels.first
            local SimpleList_ListNode curTeam
            local SimpleList_ListNode curUser
			
			local SimpleList_ListNode curCheckpoint
            
			local integer i
			local real x
			local real y
			
            local Level nextLevel
			local integer nextCheckpointID
			
			local WorldProgress worldProgress
			
            loop
            exitwhen curLevel == 0
				set curTeam = thistype(curLevel.value).ActiveTeams.first
				
				loop
				exitwhen curTeam == 0
					//call DisplayTextToForce(bj_FORCE_PLAYER[0], "Checking team " + I2S(curTeam.value))
					set nextLevel = 0
					set nextCheckpointID = -1
					set curUser = Teams_MazingTeam(curTeam.value).Users.first
											
					loop
					exitwhen curUser == 0 or nextLevel != 0
						//call DisplayTextToForce(bj_FORCE_PLAYER[0], "Checking player " + I2S(curUser.value))
						if User(curUser.value).GameMode == Teams_GAMEMODE_STANDARD or User(curUser.value).GameMode == Teams_GAMEMODE_PLATFORMING then
							set x = GetUnitX(User(curUser.value).ActiveUnit)
							set y = GetUnitY(User(curUser.value).ActiveUnit)
							
							//check level transfer(s)
							if Level(curLevel.value) == DOORS_LEVEL_ID then
								set i = 0
								loop
								exitwhen i == WorldCount or nextLevel != 0
									if DoorRects[i] != null and RectContainsCoords(DoorRects[i], x, y) then
										set nextLevel = Level(i + DOORS_LEVEL_ID + 1) //levels take standard structure after the DOORS level
										
										//check if the team has already made progress into that world
										set worldProgress = Teams_MazingTeam(curTeam.value).GetWorldProgress(nextLevel.GetWorldID())
										//call DisplayTextToForce(bj_FORCE_PLAYER[0], "World ID " + I2S(nextLevel.GetWorldID()))
										//call DisplayTextToForce(bj_FORCE_PLAYER[0], "World Progress " + I2S(worldProgress))
										if worldProgress != 0 then
											if worldProgress.FurthestLevel.NextLevel == 0 then
												//team has already beaten this world!
												// call DisplayTextToForce(bj_FORCE_PLAYER[curUser.value], "You've already beaten that world!")
												call User(curUser.value).DisplayLocalizedMessage('LCGG', 0)
												
												set nextLevel = 0
												call User(curUser.value).RespawnAtRect(Teams_MazingTeam(curTeam.value).Revive, true)
											else
												set Teams_MazingTeam(curTeam.value).LastEventUser = curUser.value
												
												set nextLevel = worldProgress.FurthestLevel.NextLevel
											endif
										endif
									endif
								set i = i + 1
								endloop
							else
								if Level(curLevel.value).LevelEnd != null and RectContainsCoords(Level(curLevel.value).LevelEnd, x, y) then
									set Teams_MazingTeam(curTeam.value).LastEventUser = curUser.value
									
									//check if there's a sequential level after the current one
									if Level(curLevel.value).NextLevel != 0 then
										set nextLevel = Level(curLevel.value).NextLevel
									else
										//finished all available levels in world, returning to Doors
										set nextLevel = Level(DOORS_LEVEL_ID)
									endif
								endif
							endif
							
							///check for any checkpoints if nothing has been found yet
							if nextLevel == 0 and nextCheckpointID == -1 then
								set i = 0
								set curCheckpoint = Level(curLevel.value).Checkpoints.first
								loop
								exitwhen curCheckpoint == 0 or nextCheckpointID >= 0
									if i > Teams_MazingTeam(curTeam.value).OnCheckpoint and (not Checkpoint(curCheckpoint.value).RequiresSameGameMode or User(curUser.value).GameMode == Checkpoint(curCheckpoint.value).DefaultGameMode) and Checkpoint(curCheckpoint.value).Gate != null and RectContainsCoords(Checkpoint(curCheckpoint.value).Gate, x, y) then
										set Teams_MazingTeam(curTeam.value).LastEventUser = curUser.value
										
										set nextCheckpointID = i
									endif
								set i = i + 1
								set curCheckpoint = curCheckpoint.next
								endloop
							endif
						endif
					set curUser = curUser.next
					endloop
					
					//apply either the next level or the next checkpoint or neither to the current team (never apply both)
					if nextLevel != 0 then
						static if DEBUG_LEVEL_CHANGE then
							call DisplayTextToForce(bj_FORCE_PLAYER[0], "Team entered transfer leading to  " + I2S(nextLevel))
						endif
						
						call Level(curLevel.value).SwitchLevelsAnimated(Teams_MazingTeam(curTeam.value), nextLevel, true)
					elseif nextCheckpointID >= 0 then
						static if DEBUG_CHECKPOINT_CHANGE then
							call DisplayTextToForce(bj_FORCE_PLAYER[0], "Activated by User  " + I2S(Teams_MazingTeam(curTeam.value).LastEventUser))
							call DisplayTextToForce(bj_FORCE_PLAYER[0], "Team entered checkpoint with ID  " + I2S(nextCheckpointID))
						endif
						
						//call Level(curLevel.value).SetCheckpointForTeam(Teams_MazingTeam(curTeam.value), nextCheckpointID)
						call Level(curLevel.value).AnimatedSetCheckpointForTeam(Teams_MazingTeam(curTeam.value), nextCheckpointID)
					endif
					
				set curTeam = curTeam.next
				endloop
                
            set curLevel = curLevel.next
            endloop
        endmethod        
        
		public method AddStartable takes IStartable startable returns nothing
			if startable.ParentLevel != 0 and startable.ParentLevel.Startables != 0 then
				call startable.ParentLevel.Startables.remove(startable)
			endif
			
			set startable.ParentLevel = this
			
			if .Startables == 0 then
				set .Startables = SimpleList_List.create()
			endif
			call .Startables.addEnd(startable)
		endmethod
        
        public method AddCinematic takes Cinematic cinema returns nothing
            call .Cinematics.addEnd(cinema)
            set cinema.ParentLevel = this
        endmethod
        private static method CheckCinematics takes nothing returns nothing
            local SimpleList_ListNode curLevel = thistype.ActiveLevels.first
            local SimpleList_ListNode curCinematic
            local SimpleList_ListNode curTeam
            local SimpleList_ListNode curUser
            
            local User user
            
            loop
            exitwhen curLevel == 0
                set curCinematic = thistype(curLevel.value).Cinematics.first
                
                loop
                exitwhen curCinematic == 0
                    //call DisplayTextToForce(bj_FORCE_PLAYER[0], "Checking cinematic " + I2S(curCinematic.value) + ", total count: " + I2S(thistype(curLevel.value).Cinematics.count))
                    
					set curTeam = thistype(curLevel.value).ActiveTeams.first
                    
                    loop
                    exitwhen curTeam == 0
                        //call DisplayTextToForce(bj_FORCE_PLAYER[0], "Checking team " + I2S(curTeam.value))
                        set curUser = Teams_MazingTeam(curTeam.value).Users.first
                                                
                        loop
                        exitwhen curUser == 0
                            set user = User(curUser.value)
                            //call DisplayTextToForce(bj_FORCE_PLAYER[0], "Checking player " + I2S(curUser.value))
                            
                            if Cinematic(curCinematic.value).CanUserActivate(User(curUser.value)) then
                                //call Cinematic(curCinematic.value).Activate(curUser.value)
                                if Cinematic(curCinematic.value).Individual then
                                    //call DisplayTextToForce(bj_FORCE_PLAYER[0], "User " + I2S(user) + " activating cine " + I2S(curCinematic.value) + " for self")
                                    call user.AddCinematicToQueue(curCinematic.value)
                                else
                                    //call DisplayTextToForce(bj_FORCE_PLAYER[0], "User " + I2S(user) + " activating cine " + I2S(curCinematic.value) + " for team")
                                    call Teams_MazingTeam(curTeam.value).AddTeamCinema(curCinematic.value, user)
                                endif
                            endif
                        set curUser = curUser.next
                        endloop
                        
                    set curTeam = curTeam.next
                    endloop
                    
                set curCinematic = curCinematic.next
                endloop
                
            set curLevel = curLevel.next
            endloop
        endmethod
		
		//creates the level struct / region triggers for the doors area
        public static method CreateDoors takes Level intro, string startFunction, string stopFunction, rect startspawn, rect vision returns Level
            local Level new = DOORS_LEVEL_ID
            
            set new.Name = "Doors"
            set new.RawContinues = 0
            set new.RawScore = 0

			set new.StartFunction = startFunction
			set new.StopFunction = stopFunction
			set new.Startables = 0
			
			set new.Checkpoints = SimpleList_List.create()
            call new.AddCheckpoint(null, startspawn)
            //set new.CPToHere = tothislevel //these might change
            //set new.StartRect = startspawn
            set new.Boundaries = RectList.create()
			call new.Boundaries.addEnd(vision)
                        
            set new.PrevLevel = intro
            set intro.NextLevel = new
			
			set new.Cinematics = SimpleList_List.create()
            set new.ActiveTeams = SimpleList_List.create()
			
			set DoorRects[0] = gg_rct_IW_Entrance
			set DoorRects[1] = gg_rct_EIW_Entrance
			set DoorRects[2] = gg_rct_LW_Entrance
			set DoorRects[5] = gg_rct_FS_Entrance
			set DoorRects[6] = gg_rct_PW_Entrance
			
			
			set new.MaxCollisionSize = DEFAULT_MAX_COLLISION_SIZE
            //call DisplayTextToForce(bj_FORCE_PLAYER[0], "Created doors")
            
            return new
        endmethod
        
		public method AddLevelStartCB takes conditionfunc cb returns nothing
			if .OnLevelStart == 0 then
				set .OnLevelStart = Event.create()
			endif
			
			call .OnLevelStart.register(cb)
		endmethod
		public method AddLevelStopCB takes conditionfunc cb returns nothing
			if .OnLevelStop == 0 then
				set .OnLevelStop = Event.create()
			endif
			
			call .OnLevelStop.register(cb)
		endmethod
		public method AddCheckpointChangeCB takes conditionfunc cb returns nothing
			if .OnCheckpointChange == 0 then
				set .OnCheckpointChange = Event.create()
			endif
			
			call .OnCheckpointChange.register(cb)
		endmethod
		
		
        //creates a level struct
        static method create takes integer LevelID, string name, integer rawContinues, integer rawScore, string startFunction, string stopFunction, rect startspawn, rect vision, rect levelEnd, Level previouslevel returns Level
            local Level new = LevelID
            
            //infer this is a partial level
            //set new.Name = new.ToString()
            set new.Name = name
            set new.RawContinues = rawContinues
            set new.RawScore = rawScore
            //set new.Difficulty = diff
            /*
            set new.Start = start
            set new.Stop = stop
            */
            
			set new.StartFunction = startFunction
			set new.StopFunction = stopFunction
			set new.Startables = 0
            //set new.CPToHere = tothislevel
            //set new.StartRect = startspawn
			set new.Boundaries = RectList.create()
			call new.Boundaries.addEnd(vision)
                                    
            set new.Cinematics = SimpleList_List.create()
            set new.ActiveTeams = SimpleList_List.create()
            
            if (previouslevel != 0) then
                //don't point backwards to partial levels
                set new.PrevLevel = previouslevel
                set new.PrevLevel.NextLevel = new
            endif
            
			set new.LevelEnd = levelEnd
            
			set new.Checkpoints = SimpleList_List.create()
            //use the checkpoint schema for the first checkpoint. region enter event is handled separately, so use null for the region
            call new.AddCheckpoint(null, startspawn)
            
			set new.MaxCollisionSize = DEFAULT_MAX_COLLISION_SIZE
			set new.OnLevelStart = 0
			set new.OnLevelStop = 0
			set new.OnCheckpointChange = 0
			
            return new
        endmethod
		
		private static method onInit takes nothing returns nothing
			//set OnLevelChange = Event.create()
			//set OnCheckpointChange = Event.create()
			
			set thistype.ActiveLevels = SimpleList_List.create()
			
			call TimerStart(CreateTimer(), TRANSFER_TIMER_TIMEOUT, true, function thistype.CheckTransfers)
			call TimerStart(CreateTimer(), CINEMATIC_TIMER_TIMEOUT, true, function thistype.CheckCinematics)			
		endmethod
    endstruct
endlibrary