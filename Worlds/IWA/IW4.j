library IW4 requires Recycle, Levels
	function IW4Start takes nothing returns nothing
		local Levels_Level parentLevel = Levels_Level(IW4_LEVEL_ID)
		
		if RewardMode == GameModesGlobals_HARD then
			call Recycle_MakeUnitAndPatrol(LGUARD, 6912, 9600, 7552, 9600)
			call Recycle_MakeUnitAndPatrol(GUARD, 7552, 9472, 6912, 9472)
		endif
		
		call Recycle_MakeUnitAndPatrol(LGUARD, 7170, 8961, 7546, 9222)
		
		call Recycle_MakeUnitAndPatrol(GUARD, 5758, 6918, 5758, 6405)
	endfunction

	function IW4Stop takes nothing returns nothing
	endfunction
endlibrary