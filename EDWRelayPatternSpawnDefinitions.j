library EDWRelayPatternSpawnDefinitions requires RelayPatternSpawn, GroupUtils, Recycle
	function RelayGeneratorFirstSpawn takes RelayPatternSpawn spawn, Levels_Level parentLevel returns group
		local group g = NewGroup()
		local RelayTurn spawnTurn = spawn.Parent.Turns.first.value
		local unit u
				
		set u = Recycle_MakeUnit(spawn.Data, spawnTurn.FirstLane.x, spawnTurn.FirstLane.y)
		call IndexedUnit(GetUnitUserData(u)).SetMoveSpeed(GetUnitMoveSpeed(u)*spawn.Parent.OverclockFactor)
		call GroupAddUnit(g, u)
		
		return g
	endfunction
	
	function RelayGeneratorAllSpawn takes RelayPatternSpawn spawn, Levels_Level parentLevel returns group
		local group g = NewGroup()
		local integer currentLane = 0
		local integer numberLanes = spawn.Parent.GetNumberLanes()
		local RelayTurn spawnTurn = spawn.Parent.Turns.first.value
		local real x
		local real y
		local unit u
		
		loop
		exitwhen currentLane >= numberLanes
			if spawnTurn.Direction == 90 or spawnTurn.Direction == 270 then
				set x = spawnTurn.FirstLane.x + spawnTurn.FirstLaneX*currentLane*spawn.Parent.UnitLaneSize
				set y = spawnTurn.FirstLane.y
			else
				set x = spawnTurn.FirstLane.x
				set y = spawnTurn.FirstLane.y + spawnTurn.FirstLaneY*currentLane*spawn.Parent.UnitLaneSize
			endif
			
			set u = Recycle_MakeUnit(spawn.Data, x, y)
			call IndexedUnit(GetUnitUserData(u)).SetMoveSpeed(GetUnitMoveSpeed(u)*spawn.Parent.OverclockFactor)
			call GroupAddUnit(g, u)
		
		set currentLane = currentLane + 1
		endloop
		
		return g
	endfunction
	
	function RelayGeneratorRandomSpawn takes RelayPatternSpawn spawn, Levels_Level parentLevel returns group
		local group g = NewGroup()
		local integer lane = GetRandomInt(0, spawn.Parent.GetNumberLanes() - 1)
		local RelayTurn spawnTurn = spawn.Parent.Turns.first.value
		local real x = spawnTurn.FirstLane.x
		local real y = spawnTurn.FirstLane.y
		local unit u
		
		if spawnTurn.Direction == 90 or spawnTurn.Direction == 270 then
			set x = x + spawnTurn.FirstLaneX*lane*spawn.Parent.UnitLaneSize
		else
			set y = y + spawnTurn.FirstLaneY*lane*spawn.Parent.UnitLaneSize
		endif
		
		set u = Recycle_MakeUnit(spawn.Data, x, y)
		call IndexedUnit(GetUnitUserData(u)).SetMoveSpeed(GetUnitMoveSpeed(u)*spawn.Parent.OverclockFactor)
		call GroupAddUnit(g, u)
		
		return g
	endfunction
	
	function LW2PatternSpawn4 takes RelayPatternSpawn spawn, Levels_Level parentLevel returns group
		local group g = NewGroup()
		local RelayTurn spawnTurn = spawn.Parent.Turns.first.value
		local unit u
		
		if spawn.CurrentCycle == 0 or spawn.CurrentCycle == 1 then
			if spawn.CurrentCycle == 0 then
				set u = Recycle_MakeUnit(PASSENGERCAR, spawnTurn.FirstLane.x, spawnTurn.FirstLane.y)
			else
				set u = Recycle_MakeUnit(PASSENGERCAR, spawnTurn.FirstLane.x, spawnTurn.FirstLane.y + spawnTurn.FirstLaneY*spawn.Parent.UnitLaneSize)
			endif
			
			call IndexedUnit(GetUnitUserData(u)).SetMoveSpeed(1.5 * TERRAIN_TILE_SIZE * spawn.Parent.OverclockFactor)
			call GroupAddUnit(g, u)
		endif
		
		return g
	endfunction
	
	function PW2PatternSpawn takes RelayPatternSpawn spawn, Levels_Level parentLevel returns group
		local group g = NewGroup()
		local unit u
		//local integer lane = GetRandomInt(0, spawn.Parent.GetNumberLanes() - 1)
		local RelayTurn spawnTurn = spawn.Parent.Turns.first.value
				
		if spawn.CurrentCycle == 1 or spawn.CurrentCycle == 3 then
			//lane 0
			set u = Recycle_MakeUnit(ICETROLL, spawnTurn.FirstLane.x, spawnTurn.FirstLane.y)
			call IndexedUnit(GetUnitUserData(u)).SetMoveSpeed(200.*spawn.Parent.OverclockFactor)
			//call SetUnitMoveSpeed(u, 200)
			call GroupAddUnit(g, u)
			
			//lane 2
			set u = Recycle_MakeUnit(ICETROLL, spawnTurn.FirstLane.x, spawnTurn.FirstLane.y + 2*spawnTurn.FirstLaneY*spawn.Parent.UnitLaneSize)
			call IndexedUnit(GetUnitUserData(u)).SetMoveSpeed(200.*spawn.Parent.OverclockFactor)
			//call SetUnitMoveSpeed(u, 200)
			call GroupAddUnit(g, u)
		elseif spawn.CurrentCycle == 2 then
			//lane 1
			set u = Recycle_MakeUnit(ICETROLL, spawnTurn.FirstLane.x, spawnTurn.FirstLane.y + spawnTurn.FirstLaneY*spawn.Parent.UnitLaneSize)
			call IndexedUnit(GetUnitUserData(u)).SetMoveSpeed(400.*spawn.Parent.OverclockFactor)
			//call SetUnitMoveSpeed(u, 400)
			call GroupAddUnit(g, u)
		endif
		
		return g
	endfunction
endlibrary