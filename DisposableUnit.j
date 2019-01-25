library DisposableUnit requires IndexedUnit, IStartable
	struct DisposableUnit extends array
		private static IStartable array TrackedUnits
		
		public static method IsUnitDisposable takes unit u returns boolean
			return TrackedUnits[GetUnitId(u)] != 0
		endmethod
		
		public method dispose takes nothing returns nothing
			call TrackedUnits[this].destroy()
			
			set TrackedUnits[this] = 0
			call DeindexUnit(GetUnitFromId(this))
		endmethod
		public static method register takes unit u, IStartable disposable returns thistype
			local thistype new = IndexUnit(u)
			
			set thistype.TrackedUnits[new] = disposable
			
			return new
		endmethod
	endstruct
endlibrary