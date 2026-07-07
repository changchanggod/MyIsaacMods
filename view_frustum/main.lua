local mod = RegisterMod("view_frustum", 1)
local view_rotate_speed=10
local grid_half_size=20
local view_spr=Sprite()
view_spr:Load("gfx/view.anm2", true)
view_spr:Play("view",false)

local function GetFastestAngleDir(angleA, angleB)
    local full = 360
    -- 先把角度规整到 [0, 360) 区间
    local a = angleA % full
    local b = angleB % full
    if a==b then
        return 0
    end
    -- 正向增量：b 不断增加到 a 的差值
    local diffAdd = (a - b) % full
    -- 反向减量：b 不断减少到 a 的差值
    local diffSub = full - diffAdd
    local vel=1
    if math.min(diffAdd,diffSub)<view_rotate_speed then
        vel=math.min(diffAdd,diffSub)/view_rotate_speed
    end
    if diffAdd <= diffSub then
        return vel
    else
        return -vel
    end
end

function mod:view_frustum()
    local player= Isaac.GetPlayer()
    if Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, 0) or
    Input.IsActionPressed(ButtonAction.ACTION_SHOOTUP, 0) or
    Input.IsActionPressed(ButtonAction.ACTION_SHOOTRIGHT, 0) or
    Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, 0)
     then
        local aimAngle=player:GetAimDirection():GetAngleDegrees()
        view_spr.Rotation=view_spr.Rotation+view_rotate_speed*GetFastestAngleDir(aimAngle,view_spr.Rotation)
    end
    view_spr:Render(Isaac.WorldToScreen(player.Position+Vector.FromAngle(view_spr.Rotation)*grid_half_size))
end
function mod:darkenRoom()
    Game():Darken(1,10000)
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.view_frustum)
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.darkenRoom)