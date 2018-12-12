//TESH.scrollpos=520
//TESH.alwaysfold=0
library StringParser uses Ascii
//Ascii- thehelper.net/forums/showthread.php?t=135066
globals
    //what StringStack.DELIMITER is set to
    private constant string VAL_DELIMITER = " "
endglobals
////////////////////////////////////////////////////////////////////////
//Version: 2.0.0.0
//Author: Nestharus
//
//Characters:
//  String Delimiter: "
//      what a string starts and ends with:
//          "hello there"
//          "omg!!"
//
//  Escape Character: \
//      Escapes a special character:
//          "I said \"hi\" to that guy"
//
//Description
//      String Parser splits a string up into a stack of types. These types include primitive and user
//      defined types. Types may extend off of each other. Type comparisons checks to see if the first type
//      fits into the second type.
//
//      String values are split by the delimiter character (default " "), but strings within strings and 
//      ascii integers do not need to be split with the delimiter character since they already have 
//      delimiters.
//
//          Example:
//              type unit extends widget
//                  unit.is(widget) returns true //a unit fits into a widget     
//
//      String Parser is used to retrieve a string's primitive type and to split a string up
//      into a stack of primitive types.
//
//      For example (delimiter of " "), 123 "hello" 'hpea' ->
//          integer: 123
//          string: hello
//          ascii: hpea
//
//      String Parser is also made to intelligently parse a string even if delimiters are not present:
//          "hello""boo"123 ->
//              string: hello
//              string: boo
//              integer: 123
//
//      Keep in mind that intelligent parsing only operates on strings and ascii integers.
//
//      String Parser also supports custom types, type aliasing, and custom type integer values. For example, the boolean
//      is actually a custom type. It has 4 different values.
//          "true" - 1
//          "false" - 0
//          "on" - 1
//          "off" 0
//
//      String Parser supports converting values into integers or booleans.
////////////////////////////////////////////////////////////////////////
//API
//      function S2B takes string s returns boolean
//          string to boolean
//
//      function B2S takes boolean val returns string
//          boolean to string
//
//      function A2S takes integer val returns string
//          ascii to to string
//
//      function S2A takes string val returns integer
//          string to ascii
//
//      struct StringValue
//          readonly boolean boolean
//              returns string value object as boolean
//
//          readonly integer integer
//              returns string value object as integer
//
//          readonly string string
//              returns string value of string value object
//
//          readonly StringType type
//              returns string value object type
//
//          static method operator [] takes string s returns StringValue
//              converts a string into a string value object
//
//          static method create takes string value, StringType valueType, integer convertedValue returns StringValue
//              creates a new string value objct
//                  value: the string value of the object
//                  valueType: the type of value (StringType)
//                  convertedValue: the integer value (boolean true would be 1)
//
//      struct StringType
//          primitive types already defined-
//              static constant integer NULL
//              static constant integer BOOLEAN
//              static constant integer ASCII
//              static constant integer INTEGER
//              static constant integer REAL
//              static constant integer STRING
//
//          readonly string name
//              the name of the StringType object
//
//          readonly integer extends
//              what StringType the object extends off of. For example, real extends
//              integer, meaning that all integers can be converted into reals and that
//              a string type comparison with an integer and a real would return true.
//
//          static method create takes string name, integer extend returns StringType
//              creates a new StringType
//                  name: the name of the StringType
//                  extend: what the new StringType object extends if anything
//
//          method is takes thistype ofType returns boolean
//              Returns a boolean determining whether or not the string type can fit into ofType.
//
//              For example, an integer will always be of type real, 
//              but a real may not always be of type integer.
//
//              StringType(StringType.INTEGER).is(StringType.REAL)
//                  returns true
//              StringType(StringType.REAL).is(StringType.INTEGER)
//                  returns false
//
//      struct StringStack
//          A stack of typed strings.
//
//          static constant string DELIMITER
//              DELIMITER used for parsing. Is set to VAL_DELIMITER.
//
//          readonly StringStack next
//              next node on the stack. 0 is null.
//
//              loop
//                  set node = node.next
//                  exitwhen node == 0
//              endloop
//
//          readonly string value
//              The string's value.
//
//          readonly integer count
//              All nodes after and including the current node.
//
//          readonly StringType type
//              The StringType of the current node.
//
//          method toString takes nothing returns string
//              Converts the string stack into a single string where each value is delimited
//              by the DELIMITER. Works from the current node to the last node.
//
//          method pop takes nothing returns thistype
//              Pops off the current node and returns the next node.
//
//          method destroy takes nothing returns nothing
//              Destroys the StringStack from the current node to the last node.
//
//      struct String
//          static method filter takes string toFilter, string filterChar, boolean onlyAtStart returns string
//              Filters characters out of a string. onlyAtStart is used to only filter characters until
//              it runs into a character other than the filterChar.
//
//          static method parse takes string val returns StringStack
//              Parses a string.
//
//          static method typeof takes string s returns StringType
//              Gets the type of a given string. Only use it on single string values like "123"
////////////////////////////////////////////////////////////////////////
    globals
        private integer stringValueCount = 0
        private string array stringValues
        private integer array stringConvertValue
        private integer array stringValueTypes
        private integer array stringValueLength
        private hashtable stringValueIds = InitHashtable()
        
        private string array stringTypeNames
        private integer stringTypeCount = 5
        private integer array stringTypeExtend
        private boolean array stringTypeParses
        
        private StringStack array stackNext
        private string array stackValue
        private integer array stackCount
        private integer array stackStringType
        private integer stackInstanceCount = 0
        private integer array stackRecycle
        private integer stackRecycleCount = 0
    endglobals
    
    private function FilterCharacter takes string stringToFilter, string char, boolean onlyAtStart returns string
        local integer count = 0
        local integer length = StringLength(stringToFilter)
        local string newString = ""
        local string charCheck
        if (onlyAtStart) then
            loop
                exitwhen SubString(stringToFilter, count, count+1) != char
                set count = count + 1
            endloop
            set newString = SubString(stringToFilter, count, length)
        else
            loop
                exitwhen count == length
                set charCheck = SubString(stringToFilter, count, count+1)
                if (charCheck != char) then
                    set newString = newString + charCheck
                endif
                set count = count + 1
            endloop
        endif
        
        return newString
    endfunction
    
    private function Typeof takes string val returns StringType
        local integer length //length of the string
        local integer length2
        local string char //current character being checked
        local integer curType //current type to be returned
        
        local boolean foundDecimal //found a decimal place
        local boolean foundNeg //found a negative sign
        local boolean foundInt //found an integer
        local boolean escapeOn //escape is on
        local boolean escaping //currently escaping
        
        if (val != null) then
            set char = StringCase(val, false)
            set curType = stringValueCount
            loop
                if (val == stringValues[curType]) then
                    return stringValueTypes[curType]
                endif
                set curType = curType - 1
                exitwhen curType == 0
            endloop
            
            set length = StringLength(val)
            set curType = StringType.ASCII
            if ((length != 3 and length != 6) or SubString(val, 0, 1) != "'" or SubString(val, length-1, length) != "'") then
                if (SubString(val, 0, 1) == "\"") then
                    set curType = StringType.STRING
                    set length2 = 1
                    set escapeOn = false
                    set escaping = false
                    loop
                        if (length2 == length) then
                            return StringType.NULL
                        endif
                        set char = SubString(val, length2, length2+1)
                        if (not escapeOn) then
                            if (char =="\\") then
                                set escapeOn = true
                                set escaping = true
                            else
                                exitwhen char == "\""
                            endif
                        endif
                        
                        if (not escaping) then
                            set escapeOn = false
                        else
                            set escaping = false
                        endif
                        set length2 = length2 + 1
                    endloop
                else
                    set curType = StringType.INTEGER
                    set foundDecimal = false
                    set foundNeg = false
                    set foundInt = false
                    
                    loop
                        exitwhen length == 0
                        set char = SubString(val, length-1, length)
                        if (foundNeg) then
                            return StringType.NULL //no more parsing necessary
                        elseif (char != "0" and char != "1" and char != "2" and char != "3" and char != "4" and char != "5" and char != "6" and char != "7" and char != "8" and char != "9") then
                            if (char == "-" and foundInt) then
                                set foundNeg = true
                            elseif (char == "." and not foundDecimal) then
                                set curType = StringType.REAL
                                set foundDecimal = true
                            else
                                return StringType.NULL
                            endif
                        else
                            set foundInt = true
                        endif
                        set length = length - 1
                    endloop
                endif
            endif
        endif
        
        return curType
    endfunction
    
    struct StringStack extends array
        public static constant string DELIMITER = VAL_DELIMITER
        
        public method operator next takes nothing returns thistype
            return stackNext[this]
        endmethod
        
        public method operator value takes nothing returns string
            return stackValue[this]
        endmethod
        
        public method operator count takes nothing returns integer
            return stackCount[this]
        endmethod
        
        public method operator type takes nothing returns StringType
            return stackStringType[this]
        endmethod
        
        public method toString takes nothing returns string
            local string s = null
            loop
                exitwhen this == 0
                if (stackValue[this] != null and stackValue[this] != DELIMITER and stackValue[this] != "") then
                    if (s == null) then
                        set s = stackValue[this]
                    else
                        set s = s + DELIMITER + stackValue[this]
                    endif
                endif
                set this = stackNext[this]
            endloop
            return s
        endmethod
        
        public method pop takes nothing returns thistype
            set stackRecycle[stackRecycleCount] = this
            set stackRecycleCount = stackRecycleCount + 1
            return stackNext[this]
        endmethod
        
        public method destroy takes nothing returns nothing
            loop
                exitwhen this == 0
                set stackRecycle[stackRecycleCount] = this
                set stackRecycleCount = stackRecycleCount + 1
                set this = stackNext[this]
            endloop
        endmethod
    endstruct
    
    struct String extends array
        public static method filter takes string toFilter, string filterChar, boolean onlyAtStart returns string
            return FilterCharacter(toFilter, filterChar, onlyAtStart)
        endmethod
        
        public static method parse takes string val returns StringStack
            local StringStack this
            local StringStack last
            local integer start
            local integer finish
            local string char
            local integer length
            local boolean found
            
            local boolean escaping
            local boolean escaped
            
            local boolean foundDecimal
            local boolean foundNeg
            local boolean foundInt
            
            local integer totalCount = 0
            
            local integer tyepCheck
            
            local integer length2
            
            local StringType curType
            
            if (val != null and val != "") then
                set this = 0
                set last = 0
                set length = StringLength(val)
                set finish = 0
                loop
                    set found = false
                    set curType = -1
                    loop
                        set finish = finish + 1
                        set char = SubString(val,finish-1, finish)
                        if (char != StringStack.DELIMITER) then
                            set start = finish-1
                            set found = true
                        endif
                        exitwhen found or finish == length
                    endloop
                    
                    exitwhen not found
                    
                    if (char == "\"" and length-finish > 0) then
                        set escaped = false
                        set escaping = false
                        loop
                            set finish = finish + 1
                            set char = SubString(val, finish-1, finish)
                            
                            if (not escaped) then
                                if (char == "\"") then
                                    set curType = StringType.STRING
                                    exitwhen true
                                elseif (char == "\\") then
                                    set val = SubString(val, 0, finish-1)+SubString(val, finish, length)
                                    set length = length - 1
                                    set finish = finish - 1
                                    if (finish == start) then
                                        set start = start - 1
                                    endif
                                    set escaped = true
                                    set escaping = true
                                endif
                            endif
                            
                            if (not escaping) then
                                set escaped = false
                            else
                                set escaping = false
                            endif
                            exitwhen finish == length
                        endloop
                        if (curType == -1) then
                            set curType = 0
                        endif
                    elseif (char == "'") then
                        if (length-finish > 4 and SubString(val, finish+4, finish+5) == "'") then
                            set finish = finish + 5
                            set curType = StringType.ASCII
                        elseif (length-finish > 1 and SubString(val, finish+1, finish+2) == "'") then
                            set finish = finish + 2
                            set curType = StringType.ASCII
                        endif
                        if (curType == -1) then
                            set curType = 0
                        endif
                    else
                        loop
                            exitwhen finish == length or char == StringStack.DELIMITER
                            set finish = finish + 1
                            set char = SubString(val, finish-1, finish)
                        endloop
                        if (char == StringStack.DELIMITER) then
                            set finish = finish - 1
                        endif
                    endif
                    
                    if (stackRecycleCount != 0) then
                        set stackRecycleCount = stackRecycleCount - 1
                        set this = stackRecycle[stackRecycleCount]
                    else
                        set stackInstanceCount = stackInstanceCount + 1
                        set this = stackInstanceCount
                    endif
                    
                    set totalCount = totalCount + 1
                    set stackNext[last] = this
                    set last = this
                    
                    set stackValue[this] = SubString(val, start, finish)
                    
                    if (curType == -1) then
                        set char = StringCase(stackValue[this], false)
                        set curType = stringValueCount
                        loop
                            exitwhen stackValue[this] == stringValues[curType] or curType == 0
                            set curType = curType - 1
                        endloop
                        if (curType != 0) then
                            set stackStringType[this] = stringValueTypes[curType]
                        else //parse number
                            set curType = StringType.INTEGER
                            set foundDecimal = false
                            set foundNeg = false
                            set foundInt = false
                            set length2 = finish
                            
                            loop
                                exitwhen length2 == start
                                set char = SubString(val, length2-1, length2)
                                if (foundNeg) then
                                    set curType = StringType.NULL
                                    exitwhen true
                                elseif (char != "0" and char != "1" and char != "2" and char != "3" and char != "4" and char != "5" and char != "6" and char != "7" and char != "8" and char != "9") then
                                    if (char == "-" and foundInt) then
                                        set foundNeg = true
                                    elseif (char == "." and not foundDecimal) then
                                        set curType = StringType.REAL
                                        set foundDecimal = true
                                    else
                                        set curType = StringType.NULL
                                        exitwhen true
                                    endif
                                else
                                    set foundInt = true
                                endif
                                set length2 = length2 - 1
                            endloop
                            set stackStringType[this] = curType
                        endif
                    else
                        set stackStringType[this] = curType
                    endif
                    
                    if (stackStringType[this] == StringType.ASCII or stackStringType[this] == StringType.STRING) then
                        set stackValue[this] = SubString(stackValue[this], 1, StringLength(stackValue[this])-1)
                    endif
                    
                    exitwhen finish == length
                endloop
                
                set stackNext[last] = 0
                set this = stackNext[0]
                loop
                    exitwhen this == 0
                    set stackCount[this] = totalCount
                    set totalCount = totalCount - 1
                    set this = stackNext[this]
                endloop
                return stackNext[0]
            endif
            
            return 0
        endmethod
        
        public static method typeof takes string s returns StringType
            return Typeof(s)
        endmethod
    endstruct
    
    //string to boolean
    function S2B takes string s returns boolean
        return stringConvertValue[LoadInteger(stringValueIds, StringHash(s), 0)] > 0
    endfunction
    
    //boolean to string
    function B2S takes boolean val returns string
        if (val) then
            return stringValues[1]
        endif
        return stringValues[2]
    endfunction
    
    //ascii to string
    function A2S takes integer val returns string
        local string ascii = ""
        loop
            exitwhen val == 0
            set ascii = ascii + Ascii2Char(val - val/128*128)
            set val = val / 128
        endloop
        
        return ascii
    endfunction
    
    //string to ascii
    function S2A takes string val returns integer
        local integer i = 0
        local integer digit
        if (val != null) then
            set digit = StringLength(val)
            loop
                exitwhen digit == 0
                set digit = digit - 1
                set i = i * 128 + Char2Ascii(SubString(val, digit, digit+1))
            endloop
        endif
        
        return i
    endfunction
    
    struct StringValue extends array
        public static method create takes string value, StringType valueType, integer convertedValue returns thistype
            local integer id = StringHash(value)
            if (not stringTypeParses[valueType] and not HaveSavedInteger(stringValueIds, id, 0)) then
                set stringValueCount = stringValueCount + 1
                set stringValues[stringValueCount] = value
                set stringValueTypes[stringValueCount] = valueType
                set stringValueLength[stringValueCount] = StringLength(value)
                set stringConvertValue[stringValueCount] = convertedValue
                call SaveInteger(stringValueIds, id, 0, stringValueCount)
                return stringValueCount
            endif
            return 0
        endmethod
        
        public static method operator [] takes string s returns thistype
            return LoadInteger(stringValueIds, StringHash(s), 0)
        endmethod
        
        public method operator boolean takes nothing returns boolean
            return stringConvertValue[this] > 0
        endmethod
        
        public method operator integer takes nothing returns integer
            return stringConvertValue[this]
        endmethod
        
        public method operator string takes nothing returns string
            return stringValues[this]
        endmethod
        
        public method operator type takes nothing returns StringType
            return stringValueTypes[this]
        endmethod
    endstruct

    struct StringType extends array
        public static constant integer NULL = 0
        public static constant integer BOOLEAN = 1
        public static constant integer ASCII = 2
        public static constant integer INTEGER = 3
        public static constant integer REAL = 4
        public static constant integer STRING = 5
        
        public static method create takes string name, integer extend returns thistype
            set stringTypeCount = stringTypeCount + 1
            set stringTypeNames[stringTypeCount] = name
            set stringTypeExtend[stringTypeCount] = extend
            loop
                exitwhen extend == 0
                call SaveBoolean(stringValueIds, extend, stringTypeCount, true)
                set extend = stringTypeExtend[extend]
            endloop
            return stringTypeCount
        endmethod
        
        public method operator name takes nothing returns string
            return stringTypeNames[this]
        endmethod
        
        public method operator extends takes nothing returns integer
            return stringTypeExtend[this]
        endmethod
        
        public method is takes thistype ofType returns boolean
            return this == ofType or ofType == STRING or LoadBoolean(stringValueIds, this, ofType)
        endmethod
        
        private static method onInit takes nothing returns nothing
            set stringTypeNames[NULL] = "null"
            set stringTypeNames[BOOLEAN] = "boolean"
            set stringTypeNames[ASCII] = "ascii"
            set stringTypeNames[INTEGER] = "integer"
            set stringTypeNames[REAL] = "real"
            set stringTypeNames[STRING] = "string"
            
            set stringTypeParses[INTEGER] = true
            set stringTypeParses[REAL] = true
            set stringTypeParses[STRING] = true
            
            set stringValueCount = 4
            set stringValues[1] = "true"
            set stringValues[2] = "false"
            set stringValues[3] = "on"
            set stringValues[4] = "off"
            call SaveInteger(stringValueIds, StringHash("true"), 0, 1)
            call SaveInteger(stringValueIds, StringHash("false"), 0, 2)
            call SaveInteger(stringValueIds, StringHash("on"), 0, 3)
            call SaveInteger(stringValueIds, StringHash("off"), 0, 4)
            set stringValueTypes[1] = BOOLEAN
            set stringValueTypes[2] = BOOLEAN
            set stringValueTypes[3] = BOOLEAN
            set stringValueTypes[4] = BOOLEAN
            set stringValueLength[1] = 4
            set stringValueLength[2] = 5
            set stringValueLength[3] = 2
            set stringValueLength[4] = 3
            set stringConvertValue[1] = 1
            set stringConvertValue[2] = 0
            set stringConvertValue[3] = 1
            set stringConvertValue[4] = 0
            
            set stringTypeExtend[REAL] = INTEGER
            call SaveBoolean(stringValueIds, INTEGER, REAL, true)
        endmethod
    endstruct
endlibrary