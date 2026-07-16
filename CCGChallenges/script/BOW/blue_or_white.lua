local mod=CCGChallenges45768
local utils=require("script.CCG_utils")
local challengeName="blue or white"
local challengeId=utils.GetChallengeSafe(challengeName)
local myRNG=utils.getRNG()
if not challengeId then
    return nil
end
utils.allowChallengeSecretPath(challengeId, false)

local setting = nil
local resetting = false
local function reset()
    if type(mod.Data) ~= "table" then
        mod.Data = {}
    end
    mod.Data.BOWSetting = {
        soulHeartChance = 80
    }
    setting = mod.Data.BOWSetting
end
if mod.Data and mod.Data.BOWSetting then
    setting = mod.Data.BOWSetting
else
    reset()
end

function mod:blue_or_white(EntP)
    if Game().Challenge==challengeId and setting then
        if  EntP.Timeout>0
        and EntP.FrameCount==0
        and EntP.SubType~=8
        and EntP.SubType~=4 then
            local rand=myRNG:RandomInt(100)
            if rand<setting.soulHeartChance then
                EntP:Morph(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_HEART,8)
                print(EntP.FrameCount)
            else
                EntP:Morph(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_HEART,4)
                print(EntP.FrameCount)
            end
        end 
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, mod.blue_or_white,PickupVariant.PICKUP_HEART)
utils.addTrinket(challengeId,TrinketType.TRINKET_KEEPERS_BARGAIN | TrinketType.TRINKET_GOLDEN_FLAG)

---------------------------------------------------------------------
local BOW_MCM = {
    zh = {
        MN = "CCG挑战合集",
        ST = "蓝或白",
        T0 = "对应挑战："..challengeName,
        N0 = "永恒之心生成几率:",
        K0 = "里抹大拉击杀敌人时生成永恒之心取代红心的几率",
        N1 = "魂心生成几率:",
        K1 = "里抹大拉击杀敌人时生成魂心取代红心的几率",
        N2 = "重置",
        K2 = "将所有设置重置回默认值",
    },
    en = {
        MN = "CCG Challenge Collection",
        ST = challengeName,
        --T0 = "Corresponding Challenge: blue or white",
        N0 = "Eternal Heart Spawn Chance:",
        K0 = "Chance to spawn an Eternal Heart instead of a Red Heart when killing enemies with Tainted Magdalene",
        N1 = "Soul Heart Spawn Chance:",
        K1 = "Chance to spawn a Soul Heart instead of a Red Heart when killing enemies with Tainted Magdalene",
        N2 = "RESET ALL SETTINGS",
        K2 = "RESET ALL SETTINGS TO DEFAULT",
    }
}
if ModConfigMenu and setting ~= nil then
    local MN = utils.getMCMDes(BOW_MCM, "MN")
    local ST = utils.getMCMDes(BOW_MCM, "ST")
    ModConfigMenu.RemoveSubcategory(MN, ST)
    if utils.getMCMDes(BOW_MCM, "T0") then
        ModConfigMenu.AddTitle(MN, ST, utils.getMCMDes(BOW_MCM, "T0"))
        ModConfigMenu.AddSpace(MN, ST)
    end
    ModConfigMenu.AddSetting(MN, ST, {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function()
            return (100-setting.soulHeartChance)/5
        end,
        Minimum = 0,
        Maximum = 20,
        Display = function()
            return utils.getMCMDes(BOW_MCM, "N0") .. 100-setting.soulHeartChance.."%"
        end,
        OnChange = function(n)
            setting.soulHeartChance = 100 - n*5
        end,
        Info = { utils.getMCMDes(BOW_MCM, "K0") }
    })
    ModConfigMenu.AddSetting(MN, ST, {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function()
            return setting.soulHeartChance/5
        end,
        Minimum = 0,
        Maximum = 20,
        Display = function()
            return utils.getMCMDes(BOW_MCM, "N1") .. setting.soulHeartChance.."%"
        end,
        OnChange = function(n)
            setting.soulHeartChance = n*5
        end,
        Info = { utils.getMCMDes(BOW_MCM, "K1") }
    })
    ModConfigMenu.AddSpace(MN, ST)
    ModConfigMenu.AddSetting(MN, ST, {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function()
            return resetting
        end,
        Display = function()
            return utils.getMCMDes(BOW_MCM, "N2")
        end,
        OnChange = function(boolean)
            resetting = boolean
            reset()
        end,
        Info = { utils.getMCMDes(BOW_MCM, "K2") }
    })
end
---------------------------------------------------------------------