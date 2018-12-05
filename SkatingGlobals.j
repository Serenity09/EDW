//all the globals used in the skating functions

library SkatingGlobals requires GameGlobalConstants
    globals
        constant real SlowIceSpeed = 8.5
        constant real MediumIceSpeed = 12.5
        constant real FastIceSpeed = 17.5
        //if a unit has an increased speed due to a booster, then this is the rate that it returns to normal speed
        //this must be greater than 1, the larger it is the quicker the return to normal speed
        constant real SkateFallOff = 1.01
        
        //for RSnow
        constant real VelocityAcceleration2 = .3
        
        //the factor of speed to carry over from any icetype to sand
        constant real ICE2MOMENTUMFACTOR = .5

        
        real array SkateSpeed[NumberPlayers]
        real array VelocityX[NumberPlayers]
        real array VelocityY[NumberPlayers]
        
        //for Rocky Snow
        real array RSFacing[NumberPlayers]
        constant real MAXRSVELOCITY = 10
        constant real MAXVELOCITY = 15
                
        boolean array CanSteer[NumberPlayers]
        
        group OnSandGroup = CreateGroup()
        group OnSnowGroup = CreateGroup()
        group OnRSnowGroup = CreateGroup()
        
        integer NumberOnSand = 0
        integer NumberOnSnow = 0
        integer NumberOnRSnow = 0
    endglobals
endlibrary

function InitTrig_SkatingGlobals takes nothing returns nothing
    local integer i = 0
    
    loop
    exitwhen i >= NumberPlayers
        set SkateSpeed[i] = 0
        set VelocityX[i] = 0
        set VelocityY[i] = 0
        set CanSteer[i] = false
        
        set i = i + 1
    endloop
endfunction