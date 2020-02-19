library PlatformerIce initializer Init requires SimpleList, PlatformerGlobals
    globals
        public constant real TIMESTEP = .1
        
        //properties that are applied in the main physics loop should be relative to that timestep
        public constant real SLOW_MS = .25
        public constant real SLOW_XFALLOFF = .1
        public constant real SLOW_YFALLOFF = .1
        public constant real SLOW_OPPOSITIONDIFFERENCE = .1
        
        public constant real SLOW_VELOCITY = 20 * TIMESTEP
        public constant real SLOW_MAX_VELOCITY = PLATFORMING_MAXCHANGE * .75
		
		// private string VFX_PATH = "Abilities\\Spells\\Undead\\FrostArmor\\FrostArmorDamage.mdl"
		private constant string VFX_PATH = "war3mapImported\\2d-skating.mdx"
		private constant string ALT_VFX_PATH = "war3mapImported\\2d-skating-alt.mdx"
		private constant real ALT_VFX_MIN_RATE = .5 * TIMESTEP
		private constant real ALT_VFX_MAX_RATE = 10. * TIMESTEP
		private constant real ALT_VFX_RATE_CAP = PLATFORMING_MAXCHANGE * .1
		private constant real ALT_VFX_TIMEOUT = 4.
		
        public constant real FAST_MS = .1
        public constant real FAST_XFALLOFF = .01
        public constant real FAST_YFALLOFF = .01
        public constant real FAST_OPPOSITIONDIFFERENCE = 0.
        
		//properties applied in this timer loop should be relative to it's timestep
        public constant real FAST_VELOCITY = 40 * TIMESTEP
        public constant real FAST_MAX_VELOCITY = PLATFORMING_MAXCHANGE * 4.
        
        public constant real HYBRID_VELOCITY = (SLOW_VELOCITY + FAST_VELOCITY) / 2.
		public constant real HYBRID_MAX_VELOCITY = (SLOW_MAX_VELOCITY + FAST_MAX_VELOCITY) / 2.
        public constant real HYBRID_OPP_VELOCITY = (SLOW_VELOCITY * SLOW_OPPOSITIONDIFFERENCE + FAST_VELOCITY * FAST_OPPOSITIONDIFFERENCE) / 2.
        
        private timer Timer
        public SimpleList_List Platformers
		
		private real array AltVFXTimeout
		private real array PreviousXVelocity
		private real array PreviousYVelocity
		
		private constant boolean DEBUG_ICE_LOOP = false
		private constant boolean DEBUG_VELOCITY = false
		private constant boolean DEBUG_ALT_VFX = false
    endglobals
    
    private function Loop takes Platformer p returns nothing        
        local vector2 projVelocity
        local real distance
        local real maxDistance
        
		local real xAcceleration
		local real yAcceleration
		local real accelerationDistance
		
		static if DEBUG_ICE_LOOP then
			call DisplayTextToForce(bj_FORCE_PLAYER[0], "Before ice physics ---")
		endif
        //design concept:
        //movement left and right should be like sledding -- lots of velocity with a bit of control
		
		//need to check that platformer is still on a diagonal because the terrain loop (which controls this callbacks parameters) runs at a different, much slower rate than the physics loop
		//the terrain loop can claim that the platformer is still on ice (and still in this callback group) while the physics loop has since established that they've left a diagonal
        if p.OnDiagonal and p.HorizontalAxisState != 0 then
			//project velocity vector against current diagonal to match actual direction
			set projVelocity = vector2.create(p.XVelocity, p.YVelocity)
			call projVelocity.projectUnitVector(ComplexTerrainPathing_GetParallelForPathing(p.DiagonalPathing.TerrainPathingForPoint))
			
			//get the maximum velocity for the relevant terrain type
			if (p.XTerrainPushedAgainst == SLOWICE and p.YTerrainPushedAgainst == FASTICE) or (p.XTerrainPushedAgainst == FASTICE and p.YTerrainPushedAgainst == SLOWICE) then
				set maxDistance = HYBRID_MAX_VELOCITY
			elseif p.XTerrainPushedAgainst == SLOWICE or p.YTerrainPushedAgainst == SLOWICE then
				set maxDistance = SLOW_MAX_VELOCITY
			elseif p.XTerrainPushedAgainst == FASTICE or p.YTerrainPushedAgainst == FASTICE then
				set maxDistance = FAST_MAX_VELOCITY
			endif
			
			set distance = SquareRoot(projVelocity.x*projVelocity.x + projVelocity.y*projVelocity.y)
			
			if distance < maxDistance then
				if p.HorizontalAxisState == 1 then
					if projVelocity.x >= 0 then //velocity right
						if p.DiagonalPathing != 0 then
							//only effects x velocity when on top or bottom
							if p.DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_Top or p.DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_Bottom then
								if p.YTerrainPushedAgainst == SLOWICE then
									set projVelocity.x = projVelocity.x + SLOW_VELOCITY
								elseif p.YTerrainPushedAgainst == FASTICE then
									set projVelocity.x = projVelocity.x + FAST_VELOCITY
								endif
							//also effects y velocity when on diagonal pieces
							elseif p.DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_NE then
								if (p.XTerrainPushedAgainst == SLOWICE and p.YTerrainPushedAgainst == FASTICE) or (p.XTerrainPushedAgainst == FASTICE and p.YTerrainPushedAgainst == SLOWICE) then
									set projVelocity.x = projVelocity.x + HYBRID_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y - HYBRID_VELOCITY * SIN_45
								elseif p.XTerrainPushedAgainst == SLOWICE then
									set projVelocity.x = projVelocity.x + SLOW_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y - SLOW_VELOCITY * SIN_45
								elseif p.XTerrainPushedAgainst == FASTICE then
									set projVelocity.x = projVelocity.x + FAST_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y - FAST_VELOCITY * SIN_45
								endif
							elseif p.DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_SE then
								if (p.XTerrainPushedAgainst == SLOWICE and p.YTerrainPushedAgainst == FASTICE) or (p.XTerrainPushedAgainst == FASTICE and p.YTerrainPushedAgainst == SLOWICE) then
									set projVelocity.x = projVelocity.x + HYBRID_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y + HYBRID_VELOCITY * SIN_45
								elseif p.XTerrainPushedAgainst == SLOWICE then
									set projVelocity.x = projVelocity.x + SLOW_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y + SLOW_VELOCITY * SIN_45
								elseif p.XTerrainPushedAgainst == FASTICE then
									set projVelocity.x = projVelocity.x + FAST_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y + FAST_VELOCITY * SIN_45
								endif
							elseif p.DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_SW then
								if (p.XTerrainPushedAgainst == SLOWICE and p.YTerrainPushedAgainst == FASTICE) or (p.XTerrainPushedAgainst == FASTICE and p.YTerrainPushedAgainst == SLOWICE) then
									set projVelocity.x = projVelocity.x + HYBRID_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y - HYBRID_VELOCITY * SIN_45
								elseif p.XTerrainPushedAgainst == SLOWICE then
									set projVelocity.x = projVelocity.x + SLOW_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y - SLOW_VELOCITY * SIN_45
								elseif p.XTerrainPushedAgainst == FASTICE then
									set projVelocity.x = projVelocity.x + FAST_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y - FAST_VELOCITY * SIN_45
								endif
							elseif p.DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_NW then
								if (p.XTerrainPushedAgainst == SLOWICE and p.YTerrainPushedAgainst == FASTICE) or (p.XTerrainPushedAgainst == FASTICE and p.YTerrainPushedAgainst == SLOWICE) then
									set projVelocity.x = projVelocity.x + HYBRID_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y + HYBRID_VELOCITY * SIN_45
								elseif p.XTerrainPushedAgainst == SLOWICE then
									set projVelocity.x = projVelocity.x + SLOW_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y + SLOW_VELOCITY * SIN_45
								elseif p.XTerrainPushedAgainst == FASTICE then
									set projVelocity.x = projVelocity.x + FAST_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y + FAST_VELOCITY * SIN_45
								endif
							endif
							
							//play effect when moving in same direction
							// call DestroyEffect(AddSpecialEffect(VFX_PATH, p.XPosition - p.PushedAgainstVector.x * PlatformerGlobals_RADIUS, p.YPosition - p.PushedAgainstVector.y * PlatformerGlobals_RADIUS))
						endif
					else
						if p.DiagonalPathing != 0 then
							//only effects x velocity when on top or bottom
							if p.DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_Top or p.DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_Bottom then
								if p.YTerrainPushedAgainst == SLOWICE then
									set projVelocity.x = projVelocity.x + SLOW_VELOCITY * SLOW_OPPOSITIONDIFFERENCE
								elseif p.YTerrainPushedAgainst == FASTICE then
									set projVelocity.x = projVelocity.x + FAST_VELOCITY * FAST_OPPOSITIONDIFFERENCE
								endif
							
							//no effect when on left or right wall
							
							//also effects y velocity when on diagonal pieces
							elseif p.DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_NE then
								if (p.XTerrainPushedAgainst == SLOWICE and p.YTerrainPushedAgainst == FASTICE) or (p.XTerrainPushedAgainst == FASTICE and p.YTerrainPushedAgainst == SLOWICE) then
									set projVelocity.x = projVelocity.x + HYBRID_OPP_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y - HYBRID_OPP_VELOCITY * SIN_45
								elseif p.XTerrainPushedAgainst == SLOWICE then
									set projVelocity.x = projVelocity.x + SLOW_VELOCITY * SLOW_OPPOSITIONDIFFERENCE * SIN_45
									set projVelocity.y = projVelocity.y - SLOW_VELOCITY * SLOW_OPPOSITIONDIFFERENCE * SIN_45
								elseif p.XTerrainPushedAgainst == FASTICE then
									set projVelocity.x = projVelocity.x + FAST_VELOCITY * FAST_OPPOSITIONDIFFERENCE * SIN_45
									set projVelocity.y = projVelocity.y - FAST_VELOCITY * FAST_OPPOSITIONDIFFERENCE * SIN_45
								endif
							elseif p.DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_SE then
								if (p.XTerrainPushedAgainst == SLOWICE and p.YTerrainPushedAgainst == FASTICE) or (p.XTerrainPushedAgainst == FASTICE and p.YTerrainPushedAgainst == SLOWICE) then
									set projVelocity.x = projVelocity.x + HYBRID_OPP_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y + HYBRID_OPP_VELOCITY * SIN_45
								elseif p.XTerrainPushedAgainst == SLOWICE then
									set projVelocity.x = projVelocity.x + SLOW_VELOCITY * SLOW_OPPOSITIONDIFFERENCE * SIN_45
									set projVelocity.y = projVelocity.y + SLOW_VELOCITY * SLOW_OPPOSITIONDIFFERENCE * SIN_45
								elseif p.XTerrainPushedAgainst == FASTICE then
									set projVelocity.x = projVelocity.x + FAST_VELOCITY * FAST_OPPOSITIONDIFFERENCE * SIN_45
									set projVelocity.y = projVelocity.y + FAST_VELOCITY * FAST_OPPOSITIONDIFFERENCE * SIN_45
								endif
							elseif p.DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_SW then
								if (p.XTerrainPushedAgainst == SLOWICE and p.YTerrainPushedAgainst == FASTICE) or (p.XTerrainPushedAgainst == FASTICE and p.YTerrainPushedAgainst == SLOWICE) then
									set projVelocity.x = projVelocity.x + HYBRID_OPP_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y - HYBRID_OPP_VELOCITY * SIN_45
								elseif p.XTerrainPushedAgainst == SLOWICE then
									set projVelocity.x = projVelocity.x + SLOW_VELOCITY * SLOW_OPPOSITIONDIFFERENCE * SIN_45
									set projVelocity.y = projVelocity.y - SLOW_VELOCITY * SLOW_OPPOSITIONDIFFERENCE * SIN_45
								elseif p.XTerrainPushedAgainst == FASTICE then
									set projVelocity.x = projVelocity.x + FAST_VELOCITY * FAST_OPPOSITIONDIFFERENCE * SIN_45
									set projVelocity.y = projVelocity.y - FAST_VELOCITY * FAST_OPPOSITIONDIFFERENCE * SIN_45
								endif
							elseif p.DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_NW then
								if (p.XTerrainPushedAgainst == SLOWICE and p.YTerrainPushedAgainst == FASTICE) or (p.XTerrainPushedAgainst == FASTICE and p.YTerrainPushedAgainst == SLOWICE) then
									set projVelocity.x = projVelocity.x + HYBRID_OPP_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y + HYBRID_OPP_VELOCITY * SIN_45
								elseif p.XTerrainPushedAgainst == SLOWICE then
									set projVelocity.x = projVelocity.x + SLOW_VELOCITY * SLOW_OPPOSITIONDIFFERENCE * SIN_45
									set projVelocity.y = projVelocity.y + SLOW_VELOCITY * SLOW_OPPOSITIONDIFFERENCE * SIN_45
								elseif p.XTerrainPushedAgainst == FASTICE then
									set projVelocity.x = projVelocity.x + FAST_VELOCITY * FAST_OPPOSITIONDIFFERENCE * SIN_45
									set projVelocity.y = projVelocity.y + FAST_VELOCITY * FAST_OPPOSITIONDIFFERENCE * SIN_45
								endif
							endif
						endif
					endif				
				elseif p.HorizontalAxisState == -1 then
					if projVelocity.x <= 0 then //velocity left
						if p.DiagonalPathing != 0 then
							//only effects x velocity when on top or bottom
							if p.DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_Top or p.DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_Bottom then
								if p.YTerrainPushedAgainst == SLOWICE then
									set projVelocity.x = projVelocity.x - SLOW_VELOCITY
								elseif p.YTerrainPushedAgainst == FASTICE then
									set projVelocity.x = projVelocity.x - FAST_VELOCITY
								endif
							
							//debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "X Velocity after: " + R2S(p.XVelocity))
							//also effects y velocity when on diagonal pieces
							elseif p.DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_NE then
								if (p.XTerrainPushedAgainst == SLOWICE and p.YTerrainPushedAgainst == FASTICE) or (p.XTerrainPushedAgainst == FASTICE and p.YTerrainPushedAgainst == SLOWICE) then
									set projVelocity.x = projVelocity.x - HYBRID_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y + HYBRID_VELOCITY * SIN_45
								elseif p.XTerrainPushedAgainst == SLOWICE then
									set projVelocity.x = projVelocity.x - SLOW_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y + SLOW_VELOCITY * SIN_45
								elseif p.XTerrainPushedAgainst == FASTICE then
									set projVelocity.x = projVelocity.x - FAST_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y + FAST_VELOCITY * SIN_45
								endif
							elseif p.DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_SE then
								if (p.XTerrainPushedAgainst == SLOWICE and p.YTerrainPushedAgainst == FASTICE) or (p.XTerrainPushedAgainst == FASTICE and p.YTerrainPushedAgainst == SLOWICE) then
									set projVelocity.x = projVelocity.x - HYBRID_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y - HYBRID_VELOCITY * SIN_45
								elseif p.XTerrainPushedAgainst == SLOWICE then
									set projVelocity.x = projVelocity.x - SLOW_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y - SLOW_VELOCITY * SIN_45
								elseif p.XTerrainPushedAgainst == FASTICE then
									set projVelocity.x = projVelocity.x - FAST_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y - FAST_VELOCITY * SIN_45
								endif
							elseif p.DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_SW then
								if (p.XTerrainPushedAgainst == SLOWICE and p.YTerrainPushedAgainst == FASTICE) or (p.XTerrainPushedAgainst == FASTICE and p.YTerrainPushedAgainst == SLOWICE) then
									set projVelocity.x = projVelocity.x - HYBRID_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y + HYBRID_VELOCITY * SIN_45
								elseif p.XTerrainPushedAgainst == SLOWICE then
									set projVelocity.x = projVelocity.x - SLOW_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y + SLOW_VELOCITY * SIN_45
								elseif p.XTerrainPushedAgainst == FASTICE then
									set projVelocity.x = projVelocity.x - FAST_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y + FAST_VELOCITY * SIN_45
								endif
							elseif p.DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_NW then
								if (p.XTerrainPushedAgainst == SLOWICE and p.YTerrainPushedAgainst == FASTICE) or (p.XTerrainPushedAgainst == FASTICE and p.YTerrainPushedAgainst == SLOWICE) then
									set projVelocity.x = projVelocity.x - HYBRID_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y - HYBRID_VELOCITY * SIN_45
								elseif p.XTerrainPushedAgainst == SLOWICE then
									set projVelocity.x = projVelocity.x - SLOW_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y - SLOW_VELOCITY * SIN_45
								elseif p.XTerrainPushedAgainst == FASTICE then
									set projVelocity.x = projVelocity.x - FAST_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y - FAST_VELOCITY * SIN_45
								endif
							endif
							
							//play effect when moving in same direction
							// call DestroyEffect(AddSpecialEffect(VFX_PATH, p.XPosition - p.PushedAgainstVector.x * PlatformerGlobals_RADIUS, p.YPosition - p.PushedAgainstVector.y * PlatformerGlobals_RADIUS))
						endif
					else
						//debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "(same) before: " + R2S(p.XVelocity) + " after: " + R2S(p.XVelocity - p.MoveSpeed * OCEAN_MOTION))
						if p.DiagonalPathing != 0 then
							//only effects x velocity when on top or bottom
							if p.DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_Top or p.DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_Bottom then
								if p.YTerrainPushedAgainst == SLOWICE then
									set projVelocity.x = projVelocity.x - SLOW_VELOCITY * SLOW_OPPOSITIONDIFFERENCE
								elseif p.YTerrainPushedAgainst == FASTICE then
									set projVelocity.x = projVelocity.x - FAST_VELOCITY * FAST_OPPOSITIONDIFFERENCE
								endif
								
								//debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "X Velocity after: " + R2S(p.XVelocity))
							//no effect when on left or right wall
							
							//also effects y velocity when on diagonal pieces
							elseif p.DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_NE then
								if (p.XTerrainPushedAgainst == SLOWICE and p.YTerrainPushedAgainst == FASTICE) or (p.XTerrainPushedAgainst == FASTICE and p.YTerrainPushedAgainst == SLOWICE) then
									set projVelocity.x = projVelocity.x - HYBRID_OPP_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y + HYBRID_OPP_VELOCITY * SIN_45
								elseif p.XTerrainPushedAgainst == SLOWICE then
									set projVelocity.x = projVelocity.x - SLOW_VELOCITY * SLOW_OPPOSITIONDIFFERENCE * SIN_45
									set projVelocity.y = projVelocity.y + SLOW_VELOCITY * SLOW_OPPOSITIONDIFFERENCE * SIN_45
								elseif p.XTerrainPushedAgainst == FASTICE then
									set projVelocity.x = projVelocity.x - FAST_VELOCITY * FAST_OPPOSITIONDIFFERENCE * SIN_45
									set projVelocity.y = projVelocity.y + FAST_VELOCITY * FAST_OPPOSITIONDIFFERENCE * SIN_45
								endif
							elseif p.DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_SE then
								if (p.XTerrainPushedAgainst == SLOWICE and p.YTerrainPushedAgainst == FASTICE) or (p.XTerrainPushedAgainst == FASTICE and p.YTerrainPushedAgainst == SLOWICE) then
									set projVelocity.x = projVelocity.x - HYBRID_OPP_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y - HYBRID_OPP_VELOCITY * SIN_45
								elseif p.XTerrainPushedAgainst == SLOWICE then
									set projVelocity.x = projVelocity.x - SLOW_VELOCITY * SLOW_OPPOSITIONDIFFERENCE * SIN_45
									set projVelocity.y = projVelocity.y - SLOW_VELOCITY * SLOW_OPPOSITIONDIFFERENCE * SIN_45
								elseif p.XTerrainPushedAgainst == FASTICE then
									set projVelocity.x = projVelocity.x - FAST_VELOCITY * FAST_OPPOSITIONDIFFERENCE * SIN_45
									set projVelocity.y = projVelocity.y - FAST_VELOCITY * FAST_OPPOSITIONDIFFERENCE * SIN_45
								endif
							elseif p.DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_SW then
								if (p.XTerrainPushedAgainst == SLOWICE and p.YTerrainPushedAgainst == FASTICE) or (p.XTerrainPushedAgainst == FASTICE and p.YTerrainPushedAgainst == SLOWICE) then
									set projVelocity.x = projVelocity.x - HYBRID_OPP_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y + HYBRID_OPP_VELOCITY * SIN_45
								elseif p.XTerrainPushedAgainst == SLOWICE then
									set projVelocity.x = projVelocity.x - SLOW_VELOCITY * SLOW_OPPOSITIONDIFFERENCE * SIN_45
									set projVelocity.y = projVelocity.y + SLOW_VELOCITY * SLOW_OPPOSITIONDIFFERENCE * SIN_45
								elseif p.XTerrainPushedAgainst == FASTICE then
									set projVelocity.x = projVelocity.x - FAST_VELOCITY * FAST_OPPOSITIONDIFFERENCE * SIN_45
									set projVelocity.y = projVelocity.y + FAST_VELOCITY * FAST_OPPOSITIONDIFFERENCE * SIN_45
								endif
							elseif p.DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_NW then
								if (p.XTerrainPushedAgainst == SLOWICE and p.YTerrainPushedAgainst == FASTICE) or (p.XTerrainPushedAgainst == FASTICE and p.YTerrainPushedAgainst == SLOWICE) then
									set projVelocity.x = projVelocity.x - HYBRID_OPP_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y - HYBRID_OPP_VELOCITY * SIN_45
								elseif p.XTerrainPushedAgainst == SLOWICE then
									set projVelocity.x = projVelocity.x - SLOW_VELOCITY * SLOW_OPPOSITIONDIFFERENCE * SIN_45
									set projVelocity.y = projVelocity.y - SLOW_VELOCITY * SLOW_OPPOSITIONDIFFERENCE * SIN_45
								elseif p.XTerrainPushedAgainst == FASTICE then
									set projVelocity.x = projVelocity.x - FAST_VELOCITY * FAST_OPPOSITIONDIFFERENCE * SIN_45
									set projVelocity.y = projVelocity.y - FAST_VELOCITY * FAST_OPPOSITIONDIFFERENCE * SIN_45
								endif
							endif
						endif
					endif
				endif
				//debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Projected velocity: " + projVelocity.toString())
					
				//compute projVelocity distance
				set distance = SquareRoot(projVelocity.x * projVelocity.x + projVelocity.y * projVelocity.y)

				static if DEBUG_VELOCITY then
					call DisplayTextToForce(bj_FORCE_PLAYER[0], "Original distance: " + R2S(distance))
					call DisplayTextToForce(bj_FORCE_PLAYER[0], "Max distance: " + R2S(maxDistance))
					
					call DisplayTextToForce(bj_FORCE_PLAYER[0], "Projected velocity: " + projVelocity.toString())
				endif
				
				//enforce upper bound on velocity based on the terrain surface pushed into and if the platformer
				if distance > maxDistance then
					//debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Projected velocity: " + projVelocity.toString())
					
					set projVelocity.x = projVelocity.x * maxDistance / distance
					set projVelocity.y = projVelocity.y * maxDistance / distance
				endif
				
				//finally, update velocity
				set p.XVelocity = projVelocity.x
				set p.YVelocity = projVelocity.y
				
				static if DEBUG_VELOCITY then
					call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "X Velocity: " + R2S(p.XVelocity))
					call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Y Velocity: " + R2S(p.YVelocity))
				endif
			endif
			
			//apply VFX
			if (p.HorizontalAxisState == 1 and projVelocity.x >= 0) or (p.HorizontalAxisState == -1 and projVelocity.x <= 0) then
				//calculate change in velocity, acceleration, and get the distance of the change vector, and calculate the alternate acceleration/time based VFX
				set xAcceleration = projVelocity.x - PreviousXVelocity[p]
				set yAcceleration = projVelocity.y - PreviousYVelocity[p]
				
				set accelerationDistance = SquareRoot(xAcceleration * xAcceleration + yAcceleration * yAcceleration)
				if accelerationDistance > ALT_VFX_RATE_CAP then
					set accelerationDistance = ALT_VFX_RATE_CAP
				endif
				
				set AltVFXTimeout[p] = AltVFXTimeout[p] + accelerationDistance/ALT_VFX_RATE_CAP*(ALT_VFX_MAX_RATE - ALT_VFX_MIN_RATE) + ALT_VFX_MIN_RATE
				
				if AltVFXTimeout[p] >= ALT_VFX_TIMEOUT and p.DiagonalPathing.TerrainPathingForPoint != ComplexTerrainPathing_Left and p.DiagonalPathing.TerrainPathingForPoint != ComplexTerrainPathing_Right then
					//play effect when moving in same direction
					// call DestroyEffect(AddSpecialEffect(ALT_VFX_PATH, p.XPosition - p.PushedAgainstVector.x * PlatformerGlobals_RADIUS, p.YPosition - p.PushedAgainstVector.y * PlatformerGlobals_RADIUS))
					call CreateInstantSpecialEffect(ALT_VFX_PATH, p.XPosition - p.PushedAgainstVector.x * PlatformerGlobals_RADIUS, p.YPosition - p.PushedAgainstVector.y * PlatformerGlobals_RADIUS, Player(p.PID))
					
					set AltVFXTimeout[p] = 0
				else
					//TODO use a different, firey effect when distance >= STICKY
					//play effect when moving in same direction
					// call DestroyEffect(AddSpecialEffect(VFX_PATH, p.XPosition - p.PushedAgainstVector.x * PlatformerGlobals_RADIUS, p.YPosition - p.PushedAgainstVector.y * PlatformerGlobals_RADIUS))
					call CreateInstantSpecialEffect(VFX_PATH, p.XPosition - p.PushedAgainstVector.x * PlatformerGlobals_RADIUS, p.YPosition - p.PushedAgainstVector.y * PlatformerGlobals_RADIUS, null)
				endif
				
				static if DEBUG_ALT_VFX then
					call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Rate cap: " + R2S(ALT_VFX_RATE_CAP))
					call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Acceleration Distance: " + R2S(accelerationDistance))
					call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Factored Acceleration Distance: " + R2S(accelerationDistance/ALT_VFX_RATE_CAP*(ALT_VFX_MAX_RATE - ALT_VFX_MIN_RATE) + ALT_VFX_MIN_RATE))
				endif
			else
				//Alt VFX should run right after momentum shifts in key press direction
				set AltVFXTimeout[p] = ALT_VFX_TIMEOUT
			endif
			
			//update previous x/y velocity
			set PreviousXVelocity[p] = p.XVelocity
			set PreviousYVelocity[p] = p.YVelocity
			
			call projVelocity.destroy()
		endif
		
        static if DEBUG_ICE_LOOP then
			call DisplayTextToForce(bj_FORCE_PLAYER[0], "After ice physics ---")
		endif
    endfunction
    
    private function Loop_Init takes nothing returns nothing
        local SimpleList_ListNode head = Platformers.first
        
        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "init: " + I2S(head))
        
        if head != 0 then
            loop
            exitwhen head == 0
                call Loop(head.value)
            set head = head.next
            endloop
        endif
    endfunction
    
    public function Add takes Platformer p returns nothing
        if not Platformers.contains(p) then            
            call Platformers.add(p)
			
			//set alt VFX to run as soon as momentum shifts in key press direction
			set AltVFXTimeout[p] = ALT_VFX_TIMEOUT
			set PreviousXVelocity[p] = 0.
			set PreviousYVelocity[p] = 0.
			
			//immediately update physics, so that the platformer's initial velocity always reflects physics state
			call p.ApplyPhysics()
            
            if Platformers.count == 1 then
                //set Timer = NewTimer()
                call TimerStart(Timer, TIMESTEP, true, function Loop_Init)
            endif
        endif
    endfunction
    
    public function Remove takes Platformer p returns nothing
        if Platformers.contains(p) then
            call Platformers.remove(p)
            
            if Platformers.count == 0 then
                call PauseTimer(Timer)
                //call ReleaseTimer(Timer)
                //set Timer = null
            endif
        endif
    endfunction
    
    private function Init takes nothing returns nothing
        local integer i = 0
        
        set Platformers = SimpleList_List.create()
        set Timer = CreateTimer()
    endfunction
endlibrary
