library SpecialEffect requires Alloc
	globals
		public constant boolean ENABLED = true
		public constant boolean APPLY_LOCAL = false
		
		public constant string OVERHEAD = "overhead"
		public constant string HEAD = "head"
		public constant string CHEST = "chest"
		public constant string LEFT_HAND = "left,hand"
		public constant string RIGHT_HAND = "right,hand"
		public constant string LEFT_FOOT = "left,foot"
		public constant string RIGHT_FOOT = "right,foot"
		public constant string ORIGIN = "origin"
		public constant string WEAPON = "weapon"
	endglobals
	
	struct TimedEffect extends array
		public effect Effect
		
		implement Alloc
		
		private static method OnExpire takes nothing returns nothing
			local timer t = GetExpiredTimer()
			local thistype te = GetTimerData(t)
			
			call DestroyEffect(te.Effect)
			set te.Effect = null
			
			call te.deallocate()
			call ReleaseTimer(t)
			set t = null
		endmethod
		
		public static method createForTarget takes string fxFileLocation, widget targetWidget, string attachPointName, player target, real duration returns thistype
			local thistype new = thistype.allocate()
			
			static if APPLY_LOCAL then
				local string localFXFileLocation = fxFileLocation
				
				if GetLocalPlayer() != target then
					set localFXFileLocation = ""
				endif
				
				set new.Effect = AddSpecialEffectTarget(localFXFileLocation, targetWidget, attachPointName)
			else
				set new.Effect = AddSpecialEffectTarget(fxFileLocation, targetWidget, attachPointName)
			endif
			
			call TimerStart(NewTimerEx(new), duration, false, function thistype.OnExpire)
			
			return new
		endmethod
		public static method create takes string fxFileLocation, real x, real y, player target, real duration returns thistype
			local thistype new = thistype.allocate()
			
			static if APPLY_LOCAL then
				local string localFXFileLocation = fxFileLocation
				
				if GetLocalPlayer() != target then
					set localFXFileLocation = ""
				endif
				
				set new.Effect = AddSpecialEffect(localFXFileLocation, x, y)
			else
				set new.Effect = AddSpecialEffect(fxFileLocation, x, y)
			endif
			
			call TimerStart(NewTimerEx(new), duration, false, function thistype.OnExpire)
			
			return new
		endmethod
	endstruct
	
	function CreateSpecialEffect takes string fxFileLocation, real x, real y, player target returns effect
		static if APPLY_LOCAL then
			local string localFXFileLocation = fxFileLocation
			
			if GetLocalPlayer() != target then
				set localFXFileLocation = ""
			endif
			
			return AddSpecialEffect(localFXFileLocation, x, y)
		else
			return AddSpecialEffect(fxFileLocation, x, y)
		endif
	endfunction
	
	function CreateTimedSpecialEffect takes string fxFileLocation, real x, real y, player target, real duration returns effect
		return TimedEffect.create(fxFileLocation, x, y, target, duration).Effect
	endfunction
	function CreateTimedSpecialEffectTarget takes string fxFileLocation, unit targetUnit, string attachPointName, real duration returns effect
		return TimedEffect.createForTarget(fxFileLocation, targetUnit, attachPointName, GetOwningPlayer(targetUnit), duration).Effect
	endfunction
	
	function CreateInstantSpecialEffect takes string fxFileLocation, real x, real y, player target returns nothing
		static if APPLY_LOCAL then
			local string localFXFileLocation = fxFileLocation
			
			if GetLocalPlayer() != target then
				set localFXFileLocation = ""
			endif
			
			call DestroyEffect(AddSpecialEffect(localFXFileLocation, x, y))
		else
			call DestroyEffect(AddSpecialEffect(fxFileLocation, x, y))
		endif
	endfunction
	function CreateInstantSpecialEffectTarget takes string fxFileLocation, widget targetWidget, string attachPointName, player target returns nothing
		static if APPLY_LOCAL then
			local string localFXFileLocation = fxFileLocation
			
			if GetLocalPlayer() != target then
				set localFXFileLocation = ""
			endif
			
			call DestroyEffect(AddSpecialEffectTarget(localFXFileLocation, targetWidget, attachPointName))
		else
			call DestroyEffect(AddSpecialEffectTarget(fxFileLocation, targetWidget, attachPointName))
		endif
	endfunction
endlibrary