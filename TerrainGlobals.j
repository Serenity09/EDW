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
        constant integer RUNEBRICKS = 'cIc2' //Icecrown Runes Bricks (non-cliff) : keeps the effect of last tile
        
        constant integer NOEFFECT = 'Agrd' //Ashenvale Lumpy Grass : NO EFFECT
        
        //redefines to make platformer naming convention more memorable
        constant integer DEATH = LAVA
        constant integer WALL = NOEFFECT
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
        
        //by default how much "space" should be given for terrain kill -- 26 is good
        //should be under a tile quadrant (64) for predictable effects
        constant real DefaultTerrainOffset = 26
        constant real FASTICEOFFSET = 40
        constant real MEDIUMICEOFFSET = 45
        constant real SLOWICEOFFSET = 34
        constant real LAVAOFFSET = 42
        constant real RTILEOFFSET = 42
        constant real LEAVESOFFSET = 42
        constant real VINESOFFSET = 50
        constant real LRGBRICKSOFFSET = 28
        constant real SANDOFFSET = 45
        constant real SNOWOFFSET = 45
        constant real RSNOWOFFSET = 45
        constant real D_GRASSOFFSET = 30
        constant real GRASSOFFSET = 30
        constant real RUNEBRICKSOFFSET = 40

        real array TerrainOffset[NumberPlayers]
        
        //the rate at which lava deals damage
        constant real LAVARATE = 175
        group OnLavaGroup = CreateGroup()
        integer NumberOnLava = 0
        
        constant integer TERRAIN_QUADRANT_SIZE  = 64
        constant integer TERRAIN_TILE_SIZE      = 128
        
        constant real TERRAIN_QUADRANT_ROUND = .50001
    endglobals
    
    public function IsTerrainPathable takes integer ttype returns boolean
        return ttype == DEATH or ttype == PATHABLE or ttype == OCEAN or ttype == PLATFORMING or ttype == VINES or ttype == RTILE or ttype == LEAVES or ttype == RUNEBRICKS
    endfunction
    public function IsTerrainUnpathable takes integer ttype returns boolean
        return ttype == WALL or ttype == SAND or ttype == SNOW or ttype == RSNOW or ttype == GRASS or ttype == DGRASS or ttype == FASTICE or ttype == SLOWICE
    endfunction
    
    public function IsTerrainJumpable takes integer ttype returns boolean
        return IsTerrainUnpathable(ttype)
    endfunction
    
    public function IsTerrainWallJumpable takes integer ttype returns boolean
        return ttype == WALL or ttype == RSNOW or ttype == GRASS or ttype == DGRASS or ttype == SLOWICE or ttype == FASTICE
    endfunction
    
    public function IsTerrainSoft takes integer ttype returns boolean
        return ttype == SAND or ttype == SNOW
    endfunction
    
    public function IsTerrainDiagonal takes integer ttype returns boolean
        return ttype == SLOWICE or ttype == FASTICE or ttype == GRASS or ttype == DGRASS
    endfunction
    public function IsTerrainSquare takes integer ttype returns boolean
        return ttype == WALL or ttype == SNOW or ttype == SAND or ttype == RSNOW
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
        return centerX - TERRAIN_QUADRANT_SIZE + TERRAIN_QUADRANT_ROUND
    endfunction
    
    function GetTerrainRight takes real centerX returns real
        return centerX + TERRAIN_QUADRANT_SIZE + TERRAIN_QUADRANT_ROUND
    endfunction
    
    function GetTerrainBottom takes real centerY returns real
        return centerY - TERRAIN_QUADRANT_SIZE + TERRAIN_QUADRANT_ROUND
    endfunction
    
    function GetTerrainTop takes real centerY returns real
        return centerY + TERRAIN_QUADRANT_SIZE + TERRAIN_QUADRANT_ROUND
    endfunction
    
    function initTerrainGlobals takes nothing returns nothing
        local integer i = 0
    
        loop
        exitwhen i >= NumberPlayers
            //set PreviousTerrainType2[i] = NOEFFECT
            //set PreviousTerrainType[i] = NOEFFECT
            set PreviousTerrainTypedx[i] = NOEFFECT
            
            set TerrainOffset[i] = DefaultTerrainOffset
            
            set i = i + 1
        endloop
    endfunction
endlibrary