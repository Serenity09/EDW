library IndexedUnit requires UnitDefaultRadius, MovementSpeedHelpers
	struct IndexedUnit extends array
		public unit Unit
		//replace the UnitUserData property that was taken
		public integer Data
		readonly real MoveSpeed //can be any real, max value depends on the struct using the custom movespeed
		
		public boolean Collideable
		public boolean RectangularGeometry
		readonly real Radius //only applies for circular collision, caching rectangular collision is probably not worth the overhead of 4 reals
		readonly real Scale
		
		readonly integer R
		readonly integer G
		readonly integer B
		readonly integer A
						
		implement Alloc
		
		public static method operator [] takes unit u returns thistype
			return GetUnitUserData(u)
		endmethod
		public static method create takes unit u returns thistype
			local integer unitTypeID = GetUnitTypeId(u)
			local integer rand
			
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
				set new.Scale = 1.
			endif
			
			if unitTypeID == PASSENGERCAR then
				//equal weights per color
				set rand = GetRandomInt(0, 4)
				
				if rand == 0 then
					call SetUnitColor(new.Unit, PLAYER_COLOR_CYAN)
				elseif rand == 1 then
					call SetUnitColor(new.Unit, PLAYER_COLOR_YELLOW)
				elseif rand == 2 then
					call SetUnitColor(new.Unit, PLAYER_COLOR_LIGHT_BLUE)
				elseif rand == 3 then
					call SetUnitColor(new.Unit, PLAYER_COLOR_MINT)
				else
					call SetUnitColor(new.Unit, PLAYER_COLOR_LAVENDER)
				endif
			elseif unitTypeID == CORVETTE then
				set rand = GetRandomInt(0, 30)
				
				if rand < 10 then
					call SetUnitColor(new.Unit, PLAYER_COLOR_RED)
				elseif rand < 15 then
					call SetUnitColor(new.Unit, PLAYER_COLOR_ORANGE)
				elseif rand < 25 then
					call SetUnitColor(new.Unit, PLAYER_COLOR_LIGHT_BLUE)
				else
					call SetUnitColor(new.Unit, PLAYER_COLOR_LAVENDER)
				endif
			elseif unitTypeID == TRUCK then
				call SetUnitColor(new.Unit, PLAYER_COLOR_RED)
			endif
			
			//defaults
			set new.R = -1
			set new.MoveSpeed = -1
			
			return new
		endmethod
		
		public method SetScale takes real scale returns nothing		
			static if DEBUG_MODE then
				if this == 0 then
					call DisplayTextToForce(bj_FORCE_PLAYER[0], "WARNING: Setting scale for an unindexed unit")
				endif
			endif
			
			//update related properties. TODO consider supporting scale on rectangular geomtries in the future
			if not this.RectangularGeometry then
				set this.Radius = this.Radius * scale / this.Scale
			endif
			
			set this.Scale = scale
			call SetUnitScale(this.Unit, scale, scale, scale)
		endmethod
		
		public method GetMoveSpeed takes nothing returns real
			if this.MoveSpeed != -1 then
				return this.MoveSpeed
			else
				return GetDefaultMoveSpeed(GetUnitTypeId(this.Unit))
			endif
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