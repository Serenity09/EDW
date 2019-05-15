library IndexedUnit
	struct IndexedUnit extends array
		public unit Unit
		public IStartable ParentStartable
		readonly real MoveSpeed //can be any real, max value depends on the struct using the custom movespeed
		
		public boolean Collideable
		public boolean RectangularGeometry
		readonly real Radius //only applies for circular collision, caching rectangular collision is probably not worth the overhead of 4 reals
		
		readonly integer R
		readonly integer G
		readonly integer B
		readonly integer A
		
		implement Alloc
		
		public static method create takes unit u returns thistype
			local integer unitTypeID = GetUnitTypeId(u)
			static if DEBUG_MODE then
				local thistype new
				
				if GetUnitUserData(u) != 0 then
					call DisplayTextToForce(bj_FORCE_PLAYER[0], "Indexing unit that has user data!")
					//is it better to mirror release code state or to catch and manage the leak so other tests, including this one, may proceed?
					return GetUnitUserData(u)
				endif
				
				set new = thistype.allocate()
			else
				local thistype new = thistype.allocate()
			endif
			
			set new.Unit = u
			call SetUnitUserData(u, new)
			
			//set properties that will be used for any indexed unit
			//set new.MoveSpeed = GetUnitMoveSpeed(u)
			set new.Collideable = unitTypeID != MAZER and unitTypeID != PLATFORMERWISP and unitTypeID != GREENFROG and unitTypeID != ORANGEFROG and unitTypeID != PURPLEFROG and unitTypeID != TURQOISEFROG and unitTypeID != REDFROG and unitTypeID != SMLTARG and unitTypeID != BLACKHOLE
			set new.RectangularGeometry = unitTypeID == TANK or unitTypeID == TRUCK or unitTypeID == FIRETRUCK or unitTypeID == AMBULANCE or unitTypeID == JEEP or unitTypeID == PASSENGERCAR or unitTypeID == CORVETTE or unitTypeID == POLICECAR
			if not new.RectangularGeometry then
				set new.Radius = GetUnitDefaultRadius(unitTypeID)
			endif
			
			//defaults
			set new.R = -1
			
			return new
		endmethod
		
		public method UpdateMoveSpeed takes nothing returns nothing
			set this.MoveSpeed = GetUnitMoveSpeed(this.Unit)
		endmethod
		public method SetMoveSpeed takes real movespeed returns nothing
			set this.MoveSpeed = movespeed
			call SetUnitMoveSpeed(this.Unit, movespeed)
		endmethod
		
		//NOT safe to call for GetLocalPlayer
		public method InitializeVertexColor takes nothing returns nothing
			local integer unitTypeID = GetUnitTypeId(this.Unit)
			
			if unitTypeID == REDFROG then
				set this.R = 255
				set this.G = 3
				set this.B = 3
			// elseif unitTypeID == GREENFROG then
				// set this.R = 255
				// set this.G = 255
				// set this.B = 255
			elseif unitTypeID == PURPLEFROG then
				set this.R = 190
				set this.G = 0
				set this.B = 254
			elseif unitTypeID == ORANGEFROG then
				set this.R = 254
				set this.G = 65
				set this.B = 14
			elseif unitTypeID == TURQOISEFROG then
				set this.R = 0
				set this.G = 184
				set this.B = 255
			else
				set this.R = 255
				set this.G = 255
				set this.B = 255
			endif
			
			set this.A = 255
		endmethod
		public method SetVertexColor takes integer r, integer g, integer b, integer a returns nothing
			set this.R = r
			set this.G = g
			set this.B = b
			set this.A = a
			
			call SetUnitVertexColor(this.Unit, r, g, b, a)
		endmethod
		public method SetColor takes integer r, integer g, integer b returns nothing
			set this.R = r
			set this.G = g
			set this.B = b
			
			call SetUnitVertexColor(this.Unit, r, g, b, this.A)
		endmethod
		public method SetAlpha takes integer a returns nothing
			set this.A = a
			
			call SetUnitVertexColor(this.Unit, this.R, this.G, this.B, a)
		endmethod
		//the only colorization method that is safe to call in a local player block
		public method SetAlphaLocal takes integer a returns nothing
			call SetUnitVertexColor(this.Unit, this.R, this.G, this.B, a)
		endmethod
		
		public method destroy takes nothing returns nothing
			call SetUnitUserData(this.Unit, 0)
			set this.Unit = null
			
			call this.deallocate()
		endmethod
	endstruct
endlibrary