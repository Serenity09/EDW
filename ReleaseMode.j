library ConfigurationMode
globals
	constant integer DEV = 0
	constant integer TEST = 1
	constant integer RELEASE = 2
	constant integer CONFIGURATION_PROFILE = DEV
endglobals	
endlibrary

library ConfigurationModeInitializer initializer init requires ConfigurationMode, InGameCommands	
	private function init takes nothing returns nothing
		if CONFIGURATION_PROFILE == RELEASE then
			//call DisableTrigger(tInGameCommands)
		endif
		
	endfunction
endlibrary