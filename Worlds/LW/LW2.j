library LW2 requires Recycle, Levels, EDWCollectibleResolveHandlers
	public function InitializeStartableContent takes nothing returns nothing
		local Levels_Level l = Levels_Level(LW2_LEVEL_ID)
		
		local RelayGenerator rg
		
		local SynchronizedGroup nsync
		local SynchronizedUnit jtimber
		
		local CollectibleSet collectibleSet
		local Collectible collectible
		
		local Wheel wheel
		
		local FastLoad fastLoad
		
		//collect all 3 to beat the level
		set collectibleSet = CollectibleSet.create(l, EDWCollectibleResolveHandlers_AdvanceLevel)
		
		set collectible = Collectible.createFromPoint(FROG, 0, gg_rct_LW2_C1, 180)
		call collectibleSet.AddCollectible(collectible)
		
		set collectible = Collectible.createFromPoint(FROG, 0, gg_rct_LW2_C2, 0)
		//set collectible.ReturnToCheckpoint = true
		call collectibleSet.AddCollectible(collectible)
		
		set collectible = Collectible.createFromPoint(FROG, 0, gg_rct_LW2_C3, 270)
		//set collectible.ReturnToCheckpoint = true
		call collectibleSet.AddCollectible(collectible)
		
		set collectible = Collectible.createFromPoint(FROG, 0, gg_rct_LW2_C4, 0)
		//set collectible.ReturnToCheckpoint = true
		call collectibleSet.AddCollectible(collectible)
		
		set collectible = Collectible.createFromPoint(FROG, 0, gg_rct_LW2_C5, 0)
		//set collectible.ReturnToCheckpoint = true
		call collectibleSet.AddCollectible(collectible)
				
		set fastLoad = FastLoad.create(l, l.Checkpoints.first.value, 20., 3.)
		
		set wheel = Wheel.createFromPoint(gg_rct_LW2_WW1)
		set wheel.LayerCount = 6
        set wheel.SpokeCount = 2
        set wheel.AngleBetween = bj_PI
		if RewardMode == GameModesGlobals_HARD then
			set wheel.RotationSpeed = bj_PI / 1.25 * Wheel_TIMEOUT
		else
			set wheel.RotationSpeed = bj_PI / 1.5 * Wheel_TIMEOUT
		endif
		set wheel.DistanceBetween = .5*TERRAIN_TILE_SIZE
        set wheel.InitialOffset = 0
		call wheel.AddUnits(WWWISP, 12)
		call l.AddStartable(wheel)
		
		set wheel = Wheel.createFromPoint(gg_rct_LW2_C3)
		set wheel.LayerCount = 5
        set wheel.SpokeCount = 2
        set wheel.AngleBetween = bj_PI
        if RewardMode == GameModesGlobals_HARD then
			set wheel.RotationSpeed = bj_PI / 1.25 * Wheel_TIMEOUT
		else
			set wheel.RotationSpeed = bj_PI / 1.5 * Wheel_TIMEOUT
		endif
		set wheel.RotationSpeed = bj_PI / 1.5 * Wheel_TIMEOUT
		set wheel.DistanceBetween = .5*TERRAIN_TILE_SIZE
        set wheel.InitialOffset = .5*TERRAIN_TILE_SIZE
		call wheel.AddUnits(WWWISP, 10)
		call l.AddStartable(wheel)
		
		set rg = RelayGenerator.createFromPoint(gg_rct_LW2_RG1, 2, 2, 270, 12, 8., RelayGeneratorAllSpawn, 1)
		set rg.SpawnPattern.Data = ICETROLL
		call rg.AddTurnSimple(180, 4)
		call rg.AddTurnSimple(270, 26)
		call rg.EndTurns(270)
		
		call l.AddStartable(rg)
		
		set rg = RelayGenerator.createFromPoint(gg_rct_LW2_RG2, 3, 3, 90, 24, 4., RelayGeneratorAllSpawn, 1)
		set rg.SpawnPattern.Data = ICETROLL
		call rg.AddTurnSimple(0, 6)
		call rg.AddTurnSimple(270, 25)
		call rg.EndTurns(270)
		
		call l.AddStartable(rg)
		
		//TODO replace with SimpleGenerator
		set rg = RelayGenerator.createFromPoint(gg_rct_LW2_RG3, 2, 2, 270, 37, 6., RelayGeneratorAllSpawn, 1)
		set rg.SpawnPattern.Data = ICETROLL
		call rg.EndTurns(270)
		
		call l.AddStartable(rg)
		
		//MS = 2. * TERRAIN_TILE_SIZE
		set rg = RelayGenerator.createFromPoint(gg_rct_LW2_RG4, 2, 2, 180, 5, 1.33, LW2PatternSpawn4, 3)
		set rg.SpawnPattern.Data = ICETROLL
		call rg.AddTurnSimple(90, 20)
		call rg.EndTurns(90)
		
		call l.AddStartable(rg)
		
		//bottom outer
		set nsync = SynchronizedGroup.create()
		call l.AddStartable(nsync)
		
		set jtimber = nsync.AddUnit(CLAWMAN)
		set jtimber.MoveSpeed = 500
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG1_2))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG1_1))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG1_4))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG1_3))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		set jtimber = nsync.AddUnit(CLAWMAN)
		set jtimber.MoveSpeed = 500
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG1_4))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG1_3))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG1_2))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG1_1))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		//top outer
		set nsync = SynchronizedGroup.create()
		call l.AddStartable(nsync)
		
		set jtimber = nsync.AddUnit(CLAWMAN)
		set jtimber.MoveSpeed = 375
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG3_1))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG3_4))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG3_3))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG3_2))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		set jtimber = nsync.AddUnit(CLAWMAN)
		set jtimber.MoveSpeed = 375
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG3_3))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG3_2))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG3_1))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG3_4))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		//bottom inner
		set nsync = SynchronizedGroup.create()
		call l.AddStartable(nsync)
		
		set jtimber = nsync.AddUnit(ICETROLL)
		set jtimber.MoveSpeed = 375
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG2_2))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG2_1))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG2_4))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG2_3))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		set jtimber = nsync.AddUnit(ICETROLL)
		set jtimber.MoveSpeed = 375
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG2_4))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG2_3))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG2_2))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG2_1))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		//top inner
		set nsync = SynchronizedGroup.create()
		call l.AddStartable(nsync)
		
		set jtimber = nsync.AddUnit(ICETROLL)
		set jtimber.MoveSpeed = 250
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG4_4))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG4_1))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG4_2))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG4_3))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		set jtimber = nsync.AddUnit(ICETROLL)
		set jtimber.MoveSpeed = 250
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG4_2))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG4_3))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG4_4))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG4_1))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
	endfunction
	
	function LW2Start takes nothing returns nothing
		local Levels_Level parentLevel = Levels_Level(LW2_LEVEL_ID)
		
		//patrols
		//P1
		if RewardMode == GameModesGlobals_HARD then
			call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_LW2_P1_1, gg_rct_LW2_P1_2)
		endif
		
		//create single units

		//create regular mortars
		
		//unpause MnT's
		
		//unpause wisp wheels
		
		//turn on periodic functions
		
	endfunction

	function LW2Stop takes nothing returns nothing

	endfunction
endlibrary