library TerrainGlobals initializer initTerrainGlobals requires GameGlobalConstants
    globals
        //terrain name and tileset : its effect    
        constant integer FASTICE = 'Idki' //Icecrown darkice : fast ice
        constant integer MEDIUMICE = 'Glav' //Underground ice (really is called lav): medium ice
        constant integer SLOWICE = 'Iice' //Icecrown ice : slow ice
        constant integer ABYSS = 'Oaby' //outland Abyss (cliff) : abyss effect
        constant integer LAVA = 'Dlav' //dungeon Lava : variable
        constant integer RTILE = 'Ztil' //sunken ruins round tile : camera rotate effect
        constant integer LEAVES = 'Alvd' //Ashenvale leaves : Super fast
        constant integer VINES = 'Avin' //Ashenvale vines : slow
        constant integer LRGBRICKS = 'cZc1' //sunken ruins large bricks (non-cliff) : platforming
        constant integer SAND = 'Zsan' //sunken ruins sand : momentum running/turning
        constant integer SNOW = 'cWc1' //lordaron winter snow (cliff)
        constant integer RSNOW = 'Nsnr' //northrend rocky snow
        constant integer D_GRASS = 'Lgrd' //lordaron summer dark grass : fast speed boost
        constant integer GRASS = 'cLc1' //lordaeron summer grass (non-cliff) : medium speed boost
		constant integer ROAD = 'Nrck' //Northrend Rock (non-cliff): same as no effect, but is visually different
		constant integer LUMPYGRASS = 'Agrd' //Ashenvale Lumpy Grass
        
        constant integer NOEFFECT = GRASS //Ashenvale Lumpy Grass : NO EFFECT
        
        //redefines to make platformer naming convention more memorable
        constant integer DEATH = LAVA
        constant integer WALL = LUMPYGRASS
        constant integer PLATFORMING = LRGBRICKS
        constant integer PATHABLE = ABYSS
        constant integer OCEAN = MEDIUMICE
        constant integer DGRASS = D_GRASS
        constant integer BOOST = RTILE
        constant integer SLIPSTREAM = LEAVES
        
        //2 terrain types ago
        //integer array PreviousTerrainType2[NumberPlayers]
        //1 terrain type ago
        //integer array PreviousTerrainType[NumberPlayers]
        integer array PreviousTerrainTypedx[NumberPlayers]
        
        constant integer TERRAIN_QUADRANT_SIZE  = 64
        constant integer TERRAIN_TILE_SIZE      = 128
        
        constant real TERRAIN_QUADRANT_ROUND = .5
    endglobals
    
	function TerrainID2S takes integer ttype returns string
		if ttype == ABYSS then
			return "abyss"
		elseif ttype == LRGBRICKS then 
			return "large bricks"
		elseif ttype == RTILE then
			return "round tile"
		elseif ttype == ROAD then
			return "road"
		elseif ttype == LAVA then
			return "lava"
		elseif ttype == LUMPYGRASS then
			return "lumpy grass"
		elseif ttype == GRASS then
			return "grass"
		elseif ttype == SNOW then
			return "snow"
		elseif ttype == D_GRASS then
			return "dark grass"
		elseif ttype == SLOWICE then
			return "slow ice"
		elseif ttype == LEAVES then
			return "leaves"
		elseif ttype == MEDIUMICE then
			return "medium ice"
		elseif ttype == FASTICE then
			return "fast ice"
		elseif ttype == VINES then
			return "vines"
		elseif ttype == SAND then
			return "sand"
		elseif ttype == RSNOW then
			return "rocky snow"
		else
			static if DEBUG_MODE then
				call DisplayTextToForce(bj_FORCE_PLAYER[0], "Undefined ttype: " + I2S(ttype))
			endif
			
			return ""
		endif
	endfunction
	
    public function IsTerrainPathable takes integer ttype returns boolean
        return ttype == DEATH or ttype == PATHABLE or ttype == OCEAN or ttype == PLATFORMING or ttype == VINES or ttype == RTILE or ttype == LEAVES
    endfunction
    public function IsTerrainUnpathable takes integer ttype returns boolean
        return ttype == WALL or ttype == GRASS or ttype == DGRASS or ttype == FASTICE or ttype == SLOWICE or ttype == SAND or ttype == SNOW or ttype == RSNOW or ttype == ROAD
    endfunction
    
    public function IsTerrainJumpable takes integer ttype returns boolean
        return IsTerrainUnpathable(ttype)
    endfunction
    
    public function IsTerrainWallJumpable takes integer ttype returns boolean
        return ttype == WALL or ttype == RSNOW or ttype == GRASS or ttype == DGRASS or ttype == SLOWICE or ttype == FASTICE or ttype == ROAD
    endfunction
	//relevant to a strict subset of IsTerrainWallJumpable
	//if the terrain is good footing then the platformer will immediately negate any Y velocity against their jump direction
	public function IsTerrainGoodFooting takes integer ttype returns boolean
		return ttype == WALL or ttype == RSNOW or ttype == GRASS or ttype == DGRASS or ttype == ROAD
	endfunction
    public function IsTerrainSoft takes integer ttype returns boolean
        return ttype == SAND or ttype == SNOW
    endfunction
	//Use not IsTerrainSoft in conjunction with IsTerrainUnpathable instead of IsTerrainHard
	
	
	//relevant to a strict subset of hard terrains
	/* //ice isn't fun unless its got a 0 bouncyness value, but then its very unintuitive that its so much less bouncy than grass...
	public function GetTerrainBouncyness takes integer ttype returns real
		if ttype == WALL then
			return .9
		elseif ttype == GRASS or ttype == DGRASS or ttype == FASTICE or ttype == SLOWICE then
			return 0
		elseif ttype == RSNOW then
			return .5
		endif
	endfunction
    */
	
    public function IsTerrainDiagonal takes integer ttype returns boolean
        return ttype == SLOWICE or ttype == FASTICE or ttype == DGRASS or ttype == ROAD
    endfunction
    public function IsTerrainSquare takes integer ttype returns boolean
        return ttype == WALL or ttype == GRASS or ttype == SNOW or ttype == SAND or ttype == RSNOW
    endfunction
    
    function GetTerrainCenterpoint takes real x, real y returns vector2
        local vector2 center = vector2.allocate()
        
        if x >= 0 then
            set center.x = R2I((x + 64.500000) / 128.) * 128.
        else
            set center.x = R2I((x - 63.499999) / 128.) * 128.
        endif
        if y >= 0 then
            set center.y = R2I((y + 64.500000) / 128.) * 128.
        else
            set center.y = R2I((y - 63.499999) / 128.) * 128.
        endif
        
        return center
    endfunction
    
    /*
    function GetTerrainCenterpoint2 takes real x, real y returns vector2
        local vector2 center = vector2.allocate()
        //calc x centerpoint first
        local integer quotient = R2I(x / TERRAIN_TILE_SIZE) //int
        local real relCoord = x - (quotient * TERRAIN_TILE_SIZE)
        
        if relCoord >= 0 then
            set center.x = R2I((x + 64.500000) / 128.) * 128.
        else
            set center.x = R2I((x - 63.499999) / 128.) * 128.
        endif
        if y >= 0 then
            set center.y = R2I((y + 64.500000) / 128.) * 128.
        else
            set center.y = R2I((y - 63.499999) / 128.) * 128.
        endif
        
        return center
    endfunction
    */
    
    function GetTerrainLeft takes real centerX returns real
        return centerX - TERRAIN_QUADRANT_SIZE - TERRAIN_QUADRANT_ROUND
    endfunction
    
    function GetTerrainRight takes real centerX returns real
        return centerX + TERRAIN_QUADRANT_SIZE - TERRAIN_QUADRANT_ROUND
    endfunction
    
    function GetTerrainBottom takes real centerY returns real
        return centerY - TERRAIN_QUADRANT_SIZE - TERRAIN_QUADRANT_ROUND
    endfunction
    
    function GetTerrainTop takes real centerY returns real
        return centerY + TERRAIN_QUADRANT_SIZE - TERRAIN_QUADRANT_ROUND
    endfunction
    
    private function initTerrainGlobals takes nothing returns nothing
        local integer i = 0
    
        loop
        exitwhen i >= NumberPlayers
            //set PreviousTerrainType2[i] = NOEFFECT
            //set PreviousTerrainType[i] = NOEFFECT
            set PreviousTerrainTypedx[i] = NOEFFECT
            
            set i = i + 1
        endloop
    endfunction
endlibrary