library LW1 requires Recycle, Levels 
	public function InitializeStartableContent takes nothing returns nothing
		local Levels_Level l = Levels_Level(LW1_LEVEL_ID)
		
		local SimpleGenerator sg
		local RelayGenerator rg
		
		local SynchronizedGroup nsync
		local SynchronizedUnit jtimber
				
		local PatternSpawn pattern
				
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
	endfunction
	
	function LW1Start takes nothing returns nothing
		local Levels_Level parentLevel = Levels_Level(LW1_LEVEL_ID)
		
		//patrols
		//P1
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_209, gg_rct_Rect_210)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_212, gg_rct_Rect_211)
		
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_213, gg_rct_Rect_214)
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_216, gg_rct_Rect_215)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_217, gg_rct_Rect_218)
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_219, gg_rct_Rect_220)
		
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_221, gg_rct_Rect_222)
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_224, gg_rct_Rect_223)
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_225, gg_rct_Rect_226)
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_228, gg_rct_Rect_227)
		
		//call CreateMortarCenterRect(SMLMORT, Player(10), gg_rct_Rect_247, gg_rct_Rect_246)
		
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_237, gg_rct_Rect_238)
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_239, gg_rct_Rect_240)
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_241, gg_rct_Rect_242)
			
		//turn on periodic functions
		//call EnableTrigger(gg_trg_LW1_MassCreate)
	endfunction

	function LW1Stop takes nothing returns nothing
		//call DisableTrigger(gg_trg_LW1_MassCreate)
	endfunction
endlibrary