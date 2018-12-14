library Levels initializer Init requires SimpleList, Teams, GameModesGlobals, Cinema, User, IStartable
    globals
        public Levels_Level array   Levels[100]                 //an array containing all the levels. the index of the array should match its elements levelnumber
        public constant integer     INTRO_LEVEL_ID = 1
        public constant integer     DOORS_LEVEL_ID = 2
        public constant integer     TEMP_LEVEL_ID = 1000
        private region array        DoorsRegions[NumberPlayers]
        
        public constant real CINEMATIC_TIMER_TIMEOUT = .5
        public constant real CHECKPOINT_TIMER_TIMEOUT = .1
        
        public constant real EASY_SCORE_MODIFIER = 1.
        public constant real HARD_SCORE_MODIFIER = 1.25
        public constant real EASY_CONTINUE_MODIFIER = 1.25
        public constant integer EASY_MAX_CONTINUE_ROLLOVER = 2
        public constant real HARD_CONTINUE_MODIFIER = .75
        
		private constant boolean DEBUG_START_STOP = false
		private constant boolean DEBUG_LEVEL_CHANGE = false
    endglobals
    
    struct LevelContent //extends IStartable
        private string StartFunction
        private string StopFunction
        
        public string PreloadFunction
        public string UnloadFunction
        
        public SimpleList_List Startables
                
        public method Start takes nothing returns nothing
            local SimpleList_ListNode startableNode
            
            if .StartFunction != null then
                call ExecuteFunc(.StartFunction)
                
                if .Startables != 0 then
                    //debug call .Startables.print(0)
                    set startableNode = .Startables.first
                    
                    loop
                    exitwhen startableNode == 0
                        call IStartable(startableNode.value).Start()
                    set startableNode = startableNode.next
                    endloop
                endif
            endif
        endmethod
        
        public method Stop takes nothing returns nothing
            local SimpleList_ListNode startableNode
            
            if .StopFunction != null then
                call ExecuteFunc(.StopFunction)
                
                if .Startables != 0 then
                    //debug call .Startables.print(0)
                    set startableNode = .Startables.first
                    
                    loop
                    exitwhen startableNode == 0
                        call IStartable(startableNode.value).Stop()
                    set startableNode = startableNode.next
                    endloop
                endif
            endif
        endmethod
        
        public method HasPreload takes nothing returns boolean
            return this.PreloadFunction != null
        endmethod
        
        public static method create takes string startFunction, string stopFunction returns thistype
            local thistype new = thistype.allocate()
            
            set new.StartFunction = startFunction
            set new.StopFunction = stopFunction
            
            set new.Startables = 0
            set new.PreloadFunction = null
            
            return new
        endmethod
    endstruct
    
    /*
    public struct Checkpoint extends array
        public region Entrance
        public rect ReviveCenter
        public integer DefaultColor
        public integer DefaultGameMode
        public string TeamCB
        
        private static Teams_MazingTeam LastCheckpointTeam
        
        implement alloc
    endstruct
    */
    
    public struct Level //extends IStartable
        readonly integer     LevelID         //the number of a level -- the same as the index
        public string      Name            //a levels name, only used in the multiboard
        public integer     RawContinues      //refers to the difficulty of a level
        public integer     RawScore
        public LevelContent Content          //all the stuff to fill a level with when turned on/off
        /*
        readonly trigger     Start           //this trigger turns a level "on"
        readonly trigger     Stop            //this turns a level "off"
        readonly trigger     Preload         //if the next level requires time to be setup, use this to do it
        readonly trigger     Unload          //if the team dies without continues or leaves before reaching the next level, use this to unload it
        readonly boolean     HasPreload      //some levels have preloads, some don't. this is more for safety than anything else.
        */
        readonly boolean     IsPreloaded     //is this level currently preloaded
        //readonly rect        StartRect       //marks the position to move the revive rect
        public rect        Vision          //the bounds placed on a player's vision
        //readonly rect        CPToHere        //the checkpoint that triggers this level
        public static trigger CPToHereTrigger
        readonly region array CPGates[8]     //entering this region triggers the CP update action
        readonly rect array  CPCenters[8]    //where to refocus the revive rect to
        public integer array CPColors[8]   //what color key should be applied (if any) after transfering
        public integer array CPDefaultGameModes[8]  //
        public boolean array CPRequiresLastCP[8] //can the unit activate this checkpoint at any moment, allowing skill skips, or is it too abusable for this cp and it's easiest to require that they've gotten the last CP already
        private string  TeamStartCB
        private string  TeamStopCB
        readonly static Teams_MazingTeam CBTeam
        readonly integer     CPCount         //how many checkpoints there are registered for the level
        public static trigger CPTrigger //this trigger handles the levels CP events
        public Level         NextLevel       //pointer to the next Level struct
        public Level         PrevLevel       //pointer to the prev Level struct
        //public integer       DefaultGameMode
        public SimpleList_List Cinematics //any cinematics that might be on the level
        
        public SimpleList_List ActiveTeams
        
        public static SimpleList_List ActiveLevels
                        
        public method Start takes nothing returns nothing
            static if DEBUG_START_STOP then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Trying to start level " + I2S(this.LevelID) + ", count: " + I2S(Teams_MazingTeam.GetCountOnLevel(.LevelID)))
            endif
			
            if Teams_MazingTeam.GetCountOnLevel(.LevelID) == 0 then
                call .ActiveLevels.add(this)
                
                call .Content.Start()
                
                if .NextLevel != 0 and .Content.HasPreload() and not .NextLevel.IsPreloaded and Teams_MazingTeam.GetCountOnLevel(.NextLevel.LevelID) == 0 then
                    set .IsPreloaded = true
                    call ExecuteFunc(.Content.PreloadFunction)
                endif
                
                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Started level " + I2S(this.LevelID))
            endif
        endmethod
        
        //stops this level unless someone else is on it
        //removes units from whatever .Vision is currently set to!
        public method Stop takes nothing returns nothing
            local integer countprev = Teams_MazingTeam.GetCountOnLevel(.LevelID)
            
			static if DEBUG_START_STOP then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Trying to stop level " + I2S(this.LevelID) + ", count: " + I2S(countprev))
            endif
			
            if countprev == 0 then
                call .ActiveLevels.remove(this)
                
                call .Content.Stop()
                call .RemoveGreenFromLevel()
                
                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Stopped level " + I2S(this.LevelID))
            endif
        endmethod
        
        public method GetWorldID takes nothing returns integer
            if .LevelID == INTRO_LEVEL_ID or .LevelID == DOORS_LEVEL_ID then
                return -1
            else
                return ModuloInteger(.LevelID - 3, 7)
            endif
        endmethod
        
        public method GetWorldString takes nothing returns string
            local integer onWorld = .GetWorldID()
            
            if onWorld == -1 then
                return ""
            elseif onWorld == 0 then
                return "Envy"
            elseif onWorld == 1 then
                return "Lust"
            elseif onWorld == 2 then
                return "Sloth"
            elseif onWorld == 3 then
                return "Greed"
            elseif onWorld == 4 then
                return "Wrath"
            elseif onWorld == 5 then
                return "Gluttony"
            else//if onWorld == 6
                return "Pride"
            endif
        endmethod
        
        public method ToString takes nothing returns string
            local integer mod
            local string name
            local integer convertedLevel
            
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Level ID: " + I2S(.LevelID))
            
            if .LevelID == INTRO_LEVEL_ID then
                return "Entrance"
            elseif .LevelID == DOORS_LEVEL_ID then
                return "Doors"
            else
                set mod = ModuloInteger(.LevelID - 3, 7)
                
                if mod == 0 then
                    set name = "Envy"
                elseif mod == 1 then
                    set name = "Lust"
                elseif mod == 2 then
                    set name = "Sloth"
                elseif mod == 3 then
                    set name = "Greed"
                elseif mod == 4 then
                    set name = "Wrath"
                elseif mod == 5 then
                    set name = "Gluttony"
                else
                    set name = "Pride"
                endif
                
                //set convertedLevel = R2I((.LevelID - 2) / 7) + 1
                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Name: " + name + " " + I2S(convertedLevel))
                return name + " " + I2S(R2I((.LevelID - 3) / 7) + 1)
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
                call DeindexUnit(u)
                call Recycle_ReleaseUnit(u)
            call GroupRemoveUnit(TempGroup, u)
            set u = FirstOfGroup(TempGroup)
            endloop
                
            set u = null
        endmethod
        
        public method SetCheckpointForTeam takes Teams_MazingTeam mt, integer cpID returns nothing
            if cpID != -1 then
                //call DisplayTextToForce(bj_FORCE_PLAYER[0], "Started setting CP for team " + I2S(mt))
				set mt.OnCheckpoint = cpID
                
                set mt.DefaultGameMode = this.CPDefaultGameModes[cpID]
                //call mt.SwitchGameModeContinuous(mt.DefaultGameMode)
                
                call mt.MoveRevive(this.CPCenters[cpID])
                call mt.RespawnTeamAtRect(this.CPCenters[cpID], true)
                call mt.ApplyKeyToTeam(this.CPColors[cpID])
                
                call mt.UpdateMultiboard()

				//call DisplayTextToForce(bj_FORCE_PLAYER[0], "Finished setting CP for team " + I2S(mt))				
            endif
            
            //TODO add team wide CP effect instead of CP effect on first user in team
            //call CPEffect(mt.FirstUser.value)
        endmethod
        
        public static method EntersCheckpoint takes nothing returns nothing
            local region r = GetTriggeringRegion()
            local unit u = GetTriggerUnit()
            local integer i = GetPlayerId(GetOwningPlayer(u))
            local integer cur = 0
            
            local User user = User.GetUserFromPlayerID(i)
            local Teams_MazingTeam mt = user.Team
            local Level level = Levels[mt.OnLevel]

            
            //call DisplayTextToForce(bj_FORCE_PLAYER[0], "Entering CP on level " + level.Name)
            
            if mt != 0 then
                loop
                    if (r == level.CPGates[cur]) then
                        //call DisplayTextToForce(bj_FORCE_PLAYER[0], "Mathched checkpoint " + I2S(cur) + ", team on: " + I2S(mt.OnCheckpoint))
                        if cur > mt.OnCheckpoint and (not level.CPRequiresLastCP[cur] or mt.OnCheckpoint + 1 == cur) then //alternatively cur == mt.OnCheckpoint + 1 if want to ensure no skipping in level                            
                            call level.SetCheckpointForTeam(mt, cur)
                            
                            call CPEffect(i)
                        endif
                    else
                        //call DisplayTextToForce(bj_FORCE_PLAYER[0], "Region not the same " + I2S(cur))
                    endif
                    
                    set cur = cur + 1
                    exitwhen cur >= level.CPCount
                endloop
            endif
            
        endmethod
                
        public method AddCheckpoint takes rect gate, rect center returns integer
            local integer cpID = .CPCount
            set .CPCenters[cpID] = center
            
            //TODO handle Checkpoint and level transfer logic via custom rect iterator, which only iterates the active levels instead of all available
            set .CPGates[cpID] = CreateRegion()
            if gate != null then
                call RegionAddRect(.CPGates[cpID], gate)
                call TriggerRegisterEnterRegion(.CPTrigger, .CPGates[cpID], PlayerOwned)
            endif
            
            //set defaults
            set .CPColors[cpID] = KEY_NONE //by default no color
            set .CPDefaultGameModes[cpID] = Teams_GAMEMODE_STANDARD
            set .CPRequiresLastCP[cpID] = false
            
            set .CPCount = .CPCount + 1
            
            return cpID
        endmethod
        
        public method AddTeamCB takes string startCB, string stopCB returns nothing
            set .TeamStartCB = startCB
            set .TeamStopCB = stopCB
        endmethod
        
        private static method EntersLevelTransferCallback takes nothing returns nothing
            local timer t = GetExpiredTimer()
            local Teams_MazingTeam mt = Teams_MazingTeam(GetTimerData(t))
            
            if mt != 0 then
                set mt.RecentlyTransferred = false
            endif
            
            call ReleaseTimer(t)
            set t = null
        endmethod
                
        //update level continuously or discontinuously from one to the next. IE lvl 1 -> 2 -> 3 -> 4 OR 1 -> 4 -> 2 etc
        public method SwitchLevels takes Teams_MazingTeam mt, Level nextLevel returns nothing
            local integer originalContinues
			local integer rolloverContinues
			local integer nextLevelContinues
			
			static if DEBUG_LEVEL_CHANGE then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "From (static) " + I2S(this.LevelID) + " To " + I2S(nextLevel.LevelID))
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "From " + I2S(this) + " To " + I2S(nextLevel))
            endif
			
			call mt.ClearCinematicQueue()
			
            set this.CBTeam = mt
            call this.ActiveTeams.remove(mt)
            
            set mt.OnLevel = TEMP_LEVEL_ID
            call this.Stop() //only stops the level if no ones on it. reloads preload scripts after if necessary
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Stopped")
            call nextLevel.Start() //only starts the next level if there is one -- also preloads the following level
            
            set mt.OnLevel = nextLevel.LevelID
			
			if RewardMode == GameModesGlobals_EASY or RewardMode == GameModesGlobals_HARD then
				set originalContinues = mt.ContinueCount
				
				if RewardMode == GameModesGlobals_EASY then
					if mt.ContinueCount > EASY_MAX_CONTINUE_ROLLOVER then
						set rolloverContinues = EASY_MAX_CONTINUE_ROLLOVER
					else
						set rolloverContinues = mt.ContinueCount
					endif
					
					set nextLevelContinues = R2I(nextLevel.RawContinues*EASY_CONTINUE_MODIFIER + .5)
				elseif RewardMode == GameModesGlobals_HARD then
					set rolloverContinues = 0
					set nextLevelContinues = R2I(nextLevel.RawContinues*HARD_CONTINUE_MODIFIER + .5)
				endif
				
				set mt.ContinueCount = rolloverContinues + nextLevelContinues
				
				//call mt.PrintMessage("Starting level " + ColorMessage(nextLevel.Name, SPEAKER_COLOR) + "!")
				call mt.PrintMessage("You kept " + ColorMessage(I2S(rolloverContinues), SPEAKER_COLOR) + " of your " + ColorMessage(I2S(originalContinues), SPEAKER_COLOR) + " continues, and gained " + ColorMessage(I2S(nextLevelContinues), HAPPY_TEXT_COLOR) + " extra continues to boot")
			endif
            
            call nextLevel.ActiveTeams.add(mt)
            
            if this.TeamStopCB != null then
                call ExecuteFunc(this.TeamStopCB)
            endif
            
            if nextLevel.TeamStartCB != null then
                call ExecuteFunc(nextLevel.TeamStartCB)
            endif

            
            call mt.AddTeamVision(nextLevel.Vision)
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Started")
            //team tele, respawn update, vision, pause + unpause
            call nextLevel.SetCheckpointForTeam(mt, 0)
            //rewards system
            
            //Now happens in SetCheckpointForTeam
            //multiboard update
            //call mt.UpdateMultiboard()
        endmethod
        
        //handles transfers
        public static method EntersLevelTransfer takes nothing returns nothing
            //local real elapsed = GameElapsedTime()
            local region r = GetTriggeringRegion()
            local unit   u = GetTriggerUnit()
            local integer i = GetPlayerId(GetOwningPlayer(u))
            
            local User user = User.GetUserFromPlayerID(i)
            local Teams_MazingTeam mt = user.Team
            
            local Level curLevel = Levels[mt.OnLevel]
            local Level nextLevel
			
			local integer score
            
			static if DEBUG_LEVEL_CHANGE then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Entered level transfer region on level " + I2S(curLevel.LevelID))
            endif
			
            //call KillUnit(u)
            if mt != 0 and not mt.RecentlyTransferred then //levels 0, 1 have special hardcoded level transfers -- esp for hub                
                set mt.RecentlyTransferred = true
                //set mt.LastTransferTime = elapsed
                				
                if RewardMode == GameModesGlobals_EASY or RewardMode == GameModesGlobals_CHEAT then
                    set score = R2I(curLevel.RawScore*EASY_SCORE_MODIFIER + .5)
                elseif RewardMode == GameModesGlobals_HARD then
                    set score = R2I(curLevel.RawScore*HARD_SCORE_MODIFIER + .5)
                endif
				
				//call mt.PrintMessage("Cleared level " + ColorMessage(curLevel.Name, SPEAKER_COLOR) + "!")
				call mt.PrintMessage("Your score has increased by " + ColorMessage(I2S(score), HAPPY_TEXT_COLOR))
				
				set mt.Score = mt.Score + score
                
                //determine what the next level is, based on what the current level is
                if mt.OnLevel == DOORS_LEVEL_ID then
                    call mt.MoveReviveToDoors() //not pretty but it works
                    
                    if r == DoorsRegions[0] then
                        debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "ice")
                        set nextLevel = Levels_Levels[3]
                    elseif r == DoorsRegions[1] then
                        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "fdsa ")
                    elseif r == DoorsRegions[2] then
                        debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "pride")
                        set nextLevel = Levels_Levels[9]
                    else
                        call DisplayTextToForce(bj_FORCE_PLAYER[0], "couldn't match region")
                    endif
                else
                    set nextLevel = curLevel.NextLevel
                    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "going to " + nextLevel.Name)
                endif
                
                call curLevel.SwitchLevels(mt, nextLevel)
                
                call TimerStart(NewTimerEx(mt), .5, false, function Levels_Level.EntersLevelTransferCallback)
            endif            
        endmethod
        
        //creates the level struct / region triggers for the doors area
        public static method CreateDoors takes Level intro, string startFunction, string stopFunction, rect startspawn, rect vision, rect tothislevel returns Level
            local Level new = Level.allocate()
            local trigger t
            local region r
            
            set new.LevelID = DOORS_LEVEL_ID
            set new.Name = "Doors"
            set new.RawContinues = 0
            set new.RawScore = 0

            set new.Content = Content.create(startFunction, stopFunction)
            set new.CPCount = 0
            call new.AddCheckpoint(null, startspawn)
            //set new.CPToHere = tothislevel //these might change
            //set new.StartRect = startspawn
            set new.Vision = vision
            
            set new.IsPreloaded = false
            
            set Levels[new.LevelID] = new
            set new.PrevLevel = intro
            set intro.NextLevel = new
            
            //call DisplayTextToForce(bj_FORCE_PLAYER[0], I2S(Levels[1]) + " " + I2S(Levels[1].PrevLevel) + " " + I2S(Levels[1].PrevLevel.NextLevel))
            
            //set t = CreateTrigger()
            set r = CreateRegion()
            
            call RegionAddRect(r, tothislevel)
            call TriggerRegisterEnterRegion(.CPToHereTrigger, r, PlayerOwned)
            //call TriggerAddAction(t, function Level.EntersLevelTransfer)
            
            //why did i do this...?
            //! textmacro Levels_CreateDoorsTrigger takes COUNT, RECT
                set r = CreateRegion()
                call RegionAddRect(r, $RECT$)
                set DoorsRegions[$COUNT$] = r
                call TriggerRegisterEnterRegion(.CPToHereTrigger, r, PlayerOwned)
                call TriggerAddAction(.CPToHereTrigger, function Level.EntersLevelTransfer)
            //! endtextmacro
            
            //! runtextmacro Levels_CreateDoorsTrigger("0", "gg_rct_IW_Entrance"))
            //! runtextmacro Levels_CreateDoorsTrigger("1", "gg_rct_LW_Entrance"))
            //! runtextmacro Levels_CreateDoorsTrigger("2", "gg_rct_PW_Entrance"))
            
            set t = null
            set r = null
            //call DisplayTextToForce(bj_FORCE_PLAYER[0], "Created doors")
            
            return new
        endmethod
        
        public method UnPreload takes nothing returns nothing
            //check that this level is already preloaded, and that there are no teams on this level or the one before it
            if .Content.HasPreload() and .IsPreloaded and Teams_MazingTeam.GetCountOnLevel(.PrevLevel.LevelID) == 0 and Teams_MazingTeam.GetCountOnLevel(.LevelID) == 0 then
                set .IsPreloaded = false
                call ExecuteFunc(.Content.UnloadFunction)
            endif
        endmethod
        
        public method addPreload takes string preloadFunction, string unloadFunction returns nothing
            set .Content.PreloadFunction = preloadFunction
            set .Content.UnloadFunction = unloadFunction
        endmethod
        
        public method GetContent takes nothing returns LevelContent
            return .Content
        endmethod
        public method SetStartables takes SimpleList_List startables returns nothing
            set .Content.Startables = startables
        endmethod
        
        public method AddCinematic takes Cinematic cinema returns nothing
            call .Cinematics.addEnd(cinema)
            set cinema.ParentLevel = this
        endmethod
        public static method CheckCinematics takes nothing returns nothing
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
        
        //creates a level struct
        static method create takes integer LevelID, string name, integer rawContinues, integer rawScore, string startFunction, string stopFunction, rect startspawn, rect vision, rect tothislevel, Level previouslevel returns Level
            local Level new = Level.allocate()
            local region r
            
            //infer this is a partial level
            set new.LevelID = LevelID
            //set new.Name = new.ToString()
            set new.Name = name
            set new.RawContinues = rawContinues
            set new.RawScore = rawScore
            //set new.Difficulty = diff
            /*
            set new.Start = start
            set new.Stop = stop
            set new.HasPreload = false
            */
            set new.Content = LevelContent.create(startFunction, stopFunction)
            //set new.CPToHere = tothislevel
            //set new.StartRect = startspawn
            set new.Vision = vision
                        
            set new.TeamStartCB = null
            set new.TeamStopCB = null
            
            set new.IsPreloaded = false
            
            set new.Cinematics = SimpleList_List.create()
            set new.ActiveTeams = SimpleList_List.create()
            
            if (previouslevel != 0) then
                //don't point backwards to partial levels
                set new.PrevLevel = previouslevel
                set new.PrevLevel.NextLevel = new
            endif
            
            if tothislevel != null then
                set r = CreateRegion()
                call RegionAddRect(r, tothislevel)
            
                call TriggerRegisterEnterRegion(.CPToHereTrigger, r, PlayerOwned)
                
                set r = null
            endif
            
            set new.CPCount = 0
            //use the checkpoint schema for the first checkpoint. region enter event is handled separately, so use null for the region
            call new.AddCheckpoint(null, startspawn)
            
            set Levels[LevelID] = new
            return new
        endmethod
    endstruct
    
    private function Init takes nothing returns nothing
        set Levels_Level.CPToHereTrigger = CreateTrigger()
        set Levels_Level.CPTrigger = CreateTrigger()
        set Levels_Level.ActiveLevels = SimpleList_List.create()
    
        call TriggerAddAction(Levels_Level.CPToHereTrigger, function Levels_Level.EntersLevelTransfer)
        call TriggerAddAction(Levels_Level.CPTrigger, function Levels_Level.EntersCheckpoint)
        
        call TimerStart(CreateTimer(), CINEMATIC_TIMER_TIMEOUT, true, function Levels_Level.CheckCinematics)
    endfunction

endlibrary