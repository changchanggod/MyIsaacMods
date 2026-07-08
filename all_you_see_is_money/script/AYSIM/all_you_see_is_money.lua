local mod= CCGChallenges45768
---@type number
local challengeId = Isaac.GetChallengeIdByName("all_you_see_is_money")
if challengeId == -1 then
    Isaac.ConsoleOutput("[Error]:challenge all_you_see_is_money load failed")
    return nil
end

local setting=nil
local resetting=false
local function reset()
    if type(mod.Data)~=table then
        mod.Data={}
    end
    mod.Data.AYSIMSetting={
        totalScale=1,
        PennyScale = 5,
        DoublePennyScale = 7,
        NickelScale = 9,
        LuckyPennyScale = 10,
        StickyNickelScale = 9,
        DimeScale = 15,
        GoldenPennyScale = 20,
    }
    setting=mod.Data.AYSIMSetting
end
if mod.Data and mod.Data.AYSIMSetting then
    setting=mod.Data.AYSIMSetting
else
    reset()
end

---@param EntPick EntityPickup
local function enlargeTheMoney(_, EntPick)
    if Game().Challenge==challengeId and setting~=nil then
        if EntPick.Type == EntityType.ENTITY_PICKUP and EntPick.Variant == 20 then
            local scale = 1
            if EntPick.SubType == 1 then
                scale = setting.PennyScale
            elseif EntPick.SubType == 2 then
                scale = setting.NickelScale
            elseif EntPick.SubType == 3 then
                scale = setting.DimeScale
            elseif EntPick.SubType == 4 then
                scale = setting.DoublePennyScale
            elseif EntPick.SubType == 5 then
                scale = setting.LuckyPennyScale
            elseif EntPick.SubType == 6 then
                scale = setting.StickyNickelScale
            elseif EntPick.SubType == 7 then
                scale = setting.GoldenPennyScale
            end
            EntPick.SpriteScale=Vector.One*scale*setting.totalScale
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, enlargeTheMoney)
local AYSIM_MCM={
    zh = {
        MN = "目尽金银",
        ST = "硬币缩放倍率调整",
        N0 = "总缩放倍率:",
        K0 = "该缩放倍率将作用于每一个硬币实体，乘算叠加",
        N1 = "硬币缩放倍率:",
        K1 = "5.20.1实体对应的缩放倍率",
        N2 = "镍币缩放倍率:",
        K2 = "5.20.2实体对应的缩放倍率",
        N3 = "铸币缩放倍率:",
        K3 = "5.20.3实体对应的缩放倍率",
        N4 = "双硬币币缩放倍率:",
        K4 = "5.20.4实体对应的缩放倍率",
        N5 = "幸运硬币缩放倍率:",
        K5 = "5.20.5实体对应的缩放倍率",
        N6 = "黏性镍币缩放倍率:",
        K6 = "5.20.6实体对应的缩放倍率",
        N7 = "金硬币缩放倍率:",
        K7 = "5.20.7实体对应的缩放倍率",
        N8 = "重置倍率",
        K8 = "将所有倍率重置回默认值",
    },
    en = {
        MN = "All You See Is Money",
        ST = "Coin Scale Adjustment",
        N0 = "Total Scale:",
        K0 = "This scale will be applied to every coin entity, multiplied together",
        N1 = "Penny Scale:",
        K1 = "Scale for 5.20.1 entity",
        N2 = "Nickel Scale:",
        K2 = "Scale for 5.20.2 entity",
        N3 = "Dime Scale:",
        K3 = "Scale for 5.20.3 entity",
        N4 = "Double Penny Scale:",
        K4 = "Scale for 5.20.4 entity",
        N5 = "Lucky Penny Scale:",
        K5 = "Scale for 5.20.5 entity",
        N6 = "Sticky Nickel Scale:",
        K6 = "Scale for 5.20.6 entity",
        N7 = "Golden Penny Scale:",
        K7 = "Scale for 5.20.7 entity",
        N8 = "RESET ALL SETTINGS",
        K8 = "RESET ALL SETTINGS TO DEFAULT",
    }
}
local function getMCMDes(key)
    local lan = Options.Language
    lan = AYSIM_MCM[lan] and lan or "en"
    local zhMCM = ModConfigMenu.i18n == "Chinese"
    if zhMCM and lan ~= "zh" then
        lan = "zh"
    elseif not (zhMCM) and lan == "zh" then
        lan = "en"
    end
    return AYSIM_MCM[lan] and AYSIM_MCM[lan][key]
end
if ModConfigMenu and setting~=nil then
    local MN=getMCMDes("MN")
    local ST=getMCMDes("ST")
    ModConfigMenu.RemoveSubcategory(MN, ST)
    ModConfigMenu.AddSetting(MN, ST, {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function()
            if setting.totalScale>=1 then
                return setting.totalScale
            else
                return 2-math.floor(1/setting.totalScale)
            end
        end,
        Minimum = -8,
        Maximum = 10,
        Display = function()
            if setting.totalScale>=1 then
                return getMCMDes("N0") ..
                    string.format("1 X %d", setting.totalScale)
            else
                return getMCMDes("N0") ..
                    string.format("1 / %d", 1/setting.totalScale)
            end
        end,
        OnChange = function(n)
            if n>0 then
                setting.totalScale=n
            else
                setting.totalScale=1/(2-n)
            end
        end,
        Info = { getMCMDes("K0") }
    })
    ModConfigMenu.AddSetting(MN, ST, {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function()
            if setting.PennyScale>=1 then
                return setting.PennyScale
            else
                return 2-math.floor(1/setting.PennyScale)
            end
        end,
        Minimum = -18,
        Maximum = 20,
        Display = function()
            if setting.PennyScale>=1 then
                return getMCMDes("N1") ..
                    string.format("1 X %d",setting.PennyScale)
            else
                return getMCMDes("N1") ..
                    string.format("1 / %d",1/setting.PennyScale)
            end
        end,
        OnChange = function(n)
            if n>0 then
                setting.PennyScale=n
            else
                setting.PennyScale=1/(2-n)
            end
        end,
        Info = { getMCMDes("K1") }
    })
    ModConfigMenu.AddSetting(MN, ST, {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function()
            if setting.NickelScale>=1 then
                return setting.NickelScale
            else
                return 2-math.floor(1/setting.NickelScale)
            end
        end,
        Minimum = -18,
        Maximum = 20,
        Display = function()
            if setting.NickelScale>=1 then
                return getMCMDes("N2") ..
                    string.format("1 X %d", setting.NickelScale)
            else
                return getMCMDes("N2") ..
                    string.format("1 / %d", 1/setting.NickelScale)
            end
        end,
        OnChange = function(n)
            if n>0 then
                setting.NickelScale=n
            else
                setting.NickelScale=1/(2-n)
            end
        end,
        Info = { getMCMDes("K2") }
    })
    ModConfigMenu.AddSetting(MN, ST, {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function()
            if setting.DimeScale>=1 then
                return setting.DimeScale
            else
                return 2-math.floor(1/setting.DimeScale)
            end
        end,
        Minimum = -18,
        Maximum = 20,
        Display = function()
            if setting.DimeScale>=1 then
                return getMCMDes("N3") ..
                    string.format("1 X %d", setting.DimeScale)
            else
                return getMCMDes("N3") ..
                    string.format("1 / %d", 1/setting.DimeScale)
            end
        end,
        OnChange = function(n)
            if n>0 then
                setting.DimeScale=n
            else
                setting.DimeScale=1/(2-n)
            end
        end,
        Info = { getMCMDes("K3") }
    })
    ModConfigMenu.AddSetting(MN, ST, {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function()
            if setting.DoublePennyScale>=1 then
                return setting.DoublePennyScale
            else
                return 2-math.floor(1/setting.DoublePennyScale)
            end
        end,
        Minimum = -18,
        Maximum = 20,
        Display = function()
            if setting.DoublePennyScale>=1 then
                return getMCMDes("N4") ..
                    string.format("1 X %d", setting.DoublePennyScale)
            else
                return getMCMDes("N4") ..
                    string.format("1 / %d", 1/setting.DoublePennyScale)
            end
        end,
        OnChange = function(n)
            if n>0 then
                setting.DoublePennyScale=n
            else
                setting.DoublePennyScale=1/(2-n)
            end
        end,
        Info = { getMCMDes("K4") }
    })
    ModConfigMenu.AddSetting(MN, ST, {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function()
            if setting.LuckyPennyScale>=1 then
                return setting.LuckyPennyScale
            else
                return 2-math.floor(1/setting.LuckyPennyScale)
            end
        end,
        Minimum = -18,
        Maximum = 20,
        Display = function()
            if setting.LuckyPennyScale>=1 then
                return getMCMDes("N5") ..
                    string.format("1 X %d", setting.LuckyPennyScale)
            else
                return getMCMDes("N5") ..
                    string.format("1 / %d", 1/setting.LuckyPennyScale)
            end
        end,
        OnChange = function(n)
            if n>0 then
                setting.LuckyPennyScale=n
            else
                setting.LuckyPennyScale=1/(2-n)
            end
        end,
        Info = { getMCMDes("K5") }
    })
    ModConfigMenu.AddSetting(MN, ST, {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function()
            if setting.StickyNickelScale>=1 then
                return setting.StickyNickelScale
            else
                return 2-math.floor(1/setting.StickyNickelScale)
            end
        end,
        Minimum = -18,
        Maximum = 20,
        Display = function()
            if setting.StickyNickelScale>=1 then
                return getMCMDes("N6") ..
                    string.format("1 X %d", setting.StickyNickelScale)
            else
                return getMCMDes("N6") ..
                    string.format("1 / %d", 1/setting.StickyNickelScale)
            end
        end,
        OnChange = function(n)
            if n>0 then
                setting.StickyNickelScale=n
            else
                setting.StickyNickelScale=1/(2-n)
            end
        end,
        Info = { getMCMDes("K6") }
    })
    ModConfigMenu.AddSetting(MN, ST, {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function()
            if setting.GoldenPennyScale>=1 then
                return setting.GoldenPennyScale
            else
                return 2-math.floor(1/setting.GoldenPennyScale)
            end
        end,
        Minimum = -18,
        Maximum = 20,
        Display = function()
            if setting.GoldenPennyScale>=1 then
                return getMCMDes("N7") ..
                    string.format("1 X %d", setting.GoldenPennyScale)
            else
                return getMCMDes("N7") ..
                    string.format("1 / %d", 1/setting.GoldenPennyScale)
            end
        end,
        OnChange = function(n)
            if n>0 then
                setting.GoldenPennyScale=n
            else
                setting.GoldenPennyScale=1/(2-n)
            end
        end,
        Info = { getMCMDes("K7") }
    })
    ModConfigMenu.AddSpace(MN, ST)
    ModConfigMenu.AddSetting(MN,ST, {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function()
            return resetting
        end,
        Display = function()
            return getMCMDes("N8")
        end,
        OnChange = function(boolean)
            resetting=boolean
            reset()
        end,
        Info = { getMCMDes("K8") }
    })
end