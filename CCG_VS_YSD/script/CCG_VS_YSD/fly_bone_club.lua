local mod=CCG_VS_YSD
local challengeName="挑战1"
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
---@param EntP EntityPlayer
local function FBC_force_the_forgotten(_,EntP)
    if EntP:GetPlayerType()~=PlayerType.PLAYER_THEFORGOTTEN then
        EntP:ChangePlayerType(PlayerType.PLAYER_THEFORGOTTEN)
        Game():GetHUD():ShowFortuneText("万变不离其宗")
    end
end
local function remove_item()
    local itemPool=Game():GetItemPool()
    itemPool:RemoveCollectible(CollectibleType.COLLECTIBLE_LIBRA)
end
function mod:FBC_on()
    mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE,FBC_not_allow_soulHeart)
    mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE,FBC_force_the_forgotten)
    mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE,FBC_force_long_range,CacheFlag.CACHE_RANGE)
    mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED,remove_item)
end
function mod:FBC_off()
    mod:RemoveCallback(ModCallbacks.MC_POST_PLAYER_UPDATE,FBC_not_allow_soulHeart)
    mod:RemoveCallback(ModCallbacks.MC_POST_PLAYER_UPDATE,FBC_force_the_forgotten)
    mod:RemoveCallback(ModCallbacks.MC_EVALUATE_CACHE,FBC_force_long_range)
    mod:RemoveCallback(ModCallbacks.MC_POST_GAME_STARTED,remove_item)
end

-------------------------------------------------------------------------------------------------------------------------------

if mod.Data==nil then
    mod.Data={}
end
if mod.Data.FBC_on==nil then
    mod.Data.FBC_on=false
end

local function reset_active()
    if mod.Data.FBC_on then
        mod:FBC_on()
    else
        mod:FBC_off()
    end
end


if ModConfigMenu then
    ModConfigMenu.RemoveSubcategory(mod.Name,challengeName )
    ModConfigMenu.AddTitle(mod.Name,challengeName, "飞骨流骨哥")
    ModConfigMenu.AddSetting(mod.Name,challengeName, {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function()
            return mod.Data.FBC_on
        end,
        Display = function()
            return "总开关:"..tostring(mod.Data.FBC_on)
        end,
        OnChange = function(boolean)
            if mod.Data.FBC_on~=boolean then
                mod.Data.FBC_on=boolean
                reset_active()
            end
            
        end,
        Info = { "无法使用灵魂形态，但部分属性上升" }
    })
end