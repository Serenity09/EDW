library Levels initializer Init requires ListModule, Teams, GameModesGlobals, IStartable
    globals
        public Levels_Level array   Levels[100]                 //an array containing all the levels. the index of the array should match its elements levelnumber
        public timer                LevelTimer = CreateTimer()
        public constant integer     INTRO_LEVEL_ID = 1
        public constant integer     DOORS_LEVEL_ID = 2
        public constant integer     TEMP_LEVEL_ID = 1000
        private region array        DoorsRegions[NumberPlayers]
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
        public integer     ParContinues      //refers to the difficulty of a level
        public integer     Difficulty
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
        public static trigger CPToHereTrigger = CreateTrigger()
        readonly region array CPGates[4]     //entering this region triggers the CP update action
        readonly rect array  CPCenters[4]    //where to refocus the revive rect to
        public integer array CPColors[4]   //what color key should be applied (if any) after transfering
        public integer array CPDefaultGameModes[4]  //
        private string  TeamStartCB
        private string  TeamStopCB
        readonly static Teams_MazingTeam CBTeam
        readonly integer     CPCount         //how many checkpoints there are registered for the level
        public static trigger CPTrigger = CreateTrigger() //this trigger handles the levels CP events
        public Level         NextLevel       //pointer to the next Level struct
        public Level         PrevLevel       //pointer to the prev Level struct
        //public integer       DefaultGameMode
        
        readonly boolean     Starting        //true if another thread is starting this level
        readonly boolean     Stopping        //true if another thread is stopping this level
                        
        public method Start takes nothing returns nothing
            debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Trying to start level " + I2S(this.LevelID) + ", count: " + I2S(Teams_MazingTeam.GetCountOnLevel(.LevelID)))
            
            if Teams_MazingTeam.GetCountOnLevel(.LevelID) == 0 and not .Starting then
                set .Starting = true
                                
                call .Content.Start()
                
                if .NextLevel != 0 and .Content.HasPreload() and not .NextLevel.IsPreloaded and Teams_MazingTeam.GetCountOnLevel(.NextLevel.LevelID) == 0 then
                    set .IsPreloaded = true
                    call ExecuteFunc(.Content.PreloadFunction)
                endif
                
                set .Starting = false
                
                //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Started level " + I2S(this.LevelID))
            endif
        endmethod
        
        //stops this level unless someone else is on it
        //removes units from whatever .Vision is currently set to!
        public method Stop takes nothing returns nothing
            local integer countprev = Teams_MazingTeam.GetCountOnLevel(.LevelID)
            
            debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Trying to stop level " + I2S(this.LevelID) + ", count: " + I2S(countprev))
            
            if countprev == 0 and not .Stopping and not .Starting then
                set .Stopping = true
                
                call .Content.Stop()
                call .RemoveGreenFromLevel()
                
                set .Stopping = false
                
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
                set mt.OnCheckpoint = cpID
                
                set mt.DefaultGameMode = this.CPDefaultGameModes[cpID]
                //call mt.SwitchGameModeContinuous(mt.DefaultGameMode)
                
                call mt.MoveRevive(this.CPCenters[cpID])
                call mt.RespawnTeamAtRect(this.CPCenters[cpID], true)
                call mt.ApplyKeyToTeam(this.CPColors[cpID])
                
                call mt.UpdateMultiboard()                
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
                        //call DisplayTextToForce(bj_FORCE_PLAYER[0], "On checkpoint " + I2S(cur))
                        if cur > mt.OnCheckpoint then //alternatively cur == mt.OnCheckpoint + 1 if want to ensure no skipping in level                            
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
            //if .CPCount == 0 then
                //set .CPTrigger = CreateTrigger()
                //call TriggerAddAction(.CPTrigger, function Levels_Level.EntersCheckpoint)
            //endif            
            set .CPCenters[cpID] = center
            set .CPGates[cpID] = CreateRegion()
            set .CPColors[cpID] = KEY_NONE //by default no color
            set .CPDefaultGameModes[cpID] = Teams_GAMEMODE_STANDARD
            
            if gate != null then
                call RegionAddRect(.CPGates[cpID], gate)
                call TriggerRegisterEnterRegion(.CPTrigger, .CPGates[cpID], PlayerOwned)
            endif
            
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
            debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "From (static) " + I2S(this.LevelID) + " To " + I2S(nextLevel.LevelID))
            debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "From " + I2S(this) + " To " + I2S(nextLevel))
            
            set this.CBTeam = mt
            
            set mt.OnLevel = TEMP_LEVEL_ID
            call this.Stop() //only stops the level if no ones on it. reloads preload scripts after if necessary
            //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Stopped")
            call nextLevel.Start() //only starts the next level if there is one -- also preloads the following level
            set mt.OnLevel = nextLevel.LevelID
            
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
            
            //call DisplayTextToForce(bj_FORCE_PLAYER[0], "From " + I2S(curLevel.LevelID))
            
            //call KillUnit(u)
            if mt != 0 and not mt.RecentlyTransferred then //levels 0, 1 have special hardcoded level transfers -- esp for hub                
                set mt.RecentlyTransferred = true
                //set mt.LastTransferTime = elapsed
                
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
            set new.Name = new.ToString()
            /*
            set new.Start = null
            set new.Stop = null
            set new.Preload = null
            set new.Unload = null
            set new.HasPreload = false
            */
            set new.Content = Content.create(startFunction, stopFunction)
            set new.CPCount = 0
            call new.AddCheckpoint(null, startspawn)
            //set new.CPToHere = tothislevel //these might change
            //set new.StartRect = startspawn
            set new.Vision = vision
            
            set new.Starting = false //these shouldn't
            set new.Stopping = false
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
        
        //creates a level struct
        static method create takes integer LevelID, /*string name, integer diff, */string startFunction, string stopFunction, rect startspawn, rect vision, rect tothislevel, Level previouslevel returns Level
            local Level new = Level.allocate()
            local region r
            
            //infer this is a partial level
            set new.LevelID = LevelID
            set new.Name = new.ToString()
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
            set new.Starting = false
            set new.Stopping = false
            
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
        call TriggerAddAction(Levels_Level.CPToHereTrigger, function Levels_Level.EntersLevelTransfer)
        call TriggerAddAction(Levels_Level.CPTrigger, function Levels_Level.EntersCheckpoint)
    endfunction

endlibrary