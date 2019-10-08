library RelativeVector2 requires Vector2
	struct relativeVector2 extends array
		public thistype Parent
		
		public method getAbsolutePosition takes nothing returns vector2
			local vector2 position
			
			if this.Parent == 0 then
				return vector2.create(vector2(this).x, vector2(this).y)
			else
				set position = this.Parent.getAbsolutePosition()
				
				set position.x = position.x + vector2(this).x
				set position.y = position.y + vector2(this).y
				
				return position
			endif
		endmethod
		
		public static method createFromAbsolute takes real absX, real absY, thistype parent returns thistype
			local vector2 new
			
			if parent == 0 then
				set new = vector2.create(absX, absY)
			else
				set new = parent.getAbsolutePosition()
				set new.x = absX - new.x
				set new.y = absY - new.y
			endif
						
			set thistype(new).Parent = parent
			
			return new
		endmethod
		public static method create takes real x, real y, thistype parent returns thistype
			local thistype new = vector2.create(x, y)
			
			set new.Parent = parent
			
			return new
		endmethod
		public method destroy takes nothing returns nothing
			set this.Parent = 0
			
			call vector2(this).deallocate()
		endmethod
	endstruct
endlibrary