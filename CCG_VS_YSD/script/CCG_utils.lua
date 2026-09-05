local mod = CCG_VS_YSD
local Utils = {}

-- Registries are keyed by the same challenge-name strings used by mod.Data.
local allowedCharacters = {}
local allowedCharacterOrder = {}
local blockedIsaacSatanEnds = {}
local blockedDonationMachines = {}

local DONATION_MACHINE_VARIANT = 8
local GREED_DONATION_MACHINE_VARIANT = 11

local function isEnabled(challengeName)
    return mod.Data ~= nil and mod.Data[challengeName] == true
end

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

-- Register the player types a challenge may use.  A player outside this set
-- is converted to the first registered type when it is initialized.
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

-- Register a challenge whose Isaac/Satan ending chest may not be used.
function Utils.registerNoIsaacSatanEnd(challengeName)
    if type(challengeName) ~= "string" then
        Isaac.ConsoleOutput("[CCG VS YSD][Error]: registerNoIsaacSatanEnd expects a string.\n")
        return
    end

    blockedIsaacSatanEnds[challengeName] = true
end

-- Register a challenge in which donation machines and Greed donation
-- machines are removed whenever they appear.
function Utils.registerNoDonationMachine(challengeName)
    if type(challengeName) ~= "string" then
        Isaac.ConsoleOutput("[CCG VS YSD][Error]: registerNoDonationMachine expects a string.\n")
        return
    end

    blockedDonationMachines[challengeName] = true
end

local function hasEnabledRule(registry)
    for challengeName in pairs(registry) do
        if isEnabled(challengeName) then
            return true
        end
    end
    return false
end

local function restrictCharacter(_, player)
    local allowed = {}
    local fallbackPlayerType = nil

    -- All enabled challenge rules contribute to one shared allowed set.
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
    end
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
    if not hasEnabledRule(blockedIsaacSatanEnds) then
        return
    end

    local level = Game():GetLevel()
    if level:GetStage() == LevelStage.STAGE5
        and ((level:GetStageType() == 0 and not playersHaveCollectible(328))
            or (level:GetStageType() == 1 and not playersHaveCollectible(327))) then
        Game():StartStageTransition(false, 3, Isaac.GetPlayer())
        return false
    end
end

local function removeDonationMachines()
    if not hasEnabledRule(blockedDonationMachines) then
        return
    end

    for _, slot in pairs(Isaac.FindByType(EntityType.ENTITY_SLOT, -1, -1, false, false)) do
        if slot.Variant == DONATION_MACHINE_VARIANT
            or slot.Variant == GREED_DONATION_MACHINE_VARIANT then
            slot:Remove()
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, restrictCharacter)
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, preventIsaacSatanEnd, PickupVariant.PICKUP_BIGCHEST)
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, preventIsaacSatanEnd, PickupVariant.PICKUP_TROPHY)
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, removeDonationMachines)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, removeDonationMachines)

return Utils
