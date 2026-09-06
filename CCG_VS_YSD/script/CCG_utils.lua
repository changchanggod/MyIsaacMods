--[[
CCG_utils 使用说明

在挑战文件中加载本模块后，以挑战名登记所需功能：
    local utils = require("script.CCG_utils")
    utils.registerAllowedCharacters("challenge name", {PlayerType.PLAYER_ISAAC})
    utils.registerNonPlayerTearDilution("challenge name")
    utils.registerRemoveItemsOnCollectibleSpawn("challenge name")

登记规则仅在 mod.Data["challenge name"] == true 时生效。
多个已开启的人物限制会合并允许人物集合；其他登记规则任一开启即生效。
]]

local mod = CCG_VS_YSD
local Utils = {}

-- ================================================================
-- 公共辅助
-- ================================================================

local function isEnabled(challengeName)
    return mod.Data ~= nil and mod.Data[challengeName] == true
end

local function hasEnabledRule(registry)
    for challengeName in pairs(registry) do
        if isEnabled(challengeName) then
            return true
        end
    end
    return false
end

-- ================================================================
-- registerAllowedCharacters
-- 限制人物；所有已开启规则的人物集合会合并。
-- ================================================================

local allowedCharacters = {}
local allowedCharacterOrder = {}
local characterRestrictionTaunt = "万变不离其宗"

local function normalizePlayerTypes(playerTypes)
    local result = {}
    local firstPlayerType = nil

    for key, value in pairs(playerTypes) do
        -- Supports both arrays ({ PlayerType.PLAYER_ISAAC }) and sets
        -- ({ [PlayerType.PLAYER_ISAAC] = true }).
        local playerType = type(value) == "number" and value or key
        if type(playerType) == "number" and value ~= false then
            result[playerType] = true
            if firstPlayerType == nil then
                firstPlayerType = playerType
            end
        end
    end

    return result, firstPlayerType
end

function Utils.registerAllowedCharacters(challengeName, playerTypes)
    if type(challengeName) ~= "string" or type(playerTypes) ~= "table" then
        Isaac.ConsoleOutput("[CCG VS YSD][Error]: registerAllowedCharacters expects a string and a table.\n")
        return
    end

    local allowed, fallbackPlayerType = normalizePlayerTypes(playerTypes)
    if fallbackPlayerType == nil then
        Isaac.ConsoleOutput(string.format(
            "[CCG VS YSD][Error]: Challenge \"%s\" has no allowed player type.\n",
            challengeName
        ))
        return
    end

    if allowedCharacters[challengeName] == nil then
        table.insert(allowedCharacterOrder, challengeName)
    end
    allowedCharacters[challengeName] = {
        allowed = allowed,
        fallback = fallbackPlayerType,
    }
end

local function restrictCharacter(_, player)
    local allowed = {}
    local fallbackPlayerType = nil

    for _, challengeName in ipairs(allowedCharacterOrder) do
        local rule = allowedCharacters[challengeName]
        if isEnabled(challengeName) then
            for playerType in pairs(rule.allowed) do
                allowed[playerType] = true
            end
            fallbackPlayerType = fallbackPlayerType or rule.fallback
        end
    end

    if fallbackPlayerType ~= nil and not allowed[player:GetPlayerType()] then
        player:ChangePlayerType(fallbackPlayerType)
        Game():GetHUD():ShowFortuneText(characterRestrictionTaunt)
    end
end

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, restrictCharacter)

-- ================================================================
-- registerNonPlayerTearDilution
-- 怪物受到非玩家泪弹伤害时，将伤害按楼层稀释。
-- ================================================================

local dilutedNonPlayerTears = {}
local URN_OF_SOULS = CollectibleType.COLLECTIBLE_URN_OF_SOULS

function Utils.registerNonPlayerTearDilution(challengeName)
    if type(challengeName) ~= "string" then
        Isaac.ConsoleOutput("[CCG VS YSD][Error]: registerNonPlayerTearDilution expects a string.\n")
        return
    end

    dilutedNonPlayerTears[challengeName] = true
end

local function isPlayerTear(damageSource)
    if damageSource == nil or damageSource.Entity == nil then
        return false
    end

    local tear = damageSource.Entity:ToTear()
    local player = tear and tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
    if player == nil then
        return false
    end

    -- Urn of Souls blue flames are internally player tears, but should be
    -- diluted together with other non-standard damage sources.
    return not (
        tear.Variant == TearVariant.FIRE
        and player:HasCollectible(URN_OF_SOULS)
    )
end

local function diluteNonPlayerTearDamage(_, entity, amount, damageFlags, damageSource, damageCountdown)
    if not hasEnabledRule(dilutedNonPlayerTears) then
        return
    end

    if entity:ToNPC() == nil or isPlayerTear(damageSource) then
        return
    end

    local data = entity:GetData()
    if data.CCGUtilsDilutedDamage then
        return
    end

    -- LevelStage starts at 1, so the divisor progresses as 10, 15, 20, ...
    local dilutionDivisor = 5 + Game():GetLevel():GetStage() * 5
    data.CCGUtilsDilutedDamage = true
    entity:TakeDamage(amount / dilutionDivisor, damageFlags, damageSource, damageCountdown)
    data.CCGUtilsDilutedDamage = nil
    return false
end

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, diluteNonPlayerTearDamage)

-- ================================================================
-- registerRemoveItemsOnCollectibleSpawn
-- 每生成一个道具，随机移除五个尚未出现的道具池道具。
-- ================================================================

local removeItemsOnCollectibleSpawn = {}
local seenCollectibles = {}
local removedCollectibles = {}
local processedCollectibleSpawns = {}

function Utils.registerRemoveItemsOnCollectibleSpawn(challengeName)
    if type(challengeName) ~= "string" then
        Isaac.ConsoleOutput("[CCG VS YSD][Error]: registerRemoveItemsOnCollectibleSpawn expects a string.\n")
        return
    end

    removeItemsOnCollectibleSpawn[challengeName] = true
end

local function getCollectibleSpawnKey(pickup)
    local level = Game():GetLevel()
    local roomDescriptor = level:GetCurrentRoomDesc()
    return string.format(
        "%d:%d:%d:%d",
        level:GetStage(),
        level:GetStageType(),
        roomDescriptor.ListIndex,
        pickup.InitSeed
    )
end

local function removeRandomUnseenCollectibles()
    local itemConfig = Isaac.GetItemConfig()
    local collectibleCount = itemConfig:GetCollectibles().Size
    local candidates = {}

    for collectibleId = 1, collectibleCount - 1 do
        local collectible = itemConfig:GetCollectible(collectibleId)
        if collectible ~= nil
            and collectible:IsAvailable()
            and not collectible.Hidden
            and not seenCollectibles[collectibleId]
            and not removedCollectibles[collectibleId] then
            table.insert(candidates, collectibleId)
        end
    end

    local itemPool = Game():GetItemPool()
    for _ = 1, math.min(5, #candidates) do
        local index = Random() % #candidates + 1
        local collectibleId = table.remove(candidates, index)
        itemPool:RemoveCollectible(collectibleId)
        removedCollectibles[collectibleId] = true
    end
end

local function removeItemsOnCollectibleSpawnCallback(_, pickup)
    if pickup.SubType <= 0 then
        return
    end
    seenCollectibles[pickup.SubType] = true

    if not hasEnabledRule(removeItemsOnCollectibleSpawn) then
        return
    end

    local spawnKey = getCollectibleSpawnKey(pickup)
    if processedCollectibleSpawns[spawnKey] then
        return
    end

    processedCollectibleSpawns[spawnKey] = true
    removeRandomUnseenCollectibles()
end

local function resetCollectibleSpawnHistory(_, isContinued)
    if not isContinued then
        seenCollectibles = {}
        removedCollectibles = {}
        processedCollectibleSpawns = {}
    end
end

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, removeItemsOnCollectibleSpawnCallback, PickupVariant.PICKUP_COLLECTIBLE)
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, resetCollectibleSpawnHistory)

-- ================================================================
-- registerNoIsaacSatanEnd
-- 禁止以撒/撒旦终点；force_YSD 原逻辑现作为内置常驻规则。
-- ================================================================

local blockedIsaacSatanEnds = {}
local alwaysBlockIsaacSatanEnd = true
local isaacSatanTaunts = {
    "逃避虽然可耻 但是没用",
    "略鸭不完全 相当于完全不略鸭",
    "亚波伦对你使用了虚空",
}
local tauntCountdown = -1

function Utils.registerNoIsaacSatanEnd(challengeName)
    if type(challengeName) ~= "string" then
        Isaac.ConsoleOutput("[CCG VS YSD][Error]: registerNoIsaacSatanEnd expects a string.\n")
        return
    end

    blockedIsaacSatanEnds[challengeName] = true
end

local function playersHaveCollectible(collectibleId)
    local index = 0
    local checked = {}

    while true do
        local player = Isaac.GetPlayer(index)
        if checked[player.Index] then
            break
        end
        checked[player.Index] = true

        if player:HasCollectible(collectibleId, true) then
            return true
        end
        index = index + 1
    end

    return false
end

local function preventIsaacSatanEnd()
    if not alwaysBlockIsaacSatanEnd and not hasEnabledRule(blockedIsaacSatanEnds) then
        return
    end

    local level = Game():GetLevel()
    if level:GetStage() == LevelStage.STAGE5
        and ((level:GetStageType() == 0 and not playersHaveCollectible(328))
            or (level:GetStageType() == 1 and not playersHaveCollectible(327))) then
        Game():StartStageTransition(false, 3, Isaac.GetPlayer())
        tauntCountdown = 30
        return false
    end
end

local function showIsaacSatanTaunt()
    if tauntCountdown < 0 then
        return
    end

    if tauntCountdown == 0 then
        local random = Random()
        Game():GetHUD():ShowFortuneText(isaacSatanTaunts[random % #isaacSatanTaunts + 1])
    end
    tauntCountdown = tauntCountdown - 1
end

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, preventIsaacSatanEnd, PickupVariant.PICKUP_BIGCHEST)
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, preventIsaacSatanEnd, PickupVariant.PICKUP_TROPHY)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, showIsaacSatanTaunt)

-- ================================================================
-- registerNoDonationMachine
-- 删除捐款机和贪婪捐款机；force_YSD 原逻辑现作为内置常驻规则。
-- ================================================================

local blockedDonationMachines = {}
local alwaysBlockDonationMachines = true
local DONATION_MACHINE_VARIANT = 8
local GREED_DONATION_MACHINE_VARIANT = 11

function Utils.registerNoDonationMachine(challengeName)
    if type(challengeName) ~= "string" then
        Isaac.ConsoleOutput("[CCG VS YSD][Error]: registerNoDonationMachine expects a string.\n")
        return
    end

    blockedDonationMachines[challengeName] = true
end

local function removeDonationMachines()
    if not alwaysBlockDonationMachines and not hasEnabledRule(blockedDonationMachines) then
        return
    end

    for _, slot in pairs(Isaac.FindByType(EntityType.ENTITY_SLOT, -1, -1, false, false)) do
        if slot.Variant == DONATION_MACHINE_VARIANT
            or slot.Variant == GREED_DONATION_MACHINE_VARIANT then
            slot:Remove()
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, removeDonationMachines)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, removeDonationMachines)

return Utils
