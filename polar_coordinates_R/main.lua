local mod = RegisterMod("polar_coordinates", 1)

local rLeft=false
local rRight=false
local rUp=false
local rDown=false
local rShootLeft=false
local rShootRight=false
local rShootUp=false
local rShootDown=false
local lrLeft=false
local lrRight=false
local lrUp=false
local lrDown=false
local lrShootLeft=false
local lrShootRight=false
local lrShootUp=false
local lrShootDown=false
function mod:getPlayerAction(_)
    lrLeft=rLeft
    lrRight=rRight
    lrDown=rDown
    lrUp=rUp
    lrShootLeft=rShootLeft
    lrShootRight=rShootRight
    lrShootDown=rShootDown
    lrShootUp=rShootUp
    if Input.IsActionPressed(ButtonAction.ACTION_LEFT, 0) then
        rLeft=true
    else
        rLeft=false
    end
    if Input.IsActionPressed(ButtonAction.ACTION_RIGHT, 0) then
        rRight=true
    else 
        rRight=false
    end
    if Input.IsActionPressed(ButtonAction.ACTION_UP, 0) then
        rUp=true
    else 
        rUp=false
    end
    if Input.IsActionPressed(ButtonAction.ACTION_DOWN, 0) then
        rDown=true
    else 
        rDown=false
    end
    if Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, 0) then
        rShootLeft=true
    else 
        rShootLeft=false
    end
    if Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, 0) then
        rShootRight=true
    else 
        rShootRight=false
    end
    if Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, 0) then
        rShootUp=true
    else 
        rShootUp=false
    end
    if Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, 0) then
        rShootDown=true
    else 
        rShootDown=false
    end
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.getPlayerAction)

function mod:IgnorePlayerAction(Ent, InputH, ButtonA)
    if Ent == nil then
        return nil
    end
    if InputH == InputHook.IS_ACTION_PRESSED then
        if ButtonA==ButtonAction.ACTION_SHOOTLEFT then
            return false
        end
        if ButtonA==ButtonAction.ACTION_SHOOTRIGHT then
            return false
        end
    elseif InputH==InputHook.GET_ACTION_VALUE then
        if ButtonA==ButtonAction.ACTION_LEFT then
            return 0
        end
        if ButtonA==ButtonAction.ACTION_RIGHT then
            return 0
        end
        if ButtonA==ButtonAction.ACTION_UP then
            return 0
        end
        if ButtonA==ButtonAction.ACTION_DOWN then
            return 0
        end
        if ButtonA==ButtonAction.ACTION_SHOOTLEFT then
            return 0
        end
        if ButtonA==ButtonAction.ACTION_SHOOTRIGHT then
            return 0
        end
    end
    return nil
end
mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, mod.IgnorePlayerAction)

local sprM = Sprite()
local sprS = Sprite()
sprM:Load("gfx/move_arrow.anm2", true)
sprM:Play("move", false)
sprM.Scale=Vector.One/10
sprS:Load("gfx/shoot_arrow.anm2", true)
sprS:Play("shoot", false)
sprS.Scale=Vector.One/10
local move_dir=Vector.One:Normalized()
local shoot_dir=-Vector.One:Normalized()
function mod:polar_coordinates(_)
    local player=Isaac.GetPlayer()
    local shoot_speed=player.ShotSpeed
    local move_speed=player.MoveSpeed
    if rLeft then
        move_dir=move_dir:Rotated(-move_speed*3)
    end
    if rRight then
        move_dir=move_dir:Rotated(move_speed*3)
    end
    if rUp or rDown then
        if rUp then
            player.Velocity=player.Velocity+move_dir*move_speed
        end
        if rDown then
            player.Velocity=player.Velocity-move_dir*move_speed
        end
    end
    if rShootLeft then
        shoot_dir=shoot_dir:Rotated(-shoot_speed*3)
    end
    if rShootRight then
        shoot_dir=shoot_dir:Rotated(shoot_speed*3)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.polar_coordinates)

function mod:renderArrow()
    local player=Isaac.GetPlayer()
    sprM.Rotation=move_dir:GetAngleDegrees()
    sprM:Render(Isaac.WorldToScreen(player.Position)+move_dir*30)
    sprS.Rotation=shoot_dir:GetAngleDegrees()
    sprS:Render(Isaac.WorldToScreen(player.Position)+shoot_dir*30)
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.renderArrow)

function mod:playerFireTear(Ent)
    if Ent==nil then
        return
    end
    if rShootDown or (Ent.Type==7 and lrShootDown) then
        Ent.Velocity=-shoot_dir*Ent.Velocity:Length() 
    else
        Ent.Velocity=shoot_dir*Ent.Velocity:Length() 
    end
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, mod.playerFireTear)
mod:AddCallback(ModCallbacks.MC_POST_FIRE_BOMB, mod.playerFireTear)
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TECH_X_LASER, mod.playerFireTear)

function mod:playerFireBrimStone(Ent)
    if Ent==nil then
        return
    end
    if rShootDown or lrShootDown then
        Ent.Angle=shoot_dir:GetAngleDegrees()+180
    else
        Ent.Angle=shoot_dir:GetAngleDegrees()
    end
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_BRIMSTONE, mod.playerFireBrimStone)
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TECH_LASER, mod.playerFireBrimStone)

local deathProofNum=0
function mod:spawnDeathCertificate(isC)
    if isC then
        return
    end
    for i = 1, deathProofNum, 1 do
        Game():Spawn(5,100,Game():GetRoom():GetRandomPosition(1),Vector(0, 0),nil,628,Game():GetRoom():GetSpawnSeed())
    end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.spawnDeathCertificate)

function mod:spawnMoreDeathCertificate()
    deathProofNum=deathProofNum+1
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_END, mod.spawnMoreDeathCertificate)