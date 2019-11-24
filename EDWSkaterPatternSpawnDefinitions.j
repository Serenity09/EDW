library EDWSkaterPatternSpawnDefinitions requires PatternSpawn, IceSkater, GroupUtils, Recycle
	function IW3SkaterPattern takes PatternSpawn spawn, Levels_Level parentLevel returns group
		local IceSkater skater
		local group g = NewGroup()
		
		// call DisplayTextToForce(bj_FORCE_PLAYER[0], "Current cycle: " + I2S(spawn.CurrentCycle))
		
		if spawn.CurrentCycle == 0 then
			//fast and tight down the middle, straight to the end
			set skater = IceSkater.create(vector2.createFromRect(gg_rct_IW3_SkaterStart), vector2.createFromRect(gg_rct_IW3_SkaterEnd), ICETROLL, parentLevel.GetWeightedRandomReal(7.5, 12.5), parentLevel.GetWeightedRandomReal(5, 7.5))
		
			if parentLevel.GetWeightedRandomInt(0, 1) == 0 then
				set skater.InitialAngleDirection = 1
			endif
			
			call IndexedUnit[skater.SkateUnit].SetMoveSpeed(400.)
		else
			set skater = IceSkater.create(vector2.createFromRect(gg_rct_IW3_SkaterStart), vector2.createFromRect(gg_rct_IW3_SkaterEnd), ICETROLL, parentLevel.GetWeightedRandomReal(15, 20), parentLevel.GetWeightedRandomReal(7.5, 12.5))
			
			if spawn.CurrentCycle == 1 then
				//slow and wide, starting with left branch and alternating
				// set skater = IceSkater.create(vector2.createFromRect(gg_rct_IW3_SkaterStart), vector2.createFromRect(gg_rct_IW3_SkaterPath1a), ICETROLL, parentLevel.GetWeightedRandomReal(15, 30), parentLevel.GetWeightedRandomReal(3, 6))
			else
				//slow and wide, starting with right branch and alternating
				// set skater = IceSkater.create(vector2.createFromRect(gg_rct_IW3_SkaterStart), vector2.createFromRect(gg_rct_IW3_SkaterPath1b), ICETROLL, parentLevel.GetWeightedRandomReal(15, 30), parentLevel.GetWeightedRandomReal(3, 6))
				
				set skater.InitialAngleDirection = 1
			endif
			
			// call skater.AddDestination(vector2.createFromRect(gg_rct_IW3_SkaterPath2))
			// call skater.AddDestination(vector2.createFromRect(gg_rct_IW3_SkaterPath3))
			// call skater.AddDestination(vector2.createFromRect(gg_rct_IW3_SkaterPath4))
			
			// call skater.AddDestination(vector2.createFromRect(gg_rct_IW3_SkaterEnd))
			
			call IndexedUnit[skater.SkateUnit].SetMoveSpeed(300.)
		endif
		
		set IndexedUnit[skater.SkateUnit].Data = skater
		
		call GroupAddUnit(g, skater.SkateUnit)
		return g
	endfunction
endlibrary