local mod=CCG_VS_YSD
local sin_param={}
local entP_attribute={}
---@param EntP EntityPlayer
---@param CF CacheFlag
local function SA_set_sin_attribute(_,EntP,CF)
    if CF==CacheFlag.CACHE_DAMAGE and sin_param["Damage"] then
        entP_attribute["Damage"] = EntP.Damage
    end
    if CF==CacheFlag.CACHE_RANGE and sin_param["Range"] then
        entP_attribute["Range"] = EntP.TearRange
    end
    if CF==CacheFlag.CACHE_LUCK and sin_param["Luck"] then
        entP_attribute["Luck"] = EntP.Luck
    end
    if CF==CacheFlag.CACHE_SHOTSPEED and sin_param["ShotSpeed"] then
        entP_attribute["ShotSpeed"] = EntP.ShotSpeed
    end
    if CF==CacheFlag.CACHE_SPEED and sin_param["Speed"] then
        entP_attribute["Speed"] = EntP.MoveSpeed
    end
    if CF==CacheFlag.CACHE_FIREDELAY and sin_param["MaxFiredDelay"] then
        entP_attribute["MaxFiredDelay"] = EntP.MaxFireDelay
    end
end
local function SA_set_sin_param()
    -- 使用全局开局种子构建RNG，同一局游戏种子固定
    local player = Isaac.GetPlayer()
    local RECOMMENDED_SHIFT_IDX = 35
    local game = Game()
    local seeds = game:GetSeeds()
    local startSeed = seeds:GetStartSeed()
    local rng = RNG()
    rng:SetSeed(math.max(1, startSeed), RECOMMENDED_SHIFT_IDX)

    --######################## 【用户自行修改随机范围】########################
    -- frequency：震荡频率，数值越大属性波动越快；建议小数 0.01 ~ 0.15
    local freq_min = 0.001
    local freq_max = 0.005

    -- offset：正弦相位偏移，推荐 0 ~ 2*math.pi（完整正弦周期），让各属性波峰波谷错开
    local offset_min = 0
    local offset_max = 2 * math.pi
    --########################################################################

    sin_param = sin_param or {}

    -- min + (max‑min) * rng:RandomFloat()
    sin_param.Damage = {
        frequency = freq_min + (freq_max - freq_min) * rng:RandomFloat(),
        offset = offset_min + (offset_max - offset_min) * rng:RandomFloat()
    }
    sin_param.Range = {
        frequency = freq_min + (freq_max - freq_min) * rng:RandomFloat(),
        offset = offset_min + (offset_max - offset_min) * rng:RandomFloat()
    }
    sin_param.Luck = {
        frequency = freq_min + (freq_max - freq_min) * rng:RandomFloat(),
        offset = offset_min + (offset_max - offset_min) * rng:RandomFloat()
    }
    sin_param.ShotSpeed = {
        frequency = freq_min + (freq_max - freq_min) * rng:RandomFloat(),
        offset = offset_min + (offset_max - offset_min) * rng:RandomFloat()
    }
    sin_param.Speed = {
        frequency = freq_min + (freq_max - freq_min) * rng:RandomFloat(),
        offset = offset_min + (offset_max - offset_min) * rng:RandomFloat()
    }
    sin_param.MaxFiredDelay = {
        frequency = freq_min + (freq_max - freq_min) * rng:RandomFloat(),
        offset = offset_min + (offset_max - offset_min) * rng:RandomFloat()
    }
    player:AddCacheFlags(CacheFlag.CACHE_ALL)
    player:EvaluateItems()
end

local function SA_enable_sin_attribute()
    local player = Isaac.GetPlayer()
    local EntP = player
    if sin_param["Damage"] and entP_attribute["Damage"] then
        EntP.Damage = entP_attribute["Damage"] * (0.5 + 0.5*math.sin(sin_param["Damage"]["frequency"] * EntP.FrameCount + sin_param["Damage"]["offset"]))
    end
    if sin_param["Range"] and entP_attribute["Range"] then
        EntP.TearRange = entP_attribute["Range"] * (0.5 + 0.5*math.sin(sin_param["Range"]["frequency"] * EntP.FrameCount + sin_param["Range"]["offset"]))
    end
    if sin_param["Luck"] and entP_attribute["Luck"] then
        EntP.Luck = entP_attribute["Luck"] * (0 + 1*math.sin(sin_param["Luck"]["frequency"] * EntP.FrameCount + sin_param["Luck"]["offset"]))
    end
    if sin_param["ShotSpeed"] and entP_attribute["ShotSpeed"] then
        EntP.ShotSpeed = entP_attribute["ShotSpeed"] * (0 + 1*math.sin(sin_param["ShotSpeed"]["frequency"] * EntP.FrameCount + sin_param["ShotSpeed"]["offset"]))
    end
    if sin_param["Speed"] and entP_attribute["Speed"] then
        EntP.MoveSpeed = entP_attribute["Speed"] * (0.5 + 0.5*math.sin(sin_param["Speed"]["frequency"] * EntP.FrameCount + sin_param["Speed"]["offset"]))
    end
    if sin_param["MaxFiredDelay"] and entP_attribute["MaxFiredDelay"] then
        EntP.MaxFireDelay = entP_attribute["MaxFiredDelay"] * (1.5 + 0.5*math.sin(sin_param["MaxFiredDelay"]["frequency"] * EntP.FrameCount + sin_param["MaxFiredDelay"]["offset"]))
    end
end


local function SA_remove_item()
    local itemPool=Game():GetItemPool()
    itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_LIBRA)
end
function mod:SA_on()
    mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE,SA_enable_sin_attribute)
    mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE,SA_set_sin_attribute)
    mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED,SA_remove_item)
    mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED,SA_set_sin_param)
end
function mod:SA_off()
    mod:RemoveCallback(ModCallbacks.MC_POST_PLAYER_UPDATE,SA_enable_sin_attribute)
    mod:RemoveCallback(ModCallbacks.MC_EVALUATE_CACHE,SA_set_sin_attribute)
    mod:RemoveCallback(ModCallbacks.MC_POST_GAME_STARTED,SA_remove_item)
    mod:RemoveCallback(ModCallbacks.MC_POST_GAME_STARTED,SA_set_sin_param)
end

-------------------------------------------------------------------------------------------------------------------------------

if mod.Data==nil then
    mod.Data={}
end
if mod.Data.SA_on==nil then
    mod.Data.SA_on=false
end

local function reset_active()
    if mod.Data.SA_on then
        mod:SA_on()
    else
        mod:SA_off()
    end
end


if ModConfigMenu then
    ModConfigMenu.AddSetting(mod.Name,mod.Des, {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function()
            return mod.Data.SA_on
        end,
        Display = function()
            return "正弦属性:"..tostring(mod.Data.SA_on)
        end,
        OnChange = function(boolean)
            if mod.Data.SA_on~=boolean then
                mod.Data.SA_on=boolean
                reset_active()
            end
            
        end,
        Info = { "属性变为正弦函数" }
    })
end