library MovementSpeedHelpers requires UnitGlobals, IndexedUnit, Alloc
	//only so many units so not worth making these dynamically read a unit for values. might not even be possible for animation index
	function IsUnitAnimated takes integer unitID returns boolean
		return unitID == LGUARD or unitID == GUARD or unitID == ICETROLL or unitID == SPIRITWALKER or unitID == CLAWMAN or unitID == MAZER or unitID == CORVETTE or unitID == POLICECAR or unitID == FIRETRUCK or unitID == JEEP or unitID == PASSENGERCAR or unitID == TRUCK
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
		elseif unitID == CORVETTE then
			return 1
		elseif unitID == FIRETRUCK then
			return 2
		elseif unitID == JEEP then
			return 2
		elseif unitID == PASSENGERCAR then
			return 3
		elseif unitID == POLICECAR then
			return 1
		elseif unitID == TRUCK then
			return 3
		else
			static if DEBUG_MODE then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "GetWalkAnimationIndex with unrecognized unitID: " + I2S(unitID))
			endif
			
			return 0
		endif
	endfunction
	//the existing GetUnitDefaultMoveSpeed native seems a little weird
	function GetDefaultMoveSpeed takes integer unitID returns real
		if unitID == LGUARD then
			return 140.
		elseif unitID == GUARD then
			return 270.
		elseif unitID == ICETROLL then
			return 230.
		elseif unitID == SPIRITWALKER then
			return 270.
		elseif unitID == CLAWMAN then
			return 270.
		elseif unitID == MAZER then
			return 320.
		elseif unitID == BOUNCER then
			return 200.
		elseif unitID == GRAVITY then
			return 100.
		elseif unitID == LBOUNCE or unitID == RBOUNCE or unitID == UBOUNCE or unitID == DBOUNCE then
			return 160.
		elseif unitID == SUPERSPEED then
			return 200.
		else
			static if DEBUG_MODE then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "GetDefaultMoveSpeed with unrecognized unitID: " + I2S(unitID))
			endif
			
			return 0.
		endif
	endfunction
endlibrary