library Localization
	globals
		public constant string LOCALIZATION_AI_FILE = "locale\\detect.ai"
		public constant string DEFAULT_LOCALIZATION = "en"
		
		private constant boolean DEBUG = true
		
		private constant integer LANGUAGE_CODE = 0
	endglobals
	
	//Can return different results for different players, depending on their specific localization settings
	//Do not depend on the result by using any functions that desync	
	function GetLanguageCode takes nothing returns string
		local player p = GetLocalPlayer()
		local string original = GetPlayerName(p)
		local string locale = null
				
		//starting CampaignAI via: LOCALIZATION_AI_FILE calls SetPlayerName(GetLocalPlayer(), "{LCID Name for their installed localization}")
		call StartCampaignAI(Player(PLAYER_NEUTRAL_AGGRESSIVE), LOCALIZATION_AI_FILE)
		//retrieve {LCID Name for their installed localization} from local player name
		set locale = GetPlayerName(p)
				
		//reset the local player's name to its original value
		call SetPlayerName(p, original)
		
		//check to see if any AI file was run for the players localization config, return default localization if not
		if original == locale then
			static if DEBUG then
				call DisplayTextToForce(bj_FORCE_PLAYER[GetPlayerId(p)], "Defaulted locale")
			endif
			
			return DEFAULT_LOCALIZATION
		endif
	 	
		return locale
	endfunction
endlibrary