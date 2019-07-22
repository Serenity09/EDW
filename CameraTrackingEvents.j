library CameraTrackingEvents initializer Init requires User, MazerGlobals
	globals
		private trigger EscapeKeyEvent
	endglobals
	
	function RegisterCameraToggleEvents takes User user returns nothing
		call TriggerRegisterPlayerEventEndCinematic(EscapeKeyEvent, Player(user))
	endfunction
	
	private function OnEscapePress takes nothing returns nothing
		// local User source = User(GetPlayerId(GetTriggerPlayer()))
		call User(GetPlayerId(GetTriggerPlayer())).ToggleDefaultTracking()
	endfunction
	private function Init takes nothing returns nothing
		// set EscapeKeyEvent = Event.create()
		// call EscapeKeyEvent.register(Condition(function OnEscapePress))
		set EscapeKeyEvent = CreateTrigger()
		call TriggerAddAction(EscapeKeyEvent, function OnEscapePress)
	endfunction
endlibrary