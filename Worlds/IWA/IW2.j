library IW2 requires Recycle, Levels
	function IW2Start takes nothing returns nothing    
		local Levels_Level parentLevel = Levels_Level(IW2_LEVEL_ID)
		
		//patrols
		//P1
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_071, gg_rct_Rect_072)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_073, gg_rct_Rect_074)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_075, gg_rct_Rect_076)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_077, gg_rct_Rect_078)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_079, gg_rct_Rect_080)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_081, gg_rct_Rect_082)
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_083, gg_rct_Rect_084)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_085, gg_rct_Rect_086)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_087, gg_rct_Rect_088)
		
		//P3
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_095, gg_rct_Rect_096)
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_097, gg_rct_Rect_098)
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_099, gg_rct_Rect_100)
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_101, gg_rct_Rect_102)
		//call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_103, gg_rct_Rect_104)
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_105, gg_rct_Rect_106)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_107, gg_rct_Rect_108)
			
		//turn on periodic functions
	endfunction

	function IW2Stop takes nothing returns nothing

	endfunction
endlibrary