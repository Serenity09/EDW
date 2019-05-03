library IW1 requires Recycle, Levels
	function IW1Start takes nothing returns nothing    
		local Levels_Level parentLevel = Levels_Level(IW1_LEVEL_ID)
		
		//patrols
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_056, gg_rct_Rect_057)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_058, gg_rct_Rect_059)
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_060, gg_rct_Rect_061)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_062, gg_rct_Rect_063)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_064, gg_rct_Rect_065)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_066, gg_rct_Rect_067)
	endfunction

	function IW1Stop takes nothing returns nothing

	endfunction
endlibrary