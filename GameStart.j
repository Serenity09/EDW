library GameStart initializer Init requires Levels, EDWVisualVote, UnitGlobals, MazerGlobals
    globals
        constant real GAME_INIT_TIME_INITIAL = 0.01 //how long into the game before we start
        //constant real GAME_INIT_TIME_STEP = .5
        public timer GameInitTimer
        
        constant string SPEAKER_COLOR = "FFFFBD33"
        constant string DEFAULT_TEXT_COLOR = null
        constant string HAPPY_TEXT_COLOR = null
        constant string SAD_TEXT_COLOR = null
        constant string ANGRY_TEXT_COLOR = null
        constant string STERN_TEXT_COLOR = null
        
        constant string PRIMARY_SPEAKER_NAME = "SARGE"
        constant string SECONDARY_SPEAKER_NAME = "Cupcake"
        
        constant string FINAL_BOSS_PRE_REVEAL = "???"
        constant string FINAL_BOSS_NAME = "???" //??? no, seriously, what's the final boss?
        
        constant real DEFAULT_TINY_TEXT_SPEED = 1.0
        constant real DEFAULT_SHORT_TEXT_SPEED = 3.0
        constant real DEFAULT_MEDIUM_TEXT_SPEED = 5.0
        constant real DEFAULT_LONG_TEXT_SPEED = 8.0
    endglobals
    
    private function PlayerInit takes nothing returns nothing
        local SimpleList_ListNode fp = PlayerUtils_FirstPlayer
        local User u
        
        loop
        exitwhen fp == 0
            set u = fp.value
            
            if u.IsPlaying then
                set u.ActiveUnit = MazersArray[u]
            endif
        set fp = fp.next
        endloop
    endfunction
                    
    private function PreplacedUnitInit takes nothing returns nothing
        local unit u
        local integer uID
                
        call GroupEnumUnitsInRect(TempGroup, bj_mapInitialPlayableArea, null)
        
        loop
        set u = FirstOfGroup(TempGroup)
        exitwhen u == null
            set uID = GetUnitTypeId(u)
            
            if uID == POWERUP_MARKER then
                call InWorldPowerup.CreateRandom(GetUnitX(u), GetUnitY(u))
                call RemoveUnit(u)
            elseif uID == UBOUNCE then
                call AddUnitLocust(CreateUnit(Player(11), UBOUNCE, GetUnitX(u), GetUnitY(u), 90))
                call RemoveUnit(u)
            elseif uID == LBOUNCE then
                call AddUnitLocust(CreateUnit(Player(11), LBOUNCE, GetUnitX(u), GetUnitY(u), 180))
                call RemoveUnit(u)
            elseif uID == DBOUNCE then
                call AddUnitLocust(CreateUnit(Player(11), DBOUNCE, GetUnitX(u), GetUnitY(u), 270))
                call RemoveUnit(u)
            elseif uID == RBOUNCE then
                call AddUnitLocust(CreateUnit(Player(11), RBOUNCE, GetUnitX(u), GetUnitY(u), 0))
                call RemoveUnit(u)
            endif            
        call GroupRemoveUnit(TempGroup, u)
        endloop
        
        call GroupClear(TempGroup)
    endfunction

    
    private function LevelRewardsInit takes nothing returns nothing
        if RewardMode == 0 or RewardMode == 2 then
            
        elseif RewardMode == 1 then
            
        endif
    endfunction
    
    private function CreateTutorialTexttags takes nothing returns nothing
        local texttag tt = CreateTextTag()
        
        
        
        set tt = null
        //call TextTag
    endfunction
        
    public function First takes nothing returns nothing
        //INITIALIZE MAP SETTINGS
        //time should be fixed at noon
        call SetFloatGameState(GAME_STATE_TIME_OF_DAY, 12.00001)
        call SetTimeOfDayScale(0)
        
        //ADD LOCUST TO ALL OF BROWNS UNITS
        call AddLocustAll()
        
        //CALL OTHER INITS
        call PlayerInit()
        call PreplacedUnitInit()
        
        //GAME MODE INIT
        //Menu should happen after level creation so that it doesn't mess with the number of players on the intro world
        //use single players when in debug mode, now that menu is functional
        call EDWVisualVote_CreateMenu()
        
        debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Finished GameStart")
    endfunction
    
    private function GetEDWSpeakerMessage takes string speaker, string message, string messageColor returns string
        if messageColor == null then
            return "|c" + SPEAKER_COLOR + speaker + "|r" + ": " + message
        else
            return "|c" + SPEAKER_COLOR + speaker + "|r" + ": " + "|c" + messageColor + message + "|r"
        endif
    endfunction
    
    private function IsUserRed takes User user returns boolean
        return MazerColor[user] == KEY_RED
    endfunction
    private function IsUserNotRed takes User user returns boolean
        return MazerColor[user] != KEY_RED
    endfunction
    private function IsUserPlayerOne takes User user returns boolean
        return user == 0
    endfunction
    private function IsUserPlayerTwo takes User user returns boolean
        return user == 1
    endfunction
    private function IsUserCinemaQueueBig takes User user returns boolean
        return user.CinematicQueue.count >= 3
    endfunction
    private function IsUserCinemaQueueEmpty takes User user returns boolean
        return user.CinematicQueue.count == 0
    endfunction
    private function IsUserDying takes User user returns boolean
        return user.GameMode == Teams_GAMEMODE_DYING or user.GameMode == Teams_GAMEMODE_DEAD
    endfunction
        
    public function Init takes nothing returns nothing
        local Levels_Level l
        local integer cpID
        
        local SimpleList_List startables
        
        local BoundedSpoke boundedSpoke
        local Wheel wheel
        local BoundedWheel boundedWheel
        
        local SimpleGenerator sg
        local RelayGenerator rg
        
        local Cinematic cine
        local CinemaMessage cineMsg
        
        local integer i
        
        set GameInitTimer = CreateTimer()
        call TimerStart(GameInitTimer, GAME_INIT_TIME_INITIAL, false, function GameStart_First)
        
        //FIRST LEVEL INITS HARD CODED
        set l = Levels_Level.create(1, "???", 0, 0, "IntroWorldLevelStart", "IntroWorldLevelStop", gg_rct_IntroWorld_R1, gg_rct_IntroWorld_Vision, null, 0)
        //1st level is now handled in EDWVisualVote vote finish callback
        //call l.StartLevel() //just start it, intro level vision handled by Reveal Intro World... i like the reveal effect
        call l.AddCheckpoint(gg_rct_IntroWorldCP_1_1, gg_rct_IntroWorld_R2)
        call l.AddCheckpoint(gg_rct_IntroWorldCP_1_2a, gg_rct_IntroWorld_R3a)
        call l.AddCheckpoint(gg_rct_IntroWorldCP_1_2, gg_rct_IntroWorld_R3)
        
        set startables = SimpleList_List.create()
        
        set boundedSpoke = BoundedSpoke.create(11970, 14465)
        set boundedSpoke.InitialOffset = 1*TERRAIN_TILE_SIZE
        set boundedSpoke.LayerOffset = 2.25*TERRAIN_QUADRANT_SIZE
        set boundedSpoke.CurrentRotationSpeed = bj_PI / 5 * BoundedSpoke_TIMESTEP
        call boundedSpoke.AddUnits('e00A', 3)
        call boundedSpoke.SetAngleBounds(bj_PI/4, bj_PI * 3/4)
        
        call startables.add(boundedSpoke)
        
        set l.Content.Startables = startables
        
        /*
        set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage(FINAL_BOSS_PRE_REVEAL, "Welcome", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_WelcomeMessage, false, false, cineMsg)
        call cine.AddMessage(null, GetEDWSpeakerMessage(FINAL_BOSS_PRE_REVEAL, "To", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        call cine.AddMessage(null, GetEDWSpeakerMessage(FINAL_BOSS_PRE_REVEAL, "Dream World", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        call l.AddCinematic(cine)
        */
        
        set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Hey you!", STERN_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_WelcomeMessage, false, false, cineMsg)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Yeah, you", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "...Maggot", ANGRY_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Sorry, but that just felt right", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        call l.AddCinematic(cine)
                
        set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Anyways, like I was saying, how'd we even get into this pit?", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeIntro, false, false, cineMsg)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Well one things for clear", DEFAULT_TEXT_COLOR), DEFAULT_TINY_TEXT_SPEED)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "I drank WAY too much last night", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "And you definitely shouldn't get near those colorful dragons", STERN_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "...I think they might be pedophiles", DEFAULT_TEXT_COLOR), DEFAULT_TINY_TEXT_SPEED)
        call l.AddCinematic(cine)
        
        set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Whoa!", STERN_TEXT_COLOR), DEFAULT_TINY_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeFireWarning, true, false, cineMsg)
        set cine.ActivationCondition = IsUserNotRed
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Better stay clear of that fire, I don't think it likes the look of you", STERN_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
        call l.AddCinematic(cine)
                
        set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Nice!", HAPPY_TEXT_COLOR), DEFAULT_TINY_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeFoundRed, true, false, cineMsg)
        set cine.ActivationCondition = IsUserRed
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Your skin's glowing red!", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "I bet you could go through that fire now", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Everyone knows that the best color is the same color!", DEFAULT_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
        call l.AddCinematic(cine)
        
        set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Hah, classic Red", HAPPY_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeBeatRed, true, false, cineMsg)
        set cine.ActivationCondition = IsUserRed
        call l.AddCinematic(cine)
        
        set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Wow...", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeVines, true, false, cineMsg)
        set cine.ActivationCondition = IsUserCinemaQueueEmpty
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "It's like a Special Ed class took a field trip to a Catholic Church", DEFAULT_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
        call l.AddCinematic(cine)
                        
        set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "I see that you, too, hold a secret passion for the elegant art of figure skating", DEFAULT_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_IceTutorial, false, false, cineMsg)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Remember to hold your head high, and always face towards your future", DEFAULT_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "There's no stopping, just relentless progress towards that future", DEFAULT_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Keep track of yourself using the arrow keys or mouse, or type '-track' or '-t'", DEFAULT_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
        call l.AddCinematic(cine)
        
        set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Another one of these shimmering portals...", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeCheckpoint, true, false, cineMsg)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Stepping over them seems to give you a checkpoint, and bring back the souls of your friends", DEFAULT_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "But are they the same friends, or are these just copies?", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        call l.AddCinematic(cine)
        
        set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Ahhh, I'd know that brick terrain anywhere", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargePlatformingTile, true, false, cineMsg)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Brings me right back to my time in 'Nam", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Touching it will change your world", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        call l.AddCinematic(cine)
        
        set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Pull yourself together soldier!", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargePlatformingMovement, true, false, cineMsg)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "You're a circle now!", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Show some dignity, and use your arrow keys to move", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        call l.AddCinematic(cine)
        
        set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Jesus christ, no, not like that", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeJump, true, false, cineMsg)
        set cine.ActivationCondition = IsUserDying
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Press up to jump UP!", DEFAULT_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "I swear, you're the reason I needed to add these tutorials", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        call l.AddCinematic(cine)
        
        set cineMsg = CinemaMessage.create(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Now, hold that wall close,", DEFAULT_TEXT_COLOR), DEFAULT_SHORT_TEXT_SPEED)
        set cine = Cinematic.create(gg_rct_SargeWallJump, true, false, cineMsg)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "Like it was your fiance who promised that you'd never be alone but died far too young in a horrible accident that was no ones fault but has still left you a soul-less husk", DEFAULT_TEXT_COLOR), DEFAULT_TINY_TEXT_SPEED)
        call cine.AddMessage(null, GetEDWSpeakerMessage(PRIMARY_SPEAKER_NAME, "And then press the Up key to do a wall-jump!", DEFAULT_TEXT_COLOR), DEFAULT_MEDIUM_TEXT_SPEED)
        call l.AddCinematic(cine)
        
        //DOORS HARD CODED
        //currently no start or stop logic
        call Levels_Level.CreateDoors(l, null, null, gg_rct_HubWorld_R, gg_rct_HubWorld_Vision, gg_rct_IntroWorld_End)
        
        //REMAINING LEVELS
        //takes integer levelID, trigger start, trigger stop, trigger preload, trigger unload, boolean haspreload, rect startspawn, rect vision, rect tothislevel, Level previouslevel returns Level
        //config extension methods:
        //.setPreload(trigger preload, trigger unload) returns Levels_Level
        //ICE WORLD TECH / ENVY WORLD
        //LEVEL 1
        set l = Levels_Level.create(3, "Cruise Control", 3, 2, "IW1Start", "IW1Stop", gg_rct_IWR_1_1, gg_rct_IW1_Vision, null, 0)
        call l.AddCheckpoint(gg_rct_IWCP_1_1, gg_rct_IWR_1_2)
        
        set startables = SimpleList_List.create()
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW1_Mortar1 , gg_rct_IW1_Target1))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW1_Mortar2 , gg_rct_IW1_Target2))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW1_Mortar3 , gg_rct_IW1_Target3))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW1_Mortar1 , gg_rct_IW1_Target1))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW1_Mortar2 , gg_rct_IW1_Target2))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW1_Mortar3 , gg_rct_IW1_Target3))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW1_Mortar1 , gg_rct_IW1_Target1))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW1_Mortar2 , gg_rct_IW1_Target2))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW1_Mortar3 , gg_rct_IW1_Target3))
        set l.Content.Startables = startables
        //call l.SetStartables(startables)
        
        //LEVEL 2
        set l = Levels_Level.create(10, "Jesus on the Wheel", 6, 4, "IW2Start", "IW2Stop", gg_rct_IWR_2_1, gg_rct_IW2_Vision, gg_rct_IW1_End, l)
        call l.AddCheckpoint(gg_rct_IWCP_2_1, gg_rct_IWR_2_2)
        call l.AddCheckpoint(gg_rct_IWCP_2_2, gg_rct_IWR_2_3)
        
        set startables = SimpleList_List.create()
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW2_Mortar1 , gg_rct_IW2_Target1))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW2_Mortar2 , gg_rct_IW2_Target2))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW2_Mortar1 , gg_rct_IW2_Target1))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW2_Mortar2 , gg_rct_IW2_Target2))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW2_Mortar1 , gg_rct_IW2_Target1))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW2_Mortar2 , gg_rct_IW2_Target2))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW2_Mortar1 , gg_rct_IW2_Target1))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW2_Mortar2 , gg_rct_IW2_Target2))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW2_Mortar1 , gg_rct_IW2_Target1))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW2_Mortar2 , gg_rct_IW2_Target2))
        set l.Content.Startables = startables
        
        //LEVEL 3
        set l = Levels_Level.create(17, "Illidan Goes Skiing", 6, 8, "IW3Start", "IW3Stop", gg_rct_IWR_3_1, gg_rct_IW3_Vision, gg_rct_IW2_End, l)
        call l.AddCheckpoint(gg_rct_IWCP_3_1, gg_rct_IWR_3_2)
        call l.AddCheckpoint(gg_rct_IWCP_3_2, gg_rct_IWR_3_3)
        call l.AddCheckpoint(gg_rct_IWCP_3_3, gg_rct_IWR_3_4)
        
        set startables = SimpleList_List.create()
        call startables.add(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_IW3_Drunks_1, 6, 5, LGUARD, 24))
        call startables.add(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_IW3_Drunks_2, 8, 6, LGUARD, 16))
        set l.Content.Startables = startables
        
        //LEVEL 4
        set l = Levels_Level.create(24, "Hard Angles", 4, 6, "IW4Start", "IW4Stop", gg_rct_IWR_4_1, gg_rct_IW4_Vision, gg_rct_IW3_End, l)
        set cpID = l.AddCheckpoint(gg_rct_IWCP_4_1, gg_rct_IWR_4_2)
        set l.CPColors[cpID] = KEY_RED
        call l.AddCheckpoint(gg_rct_IWCP_4_2, gg_rct_IWR_4_3)
        
        set startables = SimpleList_List.create()

        call startables.add(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_IW4_Drunks, 6, 5, LGUARD, 24))
        call startables.add(Blackhole.create(8958, 6400))
        //
        set rg = RelayGenerator.create(5373, 9984, 3, 6, 270, 0, LGUARD, 2.)
        call rg.AddTurnSimple(0, 6)
        call rg.AddTurnSimple(90, 0)
        call rg.EndTurns(90)
        
        call startables.add(rg)
        //
        set rg = RelayGenerator.create(6654, 6528, 3, 6, 90, 7, LGUARD, 1.5)
        call rg.AddTurnSimple(180, 7)
        call rg.AddTurnSimple(270, 1)
        call rg.AddTurnSimple(0, 13)
        call rg.AddTurnSimple(90, 3)
        call rg.AddTurnSimple(0, 6)
        call rg.AddTurnSimple(270, 1)
        call rg.AddTurnSimple(0, 1)
        call rg.AddTurnSimple(90, 1)
        call rg.AddTurnSimple(0, 3)
        call rg.EndTurns(0)
        
        call startables.add(rg)
        //
        set rg = RelayGenerator.create(3830, 6278, 3, 6, 90, 3, GUARD, 3.)
        call rg.AddTurnSimple(0, 1)
        call rg.AddTurnSimple(270, 3)
        call rg.EndTurns(270)
        
        call startables.add(rg)
        
        set l.Content.Startables = startables
        
        //LEVEL 5
        set l = Levels_Level.create(31, "This Levels a Mess", 4, 4, "IW5Start", "IW5Stop", gg_rct_IWR_5_1, gg_rct_IW5_Vision, gg_rct_IW4_End, l)
        call l.AddCheckpoint(gg_rct_IWCP_5_1, gg_rct_IWR_5_2)
        
        set startables = SimpleList_List.create()
        set l.Content.Startables = startables
        
        call startables.add(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_IW5_Drunks_3, 2, 2, GUARD, 12))
        call startables.add(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_IW5_Drunks_2, 6, 3.5, LGUARD, 16))
        call startables.add(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_IW5_Drunks_1, 10, 8, LGUARD, 60))
        
                
        //PRIDE WORLD / PLATFORMING
        //LEVEL 1
        set l = Levels_Level.create(9, "Perspective", 4, 2, "PW1Start", "PW1Stop", gg_rct_PWR_1_1, gg_rct_PW1_Vision, null, 0) //gg_rct_PW1_Vision
        call l.AddCheckpoint(gg_rct_PWCP_1_1, gg_rct_PWR_1_2)
        call l.AddCheckpoint(gg_rct_PWCP_1_2, gg_rct_PWR_1_3)
        call l.AddCheckpoint(gg_rct_PWCP_1_3, gg_rct_PWR_1_4)
        
        set startables = SimpleList_List.create()
        set l.Content.Startables = startables
        
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_Rect_340 , gg_rct_Rect_339))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_Rect_340 , gg_rct_Rect_339))
        
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_Rect_352 , gg_rct_Rect_351))
        
        
        //LEVEL 2
        set l = Levels_Level.create(16, "Palindrome", 5, 5, "PW2Start", "PW2Stop", gg_rct_PWR_2_1, gg_rct_PW2_Vision, gg_rct_PW1_End, l) //gg_rct_PW1_Vision
        //set cpID = l.AddCheckpoint(gg_rct_PWCP_2_1, gg_rct_PWR_2_2)
        set cpID = l.AddCheckpoint(gg_rct_PWCP_2_2, gg_rct_PWR_2_3)
        set cpID = l.AddCheckpoint(gg_rct_PWCP_2_3, gg_rct_PWR_2_4)
        set l.CPDefaultGameModes[cpID] = Teams_GAMEMODE_PLATFORMING
        set cpID = l.AddCheckpoint(gg_rct_PWCP_2_4, gg_rct_PWR_2_5)
        set l.CPDefaultGameModes[cpID] = Teams_GAMEMODE_PLATFORMING
        set l.CPRequiresLastCP[cpID] = true
                
        set startables = SimpleList_List.create()
        set l.Content.Startables = startables
        
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_PW2_Mortar , gg_rct_PW2_Target))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_PW2_Mortar , gg_rct_PW2_Target))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_PW2_Mortar , gg_rct_PW2_Target))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_PW2_Mortar , gg_rct_PW2_Target))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_PW2_Mortar , gg_rct_PW2_Target))
        call startables.add(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_PW2_Mortar , gg_rct_PW2_Target))
        
        //public static method create takes rect spawn, real spawntimeout, real walktimeout, integer uid, real lifespan returns thistype
        call startables.add(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_PW2_Drunks_1, 4, 3, LGUARD, 17))
        call startables.add(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_PW2_Drunks_1, 10, 3, GUARD, 8))
        call startables.add(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_PW2_Drunks_2, 6, 3, LGUARD, 8))
        call startables.add(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_PW2_Drunks_3, 5, 2.5, LGUARD, 14))
        call startables.add(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_PW2_Drunks_4, 4, 6, LGUARD, 10))
        
        set rg = RelayGenerator.create(8186, -3191, 3, 5, 0, 0, ICETROLL, 2.)
        call rg.AddTurnSimple(90, 4)
        call rg.AddTurnSimple(180, 1)
        call rg.AddTurnSimple(270, 0)
        call rg.AddTurnSimple(180, 0)
        call rg.AddTurnSimple(270, 1)
        call rg.AddTurnSimple(180, 1)
        call rg.AddTurnSimple(90, 3)
        call rg.AddTurnSimple(180, 1)
        call rg.AddTurnSimple(270, 0)
        call rg.AddTurnSimple(180, 3)
        call rg.AddTurnSimple(90, 8)
        call rg.AddTurnSimple(0, 5)
        call rg.AddTurnSimple(270, 0)
        call rg.AddTurnSimple(0, 3)
        call rg.AddTurnSimple(90, 0)
        call rg.AddTurnSimple(0, 12)
        call rg.EndTurns(0)
        
        //call DisplayTextToForce(bj_FORCE_PLAYER[0], "PW2 RG: " + rg.ToString())
        debug call rg.DrawTurns()
        
        call startables.add(rg)
        
        //LEVEL 3
        set l = Levels_Level.create(23, "Playground", 5, 4, "PW3Start", "PW3Stop", gg_rct_PWR_3_1, gg_rct_PW3_Vision, gg_rct_PW2_End, l) //gg_rct_PW1_Vision
        set l.CPDefaultGameModes[0] = Teams_GAMEMODE_PLATFORMING
        set cpID = l.AddCheckpoint(gg_rct_PWCP_3_1, gg_rct_PWR_3_2)
        set l.CPDefaultGameModes[cpID] = Teams_GAMEMODE_PLATFORMING
        set cpID = l.AddCheckpoint(gg_rct_PWCP_3_2, gg_rct_PWR_3_3)
        set l.CPDefaultGameModes[cpID] = Teams_GAMEMODE_PLATFORMING
        set cpID = l.AddCheckpoint(gg_rct_PWCP_3_3, gg_rct_PWR_3_4)
        set l.CPDefaultGameModes[cpID] = Teams_GAMEMODE_PLATFORMING
        
        set startables = SimpleList_List.create()
        set l.Content.Startables = startables
        
        call startables.add(SimpleGenerator.create(gg_rct_PW3_MassCreate, 'e00K', 1.5, 180, 16, 100))
        
        /*
        set wheel = Wheel.create(-2904, -6765)
        set wheel.LayerCount = 3
        set wheel.SpokeCount = 12
        set wheel.AngleBetween = 30 * bj_PI / 180
        set wheel.RotationSpeed = bj_PI / 20 * Wheel_TIMEOUT
        set wheel.DistanceBetween = 2*TERRAIN_TILE_SIZE
        set wheel.InitialOffset = 2*TERRAIN_TILE_SIZE
        
        call wheel.AddUnits('e00A', 12)
        call wheel.AddUnits('e00K', 1)
        call wheel.AddEmptySpace(5)
        call wheel.AddUnits('e00K', 1)
        call wheel.AddLayer(0)
        call wheel.AddUnits('e00J', 12)
        
        call startables.add(wheel)
        */
        //set wheel = Wheel.create(-2694, -9200)
        set boundedWheel = BoundedWheel.create(-2694, -9200)
        set boundedWheel.SpokeCount = 16
        set boundedWheel.AngleBetween = bj_PI / 8
        set boundedWheel.RotationSpeed = bj_PI / 20 * Wheel_TIMEOUT
        set boundedWheel.InitialOffset = 1.5*TERRAIN_TILE_SIZE
        set boundedWheel.DistanceBetween = 1*TERRAIN_QUADRANT_SIZE
        call boundedWheel.SetAngleBounds(bj_PI * 3/6,bj_PI * 5/6)
        
        /*
        call boundedWheel.AddUnits('e00A', 3)
        call boundedWheel.AddUnits('e00J', 1)
        call boundedWheel.AddUnits('e00A', 3)
        call boundedWheel.AddEmptySpace(1)
        */
        call boundedWheel.AddEmptySpace(1)
        call boundedWheel.AddUnits('e00A', 6)
        call boundedWheel.AddUnits('e00J', 1)
        call boundedWheel.AddUnits('e00A', 6)
        call boundedWheel.AddEmptySpace(2)
        
        /*
        set i = 0
        loop
        exitwhen i > 1
            call wheel.AddUnits('e00A', 3)
            call wheel.AddUnits('e00J', 1)
        set i = i + 1
        endloop
        */
        call startables.add(boundedWheel)
        
        call AddUnitLocust(CreateUnit(Player(11), 'e00K', -554, -4840, 0))
        set wheel = Wheel.create(-554, -4840)
        set wheel.SpokeCount = 4
        set wheel.AngleBetween = bj_PI / 2
        set wheel.RotationSpeed = bj_PI / 10 * Wheel_TIMEOUT
        set wheel.DistanceBetween = 2.25*TERRAIN_TILE_SIZE
        call wheel.AddUnits('e00K', 4)
        /*
        call wheel.AddUnits('e00K', 1)
        call wheel.AddEmptySpace(1)
        call wheel.AddUnits('e00K', 1)
        call wheel.AddEmptySpace(1)
        
        
        call wheel.AddEmptySpace(1)
        call wheel.AddUnits('e00K', 1)
        call wheel.AddEmptySpace(1)
        call wheel.AddUnits('e00K', 1)
        
        call wheel.AddUnits('e00K', 4)
        */
        call startables.add(wheel)
        
        //call l.AddTeamCB("PW3TeamStart", "PW3TeamStop")
        /*
        set cpID = l.AddCheckpoint(gg_rct_PWCP_2_1, gg_rct_PWR_2_2)
        set l.CPDefaultGameModes[cpID] = Teams_GAMEMODE_PLATFORMING
        set cpID = l.AddCheckpoint(gg_rct_PWCP_2_2, gg_rct_PWR_2_3)
        set l.CPDefaultGameModes[cpID] = Teams_GAMEMODE_PLATFORMING
        */
        
        //Justine's Four Seasons
        //set l = Levels_Level.create(7, null, null, gg_rct_FSR_1_1, gg_rct_IW3_Vision, gg_rct_IW2_End, 0)
        
        //LANDWORLD / LUSTWORLD
        
        //Testing world / secret world
        set l = Levels_Level.create(66, "Test Platforming", 0, 0, null, null, gg_rct_SWR_1_1, null, null, 0)
        set l.CPDefaultGameModes[0] = Teams_GAMEMODE_PLATFORMING
        
        set l = Levels_Level.create(67, "Test Standard", 0, 0, null, null, gg_rct_SWR_2_1, null, null, l)
    endfunction
endlibrary