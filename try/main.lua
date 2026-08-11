local mod=RegisterMod("try", 1)
local MASK = 0x3FF      -- 10bit 掩码 (0~1023，适配上限1000)
local SHIFT_VAR = 10
local SHIFT_SUB = 20
local json=require("json")
local function TypeToNum(Type, Var, SubType)
    Type = Type & MASK
    Var  = Var  & MASK
    SubType = SubType & MASK
    return (Type << SHIFT_SUB) | (SubType << SHIFT_VAR) | Var
end
mod.Cham={}
if mod:HasData() then
    local data=mod:LoadData()
    mod.Cham=json.decode(data)
end
---@param EntN EntityNPC
function mod:try(EntN)
    if EntN:IsChampion() then
        mod.Cham[tostring(TypeToNum(EntN.Type,EntN.Variant,EntN.SubType))]=true
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, mod.try)
function mod:saveMyData()
    mod:SaveData(json.encode(mod.Cham))
end
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT,mod.saveMyData)

local sprScale=0
local offsetScale=100
local function setArgs()
    if Input.IsButtonPressed(Keyboard.KEY_1,0) then
        sprScale=sprScale-0.5
    elseif Input.IsButtonPressed(Keyboard.KEY_2,0) then
        sprScale=sprScale+0.5
    elseif Input.IsButtonPressed(Keyboard.KEY_8,0) then
        offsetScale=offsetScale-0.5
    elseif Input.IsButtonPressed(Keyboard.KEY_9,0) then
        offsetScale=offsetScale+0.5
    end
    Isaac.RenderText("sprScale:"..tostring(sprScale),200,200,255,0,0,255)
    Isaac.RenderText("offsetScale:"..tostring(offsetScale),200,250,255,0,0,255)
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER,setArgs)


---@param npc  EntityNPC
function mod:onNpcRender(npc, _)
    local spr=npc:GetSprite()

    npc.SpriteOffset=Vector(offsetScale,sprScale)
    if npc.FlipX then
        npc.SpriteOffset=Vector(-100,100)
        
    end
    if spr.FlipY then
        npc.SpriteOffset=Vector(offsetScale- sprScale*2 ,sprScale)
        print(1)
    end
    local game = Game()
    local room = game:GetRoom()

    -- 获取房间中心世界坐标
    local centerPos = room:GetCenterPos()
    npc.Position=Vector(npc.Position.X,centerPos.Y)
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, mod.onNpcRender)

-- 进入新房间时执行
function mod:SpawnChampionGaper()
    local game = Game()
    local room = game:GetRoom()

    -- 获取房间中心世界坐标
    local centerPos = room:GetCenterPos()

    -- 在中心生成裂口尸，无变体、无子类型、初始速度为0
    local enemy = Isaac.Spawn(240, 0, 0, centerPos, Vector.Zero, nil)
end

-- 注册进入房间回调
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.SpawnChampionGaper)

-- l  Isaac.Spawn(240, 0, 0, Vector(0,280), Vector.Zero, nil)