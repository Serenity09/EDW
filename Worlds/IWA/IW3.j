library IW3 requires Recycle, Levels
	public function InitializeStartableContent takes nothing returns nothing
		local Levels_Level l = Levels_Level(IW3_LEVEL_ID)
		
		local PatternSpawn pattern
		local SimpleGenerator sg
		
		local SynchronizedGroup nsync
		local SynchronizedUnit jtimber
		
		local ZoomChange zc
        
		local integer i
		
		set nsync = SynchronizedGroup.create()
		call l.AddStartable(nsync)
		
		set jtimber = nsync.AddUnit(GUARD)
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_128))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_129))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		set jtimber = nsync.AddUnit(GUARD)
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_130))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_131))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		if RewardMode == GameModesGlobals_HARD then
			set i = l.GetWeightedRandomInt(3, 7)
			loop
			exitwhen i == 0
				call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, gg_rct_IW3_Mortar1 , gg_rct_IW3_Target2))
			set i = i - 1
			endloop
			
			set i = l.GetWeightedRandomInt(3, 7)
			loop
			exitwhen i == 0
				call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, gg_rct_IW3_Mortar1 , gg_rct_IW3_Target3))
			set i = i - 1
			endloop
			
			set i = l.GetWeightedRandomInt(5, 7)
		else
			set i = 4
		endif
		loop
		exitwhen i == 0
			call l.AddStartable(MortarNTarget.create(SMLMORT, SMLTARG, gg_rct_IW3_Mortar1 , gg_rct_IW3_Target1))
		set i = i - 1
		endloop
		
		call l.AddStartable(Blackhole.create(15000, 3330, true))
		
		//
		set nsync = SynchronizedGroup.create()
		call l.AddStartable(nsync)
		
		set jtimber = nsync.AddUnit(GUARD)
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_170))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_171))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		set jtimber = nsync.AddUnit(GUARD)
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_172))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_173))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
        
		//
		// set nsync = SynchronizedGroup.create()
		// call l.AddStartable(nsync)
		
		// set jtimber = nsync.AddUnit(LGUARD)
		// call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_182))
		// call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_183))
		// set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		// set jtimber = nsync.AddUnit(LGUARD)
		// call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_184))
		// call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_185))
		// set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		set zc = ZoomChange.create(gg_rct_IW3_VC1b, FAR_CAMERA_DISTANCE)
		call zc.AddBoundary(gg_rct_IW3_VC1a)
		call l.AddStartable(zc)
		
		call l.AddStartable(IceSkaterGenerator.create(PatternSpawn.create(IW3SkaterPattern, 3), 5.))
		
		//
		// set nsync = SynchronizedGroup.create()
		// call l.AddStartable(nsync)
		
		// set jtimber = nsync.AddUnit(LGUARD)
		// call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_186))
		// call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_187))
		// set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		// set jtimber = nsync.AddUnit(LGUARD)
		// call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_188))
		// call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_189))
		// set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		//
		set nsync = SynchronizedGroup.create()
		call l.AddStartable(nsync)
		
		set jtimber = nsync.AddUnit(LGUARD)
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_198))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_199))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		set jtimber = nsync.AddUnit(LGUARD)
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_200))
		call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_201))
		set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
		if RewardMode == GameModesGlobals_HARD then
			//
			set nsync = SynchronizedGroup.create()
			call l.AddStartable(nsync)
			
			set jtimber = nsync.AddUnit(LGUARD)
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_202))
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_203))
			set jtimber.AllOrders.last.next = jtimber.AllOrders.first
			
			set jtimber = nsync.AddUnit(LGUARD)
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_204))
			call jtimber.AllOrders.addEnd(vector2.createFromRect(gg_rct_Rect_205))
			set jtimber.AllOrders.last.next = jtimber.AllOrders.first
		
			call l.AddStartable(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_IW3_Drunks_1, 6, LGUARD, 24))
			call l.AddStartable(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_IW3_Drunks_2, 8, LGUARD, 16))
		else
			call l.AddStartable(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_IW3_Drunks_1, 6, LGUARD, 20))
			call l.AddStartable(DrunkWalker_DrunkWalkerSpawn.create(gg_rct_IW3_Drunks_2, 8, LGUARD, 12))
		endif
	endfunction
	
	function IW3Start takes nothing returns nothing
		local Levels_Level parentLevel = Levels_Level(IW3_LEVEL_ID)
		
		//patrols
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_124, gg_rct_Rect_125)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_126, gg_rct_Rect_127)
		// call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_128, gg_rct_Rect_129)
		// call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_130, gg_rct_Rect_131)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_132, gg_rct_Rect_133)
		if RewardMode == GameModesGlobals_HARD then
			call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_135, gg_rct_Rect_134)
		endif
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_136, gg_rct_Rect_137)
		
		//P2
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_138, gg_rct_Rect_139)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_140, gg_rct_Rect_141)
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_142, gg_rct_Rect_143)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_144, gg_rct_Rect_145)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_146, gg_rct_Rect_147)
		if RewardMode == GameModesGlobals_HARD then
			call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_148, gg_rct_Rect_149)
		endif
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_150, gg_rct_Rect_151)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_152, gg_rct_Rect_153)
		if RewardMode == GameModesGlobals_HARD then
			call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_154, gg_rct_Rect_155)
		endif
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_156, gg_rct_Rect_157)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_158, gg_rct_Rect_159)
		if RewardMode == GameModesGlobals_HARD then
			call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_160, gg_rct_Rect_161)
			call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_162, gg_rct_Rect_163)
		else
			call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_160, gg_rct_Rect_161)
			call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_162, gg_rct_Rect_163)
		endif
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_164, gg_rct_Rect_165)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_166, gg_rct_Rect_167)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_168, gg_rct_Rect_169)
		// call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_170, gg_rct_Rect_171)
		// call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_172, gg_rct_Rect_173)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_174, gg_rct_Rect_175)
		if RewardMode == GameModesGlobals_HARD then
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_176, gg_rct_Rect_177)
		endif
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_178, gg_rct_Rect_179)
		
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_180, gg_rct_Rect_181)
		if RewardMode == GameModesGlobals_HARD then
			call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_280, gg_rct_Rect_281)
		endif
		// call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_182, gg_rct_Rect_183)
		// call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_184, gg_rct_Rect_185)
		// call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_186, gg_rct_Rect_187)
		// call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_188, gg_rct_Rect_189)
		// call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_190, gg_rct_Rect_191)
		// call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_192, gg_rct_Rect_193)
		// call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_194, gg_rct_Rect_195)
		// call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_196, gg_rct_Rect_197)
		// call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_198, gg_rct_Rect_199)
		// call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_200, gg_rct_Rect_201)
		// if RewardMode == GameModesGlobals_HARD then
			// call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_207, gg_rct_Rect_208)
		// endif
		
		if RewardMode != GameModesGlobals_HARD then
			call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_202, gg_rct_Rect_203)
		endif
	endfunction

	function IW3Stop takes nothing returns nothing
	endfunction
endlibrary