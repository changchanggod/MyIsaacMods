---@type ModReference
CCGChallenges45768 =CCGChallenges45768 or RegisterMod("all_you_see_is_money", 1)
local mod= CCGChallenges45768
include("script.AYSIM.all_you_see_is_money")
local json=require("json")
if mod:HasData() then
    local data=mod:LoadData()
    mod.Data=json.decode(data)
end
local function saveData(_)
    mod:SaveData(json.encode(mod.Data))
end
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, saveData)
mod:AddCallback(ModCallbacks.MC_PRE_MOD_UNLOAD, saveData)