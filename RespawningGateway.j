library RespawningGateway requires RespawningUnit
globals
	private constant real ACTIVATION_CHECK_TIMESTEP = .2
	private constant real REPSAWN_TEXTTAG_VERTICAL_OFFSET = 128.
	private constant real RESPAWN_TEXTTAG_FONT_SIZE = 24.
endglobals


struct RespawningGateway extends IStartable
	private integer WallUnitID
	private unit WallUnit
	private RespawningUnit WallRespawnData
	
	private rect ActivationArea
	private destructable ActivationDoodad
	
	private integer RespawnTime 	//in seconds
	private integer RespawnTimeRemaining		//in seconds
	private texttag RespawnTimeTag
	
	private static SimpleList_List ActiveGateways
	private static timer ActiveGatewayTimer
	
	//keeps respawn update interval consistent throughout respawn timeout
	public method operator RespawnTimeout takes nothing returns integer
		if .RespawnTime >= 180 then
			return 60
		elseif .RespawnTime >= 60 then
			return 30
		elseif .RespawnTime >= 30 then
			return 15
		elseif .RespawnTime >= 15 then
			return 5
		else
			return 1
		endif
	endmethod
	
	private method UpdateTimeRemainingDisplay takes nothing returns nothing
		local string timeTagLabel
		
		if .RespawnTimeRemaining == .RespawnTimeout then
			call SetTextTagColor(.RespawnTimeTag, 255, 0, 0, 1)
		endif
		
		if .RespawnTimeRemaining >= 60 then
			set timeTagLabel = I2S(R2I(.RespawnTimeRemaining / 60.)) + " minute"
			
			if R2I(.RespawnTimeRemaining / 60.) != 60 then
				set timeTagLabel = timeTagLabel + "s"
			endif
		else
			set timeTagLabel = I2S(.RespawnTimeRemaining) + " second"
			
			if .RespawnTimeRemaining != 1 then
				set timeTagLabel = timeTagLabel + "s"
			endif
		endif
		
		call SetTextTagText(.RespawnTimeTag, timeTagLabel, TextTagSize2Height(RESPAWN_TEXTTAG_FONT_SIZE))
	endmethod
	
	private static method OnGatewayRespawnTick takes nothing returns nothing
		local timer t = GetExpiredTimer()
		local thistype gateway = GetTimerData(t)
		
		set gateway.RespawnTimeRemaining = gateway.RespawnTimeRemaining - gateway.RespawnTimeout
		call gateway.UpdateTimeRemainingDisplay()
		
		if gateway.RespawnTimeRemaining == 0 then
			set gateway.WallUnit = gateway.WallRespawnData.respawn()
			call gateway.WallRespawnData.destroy()
			set gateway.WallRespawnData = 0
			
			call DestructableRestoreLife(gateway.ActivationDoodad, GetDestructableMaxLife(gateway.ActivationDoodad), true)
			
			call DestroyTextTag(gateway.RespawnTimeTag)
			set gateway.RespawnTimeTag = null
			
			call ReleaseTimer(t)
		endif
		
		set t = null
	endmethod
	
	private static method CheckActiveGateways takes nothing returns nothing
		local SimpleList_ListNode curGateway = thistype.ActiveGateways.first
		local SimpleList_ListNode curTeam
		local SimpleList_ListNode curUser
		
		loop
		exitwhen curGateway == 0
			//only check gateways that are still alive
			if thistype(curGateway.value).WallUnit != null then
				set curTeam = thistype(curGateway.value).ParentLevel.ActiveTeams.first
						
				loop
				exitwhen curTeam == 0
					//call DisplayTextToForce(bj_FORCE_PLAYER[0], "Checking team " + I2S(curTeam.value))
					set curUser = Teams_MazingTeam(curTeam.value).Users.first
											
					loop
					exitwhen curUser == 0
						//recheck that the gateway is still alive, in case two users simultaneously destroy the same gateway
						if RectContainsCoords(thistype(curGateway.value).ActivationArea, GetUnitX(User(curUser.value).ActiveUnit), GetUnitY(User(curUser.value).ActiveUnit)) and thistype(curGateway.value).WallUnit != null then
							call CreateInstantSpecialEffect("Abilities\\Spells\\Demon\\DarkPortal\\DarkPortalTarget.mdl", GetUnitX(thistype(curGateway.value).WallUnit), GetUnitY(thistype(curGateway.value).WallUnit), Player(curUser.value))
							
							set thistype(curGateway.value).WallRespawnData = RespawningUnit.create(GetUnitX(thistype(curGateway.value).WallUnit), GetUnitY(thistype(curGateway.value).WallUnit), thistype(curGateway.value).WallUnitID, GetUnitFacing(thistype(curGateway.value).WallUnit))
							call Recycle_ReleaseUnit(thistype(curGateway.value).WallUnit)
							set thistype(curGateway.value).WallUnit = null
							
							call KillDestructable(thistype(curGateway.value).ActivationDoodad)
							
							set thistype(curGateway.value).RespawnTimeRemaining = thistype(curGateway.value).RespawnTime
							set thistype(curGateway.value).RespawnTimeTag = CreateTextTag()
							call SetTextTagPos(thistype(curGateway.value).RespawnTimeTag, GetRectCenterX(thistype(curGateway.value).ActivationArea), GetRectCenterY(thistype(curGateway.value).ActivationArea) + REPSAWN_TEXTTAG_VERTICAL_OFFSET, 0)
							call SetTextTagPermanent(thistype(curGateway.value).RespawnTimeTag, true)
							call SetTextTagColor(thistype(curGateway.value).RespawnTimeTag, 255, 255, 255, 1)
							call SetTextTagVisibility(thistype(curGateway.value).RespawnTimeTag, true)
							
							call thistype(curGateway.value).UpdateTimeRemainingDisplay()
							
							call TimerStart(NewTimerEx(curGateway.value), thistype(curGateway.value).RespawnTimeout, true, function thistype.OnGatewayRespawnTick)
						endif
					set curUser = curUser.next
					endloop
					
				set curTeam = curTeam.next
				endloop
			endif
		set curGateway = curGateway.next
		endloop
	endmethod
	
	public method Stop takes nothing returns nothing
		call thistype.ActiveGateways.remove(this)
		if thistype.ActiveGateways.count == 0 then
			call PauseTimer(thistype.ActiveGatewayTimer)
		endif
	endmethod
	public method Start takes nothing returns nothing
		if thistype.ActiveGateways.count == 0 then
			call TimerStart(thistype.ActiveGatewayTimer, ACTIVATION_CHECK_TIMESTEP, true, function thistype.CheckActiveGateways)
		endif
		call thistype.ActiveGateways.add(this)
				
		if .RespawnTimeRemaining > 0 then
			call .UpdateTimeRemainingDisplay()
		endif
	endmethod
	
	public static method create takes integer wallUnitID, real wallX, real wallY, real activationX, real activationY, integer respawnTime returns thistype
		local thistype new = thistype.allocate()
		
		set new.WallUnitID = wallUnitID
		set new.WallUnit = Recycle_MakeUnit(wallUnitID, wallX, wallY)
		
		set new.ActivationArea = Rect(activationX - FOOT_SWITCH_SIZE, activationY - FOOT_SWITCH_SIZE, activationX + FOOT_SWITCH_SIZE, activationY + FOOT_SWITCH_SIZE)
		set new.ActivationDoodad = CreateDestructable(FOOT_SWITCH, activationX, activationY, 270., 1., 0)
		
		//set respawn time to the nearest number of update intervals for raw respawn time
		set new.RespawnTime = respawnTime
		set new.RespawnTime = (new.RespawnTime / new.RespawnTimeout) * new.RespawnTimeout
		
		return new
	endmethod
	public static method CreateFromVectors takes integer wallUnitID, vector2 wallPosition, vector2 activationPosition, integer respawnTime returns thistype
		return thistype.create(wallUnitID, wallPosition.x, wallPosition.y, activationPosition.x, activationPosition.y, respawnTime)
	endmethod
	
	private static method onInit takes nothing returns nothing
		set thistype.ActiveGateways = SimpleList_List.create()
		set thistype.ActiveGatewayTimer = CreateTimer()
	endmethod
endstruct
endlibrary