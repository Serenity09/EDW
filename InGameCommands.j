library InGameCommands requires MazerGlobals, Platformer
function ExportPlatformingVariables takes Platformer p returns nothing
    //display all variables on screen
    call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[tvx] Terminal Velocity X: " + R2S(p.TerminalVelocityX / PlatformerGlobals_GAMELOOP_TIMESTEP))
    call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[tvy] Terminal Velocity Y: " + R2S(p.TerminalVelocityY / PlatformerGlobals_GAMELOOP_TIMESTEP))
    //call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[tvf] Terminal Velocity Falloff: " + R2S(p.TerminalFalloff))
    call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[xf] Horizontal Falloff: " + R2S(p.XFalloff / PlatformerGlobals_GAMELOOP_TIMESTEP))
    call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[yf] Vertical Falloff: " + R2S(p.YFalloff / PlatformerGlobals_GAMELOOP_TIMESTEP))
    call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[ms] Move Speed: " + R2S(p.MoveSpeed / PlatformerGlobals_GAMELOOP_TIMESTEP))
    call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[msoff] Move Speed's Offset Effect against cur Velocity: " + R2S(p.MoveSpeedVelOffset))
    call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[ga] Gravitational Acceleration: " + R2S(p.GravitationalAccel / PlatformerGlobals_GAMELOOP_TIMESTEP))
    call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[vj] Vertical Jump: " + R2S(p.vJumpSpeed / PlatformerGlobals_GAMELOOP_TIMESTEP))
    call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[v2h] Vertical 2 Horizontal Jump: " + R2S(p.v2hJumpRatio / PlatformerGlobals_GAMELOOP_TIMESTEP))
    call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[hj] Horizontal Jump: " + R2S(p.hJumpSpeed / PlatformerGlobals_GAMELOOP_TIMESTEP))
    call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[om] Ocean Motion: " + R2S(PlatformerOcean_OCEAN_MOTION / PlatformerOcean_TIMESTEP))
    call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[ovj] Ocean Jump Height: " + R2S(JUMPHEIGHTINOCEAN / PlatformerGlobals_GAMELOOP_TIMESTEP))
    call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[iss] Ice Slow Speed: " + R2S(PlatformerIce_SLOW_VELOCITY / PlatformerIce_TIMESTEP))
    call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[ifs] Ice Fast Speed: " + R2S(PlatformerIce_FAST_VELOCITY / PlatformerIce_TIMESTEP))
    call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "--------------------")
endfunction

function PrintPlatformingVariables takes Platformer p returns nothing
    //display all variables on screen
    call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[tvx] Terminal Velocity X: " + R2S(p.TerminalVelocityX))
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
    call DisplayTextToForce(bj_FORCE_PLAYER[p.PID], "[tvx] Terminal Velocity X: " + R2S(p.BaseProfile.TerminalVelocityX))
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
    debug call DisplayTextToForce(bj_FORCE_PLAYER[pID], "Vector2: " + I2S(vector2.calculateMemoryUsage()))
    debug call DisplayTextToForce(bj_FORCE_PLAYER[pID], "SimpleList: " + I2S(SimpleList_List.calculateMemoryUsage()))
    debug call DisplayTextToForce(bj_FORCE_PLAYER[pID], "SimpleListNode: " + I2S(SimpleList_ListNode.calculateMemoryUsage()))
    debug call DisplayTextToForce(bj_FORCE_PLAYER[pID], "PlatformerPropertyEquation: " + I2S(PlatformerPropertyEquation.calculateMemoryUsage()))
    debug call DisplayTextToForce(bj_FORCE_PLAYER[pID], "PlatformerPropertyAdjustment: " + I2S(PlatformerPropertyAdjustment.calculateMemoryUsage()))
    debug call DisplayTextToForce(bj_FORCE_PLAYER[pID], "RelayUnit: " + I2S(RelayUnit.calculateMemoryUsage()))    
    
    debug call DisplayTextToForce(bj_FORCE_PLAYER[pID], "IndexedUnit_AutoId: " + I2S(IndexedUnit_GetAutoId()))
    debug call DisplayTextToForce(bj_FORCE_PLAYER[pID], "IndexedUnit_RecycleCount: " + I2S(IndexedUnit_GetRecycleCount()))
endfunction
/*
function ProfileChange takes nothing returns nothing
    local string msg = GetEventPlayerChatString()
    local integer pID = GetPlayerId(GetTriggerPlayer())
    local integer i = 0
    local string cmd
    local real val
    local Platformer p = Platformer.AllPlatformers[pID]
    local PlatformerProfile pp = p.BaseProfile
    
    loop
    exitwhen i >= StringLength(msg) - 1 or SubString(msg, i, i + 1) == " "
    set i = i + 1
    endloop
    
    set cmd = SubString(msg, 1, i)
    
    if StringLength(msg) >= i + 1 then
        set val = S2R(SubString(msg, i + 1, StringLength(msg)))
    endif
    
    //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "msg: " + msg + " cmd: " + cmd + " val: " + R2S(val))
    if cmd == "tvx" then
        set pp.TerminalVelocityX = val
    elseif cmd == "tvy" then
        set pp.TerminalVelocityY = val
    //elseif cmd == "tvf" then
        //set p.TerminalFalloff = val
    elseif cmd == "xf" then
        set pp.XFalloff = val
    elseif cmd == "yf" then
        set pp.YFalloff = val
    elseif cmd == "ms" then
        set pp.MoveSpeed = val
    elseif cmd == "msoff" then
        set pp.MoveSpeedVelOffset = val
    elseif cmd == "ga" then
        set pp.GravitationalAccel = val
    elseif cmd == "vj" then
        set pp.vJumpSpeed = val
    elseif cmd == "hj" then
        set pp.hJumpSpeed = val
    elseif cmd == "v2h" then
        set pp.v2hJumpRatio = val
    elseif cmd == "om" then
        set PlatformerOcean_OCEAN_MOTION = val
    elseif cmd == "ovj" then
        set JUMPHEIGHTINOCEAN = val
    elseif cmd == "iss" then
        set PlatformerIce_SLOW_VELOCITY = val
    elseif cmd == "ifs" then
        set PlatformerIce_FAST_VELOCITY = val
    elseif cmd == "help" or cmd == "h" then
        call PrintPlatformingVariables(p)
    elseif cmd == "prof" then
        call PrintPlatformingProfileVariables(p)
    elseif cmd == "export" then
        call ExportPlatformingVariables(p)
   elseif cmd == "mem" then
        call PrintMemoryAnalysis(p.PID)
        
    elseif cmd == "track" or cmd == "t" or cmd == "follow" or cmd == "f" then
        call ToggleDefaultTracking(p.PID)
    endif
    
    call p.SetPhysicsToProfile()
endfunction
*/
function Trig_InGamePlatformingChanges_Actions takes nothing returns nothing
    local string msg = GetEventPlayerChatString()
    local integer pID = GetPlayerId(GetTriggerPlayer())
    local integer i = 0
    local integer strLength = StringLength(msg)
    local string cmd
    local real val
    local integer intVal
    local User u = User(pID)
    local Platformer p = u.Platformer
    local Teams_MazingTeam team = User(pID).Team
    
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
        set val = S2R(SubString(msg, i + 1, strLength))
        set intVal = R2I(val)
	endif
        
	//debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "msg: " + msg + " cmd: " + cmd + " val: " + R2S(val))
	if cmd == "tvx" then
		set p.TerminalVelocityX = val
	elseif cmd == "tvy" then
		set p.TerminalVelocityY = val
	//elseif cmd == "tvf" then
		//set p.TerminalFalloff = val
	elseif cmd == "xf" then
		set p.XFalloff = val
	elseif cmd == "yf" then
		set p.YFalloff = val
	elseif cmd == "ms" then
		set p.MoveSpeed = val
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
	elseif cmd == "iss" then
		set PlatformerIce_SLOW_VELOCITY = val
	elseif cmd == "ifs" then
		set PlatformerIce_FAST_VELOCITY = val
		
	elseif cmd == "level" or cmd == "lvl" then
		if Levels_Levels[intVal] != null then
			call Levels_Levels[team.OnLevel].SwitchLevels(team, Levels_Levels[intVal])
		endif
	elseif cmd == "checkpoint" or cmd == "cp" then
		if Levels_Levels[team.OnLevel].CPCount > intVal and intVal >= 0 then
			call Levels_Levels[team.OnLevel].SetCheckpointForTeam(team, intVal)
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
	elseif cmd == "testpocean" or cmd == "tpo" then
		call team.MoveRevive(gg_rct_Region_380)
		set team.DefaultGameMode = Teams_GAMEMODE_PLATFORMING
		call team.RespawnTeamAtRect(gg_rct_Region_380, true)
		
		debug call DisplayTextToForce(bj_FORCE_PLAYER[pID], "Finished setting up plat test")
	elseif cmd == "testpice" or cmd == "tpi" then
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
	endif
    
    if cmd == "track" or cmd == "t" or cmd == "follow" or cmd == "f" then
        call ToggleDefaultTracking(p.PID)
    endif
endfunction


//===========================================================================
function InitTrig_In_Game_Commands takes nothing returns nothing
    local integer i = 0
    //local trigger t = CreateTrigger()
    local trigger t = CreateTrigger()
    
    loop
        call TriggerRegisterPlayerChatEvent( t, Player(i), "-", false )
        //call TriggerRegisterPlayerChatEvent( t, Player(i), "!", false )
    set i = i + 1
    exitwhen i >= 8
    endloop
    
    call TriggerAddAction( t, function Trig_InGamePlatformingChanges_Actions )
    
    set t = null
    //call TriggerAddAction(t, function ProfileChange)
endfunction
endlibrary
