library MnT requires ListModule, locust, TerrainGlobals, IStartable

globals
	private constant integer MAX_VALID_TARGET_ATTEMPTS = 20

	//how long to wait between firing each mortar... must be synced with object editor to prevent multiple shots
    private constant real MnTTimeStep = 2.2
    //timer used for all MnT pairs
    private timer MnTTimer = CreateTimer()
    //the target cannot be placed on this terrain type
    private constant integer IllegalTerrainType = ABYSS
	
	private constant boolean DEBUG_VALID_TARGET = false
endglobals

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                          Mortar And Target Struct
//                              by Serenity09
//                            Clan TMMM US East
//
// Purpose: Creates a mortar and target pair that is easy to keep track of.
// Consolidates all code into creating the pair and then periodically calling
// MnTActions in order to randomly move the target within the confines and order
// the Mortar to attack it.
//
// To create: create a way to reference the mortar/target pair after creation (such as a global variable)
// Instantiate the struct using .create()
// Ex. local MortarNTarget lvl2Mortar = MortarNTarget.create(int <mortarID>, int <targetID>, player <playerID>, rect <mortarrect>, rect <targetrect>)
// mortarID is the integer data value for the unit to be used as the mortar
// targetID is the integer data value for the unit to be used as the target
// playerID is who will own the mortar and target
// mortarrect is the rect in which the mortar will be created
// targetrect is the boundaries within which the target will randomly move (teleport style)
//
// To issue the standard MnTActions to that mortar just call MnTActions on it
// Ex. call lvl2Mortar.MnTActions()
//
// Unlike wispwheels, you should destroy mortars when not in use (mortars dont use hashes)
// When you destroy a mortar/target with .destroy(), .onDestroy() will automatically be called
// .onDestroy() removes the mortar/target and nulls the unit member variables for that instance.
/////////////////////////////////////////////////////////////////////////////////////////////////////////////

//dear god why did i abbreviate "And" to "N"
struct MortarNTarget extends IStartable
    //member variables
    readonly unit Mortar
    readonly unit Target
    
    private real minX
    private real maxX
    private real minY
    private real maxY
    
    implement List
        
    public method MnTActions takes nothing returns nothing
        local real newX
        local real newY
		
		local integer attempt = 0
        
        loop
			set attempt = attempt + 1
            set newX = GetRandomReal(this.minX, this.maxX)
            set newY = GetRandomReal(this.minY, this.maxY)
            
            exitwhen GetTerrainType(newX, newY) != IllegalTerrainType or attempt == MAX_VALID_TARGET_ATTEMPTS
        endloop
		
		static if DEBUG_VALID_TARGET then
			call DisplayTextToForce(bj_FORCE_PLAYER[0], "Valid target loop took " + I2S(attempt) + " iterations")
		endif
		
        //move the target randomly within its given boundaries
        call SetUnitX(Target, newX)
        call SetUnitY(Target, newY)
        
        //order the mortar to attack the target
        call IssuePointOrder(this.Mortar, "attackground", GetUnitX(this.Target), GetUnitY(this.Target))
    endmethod
    
    /*
    private method MnTCreateWheel takes unit center, player owner, integer unitID, integer numspoke, integer spokel, real degbet, real distbet, real angvel returns nothing
        local SimpleWheel newWheel = SimpleWheel.create(center, owner, unitID, numspoke, spokel, degbet, distbet, angvel)
        call UnitRemoveAbility(center, 'Apiv')
        call DestroyTrigger(GetTriggeringTrigger())
    endmethod
    
    public method MnTWispShot takes player owner, integer unitID, integer numspoke, integer spokel, real degbet, real distbet, real angvel returns nothing
        local unit u
        local trigger onProjLand = CreateTrigger()
        
        call SetUnitX(Target, GetRandomReal(this.minX, this.maxX))
        call SetUnitY(Target, GetRandomReal(this.minY, this.maxY))
        
        set u = CreateUnit(owner, unitID, GetUnitX(this.Target), GetUnitY(this.Target), 0)
        call UnitAddAbility(u, 'Apiv')
        
        call TriggerRegisterUnitEvent(onProjLand, u, EVENT_UNIT_DEATH)
        call TriggerAddAction(onProjLand, function MnTCreateWheel(u, owner, unitID, numspoke, spokel, degbet, distbet, angvel))
        
        set onProjLand = null
        set u = null
    endmethod
    */
    
    private static method MnTPeriodic takes nothing returns nothing
        //use of thistype because it might not be called by a simple wheel
        local MortarNTarget e = .first
        
        loop
        exitwhen e == 0
            call e.MnTActions()
            set e = e.next
        endloop
    endmethod
    
    public method Start takes nothing returns nothing
        if .count == 0 then
            call TimerStart(MnTTimer, MnTTimeStep, true, function MortarNTarget.MnTPeriodic)
        endif
        call .listAdd()
    endmethod
    
    public method Stop takes nothing returns nothing
        call IssueImmediateOrder(Mortar, "stop")
        call .listRemove()
        if .count == 0 then
            call PauseTimer(MnTTimer)
        endif
    endmethod

        
    method onDestroy takes nothing returns nothing
        //runs when MortarNTarget.destroy() is called
        call RemoveUnit(Mortar)
        call RemoveUnit(Target)
        
        call .listRemove()
        if .count == 0 then
            call PauseTimer(MnTTimer)
        endif
        
        set Mortar = null
        set Target = null
    endmethod
    
    static method create takes integer mortarID, integer targetID, player playerID, rect mortarloc, rect targetrect returns MortarNTarget
        //allocate memory for the mortar and target
        local MortarNTarget new = MortarNTarget.allocate()
        //create the mortar and target
        set new.Mortar = CreateUnit(playerID, mortarID, GetRectCenterX(mortarloc), GetRectCenterY(mortarloc), 0)
        set new.Target = CreateUnit(playerID, targetID, GetRectCenterX(targetrect), GetRectCenterY(targetrect), 0)
        
        call AddUnitLocust(new.Mortar)
        call AddUnitLocust(new.Target)
        
        set new.minX = GetRectMinX(targetrect)
        set new.maxX = GetRectMaxX(targetrect)
        set new.minY = GetRectMinY(targetrect)
        set new.maxY = GetRectMaxY(targetrect)
        
        return new
    endmethod
endstruct

endlibrary