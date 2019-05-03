library PW1 requires Recycle, Levels
	function PW1Start takes nothing returns nothing
		local Levels_Level parentLevel = Levels_Level(PW1_LEVEL_ID)
		
		//cp 0
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_284, gg_rct_Rect_285)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_288, gg_rct_Rect_289)
		//cp 1
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_299, gg_rct_Rect_300)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_293, gg_rct_Rect_294)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_295, gg_rct_Rect_296)
		
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_292, gg_rct_Rect_291)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_298, gg_rct_Rect_297)
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_311, gg_rct_Rect_312)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_303, gg_rct_Rect_304)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_306, gg_rct_Rect_305)
		//after fall
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_313, gg_rct_Rect_314)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_314, gg_rct_Rect_315)
		//right
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_319, gg_rct_Rect_320)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_321, gg_rct_Rect_322)
		call Recycle_MakeUnitAndPatrolRect(GUARD, gg_rct_Rect_343, gg_rct_Rect_344)
		//left
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_327, gg_rct_Rect_328)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_335, gg_rct_Rect_336)
		call Recycle_MakeUnitAndPatrolRect(LGUARD, gg_rct_Rect_337, gg_rct_Rect_338)
	endfunction

	function PW1Stop takes nothing returns nothing
	endfunction
endlibrary