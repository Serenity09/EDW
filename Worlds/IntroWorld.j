library IntroWorld requires Recycle, Levels
	function IntroWorldLevelStart takes nothing returns nothing
		//patrols
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_012, gg_rct_Rect_013)
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Region_332, gg_rct_Region_331)
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_014, gg_rct_Rect_015)
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_016, gg_rct_Rect_017)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_049, gg_rct_Rect_050)
		
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_027, gg_rct_Rect_028)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_029, gg_rct_Rect_030)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_031, gg_rct_Rect_032)
		
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_041, gg_rct_Rect_042)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_040, gg_rct_Rect_043)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_039, gg_rct_Rect_044)
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_038, gg_rct_Rect_045)
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_037, gg_rct_Rect_046)
		
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_275, gg_rct_Rect_276)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_277, gg_rct_Rect_278)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_271, gg_rct_Rect_272)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_273, gg_rct_Rect_274)
		
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_047, gg_rct_Rect_048)
				
		//turn on periodic functions
	endfunction

	function IntroWorldLevelStop takes nothing returns nothing
		//disable periodic functions
		
	endfunction
endlibrary