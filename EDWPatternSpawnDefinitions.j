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
	function DiagonalCrossSpawn takes PatternSpawn spawn, Levels_Level parentLevel returns group
		local group g = NewGroup()
		local integer cycle = spawn.GetCycle(spawn.GetVariation())
		local integer spawnPositionLastIndex = LinePatternSpawn(spawn).GetSpawnPositionCount() - 1
		local vector2 spawnPosition
		
		//! runtextmacro DiagonalCrossSpawn("spawn", "g", "cycle", "spawnPositionLastIndex", "spawnPosition", "spawn.Data")
		
		return g
	endfunction
	
	//basic spawns for basic bitches
	function OriginSpawn takes PatternSpawn spawn, Levels_Level parentLevel returns group
		local group g = NewGroup()
		call GroupAddUnit(g, Recycle_MakeUnit(spawn.Data, LinePatternSpawn(spawn).SpawnOrigin.x, LinePatternSpawn(spawn).SpawnOrigin.y))
		return g
	endfunction
	function RandomLineSpawn takes PatternSpawn spawn, Levels_Level parentLevel returns group
		local group g = NewGroup()
		
		call GroupAddUnit(g, Recycle_MakeUnit(spawn.Data, LinePatternSpawn(spawn).SpawnOrigin.x + Cos(LinePatternSpawn(spawn).SpawnLineAngle) * GetRandomReal(0, LinePatternSpawn(spawn).SpawnLineLength), LinePatternSpawn(spawn).SpawnOrigin.y + Sin(LinePatternSpawn(spawn).SpawnLineAngle) * GetRandomReal(0, LinePatternSpawn(spawn).SpawnLineLength)))
		
		return g
	endfunction
	function RandomLineSlotSpawn takes PatternSpawn spawn, Levels_Level parentLevel returns group
		local group g = NewGroup()
		local vector2 spawnPosition = LinePatternSpawn(spawn).GetSpawnPosition(GetRandomInt(0, LinePatternSpawn(spawn).GetSpawnPositionCount() - 1))
		
		call GroupAddUnit(g, Recycle_MakeUnit(spawn.Data, spawnPosition.x, spawnPosition.y))
		
		call spawnPosition.deallocate()
		return g
	endfunction
	
	function BlackholeSpawn takes PatternSpawn spawn, Levels_Level parentLevel returns group
		local group g = NewGroup()
		local vector2 spawnPosition = LinePatternSpawn(spawn).GetSpawnPosition(0)
		local Blackhole bhole = Blackhole.create(spawnPosition.x, spawnPosition.y, false)
		set bhole.ParentLevel = parentLevel
		
		call DisposableUnit.register(bhole.BlackholeUnit, bhole)
		call bhole.Start()
		
		call GroupAddUnit(g, bhole.BlackholeUnit)
		
		call spawnPosition.deallocate()
		
		return g
	endfunction
	
	function IntroPatternSpawn takes PatternSpawn spawn, Levels_Level parentLevel returns group
		local group g = NewGroup()
		//local integer cycle = spawn.CurrentCycle
		
		call GroupAddUnit(g, Recycle_MakeUnit(GUARD, LinePatternSpawn(spawn).SpawnOrigin.x + GetRandomReal(0, LinePatternSpawn(spawn).SpawnLineLength), LinePatternSpawn(spawn).SpawnOrigin.y))
		
		return g
	endfunction
	
	function IW2PatternSpawn takes PatternSpawn spawn, Levels_Level parentLevel returns group
		local group g = NewGroup()
		//local integer cycle = spawn.CurrentCycle
		
		call GroupAddUnit(g, Recycle_MakeUnit(LGUARD, LinePatternSpawn(spawn).SpawnOrigin.x, LinePatternSpawn(spawn).SpawnOrigin.y + GetRandomReal(0, LinePatternSpawn(spawn).SpawnLineLength)))
		if GetRandomInt(0, 1) == 0 then
			call GroupAddUnit(g, Recycle_MakeUnit(ICETROLL, LinePatternSpawn(spawn).SpawnOrigin.x, LinePatternSpawn(spawn).SpawnOrigin.y + GetRandomReal(0, LinePatternSpawn(spawn).SpawnLineLength)))
		endif
		
		return g
	endfunction
	
	function W3APatternSpawn takes PatternSpawn spawn, Levels_Level parentLevel returns group
		local group g = NewGroup()
		local integer variation = spawn.GetVariation()
		local integer cycle = spawn.GetCycle(variation)
		local integer spawnPositionLastIndex = LinePatternSpawn(spawn).GetSpawnPositionCount() - 1
		local vector2 spawnPosition
		local integer rand
		local integer i
		local Blackhole bhole
		
		if variation == 0 then
			if cycle == 0 then
				//! runtextmacro AllSpawn("spawn", "g", "i", "2", "spawnPositionLastIndex", "spawnPosition", "ICETROLL")
			elseif cycle == 1 then
				//! runtextmacro AllSpawn("spawn", "g", "i", "1", "spawnPositionLastIndex", "spawnPosition", "ICETROLL")
			elseif cycle == 2 then
				//! runtextmacro AllSpawn("spawn", "g", "i", "0", "spawnPositionLastIndex", "spawnPosition", "ICETROLL")
			endif
		elseif variation == 1 then
			if cycle == 0 or cycle == 2 then
				//! runtextmacro AllSpawn("spawn", "g", "i", "1", "spawnPositionLastIndex", "spawnPosition", "ICETROLL")
			elseif cycle == 1 then
				set spawnPosition = LinePatternSpawn(spawn).GetSpawnPosition(1)
				call GroupAddUnit(g, Recycle_MakeUnit(ICETROLL, spawnPosition.x, spawnPosition.y))
				call spawnPosition.deallocate()
			endif
		elseif variation == 2 then
			if cycle == 0 or cycle == 2 then
				set spawnPosition = LinePatternSpawn(spawn).GetSpawnPosition(1)
				call GroupAddUnit(g, Recycle_MakeUnit(ICETROLL, spawnPosition.x, spawnPosition.y))
				call spawnPosition.deallocate()
			elseif cycle == 1 then
				//! runtextmacro AllSpawn("spawn", "g", "i", "1", "spawnPositionLastIndex", "spawnPosition", "ICETROLL")
			endif
		elseif variation == 3 then
			if cycle == 0 then
				set spawnPosition = LinePatternSpawn(spawn).GetSpawnPosition(GetRandomInt(0, 2))
				call GroupAddUnit(g, Recycle_MakeUnit(ICETROLL, spawnPosition.x, spawnPosition.y))
				call spawnPosition.deallocate()
			elseif cycle == 1 then
				//TODO make some sort of IDisposable interface / Using-like wrapper that can interact with Recycle_ReleaseUnit
				set spawnPosition = LinePatternSpawn(spawn).GetSpawnPosition(GetRandomInt(0, 2))
				
				set bhole = Blackhole.create(spawnPosition.x, spawnPosition.y, false)
				set bhole.ParentLevel = parentLevel
				call DisposableUnit.register(bhole.BlackholeUnit, bhole)
				call bhole.Start()
				
				call GroupAddUnit(g, bhole.BlackholeUnit)
				
				call spawnPosition.deallocate()
			elseif cycle == 2 then
				set spawnPosition = LinePatternSpawn(spawn).GetSpawnPosition(GetRandomInt(0, 2))
				call GroupAddUnit(g, Recycle_MakeUnit(ICETROLL, spawnPosition.x, spawnPosition.y))
				call spawnPosition.deallocate()
			endif
		endif
				
		return g
	endfunction
	function W4APatternSpawn takes PatternSpawn spawn, Levels_Level parentLevel returns group
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
			elseif cycle == 1 or cycle == 4 then
				//! runtextmacro EvenSpawn("spawn", "g", "i", "spawnPositionLastIndex", "spawnPosition", "ICETROLL")
			elseif cycle == 2 then
				//! runtextmacro OddSpawn("spawn", "g", "i", "spawnPositionLastIndex", "spawnPosition", "ICETROLL")
			elseif cycle == 3 then
				set rand = GetRandomInt(0, 3)
				//! runtextmacro AllSpawn("spawn", "g", "i", "rand", "spawnPositionLastIndex", "spawnPosition", "ICETROLL")
			endif
		elseif variation == 1 then
			if cycle == 0 or cycle == 3 then
				set spawnPosition = LinePatternSpawn(spawn).GetSpawnPosition(0)
				call GroupAddUnit(g, Recycle_MakeUnit(ICETROLL, spawnPosition.x, spawnPosition.y))
				call spawnPosition.deallocate()
				
				set spawnPosition = LinePatternSpawn(spawn).GetSpawnPosition(3)
				call GroupAddUnit(g, Recycle_MakeUnit(ICETROLL, spawnPosition.x, spawnPosition.y))
				call spawnPosition.deallocate()
			elseif cycle == 1 or cycle == 2 or cycle == 4 then
				set spawnPosition = LinePatternSpawn(spawn).GetSpawnPosition(1)
				call GroupAddUnit(g, Recycle_MakeUnit(ICETROLL, spawnPosition.x, spawnPosition.y))
				call spawnPosition.deallocate()
				
				set spawnPosition = LinePatternSpawn(spawn).GetSpawnPosition(2)
				call GroupAddUnit(g, Recycle_MakeUnit(ICETROLL, spawnPosition.x, spawnPosition.y))
				call spawnPosition.deallocate()
			endif
		elseif variation == 2 then
			if cycle == 0 or cycle == 2 then
				set rand = GetRandomInt(0, 3)
				//! runtextmacro AllSpawn("spawn", "g", "i", "rand", "spawnPositionLastIndex", "spawnPosition", "ICETROLL")
			elseif cycle == 1 or cycle == 4 then
				set rand = GetRandomInt(0, 1)
				
				if rand == 0 then
					//! runtextmacro EvenSpawn("spawn", "g", "i", "spawnPositionLastIndex", "spawnPosition", "ICETROLL")
				else
					//! runtextmacro OddSpawn("spawn", "g", "i", "spawnPositionLastIndex", "spawnPosition", "ICETROLL")
				endif
			elseif cycle == 3 then
				set rand = GetRandomInt(0, 1)
				
				if rand == 0 then
					set spawnPosition = LinePatternSpawn(spawn).GetSpawnPosition(0)
					call GroupAddUnit(g, Recycle_MakeUnit(ICETROLL, spawnPosition.x, spawnPosition.y))
					call spawnPosition.deallocate()
					
					set spawnPosition = LinePatternSpawn(spawn).GetSpawnPosition(3)
					call GroupAddUnit(g, Recycle_MakeUnit(ICETROLL, spawnPosition.x, spawnPosition.y))
					call spawnPosition.deallocate()
				else
					set spawnPosition = LinePatternSpawn(spawn).GetSpawnPosition(1)
					call GroupAddUnit(g, Recycle_MakeUnit(ICETROLL, spawnPosition.x, spawnPosition.y))
					call spawnPosition.deallocate()
					
					set spawnPosition = LinePatternSpawn(spawn).GetSpawnPosition(2)
					call GroupAddUnit(g, Recycle_MakeUnit(ICETROLL, spawnPosition.x, spawnPosition.y))
					call spawnPosition.deallocate()
				endif
			endif
		endif
				
		return g
	endfunction
endlibrary