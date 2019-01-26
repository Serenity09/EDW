library MovementSpeedHelpers requires UnitGlobals
	//only so many units so not worth making these dynamically read a unit for values. might not even be possible for animation index
	function GetWalkAnimationIndex takes integer unitID returns integer
		if unitID == LGUARD or unitID == GUARD then
			return 4
		elseif unitID == ICETROLL then
			return 8
		elseif unitID == SPIRITWALKER then
			return 8
		elseif unitID == CLAWMAN then
			return 8
		elseif unitID == MAZER then
			return 4
		else
			return 0
		endif
	endfunction
	function GetDefaultMoveSpeed takes integer unitID returns real
		if unitID == LGUARD then
			return 140.
		elseif unitID == GUARD then
			return 270.
		elseif unitID == ICETROLL then
			return 200.
		elseif unitID == SPIRITWALKER then
			return 180.
		elseif unitID == CLAWMAN then
			return 270.
		elseif unitID == BLACKHOLE then
			return 80.
		elseif unitID == MAZER then
			return 320.
		else
			return 0.
		endif
	endfunction
endlibrary