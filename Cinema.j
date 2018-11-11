library Cinema requires User, SimpleList, Alloc

globals
    //amount of time before the message should start fading
    //WC3 implements a positive buffer of about 3 seconds under the hood of this function
    //probably should not cause a negative result -- see the shortest message time in GameStart
    constant real MESSAGE_ALIVE_BUFFER = -2.
    constant real CONVERSATION_BUFFER = 2.
endglobals

function interface CinemaUserConditional takes User user returns boolean
function interface CinemaUserCallback takes User user returns nothing

//allows a single integer ID to lookup fields for the cinema's callback function (which only gives you a single int to work with)
struct CinemaCallbackModel extends array
    public Cinematic Cinematic
    public SimpleList_ListNode CurrentMessage
    public User User
    
    implement Alloc
    
    public static method create takes Cinematic cinematic, SimpleList_ListNode currentMessage, User user returns thistype
        local thistype new = thistype.allocate()
        
        set new.Cinematic = cinematic
        set new.CurrentMessage = currentMessage
        set new.User = user
        
        return new
    endmethod
endstruct

struct CinemaMessage extends array
    public unit Source
    public string Text
    public real Time
        
    implement Alloc
    
    public static method create takes unit source, string text, real time returns thistype
        local thistype new = thistype.allocate()
        
        set new.Source = source
        set new.Text = text
        set new.Time = time
        
        return new
    endmethod
endstruct

struct Cinematic extends array
    public rect ActivationArea
    public CinemaUserConditional ActivationCondition
    public boolean Individual
    public boolean PauseViewers
    public SimpleList_List PreviousViewers
    public SimpleList_List CinemaMessages
    
    //public CinemaUserCallback OnCinemaStart
    public CinemaUserCallback OnCinemaEnd
    
    implement Alloc
    
    public method HasUserViewed takes User user returns boolean
        local SimpleList_ListNode cur = .PreviousViewers.first
        
        loop
        exitwhen cur == 0
            if cur.value == user then
                return true
            endif
        set cur = cur.next
        endloop
        
        return false
    endmethod
    
    public method AddMessage takes unit u, string text, real timeout returns nothing
        call .CinemaMessages.addEnd(CinemaMessage.create(u, text, timeout))
    endmethod
    
    private static method PlayMessageCallback takes nothing returns nothing
        local timer t = GetExpiredTimer()
        local CinemaCallbackModel cinemaCBModel = GetTimerData(t)
        local real messageTime
        
        if cinemaCBModel.CurrentMessage == 0 then
            call DisplayTextToForce(bj_FORCE_PLAYER[0], "No more messages for CB Model " + I2S(cinemaCBModel))

            if cinemaCBModel.Cinematic.PauseViewers then
                call cinemaCBModel.User.Pause(false)
            endif
            
            call ReleaseTimer(t)
            
            if cinemaCBModel.Cinematic.OnCinemaEnd != 0 then
                call DisplayTextToForce(bj_FORCE_PLAYER[0], "Calling on end CB for user " + I2S(cinemaCBModel.User))
                call cinemaCBModel.Cinematic.OnCinemaEnd.evaluate(cinemaCBModel.User)
            endif
            
            //reached last message in cinematic, recycle CB object and release viewers
            call cinemaCBModel.deallocate()
        else
            set messageTime = CinemaMessage(cinemaCBModel.CurrentMessage.value).Time
            call cinemaCBModel.User.DisplayMessage(CinemaMessage(cinemaCBModel.CurrentMessage.value).Text, messageTime + MESSAGE_ALIVE_BUFFER)
            
            //finished current message in cinematic but there's still more
            set cinemaCBModel.CurrentMessage = cinemaCBModel.CurrentMessage.next
            //call SetTimerData(t, cinemaCBModel) //re-using same model, so original ID attached to timer is still applicable
            
            //if this is the very last message give an extra buffer after it (to offset any following conversations)
            if cinemaCBModel.CurrentMessage == 0 then
                set messageTime = messageTime + CONVERSATION_BUFFER
            endif
            
            call TimerStart(t, messageTime, false, function thistype.PlayMessageCallback)
        endif
        
        set t = null
    endmethod
    
    public method CanUserActivate takes User user returns boolean
        return not .HasUserViewed(user) and user.IsActiveUnitInRect(.ActivationArea) and (.ActivationCondition == 0 or .ActivationCondition.evaluate(user))
    endmethod
    
    public method Activate takes User user returns nothing
        local CinemaCallbackModel cbModel = CinemaCallbackModel.create(this, .CinemaMessages.first, user)
        local timer t = NewTimerEx(cbModel)
        
        if .PauseViewers then
            call user.Pause(true)
        endif
        
        /*
        if .OnCinemaStart != 0 then
            call .OnCinemaStart.evaluate(user)
        endif
        */
        
        call TimerStart(t, .0, false, function thistype.PlayMessageCallback)
        set t = null
    endmethod
    
    public static method create takes rect activationArea, boolean individual, boolean pause, CinemaMessage firstMessage returns thistype
        local thistype new = thistype.allocate()
        
        set new.ActivationArea = activationArea
        set new.Individual = individual
        set new.PauseViewers = pause
        
        set new.ActivationCondition = 0
        //set new.OnCinemaStart = 0
        set new.OnCinemaEnd = 0
        
        set new.PreviousViewers = SimpleList_List.create()
        set new.CinemaMessages = SimpleList_List.create()
        
        call new.CinemaMessages.add(firstMessage)
        
        return new
    endmethod
endstruct

endlibrary