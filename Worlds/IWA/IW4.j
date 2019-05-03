library IW4 requires Recycle, Levels
	function IW4Start takes nothing returns nothing
		local Levels_Level parentLevel = Levels_Level(IW4_LEVEL_ID)
		
		call Recycle_MakeUnitAndPatrol(LGUARD, 6911, 9602, 7553, 9602)
		call Recycle_MakeUnitAndPatrol(LGUARD, 7553, 9472, 6911, 9472)
		call Recycle_MakeUnitAndPatrol(LGUARD, 7170, 8961, 7546, 9222)
		
		call Recycle_MakeUnitAndPatrol(GUARD, 5758, 6918, 5758, 6405)
	endfunction

	function IW4Stop takes nothing returns nothing
	endfunction
endlibrary