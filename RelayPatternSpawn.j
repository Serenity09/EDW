library RelayPatternSpawn requires PatternSpawn
	struct RelayPatternSpawn extends array
		public RelayGenerator Parent
		//public RelayTurn SpawnTurn
		public delegate PatternSpawn Pattern
		
		public static method create takes IPatternSpawn spawnCB, integer cycleCount, RelayGenerator parent returns RelayPatternSpawn
			local thistype new = PatternSpawn.create(spawnCB, cycleCount)						
			set new.Pattern = new
			set new.Parent = parent
			//set new.SpawnTurn = RelayTurn(parent.Turns.first.value)
			
			return new
		endmethod
	endstruct
endlibrary