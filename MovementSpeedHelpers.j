library MovementSpeedHelpers requires UnitGlobals, IndexedUnit, Alloc
	//only so many units so not worth making these dynamically read a unit for values. might not even be possible for animation index
	function IsUnitAnimated takes integer unitID returns boolean
		return unitID == LGUARD or unitID == GUARD or unitID == ICETROLL or unitID == SPIRITWALKER or unitID == CLAWMAN or unitID == MAZER
	endfunction
	function GetWalkAnimationIndex takes integer unitID returns integer
		if unitID == LGUARD or unitID == GUARD then
			return 2
		elseif unitID == ICETROLL then
			return 8
		elseif unitID == SPIRITWALKER then
			return 2
		elseif unitID == CLAWMAN then
			return 8
		elseif unitID == MAZER then
			return 4
		else
			return 0
		endif
	endfunction
endlibrary