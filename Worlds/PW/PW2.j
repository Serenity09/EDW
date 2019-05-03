library PW2 requires Recycle, Levels
	function PW2Start takes nothing returns nothing
		local Levels_Level parentLevel = Levels_Level(PW2_LEVEL_ID)
		
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_357, gg_rct_Rect_360)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_358, gg_rct_Rect_359)
	endfunction

	function PW2Stop takes nothing returns nothing
	endfunction
endlibrary