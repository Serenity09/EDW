library IceSkater requires SimpleList, Vector2, IceMovement
	globals
		private constant real TIMESTEP = .5
		private constant player NPC_SKATE_PLAYER = Player(10)
		private constant real ORDER_DISTANCE_OFFSET = 4*128.
		
		private constant real BUFFER_DISTANCE = 2*128. //amount of 
		
		private timer t = CreateTimer()
	endglobals
	
	private struct Destination extends array
		public vector2 Position
		//TODO metadata about destination
		public vector2 QuadrantDirection //value sign pair for what quadrant this destination is in compared to its previous
		public real AngleFromPrevious //in degrees, only used for unit facing
		public real AngleToNext
		
		implement Alloc
		
		public method print takes nothing returns nothing
			call DisplayTextToForce(bj_FORCE_PLAYER[0], "Printing Destination: " + I2S(this))
			call DisplayTextToForce(bj_FORCE_PLAYER[0], "Position: " + .Position.toString())
			call DisplayTextToForce(bj_FORCE_PLAYER[0], "Quadrant From Previous: " + .QuadrantDirection.toString())
			call DisplayTextToForce(bj_FORCE_PLAYER[0], "Angle From Previous: " + R2S(.AngleFromPrevious))
		endmethod
		
		public static method create takes vector2 position, vector2 previousPosition returns thistype
			local thistype new = thistype.allocate()
			
			set new.Position = position
			
			//create metadata for later use
			if previousPosition != 0 then
				set new.AngleFromPrevious = vector2.getAngle(previousPosition, position) * bj_RADTODEG
			
				if position.x >= previousPosition.x then
					if position.y >= previousPosition.y then
						set new.QuadrantDirection = vector2.create(1, 1)
					else
						set new.QuadrantDirection = vector2.create(1, -1)
					endif
				else
					if position.y >= previousPosition.y then
						set new.QuadrantDirection = vector2.create(-1, 1)
					else
						set new.QuadrantDirection = vector2.create(-1, -1)
					endif
				endif
			endif
			
			call DisplayTextToForce(bj_FORCE_PLAYER[0], "Creating destination " + I2S(new))
			call new.print()
			
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
		
		public method AddDestination takes vector2 destination returns nothing
			if .Destinations.count > 0 then
				call .Destinations.addEnd(Destination.create(destination, Destination(.Destinations.last.value).Position))
			else
				call .Destinations.addEnd(Destination.create(destination, 0))
			endif
		endmethod
		public method ConnectEnds takes nothing returns nothing
			local Destination start = Destinations.first.value
			local Destination end = Destinations.last.value
			
			set start.AngleFromPrevious = vector2.getAngle(end, start) * bj_RADTODEG
			
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
				
				//TODO check if skater has passed their current destination
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
				
				//set facing = GetUnitFacing(currentSkater.SkateUnit)//*DEGREE_TO_RADIANS
				
				//check if exceeding max delta
				if currentSkater.CurrentAngleDelta + currentSkater.CurrentAngleDirection*currentSkater.AngleChangeRate > currentSkater.MaxAngleDelta or currentSkater.CurrentAngleDelta + currentSkater.CurrentAngleDirection*currentSkater.AngleChangeRate < -currentSkater.MaxAngleDelta then
					set currentSkater.CurrentAngleDirection = -currentSkater.CurrentAngleDirection
				endif
				
				set currentSkater.CurrentAngleDelta = currentSkater.CurrentAngleDelta + currentSkater.CurrentAngleDirection*currentSkater.AngleChangeRate
				//set facing = facing + .CurrentAngleDelta
				//set unitDirection = vector2.create(Cos(facing + .CurrentAngleDelta), Sin(facing + .CurrentAngleDelta))
				
				call SetUnitFacingTimed(currentSkater.SkateUnit, Destination(currentSkater.CurrentDestination.value).AngleFromPrevious + currentSkater.CurrentAngleDelta, 0)
			set currentSkaterNode = currentSkaterNode.next
			endloop
		endmethod
		
		public method Start takes nothing returns nothing
			if not thistype.ActiveSkaters.contains(this) then
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
				
				//call ShowUnit(.SkateUnit, false)
				set .CurrentDestination = .Destinations.first.next
				call SetUnitPosition(.SkateUnit, Destination(.Destinations.first.value).Position.x, Destination(.Destinations.first.value).Position.y)
				call SetUnitFacing(.SkateUnit, Destination(.CurrentDestination.value).AngleFromPrevious)
				
				if thistype.ActiveSkaters.count == 0 then
                    call PauseTimer(t)
                    call DisplayTextToForce(bj_FORCE_PLAYER[0], "Paused NPC skater timer")
                endif
			endif
		endmethod
		
		//all angles are input in degrees and then converted to rads if necessary
		public static method create takes vector2 start, vector2 next, integer unitID, real maxAngle, real rawAngleChangeRate returns thistype
			local thistype new = thistype.allocate()
			
			set new.Destinations = SimpleList_List.create()
			call new.AddDestination(start)
			call new.AddDestination(next)
			set new.CurrentDestination = new.Destinations.last
			
			set new.SkateUnit = CreateUnit(NPC_SKATE_PLAYER, unitID, start.x, start.y, Destination(new.Destinations.last.value).AngleFromPrevious)
			//call ShowUnit(new.SkateUnit, false)
			
			set new.MaxAngleDelta = maxAngle
			set new.AngleChangeRate = rawAngleChangeRate*TIMESTEP
			
			set new.CurrentAngleDelta = 0
			set new.CurrentAngleDirection = -1
			
			return new
		endmethod
		
		private static method onInit takes nothing returns nothing
			set thistype.ActiveSkaters = SimpleList_List.create()
		endmethod
	endstruct
endlibrary