library PlatformerIce initializer Init requires SimpleList, PlatformerGlobals
    globals
        public constant real TIMESTEP = .1
        
        //properties that are applied in the main physics loop should be relative to that timestep
        public constant real SLOW_MS = .25
        public constant real SLOW_XFALLOFF = .1
        public constant real SLOW_YFALLOFF = .1
        public constant real SLOW_OPPOSITIONDIFFERENCE = .1
        
        public real SLOW_VELOCITY = 15 * TIMESTEP
        public real SLOW_MAX_VELOCITY = PLATFORMING_MAXCHANGE / 1.25
        
        //properties applied in this timer loop should be relative to it's timestep
        
        
        public constant real FAST_MS = .1
        public constant real FAST_XFALLOFF = .01
        public constant real FAST_YFALLOFF = .01
        public constant real FAST_OPPOSITIONDIFFERENCE = 0
        
        public real FAST_VELOCITY = 30 * TIMESTEP
        public real FAST_MAX_VELOCITY = PLATFORMING_MAXCHANGE * 2.
        
        public real HYBRID_VELOCITY = (SLOW_VELOCITY * SIN_45 + FAST_VELOCITY * SIN_45) / 2
        public real HYBRID_OPP_VELOCITY = (SLOW_VELOCITY * SLOW_OPPOSITIONDIFFERENCE * SIN_45 + FAST_VELOCITY * FAST_OPPOSITIONDIFFERENCE * SIN_45) / 2
        
        private timer Timer
        public SimpleList_List Platformers
        public boolean array IsOnIce //TODO remove and replace with Platformers.contains(p)
		
		private constant boolean DEBUG_ICE_LOOP = false
    endglobals
    
    private function Loop takes Platformer p returns nothing        
        local vector2 projVelocity
        local real distance
        local real maxDistance
        
		static if DEBUG_ICE_LOOP then
			call DisplayTextToForce(bj_FORCE_PLAYER[0], "Before ice physics ---")
		endif
        //design concept:
        //movement left and right should be like sledding -- lots of velocity with a bit of control
        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "before: " + R2S(p.XVelocity))
		
		//need to check that platformer is still on a diagonal because the terrain loop (which controls this callbacks parameters) runs at a different, much slower rate than the physics loop
		//the terrain loop can claim that the platformer is still on ice (and still in this callback group) while the physics loop has since established that they've left a diagonal
        if p.OnDiagonal then
			if p.HorizontalAxisState == 1 then
				//check that current velocity is into the diagonal
				if not p.DoesPointEscapeDiagonal(p.DiagonalPathing.TerrainPathingForPoint, p.XVelocity, p.YVelocity, 0.01) then
					//project velocity vector against current diagonal to match actual direction
					set projVelocity = vector2.create(p.XVelocity, p.YVelocity)
					
					//debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Raw velocity: " + projVelocity.toString())
					call projVelocity.projectUnitVector(ComplexTerrainPathing_GetParallelForPathing(p.DiagonalPathing.TerrainPathingForPoint))
					//debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Projected velocity: " + projVelocity.toString())
					//debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Projected velocity: " + projVelocity.toString())
					
					if projVelocity.x >= 0 then //velocity right
						//TODO check i
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
									set projVelocity.x = projVelocity.x + HYBRID_VELOCITY
									set projVelocity.y = projVelocity.y - HYBRID_VELOCITY
								elseif p.XTerrainPushedAgainst == SLOWICE then
									set projVelocity.x = projVelocity.x + SLOW_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y - SLOW_VELOCITY * SIN_45
								elseif p.XTerrainPushedAgainst == FASTICE then
									set projVelocity.x = projVelocity.x + FAST_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y - FAST_VELOCITY * SIN_45
								endif
							elseif p.DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_SE then
								if (p.XTerrainPushedAgainst == SLOWICE and p.YTerrainPushedAgainst == FASTICE) or (p.XTerrainPushedAgainst == FASTICE and p.YTerrainPushedAgainst == SLOWICE) then
									set projVelocity.x = projVelocity.x + HYBRID_VELOCITY
									set projVelocity.y = projVelocity.y + HYBRID_VELOCITY
								elseif p.XTerrainPushedAgainst == SLOWICE then
									set projVelocity.x = projVelocity.x + SLOW_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y + SLOW_VELOCITY * SIN_45
								elseif p.XTerrainPushedAgainst == FASTICE then
									set projVelocity.x = projVelocity.x + FAST_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y + FAST_VELOCITY * SIN_45
								endif
							elseif p.DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_SW then
								if (p.XTerrainPushedAgainst == SLOWICE and p.YTerrainPushedAgainst == FASTICE) or (p.XTerrainPushedAgainst == FASTICE and p.YTerrainPushedAgainst == SLOWICE) then
									set projVelocity.x = projVelocity.x + HYBRID_VELOCITY
									set projVelocity.y = projVelocity.y - HYBRID_VELOCITY
								elseif p.XTerrainPushedAgainst == SLOWICE then
									set projVelocity.x = projVelocity.x + SLOW_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y - SLOW_VELOCITY * SIN_45
								elseif p.XTerrainPushedAgainst == FASTICE then
									set projVelocity.x = projVelocity.x + FAST_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y - FAST_VELOCITY * SIN_45
								endif
							elseif p.DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_NW then
								if (p.XTerrainPushedAgainst == SLOWICE and p.YTerrainPushedAgainst == FASTICE) or (p.XTerrainPushedAgainst == FASTICE and p.YTerrainPushedAgainst == SLOWICE) then
									set projVelocity.x = projVelocity.x + HYBRID_VELOCITY
									set projVelocity.y = projVelocity.y + HYBRID_VELOCITY
								elseif p.XTerrainPushedAgainst == SLOWICE then
									set projVelocity.x = projVelocity.x + SLOW_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y + SLOW_VELOCITY * SIN_45
								elseif p.XTerrainPushedAgainst == FASTICE then
									set projVelocity.x = projVelocity.x + FAST_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y + FAST_VELOCITY * SIN_45
								endif
							endif
							
							//play effect when moving in same direction
							set p.FX = AddSpecialEffect("Abilities\\Spells\\Undead\\FrostArmor\\FrostArmorDamage.mdl", p.XPosition - p.PushedAgainstVector.x * PlatformerGlobals_RADIUS, p.YPosition - p.PushedAgainstVector.y * PlatformerGlobals_RADIUS)
							call DestroyEffect(p.FX)
							set p.FX = null
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
									set projVelocity.x = projVelocity.x + HYBRID_OPP_VELOCITY
									set projVelocity.y = projVelocity.y - HYBRID_OPP_VELOCITY
								elseif p.XTerrainPushedAgainst == SLOWICE then
									set projVelocity.x = projVelocity.x + SLOW_VELOCITY * SLOW_OPPOSITIONDIFFERENCE * SIN_45
									set projVelocity.y = projVelocity.y - SLOW_VELOCITY * SLOW_OPPOSITIONDIFFERENCE * SIN_45
								elseif p.XTerrainPushedAgainst == FASTICE then
									set projVelocity.x = projVelocity.x + FAST_VELOCITY * FAST_OPPOSITIONDIFFERENCE * SIN_45
									set projVelocity.y = projVelocity.y - FAST_VELOCITY * FAST_OPPOSITIONDIFFERENCE * SIN_45
								endif
							elseif p.DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_SE then
								if (p.XTerrainPushedAgainst == SLOWICE and p.YTerrainPushedAgainst == FASTICE) or (p.XTerrainPushedAgainst == FASTICE and p.YTerrainPushedAgainst == SLOWICE) then
									set projVelocity.x = projVelocity.x + HYBRID_OPP_VELOCITY
									set projVelocity.y = projVelocity.y + HYBRID_OPP_VELOCITY
								elseif p.XTerrainPushedAgainst == SLOWICE then
									set projVelocity.x = projVelocity.x + SLOW_VELOCITY * SLOW_OPPOSITIONDIFFERENCE * SIN_45
									set projVelocity.y = projVelocity.y + SLOW_VELOCITY * SLOW_OPPOSITIONDIFFERENCE * SIN_45
								elseif p.XTerrainPushedAgainst == FASTICE then
									set projVelocity.x = projVelocity.x + FAST_VELOCITY * FAST_OPPOSITIONDIFFERENCE * SIN_45
									set projVelocity.y = projVelocity.y + FAST_VELOCITY * FAST_OPPOSITIONDIFFERENCE * SIN_45
								endif
							elseif p.DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_SW then
								if (p.XTerrainPushedAgainst == SLOWICE and p.YTerrainPushedAgainst == FASTICE) or (p.XTerrainPushedAgainst == FASTICE and p.YTerrainPushedAgainst == SLOWICE) then
									set projVelocity.x = projVelocity.x + HYBRID_OPP_VELOCITY
									set projVelocity.y = projVelocity.y - HYBRID_OPP_VELOCITY
								elseif p.XTerrainPushedAgainst == SLOWICE then
									set projVelocity.x = projVelocity.x + SLOW_VELOCITY * SLOW_OPPOSITIONDIFFERENCE * SIN_45
									set projVelocity.y = projVelocity.y - SLOW_VELOCITY * SLOW_OPPOSITIONDIFFERENCE * SIN_45
								elseif p.XTerrainPushedAgainst == FASTICE then
									set projVelocity.x = projVelocity.x + FAST_VELOCITY * FAST_OPPOSITIONDIFFERENCE * SIN_45
									set projVelocity.y = projVelocity.y - FAST_VELOCITY * FAST_OPPOSITIONDIFFERENCE * SIN_45
								endif
							elseif p.DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_NW then
								if (p.XTerrainPushedAgainst == SLOWICE and p.YTerrainPushedAgainst == FASTICE) or (p.XTerrainPushedAgainst == FASTICE and p.YTerrainPushedAgainst == SLOWICE) then
									set projVelocity.x = projVelocity.x + HYBRID_OPP_VELOCITY
									set projVelocity.y = projVelocity.y + HYBRID_OPP_VELOCITY
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
					
					//debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Projected velocity: " + projVelocity.toString())
					
					//compute projVelocity distance
					set distance = SquareRoot(projVelocity.x * projVelocity.x + projVelocity.y * projVelocity.y)

					//check if projVelocity distance is greater than or equal to max speed for ice type
					if (p.XTerrainPushedAgainst == SLOWICE and p.YTerrainPushedAgainst == FASTICE) or (p.XTerrainPushedAgainst == FASTICE and p.YTerrainPushedAgainst == SLOWICE) then
						set maxDistance = (SLOW_MAX_VELOCITY + FAST_MAX_VELOCITY) / 2
					elseif p.XTerrainPushedAgainst == SLOWICE or p.YTerrainPushedAgainst == SLOWICE then
						set maxDistance = SLOW_MAX_VELOCITY
					elseif p.XTerrainPushedAgainst == FASTICE or p.YTerrainPushedAgainst == FASTICE then
						set maxDistance = FAST_MAX_VELOCITY
					endif
					
					//debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Max distance: " + R2S(maxDistance))
					
					//update velocity
					if distance > maxDistance then
						//debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Projected velocity: " + projVelocity.toString())
						
						//only update velocities if they were below the max velocity before
						if SquareRoot(p.XVelocity * p.XVelocity + p.YVelocity * p.YVelocity) < maxDistance then
							set p.XVelocity = projVelocity.x * maxDistance / distance
							set p.YVelocity = projVelocity.y * maxDistance / distance
						endif
						
						//TODO show superspeed animation
					else
						set p.XVelocity = projVelocity.x
						set p.YVelocity = projVelocity.y
					endif
					
					//debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Updated velocity: " + R2S(p.XVelocity))
					
					call projVelocity.destroy()
				endif
			elseif p.HorizontalAxisState == -1 then
				//check that current velocity is into the diagonal
				if not p.DoesPointEscapeDiagonal(p.DiagonalPathing.TerrainPathingForPoint, p.XVelocity, p.YVelocity, 0.01) then
					set projVelocity = vector2.create(p.XVelocity, p.YVelocity)
					//debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Raw velocity: " + projVelocity.toString())
					call projVelocity.projectUnitVector(ComplexTerrainPathing_GetParallelForPathing(p.DiagonalPathing.TerrainPathingForPoint))
					//debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Projected velocity: " + projVelocity.toString())
					
					//debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Projected velocity: " + projVelocity.toString())
					
					//debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Axis left, X Velocity: " + R2S(projVelocity.x))
					
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
									set projVelocity.x = projVelocity.x - HYBRID_VELOCITY
									set projVelocity.y = projVelocity.y + HYBRID_VELOCITY
								elseif p.XTerrainPushedAgainst == SLOWICE then
									set projVelocity.x = projVelocity.x - SLOW_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y + SLOW_VELOCITY * SIN_45
								elseif p.XTerrainPushedAgainst == FASTICE then
									set projVelocity.x = projVelocity.x - FAST_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y + FAST_VELOCITY * SIN_45
								endif
							elseif p.DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_SE then
								if (p.XTerrainPushedAgainst == SLOWICE and p.YTerrainPushedAgainst == FASTICE) or (p.XTerrainPushedAgainst == FASTICE and p.YTerrainPushedAgainst == SLOWICE) then
									set projVelocity.x = projVelocity.x - HYBRID_VELOCITY
									set projVelocity.y = projVelocity.y - HYBRID_VELOCITY
								elseif p.XTerrainPushedAgainst == SLOWICE then
									set projVelocity.x = projVelocity.x - SLOW_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y - SLOW_VELOCITY * SIN_45
								elseif p.XTerrainPushedAgainst == FASTICE then
									set projVelocity.x = projVelocity.x - FAST_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y - FAST_VELOCITY * SIN_45
								endif
							elseif p.DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_SW then
								if (p.XTerrainPushedAgainst == SLOWICE and p.YTerrainPushedAgainst == FASTICE) or (p.XTerrainPushedAgainst == FASTICE and p.YTerrainPushedAgainst == SLOWICE) then
									set projVelocity.x = projVelocity.x - HYBRID_VELOCITY
									set projVelocity.y = projVelocity.y + HYBRID_VELOCITY
								elseif p.XTerrainPushedAgainst == SLOWICE then
									set projVelocity.x = projVelocity.x - SLOW_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y + SLOW_VELOCITY * SIN_45
								elseif p.XTerrainPushedAgainst == FASTICE then
									set projVelocity.x = projVelocity.x - FAST_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y + FAST_VELOCITY * SIN_45
								endif
							elseif p.DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_NW then
								if (p.XTerrainPushedAgainst == SLOWICE and p.YTerrainPushedAgainst == FASTICE) or (p.XTerrainPushedAgainst == FASTICE and p.YTerrainPushedAgainst == SLOWICE) then
									set projVelocity.x = projVelocity.x - HYBRID_VELOCITY
									set projVelocity.y = projVelocity.y - HYBRID_VELOCITY
								elseif p.XTerrainPushedAgainst == SLOWICE then
									set projVelocity.x = projVelocity.x - SLOW_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y - SLOW_VELOCITY * SIN_45
								elseif p.XTerrainPushedAgainst == FASTICE then
									set projVelocity.x = projVelocity.x - FAST_VELOCITY * SIN_45
									set projVelocity.y = projVelocity.y - FAST_VELOCITY * SIN_45
								endif
							endif
							
							//play effect when moving in same direction
							set p.FX = AddSpecialEffect("Abilities\\Spells\\Undead\\FrostArmor\\FrostArmorDamage.mdl", p.XPosition - p.PushedAgainstVector.x * PlatformerGlobals_RADIUS, p.YPosition - p.PushedAgainstVector.y * PlatformerGlobals_RADIUS)
							call DestroyEffect(p.FX)
							set p.FX = null
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
									set projVelocity.x = projVelocity.x - HYBRID_OPP_VELOCITY
									set projVelocity.y = projVelocity.y + HYBRID_OPP_VELOCITY
								elseif p.XTerrainPushedAgainst == SLOWICE then
									set projVelocity.x = projVelocity.x - SLOW_VELOCITY * SLOW_OPPOSITIONDIFFERENCE * SIN_45
									set projVelocity.y = projVelocity.y + SLOW_VELOCITY * SLOW_OPPOSITIONDIFFERENCE * SIN_45
								elseif p.XTerrainPushedAgainst == FASTICE then
									set projVelocity.x = projVelocity.x - FAST_VELOCITY * FAST_OPPOSITIONDIFFERENCE * SIN_45
									set projVelocity.y = projVelocity.y + FAST_VELOCITY * FAST_OPPOSITIONDIFFERENCE * SIN_45
								endif
							elseif p.DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_SE then
								if (p.XTerrainPushedAgainst == SLOWICE and p.YTerrainPushedAgainst == FASTICE) or (p.XTerrainPushedAgainst == FASTICE and p.YTerrainPushedAgainst == SLOWICE) then
									set projVelocity.x = projVelocity.x - HYBRID_OPP_VELOCITY
									set projVelocity.y = projVelocity.y - HYBRID_OPP_VELOCITY
								elseif p.XTerrainPushedAgainst == SLOWICE then
									set projVelocity.x = projVelocity.x - SLOW_VELOCITY * SLOW_OPPOSITIONDIFFERENCE * SIN_45
									set projVelocity.y = projVelocity.y - SLOW_VELOCITY * SLOW_OPPOSITIONDIFFERENCE * SIN_45
								elseif p.XTerrainPushedAgainst == FASTICE then
									set projVelocity.x = projVelocity.x - FAST_VELOCITY * FAST_OPPOSITIONDIFFERENCE * SIN_45
									set projVelocity.y = projVelocity.y - FAST_VELOCITY * FAST_OPPOSITIONDIFFERENCE * SIN_45
								endif
							elseif p.DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_SW then
								if (p.XTerrainPushedAgainst == SLOWICE and p.YTerrainPushedAgainst == FASTICE) or (p.XTerrainPushedAgainst == FASTICE and p.YTerrainPushedAgainst == SLOWICE) then
									set projVelocity.x = projVelocity.x - HYBRID_OPP_VELOCITY
									set projVelocity.y = projVelocity.y + HYBRID_OPP_VELOCITY
								elseif p.XTerrainPushedAgainst == SLOWICE then
									set projVelocity.x = projVelocity.x - SLOW_VELOCITY * SLOW_OPPOSITIONDIFFERENCE * SIN_45
									set projVelocity.y = projVelocity.y + SLOW_VELOCITY * SLOW_OPPOSITIONDIFFERENCE * SIN_45
								elseif p.XTerrainPushedAgainst == FASTICE then
									set projVelocity.x = projVelocity.x - FAST_VELOCITY * FAST_OPPOSITIONDIFFERENCE * SIN_45
									set projVelocity.y = projVelocity.y + FAST_VELOCITY * FAST_OPPOSITIONDIFFERENCE * SIN_45
								endif
							elseif p.DiagonalPathing.TerrainPathingForPoint == ComplexTerrainPathing_NW then
								if (p.XTerrainPushedAgainst == SLOWICE and p.YTerrainPushedAgainst == FASTICE) or (p.XTerrainPushedAgainst == FASTICE and p.YTerrainPushedAgainst == SLOWICE) then
									set projVelocity.x = projVelocity.x - HYBRID_OPP_VELOCITY
									set projVelocity.y = projVelocity.y - HYBRID_OPP_VELOCITY
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
					
					//debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Projected velocity: " + projVelocity.toString())
					
					//compute projVelocity distance
					set distance = SquareRoot(projVelocity.x * projVelocity.x + projVelocity.y * projVelocity.y)

					//check if projVelocity distance is greater than or equal to max speed for ice type
					if (p.XTerrainPushedAgainst == SLOWICE and p.YTerrainPushedAgainst == FASTICE) or (p.XTerrainPushedAgainst == FASTICE and p.YTerrainPushedAgainst == SLOWICE) then
						set maxDistance = (SLOW_MAX_VELOCITY + FAST_MAX_VELOCITY) / 2
					elseif p.XTerrainPushedAgainst == SLOWICE or p.YTerrainPushedAgainst == SLOWICE then
						set maxDistance = SLOW_MAX_VELOCITY
					elseif p.XTerrainPushedAgainst == FASTICE or p.YTerrainPushedAgainst == FASTICE then
						set maxDistance = FAST_MAX_VELOCITY
					endif
					
					//debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Max distance: " + R2S(maxDistance))
					
					//update velocity
					if distance > maxDistance then
						//debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Projected velocity: " + projVelocity.toString())
						
						//only update velocities if they were below the max velocity before
						if SquareRoot(p.XVelocity * p.XVelocity + p.YVelocity * p.YVelocity) < maxDistance then
							set p.XVelocity = projVelocity.x * maxDistance / distance
							set p.YVelocity = projVelocity.y * maxDistance / distance
						endif
						
						//TODO show superspeed animation
					else
						set p.XVelocity = projVelocity.x
						set p.YVelocity = projVelocity.y
					endif
					
					//debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Updated velocity: " + R2S(p.XVelocity))
					
					call projVelocity.destroy()
				endif
			endif
		endif
		
        static if DEBUG_ICE_LOOP then
			call DisplayTextToForce(bj_FORCE_PLAYER[0], "After ice physics ---")
		endif
        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "after: " + R2S(p.XVelocity))
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
        if not IsOnIce[p.PID] then            
            set IsOnIce[p.PID] = true
            
            call Platformers.add(p)
            
            if Platformers.count == 1 then
                //set Timer = NewTimer()
                call TimerStart(Timer, TIMESTEP, true, function Loop_Init)
            endif
        endif
    endfunction
    
    public function Remove takes Platformer p returns nothing
        if IsOnIce[p.PID] then
            set IsOnIce[p.PID] = false
            
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
        
        loop
        exitwhen i >= 8
            set IsOnIce[i] = false
        set i = i + 1
        endloop
    endfunction
endlibrary
