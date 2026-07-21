local mod = CCGChallenges45768
local utils = require("script.CCG_utils")
local challengeName = "rock up"
local challengeId = utils.GetChallengeSafe(challengeName)
if challengeId == nil then
    return nil
end
utils.allowChallengeSecretPath(challengeId, false)

local setting = nil
local resetting = false
local function reset()
    if type(mod.Data) ~= "table" then
        mod.Data = {}
    end
    mod.Data.RUSetting = {
        moveSpeedChange = -1,
        damageChange = -1,
        fireDelayChange = -1,
        rangeChange = -1,
        shotSpeedChange = -1,
        luckChange = -1,
    }
    setting = mod.Data.RUSetting
end
if mod.Data and mod.Data.RUSetting then
    setting = mod.Data.RUSetting
else
    reset()
end

local fixPlayerState = {
    ["moveSpeed"] = 1,
    ["damage"] = 1,
    ["fireDelay"] = 1,
    ["range"] = 1,
    ["shotSpeed"] = 1,
    ["luck"] = 1,
}

---@param EntP EntityPlayer
---@param flag CacheFlag
local function rockUp(_, EntP, flag)
    local game = Game()
    if game.Challenge ~= challengeId or not setting then
        return
    end
    local cfg = setting
    local state = fixPlayerState

    -- 1. 移速 CACHE_SPEED
    if flag & CacheFlag.CACHE_SPEED > 0 then
        if (EntP.MoveSpeed - state.moveSpeed) * cfg.moveSpeedChange > 0 then
            state.moveSpeed = EntP.MoveSpeed
        elseif (EntP.MoveSpeed - state.moveSpeed) * cfg.moveSpeedChange < 0 then
            EntP.MoveSpeed = state.moveSpeed
        end
    end

    -- 2. 伤害 CACHE_DAMAGE
    if flag & CacheFlag.CACHE_DAMAGE > 0 then
        if (EntP.Damage - state.damage) * cfg.damageChange > 0 then
            state.damage = EntP.Damage
        elseif (EntP.Damage - state.damage) * cfg.damageChange < 0 then
            EntP.Damage = state.damage
        end
    end

    -- 3. 射速 CACHE_FIREDELAY
    if flag & CacheFlag.CACHE_FIREDELAY > 0 then
        if -(EntP.MaxFireDelay - state.fireDelay) * cfg.fireDelayChange > 0 then --Fire Delay is negatively correlated with fire rate.
            state.fireDelay = EntP.MaxFireDelay
        elseif -(EntP.MaxFireDelay - state.fireDelay) * cfg.fireDelayChange < 0 then
            EntP.MaxFireDelay = state.fireDelay
        end
    end

    -- 4. 弹速 CACHE_SHOTSPEED
    if flag & CacheFlag.CACHE_SHOTSPEED > 0 then
        if (EntP.ShotSpeed - state.shotSpeed) * cfg.shotSpeedChange > 0 then
            state.shotSpeed = EntP.ShotSpeed
        elseif (EntP.ShotSpeed - state.shotSpeed) * cfg.shotSpeedChange < 0 then
            EntP.ShotSpeed = state.shotSpeed
        end
    end

    -- 5. 射程 CACHE_RANGE
    if flag & CacheFlag.CACHE_RANGE > 0 then
        if (EntP.TearRange - state.range) * cfg.rangeChange > 0 then
            state.range = EntP.TearRange
        elseif (EntP.TearRange - state.range) * cfg.rangeChange < 0 then
            EntP.TearRange = state.range
        end
    end

    -- 6. 幸运 CACHE_LUCK
    if flag & CacheFlag.CACHE_LUCK > 0 then
        if (EntP.Luck - state.luck) * cfg.luckChange > 0 then
            state.luck = EntP.Luck
        elseif (EntP.Luck - state.luck) * cfg.luckChange < 0 then
            EntP.Luck = state.luck
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, rockUp)
---@param EntP EntityPlayer
local function initState(_, EntP)
    if Game().Challenge == challengeId then
        fixPlayerState["moveSpeed"] = EntP.MoveSpeed
        fixPlayerState["damage"] = EntP.Damage
        fixPlayerState["fireDelay"] = EntP.MaxFireDelay
        fixPlayerState["range"] = EntP.TearRange
        fixPlayerState["shotSpeed"] = EntP.ShotSpeed
        fixPlayerState["luck"] = EntP.Luck
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, initState)
local RU_MCM = {
    zh = {
        MN = "CCG挑战合集",
        ST = "谷顶石",
        T0 = "对应挑战：" .. challengeName,
        T1 = "属性变化设置",
        N0 = "移速变化设置:",
        K0 = "让你的移速只能增加或者减少",
        N1 = "射速变化设置:",
        K1 = "让你的射速只能增加或者减少",
        N2 = "伤害变化设置:",
        K2 = "让你的伤害只能增加或者减少",
        N3 = "射程变化设置:",
        K3 = "让你的射程只能增加或者减少",
        N4 = "弹速变化设置:",
        K4 = "让你的弹速只能增加或者减少",
        N5 = "幸运变化设置:",
        K5 = "让你的幸运只能增加或者减少",
        C0 = "仅下降",
        C1 = "不限制",
        C2 = "仅上升",
        N6 = "重置",
        K6 = "将所有设置重置回默认值",
    },
    en = {
        MN = "CCG Challenge Collection",
        ST = challengeName,
        --T0 = "Associated Challenge: "..challengeName,
        T1 = "Stat Modifier Settings",
        N0 = "Move Speed Modifier:",
        K0 = "Restricts move speed to only gain or lose values",
        N1 = "Fire Rate Modifier:",
        K1 = "Restricts fire rate to only gain or lose values",
        N2 = "Damage Modifier:",
        K2 = "Restricts damage to only gain or lose values",
        N3 = "Range Modifier:",
        K3 = "Restricts range to only gain or lose values",
        N4 = "Projectile Speed Modifier:",
        K4 = "Restricts projectile speed to only gain or lose values",
        N5 = "Luck Modifier:",
        K5 = "Restricts luck to only gain or lose values",
        C0 = "Only Decrease",
        C1 = "No Restrictions",
        C2 = "Only Increase",
        N6 = "RESET ALL SETTINGS",
        K6 = "RESET ALL SETTINGS TO DEFAULT",
    }
}
if ModConfigMenu and setting ~= nil then
    local MN = utils.getMCMDes(RU_MCM, "MN")
    local ST = utils.getMCMDes(RU_MCM, "ST")
    ModConfigMenu.RemoveSubcategory(MN, ST)
    if utils.getMCMDes(RU_MCM, "T0") then
        ModConfigMenu.AddTitle(MN, ST, utils.getMCMDes(RU_MCM, "T0"))
        ModConfigMenu.AddSpace(MN, ST)
    end
    ModConfigMenu.AddTitle(MN, ST, utils.getMCMDes(RU_MCM, "T1"))
    ModConfigMenu.AddSetting(MN, ST, {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function()
            return setting.moveSpeedChange
        end,
        Minimum = -1,
        Maximum = 1,
        Display = function()
            if setting.moveSpeedChange == -1 then
                return utils.getMCMDes(RU_MCM, "N0") .. utils.getMCMDes(RU_MCM, "C0")
            elseif setting.moveSpeedChange == 0 then
                return utils.getMCMDes(RU_MCM, "N0") .. utils.getMCMDes(RU_MCM, "C1")
            else
                return utils.getMCMDes(RU_MCM, "N0") .. utils.getMCMDes(RU_MCM, "C2")
            end
        end,
        OnChange = function(n)
            setting.moveSpeedChange = n
        end,
        Info = { utils.getMCMDes(RU_MCM, "K0") }
    })

    ModConfigMenu.AddSetting(MN, ST, {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function()
            return setting.fireDelayChange
        end,
        Minimum = -1,
        Maximum = 1,
        Display = function()
            if setting.fireDelayChange == -1 then
                return utils.getMCMDes(RU_MCM, "N1") .. utils.getMCMDes(RU_MCM, "C0")
            elseif setting.fireDelayChange == 0 then
                return utils.getMCMDes(RU_MCM, "N1") .. utils.getMCMDes(RU_MCM, "C1")
            else
                return utils.getMCMDes(RU_MCM, "N1") .. utils.getMCMDes(RU_MCM, "C2")
            end
        end,
        OnChange = function(n)
            setting.fireDelayChange = n
        end,
        Info = { utils.getMCMDes(RU_MCM, "K1") }
    })

    ModConfigMenu.AddSetting(MN, ST, {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function()
            return setting.damageChange
        end,
        Minimum = -1,
        Maximum = 1,
        Display = function()
            if setting.damageChange == -1 then
                return utils.getMCMDes(RU_MCM, "N2") .. utils.getMCMDes(RU_MCM, "C0")
            elseif setting.damageChange == 0 then
                return utils.getMCMDes(RU_MCM, "N2") .. utils.getMCMDes(RU_MCM, "C1")
            else
                return utils.getMCMDes(RU_MCM, "N2") .. utils.getMCMDes(RU_MCM, "C2")
            end
        end,
        OnChange = function(n)
            setting.damageChange = n
        end,
        Info = { utils.getMCMDes(RU_MCM, "K2") }
    })

    ModConfigMenu.AddSetting(MN, ST, {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function()
            return setting.rangeChange
        end,
        Minimum = -1,
        Maximum = 1,
        Display = function()
            if setting.rangeChange == -1 then
                return utils.getMCMDes(RU_MCM, "N3") .. utils.getMCMDes(RU_MCM, "C0")
            elseif setting.rangeChange == 0 then
                return utils.getMCMDes(RU_MCM, "N3") .. utils.getMCMDes(RU_MCM, "C1")
            else
                return utils.getMCMDes(RU_MCM, "N3") .. utils.getMCMDes(RU_MCM, "C2")
            end
        end,
        OnChange = function(n)
            setting.rangeChange = n
        end,
        Info = { utils.getMCMDes(RU_MCM, "K3") }
    })

    ModConfigMenu.AddSetting(MN, ST, {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function()
            return setting.shotSpeedChange
        end,
        Minimum = -1,
        Maximum = 1,
        Display = function()
            if setting.shotSpeedChange == -1 then
                return utils.getMCMDes(RU_MCM, "N4") .. utils.getMCMDes(RU_MCM, "C0")
            elseif setting.shotSpeedChange == 0 then
                return utils.getMCMDes(RU_MCM, "N4") .. utils.getMCMDes(RU_MCM, "C1")
            else
                return utils.getMCMDes(RU_MCM, "N4") .. utils.getMCMDes(RU_MCM, "C2")
            end
        end,
        OnChange = function(n)
            setting.shotSpeedChange = n
        end,
        Info = { utils.getMCMDes(RU_MCM, "K4") }
    })

    ModConfigMenu.AddSetting(MN, ST, {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function()
            return setting.luckChange
        end,
        Minimum = -1,
        Maximum = 1,
        Display = function()
            if setting.luckChange == -1 then
                return utils.getMCMDes(RU_MCM, "N5") .. utils.getMCMDes(RU_MCM, "C0")
            elseif setting.luckChange == 0 then
                return utils.getMCMDes(RU_MCM, "N5") .. utils.getMCMDes(RU_MCM, "C1")
            else
                return utils.getMCMDes(RU_MCM, "N5") .. utils.getMCMDes(RU_MCM, "C2")
            end
        end,
        OnChange = function(n)
            setting.luckChange = n
        end,
        Info = { utils.getMCMDes(RU_MCM, "K5") }
    })
    ModConfigMenu.AddSpace(MN, ST)
    ModConfigMenu.AddSetting(MN, ST, {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function()
            return resetting
        end,
        Display = function()
            return utils.getMCMDes(RU_MCM, "N6")
        end,
        OnChange = function(boolean)
            resetting = boolean
            reset()
        end,
        Info = { utils.getMCMDes(RU_MCM, "K6") }
    })
end
