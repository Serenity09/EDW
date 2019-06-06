library PatternSpawn requires Draw
	globals
		private constant boolean DEBUG_PATTERN = false
	endglobals
	
	function interface IPatternSpawn takes PatternSpawn spawn, Levels_Level parentLevel returns group
	
	struct PatternSpawn extends array
		private IPatternSpawn SpawnCB
		private integer CycleCount
		
		//assumes every variation has the same number of cycles
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
		
		public method Spawn takes Levels_Level parentLevel returns group
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
			
			return .SpawnCB.evaluate(this, parentLevel)
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
	
	struct PointPatternSpawn extends array
		public vector2 SpawnOrigin
		
		public method GetSpawnPosition takes integer spawnIndex returns vector2
			return .SpawnOrigin
		endmethod
	endstruct
	*/
	
	struct LinePatternSpawn extends array
		public vector2 SpawnOrigin
		public real SpawnLineAngle
		public real SpawnLineLength
		public real SpawnOffset
				
		private delegate PatternSpawn PatternSpawn
		
		public method GetSpawnPositionCount takes nothing returns integer			
			return R2I(.SpawnLineLength / .SpawnOffset)
		endmethod
		public method GetSpawnPosition takes integer spawnIndex returns vector2
			return vector2.create(.SpawnOrigin.x + Cos(.SpawnLineAngle*bj_DEGTORAD)*(.5*.SpawnOffset + .SpawnOffset*spawnIndex), .SpawnOrigin.y + Sin(.SpawnLineAngle*bj_DEGTORAD)*(.5*.SpawnOffset + .SpawnOffset*spawnIndex))
		endmethod
		
		public method DrawOrigin takes nothing returns nothing
			call Draw_DrawLine(.SpawnOrigin.x, .SpawnOrigin.y, .SpawnOrigin.x + Cos(.SpawnLineAngle*bj_DEGTORAD)*.SpawnLineLength, .SpawnOrigin.y + Sin(.SpawnLineAngle*bj_DEGTORAD)*.SpawnLineLength, 0)
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
		
		//hack helper for avoiding a vJASS abstract class / interface that defines GetSpawnPosition for override by its children
		public static method createFromPoint takes IPatternSpawn spawnCB, integer cycleCount, rect spawnRectPoint returns LinePatternSpawn
			return LinePatternSpawn.create(spawnCB,cycleCount, vector2.create(GetRectCenterX(spawnRectPoint), GetRectCenterY(spawnRectPoint)), 0, 0, 0)
		endmethod
		//nice helper for creating a pattern spawn area from a WE rect
		public static method createFromRect takes IPatternSpawn spawnCB, integer cycleCount, rect spawnRect, real spawnLineOffset returns LinePatternSpawn
			local vector2 spawnOrigin
			local real spawnLineAngle
			local real spawnLineLength
						
			if GetRectMaxX(spawnRect) - GetRectMinX(spawnRect) >= GetRectMaxY(spawnRect) - GetRectMinY(spawnRect) then
				set spawnLineLength = GetRectMaxX(spawnRect) - GetRectMinX(spawnRect)
				set spawnLineAngle = 0 //auto create from rect always starts position index on left side and moves right
				set spawnOrigin = vector2.create(GetRectMinX(spawnRect), (GetRectMaxY(spawnRect) + GetRectMinY(spawnRect)) / 2.)
			else
				set spawnLineLength = GetRectMaxY(spawnRect) - GetRectMinY(spawnRect)
				set spawnLineAngle = 90 //auto create from rect always starts position index on bottom side and moves up
				set spawnOrigin = vector2.create((GetRectMaxX(spawnRect) + GetRectMinX(spawnRect)) / 2., GetRectMinY(spawnRect))
			endif
			
			//bound spawnLineLength to include at least a single location
			//allows tiny rects that define position accurately to also define a single spawn location
			if spawnLineLength < spawnLineOffset then
				set spawnLineLength = spawnLineOffset
			endif
			
			return LinePatternSpawn.create(spawnCB, cycleCount, spawnOrigin, spawnLineAngle, spawnLineLength, spawnLineOffset)
		endmethod
	endstruct
endlibrary