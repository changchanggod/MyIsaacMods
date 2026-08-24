local mod = RegisterMod("spin4623", 1)
local angle=0
local angleSpeed=10
function mod:GetShaderParams(shaderName)
	if shaderName == 'RotateOnly' then
        local params = { 
             Angle=  angle
            }
        return params;
    end
end
mod:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, mod.GetShaderParams)
function mod:addAngle()
    angle=angle+angleSpeed/100
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.addAngle)


--------------------------------------------------------------------------------------------------------------


local AYSIM_MCM={
    zh = {
        MN = "CCG挑战",
        ST = "旋转",
        N0 = "转速:",
        K0 = "旋转速度",
    },
}
local function getMCMDes(MCM,key)
    local lan = Options.Language
    lan = MCM[lan] and lan or "en"
    local zhMCM = ModConfigMenu.i18n == "Chinese"
    if zhMCM and lan ~= "zh" then
        lan = "zh"
    elseif not (zhMCM) and lan == "zh" then
        lan = "en"
    end
    return MCM[lan] and MCM[lan][key]
end
if ModConfigMenu then
    local MN=getMCMDes(AYSIM_MCM, "MN")
    local ST=getMCMDes(AYSIM_MCM, "ST")
    ModConfigMenu.RemoveSubcategory(MN, ST)
    ModConfigMenu.AddSetting(MN, ST, {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function()
            return angleSpeed
        end,
        Minimum = -50,
        Maximum = 50,
        Display = function()
            return getMCMDes(AYSIM_MCM, "N0") ..
                tostring(angleSpeed)
        end,
        OnChange = function(n)
            angleSpeed=n
        end,
        Info = { getMCMDes(AYSIM_MCM, "K0") }
    })
end

