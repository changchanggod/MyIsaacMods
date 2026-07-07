local mod = RegisterMod("mature_order", 1)
local myRNG = RNG()
myRNG:SetSeed(Random()%1000000000+1,1)
local spr = Sprite()
local sprWidth,sprHeight=976,284
spr:Load("gfx/mature_order.anm2", true)
spr:Play("mature_order", false)
local max_down=Isaac.GetScreenHeight ( )
local max_right=Isaac.GetScreenWidth ( )
local spr_pos=Vector.Zero
local spr_scale=Vector.Zero
local spr_rotation_speed=0
local function selectPos()
    spr_pos=Vector(myRNG:RandomFloat()*(max_right-sprWidth*spr.Scale.X)+sprWidth*spr.Scale.X/2,myRNG:RandomFloat()*(max_down-sprHeight*spr.Scale.Y)+sprHeight*spr.Scale.Y/2)
end
local function selectScale()
    local sca=(myRNG:RandomInt(20)+30)/100
    spr_scale=Vector(sca,sca)
end
local function setRotateSpeed()
    local random=myRNG:RandomInt(25)
    random=random-5
    if random>=6 then
        spr_rotation_speed=0
    else
        spr_rotation_speed=random/10
    end
end
function mod:show_mature_order(_)
    max_down=Isaac.GetScreenHeight ( )
    max_right=Isaac.GetScreenWidth ( )
    if not spr:IsLoaded() then
        print("load fail")
        return
    end
    local ran=Random()%2000
    if ran==0 then
        selectScale()
        selectPos()
        setRotateSpeed()
    end
    spr.Scale=spr_scale
    spr.Rotation=spr.Rotation+spr_rotation_speed
    spr:Render(spr_pos)
end
function mod:EnterRoom()
    selectScale()
    selectPos()
    setRotateSpeed()
    spr.Rotation=0
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.show_mature_order)
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.EnterRoom)