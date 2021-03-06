library EDWGameTime requires Teams, GameMessage, StringFormat
    globals
        private timer t = null
		private constant integer TIMEOUT = 60
		private real currentTime = 0
    endglobals
    
    function GetElapsedGameTime takes nothing returns real
        return TimerGetElapsed(t) + currentTime
    endfunction
	function GetRemainingGameTime takes nothing returns real
		//check if theres a time related victory condition
		if VictoryTime != 0 then
			return VictoryTime - currentTime
		else
			return -1.
		endif
	endfunction
	
	private function LocalizeMinutesRemaining takes integer remainingTime, User localizer returns string
		//ColorValue(I2S(R2I(remainingTime))) + " minutes remaining"
		return StringFormat1(LocalizeContent('TCMR', localizer.LanguageCode), ColorValue(I2S(remainingTime)))
	endfunction
	private function LocalizeOnlyMinutesRemaining takes integer remainingTime, User localizer returns string
		//ColorValue(I2S(R2I(remainingTime))) + " minutes remaining"
		return StringFormat1(LocalizeContent('TCOR', localizer.LanguageCode), ColorValue(I2S(remainingTime)))
	endfunction
	private function CB takes nothing returns nothing
		local integer remainingTime
		
		set currentTime = currentTime + TIMEOUT
		
		//check if theres a time related victory condition
		if VictoryTime != 0 then
			set remainingTime = R2I((VictoryTime - currentTime) / 60)
			if remainingTime == 0 then
				//end the game
				call Teams_MazingTeam.ApplyEndGameAll(Teams_MazingTeam.GetLeadingScore())
				
				call PauseTimer(t)
				call DestroyTimer(t)
				set t = null
			elseif remainingTime >= 10 and remainingTime <= 30 then
				if ModuloInteger(R2I(currentTime), 600) == 0 then
					//post elapsed time every 10 minutes
					// call Teams_MazingTeam.PrintMessageAll(ColorValue(I2S(R2I(remainingTime))) + " minutes remaining", 0)
					call Teams_MazingTeam.DisplayDynamicContentAll(LocalizeMinutesRemaining, remainingTime, 0)
				endif
			elseif remainingTime == 5 then
				//5min warning
				// call Teams_MazingTeam.PrintMessageAll(ColorValue(I2S(R2I(remainingTime))) + " minutes remaining", 0)
				call Teams_MazingTeam.DisplayDynamicContentAll(LocalizeMinutesRemaining, remainingTime, 0)
			elseif remainingTime <= 3 then
				//post warnings every minute
				// if remainingTime != 1 then
					// call Teams_MazingTeam.PrintMessageAll("Only " + ColorValue(I2S(R2I(remainingTime))) + " minutes " + "remaining!", 0)
				// else
					// call Teams_MazingTeam.PrintMessageAll("Only " + ColorValue(I2S(R2I(remainingTime))) + " minute " + "remaining!", 0)
				// endif
				call Teams_MazingTeam.DisplayDynamicContentAll(LocalizeOnlyMinutesRemaining, remainingTime, 0)
			endif
		endif
	endfunction
	
	function ToggleGameTime takes boolean flag returns nothing
		if t != null then
			if flag then
				call ResumeTimer(t)
			else
				call PauseTimer(t)
			endif
		endif
	endfunction
    
    function TrackGameTime takes nothing returns nothing
		if t == null then
			set t = CreateTimer()
			call TimerStart(t, TIMEOUT, true, function CB)
			
			if VictoryTime != 0 then
				call Teams_MazingTeam.DisplayDynamicContentAll(LocalizeMinutesRemaining, R2I(VictoryTime / 60), 0)
				// call Teams_MazingTeam.PrintMessageAll(ColorValue(I2S(R2I(VictoryTime / 60))) + " minutes remaining", 0)
			endif
		endif
    endfunction
	
	function IsGameTimeTracked takes nothing returns boolean
		return t != null
	endfunction
endlibrary