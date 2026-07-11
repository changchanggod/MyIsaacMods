local mod = CCGChallenges45768
local utils = require("script.CCG_utils")
---@type integer|nil
local challengeId = utils.GetChallengeSafe("don't pick up shit")
---@type integer|nil
local shitId = utils.GetItemSafe("bad shit")
if challengeId == nil or shitId == nil then
    return nil
end
utils.allowChallengeSecretPath(challengeId, false)

local setting = nil
local resetting = false
local function reset()
    if type(mod.Data) ~= "table" then
        mod.Data = {}
    end
    mod.Data.DNPUSSetting = {
        shitNum = 1,
        autoIncrease = 1,
        RoomSizeConsider = true,
        avoidDoorKill = true
    }
    setting = mod.Data.DNPUSSetting
end
if mod.Data and mod.Data.DNPUSSetting then
    setting = mod.Data.DNPUSSetting
else
    reset()
end
local function spawnShit(num)
    local game = Game()
    if game.Challenge == challengeId then
        local room = game:GetRoom()
        if setting and setting.RoomSizeConsider then
            local shape = room:GetRoomShape()
            if shape == RoomShape.ROOMSHAPE_1x2 or shape == RoomShape.ROOMSHAPE_2x1 then
                num = num * 2
            elseif shape == RoomShape.ROOMSHAPE_LTL or shape == RoomShape.ROOMSHAPE_LTR or shape == RoomShape.ROOMSHAPE_LBL or shape == RoomShape.ROOMSHAPE_LBR then
                num = num * 3
            elseif shape == RoomShape.ROOMSHAPE_2x2 then
                num = num * 4
            elseif shape == RoomShape.ROOMSHAPE_IH or shape == RoomShape.ROOMSHAPE_IV then
                num = num / 2
            end
        end
        for i = 1, num, 1 do
            local pos = Isaac.GetRandomPosition()
            game:Spawn(5, 100, room:FindFreePickupSpawnPosition(pos, 10, true, true), Vector(0, 0), nil, shitId,
                room:GetSpawnSeed())
        end
    end
end
local function perRoomSpawnShit(_)
    local game = Game()
    if game.Challenge == challengeId then
        local room = game:GetRoom()
        if room:IsClear() then
            return
        end
        if not setting then
            return
        end
        spawnShit(setting.shitNum)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, perRoomSpawnShit)
local function ifHasBadShit(_)
    if Game().Challenge == challengeId then
        local player = Isaac.GetPlayer()
        if player:HasCollectible(shitId) then
            player:TakeDamage(1, DamageFlag.DAMAGE_INVINCIBLE|DamageFlag.DAMAGE_NO_PENALTIES, EntityRef(nil), 0)
            player:RemoveCollectible(shitId)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, ifHasBadShit)
local function increaseShitNumPerLevel(_)
    if Game().Challenge == challengeId and setting then
        setting.shitNum = setting.shitNum + setting.autoIncrease
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, increaseShitNumPerLevel)
local function resetShitNumPerGame(_, isC)
    if Game().Challenge == challengeId and setting and not isC then
        setting.shitNum = 1
    end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, resetShitNumPerGame)

---------------------------------------------------------------------
local DNPUS_MCM = {
    zh = {
        MN = "CCG挑战合集",
        ST = "不要搬史",
        T0 = "对应挑战：don't pick up shit",
        T1 = "史数量调整",
        N0 = "目前史量:",
        K0 = "在每一个正常大小的未清理房间生成的史数量",
        N1 = "每层增加史量:",
        K1 = "每一层将增加每个房间史的数量",
        N2 = "房间大小影响史数量:",
        K2 = "例如2*2的大房间将生成4倍于正常大小房间的史数量",
        N3 = "重置",
        K3 = "将所有设置重置回默认值",
    },
    en = {
        MN = "CCG Challenge Collection",
        ST = "Don't Pick Up Shit",
        --T0 = nil
        T1 = "Pile Count Adjustment",
        N0 = "Current Pile Count:",
        K0 = "Amount of piles spawned in every uncleared standard-sized room",
        N1 = "Per-Floor Pile Bonus:",
        K1 = "Extra piles added to each room for every floor cleared",
        N2 = "Room Size Multiplier",
        K2 = "For example, a 2x2 large room spawns 4 times as many piles as a standard room",
        N3 = "RESET ALL SETTINGS",
        K3 = "RESET ALL SETTINGS TO DEFAULT",
    }
}
if ModConfigMenu and setting ~= nil then
    local MN = utils.getMCMDes(DNPUS_MCM, "MN")
    local ST = utils.getMCMDes(DNPUS_MCM, "ST")
    ModConfigMenu.RemoveSubcategory(MN, ST)
    if utils.getMCMDes(DNPUS_MCM, "T0") then
        ModConfigMenu.AddTitle(MN, ST, utils.getMCMDes(DNPUS_MCM, "T0"))
        ModConfigMenu.AddSpace(MN, ST)
    end
    ModConfigMenu.AddTitle(MN, ST, utils.getMCMDes(DNPUS_MCM, "T1"))
    ModConfigMenu.AddSetting(MN, ST, {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function()
            return setting.shitNum
        end,
        Minimum = 0,
        Maximum = 100,
        Display = function()
            return utils.getMCMDes(DNPUS_MCM, "N0") .. setting.shitNum
        end,
        OnChange = function(n)
            setting.shitNum = n
        end,
        Info = { utils.getMCMDes(DNPUS_MCM, "K0") }
    })
    ModConfigMenu.AddSetting(MN, ST, {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function()
            if setting.autoIncrease >= 1 then
                return setting.autoIncrease
            else
                return 2 - math.floor(1 / setting.autoIncrease)
            end
        end,
        Minimum = -3,
        Maximum = 5,
        Display = function()
            if setting.autoIncrease >= 1 then
                return utils.getMCMDes(DNPUS_MCM, "N1") ..
                    string.format("1 X %d", setting.autoIncrease)
            else
                return utils.getMCMDes(DNPUS_MCM, "N1") ..
                    string.format("1 / %d", 1 / setting.autoIncrease)
            end
        end,
        OnChange = function(n)
            if n > 0 then
                setting.autoIncrease = n
            else
                setting.autoIncrease = 1 / (2 - n)
            end
        end,
        Info = { utils.getMCMDes(DNPUS_MCM, "K1") }
    })
    ModConfigMenu.AddSetting(MN, ST, {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function()
            return setting.RoomSizeConsider
        end,
        Display = function()
            return utils.getMCMDes(DNPUS_MCM, "N2") .. tostring(setting.RoomSizeConsider)
        end,
        OnChange = function(n)
            setting.RoomSizeConsider = n
        end,
        Info = { utils.getMCMDes(DNPUS_MCM, "K2") }
    })
    ModConfigMenu.AddSpace(MN, ST)
    ModConfigMenu.AddSetting(MN, ST, {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function()
            return resetting
        end,
        Display = function()
            return utils.getMCMDes(DNPUS_MCM, "N3")
        end,
        OnChange = function(boolean)
            resetting = boolean
            reset()
        end,
        Info = { utils.getMCMDes(DNPUS_MCM, "K3") }
    })
end
---------------------------------------------------------------------

if EID then
    EID:addCollectible(shitId,
        "{{Heart}} 受到一次伤害" ..
        "#移除你搬到的史",
        "史",
        "zh_cn")
    EID:addCollectible(shitId,
        "{{Heart}} Take 1 damage" ..
        "#Remove all shit you carried",
        "bad shit",
        "en_us")
end
