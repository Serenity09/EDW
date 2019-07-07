library UnitDefaultRadius
	function GetUnitDefaultRadius takes integer unitTypeID returns real
		if unitTypeID == MAZER then
			return 18.
		elseif unitTypeID == PLATFORMERWISP then
			return 14.
		elseif unitTypeID == TEAM_REVIVE_UNIT_ID then
			return 80.
		elseif unitTypeID == LGUARD or unitTypeID == GUARD then
			return 21.
		elseif unitTypeID == ICETROLL then
			return 40.
		elseif unitTypeID == SPIRITWALKER then
			return 42.
		elseif unitTypeID == CLAWMAN then
			return 50.
		elseif unitTypeID == REGRET then
			return 24.
		elseif unitTypeID == LMEMORY then
			return 39.
		elseif unitTypeID == GUILT then
			return 92.
		elseif unitTypeID == GREENFROG or unitTypeID == ORANGEFROG or unitTypeID == PURPLEFROG or unitTypeID == TURQOISEFROG or unitTypeID == REDFROG then
			return 32.
		elseif InWorldPowerup.IsPowerupUnit(unitTypeID) then
			return 47.
		elseif unitTypeID == WWWISP then
			return 19.
		elseif unitTypeID == WWSKUL then
			return 20.
		elseif unitTypeID == KEYR then
			return 128.
		elseif unitTypeID == RKEY then
			return 65.
		elseif unitTypeID == RFIRE then
			//standard GameLoop defines max flex distance as 32 from edge, so use: theoretical glitchless kill radius = [terrain radius] + [terrain flex] = 64 + 32 = 96
			//theoretical because collision runs periodically, so add in a safety margin of 4 units to compensate somewhat
			//practical kill radius = 100, default mazer radius = 18 -> fire radius = 100 - 18 = 82
			return 82.
		elseif unitTypeID == BKEY then
			return 65.
		elseif unitTypeID == BFIRE then
			return 82.
		elseif unitTypeID == GKEY then
			return 65.
		elseif unitTypeID == GFIRE then
			return 82.
		elseif unitTypeID == BLACKHOLE then
			return 96.
		elseif unitTypeID == GRAVITY then
			return 45.
		elseif unitTypeID == BOUNCER then
			return 40.
		elseif unitTypeID == UBOUNCE or unitTypeID == DBOUNCE or unitTypeID == RBOUNCE or unitTypeID == LBOUNCE then
			return 35.
		elseif unitTypeID == SUPERSPEED then
			return 85.
		elseif unitTypeID == TELEPORT then
			return 78.
		else
			return 0.
		endif
	endfunction
endlibrary