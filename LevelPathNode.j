library LevelPathNode requires PermanentAlloc, Vector2, Line, SimpleList
	globals
		public constant real CONNECTION_MAX_DISTANCE = 5. * TERRAIN_TILE_SIZE
		public constant real CONNECTION_MAX_DISTANCE_SQUARED = CONNECTION_MAX_DISTANCE * CONNECTION_MAX_DISTANCE

		public constant real CLOSE_ENOUGH = 1. * TERRAIN_TILE_SIZE
		public constant real CLOSE_ENOUGH_SQUARED = CLOSE_ENOUGH * CLOSE_ENOUGH
	endglobals
	
	struct LevelPathNodeConnection extends array
		public LevelPathNode StartNode
		public LevelPathNode NextNode
		
		public LineSegment ConnectingLine
		
		implement PermanentAlloc
		
		public method GetTotalDistanceFromPoint takes vector2 position returns real
			return this.StartNode.CumulativeDistance + this.ConnectingLine.GetProjectedDistanceFromPoint(position)
		endmethod
		
		public method GetClosestConnection takes LevelPath path, vector2 position returns thistype
			local real closestDistance = this.ConnectingLine.GetDistanceSquaredFromPoint(position)
			local thistype closestConnection = this
			
			local SimpleList_ListNode curConnectionNode = this.NextNode.Connections.first
			local real curConnectionDistance
			
			loop
			exitwhen curConnectionNode == 0
				set curConnectionDistance = thistype(curConnectionNode.value).ConnectingLine.GetDistanceSquaredFromPoint(position)
				
				if curConnectionDistance < closestDistance then
					set closestDistance = curConnectionDistance
					set closestConnection = curConnectionNode.value
				endif
			set curConnectionNode = curConnectionNode.next
			endloop
			
			set curConnectionNode = this.StartNode.Connections.first
			loop
			exitwhen curConnectionNode == 0
				set curConnectionDistance = thistype(curConnectionNode.value).ConnectingLine.GetDistanceSquaredFromPoint(position)
				
				if curConnectionDistance < closestDistance then
					set closestDistance = curConnectionDistance
					set closestConnection = curConnectionNode.value
				endif
			set curConnectionNode = curConnectionNode.next
			endloop
			
			// call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Closest distance was: " + R2S(closestDistance))
			if closestDistance >= CONNECTION_MAX_DISTANCE_SQUARED then
				set closestConnection = path.GetBestConnection(position, closestConnection, CLOSE_ENOUGH_SQUARED)
			endif
			
			return closestConnection
		endmethod
		
		public static method create takes LevelPathNode startNode, LevelPathNode nextNode returns thistype
			local thistype new = thistype.allocate()
			
			set new.StartNode = startNode
			set new.NextNode = nextNode
			
			set new.ConnectingLine = LineSegment.create(startNode.Position, nextNode.Position)
			
			return new
		endmethod
	endstruct
	
	struct LevelPathNode extends array
		public vector2 Position
		public real ParTime
		
		public SimpleList_List Connections
		public real CumulativeDistance
		
		public integer DelimiterTerrainID //needed?
		public integer AssociatedGameMode //needed?
		
		implement PermanentAlloc
				
		public method AddNextNode takes LevelPathNode nextNode returns nothing
			local LevelPathNodeConnection connection = LevelPathNodeConnection.create(this, nextNode)
			
			call this.Connections.addEnd(connection)
			call nextNode.Connections.add(connection)
		endmethod
		public method GetConnection takes LevelPathNode nextNode returns LevelPathNodeConnection
			local SimpleList_ListNode curConnectionNode = this.Connections.first
			
			loop
			exitwhen curConnectionNode == 0
				if LevelPathNodeConnection(curConnectionNode.value).NextNode == nextNode then
					return curConnectionNode.value
				endif
			set curConnectionNode = curConnectionNode.next
			endloop
			
			return 0
		endmethod
		
		public method Print takes nothing returns nothing
			call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "ID: " + I2S(this))
			call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Position: " + this.Position.toString())
			call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Cumulative Distance: " + R2S(this.CumulativeDistance) + ", Connection count: " + I2S(this.Connections.count))
		endmethod
		
		public static method create takes vector2 position returns thistype
			local thistype new = thistype.allocate()
			
			set new.Position = position
			
			set new.Connections = SimpleList_List.create()
			set new.ParTime = -1.
			set new.CumulativeDistance = -1.
			
			return new
		endmethod
		public static method createFromRect takes rect r returns thistype
			return thistype.create(vector2.createFromRect(r))
		endmethod
	endstruct
endlibrary