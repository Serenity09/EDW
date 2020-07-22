library LevelPath requires PermanentAlloc, Vector2, LevelPathNode, SimpleList
	globals
		public constant boolean DEBUG_FINALIZE = true
	endglobals
	
	struct LevelPath extends array
		public LevelPathNode Start
		public LevelPathNode End
		
		static if DEBUG_FINALIZE then
			public boolean Finalized
		endif
			
		implement PermanentAlloc
		
		public method operator TotalDistance takes nothing returns real
			return this.End.CumulativeDistance
		endmethod
		public method GetPercentDistance takes LevelPathNodeConnection connection, vector2 position returns real
			local real rawPercent = connection.GetTotalDistanceFromPoint(position) / this.TotalDistance
			
			if rawPercent > 1. then
				return 1.
			elseif rawPercent < 0. then
				return 0.
			else
				return rawPercent
			endif
		endmethod
		
		//private method GetConnectionsRecursive takes List<LevelPathNode> visited, LevelPathNode curPathNode returns List<LevelPathNodeConnection>
		private method GetConnectionsRecursive takes SimpleList_List visited, LevelPathNode curPathNode returns SimpleList_List
			//List<LevelPathNode> connections
			local SimpleList_List connections = SimpleList_List.create()
			local SimpleList_ListNode curConnectionNode = curPathNode.Connections.first
			
			local SimpleList_ListNode curChildConnectionNode
			
			//List<LevelPathNodeConnection>
			local SimpleList_List childConnections
			
			if not visited.contains(curPathNode) then
				call visited.addEnd(curPathNode)
				
				if curConnectionNode == 0 then
					return connections
				else
					call connections.addEndRange(curPathNode.Connections)
					
					loop
					exitwhen curConnectionNode == 0						
						set childConnections = GetConnectionsRecursive(visited, LevelPathNodeConnection(curConnectionNode.value).NextNode)
						set curChildConnectionNode = childConnections.first
						
						loop
						exitwhen curChildConnectionNode == 0
							if not connections.contains(curChildConnectionNode.value) then
								call connections.addEnd(curChildConnectionNode.value)
							endif
							
						set curChildConnectionNode = curChildConnectionNode.next
						endloop
						
						call childConnections.destroy()
					set curConnectionNode = curConnectionNode.next
					endloop
					
					return connections
				endif
			else
				return connections
			endif
		endmethod
		//returns List<LevelPathNodeConnection>
		public method GetConnections takes nothing returns SimpleList_List
			local SimpleList_List visited = SimpleList_List.create()
			local SimpleList_List allConnections = GetConnectionsRecursive(visited, this.Start)
			
			call visited.destroy()
			return allConnections
		endmethod
		
		public method Draw takes nothing returns nothing
			local SimpleList_List allConnections = this.GetConnections()
			local SimpleList_ListNode curConnectionNode = allConnections.first
			
			loop
			exitwhen curConnectionNode == 0
				// call LevelPathNodeConnection(curConnectionNode.value).ConnectingLine.Draw()
				call LevelPathNodeConnection(curConnectionNode.value).ConnectingLine.DrawEx(Draw_MANA_BURN)
			set curConnectionNode = curConnectionNode.next
			endloop
			
			//clean-up
			call allConnections.destroy()
		endmethod
		
		//this will lag when called on a complex level path graph
		public method GetBestConnection takes vector2 position, LevelPathNodeConnection guess, real closeEnough returns LevelPathNodeConnection
			//TODO implement lazy version of .GetConnections with filter built in. rip lambda :(
			local SimpleList_List allConnections = this.GetConnections()
			local SimpleList_ListNode curConnectionNode = allConnections.first
			local real curConnectionDistance
			
			local LevelPathNodeConnection bestConnection = 0
			local real leastConnectionDistance = LevelPathNode_CONNECTION_MAX_DISTANCE_SQUARED
			
			loop
			exitwhen curConnectionNode == 0
				set curConnectionDistance = LevelPathNodeConnection(curConnectionNode.value).ConnectingLine.GetDistanceSquaredFromPoint(position)
								
				if curConnectionDistance < leastConnectionDistance then
					set bestConnection = curConnectionNode.value
					set leastConnectionDistance = curConnectionDistance
				endif
			set curConnectionNode = curConnectionNode.next
			endloop
						
			//clean-up
			call allConnections.destroy()
			
			return bestConnection
		endmethod
				
		//private method GetBranchesRecursive takes List<LevelPathNode> parentBranch, LevelPathNode curPathNode returns List<List<LevelPathNode>>
		private method GetBranchesRecursive takes SimpleList_List parentBranch, LevelPathNode curPathNode returns SimpleList_List
			//List<List<LevelPathNode>> branches
			local SimpleList_List branches = SimpleList_List.create()
			local SimpleList_ListNode curConnectionNode = curPathNode.Connections.first
			
			local SimpleList_List childBranch
			local SimpleList_List childBranches
			
			call parentBranch.addEnd(curPathNode)
			
			if curConnectionNode == 0 then
				//call branches.addEnd(parentBranch)
				call branches.addEnd(parentBranch.clone())
				
				return branches
			else
				loop
				exitwhen curConnectionNode == 0
					if not parentBranch.contains(LevelPathNodeConnection(curConnectionNode.value).NextNode) then
						set childBranch = parentBranch.clone()
						set childBranches = GetBranchesRecursive(childBranch, LevelPathNodeConnection(curConnectionNode.value).NextNode)
						call branches.addEndRange(childBranches)
						
						call childBranch.destroy()
						call childBranches.destroy()
					endif
				set curConnectionNode = curConnectionNode.next
				endloop
				
				return branches
			endif
		endmethod
		//returns List<List<LevelPathNode>>
		public method GetBranches takes nothing returns SimpleList_List
			local SimpleList_List parentBranch = SimpleList_List.create()
			local SimpleList_List allBranches = GetBranchesRecursive(parentBranch, this.Start)
			
			call parentBranch.destroy()
			return allBranches
		endmethod
		
		private method PrintPathByBreadthRecursive takes LevelPathNode node, integer depth returns nothing
			local SimpleList_ListNode currentChildNode = node.Connections.first
			
			call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Depth: " + I2S(depth))
			call node.Print()
			
			loop
			exitwhen currentChildNode == 0
				if LevelPathNodeConnection(currentChildNode.value).NextNode != 0 then
					call this.PrintPathByBreadthRecursive(LevelPathNodeConnection(currentChildNode.value).NextNode, depth + 1)
				else
					call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
					call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Null next node for PathNode ID: " + I2S(node))
					call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "List item ID: " + I2S(currentChildNode))
					call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Connection ID: " + I2S(currentChildNode.value))
				endif
			set currentChildNode = currentChildNode.next
			endloop
		endmethod
		public method PrintPathByBreadth takes nothing returns nothing
			call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "***************")
			call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Path ID: " + I2S(this))
			call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "START**********")
			call this.Start.Print()
			call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "END************")
			call this.End.Print()
			call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "***************")
			
			call this.PrintPathByBreadthRecursive(this.Start, 0)
			
			call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "***************")
			call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Total Distance: " + R2S(this.TotalDistance))
		endmethod
		
		public method Finalize takes nothing returns nothing
			local SimpleList_List branches
			local SimpleList_ListNode curBranch
			local SimpleList_ListNode curBranchNode
			local real curBranchTotalDistance
			local real curBranchDistance
			
			static if DEBUG_FINALIZE then
				if this.Finalized then
					call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Warning! Calling LevelPath.Finalize on an already finalized Path!")
					call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Path ID: " + I2S(this))
				else
					set this.Finalized = true
				endif
			endif
			
			if this.Start.Connections.count == 0 then
				call this.Start.AddNextNode(this.End)
			endif
			
			set branches = this.GetBranches()
			
			set curBranch = branches.first
			loop
			exitwhen curBranch == 0
				//get the total distance of the branch
				set curBranchNode = SimpleList_List(curBranch.value).first
				set curBranchTotalDistance = 0.
				
				//cache the relative distance of each node in the branch. if the node has an existing distance, averaging the two values. ideally, all values would be weighted the same, but i don't think it will really matter
				loop
				exitwhen curBranchNode == 0
					if LevelPathNode(curBranchNode.value).CumulativeDistance == -1 then
						set LevelPathNode(curBranchNode.value).CumulativeDistance = curBranchTotalDistance
					else
						set LevelPathNode(curBranchNode.value).CumulativeDistance = (LevelPathNode(curBranchNode.value).CumulativeDistance + curBranchTotalDistance) / 2.
					endif
					
					if curBranchNode.next != 0 then
						set curBranchTotalDistance = curBranchTotalDistance + LevelPathNode(curBranchNode.value).GetConnection(curBranchNode.next.value).ConnectingLine.Magnitude
					endif					
				set curBranchNode = curBranchNode.next
				endloop
				
				/*
				//cache the relative distance of each node in the branch. if the node has an existing distance, averaging the two values. ideally, all values would be weighted the same, but i don't think it will really matter
				set curBranchNode = SimpleList_List(curBranch.value).first
				set curBranchDistance = 0.
				
				loop
				exitwhen curBranchNode == 0 or curBranchNode.next == 0
					if LevelPathNode(curBranchNode.value).PercentComplete == -1 then
						set LevelPathNode(curBranchNode.value).PercentComplete = curBranchDistance / curBranchTotalDistance
					else
						set LevelPathNode(curBranchNode.value).PercentComplete = (LevelPathNode(curBranchNode.value).PercentComplete + (curBranchDistance / curBranchTotalDistance)) / 2.
					endif
					
				set curBranchDistance = curBranchDistance + LevelPathNode(curBranchNode.value).GetConnection(curBranchNode.next.value).ConnectingLine.Magnitude
				set curBranchNode = curBranchNode.next
				endloop
				*/
				
			set curBranch = curBranch.next
			endloop
			
			//clean-up
			set curBranch = branches.first
			loop
			exitwhen curBranch == 0
				call SimpleList_List(curBranch.value).destroy()
			set curBranch = curBranch.next
			endloop
			call branches.destroy()
		endmethod
						
		//
		public static method create takes LevelPathNode start, LevelPathNode end returns thistype
			local thistype new = thistype.allocate()
			
			set new.Start = start
			set new.End = end
			
			static if DEBUG_FINALIZE then
				set new.Finalized = false
			endif
			
			return new
		endmethod
		public static method createFromRect takes rect startRect, rect endRect returns thistype
			return thistype.create(LevelPathNode.createFromRect(startRect), LevelPathNode.createFromRect(endRect))
		endmethod
	endstruct
endlibrary