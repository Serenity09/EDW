library GetUnitDefaultRadius
	function GetUnitDefaultRadius takes integer unitTypeID returns real
		if unitTypeID == MAZER then
			return 20.
		elseif unitTypeID == TEAM_REVIVE_UNIT_ID then
			return 80.
		elseif unitTypeID == LGUARD or unitTypeID == GUARD then
			return 32.
		elseif unitTypeID == ICETROLL then
			return 48.
		elseif unitTypeID == SPIRITWALKER then
			return 56.
		elseif unitTypeID == CLAWMAN then
			return 65.
		elseif unitTypeID == ROGTHT then
			return 40.
		elseif unitTypeID == REGRET then
			return 32.
		elseif unitTypeID == LMEMORY then
			return 60.
		elseif unitTypeID == GUILT then
			return 90.
		elseif unitTypeID == FROG then
			return 32.
		elseif unitTypeID == WWWISP then
			return 30.
		elseif unitTypeID == WWSKUL then
			return 28.
		elseif unitTypeID == KEYR then
			return 70.
		elseif unitTypeID == RKEY then
			return 64.
		elseif unitTypeID == RFIRE then
			return 70.
		elseif unitTypeID == BKEY then
			return 64.
		elseif unitTypeID == BFIRE then
			return 70.
		elseif unitTypeID == GKEY then
			return 64.
		elseif unitTypeID == GFIRE then
			return 70.
		elseif unitTypeID == BLACKHOLE then
			return 96.
		else
			return 0.
		endif
	endfunction
endlibrary