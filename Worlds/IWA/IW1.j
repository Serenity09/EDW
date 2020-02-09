library IW1 requires Recycle, Levels
	public function InitializeStartableContent takes nothing returns nothing
		local Levels_Level l = Levels_Level(IW1_LEVEL_ID)
		
		local SynchronizedGroup nsync
		local SynchronizedUnit jtimber
        
		local integer i
		
		set nsync = SynchronizedGroup.create()
		call l.AddStartable(nsync)
		
		set jtimber = nsync.AddUnit(LGUARD)
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_056))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_057))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		set jtimber = nsync.AddUnit(LGUARD)
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_058))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_059))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
				
		if RewardMode == GameModesGlobals_HARD then
			set i = l.GetWeightedRandomInt(4, 5)
		else
			set i = 3
		endif
		loop
			exitwhen i == 0
			call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, gg_rct_IW1_Mortar1 , gg_rct_IW1_Target1))
			call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, gg_rct_IW1_Mortar2 , gg_rct_IW1_Target2))
			call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, gg_rct_IW1_Mortar3 , gg_rct_IW1_Target3))
		set i = i - 1
		endloop
	endfunction
	
	function IW1Start takes nothing returns nothing    
		local Levels_Level parentLevel = Levels_Level(IW1_LEVEL_ID)
		
		//patrols
		// call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_056, gg_rct_Rect_057)
		// call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_058, gg_rct_Rect_059)
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_060, gg_rct_Rect_061)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_062, gg_rct_Rect_063)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_064, gg_rct_Rect_065)
		if RewardMode == GameModesGlobals_HARD then
			call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_066, gg_rct_Rect_067)
		endif
	endfunction

	function IW1Stop takes nothing returns nothing

	endfunction
endlibrary