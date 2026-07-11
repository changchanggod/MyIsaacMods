
CCGChallenges45768 =CCGChallenges45768 or RegisterMod("all you see is money", 1)
local mod= CCGChallenges45768
local json=require("json")
if mod:HasData() then
    local data=mod:LoadData()
    mod.Data=json.decode(data)
end
function mod:saveMyData()
    mod:SaveData(json.encode(mod.Data))
end
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.saveMyData)
include("script.AYSIM.all_you_see_is_money")
include("script.CG.conjugated_gemini")
include("script.TTT.turn_the_tables")
include("script.DNPUS.do_not_pick_up_shit")