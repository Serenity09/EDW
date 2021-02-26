library Line requires Alloc, Vector2
	struct LineSegment extends array
		public vector2 Start
		public vector2 End
		
		public vector2 Segment
		public real MagnitudeSquared
		
		// public real Slope
		// public real YIntercept
		
		implement Alloc
		
		method operator Magnitude takes nothing returns real
			return SquareRoot(this.MagnitudeSquared)
		endmethod
		
		public method ProjectPoint takes vector2 point returns vector2
			local real scalar = vector2.dotProduct(this.Segment, point) / this.MagnitudeSquared
			
			return vector2.create(scalar * this.Segment.x, scalar * this.Segment.y)
		endmethod
		public method GetProjectedDistanceFromPoint takes vector2 point returns real
			local vector2 projectedPoint = this.ProjectPoint(point)
			local real distance = SquareRoot(vector2.dotProduct(projectedPoint, projectedPoint))
			
			call projectedPoint.deallocate()
			return distance
		endmethod
		public method GetProjectedPercentFromPoint takes vector2 point returns real
			local vector2 projectedPoint = this.ProjectPoint(point)
			local real percent = projectedPoint.getLength() / SquareRoot(this.MagnitudeSquared)
			
			call projectedPoint.deallocate()
			return percent
		endmethod
		
		public method GetDistanceSquaredFromPoint takes vector2 point returns real
			// local vector2 ps = vector2.create(point.x - this.Start.x, point.y - this.Start.y)
			local vector2 pe = vector2.create(point.x - this.End.x, point.y - this.End.y)
			local real c = vector2.dotProduct(this.Segment, pe)
			
			local vector2 sp
			local vector2 d
			
			local real distance = -1
			
			if c > 0 then
				set distance = vector2.dotProduct(pe, pe)
			else
				set sp = vector2.create(this.Start.x - point.x, this.Start.y - point.y)
				// set ep = vector2.create(this.End.x - point.x, this.End.y - point.y)
				
				if vector2.dotProduct(this.Segment, sp) > 0 then
					set distance = vector2.dotProduct(sp, sp)
				else
					set d = vector2.create(pe.x - c / this.MagnitudeSquared * this.Segment.x, pe.y - c / this.MagnitudeSquared * this.Segment.y)
					set distance = vector2.dotProduct(d, d)
					
					call d.deallocate()
				endif
				
				call sp.deallocate()
			endif
			
			call pe.deallocate()
			
			return distance
		endmethod
		public method GetDistanceFromPoint takes vector2 point returns real
			return SquareRoot(this.GetDistanceSquaredFromPoint(point))
		endmethod
				
		public method DrawEx takes string fx returns lightning
			return Draw_DrawVectorLineEx(this.Start, this.End, 0., fx, false)
		endmethod
		public method Draw takes nothing returns lightning
			return Draw_DrawVectorLine(this.Start, this.End, 0.)
		endmethod
		
		public static method create takes vector2 start, vector2 end returns thistype
			local thistype new = thistype.allocate()
			
			set new.Start = start
			set new.End = end
			
			set new.Segment = vector2.create(end.x-start.x, end.y-start.y)
			set new.MagnitudeSquared = vector2.dotProduct(new.Segment, new.Segment)
			
			// set new.Slope = new.End.y - new.Start.y / new.End.x - new.Start.x
			// set new.YIntercept = new.Start.y / new.Start.x * new.Slope
			
			return new
		endmethod
		public method destroy takes nothing returns nothing
			call this.Start.deallocate()
			call this.End.deallocate()
			
			call this.deallocate()
		endmethod
	endstruct
endlibrary