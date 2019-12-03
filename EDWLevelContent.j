library EDWLevelContent requires LevelIDGlobals, EDWLevels, SimpleList, Teams, Levels, EDWPatternSpawnDefinitions, Collectible, FastLoad
	private function FinishedIntro takes nothing returns nothing
		call TrackGameTime()
		
		call Levels_Level.CBTeam.DiscoverQuestForTeam(EDWQuests_OBSTACLE)
		call Levels_Level.CBTeam.DiscoverQuestForTeam(EDWQuests_FIRE)
		call Levels_Level.CBTeam.DiscoverQuestForTeam(EDWQuests_SKATING)
		call Levels_Level.CBTeam.DiscoverQuestForTeam(EDWQuests_PLATFORMING)
	endfunction
		
	public function Initialize takes nothing returns nothing
		local Levels_Level l
		local Checkpoint cp
                
        local BoundedSpoke boundedSpoke
        local Wheel wheel
        local BoundedWheel boundedWheel
        
        local SimpleGenerator sg
        local RelayGenerator rg
		
		local SynchronizedGroup nsync
		local SynchronizedUnit jtimber
		
		local PatternSpawn pattern
		
		local CollectibleSet collectibleSet
		local Collectible collectible
		
		local FastLoad fastLoad
		
		local unit u
		local integer i
				
		//FIRST LEVEL INITS HARD CODED
        set l = Levels_Level(INTRO_LEVEL_ID)
		call l.AddLevelStopCB(Condition(function FinishedIntro))
		
		call IntroWorld_InitializeStartableContent()
		
        //DOORS HARD CODED
        //currently no start or stop logic
        
        //ICE WORLD TECH / ENVY WORLD
        //LEVEL 1
        set l = Levels_Level(IW1_LEVEL_ID)
        
		call IW1_InitializeStartableContent()
        
        //LEVEL 2
        set l = Levels_Level(IW2_LEVEL_ID)
        
		call IW2_InitializeStartableContent()
		
        
        //LEVEL 3
        set l = Levels_Level(IW3_LEVEL_ID)
        
		call IW3_InitializeStartableContent()
		
        //LEVEL 4
        set l = Levels_Level(IW4_LEVEL_ID)
        
		call FastLoad.create(l, l.Checkpoints.first.value, 10., 2.5)
		
        //
        set rg = RelayGenerator.create(5373, 9984, 3, 6, 270, 0, 2., RelayGeneratorRandomSpawn, 1)
		set rg.SpawnPattern.Data = LGUARD
        call rg.AddTurnSimple(0, 6)
        call rg.AddTurnSimple(90, 0)
        call rg.EndTurns(90)
        
        call l.AddStartable(rg)
		
        //
		if RewardMode != GameModesGlobals_HARD then
			set nsync = SynchronizedGroup.create()
			call l.AddStartable(nsync)
			
			set jtimber = nsync.AddUnit(LGUARD)
			call jtimber.AllOrders.addEnd(vector2.create(6912, 9600))
			call jtimber.AllOrders.addEnd(vector2.create(7552, 9600))
			set jtimber.AllOrders.last.next = jtimber.AllOrders.first
			
			set jtimber = nsync.AddUnit(LGUARD)
			call jtimber.AllOrders.addEnd(vector2.create(7552, 9472))
			call jtimber.AllOrders.addEnd(vector2.create(6912, 9472))
			set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		endif
		
		if RewardMode == GameModesGlobals_HARD then
			set rg = RelayGenerator.create(6654, 6528, 3, 6, 90, 7, 1.5, RelayGeneratorRandomSpawn, 1)
		else
			set rg = RelayGenerator.create(6654, 6528, 3, 6, 90, 7, 2., RelayGeneratorRandomSpawn, 1)
		endif
		set rg.SpawnPattern.Data = LGUARD
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
        
		call l.AddStartable(rg)
		
		if RewardMode == GameModesGlobals_HARD then
			call l.AddStartable(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_IW4_Drunks, 6, LGUARD, 24))
		else
			call l.AddStartable(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_IW4_Drunks, 6, LGUARD, 10))
		endif
        call l.AddStartable(Blackhole.create(8958, 6400, true))
		
        //
        set rg = RelayGenerator.create(3830, 6278, 3, 6, 90, 3, 3., RelayGeneratorRandomSpawn, 1)
		set rg.SpawnPattern.Data = GUARD
        call rg.AddTurnSimple(0, 1)
        call rg.AddTurnSimple(270, 3)
        call rg.EndTurns(270)
        
        call l.AddStartable(rg)
                
        //LEVEL 5
		if CONFIGURATION_PROFILE != RELEASE then
			set l = Levels_Level(IW5_LEVEL_ID)
						
			call l.AddStartable(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_IW5_Drunks_3, 2, GUARD, 12))
			call l.AddStartable(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_IW5_Drunks_2, 6, LGUARD, 16))
			call l.AddStartable(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_IW5_Drunks_1, 10, LGUARD, 60))
        endif
				
		//ICE WORLD B
		//LEVEL 1
		set l = Levels_Level(IWB1_LEVEL_ID)
				
		set rg = RelayGenerator.create(-5948, 10836, 4, 4, 270, 0, 2., RelayGeneratorRandomSpawn, 1)
		set rg.SpawnPattern.Data = ICETROLL
        call rg.AddTurnSimple(0, 12)
        call rg.AddTurnSimple(90, 11)
        call rg.EndTurns(90)
		        
        call l.AddStartable(rg)
				
		//LAND WORLD A
		//LEVEL 1
		if RewardMode == GameModesGlobals_EASY or RewardMode == GameModesGlobals_CHEAT then
			set cp = Levels_Level(LW1_LEVEL_ID).InsertCheckpoint(gg_rct_LWCP_1_1a, gg_rct_LWR_1_2a, 1)
			call cp.InitGate(bj_PI, 1.25)
		endif
		
		call LW1_InitializeStartableContent()
		//LEVEL 2
		call LW2_InitializeStartableContent()
		
        //PRIDE WORLD / PLATFORMING
        //LEVEL 1
        set l = Levels_Level(PW1_LEVEL_ID)
                
        call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_Rect_340 , gg_rct_Rect_339))
        call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_Rect_340 , gg_rct_Rect_339))
        
        call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_Rect_352 , gg_rct_Rect_351))
		
        //LEVEL 2
        set l = Levels_Level(PW2_LEVEL_ID)
		
        call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_PW2_Mortar , gg_rct_PW2_Target))
        call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_PW2_Mortar , gg_rct_PW2_Target))
        call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_PW2_Mortar , gg_rct_PW2_Target))
        call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_PW2_Mortar , gg_rct_PW2_Target))
        call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_PW2_Mortar , gg_rct_PW2_Target))
        call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_PW2_Mortar , gg_rct_PW2_Target))
        
        //public static method create takes rect spawn, real spawntimeout, real walktimeout, integer uid, real lifespan returns thistype
        call l.AddStartable(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_PW2_Drunks_1, 6, LGUARD, 14))
        call l.AddStartable(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_PW2_Drunks_1, 10, LGUARD, 8))
        call l.AddStartable(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_PW2_Drunks_2, 6, LGUARD, 8))
        call l.AddStartable(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_PW2_Drunks_3, 5, LGUARD, 14))
        call l.AddStartable(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_PW2_Drunks_4, 4, LGUARD, 10))
        
		// call FastLoad.create(l, l.Checkpoints.first.value, 10., 2.)
		
		
		//randomly pick a spawn pattern
		set i = l.GetWeightedRandomInt(0, 10)
		if RewardMode == GameModesGlobals_HARD then
			if i <= 5 then
				set rg = RelayGenerator.create(8186, -3191, 3, 3, 0, 0, 2.5, PW2PatternSpawnV2, 5) //2.5
			elseif i <= 9 then
				set rg = RelayGenerator.create(8186, -3191, 3, 3, 0, 0, 5., PW2PatternSpawnV3, 5) //5.
			else
				//uber variant
				set rg = RelayGenerator.create(8186, -3191, 3, 3, 0, 0, 2.5, PW2PatternSpawnV5, 1) //2.5, 3.5
				set l.RawScore = l.RawScore + 1
				set l.RawContinues = l.RawContinues + 1
			endif
		else
			if i <= 6 then
				set rg = RelayGenerator.create(8186, -3191, 3, 3, 0, 0, 4., PW2PatternSpawnV1, 5) //5.
				set rg.SpawnPattern.CycleVariations = 2
			elseif i <= 9 then
				set rg = RelayGenerator.create(8186, -3191, 3, 3, 0, 0, 2.5, PW2PatternSpawnV2, 5) //2.5
			else
				set rg = RelayGenerator.create(8186, -3191, 3, 3, 0, 0, 5., PW2PatternSpawnV3, 5) //5.
			endif
		endif
		
		set rg.SpawnPattern.Data = ICETROLL
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
        call rg.AddTurnSimple(0, 3)
        call rg.AddTurnSimple(270, 0)
        call rg.AddTurnSimple(0, 3)
        call rg.AddTurnSimple(90, 0)
		call rg.AddTurnSimple(0, 14)
        call rg.EndTurns(0)
        
        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "PW2 RG: " + rg.ToString())
        //debug call rg.DrawTurns()
        
        call l.AddStartable(rg)
        
		call l.AddStartable(PlatformerAutoStable.create(gg_rct_SargeOcean_1))
		
        //LEVEL 3
        set l = Levels_Level(PW3_LEVEL_ID)
        
		call l.AddStartable(SimplePatrol.create(BOUNCER, 1472, -7168, 1792, -7168))
		call l.AddStartable(SimplePatrol.create(BOUNCER, 1536, -6912, 2048, -6912))
		call l.AddStartable(SimplePatrol.create(GRAVITY, 2304, -9592, 2564, -9592))
		call l.AddStartable(SimplePatrol.create(BOUNCER, 2654, -4864, 2816, -4728))
		
		set pattern = LinePatternSpawn.createFromRect(RandomLineSlotSpawn, 1, gg_rct_PW3_MassCreate, TERRAIN_TILE_SIZE)
		set pattern.Data = BOUNCER
		set sg = SimpleGenerator.create(pattern, 1.5, 180, 19)
		call sg.SetMoveSpeed(100.)
        call l.AddStartable(sg)
        
        //set wheel = Wheel.create(-2694, -9200)
        set boundedWheel = BoundedWheel.create(-2694, -9200)
        set boundedWheel.SpokeCount = 16
        set boundedWheel.AngleBetween = bj_PI / 8
        set boundedWheel.RotationSpeed = bj_PI / 20 * Wheel_TIMEOUT
        set boundedWheel.InitialOffset = 2.*TERRAIN_TILE_SIZE
        call boundedWheel.SetAngleBounds(bj_PI * 3/6, bj_PI * 5/6)
        call boundedWheel.AddEmptySpace(1)
        call boundedWheel.AddUnits('e00A', 6)
        call boundedWheel.AddUnits('e00J', 1)
        call boundedWheel.AddUnits('e00A', 6)
        call boundedWheel.AddEmptySpace(2)
        call l.AddStartable(boundedWheel)
        
		set u = Recycle_MakeUnit(BOUNCER, -554, -4840)
		call SetUnitOwner(u, Player(11), true)
		
        set wheel = Wheel.create(-554, -4840)
        set wheel.SpokeCount = 4
        set wheel.AngleBetween = bj_PI / 2
        set wheel.RotationSpeed = bj_PI / 10 * Wheel_TIMEOUT
		set wheel.InitialOffset = 2.*TERRAIN_TILE_SIZE
        call wheel.AddUnits('e00K', 4)
        call l.AddStartable(wheel)
        
		//LEVEL 4
		if CONFIGURATION_PROFILE != RELEASE then
			set l = Levels_Level(PW4_LEVEL_ID)
						
			set wheel = Wheel.create(-7040, -2942)
			set wheel.LayerCount = 2
			set wheel.SpokeCount = 4
			set wheel.AngleBetween = 90 * bj_PI / 180.
			set wheel.RotationSpeed = bj_PI / 16. * Wheel_TIMEOUT
			set wheel.DistanceBetween = 3*TERRAIN_TILE_SIZE
			set wheel.InitialOffset = 2*TERRAIN_TILE_SIZE
			
			//layer 1
			call wheel.AddUnits('e00K', 1)
			call wheel.AddEmptySpace(1)
			call wheel.AddUnits('e00K', 1)
			call wheel.AddEmptySpace(1)
			//layer 2
			call wheel.AddEmptySpace(1)
			call wheel.AddUnits('e00K', 1)
			call wheel.AddEmptySpace(1)
			call wheel.AddUnits('e00K', 1)
			
			call l.AddStartable(wheel)
		endif
		
        //Justine's Four Seasons
		set l = Levels_Level(FS1_LEVEL_ID)
		
		call l.AddStartable(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_FS_1_Drunks, 3, LGUARD, 16))
	        
		
        //Testing worlds
        
	endfunction
endlibrary