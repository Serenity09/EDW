library ZoomChange requires IStartable, User, Alloc, SimpleList, HandleList, Teams
	globals
		private constant real TIMESTEP = 1.
		private constant real TRANSITION_TIME = .5
		private constant real TRANSITION_BUFFER = TERRAIN_TILE_SIZE * 2.
		
		constant real NEAR_CAMERA_DISTANCE = 1250.
		constant real VANILLA_CAMERA_DISTANCE = 1650.
		constant real DEFAULT_3D_CAMERA_DISTANCE = 1850.
		constant real FAR_CAMERA_DISTANCE = 2250.
	endglobals
	
	private struct UserChangeData extends array
		public User User
		public real OriginalCameraDistance
		
		implement Alloc
	endstruct
	
	struct ZoomChange extends IStartable
		private RectList Boundaries
		public real CameraDistance
		public SimpleList_List ActiveUserData
		
		private static SimpleList_List Active
		private static timer Timer
		
		public method AddBoundary takes rect area returns nothing
			call .Boundaries.addEnd(area)
		endmethod
		
		public method GetUser takes User user returns UserChangeData
			local SimpleList_ListNode curActiveUserData = ActiveUserData.first
			
			loop
			exitwhen curActiveUserData == 0
				if UserChangeData(curActiveUserData.value).User == user then
					return curActiveUserData.value
				endif
			set curActiveUserData = curActiveUserData.next
			endloop
			
			return 0
		endmethod
		public method AddUser takes User user returns nothing
			//store original data
			local UserChangeData data = UserChangeData.allocate()
			
			set data.User = user
			set data.OriginalCameraDistance = CameraSetupGetField(DefaultCamera[user], CAMERA_FIELD_TARGET_DISTANCE)
			
			call .ActiveUserData.addEnd(data)
			
			//change user's camera to new zoom level
			call CameraSetupSetField(DefaultCamera[user], CAMERA_FIELD_TARGET_DISTANCE, this.CameraDistance, TRANSITION_TIME)
			
			//immediately update user's camera
			// call data.User.CheckDefaultCameraZoom()
			call CameraSetupApplyForceDuration(DefaultCamera[data.User], false, TRANSITION_TIME)
		endmethod
		public method RemoveUser takes UserChangeData data returns nothing
			//reset user's camera to original zoom level
			call CameraSetupSetField(DefaultCamera[data.User], CAMERA_FIELD_TARGET_DISTANCE, data.OriginalCameraDistance, TRANSITION_TIME)
			
			//immediately update user's camera
			// call data.User.CheckDefaultCameraZoom()
			call CameraSetupApplyForceDuration(DefaultCamera[data.User], false, TRANSITION_TIME)
			
			call .ActiveUserData.remove(data)
			call data.deallocate()
		endmethod
		
		private method PeriodicCheck takes nothing returns nothing
			local SimpleList_ListNode curTeam = .ParentLevel.ActiveTeams.first
			local SimpleList_ListNode curUser
			
			local UserChangeData userData
			
			local integer iBoundaryRect
			local rect boundaryRect
			local boolean inBoundary
			
			loop
			exitwhen curTeam == 0
				set curUser = Teams_MazingTeam(curTeam.value).FirstUser
				
				loop
				exitwhen curUser == 0
					set userData = .GetUser(curUser.value)
					
					if User(curUser.value).GameMode == Teams_GAMEMODE_STANDARD or User(curUser.value).GameMode == Teams_GAMEMODE_STANDARD_PAUSED then						
						//check if current user is in any of this vision modifier's rects
						set iBoundaryRect = 0
						set inBoundary = false
						
						loop
						exitwhen inBoundary or iBoundaryRect >= .Boundaries.size
						set boundaryRect = .Boundaries[iBoundaryRect]
							if (userData == 0 and RectContainsCoords(boundaryRect, GetUnitX(User(curUser.value).ActiveUnit), GetUnitY(User(curUser.value).ActiveUnit))) /*
								*/ or (userData != 0 and BufferedRectContainsCoords(boundaryRect, GetUnitX(User(curUser.value).ActiveUnit), GetUnitY(User(curUser.value).ActiveUnit), TRANSITION_BUFFER)) then
								set inBoundary = true
							endif
						set iBoundaryRect = iBoundaryRect + 1
						endloop
						
						if userData == 0 then
							if inBoundary then
								call .AddUser(curUser.value)
							endif
						else
							if not inBoundary then
								call .RemoveUser(userData)
							endif
						endif
					elseif userData != 0 then
						call .RemoveUser(userData)
					endif
				set curUser = curUser.next
				endloop
			set curTeam = curTeam.next
			endloop
			
		endmethod
		private static method Periodic takes nothing returns nothing
			local SimpleList_ListNode curActive = thistype.Active.first
			
			loop
			exitwhen curActive == 0
				call thistype(curActive.value).PeriodicCheck()
			set curActive = curActive.next
			endloop
		endmethod
		
		public method Start takes nothing returns nothing
            if thistype.Active.count == 0 then
                call TimerStart(thistype.Timer, TIMESTEP, true, function thistype.Periodic)
            endif
            
            call thistype.Active.addEnd(this)
        endmethod
		public method Stop takes nothing returns nothing
            //reset existing zooms
			local SimpleList_ListNode curActiveUserData = .ActiveUserData.first
			
			loop
			set curActiveUserData = .ActiveUserData.first
			exitwhen curActiveUserData == 0
				call .RemoveUser(curActiveUserData.value)
			endloop
			
			//update static logic
			call thistype.Active.remove(this)
            
            if thistype.Active.count == 0 then
                call PauseTimer(thistype.Timer)
            endif
        endmethod
        
		static method create takes rect area, real cameraDistance returns thistype
			local thistype new = thistype.allocate()
			
			set new.Boundaries = RectList.create()
			call new.Boundaries.addEnd(area)
			set new.CameraDistance = cameraDistance
			
			set new.ActiveUserData = SimpleList_List.create()
			
			return new
		endmethod
		
		private static method onInit takes nothing returns nothing
			set thistype.Active = SimpleList_List.create()
			set thistype.Timer = CreateTimer()
		endmethod
	endstruct
endlibrary