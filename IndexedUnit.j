library IndexedUnit
	struct IndexedUnit extends array
		public unit Unit
		public IStartable ParentStartable
		
		implement Alloc
		
		public static method create takes unit u returns thistype
			static if DEBUG_MODE then
				local thistype new
				
				if GetUnitUserData(u) != 0 then
					call DisplayTextToForce(bj_FORCE_PLAYER[0], "Indexing unit that has user data!")
					//is it better to mirror release code state or to catch and manage the leak so other tests may proceed?
					return GetUnitUserData(u)
				endif
				
				set new = thistype.allocate()
			else
				local thistype new = thistype.allocate()
			endif
			
			set new.Unit = u
			call SetUnitUserData(u, new)
			
			return new
		endmethod
		public method destroy takes nothing returns nothing
			call SetUnitUserData(this.Unit, 0)
			set this.Unit = null
			
			call this.deallocate()
		endmethod
	endstruct
endlibrary