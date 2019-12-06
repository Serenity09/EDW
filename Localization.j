library Localization requires LocalizationData
	struct Localization extends array
		
		public static method Equals takes string input, integer contentID, boolean ignoreCase returns boolean
			local integer iLangID = 1
			local boolean match = false
			
			loop
			exitwhen iLangID > LocalizationData_LANGUAGE_COUNT or match
				if ignoreCase then
					if StringCase(LocalizeContentEx(contentID, iLangID), false) == StringCase(input, false) then
						set match = true
					endif
				else
					if LocalizeContentEx(contentID, iLangID) == input then
						set match = true
					endif
				endif
				
			set iLangID = iLangID + 1
			endloop
			
			return match
		endmethod
	endstruct
endlibrary