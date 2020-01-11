library StringFormat
	globals
		public constant integer PLACEHOLDER_LENGTH = 3
		public constant string PLACEHOLDER_START_DELIMITER = "{"
		public constant string PLACEHOLDER_1 = "{0}"
		public constant string PLACEHOLDER_2 = "{1}"
		public constant string PLACEHOLDER_3 = "{2}"
	endglobals
	
	function StringFormat1 takes string source, string arg1 returns string
		local integer iSource = 0
		local integer sourceLength = StringLength(source)
		
		local integer iFormat = 0
		local string format = ""
		
		// call DisplayTextToPlayer(Player(0), 0, 0, "String: " + source + ", length: " + I2S(sourceLength))
		
		//iterate source string until end of string or encounter a placeholder
		//add source string up to that point to format
		loop
		exitwhen iSource > sourceLength
			if iSource == sourceLength then
				return format + SubString(source, iFormat, iSource)
			elseif SubString(source, iSource, iSource + 1) == PLACEHOLDER_START_DELIMITER and SubString(source, iSource, iSource + PLACEHOLDER_LENGTH) == PLACEHOLDER_1 then
				set format = format + SubString(source, iFormat, iSource) + arg1
				
				set iSource = iSource + PLACEHOLDER_LENGTH
				set iFormat = iSource
			else
				set iSource = iSource + 1
			endif
		endloop
		
		return format
	endfunction
	function StringFormat2 takes string source, string arg1, string arg2 returns string
		local integer iSource = 0
		local integer sourceLength = StringLength(source)
		
		local integer iFormat = 0
		local string format = ""
		
		local string curPlaceholderValue
		
		//iterate source string until end of string or encounter a placeholder
		//add source string up to that point to format
		loop
		exitwhen iSource > sourceLength
			if iSource == sourceLength then
				return format + SubString(source, iFormat, iSource)
			elseif SubString(source, iSource, iSource + 1) == PLACEHOLDER_START_DELIMITER then
				set curPlaceholderValue = SubString(source, iSource, iSource + PLACEHOLDER_LENGTH)
				
				if curPlaceholderValue == PLACEHOLDER_1 then
					set format = format + SubString(source, iFormat, iSource) + arg1
				elseif curPlaceholderValue == PLACEHOLDER_2 then
					set format = format + SubString(source, iFormat, iSource) + arg2
				endif
				
				set iSource = iSource + PLACEHOLDER_LENGTH
				set iFormat = iSource
			else
				set iSource = iSource + 1
			endif
		endloop
		
		return format
	endfunction
	function StringFormat3 takes string source, string arg1, string arg2, string arg3 returns string
		local integer iSource = 0
		local integer sourceLength = StringLength(source)
		
		local integer iFormat = 0
		local string format = ""
		
		local string curPlaceholderValue
		
		//iterate source string until end of string or encounter a placeholder
		//add source string up to that point to format
		loop
		exitwhen iSource > sourceLength
			if iSource == sourceLength then
				return format + SubString(source, iFormat, iSource)
			elseif SubString(source, iSource, iSource + 1) == PLACEHOLDER_START_DELIMITER then
				set curPlaceholderValue = SubString(source, iSource, iSource + PLACEHOLDER_LENGTH)
				
				if curPlaceholderValue == PLACEHOLDER_1 then
					set format = format + SubString(source, iFormat, iSource) + arg1
				elseif curPlaceholderValue == PLACEHOLDER_2 then
					set format = format + SubString(source, iFormat, iSource) + arg2
				elseif curPlaceholderValue == PLACEHOLDER_3 then
					set format = format + SubString(source, iFormat, iSource) + arg3
				endif
				
				//update source and format indices to skip placeholder position
				set iSource = iSource + PLACEHOLDER_LENGTH
				set iFormat = iSource
			else
				set iSource = iSource + 1
			endif
		endloop
		
		return format
	endfunction
endlibrary