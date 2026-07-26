local mod = RegisterMod("fading chests", 1)
local json=require("json")
local eternalChestFrame=65
local chestVariant={
    [PickupVariant.PICKUP_CHEST]=true,
    [PickupVariant.PICKUP_BOMBCHEST]=true,
    [PickupVariant.PICKUP_SPIKEDCHEST]=true,
    [PickupVariant.PICKUP_ETERNALCHEST]=true,
    [PickupVariant.PICKUP_MIMICCHEST]=true,
    [PickupVariant.PICKUP_OLDCHEST]=true,
    [PickupVariant.PICKUP_WOODENCHEST]=true,
    [PickupVariant.PICKUP_MEGACHEST]=true,
    [PickupVariant.PICKUP_HAUNTEDCHEST]=true,
    [PickupVariant.PICKUP_LOCKEDCHEST]=true,
    [PickupVariant.PICKUP_REDCHEST]=true,
}
local FadeType={
    fade=1,
    scale=2,
    timeOut=3,
}
local speed={
    [FadeType.fade] ={
        0.01,
        0.03,
        0.05,
        0.1,
        0.3
    },
    [FadeType.scale] ={
        0.01,
        0.03,
        0.05,
        0.1,
        0.3
    },
    [FadeType.timeOut] ={
        60,
        30,
        15,
        10,
        5
    },
}
if mod:HasData() then
    local data=mod:LoadData()
    mod.setting=json.decode(data)
else
    mod.setting={
        fadeType=FadeType.fade,
        fadeRate=1,
    }
end
local eternalChest={}
---@param EntPick  EntityPickup
local function removeChest(EntPick)
    if EntPick.Variant==PickupVariant.PICKUP_ETERNALCHEST then
        if eternalChest[EntPick.Index]==nil then
            eternalChest[EntPick.Index]=EntPick.FrameCount
            return
        elseif EntPick.FrameCount-eternalChest[EntPick.Index]>eternalChestFrame then
            EntPick:Remove()
        end
    else
        EntPick:Remove()
    end
end
---@param EntPick  EntityPickup
function mod:fadeChest(EntPick)
    local isItem=EntPick.Variant==100
    if chestVariant[EntPick.Variant] or isItem then
        local rate=speed[mod.setting.fadeType][mod.setting.fadeRate]
        if  EntPick.SubType == ChestSubType.CHEST_OPENED then --ChestSubType.CHEST_OPENED=0. when pickup is an item, subType=0 means empty, so they are the same situations
            if mod.setting.fadeType==FadeType.fade then
                local spr = EntPick:GetSprite()
                if spr.Color.A > 0 then
                    spr.Color.A = math.max(spr.Color.A - rate, 0)
                elseif EntPick.SpriteScale.X>0 and EntPick.SpriteScale.Y>0 then
                    EntPick.SpriteScale.X=math.max(EntPick.SpriteScale.X- rate,0)
                    EntPick.SpriteScale.Y=math.max(EntPick.SpriteScale.Y- rate,0)
                else
                    removeChest(EntPick)
                end
            elseif mod.setting.fadeType==FadeType.scale then
                if EntPick.SpriteScale.X>0 and EntPick.SpriteScale.Y>0 then
                    EntPick.SpriteScale.X=math.max(EntPick.SpriteScale.X- rate,0)
                    EntPick.SpriteScale.Y=math.max(EntPick.SpriteScale.Y- rate,0)
                else
                    removeChest(EntPick)
                end
            elseif mod.setting.fadeType==FadeType.timeOut then
                if EntPick.Timeout<0 then
                    EntPick.Timeout=rate
                end
                if EntPick.Variant==PickupVariant.PICKUP_ETERNALCHEST then
                     if eternalChest[EntPick.Index]==nil then
                        eternalChest[EntPick.Index]=EntPick.FrameCount
                        EntPick.Timeout=rate
                    elseif EntPick.FrameCount-eternalChest[EntPick.Index]<=eternalChestFrame then
                        EntPick.Timeout=rate
                    end
                end
            end
        else
            if EntPick.Variant==PickupVariant.PICKUP_ETERNALCHEST then
                eternalChest[EntPick.Index]=nil
            end
            if mod.setting.fadeType==FadeType.fade then
                local spr = EntPick:GetSprite()
                if spr.Color.A < 1 then
                    spr.Color.A = math.min(spr.Color.A + rate, 1)
                end
                if EntPick.SpriteScale.X<1 and EntPick.SpriteScale.Y<1 then
                    EntPick.SpriteScale.X=math.min(EntPick.SpriteScale.X+ rate,1)
                    EntPick.SpriteScale.Y=math.min(EntPick.SpriteScale.Y+ rate,1)
                end
            elseif mod.setting.fadeType==FadeType.scale then
                if EntPick.SpriteScale.X<1 and EntPick.SpriteScale.Y<1 then
                    EntPick.SpriteScale.X=math.min(EntPick.SpriteScale.X+ rate,1)
                    EntPick.SpriteScale.Y=math.min(EntPick.SpriteScale.Y+ rate,1)
                end
            elseif mod.setting.fadeType==FadeType.timeOut then
                EntPick.Timeout=-1
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, mod.fadeChest)

function mod:ignoreOpenChestCollision(EntPick, _, _)
    if chestVariant[EntPick.Variant] and EntPick.SubType == ChestSubType.CHEST_OPENED then
        return true
    end
    if EntPick.Variant==100 and EntPick.SubType==0 then
        return true
    end
end

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.ignoreOpenChestCollision)

-- function mod:try(EntPick)
--     print(EntPick.Variant," ",EntPick.SubType)
-- end

-- mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, mod.try)
---l local entity = Isaac.GetRoomEntities()[5] print(entity.Type)


--------------------------------------------------------------------------------------------

local FC_MCM={
    zh = {
        MN = "箱子自动消失",
        ST = "设置",
        N0 = "箱子消失方式:",
        O0 = {"淡出","缩小","闪烁消失"},
        K0 = "可以从作者预设计的消失方式中进行选择",
        N1 = "消失速率:",
        O1 = {"极慢","慢","中","快","极快"},
        K1 = "箱子消失的速度",
    },
    en = {
        MN = "Fading Chests",
        ST = "Settings",
        N0 = "Fading Animation Style:",
        O0 = {"Fade Out","Shrink","Blink Away"},
        K0 = "Select from several custom fading animations made by the author.",
        N1 = "Fading Speed:",
        O1 = {"Very Slow","Slow","Normal","Fast","Very Fast"},
        K1 = "Adjust how fast chests fade away.",
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
    local MN=getMCMDes("MN")
    local ST=getMCMDes("ST")
    ModConfigMenu.RemoveSubcategory(MN, ST)
    ModConfigMenu.AddSpace(MN, ST)
    ModConfigMenu.AddSetting(MN, ST, {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function()
            return mod.setting.fadeType
        end,
        Minimum = 1,
        Maximum = 3,
        Display = function()
            return getMCMDes("N0")..getMCMDes("O0")[mod.setting.fadeType]
        end,
        OnChange = function(n)
            mod.setting.fadeType=n
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
            return getMCMDes("N1")..getMCMDes("O1")[mod.setting.fadeRate]
        end,
        OnChange = function(n)
            mod.setting.fadeRate=n
        end,
        Info = { getMCMDes("K1") }
    })
end

