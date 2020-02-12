library IW4 requires Recycle, Levels, EDWCollectibleResolveHandlers, Blackhole, ZoomChange
	public function InitializeStartableContent takes nothing returns nothing
		local Levels_Level l = Levels_Level(IW4_LEVEL_ID)
		
		local RelayGenerator rg
		
		local SynchronizedGroup nsync
		local SynchronizedUnit jtimber
						
		local ZoomChange zc
		
		
		call FastLoad.create(l, l.Checkpoints.first.value, 10., 2.5)
		
        //
        set rg = RelayGenerator.create(5373, 9984, 3, 6, 270, 0, 2., RelayGeneratorRandomSpawn, 1)
		set rg.SpawnPattern.Data = LGUARD
        call rg.AddTurnSimple(0, 6)
        call rg.AddTurnSimple(90, 0)
        call rg.EndTurns(90)
        
        call l.AddStartable(rg)
		
		set zc = ZoomChange.create(gg_rct_IW4_VC1a, FAR_CAMERA_DISTANCE)
		call zc.AddBoundary(gg_rct_IW4_VC1b)
		call zc.AddBoundary(gg_rct_IW4_VC1c)
		call zc.AddBoundary(gg_rct_IW4_VC1d)
		call zc.AddBoundary(gg_rct_IW4_VC1e)
		call zc.AddBoundary(gg_rct_IW4_VC1f)
		call l.AddStartable(zc)
		
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
	endfunction
	
	function IW4Start takes nothing returns nothing
		local Levels_Level parentLevel = Levels_Level(IW4_LEVEL_ID)
		
		if RewardMode == GameModesGlobals_HARD then
			call Recycle_MakeUnitAndPatrol(LGUARD, 6912, 9600, 7552, 9600)
			call Recycle_MakeUnitAndPatrol(GUARD, 7552, 9472, 6912, 9472)
		endif
		
		call Recycle_MakeUnitAndPatrol(LGUARD, 7170, 8961, 7546, 9222)
		
		call Recycle_MakeUnitAndPatrol(GUARD, 5758, 6918, 5758, 6405)
	endfunction

	function IW4Stop takes nothing returns nothing
	endfunction
endlibrary