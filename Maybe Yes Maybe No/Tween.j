library Tween requires Alloc, vector2
	struct Tween extends array
		public integer TotalFrames
		public integer CurrentFrame
		
		private real StartValue
		private real ChangeValue
		
		public method Apply takes nothing returns nothing
			
		endmethod
		
		public static method create takes real totalTime, real timeStep, real startValue, real endValue returns thistype
			local thistype new = thistype.allocate()
			
			set new.TotalFrames = R2I(totalTime / timeStep)
			set new.StartValue = startValue
			set new.ChangeValue = endValue - startValue
			
			set new.CurrentFrame = 0
			
			return new
		endmethod
	endstruct
	
	struct LinearTween extends array
		public real Slope
		public real Offset
		
		public Tween Base
		
		public method GetValue takes integer frame returns real
			return this.Slope*frame + this.Offset
		endmethod
		
		public static method create takes real totalTime, real timeStep, real startValue, real endValue returns thistype
			local thistype new = Tween.create(totalTime, timeStep, startValue, endValue)
			set new.Base = new
			
			set new.Slope = new.ChangeValue / new.TotalFrames
			set new.Offset = endValue - new.Slope*new.TotalFrames
			
			return new
		endmethod
	endstruct
endlibrary

library Line requires Alloc
	struct Line extends array
		public real Slope
		public real Offset
			
		implement Alloc
		
		public static method create takes real slope, real offset returns thistype
			local thistype new = thistype.allocate()
			
			set new.Slope = slope
			set new.Offset = offset
			
			return new
		endmethod
	endstruct
	
	//solves m,b in y=mx+b for two points
	//represents the line between those points
	function LinearInterpolate takes vector2 p1, vector2 p2 returns Line
		local real slope = (p2.y - p1.y) / (p2.x - p1.x)
		local real offset = p1.y - slope*p1.x
		
		return Line.create(slope, offset)
	endfunction	
	//single variable version more used in CS algs
	//x should be between [0-1]
	function LinearInterpolateSingle takes real start, real end, real x returns real
		return (1 - x)*start + x*end
	endfunction
endlibrary