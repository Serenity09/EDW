library Draw
	globals
		public constant string MANA_BURN = "MBUR"
		public constant string SPIRIT_LINK = "SPLK"
		
		public constant string LINE_EFFECT = MANA_BURN
		public constant string RECTANGLE_EFFECT = MANA_BURN
	endglobals
	
	public function DrawPoint takes integer playerID, real x, real y returns unit
		return CreateUnit(Player(playerID), DEBUG_UNIT, x, y, 0)
	endfunction
	public function DrawVectorPoint takes integer playerID, vector2 v returns unit
		return DrawPoint(playerID, v.x, v.y)
	endfunction
	
    public function DrawLine takes real x1, real y1, real x2, real y2, real z returns lightning
        return AddLightningEx(LINE_EFFECT, false, x1, y1, z, x2, y2, z)
    endfunction
	public function DrawVectorLine takes vector2 v1, vector2 v2, real z returns lightning
		return DrawLine(v1.x, v1.y, v2.x, v2.y, z)
	endfunction
	public function DrawVectorLineEx takes vector2 v1, vector2 v2, real z, string fx, boolean fog returns lightning
		return AddLightningEx(fx, fog, v1.x, v1.y, z, v2.x, v2.y, z)
	endfunction
	
    public function DrawRegion takes rect r, real z returns nothing
        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Drawing region BL: " + R2S(GetRectMinX(r)) + ", " + R2S(GetRectMinY(r)) + "; TR: " + R2S(GetRectMaxX(r)) + ", " + R2S(GetRectMaxY(r)))
        
        call AddLightningEx(RECTANGLE_EFFECT, false, GetRectMinX(r), GetRectMinY(r), z, GetRectMinX(r), GetRectMaxY(r), z)
        call AddLightningEx(RECTANGLE_EFFECT, false, GetRectMinX(r), GetRectMinY(r), z, GetRectMaxX(r), GetRectMinY(r), z)
        call AddLightningEx(RECTANGLE_EFFECT, false, GetRectMinX(r), GetRectMaxY(r), z, GetRectMaxX(r), GetRectMaxY(r), z)
        call AddLightningEx(RECTANGLE_EFFECT, false, GetRectMaxX(r), GetRectMinY(r), z, GetRectMaxX(r), GetRectMaxY(r), z)
        
        //debug call DisplayTextToForce(bj_FORCE_PLAYER[0], "Done drawing region")
    endfunction
endlibrary