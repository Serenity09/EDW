library IceMovement initializer Init requires MazerGlobals, GroupUtils

globals
    constant real DEGREE_TO_RADIANS = 0.01745
    
    private constant real TIMEOUT = .035
    
    private constant real VELOCITY_FALLOFF = 1
    private constant real VELOCITY_CUTOFF = VELOCITY_FALLOFF + .5
	
	private constant real NPC_SKATE_SPEED = 12.5
	
	private timer t
	private group g
endglobals

function AdvancedIceMovement takes nothing returns nothing
    local group swap = NewGroup()
    local unit u
    local integer i
	
	loop
	set u = FirstOfGroup(g)
	exitwhen u == null
		set i = GetPlayerId(GetOwningPlayer(u))
		
		if i <= 8 then
			//apply player only actions
			//decrement remaining velocity, if any
			if VelocityX[i] != 0 then
				if VelocityX[i] > 0 then
					if VelocityX[i] < VELOCITY_CUTOFF then
						set VelocityX[i] = 0
					else
						set VelocityX[i] = VelocityX[i] - VELOCITY_FALLOFF
					endif
				else
					if VelocityX[i] > -VELOCITY_CUTOFF then
						set VelocityX[i] = 0
					else
						set VelocityX[i] = VelocityX[i] + VELOCITY_FALLOFF
					endif
				endif
			endif
			if VelocityY[i] != 0 then
				if VelocityY[i] > 0 then
					if VelocityY[i] < VELOCITY_CUTOFF then
						set VelocityY[i] = 0
					else
						set VelocityY[i] = VelocityY[i] - VELOCITY_FALLOFF
					endif
				else
					if VelocityY[i] > -VELOCITY_CUTOFF then
						set VelocityY[i] = 0
					else
						set VelocityY[i] = VelocityY[i] + VELOCITY_FALLOFF
					endif
				endif
			endif
			
			//physically move the unit a constant distance in the direction it's facing
			call SetUnitX(u, GetUnitX(u) + VelocityX[i] + SkateSpeed[i] * Cos(GetUnitFacing(u) * DEGREE_TO_RADIANS))
			call SetUnitY(u, GetUnitY(u) + VelocityY[i] + SkateSpeed[i] * Sin(GetUnitFacing(u) * DEGREE_TO_RADIANS))
			call IssueImmediateOrder(u, "stop")
		else
			//handle non-player units
			
			call SetUnitX(u, GetUnitX(u) + NPC_SKATE_SPEED * Cos(GetUnitFacing(u) * DEGREE_TO_RADIANS))
			call SetUnitY(u, GetUnitX(u) + NPC_SKATE_SPEED * Sin(GetUnitFacing(u) * DEGREE_TO_RADIANS))
			call IssueImmediateOrder(u, "stop")
		endif
		
		//TODO index mazer units
		//TODO modify skate speed array to use unit index
		//TODO move above action code to be generalized to include non-player units as well
		
	call GroupAddUnit(swap, u)
	call GroupRemoveUnit(g, u)
	endloop
	
	call ReleaseGroup(g)
	set g = swap
	
	set u = null
	set swap = null
endfunction

public function Add takes unit u returns nothing
	if IsGroupEmpty(g) then
		call TimerStart(t, TIMEOUT, true, function AdvancedIceMovement)
	endif
	
	call GroupAddUnit(g, u)
endfunction

public function Remove takes unit u returns nothing
	call GroupRemoveUnit(g, u)
	
	if IsGroupEmpty(g) then
        call PauseTimer(t)
    endif
endfunction

public function Init takes nothing returns nothing
    set g = NewGroup()
	set t = CreateTimer()
endfunction

endlibrary