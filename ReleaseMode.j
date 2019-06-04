library ConfigurationMode
	globals
		constant integer DEV = 0
		constant integer TEST = 1
		constant integer RELEASE = 2
		
		constant integer CONFIGURATION_PROFILE = 0
		
		constant boolean FORCE_SETTING_MENU = false
	endglobals
	
	function ShouldShowSettingVoteMenu takes nothing returns boolean
		return CONFIGURATION_PROFILE == RELEASE or FORCE_SETTING_MENU
	endfunction
endlibrary