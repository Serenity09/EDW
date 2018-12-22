library IceSkater requires SimpleList, Vector2, IceMovement
	globals
		private constant real TIMESTEP = .1
		private constant real TURN_SMOOTH_DURATION = 0.0
		private constant player NPC_SKATE_PLAYER = Player(10)
		private constant real AXIS_BUFFER = 2.*TERRAIN_TILE_SIZE //amount of buffer to use to infer destination buffer from, specifically applied to checking if a destination is along a vertical or horizontal axis
				
		private timer t = CreateTimer()
	endglobals
	
	private struct Destination extends array
		public vector2 Position
		//TODO replace with vector containing slope and offset values for line orthogonal to path from previous destination, and intersecting next destinations position
		//TODO metadata about destination
		public vector2 QuadrantDirection //value sign pair for what quadrant this destination is in compared to its previous
		//public vector2 PositionNormal //normal through .Position with x = m, y = b for equation thats perpindicular to the straight line between the previous destination and this one
		public real AngleFromPrevious //in degrees, only used for unit facing
		
		implement Alloc
		
		public method print takes nothing returns nothing
			call DisplayTextToForce(bj_FORCE_PLAYER[0], "Printing Destination: " + I2S(this))
			call DisplayTextToForce(bj_FORCE_PLAYER[0], "Position: " + .Position.toString())
			call DisplayTextToForce(bj_FORCE_PLAYER[0], "Quadrant From Previous: " + .QuadrantDirection.toString())
			call DisplayTextToForce(bj_FORCE_PLAYER[0], "Angle From Previous: " + R2S(.AngleFromPrevious))
		endmethod
		
		public method destroy takes nothing returns nothing
			call .Position.destroy()
			call .QuadrantDirection.destroy()
		endmethod
		
		public static method create takes vector2 position, Destination previousDestination returns thistype
			local thistype new = thistype.allocate()
			local vector2 rel
			
			set new.Position = position
			
			//create metadata for later use
			if previousDestination != 0 then
				set rel = vector2.create(position.x, position.y)
				call rel.subtract(previousDestination.Position)
				
				static if DEBUG_MODE then
					//check that destination is at least minimum distance away
					if SquareRoot(rel.x*rel.x + rel.y*rel.y) <= AXIS_BUFFER then
						call DisplayTextToForce(bj_FORCE_PLAYER[0], "Warning, adding a problematic ice skater turn going from: " + position.toString() + ", to: " + previousDestination.Position.toString())
						call DisplayTextToForce(bj_FORCE_PLAYER[0], "Each destination should be at least " + I2S(R2I(AXIS_BUFFER / 128. + .5)) + " tiles away")
					endif
				endif
				
				set new.AngleFromPrevious = rel.getAngleHorizontal() * bj_RADTODEG
				
				call rel.destroy()
			
				if position.x >= previousDestination.Position.x - AXIS_BUFFER and position.x <= previousDestination.Position.x + AXIS_BUFFER then
					if position.y >= previousDestination.Position.y then
						set new.QuadrantDirection = vector2.create(0, 1)
					else
						set new.QuadrantDirection = vector2.create(0, -1)
					endif
				elseif position.y >= previousDestination.Position.y - AXIS_BUFFER and position.y <= previousDestination.Position.y + AXIS_BUFFER then
					if position.x >= previousDestination.Position.x then
						set new.QuadrantDirection = vector2.create(1, 0)
					else
						set new.QuadrantDirection = vector2.create(-1, 0)
					endif
				elseif position.x >= previousDestination.Position.x then
					if position.y >= previousDestination.Position.y then
						set new.QuadrantDirection = vector2.create(1, 1)
					else
						set new.QuadrantDirection = vector2.create(1, -1)
					endif
				else
					if position.y >= previousDestination.Position.y then
						set new.QuadrantDirection = vector2.create(-1, 1)
					else
						set new.QuadrantDirection = vector2.create(-1, -1)
					endif
				endif
			endif
			
			//call DisplayTextToForce(bj_FORCE_PLAYER[0], "Creating destination " + I2S(new))
			//call new.print()
			
			return new
		endmethod
	endstruct
	
	struct IceSkater extends IStartable
		public SimpleList_List Destinations
		public SimpleList_ListNode CurrentDestination
		
		public unit SkateUnit
		public real CurrentAngleDelta
		public real MaxAngleDelta
		public real AngleChangeRate
		public integer CurrentAngleDirection
		
		private static SimpleList_List ActiveSkaters
		
		public method print takes nothing returns nothing
			local SimpleList_ListNode curDestination = .Destinations.first
			
			call DisplayTextToForce(bj_FORCE_PLAYER[0], "Printing Skater: " + I2S(this))
			
			//circular loop safe
			if curDestination != 0 then
				call Destination(curDestination.value).print()
				set curDestination = curDestination.next
			endif
			
			loop
			exitwhen curDestination == 0 or curDestination == .Destinations.first
				call Destination(curDestination.value).print()
			set curDestination = curDestination.next
			endloop
		endmethod
		
		public method AddDestination takes vector2 destination returns nothing
			if .Destinations.count > 0 then
				call .Destinations.addEnd(Destination.create(destination, Destination(.Destinations.last.value)))
			else
				call .Destinations.addEnd(Destination.create(destination, 0))
			endif
		endmethod
		public method ConnectEnds takes nothing returns nothing
			local Destination start = Destinations.first.value
			local Destination end = Destinations.last.value
			
			local vector2 rel = vector2.create(Destination(.Destinations.first.value).Position.x, Destination(.Destinations.first.value).Position.y)
			call rel.subtract(Destination(.Destinations.last.value).Position)
			
			set start.AngleFromPrevious = rel.getAngleHorizontal() * bj_RADTODEG

			call rel.destroy()
			
			//set start.AngleFromPrevious = vector2.getAngle(end, start) * bj_RADTODEG
			
			if start.Position.x >= end.Position.x then
				if start.Position.y >= end.Position.y then
					set start.QuadrantDirection = vector2.create(1, 1)
				else
					set start.QuadrantDirection = vector2.create(1, -1)
				endif
			else
				if start.Position.y >= end.Position.y then
					set start.QuadrantDirection = vector2.create(-1, 1)
				else
					set start.QuadrantDirection = vector2.create(-1, -1)
				endif
			endif
			
			set .Destinations.last.next = .Destinations.first
			set .Destinations.first.prev = .Destinations.last
		endmethod
		
		private method SetDefaults takes nothing returns nothing
			set .CurrentDestination = .Destinations.first.next
			call SetUnitPosition(.SkateUnit, Destination(.Destinations.first.value).Position.x, Destination(.Destinations.first.value).Position.y)
			call SetUnitFacing(.SkateUnit, Destination(.CurrentDestination.value).AngleFromPrevious)
			
			set .CurrentAngleDelta = 0
			set .CurrentAngleDirection = -1
		endmethod
		
		private static method UpdateSkaters takes nothing returns nothing
			local SimpleList_ListNode currentSkaterNode = .ActiveSkaters.first
			local IceSkater currentSkater
			local Destination currentDestination
			//local vector2 unitDirection
			
			//TODO may need to replace this with a theoretical facing which matches expectations 
			//local real facing
			
			loop
			exitwhen currentSkaterNode == 0
				set currentSkater = IceSkater(currentSkaterNode.value)
				set currentDestination = Destination(currentSkater.CurrentDestination.value)
				
				//check if skater has passed their current destination
				if currentDestination.QuadrantDirection.x > 0 then
					if currentDestination.QuadrantDirection.y > 0 then
						if GetUnitX(currentSkater.SkateUnit) >= currentDestination.Position.x and GetUnitY(currentSkater.SkateUnit) >= currentDestination.Position.y then
							set currentSkater.CurrentDestination = currentSkater.CurrentDestination.next
							if currentSkater.CurrentDestination == 0 then
								//instantly reset to starting state -- only occurs if the ends of the destination chain are NOT connected
								call currentSkater.SetDefaults()
							endif
						endif
					elseif currentDestination.QuadrantDirection.y < 0 then
						if GetUnitX(currentSkater.SkateUnit) >= currentDestination.Position.x and GetUnitY(currentSkater.SkateUnit) < currentDestination.Position.y then
							set currentSkater.CurrentDestination = currentSkater.CurrentDestination.next
							if currentSkater.CurrentDestination == 0 then
								//instantly reset to starting state -- only occurs if the ends of the destination chain are NOT connected
								call currentSkater.SetDefaults()
							endif
						endif
					else
						if GetUnitX(currentSkater.SkateUnit) >= currentDestination.Position.x then
							set currentSkater.CurrentDestination = currentSkater.CurrentDestination.next
							if currentSkater.CurrentDestination == 0 then
								//instantly reset to starting state -- only occurs if the ends of the destination chain are NOT connected
								call currentSkater.SetDefaults()
							endif
						endif
					endif
				elseif currentDestination.QuadrantDirection.x < 0 then
					if currentDestination.QuadrantDirection.y > 0 then
						if GetUnitX(currentSkater.SkateUnit) < currentDestination.Position.x and GetUnitY(currentSkater.SkateUnit) >= currentDestination.Position.y then
							set currentSkater.CurrentDestination = currentSkater.CurrentDestination.next
							if currentSkater.CurrentDestination == 0 then
								//instantly reset to starting state -- only occurs if the ends of the destination chain are NOT connected
								call currentSkater.SetDefaults()
							endif
						endif
					elseif currentDestination.QuadrantDirection.y < 0 then
						if GetUnitX(currentSkater.SkateUnit) < currentDestination.Position.x and GetUnitY(currentSkater.SkateUnit) < currentDestination.Position.y then
							set currentSkater.CurrentDestination = currentSkater.CurrentDestination.next
							if currentSkater.CurrentDestination == 0 then
								//instantly reset to starting state -- only occurs if the ends of the destination chain are NOT connected
								call currentSkater.SetDefaults()
							endif
						endif
					else
						if GetUnitX(currentSkater.SkateUnit) < currentDestination.Position.x then
							set currentSkater.CurrentDestination = currentSkater.CurrentDestination.next
							if currentSkater.CurrentDestination == 0 then
								//instantly reset to starting state -- only occurs if the ends of the destination chain are NOT connected
								call currentSkater.SetDefaults()
							endif
						endif
					endif
				else
					if currentDestination.QuadrantDirection.y >= 0 then
						if GetUnitY(currentSkater.SkateUnit) >= currentDestination.Position.y then
							set currentSkater.CurrentDestination = currentSkater.CurrentDestination.next
							if currentSkater.CurrentDestination == 0 then
								//instantly reset to starting state -- only occurs if the ends of the destination chain are NOT connected
								call currentSkater.SetDefaults()
							endif
						endif
					else
						if GetUnitY(currentSkater.SkateUnit) < currentDestination.Position.y then
							set currentSkater.CurrentDestination = currentSkater.CurrentDestination.next
							if currentSkater.CurrentDestination == 0 then
								//instantly reset to starting state -- only occurs if the ends of the destination chain are NOT connected
								call currentSkater.SetDefaults()
							endif
						endif
					endif
				endif
				
				/*
				if currentDestination.QuadrantDirection.x * GetUnitX(currentSkater.SkateUnit) >= currentDestination.Position.x and currentDestination.QuadrantDirection.y * GetUnitY(currentSkater.SkateUnit) >= currentDestination.Position.y then
					call DisplayTextToForce(bj_FORCE_PLAYER[0], "Skater " + I2S(currentSkater) + " reached destination " + I2S(currentDestination))
					
					if currentSkater.CurrentDestination.next != 0 then
						set currentSkater.CurrentDestination = currentSkater.CurrentDestination.next
					else
						//instantly reset to starting state -- only occurs if the ends of the destination chain are NOT connected
						set currentSkater.CurrentDestination = currentSkater.Destinations.first.next
						call SetUnitPosition(currentSkater.SkateUnit, Destination(currentSkater.Destinations.first.value).Position.x, Destination(currentSkater.Destinations.first.value).Position.y)
						call SetUnitFacing(currentSkater.SkateUnit, Destination(currentSkater.CurrentDestination.value).AngleFromPrevious)
					endif
					
					call DisplayTextToForce(bj_FORCE_PLAYER[0], "Next destination is " + I2S(currentSkater.CurrentDestination.value))
					call Destination(currentSkater.CurrentDestination.value).print()
				endif
				*/
				
				//check if exceeding max delta
				if currentSkater.CurrentAngleDelta + currentSkater.CurrentAngleDirection*currentSkater.AngleChangeRate > currentSkater.MaxAngleDelta or currentSkater.CurrentAngleDelta + currentSkater.CurrentAngleDirection*currentSkater.AngleChangeRate < -currentSkater.MaxAngleDelta then
					set currentSkater.CurrentAngleDirection = -currentSkater.CurrentAngleDirection
				endif
				
				set currentSkater.CurrentAngleDelta = currentSkater.CurrentAngleDelta + currentSkater.CurrentAngleDirection*currentSkater.AngleChangeRate
				//set facing = facing + .CurrentAngleDelta
				//set unitDirection = vector2.create(Cos(facing + .CurrentAngleDelta), Sin(facing + .CurrentAngleDelta))
				
				call SetUnitFacingTimed(currentSkater.SkateUnit, Destination(currentSkater.CurrentDestination.value).AngleFromPrevious + currentSkater.CurrentAngleDelta, TURN_SMOOTH_DURATION)
			set currentSkaterNode = currentSkaterNode.next
			endloop
		endmethod
		
		public method Start takes nothing returns nothing
			if not thistype.ActiveSkaters.contains(this) then
				//set .CurrentDestination = .Destinations.first.next
				//call SetUnitPosition(.SkateUnit, Destination(.Destinations.first.value).Position.x, Destination(.Destinations.first.value).Position.y)
				//call SetUnitFacing(.SkateUnit, Destination(.CurrentDestination.value).AngleFromPrevious)
				call .SetDefaults()
				
				call ShowUnit(.SkateUnit, true)
				
				call thistype.ActiveSkaters.add(this)
				call IceMovement_Add(.SkateUnit)
				
				if ActiveSkaters.count == 1 then
                    call TimerStart(t, TIMESTEP, true, function thistype.UpdateSkaters)
                    call DisplayTextToForce(bj_FORCE_PLAYER[0], "Started NPC skater timer")
                endif
			endif
		endmethod
		public method Stop takes nothing returns nothing			
			if thistype.ActiveSkaters.contains(this) then
				call thistype.ActiveSkaters.remove(this)
				call IceMovement_Remove(.SkateUnit)
				
				call ShowUnit(.SkateUnit, false)
				
				if thistype.ActiveSkaters.count == 0 then
                    call PauseTimer(t)
                    call DisplayTextToForce(bj_FORCE_PLAYER[0], "Paused NPC skater timer")
                endif
			endif
		endmethod
		
		public method destroy takes nothing returns nothing
			local SimpleList_ListNode curDestination = .Destinations.first
			
			//calling .Stop only does anything if currently active
			call .Stop()
			
			loop
			exitwhen curDestination == 0
				call Destination(curDestination.value).destroy()
			set curDestination = curDestination.next
			endloop
			
			call .Destinations.destroy()
			set .CurrentDestination = 0
			
			call RemoveUnit(.SkateUnit)
			set .SkateUnit = null
		endmethod
		
		//all angles are input in degrees and then converted to rads if necessary
		public static method create takes vector2 start, vector2 next, integer unitID, real maxAngle, real rawAngleChangeRate returns thistype
			local thistype new = thistype.allocate()
			
			set new.Destinations = SimpleList_List.create()
			call new.AddDestination(start)
			call new.AddDestination(next)
			set new.CurrentDestination = new.Destinations.first.next
			
			set new.SkateUnit = CreateUnit(NPC_SKATE_PLAYER, unitID, start.x, start.y, Destination(new.CurrentDestination.value).AngleFromPrevious)
			//call ShowUnit(new.SkateUnit, false)
			
			set new.MaxAngleDelta = maxAngle
			set new.AngleChangeRate = rawAngleChangeRate*TIMESTEP
			
			//set new.CurrentAngleDelta = 0
			//set new.CurrentAngleDirection = -1
			call new.SetDefaults()
			
			return new
		endmethod
		
		private static method onInit takes nothing returns nothing
			set thistype.ActiveSkaters = SimpleList_List.create()
		endmethod
	endstruct
endlibrary