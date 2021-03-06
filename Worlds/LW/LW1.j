library LW1 requires Recycle, Levels 
	public function InitializeStartableContent takes nothing returns nothing
		local Levels_Level l = Levels_Level(LW1_LEVEL_ID)
		
		local SimpleGenerator sg
		local RelayGenerator rg
		
		local SynchronizedGroup nsync
		local SynchronizedUnit jtimber
		
		local PatternSpawn pattern
		
		local integer rand
		local real movespeed
		local real timeout

		call FastLoad.create(l, l.Checkpoints.first.value, 50., .5)
		
		//synced patrol set
		set nsync = SynchronizedGroup.create()
		call l.AddStartable(nsync)
		
		set jtimber = nsync.AddUnit(GUARD)
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_221))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_222))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		if RewardMode == GameModesGlobals_HARD then
			set jtimber = nsync.AddUnit(GUARD)
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_224))
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_223))
			set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		endif

		set jtimber = nsync.AddUnit(GUARD)
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_225))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_226))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		set jtimber = nsync.AddUnit(GUARD)
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_228))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_227))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		//outer sync group
		set nsync = SynchronizedGroup.create()
		call l.AddStartable(nsync)
		
		if RewardMode == GameModesGlobals_HARD then
			set rand = l.GetWeightedRandomInt(1, 5)
		else
			set rand = 1
		endif

		set jtimber = nsync.AddUnit(CLAWMAN)
		set jtimber.MoveSpeed = 200
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_229))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_230))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_231))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_232))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		if rand >= 2 then
			set jtimber = nsync.AddUnit(CLAWMAN)
			set jtimber.MoveSpeed = 200
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_231))
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_232))
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_229))
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_230))
			set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		endif
		
		set jtimber = nsync.AddUnit(CLAWMAN)
		set jtimber.MoveSpeed = 200
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_246))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_232))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_445))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_247))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first

		if rand >= 4 then
			set jtimber = nsync.AddUnit(CLAWMAN)
			set jtimber.MoveSpeed = 200
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_445))
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_247))
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_246))
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_232))
			set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		endif
		
		//inner sync group A
		if RewardMode == GameModesGlobals_HARD then
			set rand = l.GetWeightedRandomInt(3, 5)

			set movespeed = 100 + 25 * rand
		else
			set rand = l.GetWeightedRandomInt(1, 3)

			set movespeed = 225 + 25 * rand
		endif

		set nsync = SynchronizedGroup.create()
		call l.AddStartable(nsync)

		set jtimber = nsync.AddUnit(ICETROLL)
		if RewardMode == GameModesGlobals_HARD then
			set jtimber.MoveSpeed = movespeed
		else
			set jtimber.MoveSpeed = movespeed
		endif
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_233))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_234))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_235))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_236))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		if RewardMode == GameModesGlobals_HARD then
			set jtimber = nsync.AddUnit(ICETROLL)
			if RewardMode == GameModesGlobals_HARD then
				set jtimber.MoveSpeed = movespeed
			else
				set jtimber.MoveSpeed = movespeed
			endif
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_235))
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_236))
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_233))
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_234))
			set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		endif

		//inner sync group B
		set nsync = SynchronizedGroup.create()
		call l.AddStartable(nsync)
		set jtimber = nsync.AddUnit(ICETROLL)
		if RewardMode == GameModesGlobals_HARD then
			set jtimber.MoveSpeed = movespeed
		else
			set jtimber.MoveSpeed = movespeed
		endif
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_442))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_441))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_440))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_439))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		if RewardMode == GameModesGlobals_HARD then
			set jtimber = nsync.AddUnit(ICETROLL)
			if RewardMode == GameModesGlobals_HARD then
				set jtimber.MoveSpeed = movespeed
			else
				set jtimber.MoveSpeed = movespeed
			endif
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_440))
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_439))
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_442))
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_441))
			set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		endif
		
		//width 3 behavior diagonal cross
		set pattern = LinePatternSpawn.createFromRect(LW1PatternSpawn1, 4, gg_rct_LW1_Generator1, TERRAIN_TILE_SIZE)
		set pattern.Data = ICETROLL
		set sg = SimpleGenerator.create(pattern, 2., 270, 21)
		call sg.SetMoveSpeed(150.)
		call l.AddStartable(sg)
		
		//gateways
		call l.AddStartable(RespawningGateway.CreateFromVectors(RFIRE, vector2.createFromRect(gg_rct_Region_451), vector2.createFromRect(gg_rct_Region_446), 1*15))
		call l.AddStartable(RespawningGateway.CreateFromVectors(RFIRE, vector2.createFromRect(gg_rct_Region_452), vector2.createFromRect(gg_rct_Region_447), 10*60))
		call l.AddStartable(RespawningGateway.CreateFromVectors(BFIRE, vector2.createFromRect(gg_rct_Region_453), vector2.createFromRect(gg_rct_Region_448), 2*60))
		call l.AddStartable(RespawningGateway.CreateFromVectors(RFIRE, vector2.createFromRect(gg_rct_Region_454), vector2.createFromRect(gg_rct_Region_449), 2*60))
		call l.AddStartable(RespawningGateway.CreateFromVectors(BFIRE, vector2.createFromRect(gg_rct_Region_455), vector2.createFromRect(gg_rct_Region_450), 2*60))
		
		//********checkpoint 2
		call l.AddStartable(RespawningGateway.CreateFromVectors(RFIRE, vector2.createFromRect(gg_rct_Region_483), vector2.createFromRect(gg_rct_Region_438), 5*60))
		call l.AddStartable(RespawningGateway.CreateFromVectors(BFIRE, vector2.createFromRect(gg_rct_Region_484), vector2.createFromRect(gg_rct_Region_479), 5*60))
		call l.AddStartable(RespawningGateway.CreateFromVectors(RFIRE, vector2.createFromRect(gg_rct_Region_485), vector2.createFromRect(gg_rct_Region_480), 5*60))
		call l.AddStartable(RespawningGateway.CreateFromVectors(BFIRE, vector2.createFromRect(gg_rct_Region_486), vector2.createFromRect(gg_rct_Region_481), 5*60))
		
		if RewardMode == GameModesGlobals_HARD then
			call l.AddStartable(RespawningGateway.CreateFromVectors(RFIRE, vector2.createFromRect(gg_rct_Region_487), vector2.createFromRect(gg_rct_Region_482), 5*60))
		else
			//x, y, ttype, variation (-1 : random), radius, shape (0 : circ, 1 : rect)
			call SetTerrainType(-9984, -13432, ABYSS, 0, 4, 1)
			call SetTerrainType(-9092, -13432, ABYSS, 0, 6, 1)
			
			call SetTerrainType(-9602, -14718, NOEFFECT, 0, 1, 1)
			call SetTerrainType(-9602, -14846, ABYSS, 0, 1, 1)
		endif
		
		//width 4 spawn
		set pattern = LinePatternSpawn.createFromRect(W4APatternSpawn, 5, gg_rct_LW1_Generator2, TERRAIN_TILE_SIZE)
		set pattern.CycleVariations = 3
		set sg = SimpleGenerator.create(pattern, 2.6, 90, 22)
		if RewardMode == GameModesGlobals_HARD then
			set sg.SpawnTimeStep = 2.2
			call sg.SetMoveSpeed(175.)
		else
			call sg.SetMoveSpeed(150.)
		endif
		
		call l.AddStartable(sg)
		
		//width 3 spawn
		set pattern = LinePatternSpawn.createFromRect(W3APatternSpawn, 3, gg_rct_LW1_Generator3, TERRAIN_TILE_SIZE)
		set pattern.CycleVariations = 4
		set sg = SimpleGenerator.create(pattern, 1.5, 270, 16)
		call sg.SetMoveSpeed(350.)
		call l.AddStartable(sg)
		
		//standard simple generators
		set pattern = LinePatternSpawn.createFromPoint(OriginSpawn, 1, gg_rct_LW1_Generator4)
		set pattern.Data = SPIRITWALKER
		set sg = SimpleGenerator.create(pattern, 5, 270, 14)
		call sg.SetMoveSpeed(270.)
		call l.AddStartable(sg)
		
		if RewardMode == GameModesGlobals_HARD then
			set pattern = LinePatternSpawn.createFromPoint(OriginSpawn, 1, gg_rct_LW1_Generator6)
			set pattern.Data = SPIRITWALKER
			set sg = SimpleGenerator.create(pattern, 5, 270, 15)
			call sg.SetMoveSpeed(200.)
			call l.AddStartable(sg)
		endif
		
		//synced patrol set
		set nsync = SynchronizedGroup.create()
		call l.AddStartable(nsync)
		
		set jtimber = nsync.AddUnit(GUARD)
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_237))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_238))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		if RewardMode == GameModesGlobals_HARD then
			set jtimber = nsync.AddUnit(GUARD)
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_239))
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_240))
			set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		endif
		
		set jtimber = nsync.AddUnit(GUARD)
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_241))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_242))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		//terrain changes below teleport area
		if RewardMode == GameModesGlobals_HARD then
			set rand = l.GetWeightedRandomInt(0, 9)
			
			if rand > 0 then
				//x, y, ttype, variation (-1 : random), radius, shape (0 : circ, 1 : rect)
				call SetTerrainType(-9992, -14578, ABYSS, 0, 1, 1)
			endif
			if rand > 4 then
				call SetTerrainType(-9728, -14838, ABYSS, 0, 1, 1)
			endif
			if rand > 8 then
				call SetTerrainType(-9992, -15098, ABYSS, 0, 1, 1)
			endif
		endif
		
		//sync movement below teleport area
		//left & right
		set nsync = SynchronizedGroup.create()
		call l.AddStartable(nsync)
		
		//left sync group
		set jtimber = nsync.AddUnit(ICETROLL)
		if RewardMode == GameModesGlobals_HARD then
			set jtimber.MoveSpeed = 180
		else
			set jtimber.MoveSpeed = 160
		endif
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_456))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_464))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_463))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_459))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		//right sync group
		set jtimber = nsync.AddUnit(ICETROLL)
		if RewardMode == GameModesGlobals_HARD then
			set jtimber.MoveSpeed = 180
		else
			set jtimber.MoveSpeed = 160
		endif
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_463))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_459))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_456))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_464))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		//top & bottom
		set nsync = SynchronizedGroup.create()
		call l.AddStartable(nsync)
		
		if RewardMode == GameModesGlobals_HARD then
			//top sync group
			set jtimber = nsync.AddUnit(CLAWMAN)
			if RewardMode == GameModesGlobals_HARD then
				set jtimber.MoveSpeed = 360
			else
				set jtimber.MoveSpeed = 320
			endif
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_467))
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_462))
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_461))
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_466))
			set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		endif
				
		//bottom sync group		
		set jtimber = nsync.AddUnit(CLAWMAN)
		if RewardMode == GameModesGlobals_HARD then
			set jtimber.MoveSpeed = 360
		else
			set jtimber.MoveSpeed = 320
		endif
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
		
		if RewardMode == GameModesGlobals_HARD then
			set rand = l.GetWeightedRandomInt(2, 3)
		else
			set rand = 1
		endif

		//inner sync group
		//left unit
		if rand == 3 then
			set nsync = SynchronizedGroup.create()
			call l.AddStartable(nsync)
			set jtimber = nsync.AddUnit(ICETROLL)
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_469))
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_468))
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_471))
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_470))
			set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		endif
		
		//center unit
		set jtimber = nsync.AddUnit(ICETROLL)
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_472))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_473))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_469))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_468))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		//right unit
		if rand >= 2 then
			set jtimber = nsync.AddUnit(ICETROLL)
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_474))
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_475))
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_472))
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Region_473))
			set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		endif
	endfunction
	
	function LW1Start takes nothing returns nothing
		local Levels_Level parentLevel = Levels_Level(LW1_LEVEL_ID)
		
		//patrols
		//P1
		if RewardMode == GameModesGlobals_HARD then
			call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_209, gg_rct_Rect_210)
		endif
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_212, gg_rct_Rect_211)
		
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_213, gg_rct_Rect_214)
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_216, gg_rct_Rect_215)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_217, gg_rct_Rect_218)
		if RewardMode == GameModesGlobals_HARD then
			call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_219, gg_rct_Rect_220)
		endif
		// call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_221, gg_rct_Rect_222)
		// call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_224, gg_rct_Rect_223)
		// call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_225, gg_rct_Rect_226)
		// call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_228, gg_rct_Rect_227)
		
		//call CreateMortarCenterRect(SMLMORT, Player(10), gg_rct_Rect_247, gg_rct_Rect_246)
		
		// call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_237, gg_rct_Rect_238)
		// call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_239, gg_rct_Rect_240)
		// call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_241, gg_rct_Rect_242)
			
		//turn on periodic functions
		//call EnableTrigger(gg_trg_LW1_MassCreate)
	endfunction

	function LW1Stop takes nothing returns nothing
		//call DisableTrigger(gg_trg_LW1_MassCreate)
	endfunction
endlibrary