library EDWLevelContent requires LevelIDGlobals, SimpleList, Teams, Levels, EDWPatternSpawnDefinitions, Collectible, FastLoad
	private function FinishedIntro takes nothing returns nothing
		call TrackGameTime()
	endfunction
	
	private function DefaultCollectibleResolve takes integer result, CollectibleTeam activeTeam returns integer
		local Levels_Level nextLevel
		
		//call DisplayTextToPlayer(Player(0), 0, 0, "Default all collectibles resolved by active team " + I2S(activeTeam))
		
		if activeTeam.Team.OnLevel.NextLevel == 0 then
			set nextLevel = Levels_Level(DOORS_LEVEL_ID)
		else
			set nextLevel = activeTeam.Team.OnLevel.NextLevel
		endif
		
		call activeTeam.Team.OnLevel.SwitchLevels(activeTeam.Team, nextLevel)
		
		return 0
	endfunction
	
	public function Initialize takes nothing returns nothing
		local Levels_Level l
        local Checkpoint cp
        
        local SimpleList_List startables
        
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
		
		local integer i
		
		//FIRST LEVEL INITS HARD CODED
        set l = Levels_Level.create(INTRO_LEVEL_ID, "???", 0, 0, "IntroWorldLevelStart", "IntroWorldLevelStop", gg_rct_IntroWorld_R1, gg_rct_IntroWorld_Vision, gg_rct_IntroWorld_End, 0)
        //1st level is now handled in EDWVisualVote vote finish callback
        //call l.StartLevel() //just start it, intro level vision handled by Reveal Intro World... i like the reveal effect
        call l.AddCheckpoint(gg_rct_IntroWorldCP_1_1, gg_rct_IntroWorld_R2)
        call l.AddCheckpoint(gg_rct_IntroWorldCP_1_2a, gg_rct_IntroWorld_R3a)
        call l.AddCheckpoint(gg_rct_IntroWorldCP_1_2, gg_rct_IntroWorld_R3)
		
		set pattern = LinePatternSpawn.createFromRect(IntroPatternSpawn, 1, gg_rct_Rect_052, TERRAIN_TILE_SIZE)
		set sg = SimpleGenerator.create(pattern, .75, 270, 16)
		call sg.SetMoveSpeed(200.)
        call l.AddStartable(sg)
		
        set boundedSpoke = BoundedSpoke.create(11970, 14465)
        set boundedSpoke.InitialOffset = 1*TERRAIN_TILE_SIZE
        set boundedSpoke.LayerOffset = 2.25*TERRAIN_QUADRANT_SIZE
        set boundedSpoke.CurrentRotationSpeed = bj_PI / 6. * BoundedSpoke_TIMESTEP
        call boundedSpoke.AddUnits('e00A', 3)
        // call boundedSpoke.SetAngleBounds(bj_PI/4, bj_PI*3./4.)
		call boundedSpoke.SetAngleBounds(55./180.*bj_PI, 125./180.*bj_PI)
        
		call l.AddStartable(boundedSpoke)
		
		call l.AddLevelStopCB(Condition(function FinishedIntro))
                
        //DOORS HARD CODED
        //currently no start or stop logic
        call Levels_Level.CreateDoors(l, null, null, gg_rct_HubWorld_R, gg_rct_HubWorld_Vision)
        
        //REMAINING LEVELS
        //takes integer levelID, trigger start, trigger stop, trigger preload, trigger unload, boolean haspreload, rect startspawn, rect vision, rect tothislevel, Level previouslevel returns Level
        //config extension methods:
        //.setPreload(trigger preload, trigger unload) returns Levels_Level
        //ICE WORLD TECH / ENVY WORLD
        //LEVEL 1
        set l = Levels_Level.create(IW1_LEVEL_ID, "Cruise Control", 3, 2, "IW1Start", "IW1Stop", gg_rct_IWR_1_1, gg_rct_IW1_Vision, gg_rct_IW1_End, 0)
        call l.AddCheckpoint(gg_rct_IWCP_1_1, gg_rct_IWR_1_2)
        
        call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW1_Mortar1 , gg_rct_IW1_Target1))
        call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW1_Mortar2 , gg_rct_IW1_Target2))
        call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW1_Mortar3 , gg_rct_IW1_Target3))
        call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW1_Mortar1 , gg_rct_IW1_Target1))
        call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW1_Mortar2 , gg_rct_IW1_Target2))
        call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW1_Mortar3 , gg_rct_IW1_Target3))
        call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW1_Mortar1 , gg_rct_IW1_Target1))
        call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW1_Mortar2 , gg_rct_IW1_Target2))
        call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW1_Mortar3 , gg_rct_IW1_Target3))
        //call l.SetStartables(startables)
        
        //LEVEL 2
        set l = Levels_Level.create(IW2_LEVEL_ID, "Jesus on Wheel", 4, 3, "IW2Start", "IW2Stop", gg_rct_IWR_2_1, gg_rct_IW2_Vision, gg_rct_IW2_End, l)
        call l.AddCheckpoint(gg_rct_IWCP_2_1, gg_rct_IWR_2_2)
        call l.AddCheckpoint(gg_rct_IWCP_2_2, gg_rct_IWR_2_3)
        
		set pattern = LinePatternSpawn.createFromRect(IW2PatternSpawn, 1, gg_rct_Rect_092, TERRAIN_TILE_SIZE)
		set sg = SimpleGenerator.create(pattern, .9, 0, 23)
        call l.AddStartable(sg)
		
        call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW2_Mortar1 , gg_rct_IW2_Target1))
        call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW2_Mortar2 , gg_rct_IW2_Target2))
        call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW2_Mortar1 , gg_rct_IW2_Target1))
        call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW2_Mortar2 , gg_rct_IW2_Target2))
        call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW2_Mortar1 , gg_rct_IW2_Target1))
        call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW2_Mortar2 , gg_rct_IW2_Target2))
        call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW2_Mortar1 , gg_rct_IW2_Target1))
        call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW2_Mortar2 , gg_rct_IW2_Target2))
        call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW2_Mortar1 , gg_rct_IW2_Target1))
        call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW2_Mortar2 , gg_rct_IW2_Target2))
        
        //LEVEL 3
        set l = Levels_Level.create(IW3_LEVEL_ID, "Illidan Goes Skiing", 6, 6, "IW3Start", "IW3Stop", gg_rct_IWR_3_1, gg_rct_IW3_Vision, gg_rct_IW3_End, l)
        call l.AddCheckpoint(gg_rct_IWCP_3_1, gg_rct_IWR_3_2)
        call l.AddCheckpoint(gg_rct_IWCP_3_2, gg_rct_IWR_3_3)
        call l.AddCheckpoint(gg_rct_IWCP_3_3, gg_rct_IWR_3_4)
        		
		call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW3_Mortar1 , gg_rct_IW3_Target1))
		call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW3_Mortar1 , gg_rct_IW3_Target1))
		call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW3_Mortar1 , gg_rct_IW3_Target1))
		call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IW3_Mortar1 , gg_rct_IW3_Target1))
		
		call l.AddStartable(Blackhole.create(15000, 3330, true))
		
        call l.AddStartable(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_IW3_Drunks_1, 6, 5, LGUARD, 24))
        call l.AddStartable(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_IW3_Drunks_2, 8, 6, LGUARD, 16))
        
        //LEVEL 4
        set l = Levels_Level.create(IW4_LEVEL_ID, "Hard Angles", 6, 4, "IW4Start", "IW4Stop", gg_rct_IWR_4_1, gg_rct_IW4_Vision, gg_rct_IW4_End, l)
        set cp = l.AddCheckpoint(gg_rct_IWCP_4_1, gg_rct_IWR_4_2)
        set cp.DefaultColor = KEY_RED
        call l.AddCheckpoint(gg_rct_IWCP_4_2, gg_rct_IWR_4_3)
        
        call l.AddStartable(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_IW4_Drunks, 6, 5, LGUARD, 24))
        call l.AddStartable(Blackhole.create(8958, 6400, true))
        //
		
        set rg = RelayGenerator.create(5373, 9984, 3, 6, 270, 0, 2., RelayGeneratorRandomSpawn, 1)
		set rg.SpawnPattern.Data = LGUARD
        call rg.AddTurnSimple(0, 6)
        call rg.AddTurnSimple(90, 0)
        call rg.EndTurns(90)
        
        call l.AddStartable(rg)
        //
        set rg = RelayGenerator.create(6654, 6528, 3, 6, 90, 7, 1.5, RelayGeneratorRandomSpawn, 1)
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
        //
        set rg = RelayGenerator.create(3830, 6278, 3, 6, 90, 3, 3., RelayGeneratorRandomSpawn, 1)
		set rg.SpawnPattern.Data = GUARD
        call rg.AddTurnSimple(0, 1)
        call rg.AddTurnSimple(270, 3)
        call rg.EndTurns(270)
        
        call l.AddStartable(rg)
                
        //LEVEL 5
		if CONFIGURATION_PROFILE != RELEASE then
			set l = Levels_Level.create(IW5_LEVEL_ID, "Frosty", 4, 4, "IW5Start", "IW5Stop", gg_rct_IWR_5_1, gg_rct_IW5_Vision, gg_rct_IW5_End, l)
			call l.AddCheckpoint(gg_rct_IWCP_5_1, gg_rct_IWR_5_2)
						
			call l.AddStartable(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_IW5_Drunks_3, 2, 2, GUARD, 12))
			call l.AddStartable(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_IW5_Drunks_2, 6, 3.5, LGUARD, 16))
			call l.AddStartable(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_IW5_Drunks_1, 10, 8, LGUARD, 60))
        endif
		
		//ICE WORLD B
		//LEVEL 1
		set l = Levels_Level.create(IWB1_LEVEL_ID, "Training Wheels", 4, 2, "IWB1Start", "IWB1Stop", gg_rct_EIWR_1_1, gg_rct_EIW1_Vision, gg_rct_EIW1_End, 0)
        call l.AddCheckpoint(gg_rct_EIWCP_1_1, gg_rct_EIWR_1_2)
				
		set rg = RelayGenerator.create(-5948, 10836, 4, 4, 270, 0, 2., RelayGeneratorRandomSpawn, 1)
		set rg.SpawnPattern.Data = ICETROLL
        call rg.AddTurnSimple(0, 12)
        call rg.AddTurnSimple(90, 11)
        call rg.EndTurns(90)
		        
        call l.AddStartable(rg)
				
		//LAND WORLD A
		//LEVEL 1
		set l = Levels_Level.create(LW1_LEVEL_ID, "Need For Speed", 3, 3, "LW1Start", "LW1Stop", gg_rct_LWR_1_1, gg_rct_LW1_Vision, gg_rct_LW1_End, 0)
        call l.AddCheckpoint(gg_rct_LWCP_1_1, gg_rct_LWR_1_2)
		
		//outer sync group
		set nsync = SynchronizedGroup.create()
		call l.AddStartable(nsync)
		
		set jtimber = nsync.AddUnit(CLAWMAN)
		set jtimber.MoveSpeed = 200
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_229))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_230))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_231))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_232))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		set jtimber = nsync.AddUnit(CLAWMAN)
		set jtimber.MoveSpeed = 200
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_231))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_232))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_229))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_230))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		set jtimber = nsync.AddUnit(CLAWMAN)
		set jtimber.MoveSpeed = 200
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_246))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_232))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_445))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_247))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		set jtimber = nsync.AddUnit(CLAWMAN)
		set jtimber.MoveSpeed = 200
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_445))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_247))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_246))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_232))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		//inner sync group A
		set nsync = SynchronizedGroup.create()
		call l.AddStartable(nsync)
		set jtimber = nsync.AddUnit(ICETROLL)
		set jtimber.MoveSpeed = 200
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_233))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_234))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_235))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_236))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		set jtimber = nsync.AddUnit(ICETROLL)
		set jtimber.MoveSpeed = 200
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_235))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_236))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_233))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_234))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		//inner sync group B
		set nsync = SynchronizedGroup.create()
		call l.AddStartable(nsync)
		set jtimber = nsync.AddUnit(ICETROLL)
		set jtimber.MoveSpeed = 200
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_442))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_441))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_440))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_439))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		set jtimber = nsync.AddUnit(ICETROLL)
		set jtimber.MoveSpeed = 200
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_440))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_439))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_442))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_441))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		//width 3 behavior diagonal cross
		set pattern = LinePatternSpawn.createFromRect(LW1PatternSpawn1, 4, gg_rct_LW1_Generator1, TERRAIN_TILE_SIZE)
		set pattern.Data = ICETROLL
		set sg = SimpleGenerator.create(pattern, 2., 270, 21)
		call sg.SetMoveSpeed(150.)
		call l.AddStartable(sg)
		
		//gateways
		call l.AddStartable(RespawningGateway.CreateFromVectors(RFIRE, vector2.createFromRect(gg_rct_Region_451), vector2.createFromRect(gg_rct_Region_446), 1*60))
		call l.AddStartable(RespawningGateway.CreateFromVectors(RFIRE, vector2.createFromRect(gg_rct_Region_452), vector2.createFromRect(gg_rct_Region_447), 10*60))
		call l.AddStartable(RespawningGateway.CreateFromVectors(BFIRE, vector2.createFromRect(gg_rct_Region_453), vector2.createFromRect(gg_rct_Region_448), 10*60))
		call l.AddStartable(RespawningGateway.CreateFromVectors(RFIRE, vector2.createFromRect(gg_rct_Region_454), vector2.createFromRect(gg_rct_Region_449), 10*60))
		call l.AddStartable(RespawningGateway.CreateFromVectors(BFIRE, vector2.createFromRect(gg_rct_Region_455), vector2.createFromRect(gg_rct_Region_450), 10*60))
		
		//********checkpoint 2
		call l.AddStartable(RespawningGateway.CreateFromVectors(RFIRE, vector2.createFromRect(gg_rct_Region_483), vector2.createFromRect(gg_rct_Region_438), 5*60))
		call l.AddStartable(RespawningGateway.CreateFromVectors(BFIRE, vector2.createFromRect(gg_rct_Region_484), vector2.createFromRect(gg_rct_Region_479), 5*60))
		call l.AddStartable(RespawningGateway.CreateFromVectors(RFIRE, vector2.createFromRect(gg_rct_Region_485), vector2.createFromRect(gg_rct_Region_480), 5*60))
		call l.AddStartable(RespawningGateway.CreateFromVectors(BFIRE, vector2.createFromRect(gg_rct_Region_486), vector2.createFromRect(gg_rct_Region_481), 5*60))
		call l.AddStartable(RespawningGateway.CreateFromVectors(RFIRE, vector2.createFromRect(gg_rct_Region_487), vector2.createFromRect(gg_rct_Region_482), 5*60))
		
		//width 4 behavior A spawn
		set pattern = LinePatternSpawn.createFromRect(W4APatternSpawn, 5, gg_rct_LW1_Generator2, TERRAIN_TILE_SIZE)
		set pattern.CycleVariations = 3
		set sg = SimpleGenerator.create(pattern, 1.8, 90, 22)
		call sg.SetMoveSpeed(175.)
		call l.AddStartable(sg)
		
		//width 3 behavior A spawn
		set pattern = LinePatternSpawn.createFromRect(W3APatternSpawn, 3, gg_rct_LW1_Generator3, TERRAIN_TILE_SIZE)
		set pattern.CycleVariations = 4
		set sg = SimpleGenerator.create(pattern, 1.4, 270, 16)
		call sg.SetMoveSpeed(350.)
		call l.AddStartable(sg)
		
		//standard simple generators
		set pattern = LinePatternSpawn.createFromPoint(OriginSpawn, 1, gg_rct_LW1_Generator4)
		set pattern.Data = SPIRITWALKER
		set sg = SimpleGenerator.create(pattern, 5, 270, 18)
		call sg.SetMoveSpeed(250.)
		call l.AddStartable(sg)
				
		set pattern = LinePatternSpawn.createFromPoint(OriginSpawn, 1, gg_rct_LW1_Generator6)
		set pattern.Data = SPIRITWALKER
		set sg = SimpleGenerator.create(pattern, 5, 270, 22)
		call sg.SetMoveSpeed(200.)
		call l.AddStartable(sg)
		
		//sync movement near teleport area
		//left & right
		set nsync = SynchronizedGroup.create()
		call l.AddStartable(nsync)
		
		//left sync group
		set jtimber = nsync.AddUnit(ICETROLL)
		set jtimber.MoveSpeed = 180
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_456))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_464))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_463))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_459))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		//right sync group		
		set jtimber = nsync.AddUnit(ICETROLL)
		set jtimber.MoveSpeed = 180
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_463))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_459))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_456))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_464))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		//top & bottom
		set nsync = SynchronizedGroup.create()
		call l.AddStartable(nsync)
		
		//top sync group
		set jtimber = nsync.AddUnit(CLAWMAN)
		set jtimber.MoveSpeed = 360
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_467))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_462))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_461))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_466))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
				
		//bottom sync group		
		set jtimber = nsync.AddUnit(CLAWMAN)
		set jtimber.MoveSpeed = 360
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_461))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_466))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_467))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_462))
		
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		//sync movement near gate
		//outer sync group
		set nsync = SynchronizedGroup.create()
		call l.AddStartable(nsync)
		set jtimber = nsync.AddUnit(CLAWMAN)
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_476))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_477))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_478))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_479))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		set jtimber = nsync.AddUnit(CLAWMAN)
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_478))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_479))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_476))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_477))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		//inner sync group
		//left unit
		set nsync = SynchronizedGroup.create()
		call l.AddStartable(nsync)
		set jtimber = nsync.AddUnit(ICETROLL)
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_469))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_468))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_471))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_470))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		//center unit
		set jtimber = nsync.AddUnit(ICETROLL)
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_472))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_473))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_469))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_468))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		//right unit
		set jtimber = nsync.AddUnit(ICETROLL)
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_474))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_475))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_472))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_473))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		
		//LEVEL 2
		set l = Levels_Level.create(LW2_LEVEL_ID, "Monday Commute", 3, 3, "LW2Start", "LW2Stop", gg_rct_LWR_2_1, gg_rct_LW2_Vision, gg_rct_LW2_End, l)
        //call l.AddCheckpoint(gg_rct_LWCP_2_1, gg_rct_LWR_2_2)
		
		//collect all 3 to beat the level
		set collectibleSet = CollectibleSet.create(l, DefaultCollectibleResolve)
		
		set collectible = Collectible.createFromPoint(FROG, 0, gg_rct_LW2_C1, 90)
		call collectibleSet.AddCollectible(collectible)
		
		set collectible = Collectible.createFromPoint(FROG, 0, gg_rct_LW2_C2, 90)
		set collectible.ReturnToCheckpoint = true
		call collectibleSet.AddCollectible(collectible)
		
		set collectible = Collectible.createFromPoint(FROG, 0, gg_rct_LW2_C3, 270)
		set collectible.ReturnToCheckpoint = true
		call collectibleSet.AddCollectible(collectible)
				
		set fastLoad = FastLoad.create(l, l.Checkpoints.first.value, 10., 3.)
		
		set rg = RelayGenerator.createFromPoint(gg_rct_LW2_RG1, 4, 4, 180, -2, 2., RelayGeneratorFirstSpawn, 1)
		set rg.SpawnPattern.Data = ICETROLL
		call rg.AddTurnSimple(90, 7)
		call rg.AddTurnSimple(180, 1)
		call rg.AddTurnSimple(270, 22)
		call rg.EndTurns(270)
		
		call l.AddStartable(rg)
		call fastLoad.AddRelayGenerator(rg)
		
		set rg = RelayGenerator.createFromPoint(gg_rct_LW2_RG2, 4, 4, 180, -1, 2., RelayGeneratorFirstSpawn, 1)
		set rg.SpawnPattern.Data = ICETROLL
		call rg.AddTurnSimple(90, 20)
		call rg.AddTurnSimple(180, 12)
		call rg.AddTurnSimple(270, 26)
		call rg.EndTurns(270)
		
		call l.AddStartable(rg)
		call fastLoad.AddRelayGenerator(rg)
		
		set rg = RelayGenerator.createFromPoint(gg_rct_LW2_RG3, 5, 5, 180, -2, 2., RelayGeneratorFirstSpawn, 1)
		set rg.SpawnPattern.Data = ICETROLL
		call rg.AddTurnSimple(270, 16)
		call rg.AddTurnSimple(0, 13)
		call rg.AddTurnSimple(90, 23)
		call rg.EndTurns(90)
		
		call l.AddStartable(rg)
		call fastLoad.AddRelayGenerator(rg)
		
        //PRIDE WORLD / PLATFORMING
        //LEVEL 1
        set l = Levels_Level.create(PW1_LEVEL_ID, "Perspective", 4, 2, "PW1Start", "PW1Stop", gg_rct_PWR_1_1, gg_rct_PW1_Vision, gg_rct_PW1_End, 0) //gg_rct_PW1_Vision
        set cp = l.AddCheckpoint(gg_rct_PWCP_1_1, gg_rct_PWR_1_2)
		set cp.DefaultGameMode = Teams_GAMEMODE_PLATFORMING
		
        set cp = l.AddCheckpoint(gg_rct_PWCP_1_2, gg_rct_PWR_1_3)
        set cp.DefaultGameMode = Teams_GAMEMODE_PLATFORMING
		
		set cp = l.AddCheckpoint(gg_rct_PWCP_1_3, gg_rct_PWR_1_4)
		set cp.RequiresSameGameMode = true
                
        call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_Rect_340 , gg_rct_Rect_339))
        call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_Rect_340 , gg_rct_Rect_339))
        
        call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_Rect_352 , gg_rct_Rect_351))
        
        
        //LEVEL 2
        set l = Levels_Level.create(PW2_LEVEL_ID, "Palindrome", 5, 5, "PW2Start", "PW2Stop", gg_rct_PWR_2_1, gg_rct_PW2_Vision, gg_rct_PW2_End, l) //gg_rct_PW1_Vision
        //set cpID = l.AddCheckpoint(gg_rct_PWCP_2_1, gg_rct_PWR_2_2)
        call l.AddCheckpoint(gg_rct_PWCP_2_2, gg_rct_PWR_2_3)
        
		set cp = l.AddCheckpoint(gg_rct_PWCP_2_3, gg_rct_PWR_2_4)
        set cp.DefaultGameMode = Teams_GAMEMODE_PLATFORMING
        
		set cp = l.AddCheckpoint(gg_rct_PWCP_2_4, gg_rct_PWR_2_5)
        set cp.DefaultGameMode = Teams_GAMEMODE_PLATFORMING
        set cp.RequiresSameGameMode = true
                        
        call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_PW2_Mortar , gg_rct_PW2_Target))
        call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_PW2_Mortar , gg_rct_PW2_Target))
        call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_PW2_Mortar , gg_rct_PW2_Target))
        call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_PW2_Mortar , gg_rct_PW2_Target))
        call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_PW2_Mortar , gg_rct_PW2_Target))
        call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_PW2_Mortar , gg_rct_PW2_Target))
        
        //public static method create takes rect spawn, real spawntimeout, real walktimeout, integer uid, real lifespan returns thistype
        call l.AddStartable(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_PW2_Drunks_1, 6, 3, LGUARD, 14))
        call l.AddStartable(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_PW2_Drunks_1, 10, 3, GUARD, 8))
        call l.AddStartable(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_PW2_Drunks_2, 6, 3, LGUARD, 8))
        call l.AddStartable(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_PW2_Drunks_3, 5, 2.5, LGUARD, 14))
        call l.AddStartable(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_PW2_Drunks_4, 4, 6, LGUARD, 10))
        
        set rg = RelayGenerator.create(8186, -3191, 3, 3, 0, 0, 2.5, PW2PatternSpawn, 4)
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
        
        //LEVEL 3
        set l = Levels_Level.create(PW3_LEVEL_ID, "Playground", 5, 4, "PW3Start", "PW3Stop", gg_rct_PWR_3_1, gg_rct_PW3_Vision, gg_rct_PW3_End, l) //gg_rct_PW1_Vision
        set Checkpoint(l.Checkpoints.first.value).DefaultGameMode = Teams_GAMEMODE_PLATFORMING
        
		set cp = l.AddCheckpoint(gg_rct_PWCP_3_1, gg_rct_PWR_3_2)
        set cp.DefaultGameMode = Teams_GAMEMODE_PLATFORMING
        
		set cp = l.AddCheckpoint(gg_rct_PWCP_3_2, gg_rct_PWR_3_3)
        set cp.DefaultGameMode = Teams_GAMEMODE_PLATFORMING
        
		set cp = l.AddCheckpoint(gg_rct_PWCP_3_3, gg_rct_PWR_3_4)
        set cp.DefaultGameMode = Teams_GAMEMODE_PLATFORMING
        
		set pattern = LinePatternSpawn.createFromRect(RandomLineSlotSpawn, 1, gg_rct_PW3_MassCreate, TERRAIN_TILE_SIZE)
		set pattern.Data = BOUNCER
		set sg = SimpleGenerator.create(pattern, 1.5, 180, 19)
		call sg.SetMoveSpeed(100.)
        call l.AddStartable(sg)
        
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
        
        call l.AddStartable(wheel)
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
        call l.AddStartable(boundedWheel)
        
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
        call l.AddStartable(wheel)
        
		//LEVEL 4
		if CONFIGURATION_PROFILE != RELEASE then
			set l = Levels_Level.create(PW4_LEVEL_ID, "Moon", 5, 4, "PW4Start", "PW4Stop", gg_rct_PWR_4_1, gg_rct_PW4_Vision, gg_rct_PW4_End, l) //gg_rct_PW1_Vision
			set Checkpoint(l.Checkpoints.first.value).DefaultGameMode = Teams_GAMEMODE_PLATFORMING
			call l.AddLevelStartCB(Condition(function PW4TeamStart))
			call l.AddLevelStopCB(Condition(function PW4TeamStop))
						
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
		set l = Levels_Level.create(FS1_LEVEL_ID, "Spring", 3, 2, "FourSeason1Start", "FourSeason1Stop", gg_rct_FSR_1_1, gg_rct_FS1_Vision, gg_rct_FS1_End, 0)
		
		call l.AddCheckpoint(gg_rct_FSCP_1_1, gg_rct_FSR_1_2)
		
		call l.AddStartable(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_FS_1_Drunks, 3, 4, LGUARD, 16))
	        
		
        //Testing worlds
        set l = Levels_Level.create(TESTDH_LEVEL_ID, "Test Standard", 0, 0, null, null, gg_rct_SWR_2_1, null, null, 0)
		
		set l = Levels_Level.create(TESTP_LEVEL_ID, "Test Platforming", 0, 0, null, null, gg_rct_SWR_1_1, null, null, 0)
        set Checkpoint(l.Checkpoints.first.value).DefaultGameMode = Teams_GAMEMODE_PLATFORMING
        
	endfunction
endlibrary