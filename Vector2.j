library Vector2
//*****************************************************************
//*  VECTOR LIBRARY
//*
//*  written by: Anitarf
//*  re-written in 2d by: Serenity09
//*
//*  The library contains a struct named vector, which represents a
//*  point in 2D space. As such, it has three real members, one for
//*  each coordinate: x, y, z. It also has the following methods:
//*
//*        static method create takes real x, real y, real z returns vector
//*  Creates a new vector with the given coordinates.
//*
//*        method getLength takes nothing returns real
//*  Returns the length of the vector it is called on.
//*
//*        static method sum takes vector augend, vector addend returns vector
//*  Returns the sum of two vectors as a new vector.
//*
//*        method add takes vector addend returns nothing
//*  Similar to sum, except that it doesn't create a new vector for the result,
//*  but changes the vector it is called on by adding the "added" to it.
//*
//*        static method difference takes vector minuend, vector subtrahend returns vector
//*  Returns the difference between two vectors as a new vector.
//*
//*        method subtract takes vector subtrahend returns nothing
//*  Similar to difference, except that it doesn't create a new vector for the result,
//*  but changes the vector it is called on by subtracting the "subtrahend" from it.
//*
//*        method scale takes real factor returns nothing
//*  Scales the vector it is called on by the given factor.
//*
//*        method setLength takes real length returns nothing
//*  Sets the length of the vector it is called on to the given value, maintaining its orientation.
//*
//*        static method dotProduct takes vector a, vector b returns real
//*  Calculates the dot product (also called scalar product) of two vectors.
//*
//*        static method projectionVector takes vector projected, vector direction returns vector
//*  Calculates the projection of the vector "projected" onto the vector "direction"
//*  and returns it as a new vector.
//*  Returns null if the vector "direction" has a length of 0.
//*
//*        method projectVector takes vector direction returns nothing
//*  Projects the vector it is called on onto the vector "direction".
//*  Does nothing if the vector "direction" has a length of 0.
//*
//*        static method getAngle takes vector a, vector b returns real
//*  Returns the angle between two vectors, in radians, returns a value between 0 and pi.
//*  Returns 0.0 if any of the vectors are 0 units long.
//*
//*        method rotate takes vector axis, real angle returns nothing
//*  Rotates the vector it is called on around the axis defined by the vector "axis"
//*  by the given angle, which should be input in radians.
//*  Does nothing if axis is 0 units long.
//*
//*****************************************************************

    struct vector2 extends array
        real x
        real y
        
        implement Alloc
        
        static method create takes real x, real y returns vector2
            local vector2 v = thistype.allocate()
            
            set v.x=x
            set v.y=y
			//debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Created vector2, current usage" + I2S(.calculateMemoryUsage()))
            return v
        endmethod
		static method createFromRect takes rect r returns vector2
			return vector2.create(GetRectCenterX(r), GetRectCenterY(r))
		endmethod
        
        public method destroy takes nothing returns nothing
            //add to recycle stack
            call this.deallocate()
			//debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Destroyed vector2, current usage" + I2S(.calculateMemoryUsage()))
        endmethod
        
        method getLength takes nothing returns real
          return SquareRoot(.x*.x + .y*.y)
        endmethod
        
        method add takes vector2 addend returns nothing
            set this.x=this.x+addend.x
            set this.y=this.y+addend.y
        endmethod
        
        method subtract takes vector2 subtrahend returns nothing
            set this.x=this.x-subtrahend.x
            set this.y=this.y-subtrahend.y
        endmethod
        
        method scale takes real factor returns nothing
            set this.x=this.x*factor
            set this.y=this.y*factor
        endmethod
        
        method setLength takes real length returns nothing
            local real l = SquareRoot(.x*.x + .y*.y)
            static if DEBUG_MODE then
				if l == 0.0 then
					debug call BJDebugMsg("vector.setLength error: The length of the vector is 0.0!")
					return
				endif
			endif
            set l = length/l
            set this.x = this.x*l
            set this.y = this.y*l
        endmethod
        
        method toString takes nothing returns string
            return R2S(.x) + "," + R2S(.y)
        endmethod
		static method fromString takes string s returns thistype
			local thistype v = thistype.allocate()
			local integer length = StringLength(s)
			local integer position = -1
			local integer mid = length / 2
			local integer i = 0
			
			loop
			exitwhen mid + i > length or position != -1
				if mid + i + 1 < length and SubString(s, mid + i, mid + i + 1) == "," then
					set position = mid + i
				elseif mid - i - 1 >= 0 and SubString(s, mid - i - 1, mid - i) == "," then
					set position = mid - i - 1
				endif
			set i = i + 1
			endloop
			
			// call BJDebugMsg("Position starting up: " + SubString(s, position, position + 1) + ", down" + SubString(s, position - 1, position))
			// call BJDebugMsg("First part: " + SubString(s, 0, position) + ", second part: " + SubString(s, position + 1, length))
			
			set v.x = S2R(SubString(s, 0, position))
			set v.y = S2R(SubString(s, position + 1, length))
			
			return v
		endmethod
        
        static method dotProduct takes vector2 a, vector2 b returns real
            return (a.x*b.x + a.y*b.y)
        endmethod
		
		method getAngleHorizontal takes nothing returns real
			return Atan2(.y, .x)
		endmethod
		
		method angleBetween takes vector2 other returns real
			// local real sin = this.x*other.y - this.y*other.x
			// local real cos = this.x*other.x + this.y*other.y
			
			// return Atan2(sin, cos)			
			return Atan2(this.x*other.y - this.y*other.x, this.x*other.x + this.y*other.y)
		endmethod
		
// ================================================================
        method projectVector takes vector2 direction returns nothing
            local real l = direction.x*direction.x+direction.y*direction.y
            static if DEBUG_MODE then
				if l == 0.0 then
					debug call BJDebugMsg("vector.projectVector error: The length of the direction vector is 0.0!")
					return
				endif
			endif
            set l = (this.x*direction.x+this.y*direction.y) / l
            set this.x = direction.x*l
            set this.y = direction.y*l
        endmethod
        method projectUnitVector takes vector2 unitDirection returns nothing
            local real l
            
            set l = this.x*unitDirection.x+this.y*unitDirection.y
            set this.x = unitDirection.x*l
            set this.y = unitDirection.y*l
        endmethod
		
		static method unitInDirection takes real direction returns thistype
			return thistype.create(Cos(direction), Sin(direction))
		endmethod
        static method getAngle takes vector2 a, vector2 b returns real
            local real l = SquareRoot(a.x*a.x + a.y*a.y)*SquareRoot(b.x*b.x + b.y*b.y)
            static if DEBUG_MODE then
				if l == 0 then
					debug call BJDebugMsg("vector.getAngle error: The length of at least one of the vectors is 0.0!")
					return 0.0
				endif
			endif
            return Acos((a.x*b.x+a.y*b.y)/l) //angle is returned in radians
        endmethod
		
		method distanceToSquare takes vector2 squareCenter, real size returns real
			local real dx = 0
			local real dy = 0
			
			local real temp = squareCenter.x - size - .x
			
			if temp > dx then
				set dx = temp
			endif
			set temp = .x - squareCenter.x - size
			if temp > dx then
				set dx = temp
			endif
			
			set temp = squareCenter.y - size - .y
			if temp > dy then
				set dy = temp
			endif
			set temp = .y - squareCenter.y - size
			if temp > dy then
				set dy = temp
			endif
			
			return SquareRoot(dx*dx + dy*dy)
		endmethod
		method distanceToRect takes vector2 rectMin, vector2 rectMax returns real
			local real dx = 0
			local real dy = 0
			
			local real temp = rectMin.x - .x
			
			if temp > dx then
				set dx = temp
			endif
			set temp = .x - rectMax.x
			if temp > dx then
				set dx = temp
			endif
			
			set temp = rectMin.y - .y
			if temp > dy then
				set dy = temp
			endif
			set temp = .y - rectMax.y
			if temp > dy then
				set dy = temp
			endif
			
			return SquareRoot(dx*dx + dy*dy)
		endmethod
    endstruct
endlibrary