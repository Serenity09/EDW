library LW2 requires Recycle, Levels, EDWCollectibleResolveHandlers, ZoomChange
	globals
		public real RelayMoveRate
	endglobals
	
	public function InitializeStartableContent takes nothing returns nothing
		local Levels_Level l = Levels_Level(LW2_LEVEL_ID)
		
		local RelayGenerator rg
		
		local SynchronizedGroup nsync
		local SynchronizedUnit jtimber
		
		local CollectibleSet collectibleSet
		local Collectible collectible
		
		local Wheel wheel
		
		local ZoomChange zc
		
		local integer lastRand
		local integer i
		
		//collect all 3 to beat the level
		set collectibleSet = CollectibleSet.create(l, EDWCollectibleResolveHandlers_AdvanceLevel)
		
		set collectible = Collectible.createFromPoint(ORANGEFROG, gg_rct_LW2_C1, 270)
		// call SetUnitX(collectible.CollectedUnit, GetRectCenterX(gg_rct_LW2_C1b))
		// call SetUnitY(collectible.CollectedUnit, GetRectCenterY(gg_rct_LW2_C1b))
		// call SetUnitPosition(collectible.CollectedUnit, GetRectCenterX(gg_rct_LW2_C1b), GetRectCenterY(gg_rct_LW2_C1b))
		call collectibleSet.AddCollectible(collectible)
		
		set collectible = Collectible.createFromPoint(GREENFROG, gg_rct_LW2_C2, 180)
		//set collectible.ReturnToCheckpoint = true
		call collectibleSet.AddCollectible(collectible)
		
		if RewardMode == GameModesGlobals_HARD then
			set collectible = Collectible.createFromPoint(PURPLEFROG, gg_rct_LW2_WW3, 90)
		else
			set collectible = Collectible.createFromPoint(PURPLEFROG, gg_rct_LW2_WW2, 270)
		endif
		//set collectible.ReturnToCheckpoint = true
		call collectibleSet.AddCollectible(collectible)
		
		set collectible = Collectible.createFromPoint(REDFROG, gg_rct_LW2_C4, 180)
		//set collectible.ReturnToCheckpoint = true
		call collectibleSet.AddCollectible(collectible)
		
		set collectible = Collectible.createFromPoint(TURQOISEFROG, gg_rct_LW2_C5, 0)
		//set collectible.ReturnToCheckpoint = true
		call collectibleSet.AddCollectible(collectible)
				
		call FastLoad.create(l, l.Checkpoints.first.value, 30., 1.)
		
		set zc = ZoomChange.create(gg_rct_LW2_VC1a, FAR_CAMERA_DISTANCE)
		call zc.AddBoundary(gg_rct_LW2_VC1b)
		call zc.AddBoundary(gg_rct_LW2_VC1c)
		call zc.AddBoundary(gg_rct_LW2_VC1d)
		call l.AddStartable(zc)
		
		//
		set wheel = Wheel.createFromPoint(gg_rct_LW2_WW1)
		
        set wheel.AngleBetween = bj_PI
		set wheel.DistanceBetween = .5*TERRAIN_TILE_SIZE
		set wheel.SpokeCount = 2
		
		if RewardMode == GameModesGlobals_HARD then
			set wheel.RotationSpeed = bj_PI / 1.9 * Wheel_TIMEOUT
			set wheel.InitialOffset = .7 * TERRAIN_TILE_SIZE
			set wheel.LayerCount = 7
			call wheel.AddUnits(WWWISP, 14)
		else
			set wheel.RotationSpeed = bj_PI / 2.25 * Wheel_TIMEOUT
			set wheel.InitialOffset = TERRAIN_TILE_SIZE
			set wheel.LayerCount = 6
			call wheel.AddUnits(WWWISP, 12)
		endif
		
		call l.AddStartable(wheel)
		
		//
		set wheel = Wheel.createFromPoint(gg_rct_LW2_WW2)
		set wheel.AngleBetween = bj_PI
		
		
		set wheel.DistanceBetween = .45*TERRAIN_TILE_SIZE
		set wheel.SpokeCount = 2
		if RewardMode == GameModesGlobals_HARD then
			set wheel.RotationSpeed = bj_PI / 2. * Wheel_TIMEOUT
			set wheel.InitialOffset = .5 * TERRAIN_TILE_SIZE
			set wheel.LayerCount = 7
			call wheel.AddUnits(WWWISP, 14)
		else
			set wheel.RotationSpeed = bj_PI / 1.75 * Wheel_TIMEOUT
			set wheel.InitialOffset = 1.5*TERRAIN_TILE_SIZE
			set wheel.LayerCount = 5
			call wheel.AddUnits(WWWISP, 10)
		endif
		
		call l.AddStartable(wheel)
		
		if RewardMode == GameModesGlobals_HARD then
			//outer shell
			set wheel = Wheel.createFromPoint(gg_rct_LW2_WW3)
			set wheel.LayerCount = 1
			set wheel.InitialOffset = 3.25*TERRAIN_TILE_SIZE
			//C = 2*pi*r = 2*pi*wheel.DistanceBetween = 2411.52
			//dist between = C / (GetUnitDefaultRadius(WWWISP) * 2) = (pi*wheel.DistanceBetween) / GetUnitDefaultRadius(WWWISP) = 64
			//% circ = (2*GetUnitDefaultRadius(WWWISP)) / C
			//angle between = % circ * 2 * bj_PI
			set wheel.AngleBetween = 10 * bj_PI / 180
			set wheel.SpokeCount = R2I((2*bj_PI / wheel.AngleBetween) + .5)
			set wheel.RotationSpeed = bj_PI / 5 * Wheel_TIMEOUT
			
			set i = (wheel.SpokeCount - 12) / 2
			call wheel.AddUnits(WWWISP, i)
			call wheel.AddEmptySpace(5)
			call wheel.AddUnits(WWWISP, i)
			call wheel.AddEmptySpace(5)
			
			call l.AddStartable(wheel)
			
			//inner shell
			set wheel = Wheel.createFromPoint(gg_rct_LW2_WW3)
			set wheel.LayerCount = 1
			set wheel.InitialOffset = 1.25*TERRAIN_TILE_SIZE
			set wheel.AngleBetween = 15 * bj_PI / 180
			set wheel.SpokeCount = R2I((2*bj_PI / wheel.AngleBetween) + .5)
			set wheel.RotationSpeed = bj_PI / 5 * Wheel_TIMEOUT
			
			//facing right
			// call wheel.AddEmptySpace(2)
			// call wheel.AddUnits(WWWISP, wheel.SpokeCount - 4)
			
			//facing ?
			set i = R2I((wheel.SpokeCount - 4) / (bj_PI * 1.5))
			// call wheel.AddUnits(WWWISP, i)
			// call wheel.AddEmptySpace(4)
			// call wheel.AddUnits(WWWISP, i)
			call wheel.SetInitialAngle(.5 * bj_PI)
			call wheel.AddEmptySpace(2)
			call wheel.AddUnits(WWWISP, wheel.SpokeCount - 4)
			// call wheel.AddEmptySpace(3)
			// call wheel.AddUnits(WWWISP, i)
			// keep this wheel static, dont start/stop it
			//call l.AddStartable(wheel)
			
			//even odd inbetween
			set wheel = Wheel.createFromPoint(gg_rct_LW2_WW3)
			set wheel.LayerCount = 2
			set wheel.DistanceBetween = 1*TERRAIN_TILE_SIZE
			set wheel.InitialOffset = 1.75*TERRAIN_TILE_SIZE
			set wheel.AngleBetween = 45 * bj_PI / 180
			set wheel.SpokeCount = R2I((2*bj_PI / wheel.AngleBetween) + .5)
			set wheel.RotationSpeed = bj_PI / 5 * Wheel_TIMEOUT
			
			set i = wheel.SpokeCount
			loop
			exitwhen i <= 1
				call wheel.AddEmptySpace(1)
				call wheel.AddUnits(WWWISP, 1)
			set i = i - 2
			endloop
			set i = wheel.SpokeCount
			loop
			exitwhen i <= 1
				call wheel.AddUnits(WWWISP, 1)
				call wheel.AddEmptySpace(1)
			set i = i - 2
			endloop
			
			call l.AddStartable(wheel)
		else
			call SetTerrainType(GetRectCenterX(gg_rct_LW2_WW3), GetRectCenterY(gg_rct_LW2_WW3), ABYSS, 0, 4, 1)
		endif
		
		//referenced by the three main pattern spawns used in LW2
		if RewardMode == GameModesGlobals_HARD then
			set RelayMoveRate = 1.
		else
			set RelayMoveRate = .8
		endif

		set rg = RelayGenerator.createFromPoint(gg_rct_LW2_RG1, 3, 3, 270, 38, 1.75 * RelayMoveRate, LW2PatternSpawn1, 6)
		// call rg.AddTurnSimple(180, 4)
		// call rg.AddTurnSimple(270, 26)
		call rg.EndTurns(270)
		
		call l.AddStartable(rg)
		
		set rg = RelayGenerator.createFromPoint(gg_rct_LW2_RG2, 2, 2, 90, 26, 1.75 * RelayMoveRate, LW2PatternSpawn2, 4)
		call rg.AddTurnSimple(0, 7)
		call rg.AddTurnSimple(270, 26)
		call rg.EndTurns(270)
		
		call l.AddStartable(rg)
		
		//TODO replace with SimpleGenerator
		set rg = RelayGenerator.createFromPoint(gg_rct_LW2_RG3, 2, 2, 270, 44, 1.25 * RelayMoveRate, LW2PatternSpawn3, 4)
		call rg.EndTurns(270)
		
		call l.AddStartable(rg)
		
		//MS = 2. * TERRAIN_TILE_SIZE
		set rg = RelayGenerator.createFromPoint(gg_rct_LW2_RG4, 2, 2, 180, 5, .666, LW2PatternSpawn4, 5)
		if RewardMode == GameModesGlobals_HARD then
			set rg.SpawnPattern.CycleCount = 4
		endif
		call rg.AddTurnSimple(90, 22)
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
		
		if RewardMode == GameModesGlobals_HARD then
			set jtimber = nsync.AddUnit(ICETROLL)
			set jtimber.MoveSpeed = 375
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG2_2))
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG2_3))
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG2_4))
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG2_1))
			set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		endif
		
		set jtimber = nsync.AddUnit(ICETROLL)
		set jtimber.MoveSpeed = 375
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG2_4))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG2_1))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG2_2))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG2_3))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		//top inner
		if RewardMode == GameModesGlobals_HARD then
			set nsync = SynchronizedGroup.create()
			call l.AddStartable(nsync)
		
			set jtimber = nsync.AddUnit(ICETROLL)
			set jtimber.MoveSpeed = 250
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG4_4))
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG4_1))
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG4_2))
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG4_3))
			set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		endif
		
		set jtimber = nsync.AddUnit(ICETROLL)
		set jtimber.MoveSpeed = 250
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG4_2))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG4_3))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG4_4))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_LW2_SG4_1))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		//mortars
		if RewardMode == GameModesGlobals_HARD then
			set i = l.GetWeightedRandomInt(3, 5)
			set lastRand = i
		else
			set i = 3
		endif
		loop
		exitwhen i == 0
			call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, gg_rct_LW2_Mortar1 , gg_rct_LW2_Target1))
		set i = i - 1
		endloop
		
		if RewardMode == GameModesGlobals_HARD then
			set i = l.GetWeightedRandomInt(lastRand, 6)
			set lastRand = i
		else
			set i = 4
		endif
		loop
		exitwhen i == 0
			call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, gg_rct_LW2_Mortar2 , gg_rct_LW2_Target2))
		set i = i - 1
		endloop
		
		if RewardMode == GameModesGlobals_HARD then
			set i = l.GetWeightedRandomInt(lastRand, 8)
			set lastRand = i
		else
			set i = 6
		endif
		loop
		exitwhen i == 0
			call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, gg_rct_LW2_Mortar3 , gg_rct_LW2_Target3))
		set i = i - 1
		endloop
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