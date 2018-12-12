//TESH.scrollpos=21
//TESH.alwaysfold=0
library DemoCommands initializer init uses Cmd

globals
    StringType commandStr
    StringType shellStr
endglobals

struct Demo extends array
    private static constant string SHELL_NAME = "parser"
    private static constant boolean AUTO_ACCESS = true
    
    private static method run takes player caller, integer callerId, string args returns nothing
        local StringStack stack = String.parse(args)
        local StringType stringType
        local boolean b
        local integer a
        local integer i
        local real r
        local string s
        
        local string bs
        local string as
        local string is
        local string rs
        local string ss
        
        call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, GetPlayerName(caller)+"("+I2S(callerId)+") inputted\n              " + stack.toString())
        if (stack.count == 1 and stack.value == "?") then
            call DisplayTextToPlayer(caller, 0, 0, "This command parses a string and displays all of the arguments inputted as well as all of their possible types\nsimply type random stuff in to see it work")
        else
            loop
                exitwhen stack == 0
                set stringType = stack.type
                
                if (stringType.is(StringType.NULL)) then
                    set s = stack.value
                    call DisplayTextToPlayer(caller, 0, 0, stringType.name + " as null: " + s)
                endif
                if (stringType.is(StringType.BOOLEAN)) then
                    set b = S2B(stack.value)
                    set bs = B2S(b)
                    call DisplayTextToPlayer(caller, 0, 0, stringType.name + " as boolean: " + bs)
                endif
                if (stringType.is(StringType.ASCII)) then
                    set a = S2A(stack.value)
                    set as = A2S(a)
                    call DisplayTextToPlayer(caller, 0, 0, stringType.name + " as ascii: " + as)
                endif
                if (stringType.is(StringType.INTEGER)) then
                    set i = S2I(stack.value)
                    set is = I2S(i)
                    call DisplayTextToPlayer(caller, 0, 0, stringType.name + " as integer: " + is)
                endif
                if (stringType.is(StringType.REAL)) then
                    set r = S2R(stack.value)
                    set rs = R2S(r)
                    call DisplayTextToPlayer(caller, 0, 0, stringType.name + " as real: " + rs)
                endif
                if (stringType.is(StringType.STRING)) then
                    call DisplayTextToPlayer(caller, 0, 0, stringType.name + " as string: " + stack.value)
                endif
                
                set stack = stack.pop()
            endloop
        endif
    endmethod
    
    implement Shell
endstruct

struct SetAccess extends array
    public static constant string COMMAND_NAME = "access"
    public static constant boolean AUTO_ENABLE = true
    public static constant boolean AUTO_ACCESS = true
    public static constant integer MIN_ARGS = 1
    public static constant integer MAX_ARGS = 3
    
    private static method run takes player caller, integer callerId, Args args returns nothing
        local boolean enable
        local integer for
        local integer command
        local integer shell = -1
        
        if (args.count == 1 and args.value == "?") then
            call DisplayTextToPlayer(caller, 0, 0, "sets a player's access to a command\nCommand command, integer playerId, boolean enable")
        elseif (args.count == 3) then
            if (args.type.is(commandStr)) then
                set shell = 0
            elseif (args.type.is(shellStr)) then
                set shell = 1
            endif
            
            if (shell != -1) then
                set command = StringValue[args.value].integer
                set args = args.next
                if (args.type.is(StringType.INTEGER)) then
                    set for = S2I(args.value)
                    set args = args.next
                    if (args.type.is(StringType.BOOLEAN)) then
                        set enable = StringValue[args.value].boolean
                        
                        if (shell == 0) then
                            if (command == 1) then
                                set SetAccess[for] = enable
                            elseif (command == 2) then
                                set Enable[for] = enable
                            endif
                        else
                            if (command == 1) then
                                set Demo[for] = enable
                            endif
                        endif
                    endif
                endif
            endif
        endif
    endmethod
    
    implement Command
endstruct

struct Enable extends array
    private static delegate SetAccess default = 0
    
    public static constant string COMMAND_NAME = "enable"
    public static constant integer MIN_ARGS = 1
    public static constant integer MAX_ARGS = 2
    
    private static method run takes player caller, integer callerId, Args args returns nothing
        local boolean enable
        local integer command
        if (args.count == 1 and args.value == "?") then
            call DisplayTextToPlayer(caller, 0, 0, "enables/disables a command\nCommand command boolean enable")
        elseif (args.count == 2 and args.type.is(commandStr)) then
            set command = StringValue[args.value].integer
            set args = args.next
            if (args.type.is(StringType.BOOLEAN)) then
                set enable = StringValue[args.value].boolean
                
                if (command == 1) then
                    set SetAccess.enabled = enable
                elseif (command == 2) then
                    set Enable.enabled = enable
                endif
            endif
        endif
    endmethod
    
    implement Command
endstruct

private function init takes nothing returns nothing
    set commandStr = StringType.create("command", 0)
    set shellStr = StringType.create("shell", 0)
    call StringValue.create("parser", shellStr, 1)
    call StringValue.create("access", commandStr, 1)
    call StringValue.create("enable", commandStr, 2)
    
    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 90000, "type - to display all commands\ntype # to display all shells\ntype #- to display or change current shell. Typing non existing shell clears out current shell\ntype -command to execute command\ntype !- to execute shell")
endfunction

endlibrary