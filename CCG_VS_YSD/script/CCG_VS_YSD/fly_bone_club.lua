local mod=CCG_VS_YSD
local utils=require("script.CCG_utils")
local challenge_name="fly bone club"
utils.registerAllowedCharacters(challenge_name, {PlayerType.PLAYER_THEFORGOTTEN})
---@param EntP EntityPlayer
local function FBC_not_allow_soulHeart(_,EntP)
    if EntP:GetPlayerType()==PlayerType.PLAYER_THEFORGOTTEN then
        EntP=EntP:GetSubPlayer()
    end
    if EntP:GetSoulHearts()>0 then
        EntP:AddSoulHearts(-EntP:GetSoulHearts())
    end
    if EntP:GetBlackHearts()>0 then
        EntP:AddBlackHearts(-EntP:GetBlackHearts())
    end
end
---@param EntP EntityPlayer
---@param CF CacheFlag
local function FBC_force_long_range(_,EntP,CF)
    if CF==CacheFlag.CACHE_RANGE then
        EntP.TearRange=20000
    end
end
local function FBC_remove_item()
    local itemPool=Game():GetItemPool()
    itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_LIBRA)
end
function mod:FBC_on()
    mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE,FBC_not_allow_soulHeart)
    mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE,FBC_force_long_range,CacheFlag.CACHE_RANGE)
    mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED,FBC_remove_item)
end
function mod:FBC_off()
    mod:RemoveCallback(ModCallbacks.MC_POST_PLAYER_UPDATE,FBC_not_allow_soulHeart)
    mod:RemoveCallback(ModCallbacks.MC_EVALUATE_CACHE,FBC_force_long_range)
    mod:RemoveCallback(ModCallbacks.MC_POST_GAME_STARTED,FBC_remove_item)
end

-------------------------------------------------------------------------------------------------------------------------------

if mod.Data==nil then
    mod.Data={}
end
if mod.Data[challenge_name]==nil then
    mod.Data[challenge_name]=false
end

local function reset_active()
    if mod.Data[challenge_name] then
        mod:FBC_on()
    else
        mod:FBC_off()
    end
end


if ModConfigMenu then
    ModConfigMenu.AddSetting(mod.Name,mod.Des, {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function()
            return mod.Data[challenge_name]
        end,
        Display = function()
            return "飞骨流骨哥:"..tostring(mod.Data[challenge_name])
        end,
        OnChange = function(boolean)
            if mod.Data[challenge_name]~=boolean then
                mod.Data[challenge_name]=boolean
                reset_active()
            end
            
        end,
        Info = { "无法使用灵魂形态 但部分属性上升" }
    })
end
