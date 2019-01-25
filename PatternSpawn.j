library PatternSpawn
	globals
		private constant boolean DEBUG_PATTERN = false
	endglobals
	
	function interface IPatternSpawn takes PatternSpawn spawn returns group
	
	struct PatternSpawn extends array
		private IPatternSpawn SpawnCB
		private integer CycleCount
		
		public integer CurrentCycle
		public integer CycleVariations
		
		public integer Data
		
		private static integer c = 1
		
		public method GetVariation takes nothing returns integer
			return .CurrentCycle / .CycleCount
		endmethod
		public method GetCycle takes integer variation returns integer
			return .CurrentCycle - variation * .CycleCount
		endmethod
		
		public method Spawn takes nothing returns group
			if (.CycleVariations == 1 and .CurrentCycle + 1 == .CycleCount) or (.CycleVariations != 1 and ModuloInteger(.CurrentCycle + 1, .CycleCount) == 0) then
				if .CycleVariations == 1 then
					set .CurrentCycle = 0
				else
					set .CurrentCycle = GetRandomInt(0, .CycleVariations - 1)*CycleCount
				endif
			else
				set .CurrentCycle = .CurrentCycle + 1
			endif
			
			static if DEBUG_PATTERN then
				debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Spawning for pattern " + I2S(this))
			endif
			
			return .SpawnCB.evaluate(this)
		endmethod
		
		public method Reset takes nothing returns nothing
			set .CurrentCycle = .CycleCount - 1
		endmethod
		
		public static method create takes IPatternSpawn spawnCB, integer cycleCount returns thistype
			local thistype new = thistype.c
			set thistype.c = thistype.c + 1
			
			set new.SpawnCB = spawnCB
			set new.CycleCount = cycleCount
			
			set new.Data = 0
			set new.CurrentCycle = new.CycleCount - 1
			set new.CycleVariations = 1
			
			return new
		endmethod
	endstruct
	
	/*
	struct StartablePatternSpawn extends IStartable
		public real CycleRate
		private timer t
		
		public delegate PatternSpawn PatternSpawn
		
		public method Start takes nothing returns nothing
			set .t = PatternSpawn.Start(.CycleRate)
		endmethod
		public method Stop takes nothing returns nothing
			call ReleaseTimer(.t)
			set .t = null
		endmethod
		
		public static method create takes IPatternSpawn spawnCB, integer cycleCount, real cycleRate returns thistype
			local thistype new = thistype.allocate()
			
			set new.PatternSpawn = PatternSpawn.create(spawnCB, cycleCount)
			
			set new.CycleRate = cycleRate
			
			return new
		endmethod
	endstruct
	*/
	
	struct LinePatternSpawn extends array
		private vector2 SpawnOrigin
		private real SpawnLineAngle
		private real SpawnLineLength
		private real SpawnOffset
				
		private delegate PatternSpawn PatternSpawn
		
		public method GetSpawnPositionCount takes nothing returns integer			
			return R2I(.SpawnLineLength / .SpawnOffset)
		endmethod
		public method GetSpawnPosition takes integer spawnIndex returns vector2
			return vector2.create(.SpawnOrigin.x + Cos(.SpawnLineAngle)*.SpawnOffset*spawnIndex, .SpawnOrigin.y + Sin(.SpawnLineAngle)*.SpawnOffset*spawnIndex)
		endmethod
		
		public static method create takes IPatternSpawn spawnCB, integer cycleCount, vector2 spawnOrigin, real spawnLineAngle, real spawnLineLength, real spawnLineOffset returns LinePatternSpawn
			local thistype new = PatternSpawn.create(spawnCB, cycleCount)
			
			set new.PatternSpawn = new
			
			set new.SpawnOrigin = spawnOrigin
			set new.SpawnLineAngle = spawnLineAngle
			set new.SpawnLineLength = spawnLineLength
			set new.SpawnOffset = spawnLineOffset
			
			return new
		endmethod
	endstruct
endlibrary