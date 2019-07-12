library IntroWorld requires Recycle, Levels
	public function InitializeStartableContent takes nothing returns nothing
		local Levels_Level l = Levels_Level(INTRO_LEVEL_ID)
		
		local PatternSpawn pattern
		local SimpleGenerator sg
		
		local BoundedSpoke boundedSpoke
		
		local SynchronizedGroup nsync
		local SynchronizedUnit jtimber
		
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
			set sg = SimpleGenerator.create(pattern, .75, 270, 14)
			call sg.SetMoveSpeed(200.)
		else
			set sg = SimpleGenerator.create(pattern, 1., 270, 14)
			call sg.SetMoveSpeed(175.)
		endif
        call l.AddStartable(sg)
		
        set boundedSpoke = BoundedSpoke.create(11970, 14465)
        set boundedSpoke.InitialOffset = 2.25*TERRAIN_TILE_SIZE
        set boundedSpoke.LayerOffset = 2.25*TERRAIN_QUADRANT_SIZE
        set boundedSpoke.CurrentRotationSpeed = bj_PI / 6. * BoundedSpoke_TIMESTEP
        call boundedSpoke.AddUnits('e00A', 3)
        // call boundedSpoke.SetAngleBounds(bj_PI/4, bj_PI*3./4.)
		call boundedSpoke.SetAngleBounds(55./180.*bj_PI, 125./180.*bj_PI)
        
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
		
			call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, Player(8), gg_rct_IntroWorld_Mortar1 , gg_rct_IntroWorld_Target1))
		else
			call SetTerrainType(GetRectCenterX(gg_rct_IntroWorld_TC1), GetRectCenterY(gg_rct_IntroWorld_TC1), ABYSS, 0, 1, 0)
		endif
		
		set nsync = SynchronizedGroup.create()
		call l.AddStartable(nsync)
		
		set jtimber = nsync.AddUnit(GUARD)
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_271))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_272))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		set jtimber = nsync.AddUnit(GUARD)
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_273))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_274))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
	endfunction
	
	function IntroWorldLevelStart takes nothing returns nothing
		//patrols
		// call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_012, gg_rct_Rect_013)
		// call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Region_332, gg_rct_Region_331)
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_014, gg_rct_Rect_015)
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_016, gg_rct_Rect_017)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_049, gg_rct_Rect_050)
		
		if RewardMode != GameModesGlobals_HARD then
			call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_031, gg_rct_Rect_032)
		endif
		
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_041, gg_rct_Rect_042)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_040, gg_rct_Rect_043)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_039, gg_rct_Rect_044)
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_038, gg_rct_Rect_045)
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_037, gg_rct_Rect_046)
		
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_275, gg_rct_Rect_276)
		call Recycle_MakeUnitAndPatrolRect(ICETROLL, gg_rct_Rect_277, gg_rct_Rect_278)
		// call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_271, gg_rct_Rect_272)
		// call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_273, gg_rct_Rect_274)
		
		if RewardMode == GameModesGlobals_HARD then
			call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_047, gg_rct_Rect_048)
		endif
		
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_029, gg_rct_Rect_030)
	endfunction

	function IntroWorldLevelStop takes nothing returns nothing
		
	endfunction
endlibrary