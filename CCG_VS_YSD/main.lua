CCG_VS_YSD= RegisterMod("CCG VS YSD", 1)
local json=require("json")
local mod=CCG_VS_YSD
mod.Name="CCG VS YSD"
mod.Des="略鸭mod合集"
if ModConfigMenu then
    ModConfigMenu.RemoveSubcategory(mod.Name,mod.Des)
end
if mod:HasData() then
    local data=mod:LoadData()
    mod.Data=json.decode(data)
end
-- function mod:saveMyData()
--     mod:SaveData(json.encode(mod.Data))
-- end
-- mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.saveMyData)

include("script.CCG_VS_YSD.force_YSD")
include("script.CCG_VS_YSD.fly_bone_club")
include("script.CCG_VS_YSD.tainted_lost_happy")
include("script.CCG_VS_YSD.sin_attribute")
