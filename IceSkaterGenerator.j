library IceSkaterGenerator requires IStartable, IceSkater, PatternSpawn, SimpleList, GroupUtils, TimerUtils
	struct IceSkaterGenerator extends IStartable
		public PatternSpawn SpawnPattern
		private timer SpawnTimer
		private real SpawnTimeout
		
		private SimpleList_List ActiveSkaters
		private SimpleList_List InactiveSkaters
		
		private static SimpleList_List ActiveGenerators
				
		public static method GetGeneratorFromSkater takes IceSkater skater returns thistype
			local SimpleList_ListNode curGeneratorNode = thistype.ActiveGenerators.first
			
			loop
			exitwhen curGeneratorNode == 0
				if thistype(curGeneratorNode.value).ActiveSkaters.contains(skater) then
					return curGeneratorNode.value
				endif
			set curGeneratorNode = curGeneratorNode.next
			endloop
			
			return 0
		endmethod
		
		private static method OnSkaterReset takes nothing returns boolean
			local thistype generator = thistype.GetGeneratorFromSkater(IceSkater.EventSkater)
			
			// call DisplayTextToForce(bj_FORCE_PLAYER[0], "Resetting skater")
			
			call generator.ActiveSkaters.remove(IceSkater.EventSkater)
			call generator.InactiveSkaters.addEnd(IceSkater.EventSkater)
			
			call IceSkater.EventSkater.Stop()
			
			return false
		endmethod
		
		public method StartSkater takes IceSkater skater returns nothing
			call this.ActiveSkaters.addEnd(skater)
			call skater.Start()
		endmethod
		
		public method Spawn takes nothing returns nothing
			local group spawnGroup
			local unit spawnUnit
			
			local SimpleList_ListNode recycleNode
			
			if this.InactiveSkaters.count == 0 then
				set spawnGroup = this.SpawnPattern.Spawn(this.ParentLevel)
				
				//TODO consider forcing group to be size 1, since lazy spawn strategy will not create consistent distrubution of Spawn calls vs recycle pops
				loop
				set spawnUnit = FirstOfGroup(spawnGroup)
				exitwhen spawnUnit == null
					call this.StartSkater(IndexedUnit[spawnUnit].Data)
				call GroupRemoveUnit(spawnGroup, spawnUnit)
				endloop
				
				call ReleaseGroup(spawnGroup)
				set spawnGroup = null
			else
				set recycleNode = this.InactiveSkaters.pop()
				call this.StartSkater(recycleNode.value)
				call recycleNode.deallocate()
			endif
		endmethod
		private static method SpawnCB takes nothing returns nothing
			call thistype(GetTimerData(GetExpiredTimer())).Spawn()
		endmethod
		
		
		public method Start takes nothing returns nothing
			call thistype.ActiveGenerators.addEnd(this)
			
			set this.SpawnTimer = NewTimerEx(this)
			call TimerStart(this.SpawnTimer, this.SpawnTimeout, true, function thistype.SpawnCB)
			
			call this.Spawn()
		endmethod
		public method Stop takes nothing returns nothing
			local SimpleList_ListNode curActiveSkaterNode
			
			loop
			set curActiveSkaterNode = this.ActiveSkaters.pop()
			exitwhen curActiveSkaterNode == 0
				call IceSkater(curActiveSkaterNode.value).Stop()
				call this.InactiveSkaters.addEnd(curActiveSkaterNode.value)
			call curActiveSkaterNode.deallocate()
			endloop
			
			call thistype.ActiveGenerators.remove(this)
			
			call ReleaseTimer(this.SpawnTimer)
		endmethod
		
		public static method create takes PatternSpawn spawnPattern, real spawnTimeout returns thistype
			local thistype new = thistype.allocate()
			
			set new.SpawnPattern = spawnPattern
			set new.SpawnTimeout = spawnTimeout
			
			set new.ActiveSkaters = SimpleList_List.create()
			set new.InactiveSkaters = SimpleList_List.create()
			
			return new
		endmethod
		
		private static method onInit takes nothing returns nothing
			set thistype.ActiveGenerators = SimpleList_List.create()
			
			call IceSkater.OnSkaterReset.register(Condition(function thistype.OnSkaterReset))
		endmethod
	endstruct
endlibrary