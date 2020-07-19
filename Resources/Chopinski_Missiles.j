library Missiles requires optional WorldBounds
    globals
        public constant real PERIOD         = 1./32.
        public constant real COLLISION_SIZE = 128.
        private location     LOC            = Location(0., 0.)
    endglobals

    private interface Events
        method onHit takes unit hit returns boolean defaults false
        method onDestructable takes destructable dest returns boolean defaults false
        method onTerrain takes nothing returns boolean defaults false
        method onPeriod takes nothing returns boolean defaults false
        method onFinish takes nothing returns boolean defaults false
        method onRemove takes nothing returns nothing defaults nothing
    endinterface

    private struct Coordinates
        real x
        real y
        real z
        readonly real originX
        readonly real originY
        readonly real originZ
        readonly real impactX
        readonly real impactY
        readonly real impactZ
        readonly real angle
        readonly real distance
        readonly real square
        readonly real slope
        readonly real alpha

        /* -------------------------------- Operators ------------------------------- */
        // method operator z= takes real r returns nothing
        //     call MoveLocation(LOC, x, y)
        //     set z = r + GetLocationZ(LOC)
        // endmethod

        // method operator z takes nothing returns real
        //     call MoveLocation(LOC, x, y)
        //     return z - GetLocationZ(LOC)
        // endmethod

        private method calcParameters takes real dx, real dy returns nothing
            set .angle    = Atan2(dy, dx)
            set .square   = dx*dx + dy*dy
            set .distance = SquareRoot(.square)
            set .slope    = (.impactZ - originZ)/.distance
            set .alpha    = Atan(.slope)*bj_RADTODEG
        endmethod

        method moveImpact takes real newX, real newY, real newZ returns nothing
            set .impactX = newX
            set .impactY = newY
            call MoveLocation(LOC, .impactX, .impactX)
            set .impactZ = newZ + GetLocationZ(LOC)

            call calcParameters(newX - .originX, newY - .originY)
        endmethod
        /* ----------------------------------- end ---------------------------------- */

        /* -------------------------- Contructor/Destructor ------------------------- */
        method destroy takes nothing returns nothing
            call .deallocate()
        endmethod

        static method create takes real x, real y, real z, real tx, real ty, real tz returns thistype
            local thistype this = thistype.allocate()
            local real dx = tx - x
            local real dy = ty - y

            set .x        = x
            set .y        = y
            call MoveLocation(LOC, x, y)
            set .z        = z + GetLocationZ(LOC)
            set .originX  = x
            set .originY  = y
            set .originZ  = .z
            set .impactX  = tx
            set .impactY  = ty
            call MoveLocation(LOC, tx, ty)
            set .impactZ  = tz + GetLocationZ(LOC)
            call calcParameters(dx, dy)

            return this
        endmethod
        /* ----------------------------------- end ---------------------------------- */
    endstruct

    private struct Effect
        effect sfx
        string fxpath
        real   scale

        method setScale takes real scale returns nothing
            call BlzSetSpecialEffectScale(.sfx, scale)
        endmethod  

        method orient takes real x, real y, real z returns nothing
            local real norm
            local real yaw
            local real pitch
            local real roll
            local real N
            local real cp
       
            set norm = 1.00001*SquareRoot(x*x + y*y + z*z)
       
            if norm == 0 then
                return
            endif
       
            set x = x/norm
            set y = y/norm
            set z = z/norm
       
            set N = SquareRoot(x*x + y*y)
       
            if N == 0 then
                if z > 0 then
                    call BlzSetSpecialEffectOrientation(.sfx , 0 , -bj_PI/2 , 0)
                else
                    call BlzSetSpecialEffectOrientation(.sfx , 0 , bj_PI/2 , 0)
                endif
                return
            endif
       
            if y >= 0 then
                set pitch = -Asin(x*z/N)
                set cp = Cos(pitch)
                set roll = Asin(y*z/(N*cp))
                set yaw = Acos(x/cp)
            else
                set pitch = Asin(x*z/N) + bj_PI
                set cp = Cos(pitch)
                set roll = -Asin(y*z/(N*cp)) + bj_PI
                set yaw = Acos(x/cp)
            endif
       
            call BlzSetSpecialEffectOrientation(.sfx, yaw, pitch, roll)
        endmethod

        method move takes real x, real y, real z returns nothing
            static if not LIBRARY_WorldBounds then
                if not RectContainsCoords(bj_mapInitialPlayableArea, x, y) then
                    return
                endif
            elseif LIBRARY_WorldBounds then
                if not (x < WorldBounds.maxX and x > WorldBounds.minX and y < WorldBounds.maxY and y > WorldBounds.minY) then
                    return
                endif
            endif
            call BlzSetSpecialEffectPosition(.sfx, x, y, z)
        endmethod

        /* -------------------------- Contructor/Destructor ------------------------- */
        method destroy takes nothing returns nothing
            call DestroyEffect(.sfx)
            set .sfx    = null
            set .fxpath = null
            set .scale  = 1.
            call .deallocate()
        endmethod

        static method create takes real x, real y, real z returns thistype
            local thistype this = thistype.allocate()

            set .sfx = AddSpecialEffect("", x, y)
            call BlzSetSpecialEffectZ(.sfx, z)

            return this
        endmethod
        /* ----------------------------------- end ---------------------------------- */
    endstruct

    struct Missiles extends Events
        private static thistype array missiles
        private static integer        didx      = -1
        private static timer          t         = CreateTimer()
        private static hashtable      table     = InitHashtable()
        private static group          hitGroup  = CreateGroup()
        //----------------------------
        private real         dist
        //----------------------------
        unit                 source
        unit                 target
        player               owner
        integer              data
        real                 distance
        real                 mspeed
        real                 acceleration
        real                 collision
        real                 damage
        real                 zoffset
        readonly Coordinates coord
        readonly Effect      effect
        readonly boolean     dead
        readonly boolean     launched
        readonly boolean     allocated

        /* -------------------------------- Positions ------------------------------- */
        method operator x takes nothing returns real
            return coord.x
        endmethod

        method operator y takes nothing returns real
            return coord.y
        endmethod

        method operator z takes nothing returns real
            return coord.z
        endmethod
        /* -------------------------- Model of the missile -------------------------- */
        method operator model= takes string fx returns nothing
            call DestroyEffect(effect.sfx)
            set effect.fxpath = fx
            set effect.sfx = AddSpecialEffect(fx, coord.x, coord.y)
            call BlzSetSpecialEffectZ(effect.sfx, coord.z)
        endmethod

        method operator model takes nothing returns string
            return effect.fxpath
        endmethod
        /* ----------------------------- Curved movement ---------------------------- */
        real angle
        method operator curve= takes real value returns nothing
            set angle = Tan(value)*coord.distance
        endmethod

        method operator curve takes nothing returns real
            return Atan(angle/coord.distance)
        endmethod
        /* ----------------------------- Arced Movement ----------------------------- */
        real height
        method operator arc= takes real value returns nothing
            set height = Tan(value)*coord.distance/4
        endmethod

        method operator arc takes nothing returns real
            return Atan(4*height/coord.distance)
        endmethod
        /* ------------------------------ Effect scale ------------------------------ */
        method operator scale= takes real value returns nothing
            set effect.scale = value
            call effect.setScale(value)
        endmethod

        method operator scale takes nothing returns real
            return effect.scale
        endmethod
        /* ------------------------------ Missile Speed ----------------------------- */
        method operator speed= takes real newspeed returns nothing
            set mspeed = newspeed*PERIOD
        endmethod

        method operator speed takes nothing returns real
            return mspeed
        endmethod
        /* ------------------------------- Flight Time ------------------------------ */
        method flightTime takes real duration returns nothing
            set mspeed = RMaxBJ(0.00000001, (coord.distance - dist)*PERIOD/RMaxBJ(0.00000001, duration))
        endmethod
        /* --------------------- Destroys the misisle instantly --------------------- */
        method terminate takes nothing returns nothing
            if allocated then
                // onRemove event
                static if this.onRemove.exists then
                    call this.onRemove()
                endif

                call FlushChildHashtable(table, this)
                set .dead      = true
                set .launched  = false
                set .allocated = false
            endif
        endmethod
        /* ------------------------------ Normal remove ----------------------------- */
        private method remove takes integer i returns integer
            call terminate()
            call effect.destroy()
            call coord.destroy()
            set missiles[i] = missiles[didx]
            set didx        = didx - 1

            if didx == -1 then
                call PauseTimer(t)
            endif

            call .deallocate()

            return i - 1
        endmethod

        private static method onLoop takes nothing returns nothing
            local integer  i = 0
            local thistype this
            local unit  u
            local real  a
            local real  newX
            local real  newY
            local real  newZ
            local real  velocity
            local real  point
            local real  pitch
            local real  terrainZ

            loop
                exitwhen i > didx
                    set this = missiles[i]

                    if not dead then
                        if launched then
                            // onPeriod event
							call DisplayTextToPlayer(Player(0), 0, 0, "On Period pre-event")
							
                            if this.onPeriod.exists then
                                if allocated then
                                    if this.onPeriod() then
                                        call .terminate()
                                    endif
                                endif
                            endif

                            // onHit event
                            if this.onHit.exists then
                                if .collision > 0 and allocated then
                                    call GroupEnumUnitsInRange(hitGroup, coord.x, coord.y, .collision + COLLISION_SIZE, null)
                                    loop
                                        set u = FirstOfGroup(hitGroup)
                                        exitwhen u == null
                                            if not HaveSavedBoolean(table, this, GetHandleId(u)) then
                                                if IsUnitInRangeXY(u, coord.x, coord.y, .collision) then
                                                    call SaveBoolean(table, this, GetHandleId(u), true)
                                                    if this.onHit(u) then
                                                        call .terminate()
                                                        exitwhen true
                                                    endif
                                                endif
                                            endif
                                        call GroupRemoveUnit(hitGroup, u)
                                    endloop
                                endif
                            endif

                            // onDestructable event

                            set velocity = mspeed
                            set mspeed   = velocity + acceleration
                            set pitch    = coord.alpha

                            if distance + velocity >= coord.distance then
                                // onFinish event
                                if this.onFinish.exists then
                                    if allocated then
                                        if this.onFinish() then
                                            call .terminate()
                                        endif
                                    endif
                                endif

                                set dead = true
                                set point = coord.distance
                                set distance = distance + coord.distance - dist
                            else
                                set distance = distance + velocity
                                set point = dist + velocity
                            endif
                            set dist = point
                           
                            if target != null and GetUnitTypeId(target) != 0 then
                                call coord.moveImpact(GetUnitX(target), GetUnitY(target), GetUnitFlyHeight(target) + zoffset)
                            endif

                            set newX = coord.x + velocity*Cos(coord.angle)
                            set newY = coord.y + velocity*Sin(coord.angle)

                            // curved movement
                            if angle != 0. then
                                set velocity = 4*angle*point*(coord.distance - point)/coord.square
                                set a = angle + bj_PI/2
                                set newX = newX + velocity*Cos(a)
                                set newY = newY + velocity*Sin(a)
                                //set a = angle + Atan(-((4*angle)*(2*point - coord.distance))/coord.square)
                            endif

                            call MoveLocation(LOC, newX, newY)
                            set terrainZ = GetLocationZ(LOC)

                            // arced movement
                            if height == 0. and pitch == 0. then
                                set newZ = coord.z - terrainZ
                            else
                                set newZ = coord.z - terrainZ + coord.slope*point
                                if height != 0. then
                                    set newZ = newZ + (4*height*point*(coord.distance - point)/coord.square)
                                    //set pitch = pitch - Atan(((4*height)*(2*point - coord.distance))/coord.square)*bj_RADTODEG
                                endif
                            endif
   
                            call effect.orient(newX - coord.x, newY - coord.y, newZ - coord.z)
                            call effect.move(newX, newY, newZ)
                            set coord.x = newX
                            set coord.y = newY
                            set coord.z = newZ

                            // onTerrain event
                            if this.onTerrain.exists then
                                if coord.z < 0. and allocated then
                                    if this.onTerrain() then
                                        call .terminate()
                                    endif
                                endif
                            endif
                        endif
                    else
                        set i = remove(i)
                    endif
                set i = i + 1
            endloop
        endmethod

        private method reset takes nothing returns nothing
            set source       = null
            set target       = null
            set owner        = null
            set data         = 0
            set angle        = 0
            set height       = 0
            set distance     = 0
            set mspeed       = 0
            set acceleration = 0
            set collision    = 0
            set damage       = 0
            set zoffset      = 0
            set dead         = false
            set launched     = false
        endmethod

        method launch takes nothing returns nothing
            if not launched and not dead then
                set launched = true
            endif
        endmethod
        /* --------------------------- Main Creator method -------------------------- */
        static method create takes real x, real y, real z, real angle, real distance, real impactZ returns thistype
            local thistype this = thistype.allocate()
            local real impactX = x + distance*Cos(angle)
            local real impactY = y + distance*Sin(angle)
            //--------------------------------------------

            call reset()
            set coord          = Coordinates.create(x, y, z, impactX, impactY, impactZ)
            set effect         = Effect.create(x, y, z)
            set allocated      = true
            set didx           = didx + 1
            set missiles[didx] = this

            if didx == 0 then
                call TimerStart(t, PERIOD, true, function thistype.onLoop)
            endif

            return this
        endmethod
        /* -------------------------------- Wrappers -------------------------------- */
        static method new takes real fromX, real fromY, real fromZ, real toX, real toY, real toZ returns thistype
            local real dx = toX - fromX
            local real dy = toY - fromY
            local real dz = toZ - fromZ

            return create(fromX, fromY, fromZ, Atan2(dy, dx), SquareRoot(dx*dx + dy*dy), toZ)
        endmethod

        static method newEx takes real fromX, real fromY, real fromZ, real angle, real distance, real toZ returns thistype
            return create(fromX, fromY, fromZ, angle, distance, toZ)
        endmethod

        static method newHoming takes real fromX, real fromY, real fromZ, unit target, real zoffset returns thistype
            return new(fromX, fromY, fromZ, GetUnitX(target), GetUnitY(target), GetUnitFlyHeight(target) + zoffset)
        endmethod
    endstruct
endlibrary
