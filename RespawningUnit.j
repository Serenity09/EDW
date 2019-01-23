library RespawningUnit requires Alloc

struct RespawningUnit extends array
    private vector2 position
    private integer uID
    private real facing
	
    //in degrees
    //special values: {-1: random direction out of up,right,down,left, -2: random direction out of diagonals, }
    
	implement Alloc
    
	public method respawn takes nothing returns unit
		local real direction
        
        if .facing >= 0 then
            set direction = .facing
        else
            if .facing == -1 then
                set direction = GetRandomInt(0, 3) * 90
            elseif .facing == -2 then
                set direction = GetRandomInt(0, 3) * 90 + 45
            else
                set direction = 0
            endif
        endif
		
		return Recycle_MakeUnitWithFacing(.uID, .position.x, .position.y, direction)
	endmethod
	
	public method destroy takes nothing returns nothing
		call .position.deallocate()
		call .deallocate()
	endmethod
    public static method create takes real X, real Y, integer UID, real Facing returns thistype
        local thistype new = thistype.allocate()
		
		set new.position = vector2.create(X, Y)
        set new.uID = UID
        set new.facing = Facing
        
        return new
    endmethod
endstruct

struct AutoRespawningUnit extends array
	public static method callback takes nothing returns nothing
        local timer t = GetExpiredTimer()
        local RespawningUnit wtr = RespawningUnit(GetTimerData(t))
        
		call wtr.respawn()
		
        call ReleaseTimer(t)
        set t = null
		call wtr.destroy()
    endmethod
	
	public static method create takes real X, real Y, integer UID, real Facing, real respawnTime returns thistype
		local thistype new = RespawningUnit.create(X, Y, UID, Facing)
		
		call TimerStart(NewTimerEx(new), respawnTime, false, function thistype.callback)
		
		return new
	endmethod
endstruct

endlibrary