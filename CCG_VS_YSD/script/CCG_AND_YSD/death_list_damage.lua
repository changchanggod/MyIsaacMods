local mod = CCG_VS_YSD
local challenge_name = "death list damage"

local DEATHS_LIST = CollectibleType.COLLECTIBLE_DEATHS_LIST
local DAMAGE_MULTIPLIER = 0.05
local targets = {}
local knownTargets = {}
local deathsListFailed = false
local initialized = false

local function playerHasDeathsList()
    for playerIndex = 0, Game():GetNumPlayers() - 1 do
        if Isaac.GetPlayer(playerIndex):HasCollectible(DEATHS_LIST) then
            return true
        end
    end
    return false
end

---@param npc EntityNPC
local function getTargetId(npc)
    return GetPtrHash(npc)
end

---@param npc EntityNPC
local function canBeDeathsListTarget(npc)
    return npc:IsActiveEnemy(false) and npc:IsVulnerableEnemy()
end

local function addNewTargets()
    local newTargets = {}
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        local npc = entity:ToNPC()
        if npc and canBeDeathsListTarget(npc) then
            local targetId = getTargetId(npc)
            if not knownTargets[targetId] then
                knownTargets[targetId] = true
                table.insert(newTargets, npc)
            end
        end
    end

    table.sort(newTargets, function(left, right)
        if left.Position.Y == right.Position.Y then
            return left.Position.X < right.Position.X
        end
        return left.Position.Y < right.Position.Y
    end)

    for _, npc in ipairs(newTargets) do
        table.insert(targets, getTargetId(npc))
    end
end

local function currentTargetId()
    return targets[1]
end

local function DLD_reset_targets()
    targets = {}
    knownTargets = {}
    deathsListFailed = false
    initialized = false
end

local function DLD_update_targets()
    -- 死神名册初始目标按房间中敌人的由上到下、由左到右顺序确定。
    -- 原版当前目标没有 Lua API，因此在此同步维护同一顺序。
    addNewTargets()
    initialized = true
end

---@param _ Mod
---@param npc EntityNPC
local function DLD_track_death(_, npc)
    if not initialized or not playerHasDeathsList() then
        return
    end

    local targetId = getTargetId(npc)
    if not knownTargets[targetId] then
        return
    end

    if targetId == currentTargetId() then
        table.remove(targets, 1)
    else
        deathsListFailed = true
    end
end

---@param entity Entity
---@param amount number
---@param flags DamageFlag
---@param source EntityRef
---@param countdown number
local function DLD_reduce_unmarked_damage(_, entity, amount, flags, source, countdown)
    local npc = entity:ToNPC()
    if npc == nil
        or not npc:IsActiveEnemy(false)
        or npc.Type == EntityType.ENTITY_BISHOP
        or not playerHasDeathsList()
        or (not deathsListFailed and getTargetId(npc) == currentTargetId()) then
        return
    end

    local data = npc:GetData()
    if data.DLD_reapplyingDamage then
        return
    end

    data.DLD_reapplyingDamage = true
    npc:TakeDamage(amount * DAMAGE_MULTIPLIER, flags, source, countdown)
    data.DLD_reapplyingDamage = nil
    return false
end

function mod:DLD_on()
    DLD_reset_targets()
    mod:RemoveCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, DLD_reduce_unmarked_damage)
    mod:RemoveCallback(ModCallbacks.MC_POST_NEW_ROOM, DLD_reset_targets)
    mod:RemoveCallback(ModCallbacks.MC_POST_UPDATE, DLD_update_targets)
    mod:RemoveCallback(ModCallbacks.MC_POST_NPC_DEATH, DLD_track_death)
    mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, DLD_reduce_unmarked_damage)
    mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, DLD_reset_targets)
    mod:AddCallback(ModCallbacks.MC_POST_UPDATE, DLD_update_targets)
    mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, DLD_track_death)
end

function mod:DLD_off()
    mod:RemoveCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, DLD_reduce_unmarked_damage)
    mod:RemoveCallback(ModCallbacks.MC_POST_NEW_ROOM, DLD_reset_targets)
    mod:RemoveCallback(ModCallbacks.MC_POST_UPDATE, DLD_update_targets)
    mod:RemoveCallback(ModCallbacks.MC_POST_NPC_DEATH, DLD_track_death)
    DLD_reset_targets()
end

if mod.Data == nil then
    mod.Data = {}
end
if mod.Data[challenge_name] == nil then
    mod.Data[challenge_name] = false
end

local function reset_active()
    if mod.Data[challenge_name] then
        mod:DLD_on()
    else
        mod:DLD_off()
    end
end

reset_active()

if ModConfigMenu then
    ModConfigMenu.AddSetting(mod.Name, mod.Sed, {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function()
            return mod.Data[challenge_name]
        end,
        Display = function()
            return "死神名册惩罚:" .. tostring(mod.Data[challenge_name])
        end,
        OnChange = function(boolean)
            if mod.Data[challenge_name] ~= boolean then
                mod.Data[challenge_name] = boolean
                reset_active()
            end
        end,
        Info = { "拥有死神名册时，未被标记的敌人仅受到 5% 伤害（主教像除外）" }
    })
end
