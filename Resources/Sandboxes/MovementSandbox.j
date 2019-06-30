library MovementSandbox initializer Init //requires Table
	globals
		private constant player SANDBOX_PLAYER = Player(2)
		private constant integer SANDBOX_UNIT_TYPE_ID = 'ospw'
		private constant integer SANDBOX_MOVE_ANIMATION_ID = 2
		
		//private constant real SANDBOX_SPAWN_TIMEOUT = 1.
		private constant real SANDBOX_MOVE_TIMEOUT = .035
		private constant real SANDBOX_BASE_MOVESPEED = 150.
		private constant real SANDBOX_MOVESPEED = SANDBOX_BASE_MOVESPEED * SANDBOX_MOVE_TIMEOUT
		private constant real SANDBOX_MOVE_ANGLE = bj_PI * 1.5
		private constant real SANDBOX_RESET_DISTANCE = 128. * 10
		private constant real SANDBOX_RESET_TIMEOUT = 10.
		
		//private HashTable SandboxUnits
		private unit SandboxUnit
		//private timer SpawnTimer
		private timer MoveTimer
		private timer ResetTimer
	endglobals
	
	private function Reset takes nothing returns nothing
		call SetUnitPosition(SandboxUnit, 0, 0)
		call SetUnitX(SandboxUnit, 0)
		call SetUnitY(SandboxUnit, 0)
	endfunction
	private function Move takes nothing returns nothing
		call SetUnitX(SandboxUnit, GetUnitX(SandboxUnit) + Cos(SANDBOX_MOVE_ANGLE) * SANDBOX_MOVESPEED)
		call SetUnitY(SandboxUnit, GetUnitY(SandboxUnit) + Sin(SANDBOX_MOVE_ANGLE) * SANDBOX_MOVESPEED)
	endfunction
	
	private function Stats takes nothing returns nothing
		call DisplayTextToForce(bj_FORCE_PLAYER[0], "Sandbox MS: " + R2S(SANDBOX_MOVESPEED) + ", x: " + R2S(GetUnitX(SandboxUnit) + Cos(SANDBOX_MOVE_ANGLE) * SANDBOX_MOVESPEED) + ", y: " + R2S(GetUnitY(SandboxUnit) + Sin(SANDBOX_MOVE_ANGLE) * SANDBOX_MOVESPEED))
		call DisplayTextToForce(bj_FORCE_PLAYER[0], "Theo TimeScale: " + R2S(SANDBOX_BASE_MOVESPEED / GetUnitDefaultMoveSpeed(SandboxUnit)))
		call DisplayTextToForce(bj_FORCE_PLAYER[0], "Theo2 TimeScale: " + R2S(GetUnitMoveSpeed(SandboxUnit) / GetUnitDefaultMoveSpeed(SandboxUnit)))
		call DisplayTextToForce(bj_FORCE_PLAYER[0], "Current MoveSpeed: " + R2S(GetUnitMoveSpeed(SandboxUnit)) + ", Default MS: " + R2S(GetUnitDefaultMoveSpeed(SandboxUnit)))
	
		call DestroyTimer(GetExpiredTimer())
	endfunction
	
	private function Init takes nothing returns nothing
		set MoveTimer = CreateTimer()
		set ResetTimer = CreateTimer()
		
		set SandboxUnit = CreateUnit(SANDBOX_PLAYER, SANDBOX_UNIT_TYPE_ID, 0, 0, 0)
		call UnitAddAbility(SandboxUnit, 'Aloc')
		call ShowUnit(SandboxUnit, false)
		call ShowUnit(SandboxUnit, true)
		call PauseUnit(SandboxUnit, true)
		call SetUnitAnimationByIndex(SandboxUnit, SANDBOX_MOVE_ANIMATION_ID)
		
		call SetUnitFacing(SandboxUnit, SANDBOX_MOVE_ANGLE * bj_RADTODEG)
		call SetUnitTimeScale(SandboxUnit, SANDBOX_BASE_MOVESPEED / GetUnitDefaultMoveSpeed(SandboxUnit))
		call SetUnitMoveSpeed(SandboxUnit, SANDBOX_MOVESPEED)
		
		call TimerStart(CreateTimer(), SANDBOX_MOVE_TIMEOUT, true, function Move)
		call TimerStart(CreateTimer(), SANDBOX_RESET_DISTANCE / SANDBOX_BASE_MOVESPEED, true, function Reset)
		
		call TimerStart(CreateTimer(), 0, false, function Stats)
	endfunction
endlibrary