library TypedInt requires Alloc
	struct TypedInt extends array
		public integer InstanceID
		public integer TypeID
		
		implement alloc
		
		public method ToObject takes nothing returns ...
			return this.TypeID(this.InstanceID)
		endmethod
		
		public static method create takes integer instanceID, integer typeID returns thistype
			local thistype new = thistype.allocate()
			
			set new.InstanceID = instanceID
			set new.TypeID = typeID
			
			return new
		endmethod
	endstruct
endlibrary