
local mod=CCG_VS_YSD
local function SV_one_charge(_)
    local config=Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_VOID)
    config.MaxCharges=1
end
function mod:SV_on()
    mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED,SV_one_charge)
end
function mod:SV_off()
    mod:RemoveCallback(ModCallbacks.MC_POST_GAME_STARTED,SV_one_charge)
end

-------------------------------------------------------------------------------------------------------------------------------

if mod.Data==nil then
    mod.Data={}
end
if mod.Data.SV_on==nil then
    mod.Data.SV_on=false
end

local function reset_active()
    if mod.Data.SV_on then
        mod:SV_on()
    else
        mod:SV_off()
    end
end


if ModConfigMenu then
    ModConfigMenu.AddSetting(mod.Name,mod.Sed, {
        Type = ModConfigMenu.OptionType.BOOLEAN,
        CurrentSetting = function()
            return mod.Data.SV_on
        end,
        Display = function()
            return "超级虚空:"..tostring(mod.Data.SV_on)
        end,
        OnChange = function(boolean)
            if mod.Data.SV_on~=boolean then
                mod.Data.SV_on=boolean
                reset_active()
            end
            
        end,
        Info = { "一充能虚空罢了" }
    })
end