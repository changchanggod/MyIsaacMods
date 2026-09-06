local mod = CCG_VS_YSD
local challenge_name = "死神名册练习"

local DEATHS_LIST = CollectibleType.COLLECTIBLE_DEATHS_LIST
local DEATHS_LIST_MARK = EffectVariant.DEATH_SKULL
local DAMAGE_MULTIPLIER = 0.01

---@param _ Mod
---@param isContinued boolean
local function DLD_give_deaths_list(_, isContinued)
    if isContinued then
        return
    end

    for playerIndex = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(playerIndex)
        if not player:HasCollectible(DEATHS_LIST) then
            player:AddCollectible(DEATHS_LIST)
        end
    end
end

local function playerHasDeathsList()
    for playerIndex = 0, Game():GetNumPlayers() - 1 do
        if Isaac.GetPlayer(playerIndex):HasCollectible(DEATHS_LIST) then
            return true
        end
    end
    return false
end

---@param npc EntityNPC
local function isDeathsListMarked(npc)
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        local effect = entity:ToEffect()
        if effect and effect.Variant == DEATHS_LIST_MARK and effect.Target then
            return GetPtrHash(effect.Target) == GetPtrHash(npc)
        end
    end
    return true
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
        or isDeathsListMarked(npc) then
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
    mod:RemoveCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, DLD_reduce_unmarked_damage)
    mod:RemoveCallback(ModCallbacks.MC_POST_GAME_STARTED, DLD_give_deaths_list)
    mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, DLD_reduce_unmarked_damage)
    mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, DLD_give_deaths_list)
end

function mod:DLD_off()
    mod:RemoveCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, DLD_reduce_unmarked_damage)
    mod:RemoveCallback(ModCallbacks.MC_POST_GAME_STARTED, DLD_give_deaths_list)
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
            return "死神名册练习:" .. tostring(mod.Data[challenge_name])
        end,
        OnChange = function(boolean)
            if mod.Data[challenge_name] ~= boolean then
                mod.Data[challenge_name] = boolean
                reset_active()
            end
        end,
        Info = { "拥有死神名册时，未被标记的敌人仅受到 1% 伤害（主教像除外）" }
    })
end
