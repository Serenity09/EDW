library IW2 requires Recycle, Levels
	public function InitializeStartableContent takes nothing returns nothing
		local Levels_Level l = Levels_Level(IW2_LEVEL_ID)
		
		local PatternSpawn pattern
		local SimpleGenerator sg
		
		local SynchronizedGroup nsync
		local SynchronizedUnit jtimber
        
		local integer i
		
		set pattern = LinePatternSpawn.createFromRect(IW2PatternSpawn, 1, gg_rct_Rect_092, TERRAIN_TILE_SIZE)
		set sg = SimpleGenerator.create(pattern, .9, 0, 23)
        call l.AddStartable(sg)
		
		if RewardMode == GameModesGlobals_HARD then
			set i = l.GetWeightedRandomInt(3, 4)
		else
			set i = 2
		endif
		loop
			exitwhen i == 0
			call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, gg_rct_IW2_Mortar1 , gg_rct_IW2_Target1))
			call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, gg_rct_IW2_Mortar1 , gg_rct_IW2_Target3))
			call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, gg_rct_IW2_Mortar2 , gg_rct_IW2_Target2))
			call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, gg_rct_IW2_Mortar2 , gg_rct_IW2_Target4))
		set i = i - 1
		endloop
		
		if RewardMode == GameModesGlobals_HARD then
			call SetTerrainType(GetRectCenterX(gg_rct_IW2_TC1), GetRectCenterY(gg_rct_IW2_TC1), ABYSS, 0, 1, 0)
		endif
		
		//sync group 1
		set nsync = SynchronizedGroup.create()
		call l.AddStartable(nsync)
		
		set jtimber = nsync.AddUnit(LGUARD)
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_071))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_072))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		if RewardMode == GameModesGlobals_HARD then
			set jtimber = nsync.AddUnit(LGUARD)
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_073))
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_074))
			set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		endif
		
		set jtimber = nsync.AddUnit(LGUARD)
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_075))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_076))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		//sync group 2
		set nsync = SynchronizedGroup.create()
		call l.AddStartable(nsync)
		
		set jtimber = nsync.AddUnit(LGUARD)
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_077))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_078))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		set jtimber = nsync.AddUnit(LGUARD)
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_079))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_080))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		set jtimber = nsync.AddUnit(LGUARD)
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_081))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_082))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		//sync group 3
		if RewardMode == GameModesGlobals_HARD then
			set nsync = SynchronizedGroup.create()
			call l.AddStartable(nsync)
			
			set jtimber = nsync.AddUnit(LGUARD)
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_085))
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_086))
			set jtimber.AllOrders.last.next = jtimber.AllOrders.first
			
			set jtimber = nsync.AddUnit(LGUARD)
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_087))
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_088))
			set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		endif
	endfunction
	
	function IW2Start takes nothing returns nothing    
		local Levels_Level parentLevel = Levels_Level(IW2_LEVEL_ID)
		
		//patrols
		//P1
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_083, gg_rct_Rect_084)
		if RewardMode != GameModesGlobals_HARD then
			call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_085, gg_rct_Rect_086)
		endif
		
		//P3
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_095, gg_rct_Rect_096)
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_097, gg_rct_Rect_098)
		if RewardMode == GameModesGlobals_HARD then
			call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_099, gg_rct_Rect_100)
		endif
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_101, gg_rct_Rect_102)
		if RewardMode == GameModesGlobals_HARD then
			call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_105, gg_rct_Rect_106)
		endif
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_107, gg_rct_Rect_108)
			
		//turn on periodic functions
	endfunction

	function IW2Stop takes nothing returns nothing

	endfunction
endlibrary