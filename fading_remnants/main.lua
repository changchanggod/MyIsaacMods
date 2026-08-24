local mod = RegisterMod("Fading Remnants", 1)
local json = require("json")
local eternalChestFrame = 55
local hasFlip=false
local chestVariant = {
    [PickupVariant.PICKUP_CHEST] = true,
    [PickupVariant.PICKUP_BOMBCHEST] = true,
    [PickupVariant.PICKUP_SPIKEDCHEST] = true,
    [PickupVariant.PICKUP_ETERNALCHEST] = true,
    [PickupVariant.PICKUP_MIMICCHEST] = true,
    [PickupVariant.PICKUP_OLDCHEST] = true,
    [PickupVariant.PICKUP_WOODENCHEST] = true,
    [PickupVariant.PICKUP_MEGACHEST] = true,
    [PickupVariant.PICKUP_HAUNTEDCHEST] = true,
    [PickupVariant.PICKUP_LOCKEDCHEST] = true,
    [PickupVariant.PICKUP_REDCHEST] = true,
}
local FadeType = {
    fade = 1,
    scale = 2,
}
local speed = {
    [FadeType.fade] = {
        0.005,
        0.01,
        0.03,
        0.05,
        0.1
    },
    [FadeType.scale] = {
        0.005,
        0.01,
        0.03,
        0.05,
        0.1
    },
}
local delay = { 120, 60, 30, 10, 5 }

local function reset()
    mod.setting = {
        fadeType = FadeType.fade,
        fadeRate = 3,
        fadeDelay = 3,
    }
end

if mod:HasData() then
    local data = mod:LoadData()
    mod.setting = json.decode(data)
    if type(mod.setting) ~= "table"
        or not mod.setting.fadeDelay
        or not mod.setting.fadeRate
        or not mod.setting.fadeType then
        reset()
    end
else
    reset()
end
local fadeDelay = {}
local function getEntityKey(Ent)
    return Ent.Type .. ":" .. Ent.Variant .. ":" .. Ent.Index
end

---@param Ent  Entity
local function isInFadeDelay(Ent)
    local key = getEntityKey(Ent)
    if fadeDelay[key] == nil then
        fadeDelay[key] = Ent.FrameCount
        return true
    elseif Ent.FrameCount - fadeDelay[key] >= delay[mod.setting.fadeDelay] then
        return false
    end
    return true
end

local function clearFadeDelay(Ent)
    fadeDelay[getEntityKey(Ent)] = nil
end

-- Sprite.Color and Entity.SpriteScale are value properties.  Their individual
-- components must be copied into a new Color/Vector and assigned back.
local function setSpriteAlpha(sprite, alpha)
    local color = sprite.Color
    sprite.Color = Color(color.R, color.G, color.B, alpha, color.RO, color.GO, color.BO)
end

local function setEntityScale(Ent, x, y)
    Ent.SpriteScale = Vector(x, y)
end

local function fadeEntity(Ent, onFinished)
    local rate = speed[mod.setting.fadeType][mod.setting.fadeRate]
    if mod.setting.fadeType == FadeType.fade then
        local spr = Ent:GetSprite()
        local alpha = spr.Color.A
        if alpha > 0 then
            setSpriteAlpha(spr, math.max(alpha - rate, 0))
            return
        end
    end

    local scale = Ent.SpriteScale
    if scale.X > 0 and scale.Y > 0 then
        setEntityScale(Ent, math.max(scale.X - rate, 0), math.max(scale.Y - rate, 0))
    else
        onFinished(Ent)
    end
end

local eternalChest = {}
---@param EntPick  EntityPickup
local function removeChest(EntPick)
    local key = getEntityKey(EntPick)
    if EntPick.Variant == PickupVariant.PICKUP_ETERNALCHEST then
        if eternalChest[key] == nil then
            eternalChest[key] = EntPick.FrameCount
            return
        elseif EntPick.FrameCount - eternalChest[key] > eternalChestFrame then
            EntPick:Remove()
            eternalChest[key] = nil
            clearFadeDelay(EntPick)
        end
    else
        EntPick:Remove()
        clearFadeDelay(EntPick)
    end
end
---@param EntPick  EntityPickup
function mod:fadeChest(EntPick)
    local player=Isaac.GetPlayer()
    local isItem = EntPick.Variant == 100
    if isItem and hasFlip then
        if REPENTOGON then
            if EntPick:GetFlipCollectible() then
                return
            end
        else
            return
        end
    end
    if chestVariant[EntPick.Variant] or isItem then
        if EntPick.SubType == ChestSubType.CHEST_OPENED then --ChestSubType.CHEST_OPENED=0. when pickup is an item, subType=0 means empty, so they are the same situations
            if isInFadeDelay(EntPick) then
                return
            end
            fadeEntity(EntPick, removeChest)
        else
            clearFadeDelay(EntPick)
            if EntPick.Variant == PickupVariant.PICKUP_ETERNALCHEST then
                local key = getEntityKey(EntPick)
                eternalChest[key] = nil
                local rate = speed[mod.setting.fadeType][mod.setting.fadeRate]
                if mod.setting.fadeType == FadeType.fade then
                    local spr = EntPick:GetSprite()
                    if spr.Color.A < 1 then
                        setSpriteAlpha(spr, math.min(spr.Color.A + rate, 1))
                    end
                    local scale = EntPick.SpriteScale
                    if scale.X < 1 and scale.Y < 1 then
                        setEntityScale(EntPick, math.min(scale.X + rate, 1), math.min(scale.Y + rate, 1))
                    end
                elseif mod.setting.fadeType == FadeType.scale then
                    local scale = EntPick.SpriteScale
                    if scale.X < 1 and scale.Y < 1 then
                        setEntityScale(EntPick, math.min(scale.X + rate, 1), math.min(scale.Y + rate, 1))
                    end
                end
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, mod.fadeChest)

function mod:ignoreOpenChestCollision(EntPick, _, _)
    if chestVariant[EntPick.Variant] and EntPick.SubType == ChestSubType.CHEST_OPENED then
        return true
    end
    if EntPick.Variant == 100 and EntPick.SubType == 0 then
        return true
    end
end

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.ignoreOpenChestCollision)

function mod:fadeSlotMachine()
    local entities = Isaac.GetRoomEntities()
    for _, value in pairs(entities) do
        if value.Type == 6 then
            if value:GetSprite():GetAnimation() == "Broken" or value:GetSprite():GetAnimation() == "Death" then
                -- Slot machines are not pickups, so MC_PRE_PICKUP_COLLISION cannot
                -- disable their collision.  Remove it as soon as they become debris.
                value.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                if not isInFadeDelay(value) then
                    fadeEntity(value, function(Ent)
                        clearFadeDelay(Ent)
                        Ent:Remove()
                    end)
                end
            else
                clearFadeDelay(value)
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.fadeSlotMachine)

function mod:isEnterRoomWithFlip()
    hasFlip=Isaac.GetPlayer():HasCollectible(CollectibleType.COLLECTIBLE_FLIP,true)
    if not hasFlip then
        local roomEntities = Isaac.GetRoomEntities()
        for i = 1, #roomEntities do
            local entity = roomEntities[i]
            if entity.Type==EntityType.ENTITY_PICKUP and entity.Variant==PickupVariant.PICKUP_COLLECTIBLE and entity.SubType==CollectibleType.COLLECTIBLE_FLIP then
                hasFlip=true
                break
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM,mod.isEnterRoomWithFlip)

function mod:clearTable()
    fadeDelay = {}
    eternalChest = {}
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.clearTable)

function mod:saveMyData()
    mod:SaveData(json.encode(mod.setting))
end

mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.saveMyData)


--------------------------------------------------------------------------------------------

local FC_MCM = {
    zh = {
        MN = "残物渐隐",
        ST = "设置",
        N0 = "无用实体消失方式:",
        O0 = { "淡出", "缩小" },
        K0 = "可以从作者预设计的消失方式中进行选择",
        N1 = "消失速率:",
        O1 = { "极慢", "慢", "中", "快", "极快" },
        K1 = "无用实体消失的速度",
        N2 = "消失延迟:",
        O2 = { "极长", "长", "中", "短", "极短" },
        K2 = "无用实体生成后，等待多久才开始消失"
    },
    en = {
        MN = "Fading Remnants",
        ST = "Settings",
        N0 = "Fading Animation Style:",
        O0 = { "Fade Out", "Shrink" },
        K0 = "Select from several custom fading animations made by the author.",
        N1 = "Fading Speed:",
        O1 = { "Very Slow", "Slow", "Normal", "Fast", "Very Fast" },
        K1 = "Adjust how fast the entity fade away.",
        N2 = "Fade Delay:",
        O2 = { "Very Long", "Long", "Normal", "Short", "Very Short" },
        K2 = "How long the entity waits before starting to fade."
    }
}

local function getMCMDes(key)
    local lan = Options.Language
    lan = FC_MCM[lan] and lan or "en"
    local zhMCM = ModConfigMenu.i18n == "Chinese"
    if zhMCM and lan ~= "zh" then
        lan = "zh"
    elseif not (zhMCM) and lan == "zh" then
        lan = "en"
    end
    return FC_MCM[lan] and FC_MCM[lan][key]
end

if ModConfigMenu and mod.setting then
    local MN = getMCMDes("MN")
    local ST = getMCMDes("ST")
    ModConfigMenu.RemoveSubcategory(MN, ST)
    ModConfigMenu.AddSpace(MN, ST)

    ModConfigMenu.AddSetting(MN, ST, {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function()
            return mod.setting.fadeType
        end,
        Minimum = 1,
        Maximum = 2,
        Display = function()
            return getMCMDes("N0") .. getMCMDes("O0")[mod.setting.fadeType]
        end,
        OnChange = function(n)
            mod.setting.fadeType = n
        end,
        Info = { getMCMDes("K0") }
    })

    ModConfigMenu.AddSetting(MN, ST, {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function()
            return mod.setting.fadeRate
        end,
        Minimum = 1,
        Maximum = 5,
        Display = function()
            return getMCMDes("N1") .. getMCMDes("O1")[mod.setting.fadeRate]
        end,
        OnChange = function(n)
            mod.setting.fadeRate = n
        end,
        Info = { getMCMDes("K1") }
    })

    ModConfigMenu.AddSetting(MN, ST, {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function()
            return mod.setting.fadeDelay
        end,
        Minimum = 1,
        Maximum = 5,
        Display = function()
            return getMCMDes("N2") .. getMCMDes("O2")[mod.setting.fadeDelay]
        end,
        OnChange = function(n)
            mod.setting.fadeDelay = n
        end,
        Info = { getMCMDes("K2") }
    })
end
