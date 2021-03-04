library InGameCommands initializer init requires MazerGlobals, Platformer, RelayGenerator, Deferred, EDWQuests
	// struct InGameCommand extends array
	// 	implement PermanentAlloc
	// endstruct
	
	function ExportPlatformingVariables takes Platformer p returns nothing
		//display all variables on screen
		//call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[tvx] Terminal Velocity X: " + R2S(p.TerminalVelocityX / PlatformerGlobals_GAMELOOP_TIMESTEP))
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[tvy] Terminal Velocity Y: " + R2S(p.TerminalVelocityY / PlatformerGlobals_GAMELOOP_TIMESTEP))
		//call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[tvf] Terminal Velocity Falloff: " + R2S(p.TerminalFalloff))
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[xf] Horizontal Falloff: " + R2S(p.XFalloff / PlatformerGlobals_GAMELOOP_TIMESTEP))
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[yf] Vertical Falloff: " + R2S(p.YFalloff / PlatformerGlobals_GAMELOOP_TIMESTEP))
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[ms] Move Speed: " + R2S(p.MoveSpeed / PlatformerGlobals_GAMELOOP_TIMESTEP))
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[msoff] Move Speed's Offset Effect against cur Velocity: " + R2S(p.MoveSpeedVelOffset))
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[ga] Gravitational Acceleration: " + R2S(p.GravitationalAccel / PlatformerGlobals_GAMELOOP_TIMESTEP))
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[vj] Vertical Jump: " + R2S(p.vJumpSpeed / PlatformerGlobals_GAMELOOP_TIMESTEP))
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[v2h] Vertical 2 Horizontal Jump: " + R2S(p.v2hJumpRatio))
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[hj] Horizontal Jump: " + R2S(p.hJumpSpeed / PlatformerGlobals_GAMELOOP_TIMESTEP))
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[om] Ocean Motion: " + R2S(PlatformerOcean_OCEAN_MOTION / PlatformerOcean_TIMESTEP))
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[ovj] Ocean Jump Height: " + R2S(JUMPHEIGHTINOCEAN / PlatformerGlobals_GAMELOOP_TIMESTEP))
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[iss] Ice Slow Speed: " + R2S(PlatformerIce_SLOW_VELOCITY / PlatformerIce_TIMESTEP))
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[ifs] Ice Fast Speed: " + R2S(PlatformerIce_FAST_VELOCITY / PlatformerIce_TIMESTEP))
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "--------------------")
	endfunction

	function PrintPlatformingVariables takes Platformer p returns nothing
		//display all variables on screen
		//call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[tvx] Terminal Velocity X: " + R2S(p.TerminalVelocityX))
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[tvy] Terminal Velocity Y: " + R2S(p.TerminalVelocityY))
		//call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[tvf] Terminal Velocity Falloff: " + R2S(p.TerminalFalloff))
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[xf] Horizontal Falloff: " + R2S(p.XFalloff))
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[yf] Vertical Falloff: " + R2S(p.YFalloff))
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[ms] Move Speed: " + R2S(p.MoveSpeed))
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[msoff] Move Speed's Offset Effect against cur Velocity: " + R2S(p.MoveSpeedVelOffset))
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[ga] Gravitational Acceleration: " + R2S(p.GravitationalAccel))
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[vj] Vertical Jump: " + R2S(p.vJumpSpeed))
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[v2h] Vertical 2 Horizontal Jump: " + R2S(p.v2hJumpRatio))
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[hj] Horizontal Jump: " + R2S(p.hJumpSpeed))
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[om] Ocean Motion: " + R2S(PlatformerOcean_OCEAN_MOTION))
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[ovj] Ocean Jump Height: " + R2S(JUMPHEIGHTINOCEAN))
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[iss] Ice Slow Speed: " + R2S(PlatformerIce_SLOW_VELOCITY))
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[ifs] Ice Fast Speed: " + R2S(PlatformerIce_FAST_VELOCITY))
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "--------------------")
	endfunction

	function PrintPlatformingCurrentValues takes Platformer p returns nothing
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "Velocity X: " + R2S(p.XVelocity))
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "Velocity Y: " + R2S(p.YVelocity))
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "Movespeed: " + R2S(p.MoveSpeed))
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "Grav Accel: " + R2S(p.GravitationalAccel))
		
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "Diagonal Path: " + I2S(p.DiagonalPathing.TerrainPathingForPoint))
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "Current Terrain: " + I2S(p.TerrainDX))
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "Current Terrain X: " + I2S(p.XTerrainPushedAgainst) + ", " + I2S(p.XAppliedTerrainPushedAgainst))
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "Current Terrain Y: " + I2S(p.YTerrainPushedAgainst) + ", " + I2S(p.YAppliedTerrainPushedAgainst))
	endfunction

	function PrintPlatformingProfileVariables takes Platformer p returns nothing    
		//display all variables on screen
		//call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[tvx] Terminal Velocity X: " + R2S(p.BaseProfile.TerminalVelocityX))
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[tvy] Terminal Velocity Y: " + R2S(p.BaseProfile.TerminalVelocityY))
		//call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[tvf] Terminal Velocity Falloff: " + R2S(p.TerminalFalloff))
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[xf] Horizontal Falloff: " + R2S(p.BaseProfile.XFalloff))
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[yf] Vertical Falloff: " + R2S(p.BaseProfile.YFalloff))
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[ms] Move Speed: " + R2S(p.BaseProfile.MoveSpeed))
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[msoff] Move Speed's Offset Effect against cur Velocity: " + R2S(p.BaseProfile.MoveSpeedVelOffset))
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[ga] Gravitational Acceleration: " + R2S(p.BaseProfile.GravitationalAccel))
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[vj] Vertical Jump: " + R2S(p.BaseProfile.vJumpSpeed))
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[v2h] Vertical 2 Horizontal Jump: " + R2S(p.BaseProfile.v2hJumpRatio))
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[hj] Horizontal Jump: " + R2S(p.BaseProfile.hJumpSpeed))
		call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "--------------------")
	endfunction

	function PrintMemoryAnalysis takes integer pID returns nothing
		call DisplayTextToForce(bj_FORCE_PLAYER[pID], "Memory Analysis:")
		static if MemoryAnalysis_ENABLED then
			call DisplayTextToForce(bj_FORCE_PLAYER[pID], "Vector2: " + I2S(vector2.calculateMemoryUsage()))
			call DisplayTextToForce(bj_FORCE_PLAYER[pID], "SimpleList: " + I2S(SimpleList_List.calculateMemoryUsage()))
			call DisplayTextToForce(bj_FORCE_PLAYER[pID], "SimpleListNode: " + I2S(SimpleList_ListNode.calculateMemoryUsage()))
			call DisplayTextToForce(bj_FORCE_PLAYER[pID], "PlatformerPropertyEquation: " + I2S(PlatformerPropertyEquation.calculateMemoryUsage()))
			call DisplayTextToForce(bj_FORCE_PLAYER[pID], "PlatformerPropertyAdjustment: " + I2S(PlatformerPropertyAdjustment.calculateMemoryUsage()))
			call DisplayTextToForce(bj_FORCE_PLAYER[pID], "ComplexTerrainPathingResult: " + I2S(ComplexTerrainPathingResult.calculateMemoryUsage()))
			call DisplayTextToForce(bj_FORCE_PLAYER[pID], "RelayUnit: " + I2S(RelayUnit.calculateMemoryUsage()))
			call DisplayTextToForce(bj_FORCE_PLAYER[pID], "Deferred: " + I2S(Deferred.calculateMemoryUsage()))
			call DisplayTextToForce(bj_FORCE_PLAYER[pID], "Deferred Awaiter: " + I2S(DeferredAwaiter.calculateMemoryUsage()))
			call DisplayTextToForce(bj_FORCE_PLAYER[pID], "IndexedUnit: " + I2S(IndexedUnit.calculateMemoryUsage()))
			call DisplayTextToForce(bj_FORCE_PLAYER[pID], "--------------------")
		endif
	endfunction

	function RelayCallback takes nothing returns nothing
		local unit selectedUnit = GetEnumUnit()
		local integer pID = GetPlayerId(GetTriggerPlayer())
		local RelayUnit turnUnitInfo = RelayGenerator.UnitIDToRelayUnitID[GetUnitUserData(selectedUnit)]
		
		call DisplayTextToForce(bj_FORCE_PLAYER[pID], "Lane: " + I2S(turnUnitInfo.LaneNumber))
		call DisplayTextToForce(bj_FORCE_PLAYER[pID], "Turn center: " + RelayTurn(turnUnitInfo.CurrentTurn.value).Center.toString())
		call DisplayTextToForce(bj_FORCE_PLAYER[pID], "-----")
	endfunction

	function DistanceCallback takes nothing returns nothing
		local unit selectedUnit = GetEnumUnit()
		local integer pID = GetPlayerId(GetTriggerPlayer())
		local unit playerUnit = User(pID).ActiveUnit
		local real x = GetUnitX(selectedUnit) - GetUnitX(playerUnit)
		local real y = GetUnitY(selectedUnit) - GetUnitY(playerUnit)
		
		call DisplayTextToForce(bj_FORCE_PLAYER[pID], "Distance: " + R2S(SquareRoot(x*x + y*y)))
		
		set selectedUnit = null
		set playerUnit = null
	endfunction
	
	// function Vector2AssertEquals takes vector2 v1, vector2 v2 returns nothing
		// if v1.x == v2.x then
			// call BJDebugMsg("vectors equal for x")
		// elseif v1.x != v2.x then
			// call BJDebugMsg("vectors not equal for v1.x: " + R2S(v1.x) + ", v2.x: " + R2S(v2.x) + ", diff: " + R2S(v1.x - v2.x))
		// endif
		
		// if v1.y == v2.y then
			// call BJDebugMsg("vectors equal for y")
		// elseif v1.y != v2.y then
			// call BJDebugMsg("vectors not equal for v1.y: " + R2S(v1.y) + ", v2.y: " + R2S(v2.y) + ", diff: " + R2S(v1.y - v2.y))
		// endif
	// endfunction
	// function Vector2UnitTest takes nothing returns nothing
		// local vector2 vector = vector2.create(-1.1, -123.456)
		// local string strVector = vector.toString()
		// local vector2 parsedVector = vector2.fromString(strVector)
		
		// call Vector2AssertEquals(vector, parsedVector)
		// call vector.deallocate()
		
		// set vector = vector2.create(-123.456, -1.1)
		// set strVector = vector.toString()
		// set parsedVector = vector2.fromString(strVector)
		
		// call Vector2AssertEquals(vector, parsedVector)
		// call vector.deallocate()
		
		// set vector = vector2.create(-1, -1)
		// set strVector = vector.toString()
		// set parsedVector = vector2.fromString(strVector)
		
		// call Vector2AssertEquals(vector, parsedVector)
		// call vector.deallocate()
	// endfunction

	function DebugRelay takes integer pID returns nothing
		local Levels_Level platformerLevel = User(pID).Team.OnLevel
		local SimpleList_ListNode curNode = platformerLevel.Startables.first
		local integer curIndex
		local RelayGenerator relay = 0
		
		loop
		exitwhen curNode == 0 or relay != 0
			if IStartable(curNode.value).getType() == RelayGenerator.typeid then
				set relay = curNode.value
			endif
		set curNode = curNode.next
		endloop
		
		call DisplayTextToForce(bj_FORCE_PLAYER[pID], "Relay ID: " + I2S(relay))
		
		if relay != 0 then
			static if DEBUG_MODE then
				call relay.CachedTurnDestinations.print(pID)
			
				call DisplayTextToForce(bj_FORCE_PLAYER[pID], "Printing destinations")
				set curNode = relay.CachedTurnDestinations.first
				set curIndex = 0
				loop
				exitwhen curNode == 0
					call DisplayTextToForce(bj_FORCE_PLAYER[pID], "Destination index: " + I2S(curIndex) + ", destination: " + vector2(curNode.value).toString())
				set curNode = curNode.next
				set curIndex = curIndex + 1
				endloop
			endif
		endif
	endfunction

	function OverclockRelays takes integer pID, real overclock returns nothing
		local Levels_Level level = User(pID).Team.OnLevel
		local SimpleList_ListNode curNode = level.Startables.first
		local integer curIndex
		local RelayGenerator relay = 0
		
		loop
		exitwhen curNode == 0
			if IStartable(curNode.value).getType() == RelayGenerator.typeid then
				set relay = curNode.value
				call DisplayTextToForce(bj_FORCE_PLAYER[pID], "Overclocking relay: " + I2S(relay))
				
				call relay.SetOverclockFactor(overclock)
			endif
		set curNode = curNode.next
		endloop	
	endfunction
	
	// function OnAllCameraSync takes integer result, Deferred all returns integer
		// // call DisplayTextToForce(bj_FORCE_PLAYER[0], "On all camera sync")
		
		// local SimpleList_ListNode curTeamNode = Teams_MazingTeam.AllTeams.first
		// local SimpleList_ListNode curUserNode
		
		// local boolean anyNonAFK
		
		// loop
		// exitwhen curTeamNode == 0
			// set curUserNode = Teams_MazingTeam(curTeamNode.value).Users.first
			// set anyNonAFK = false
			
			// loop
			// exitwhen curUserNode == 0 or anyNonAFK
				// // call DisplayTextToPlayer(Player(0), 0, 0, "User: " + I2S(curUserNode.value))
				
				// if not User(curUserNode.value).IsAFK and not User(curUserNode.value).IsAFKSync() and User(curUserNode.value).IsAlive then
					// set anyNonAFK = true
				// endif
			// set curUserNode = curUserNode.next
			// endloop
			
			// if not anyNonAFK then
				// set curUserNode = Teams_MazingTeam(curTeamNode.value).Users.first
				
				// loop
				// exitwhen curUserNode == 0
					// if not User(curUserNode.value).IsAFK and User(curUserNode.value).IsAFKSync() then
						// call User(curUserNode.value).ToggleAFK()
					// endif
				// set curUserNode = curUserNode.next
				// endloop
			// endif
		// set curTeamNode = curTeamNode.next
		// endloop
		
		// call all.destroy()
		
		// return 0
	// endfunction

	function ParseCommand takes nothing returns nothing
		local string msg = GetEventPlayerChatString()
		local integer pID = GetPlayerId(GetTriggerPlayer())
		local integer i = 0
		local integer strLength = StringLength(msg)
		local string cmd
		local string strVal
		local real val
		local integer intVal
		local User u = User(pID)
		local Platformer p = u.Platformer
		local Teams_MazingTeam team = User(pID).Team
		local group unitgroup
		local unit gunit
		// local unit selectedUnit = FirstOfGroup(GetUnitsSelectedAll(Player(pID)))
		
		local Levels_Level level
		local Checkpoint checkpoint
		
		local Deferred async
		
		//debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "msg: " + msg)
		
		//set i equal to the position of first space in message
		loop
		exitwhen i >= strLength or SubString(msg, i, i + 1) == " "
			set i = i + 1
		endloop
		
		set cmd = SubString(msg, 1, i)
		
		//debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "msg: " + msg + " cmd: " + cmd)
		
		//check if string contains a value
		if strLength >= i + 1 then
			set strVal = SubString(msg, i + 1, strLength)
			set val = S2R(strVal)
			set intVal = R2I(val)
		else
			set strVal = null
			set val = 0.
			set intVal = 0
		endif
				
		// if cmd == "afk" then
			// set async = User.SyncLocalCameraIdleTime()
			// call async.Then(OnAllCameraSync, 0, async)
		// endif
		
		if CONFIGURATION_PROFILE != RELEASE then
			//debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "msg: " + msg + " cmd: " + cmd + " val: " + R2S(val))
			if cmd == "tvy" then
				set p.TerminalVelocityY = val
			//elseif cmd == "tvf" then
				//set p.TerminalFalloff = val
			elseif cmd == "xf" then
				set p.XFalloff = val
			elseif cmd == "yf" then
				set p.YFalloff = val
			elseif cmd == "ms" then
				set unitgroup = GetUnitsSelectedAll(Player(pID))
				set gunit = FirstOfGroup(unitgroup)
				
				if val != 0 then
					set p.MoveSpeed = val
				elseif gunit != null then
					if GetUnitUserData(gunit) == 0 and IndexedUnit[gunit].MoveSpeed != -1 then
						call DisplayTextToPlayer(Player(pID), 0, 0, "Not indexed or overriden: " + R2S(GetUnitMoveSpeed(gunit)))
					else
						call DisplayTextToPlayer(Player(pID), 0, 0, "Indexed: " + R2S(IndexedUnit[gunit].GetMoveSpeed()))
					endif
				endif
				
				call DestroyGroup(unitgroup)
				set unitgroup = null
				set gunit = null
			elseif cmd == "msoff" then
				set p.MoveSpeedVelOffset = val
			elseif cmd == "ga" then
				set p.GravitationalAccel = val
			elseif cmd == "vj" then
				set p.vJumpSpeed = val
			elseif cmd == "hj" then
				set p.hJumpSpeed = val
			elseif cmd == "v2h" then
				set p.v2hJumpRatio = val
			elseif cmd == "om" then
				set PlatformerOcean_OCEAN_MOTION = val
			elseif cmd == "ovj" then
				set JUMPHEIGHTINOCEAN = val
			// elseif cmd == "iss" then
				// set PlatformerIce_SLOW_VELOCITY = val
			// elseif cmd == "ifs" then
				// set PlatformerIce_FAST_VELOCITY = val
			elseif cmd == "size" or cmd == "s" then
				call DisplayTextToForce(bj_FORCE_PLAYER[pID], "Size: " + R2S(GetUnitCollision(FirstOfGroup(GetUnitsSelectedAll(Player(pID))))))
			elseif cmd == "unitmovespeed" or cmd == "ums" then
				call SetUnitMoveSpeed(FirstOfGroup(GetUnitsSelectedAll(Player(pID))), val)
			elseif cmd == "distance" or cmd == "dist" or cmd == "d" then
				set unitgroup = CreateGroup()
				call GroupEnumUnitsSelected(unitgroup, Player(pID), null)
				call ForGroup(unitgroup, function DistanceCallback)
				call DestroyGroup(unitgroup)
				set unitgroup = null
			elseif cmd == "level" or cmd == "lvl" then
				if Levels_Level(intVal) != 0 then
					call Levels_Level(team.OnLevel).SwitchLevels(team, Levels_Level(intVal), u, false)
				endif
			elseif cmd == "checkpoint" or cmd == "cp" then
				call Levels_Level(team.OnLevel).SetCheckpointForTeam(team, intVal)
			elseif cmd == "continue" or cmd == "continues" then
				if intVal >= 0 then
					call team.SetContinueCount(intVal)
				endif
			elseif cmd == "help" or cmd == "h" then
				call PrintPlatformingVariables(p)
			elseif cmd == "status" or cmd == "s" then
				call PrintPlatformingCurrentValues(p)
			elseif msg == "-prof" or  cmd == "prof" then
				call PrintPlatformingProfileVariables(p)
			elseif msg == "-export" or  cmd == "export" then
				call ExportPlatformingVariables(p)
			elseif msg == "-mem" or cmd == "mem" then
				call PrintMemoryAnalysis(p.PID)
			elseif msg == "-debugrelay" then
				call DebugRelay(pID)
			elseif msg == "-overclock" or cmd == "overclock" or cmd == "clock" then
				call DisplayTextToForce(bj_FORCE_PLAYER[pID], "Overclocking relay for player: " + I2S(pID) + ", val: " + R2S(val))
				call OverclockRelays(pID, val)
			elseif cmd == "rotate" or cmd == "rot" then
				set unitgroup = CreateGroup()
				call GroupEnumUnitsSelected(unitgroup, Player(pID), null)
				call SetUnitFacing(FirstOfGroup(unitgroup), val)
			elseif cmd == "debugpocean" then
				call team.MoveRevive(gg_rct_Region_380)
				set team.DefaultGameMode = Teams_GAMEMODE_PLATFORMING
				call team.RespawnTeamAtRect(gg_rct_Region_380, true)
				
				debug call DisplayTextToForce(bj_FORCE_PLAYER[pID], "Finished setting up plat test")
			elseif cmd == "debugpice" then
				call team.MoveRevive(gg_rct_SboxIceR)
				set team.DefaultGameMode = Teams_GAMEMODE_PLATFORMING
				call team.RespawnTeamAtRect(gg_rct_SboxIceR, true)
				
				debug call DisplayTextToForce(bj_FORCE_PLAYER[pID], "Finished setting up plat test")
			elseif cmd == "pause" or cmd == "p" then
				if u.GameMode == Teams_GAMEMODE_STANDARD or u.GameMode == Teams_GAMEMODE_PLATFORMING then
					call u.Pause(true)
				elseif u.GameMode == Teams_GAMEMODE_STANDARD_PAUSED or u.GameMode == Teams_GAMEMODE_PLATFORMING_PAUSED then
					call u.Pause(false)
				endif
			elseif cmd == "quests" then
				call LocalizeAllQuestsForPlayer(u)
			elseif cmd == "gamemode" or cmd == "gm" then
				call u.SwitchGameModesDefaultLocation(intVal)
			elseif cmd == "teamgamemode" or cmd == "tgm" then
				call team.SwitchGameModeContinuous(intVal)
			elseif cmd == "localize" then
				if GetLocalPlayer() == Player(u) then
					call DisplayTextToPlayer(Player(u), 0, 0, "Localized: " + LocalizeContent(intVal, u.LanguageCode))
				endif
			elseif cmd == "majoritylanguage" then
				call DisplayTextToPlayer(Player(u), 0, 0, "Majority Language: " + Teams_MazingTeam.GetMajorityLanguage())
			elseif cmd == "a" or cmd == "animate" then
				set unitgroup = CreateGroup()
				call GroupEnumUnitsSelected(unitgroup, Player(pID), null)
				set gunit = FirstOfGroup(unitgroup)
				
				loop
				exitwhen gunit == null
					call SetUnitAnimationByIndex(gunit, R2I(val))
				call GroupRemoveUnit(unitgroup, gunit)
				set gunit = FirstOfGroup(unitgroup)
				endloop
				
				call DestroyGroup(unitgroup)
				set unitgroup = null
				set gunit = null
			elseif cmd == "share" then
				call SetPlayerAllianceBJ(Player(intVal), ALLIANCE_SHARED_CONTROL, true, Player(pID))
			// elseif cmd == "afk" then
				// set async = User.SyncLocalCameraIdleTime()
				// call async.Then(OnAllCameraSync, 0, async)
			// endif
			elseif cmd == "debugpath" then
				// call LevelPath(intVal).PrintPathByBreadth()
				call DisplayTextToPlayer(Player(pID), 0, 0, "************************")
				if intVal != 0 then
					set level = Levels_Level(intVal)
					set checkpoint = level.GetCheckpoint(0)
				else
					set level = team.OnLevel
					set checkpoint = level.GetCheckpoint(team.OnCheckpoint)
				endif
				
				if checkpoint.Path != 0 then
					call DisplayTextToPlayer(Player(pID), 0, 0, "Printing path for level: " + level.GetLocalizedLevelName(pID))
					call DisplayTextToPlayer(Player(pID), 0, 0, "Checkpoint ID: " + I2S(checkpoint))
					call checkpoint.Path.PrintPathByBreadth()
				else
					call DisplayTextToPlayer(Player(pID), 0, 0, "Null path for level: " + level.GetLocalizedLevelName(pID))
					call DisplayTextToPlayer(Player(pID), 0, 0, "Checkpoint ID: " + I2S(checkpoint))
				endif
			elseif cmd == "debugdrawpath" then
				if intVal != 0 then
					set level = Levels_Level(intVal)
					set checkpoint = level.GetCheckpoint(0)
				else
					set level = team.OnLevel
					set checkpoint = level.GetCheckpoint(team.OnCheckpoint)
				endif
				
				if checkpoint.Path != 0 then
					call checkpoint.Path.Draw()
				else
					call DisplayTextToPlayer(Player(pID), 0, 0, "Null path for level: " + level.GetLocalizedLevelName(pID))
					call DisplayTextToPlayer(Player(pID), 0, 0, "Checkpoint ID: " + I2S(checkpoint))
				endif
			elseif cmd == "debugpathconnection" then
				call u.SetDebugPathConnection(not u.GetDebugPathConnection())
			elseif cmd == "debugpathdistance" then
				set u.DebugCurrentDistance = not u.DebugCurrentDistance
			elseif cmd == "cam" or cmd == "camera" then
				if GetLocalPlayer() == Player(pID) then
					call DisplayTextToPlayer(Player(pID), 0, 0, "Camera distance: " + R2S(GetCameraField(CAMERA_FIELD_TARGET_DISTANCE)))
					call DisplayTextToPlayer(Player(pID), 0, 0, "Camera AoA: " + R2S(GetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK)))
					
					call DisplayTextToPlayer(Player(pID), 0, 0, "Camera Far Z: " + R2S(GetCameraField(CAMERA_FIELD_FARZ)))
					call DisplayTextToPlayer(Player(pID), 0, 0, "Camera FoV: " + R2S(GetCameraField(CAMERA_FIELD_FIELD_OF_VIEW)))
					call DisplayTextToPlayer(Player(pID), 0, 0, "Camera Roll: " + R2S(GetCameraField(CAMERA_FIELD_ROLL)))
					call DisplayTextToPlayer(Player(pID), 0, 0, "Camera Rotation: " + R2S(GetCameraField(CAMERA_FIELD_ROTATION)))
					call DisplayTextToPlayer(Player(pID), 0, 0, "Camera Z Offset: " + R2S(GetCameraField(CAMERA_FIELD_ZOFFSET)))
					
					call DisplayTextToPlayer(Player(pID), 0, 0, "Camera Near Z: " + R2S(GetCameraField(CAMERA_FIELD_NEARZ)))
					call DisplayTextToPlayer(Player(pID), 0, 0, "Camera L-Pitch: " + R2S(GetCameraField(CAMERA_FIELD_LOCAL_PITCH)))
					call DisplayTextToPlayer(Player(pID), 0, 0, "Camera L-Yaw: " + R2S(GetCameraField(CAMERA_FIELD_LOCAL_YAW)))
					call DisplayTextToPlayer(Player(pID), 0, 0, "Camera L-Roll: " + R2S(GetCameraField(CAMERA_FIELD_LOCAL_ROLL)))
				endif
			elseif cmd == "error" or cmd == "err" then
				call ThrowError(true, "InGameCommands", "ParseCommand", "error", 0, "User forced an error!")
			endif
		endif
		
		//commands available to any release mode
		//TODO localize command value via Localization.Equals(cmd, 'CAFK', true)
		if Localization.Equals(cmd, 'CAFK', true) then
			call u.SetAFK(true)
		// elseif cmd == "language" then
		elseif Localization.Equals(cmd, 'LTIT', true) or Localization.Equals(cmd, 'LNAM', true) then			
			if strVal == null or StringLength(strVal) == 0 then
				set strVal = ConvertLanguageToLanguageCode(cmd)
				
				if strVal == null then
					set strVal = ConvertInputToLanguageCode('LNAM', cmd)
				endif
								
				call u.SetLanguageCode(strVal)
			else
				call u.SetLanguageCode(strVal)
			endif
		endif
	endfunction
	

	//===========================================================================
	private function init takes nothing returns nothing
		local integer i = 0
		local trigger t
		
		// if CONFIGURATION_PROFILE != RELEASE then
		set t = CreateTrigger()
		
		loop
			call TriggerRegisterPlayerChatEvent(t, Player(i), "-", false )
			//call TriggerRegisterPlayerChatEvent( t, Player(i), "!", false )
		set i = i + 1
		exitwhen i >= 8
		endloop
		
		call TriggerAddAction(t, function ParseCommand)
		
		set t = null
		// endif
	endfunction
endlibrary