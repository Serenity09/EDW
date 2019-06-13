library LavaGenerator requires Alloc, SimpleList, TimerUtils
	globals
	
	endglobals
	
	private struct LavaFlowTile extends array
		public LavaFlowTile Previous
		
		public vector2 Center
		public integer Layer
		
		implement Alloc
		
		public method create takes LavaFlowTile previous, vector2 center, integer layer returns thistype
			local thistype new = thistype.allocate()
			
			set new.Previous = previous
			set new.Center = center
			set new.Layer = layer
			
			return new
		endmethod
	endstruct
	private struct LavaFlow extends array
		public LavaSource Parent
		
		public SimpleList_List LavaTiles
		public integer CurrentLavaLayer
		
		public timer Timer
		
		implement Alloc
		
		private static method Update takes nothing returns nothing
			local LavaFlow flow = GetTimerData(GetExpiredTimer())
			local SimpleList_ListNode curLavaTile = flow.LavaTiles.last
			local integer headLayer
			
			//check all tiles on last layer to see if they have any viable positions available
			loop
			exitwhen LavaFlowTile(curLavaTile.value).Layer != flow.CurrentLavaLayer - 1
				
			set curLavaTile = curLavaTile.previous
			endloop
			
			//no longer connected to origin, remove top layer of lava
			if flow.LavaTiles.first.value != flow.Parent.Origin then
				set curLavaTile = flow.first
				set headLayer = LavaFlowTile(curLavaTile.value).Layer
				
				loop
				exitwhen LavaFlowTile(curLavaTile.value).Layer != headLayer
					
				set curLavaTile = curLavaTile.next
				endloop
			endif
			
			call TimerStart(flow.Timer, flow.Parent.FlowRate, false, function thistype.Update)
		endmethod
		
		public method create takes LavaSource parent returns thistype
			local thistype new = thistype.allocate()
			
			set new.LavaTiles = SimpleList_List.create()
			call new.LavaTiles.add(parent.Origin)
			
			set new.CurrentLavaLayer = 1
			
			set new.Timer = NewTimerEx(new)
			
			return new
		endmethod
	endstruct
	
	struct LavaSource extends IStartable
		public LavaFlowTile Origin
		public SimpleList_List LavaFlows
		
		public real FlowRate
		public real FlowDuration
		public real SleepDuration
				
		
		
		public method Start takes nothing returns nothing
			local LavaFlow flow = LavaFlow.create(this)
			call .LavaFlows.addEnd(flow)
			call TimerStart(flow.Timer, 0.0, false, function thistype.Update)
		endmethod
		
		public static method create takes vector2 origin, real flowRate, real flowDuration, real sleepRate, real sleepDuration returns thistype
			local thistype new = thistype.allocate()
			
			set new.LavaFlows = SimpleList_List.create()
			
			set new.Origin = LavaFlowTile.create(0, origin, 0)
			
			set new.FlowRate = flowRate
			set new.FlowDuration = flowDuration
			set new.SleepRate = sleepRate
			set new.SleepDuration = sleepDuration
			
			return new
		endmethod
	endstruct
endlibrary