local mod = CCG_VS_YSD
local challenge_name = "giga fetus"
local GIGA_BOMB_COUNTDOWN = 45

---@param _ Mod
---@param isContinued boolean
local function GF_give_dr_fetus(_, isContinued)
    if isContinued then
        return
    end

    for playerIndex = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(playerIndex)
        if not player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS) then
            player:AddCollectible(CollectibleType.COLLECTIBLE_DR_FETUS)
        end
    end
end

---@param bomb EntityBomb
local function GF_replace_dr_fetus_bomb(_, bomb)
    local data = bomb:GetData()
    if data.GF_replaced or not bomb.IsFetus then
        return
    end

    local gigaBomb = Game():Spawn(
        EntityType.ENTITY_BOMB,
        BombVariant.BOMB_GIGA,
        bomb.Position,
        bomb.Velocity,
        bomb.SpawnerEntity,
        bomb.SubType,
        bomb.InitSeed
    ):ToBomb()

    gigaBomb:GetData().GF_replaced = true
    -- 继承胎儿博士炸弹的地形碰撞规则，使其不会被沟壑阻拦。
    gigaBomb.GridCollisionClass = bomb.GridCollisionClass
    -- 游戏逻辑帧为每秒 30 帧，45 帧即约 1.5 秒。
    gigaBomb:SetExplosionCountdown(GIGA_BOMB_COUNTDOWN)
    bomb:Remove()
end

function mod:GF_on()
    mod:RemoveCallback(ModCallbacks.MC_POST_BOMB_UPDATE, GF_replace_dr_fetus_bomb)
    mod:RemoveCallback(ModCallbacks.MC_POST_GAME_STARTED, GF_give_dr_fetus)
    mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, GF_replace_dr_fetus_bomb)
    mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, GF_give_dr_fetus)
end

function mod:GF_off()
    mod:RemoveCallback(ModCallbacks.MC_POST_BOMB_UPDATE, GF_replace_dr_fetus_bomb)
    mod:RemoveCallback(ModCallbacks.MC_POST_GAME_STARTED, GF_give_dr_fetus)
end

if mod.Data == nil then
    mod.Data = {}
end
if mod.Data[challenge_name] == nil then
    mod.Data[challenge_name] = false
end

local function reset_active()
    if mod.Data[challenge_name] then
        mod:GF_on()
    else
        mod:GF_off()
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
            return "超级胎儿博士:" .. tostring(mod.Data[challenge_name])
        end,
        OnChange = function(boolean)
            if mod.Data[challenge_name] ~= boolean then
                mod.Data[challenge_name] = boolean
                reset_active()
            end
        end,
        Info = { "胎儿博士发射的炸弹全部替换为超级大炸弹" }
    })
end
