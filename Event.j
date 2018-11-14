library Event /* v2.0.0.1
************************************************************************************
*
*   Functions
*
*       function CreateEvent takes nothing returns integer
*       function TriggerRegisterEvent takes trigger t, integer ev returns nothing
*
************************************************************************************
*
*       struct Event extends array
*
*           static method create takes nothing returns thistype
*           method registerTrigger takes trigger t returns nothing
*           method register takes boolexpr c returns nothing
*           method fire takes nothing returns nothing
*
************************************************************************************/
    globals
        private real q=0        
    endglobals
    struct Event extends array
        private static integer w=0
        private static trigger array e
        static method create takes nothing returns thistype
            set w=w+1
            set e[w]=CreateTrigger()
            return w
        endmethod
        method registerTrigger takes trigger t returns nothing
            call TriggerRegisterVariableEvent(t,SCOPE_PRIVATE+"q",EQUAL,this)
        endmethod
        method register takes boolexpr c returns nothing
            call TriggerAddCondition(e[this],c)
        endmethod
        method fire takes nothing returns nothing
            set q=0
            set q=this
            call TriggerEvaluate(e[this])
        endmethod
    endstruct
endlibrary
