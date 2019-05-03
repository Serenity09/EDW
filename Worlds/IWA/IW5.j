library IW5 requires Recycle, Levels
	function IW5Start takes nothing returns nothing
		call Recycle_MakeUnitAndPatrol(LGUARD, 2432, 7043, 3072, 6915)
		call Recycle_MakeUnitAndPatrol(LGUARD, 2179, 6651, 2818, 6528)
	endfunction

	function IW5Stop takes nothing returns nothing
	endfunction
endlibrary