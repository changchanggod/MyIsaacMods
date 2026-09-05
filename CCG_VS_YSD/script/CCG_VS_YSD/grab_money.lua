local mod=CCG_VS_YSD
local challenge_name="grab money"
---@param entPick EntityPickup
local function GM_quicker_disappear_money(_,entPick)
    if entPick.FrameCount==1 then
        entPick.Timeout=math.min(entPick.Timeout,entPick.Timeout/2)
    end
end
local function GM_force_the_keeper(_,EntP)
    if EntP:GetPlayerType()~=PlayerType.PLAYER_KEEPER_B then
        EntP:ChangePlayerType(PlayerType.PLAYER_KEEPER_B)
        Game():GetHUD():ShowFortuneText("万变不离其宗")
    end
end

function mod:GM_on()
    mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE,GM_quicker_disappear_money,PickupVariant.PICKUP_COIN)
    mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE,GM_force_the_keeper)
end
function mod:GM_off()
    mod:RemoveCallback(ModCallbacks.MC_POST_PICKUP_UPDATE,GM_quicker_disappear_money)
    mod:RemoveCallback(ModCallbacks.MC_POST_PLAYER_UPDATE,GM_force_the_keeper)
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
        mod:GM_on()
    else
        mod:GM_off()
    end
end


if ModConfigMenu then
    ModConfigMenu.AddSetting(mod.Name,mod.Des, {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function()
            return mod.Data[challenge_name]
        end,
        Display = function()
            return "抢钱:"..tostring(mod.Data[challenge_name])
        end,
        OnChange = function(boolean)
            if mod.Data[challenge_name]~=boolean then
                mod.Data[challenge_name]=boolean
                reset_active()
            end
            
        end,
        Info = { "钱要没了怎么办  抢啊" }
    })
end
