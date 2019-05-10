library Levels requires SimpleList, Teams, GameModesGlobals, LevelIDGlobals, Cinema, User, IStartable
    globals
		
		constant integer WorldCount = 7
		private rect array DoorRects[WorldCount]
		
		public constant real TRANSFER_TIMER_TIMEOUT = .05
        public constant real CINEMATIC_TIMER_TIMEOUT = .5
        
        public constant real EASY_SCORE_MODIFIER = 1.
        public constant real HARD_SCORE_MODIFIER = 1.25
        public constant real EASY_CONTINUE_MODIFIER = 1.5
        public constant integer EASY_MAX_CONTINUE_ROLLOVER = 3
		public constant integer HARD_MAX_CONTINUE_ROLLOVER = 0
        public constant real HARD_CONTINUE_MODIFIER = .8
        
		private constant boolean DEBUG_START_STOP = false
		private constant boolean DEBUG_LEVEL_CHANGE = false
		
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
    endstruct
    
	public struct Level extends array //extends IStartable
        public string      Name            //a levels name, only used in the multiboard
        public integer     RawContinues      //refers to the difficulty of a level
        public integer     RawScore
        
		private string StartFunction
        private string StopFunction
                
        public SimpleList_List Startables
        
        public rect        Vision          //the bounds placed on a player's vision
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
        //removes units from whatever .Vision is currently set to!
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
        
        public method GetWorldID takes nothing returns integer
            //World levels follow this format
			if this >= 3 and this <= 38 then //last level ID
                return ModuloInteger(this - 3, 7) + 1
			else
				return 0
            endif
        endmethod
        
        public method GetWorldString takes nothing returns string
            local integer onWorld = .GetWorldID()
            
            if onWorld == 0 then
                return ""
            elseif onWorld == 1 then
                return ColorMessage("Black Ice", SAD_TEXT_COLOR)
            elseif onWorld == 2 then
                return ColorMessage("Icetown", SAD_TEXT_COLOR)
            elseif onWorld == 3 then
                return "Sloth"
            elseif onWorld == 4 then
                return "Greed"
            elseif onWorld == 5 then
                return "Wrath"
            elseif onWorld == 6 then
                return "Gluttony"
            else//if onWorld == 7
                return ColorMessage("2.5 Dimensions", HAPPY_TEXT_COLOR)
            endif
        endmethod
        
        public method ToString takes nothing returns string
            local string name
            
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Level ID: " + I2S(this))
            
            if this == INTRO_LEVEL_ID then
                return "Entrance"
            elseif this == DOORS_LEVEL_ID then
                return "Doors"
            else
                set name = .GetWorldString()

                return name + " " + I2S(R2I((this - 3) / 7) + 1)
            endif
        endmethod
                        
        public method RemoveGreenFromLevel takes nothing returns nothing
            local unit u
            
            call GroupEnumUnitsInRect(TempGroup, .Vision, Green)
            set u = FirstOfGroup(TempGroup)
            
            loop
            exitwhen u == null
                //reset unit to default stats based on what can currently change... at some point find a better way to unload modified units (and only them)
                call SetUnitVertexColor(u, 255, 255, 255, 255)
                call SetUnitMoveSpeed(u, GetUnitDefaultMoveSpeed(u))
				if GetUnitUserData(u) != 0 then
					call IndexedUnit(GetUnitUserData(u)).destroy()
				endif
                call Recycle_ReleaseUnit(u)
            call GroupRemoveUnit(TempGroup, u)
            set u = FirstOfGroup(TempGroup)
            endloop
                
            set u = null
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
                        
        public method AddCheckpoint takes rect gate, rect center returns Checkpoint
            local Checkpoint cp = Checkpoint.create(gate, center)
			call .Checkpoints.addEnd(cp)
			
			return cp
        endmethod
                        
		public method ApplyLevelRewards takes User u, Teams_MazingTeam mt, Level nextLevel returns nothing			
			local integer score = 0
			
			local integer originalContinues = mt.GetContinueCount()
			local integer rolloverContinues = 0
			local integer nextLevelContinues = 0
			
			//update score
			if RewardMode == GameModesGlobals_EASY or RewardMode == GameModesGlobals_CHEAT then
				set score = R2I(.RawScore*EASY_SCORE_MODIFIER + .5)
			elseif RewardMode == GameModesGlobals_HARD then
				set score = R2I(.RawScore*HARD_SCORE_MODIFIER + .5)
			endif
            if score > 0 then
				call mt.PrintMessage("Your score has increased by " + ColorMessage(I2S(score), SPEAKER_COLOR))
				call mt.ChangeScore(score)
			endif
			
			//update continues
			if RewardMode == GameModesGlobals_EASY or RewardMode == GameModesGlobals_HARD then				
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
			
			if this == DOORS_LEVEL_ID then
				//call mt.PrintMessage("Starting level " + ColorMessage(nextLevel.Name, SPEAKER_COLOR) + "!")
				if RewardMode == GameModesGlobals_CHEAT then
					call mt.PrintMessage("Starting " + nextLevel.GetWorldString())
				else
					call mt.PrintMessage("Starting " + nextLevel.GetWorldString() + " with " + ColorMessage(I2S(mt.GetContinueCount()), SPEAKER_COLOR) + " continues")
				endif
			else
				if RewardMode != GameModesGlobals_CHEAT and originalContinues != rolloverContinues + nextLevelContinues then
					call mt.PrintMessage("You kept " + ColorMessage(I2S(rolloverContinues), SPEAKER_COLOR) + " of your " + ColorMessage(I2S(originalContinues), SPEAKER_COLOR) + " continues, and gained " + ColorMessage(I2S(nextLevelContinues), SPEAKER_COLOR) + " extra continues to boot")
				endif
			endif
		endmethod
		
		public method StopLevelForTeam takes Teams_MazingTeam mt returns nothing
			set EventPreviousLevel = this
			set this.CBTeam = mt
			
			call mt.ClearCinematicQueue()
            call this.ActiveTeams.remove(mt)
			
			set mt.OnLevel = TEMP_LEVEL_ID
            call this.Stop() //only stops the level if no ones on it
			if this.OnLevelStop != 0 then
				call this.OnLevelStop.fire()
			endif
		endmethod
		public method StartLevelForTeam takes Teams_MazingTeam mt returns nothing
			set EventCurrentLevel = this
            set this.CBTeam = mt
			
			call this.Start() //only starts the next level if there is one
			if this.OnLevelStart != 0 then
				call this.OnLevelStart.fire()
			endif
			
            set mt.OnLevel = this
            call this.ActiveTeams.add(mt)
            
            call mt.AddTeamVision(this.Vision)
			
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Started")
            //team tele, respawn update, vision, pause + unpause
            call this.SetCheckpointForTeam(mt, 0)
		endmethod
		
        //update level continuously or discontinuously from one to the next. IE lvl 1 -> 2 -> 3 -> 4 OR 1 -> 4 -> 2 etc
        public method SwitchLevels takes Teams_MazingTeam mt, Level nextLevel returns nothing			
			static if DEBUG_LEVEL_CHANGE then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "From " + I2S(this) + " To " + I2S(nextLevel))
            endif
			
			call this.StopLevelForTeam(mt)
			
			call nextLevel.StartLevelForTeam(mt)
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
											call DisplayTextToForce(bj_FORCE_PLAYER[0], "You've already beaten that world!")
											set nextLevel = 0
											call User(curUser.value).RespawnAtRect(Teams_MazingTeam(curTeam.value).Revive, true)
										else
											set nextLevel = worldProgress.FurthestLevel.NextLevel
										endif
									endif
								endif
							set i = i + 1
							endloop
						else
							if Level(curLevel.value).LevelEnd != null and RectContainsCoords(Level(curLevel.value).LevelEnd, x, y) then
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
									set nextCheckpointID = i
								endif
							set i = i + 1
							set curCheckpoint = curCheckpoint.next
							endloop
						endif
					set curUser = curUser.next
					endloop
					
					//apply either the next level or the next checkpoint or neither to the current team (never apply both)
					if nextLevel != 0 then
						static if DEBUG_LEVEL_CHANGE then
							call DisplayTextToForce(bj_FORCE_PLAYER[0], "Team entered transfer leading to  " + I2S(nextLevel))
						endif
						call Level(curLevel.value).ApplyLevelRewards(User(curUser.value), Teams_MazingTeam(curTeam.value), nextLevel)
						
						call Teams_MazingTeam(curTeam.value).UpdateWorldProgress(curLevel.value)
						
						call Level(curLevel.value).SwitchLevels(Teams_MazingTeam(curTeam.value), nextLevel)
					elseif nextCheckpointID >= 0 then
						call Level(curLevel.value).SetCheckpointForTeam(Teams_MazingTeam(curTeam.value), nextCheckpointID)
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
            set new.Vision = vision
                        
            set new.PrevLevel = intro
            set intro.NextLevel = new
			
			set new.Cinematics = SimpleList_List.create()
            set new.ActiveTeams = SimpleList_List.create()
			
			set DoorRects[0] = gg_rct_IW_Entrance
			set DoorRects[1] = gg_rct_EIW_Entrance
			set DoorRects[2] = gg_rct_LW_Entrance
			set DoorRects[5] = gg_rct_PW_Entrance
			set DoorRects[6] = gg_rct_FS_Entrance
			
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
            set new.Vision = vision
                                    
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