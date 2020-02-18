library SpecialEffect requires Alloc, TimerUtils
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
		
		public static method createForTarget takes string fxFileLocation, widget targetWidget, string attachPointName, player viewer, real duration returns thistype
			local thistype new = thistype.allocate()
			
			static if APPLY_LOCAL then
				local string localFXFileLocation = fxFileLocation
				
				if viewer != null and GetLocalPlayer() != viewer then
					set localFXFileLocation = ""
				endif
				
				set new.Effect = AddSpecialEffectTarget(localFXFileLocation, targetWidget, attachPointName)
			else
				set new.Effect = AddSpecialEffectTarget(fxFileLocation, targetWidget, attachPointName)
			endif
			
			call TimerStart(NewTimerEx(new), duration, false, function thistype.OnExpire)
			
			return new
		endmethod
		public static method create takes string fxFileLocation, real x, real y, player viewer, real duration returns thistype
			local thistype new = thistype.allocate()
			
			static if APPLY_LOCAL then
				local string localFXFileLocation = fxFileLocation
				
				if viewer != null and GetLocalPlayer() != viewer then
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
	
	struct UserActiveTimedEffect extends array
		public User Viewer
		
		private static method OnExpire takes nothing returns nothing
			local timer t = GetExpiredTimer()
			local UserActiveTimedEffect te = GetTimerData(t)
			
			if te.Viewer.ActiveEffect != null then
				call DestroyEffect(te.Viewer.ActiveEffect)
				set TimedEffect(te).Effect = null
				set te.Viewer.ActiveEffect = null
			endif
			
			call TimedEffect(te).deallocate()
			call ReleaseTimer(t)
			set t = null
		endmethod
		
		public static method create takes string fxFileLocation, string attachPointName, User viewer, real duration returns thistype
			local TimedEffect new = TimedEffect.allocate()
			
			set UserActiveTimedEffect(new).Viewer = viewer
			
			if viewer.ActiveEffect != null then
				call DestroyEffect(viewer.ActiveEffect)
			endif
			
			static if APPLY_LOCAL then
				local string localFXFileLocation = fxFileLocation
				
				if viewer != null and GetLocalPlayer() != Player(viewer) then
					set localFXFileLocation = ""
				endif
				
				set new.Effect = AddSpecialEffectTarget(localFXFileLocation, viewer.ActiveUnit, attachPointName)
			else
				set new.Effect = AddSpecialEffectTarget(fxFileLocation, viewer.ActiveUnit, attachPointName)
			endif
			
			//call UserActiveTimedEffect(new).Viewer.SetActiveEffectEx(new.Effect)
			set viewer.ActiveEffect = new.Effect
			
			call TimerStart(NewTimerEx(new), duration, false, function thistype.OnExpire)
			
			return new
		endmethod
	endstruct
	
	function CreateSpecialEffect takes string fxFileLocation, real x, real y, player viewer returns effect
		static if APPLY_LOCAL then
			local string localFXFileLocation = fxFileLocation
			
			if viewer != null and GetLocalPlayer() != viewer then
				set localFXFileLocation = ""
			endif
			
			return AddSpecialEffect(localFXFileLocation, x, y)
		else
			return AddSpecialEffect(fxFileLocation, x, y)
		endif
	endfunction
	function CreateSpecialEffectTarget takes string fxFileLocation, widget targetWidget, string attachPointName, player viewer returns effect
		static if APPLY_LOCAL then
			local string localFXFileLocation = fxFileLocation
			
			if viewer != null and GetLocalPlayer() != viewer then
				set localFXFileLocation = ""
			endif
			
			return AddSpecialEffectTarget(localFXFileLocation, targetWidget, attachPointName)
		else
			return AddSpecialEffectTarget(fxFileLocation, targetWidget, attachPointName)
		endif
	endfunction
	
	function CreateTimedSpecialEffect takes string fxFileLocation, real x, real y, player viewer, real duration returns effect
		return TimedEffect.create(fxFileLocation, x, y, viewer, duration).Effect
	endfunction
	function CreateTimedSpecialEffectTarget takes string fxFileLocation, widget targetWidget, string attachPointName, player viewer, real duration returns effect
		return TimedEffect.createForTarget(fxFileLocation, targetWidget, attachPointName, viewer, duration).Effect
	endfunction
		
	function CreateInstantSpecialEffect takes string fxFileLocation, real x, real y, player viewer returns nothing
		static if APPLY_LOCAL then
			local string localFXFileLocation = fxFileLocation
			
			if viewer != null and GetLocalPlayer() != viewer then
				set localFXFileLocation = ""
			endif
			
			call DestroyEffect(AddSpecialEffect(localFXFileLocation, x, y))
		else
			call DestroyEffect(AddSpecialEffect(fxFileLocation, x, y))
		endif
	endfunction
	function CreateInstantSpecialEffectTarget takes string fxFileLocation, widget targetWidget, string attachPointName, player viewer returns nothing
		static if APPLY_LOCAL then
			local string localFXFileLocation = fxFileLocation
			
			if viewer != null and GetLocalPlayer() != viewer then
				set localFXFileLocation = ""
			endif
			
			call DestroyEffect(AddSpecialEffectTarget(localFXFileLocation, targetWidget, attachPointName))
		else
			call DestroyEffect(AddSpecialEffectTarget(fxFileLocation, targetWidget, attachPointName))
		endif
	endfunction
endlibrary