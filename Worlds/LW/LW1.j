library LW1 requires Recycle, Levels 
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