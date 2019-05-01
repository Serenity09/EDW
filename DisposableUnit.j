library DisposableUnit requires IndexedUnit, IStartable
	globals
		private constant boolean DEBUG_DISPOSE = false
	endglobals
	
	struct DisposableUnit extends array
		private IStartable TrackedStartable
		
		public static method IsUnitDisposable takes unit u returns boolean
			if GetUnitUserData(u) != 0 then
				return DisposableUnit(GetUnitUserData(u)).TrackedStartable != 0
			else
				return false
			endif
		endmethod
		
		public method dispose takes nothing returns nothing
			static if DEBUG_DISPOSE then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Starting dispose of disposable unit with ID: " + I2S(this))
			endif
			
			call this.TrackedStartable.destroy()
			set this.TrackedStartable = 0
			
			call IndexedUnit(this).destroy()
			
			static if DEBUG_DISPOSE then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Finished dispose of disposable unit with ID: " + I2S(this))
			endif
		endmethod
		public static method register takes unit u, IStartable disposable returns thistype
			local thistype new
			if GetUnitUserData(u) == 0 then
				set new = IndexedUnit.create(u)
			else
				set new = GetUnitUserData(u)
			endif
			
			set new.TrackedStartable = disposable
			
			static if DEBUG_DISPOSE then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Registering disposable unit on ID: " + I2S(new))
			endif
			
			return new
		endmethod
	endstruct
endlibrary