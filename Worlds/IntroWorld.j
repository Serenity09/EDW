library IntroWorld requires Recycle, Levels
	public function InitializeStartableContent takes nothing returns nothing
		local Levels_Level l = Levels_Level(INTRO_LEVEL_ID)
		local Checkpoint cp
		
		local PatternSpawn pattern
		local SimpleGenerator sg
		
		local BoundedSpoke boundedSpoke
		
		local SynchronizedGroup nsync
		local SynchronizedUnit jtimber
		
		local integer rand
		
		// if RewardMode == GameModesGlobals_EASY or RewardMode == GameModesGlobals_CHEAT then
			// set cp = l.InsertCheckpoint(gg_rct_IntroWorldCP_1_1a, gg_rct_IntroWorld_R2a, 1)
			// call cp.InitGate(bj_PI, 1.25)
		// endif
		
		set nsync = SynchronizedGroup.create()
		call l.AddStartable(nsync)
		
		set jtimber = nsync.AddUnit(GUARD)
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_012))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_013))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		set jtimber = nsync.AddUnit(GUARD)
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_332))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_331))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		set pattern = LinePatternSpawn.createFromRect(IntroPatternSpawn, 1, gg_rct_Rect_052, TERRAIN_TILE_SIZE)
		if RewardMode == GameModesGlobals_HARD then
			set sg = SimpleGenerator.create(pattern, l.GetWeightedRandomReal(.65, .85), 270, 14)
			call sg.SetMoveSpeed(l.GetWeightedRandomReal(200, 250))
		else
			set sg = SimpleGenerator.create(pattern, l.GetWeightedRandomReal(.9, 1.2), 270, 14)
			call sg.SetMoveSpeed(l.GetWeightedRandomReal(150, 200))
		endif
        call l.AddStartable(sg)
		
        set boundedSpoke = BoundedSpoke.create(11970, 14465)
        call boundedSpoke.SetAngleBounds(55./180.*bj_PI, 125./180.*bj_PI)
		if RewardMode == GameModesGlobals_HARD then
			set boundedSpoke.InitialOffset = 2.25*TERRAIN_TILE_SIZE
			set boundedSpoke.LayerOffset = 2.25*TERRAIN_QUADRANT_SIZE
			// call boundedSpoke.AddUnits(WWSKUL, 3)
			call boundedSpoke.AddUnits(WWWISP, 3)
			
			set boundedSpoke.CurrentRotationSpeed = bj_PI / l.GetWeightedRandomReal(6., 8.) * BoundedSpoke_TIMESTEP
		else
			set boundedSpoke.InitialOffset = 2.5*TERRAIN_TILE_SIZE
			set boundedSpoke.LayerOffset = 3.25*TERRAIN_QUADRANT_SIZE
			// call boundedSpoke.AddUnits(WWSKUL, 2)
			call boundedSpoke.AddUnits(WWWISP, 2)
			
			set boundedSpoke.CurrentRotationSpeed = bj_PI / 8. * BoundedSpoke_TIMESTEP
		endif
		call l.AddStartable(boundedSpoke)
				
		if RewardMode == GameModesGlobals_HARD then
			set nsync = SynchronizedGroup.create()
			call l.AddStartable(nsync)
			
			set jtimber = nsync.AddUnit(LGUARD)
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_027))
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_028))
			set jtimber.AllOrders.last.next = jtimber.AllOrders.first
			
			set jtimber = nsync.AddUnit(LGUARD)
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_031))
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_032))
			set jtimber.AllOrders.last.next = jtimber.AllOrders.first
			
			set rand = l.GetWeightedRandomInt(0, 2)
			
			call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, gg_rct_IntroWorld_Mortar1 , gg_rct_IntroWorld_Target1))
			
			call SetTerrainType(GetRectCenterX(gg_rct_IntroWorld_TC2), GetRectCenterY(gg_rct_IntroWorld_TC2), ABYSS, 0, 1, 0)
		else
			set rand = l.GetWeightedRandomInt(1, 3)
			
			call SetTerrainType(GetRectCenterX(gg_rct_IntroWorld_TC1), GetRectCenterY(gg_rct_IntroWorld_TC1), ABYSS, 0, 1, 0)
		endif
		
		if rand > 0 then
			call SetTerrainType(GetRectCenterX(gg_rct_IntroWorld_TC0B), GetRectCenterY(gg_rct_IntroWorld_TC0B), SLOWICE, 0, 1, 0)
		endif
		if rand > 1 then
			call SetTerrainType(GetRectCenterX(gg_rct_IntroWorld_TC0A), GetRectCenterY(gg_rct_IntroWorld_TC0A), SLOWICE, 0, 1, 0)
		endif
		if rand > 2 then
			call SetTerrainType(GetRectCenterX(gg_rct_IntroWorld_TC0C), GetRectCenterY(gg_rct_IntroWorld_TC0C), SLOWICE, 0, 1, 0)
		endif
		
		// set nsync = SynchronizedGroup.create()
		// call l.AddStartable(nsync)
		
		// set jtimber = nsync.AddUnit(GUARD)
		// call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_271))
		// call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_272))
		// set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		// set jtimber = nsync.AddUnit(GUARD)
		// call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_273))
		// call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_274))
		// set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		call l.AddStartable(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_IntroWorld_Drunks, 15, ICETROLL, 30))
	endfunction
	
	function IntroWorldLevelStart takes nothing returns nothing
		//patrols
		// call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_012, gg_rct_Rect_013)
		// call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Region_332, gg_rct_Region_331)
		if RewardMode == GameModesGlobals_HARD then
			call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_014, gg_rct_Rect_015)
		endif
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_016, gg_rct_Rect_017)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_049, gg_rct_Rect_050)
		
		//ice patrol
		if RewardMode != GameModesGlobals_HARD then
			call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_031, gg_rct_Rect_032)
		endif
		
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_041, gg_rct_Rect_042)
		if RewardMode == GameModesGlobals_HARD then
			call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_040, gg_rct_Rect_043)
		endif
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_039, gg_rct_Rect_044)
		if RewardMode == GameModesGlobals_HARD then
			call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_038, gg_rct_Rect_045)
		endif
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_037, gg_rct_Rect_046)
		
		//leaf patrol
		if RewardMode == GameModesGlobals_HARD then
			call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_047, gg_rct_Rect_048)
		endif
		
		// call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_275, gg_rct_Rect_276)
		
		// call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_271, gg_rct_Rect_272)
		// call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_273, gg_rct_Rect_274)
		// call Recycle_MakeUnitAndPatrolRect(ICETROLL, gg_rct_Rect_277, gg_rct_Rect_278)
		
		// call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_029, gg_rct_Rect_030)
		
		
	endfunction

	function IntroWorldLevelStop takes nothing returns nothing
		
	endfunction
endlibrary