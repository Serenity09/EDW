library EDWPatternSpawnDefinitions requires PatternSpawn, Recycle
	//! textmacro AllSpawn takes SPAWN, G, SPAWN_POSITION_CURRENT_INDEX, SPAWN_POSITION_FILTER_INDEX, SPAWN_POSITION_LAST_INDEX, SPAWN_POSITION, UNIT_TYPE_ID
		set $SPAWN_POSITION_CURRENT_INDEX$ = 0
		loop
		exitwhen $SPAWN_POSITION_CURRENT_INDEX$ > $SPAWN_POSITION_LAST_INDEX$
			if $SPAWN_POSITION_CURRENT_INDEX$ != $SPAWN_POSITION_FILTER_INDEX$ then
				set $SPAWN_POSITION$ = LinePatternSpawn($SPAWN$).GetSpawnPosition($SPAWN_POSITION_CURRENT_INDEX$)
				call GroupAddUnit($G$, Recycle_MakeUnit($UNIT_TYPE_ID$, $SPAWN_POSITION$.x, $SPAWN_POSITION$.y))
				call $SPAWN_POSITION$.deallocate()
			endif
		set $SPAWN_POSITION_CURRENT_INDEX$ = $SPAWN_POSITION_CURRENT_INDEX$ + 1
		endloop
	//! endtextmacro
	
	//! textmacro EvenSpawn takes SPAWN, G, SPAWN_POSITION_CURRENT_INDEX, SPAWN_POSITION_LAST_INDEX, SPAWN_POSITION, UNIT_TYPE_ID
		set $SPAWN_POSITION_CURRENT_INDEX$ = 0
		loop
		exitwhen $SPAWN_POSITION_CURRENT_INDEX$ > $SPAWN_POSITION_LAST_INDEX$
			set $SPAWN_POSITION$ = LinePatternSpawn($SPAWN$).GetSpawnPosition($SPAWN_POSITION_CURRENT_INDEX$)
			call GroupAddUnit($G$, Recycle_MakeUnit($UNIT_TYPE_ID$, $SPAWN_POSITION$.x, $SPAWN_POSITION$.y))
			call $SPAWN_POSITION$.deallocate()
		set $SPAWN_POSITION_CURRENT_INDEX$ = $SPAWN_POSITION_CURRENT_INDEX$ + 2
		endloop
	//! endtextmacro
	//! textmacro OddSpawn takes SPAWN, G, SPAWN_POSITION_CURRENT_INDEX, SPAWN_POSITION_LAST_INDEX, SPAWN_POSITION, UNIT_TYPE_ID
		set $SPAWN_POSITION_CURRENT_INDEX$ = 1
		loop
		exitwhen $SPAWN_POSITION_CURRENT_INDEX$ > $SPAWN_POSITION_LAST_INDEX$
			set $SPAWN_POSITION$ = LinePatternSpawn($SPAWN$).GetSpawnPosition($SPAWN_POSITION_CURRENT_INDEX$)
			call GroupAddUnit($G$, Recycle_MakeUnit($UNIT_TYPE_ID$, $SPAWN_POSITION$.x, $SPAWN_POSITION$.y))
			call $SPAWN_POSITION$.deallocate()
		set $SPAWN_POSITION_CURRENT_INDEX$ = $SPAWN_POSITION_CURRENT_INDEX$ + 2
		endloop
	//! endtextmacro
	
	//! textmacro DiagonalCrossSpawn takes SPAWN, G, CYCLE, SPAWN_POSITION_LAST_INDEX, SPAWN_POSITION, UNIT_TYPE_ID
		if $CYCLE$ < $SPAWN_POSITION_LAST_INDEX$ then
			set $SPAWN_POSITION$ = LinePatternSpawn($SPAWN$).GetSpawnPosition($CYCLE$)
		else
			set $SPAWN_POSITION$ = LinePatternSpawn($SPAWN$).GetSpawnPosition($SPAWN_POSITION_LAST_INDEX$ - ($CYCLE$ - $SPAWN_POSITION_LAST_INDEX$))
		endif
				
		call GroupAddUnit($G$, Recycle_MakeUnit($UNIT_TYPE_ID$, $SPAWN_POSITION$.x, $SPAWN_POSITION$.y))
		call $SPAWN_POSITION$.deallocate()
	//! endtextmacro
	//basic wrapper for above pattern
	function DiagonalCrossSpawn takes PatternSpawn spawn returns group
		local group g = NewGroup()
		local integer cycle = spawn.GetCycle(spawn.GetVariation())
		local integer spawnPositionLastIndex = LinePatternSpawn(spawn).GetSpawnPositionCount() - 1
		local vector2 spawnPosition
		
		//! runtextmacro DiagonalCrossSpawn("spawn", "g", "cycle", "spawnPositionLastIndex", "spawnPosition", "spawn.Data")
		
		return g
	endfunction
	
	function LW1BPatternSpawn takes PatternSpawn spawn returns group
		local group g = NewGroup()
		local integer variation = spawn.GetVariation()
		local integer cycle = spawn.GetCycle(variation)
		local integer spawnPositionLastIndex = LinePatternSpawn(spawn).GetSpawnPositionCount() - 1
		local vector2 spawnPosition
		local integer rand
		local integer i
		
		if variation == 0 then
			if cycle == 0 then
				set rand = GetRandomInt(0, 3)
				//! runtextmacro AllSpawn("spawn", "g", "i", "rand", "spawnPositionLastIndex", "spawnPosition", "ICETROLL")
			elseif cycle == 1 then
				//! runtextmacro EvenSpawn("spawn", "g", "i", "spawnPositionLastIndex", "spawnPosition", "ICETROLL")
			elseif cycle == 2 then
				//! runtextmacro OddSpawn("spawn", "g", "i", "spawnPositionLastIndex", "spawnPosition", "ICETROLL")
			elseif cycle == 3 then
				set rand = GetRandomInt(0, 3)
				//! runtextmacro AllSpawn("spawn", "g", "i", "rand", "spawnPositionLastIndex", "spawnPosition", "ICETROLL")
			endif
		elseif variation == 1 then
		
		endif
		
		set rand = GetRandomInt(0, 3)
		
		return g
	endfunction
endlibrary